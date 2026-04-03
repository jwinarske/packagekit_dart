import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packagekit_dart/packagekit_dart.dart';

import '../models/view_models.dart';
import 'packagekit_provider.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider.autoDispose<List<PackageListItem>>(
  (ref) async {
    final query = ref.watch(searchQueryProvider);
    if (query.isEmpty) return [];

    final connState = ref.watch(packageKitProvider);
    if (connState is! PkConnected) return [];

    final client = connState.client;
    final tx = client.searchName(query, filters: [PkFilter.none]);
    final packages = <PackageListItem>[];
    await for (final pkg in tx.packages) {
      packages.add(PackageListItem(package: pkg));
    }
    await tx.result;
    return packages;
  },
);

final installedPackagesProvider =
    FutureProvider.autoDispose<List<PackageListItem>>((ref) async {
      final connState = ref.watch(packageKitProvider);
      if (connState is! PkConnected) return [];

      final client = connState.client;
      final tx = client.getPackages(filters: [PkFilter.installed]);
      final packages = <PackageListItem>[];
      await for (final pkg in tx.packages) {
        packages.add(PackageListItem(package: pkg));
      }
      await tx.result;
      packages.sort((a, b) => a.name.compareTo(b.name));
      return packages;
    });

final updatesProvider = FutureProvider.autoDispose<List<PackageListItem>>((
  ref,
) async {
  final connState = ref.watch(packageKitProvider);
  if (connState is! PkConnected) return [];

  final client = connState.client;
  final tx = client.getUpdates(filters: [PkFilter.none]);
  final packages = <PackageListItem>[];
  await for (final pkg in tx.packages) {
    packages.add(PackageListItem(package: pkg));
  }
  await tx.result;
  packages.sort((a, b) => a.name.compareTo(b.name));
  return packages;
});

final reposProvider = FutureProvider.autoDispose<List<PkRepoDetail>>((
  ref,
) async {
  final connState = ref.watch(packageKitProvider);
  if (connState is! PkConnected) return [];

  final client = connState.client;
  final tx = client.getRepoList(filters: [PkFilter.none]);
  final repos = <PkRepoDetail>[];
  await for (final repo in tx.repoDetails) {
    repos.add(repo);
  }
  await tx.result;
  repos.sort((a, b) => a.repoId.compareTo(b.repoId));
  return repos;
});
