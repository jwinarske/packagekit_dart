// example/list_repos.dart — list configured repositories.
// Mirrors: pkcon repo-list

import 'package:packagekit_dart/packagekit_dart.dart';

Future<void> main() async {
  final client = await PkClient.connect();
  print('Backend: ${client.properties?.backendName}\n');

  final tx = client.getRepoList();

  var enabled = 0;
  var disabled = 0;

  await for (final repo in tx.repoDetails) {
    final state = repo.enabled ? 'enabled ' : 'disabled';
    print('[$state]  ${repo.repoId.padRight(40)} ${repo.description}');
    if (repo.enabled) {
      enabled++;
    } else {
      disabled++;
    }
  }
  await tx.result;

  print('\n$enabled enabled, $disabled disabled.');
  await client.close();
}
