// example/simulate_install.dart — show dep resolution output without installing.
// Useful for scripting: exits 0 if nothing to do, 1 if changes needed.
// Mirrors: pkcon install --only-download --simulate <name>

import 'dart:io';
import 'package:packagekit_dart/packagekit_dart.dart';

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart run example/simulate_install.dart <package_name>...');
    exit(2);
  }

  final client = await PkClient.connect();

  // Resolve names first
  final ids = <String>[];
  final resolve = client.resolve(args, filters: [PkFilter.newest]);
  await for (final pkg in resolve.packages) {
    ids.add(pkg.id.raw);
  }
  await resolve.result;

  if (ids.isEmpty) {
    stderr.writeln('No packages found matching: ${args.join(", ")}');
    await client.close();
    exit(2);
  }

  final plan = await client.simulateInstall(ids);

  if (plan.isEmpty) {
    print('Already installed - nothing to do.');
    await client.close();
    exit(0);
  }

  // Machine-readable output: one line per package change
  for (final p in plan.installing) {
    print('+install ${p.id.raw}');
  }
  for (final p in plan.updating) {
    print('+update  ${p.id.raw}');
  }
  for (final p in plan.removing) {
    print('-remove  ${p.id.raw}');
  }
  for (final p in plan.downgrading) {
    print('+downgrade ${p.id.raw}');
  }
  for (final p in plan.obsoleting) {
    print('-obsolete ${p.id.raw}');
  }

  await client.close();
  exit(1); // 1 = changes needed (caller can check)
}
