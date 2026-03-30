// example/install.dart — simulate then install with live progress.
//
// Demonstrates the two-transaction simulate-first pattern:
//   1. Resolve package name -> package ID
//   2. Simulate install -> show full dep plan (no system changes)
//   3. User confirms -> execute real install
//
// Mirrors: pkcon install <name>

import 'dart:io';
import 'package:packagekit_dart/packagekit_dart.dart';

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart run example/install.dart <package_name>');
    return;
  }

  final client = await PkClient.connect();
  print('Backend: ${client.properties?.backendName}\n');

  // Step 1: resolve name -> package ID
  final resolved = <String>[];
  final resolve =
      client.resolve(args, filters: [PkFilter.notInstalled, PkFilter.newest]);
  await for (final pkg in resolve.packages) {
    resolved.add(pkg.id.raw);
  }
  await resolve.result;

  if (resolved.isEmpty) {
    print('Package not found: ${args.join(", ")}');
    await client.close();
    return;
  }

  // Step 2: simulate install -> full dep plan
  //
  // PackageKit performs full dependency resolution in the backend (libsolv
  // for DNF/Zypper, libapt-pkg for APT). The plan includes every package
  // that will be added, updated, or removed as a consequence.
  //
  // TOCTOU: this plan reflects the database NOW. The real install below
  // re-resolves independently. Pass the original names (not plan.allIds)
  // so the backend can recompute against the current state at that moment.
  print('Resolving dependencies...');
  final plan = await client.simulateInstall(resolved);

  if (plan.isEmpty) {
    print('Nothing to do - all packages already installed.');
    await client.close();
    return;
  }

  // Display the plan
  print('\nThe following changes will be made:');
  for (final p in plan.installing) {
    print('  + ${p.id.name.padRight(32)} ${p.id.version}  [new]');
  }
  for (final p in plan.updating) {
    print('  ^ ${p.id.name.padRight(32)} ${p.id.version}  [upgrade]');
  }
  for (final p in plan.removing) {
    print('  - ${p.id.name.padRight(32)} ${p.id.version}  [remove]');
  }
  for (final p in plan.downgrading) {
    print('  v ${p.id.name.padRight(32)} ${p.id.version}  [downgrade]');
  }
  print('\n${plan.changeCount} package(s) will change.');
  stdout.write('\nProceed? [Y/n] ');

  // Step 3: confirm -> execute
  final answer = stdin.readLineSync()?.trim().toLowerCase() ?? '';
  if (answer == 'n') {
    print('Aborted.');
    await client.close();
    return;
  }

  // Real install — backend re-resolves from scratch.
  final tx =
      client.installPackages(resolved, flags: [PkTransactionFlag.onlyTrusted]);

  // Handle EULA prompts
  tx.eulaRequired.listen((e) async {
    print('\n! EULA required for ${PkPackageId.parse(e.packageId).name}');
    print(e.licenseAgreement);
    stdout.write('Accept? [Y/n] ');
    final a = stdin.readLineSync()?.trim().toLowerCase() ?? '';
    if (a != 'n') {
      final accept = client.acceptEula(e.eulaId);
      await accept.result;
    }
  });

  // Live progress
  String lastPkg = '';
  print('');
  await for (final p in tx.progress) {
    if (!p.isItem && p.packageId.isNotEmpty && p.packageId != lastPkg) {
      lastPkg = p.packageId;
      print('  ${PkPackageId.parse(p.packageId).name}');
    }
    if (!p.isItem) {
      final pct = p.percentageKnown ? '${p.percentage}%' : '...';
      stdout.write('\r    ${p.status.name.padRight(20)} $pct      ');
    }
  }
  stdout.writeln();

  try {
    final r = await tx.result;
    print('\nDone in ${r.runtimeMs}ms');
  } on PkTransactionException catch (e) {
    print('\nFailed: ${e.message}');
  }

  await client.close();
}
