import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/view_models.dart';
import '../providers/package_detail_provider.dart';
import 'package_row.dart';

class PackageListView extends ConsumerWidget {
  final List<PackageListItem> packages;

  const PackageListView({super.key, required this.packages});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedPackageProvider);

    return ListView.builder(
      itemCount: packages.length,
      itemExtent: 80,
      itemBuilder: (context, index) {
        final item = packages[index];
        return PackageRow(
          item: item,
          selected: selected?.package.id.raw == item.package.id.raw,
          onTap: () => ref.read(selectedPackageProvider.notifier).state = item,
        );
      },
    );
  }
}
