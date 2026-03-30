// example/search.dart — search for packages by name, print results.
// Mirrors: pkcon search name <query>

import 'package:packagekit_dart/packagekit_dart.dart';

Future<void> main(List<String> args) async {
  final query = args.isEmpty ? 'firefox' : args[0];
  final client = await PkClient.connect();

  print('Backend: ${client.properties?.backendName}');
  print('Searching for "$query"...\n');

  final tx = client.searchName(query, filters: [
    PkFilter.none, // no filter — show installed + available
  ]);

  final counts = <PkInfo, int>{};
  await for (final pkg in tx.packages) {
    counts[pkg.info] = (counts[pkg.info] ?? 0) + 1;
    final state = pkg.info == PkInfo.installed ? '[installed]' : '[available]';
    print('${pkg.id.name.padRight(40)} ${pkg.id.version.padRight(20)} $state');
    print('  ${pkg.summary}');
  }

  await tx.result;
  print('\n${counts[PkInfo.installed] ?? 0} installed, '
      '${counts[PkInfo.available] ?? 0} available.');
  await client.close();
}
