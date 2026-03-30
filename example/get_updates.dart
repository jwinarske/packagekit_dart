// example/get_updates.dart — list available updates with security classification.
// Mirrors: pkcon get-updates

import 'package:packagekit_dart/packagekit_dart.dart';

Future<void> main() async {
  final client = await PkClient.connect();
  print('Checking for updates...\n');

  final tx = client.getUpdates();
  final ids = <String>[];

  await for (final pkg in tx.packages) {
    ids.add(pkg.id.raw);
    final kind = switch (pkg.info) {
      PkInfo.security => '[security]',
      PkInfo.bugfix => '[bugfix]  ',
      PkInfo.enhancement => '[enhance] ',
      PkInfo.low => '[low]     ',
      _ => '[normal]  ',
    };
    print('$kind  ${pkg.id.name.padRight(32)} ${pkg.id.version}');
  }
  await tx.result;

  if (ids.isEmpty) {
    print('System is up to date.');
    await client.close();
    return;
  }

  // Fetch update details for all packages
  print('\n--- Update details ---');
  final details = client.getUpdateDetail(ids);
  await for (final d in details.updateDetails) {
    if (d.cveUrls.isNotEmpty) {
      print('${PkPackageId.parse(d.packageId).name}: '
          'CVEs: ${d.cveUrls.join(", ")}');
    }
  }
  await details.result;

  await client.close();
}
