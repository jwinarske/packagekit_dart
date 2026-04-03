import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/packages_provider.dart';
import '../widgets/package_list.dart';

class InstalledScreen extends ConsumerWidget {
  const InstalledScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final installed = ref.watch(installedPackagesProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                'Installed',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Spacer(),
              installed.whenOrNull(
                    data:
                        (pkgs) => Text(
                          '${pkgs.length} packages',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                  ) ??
                  const SizedBox.shrink(),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: installed.when(
            data:
                (packages) =>
                    packages.isEmpty
                        ? const Center(
                          child: Text('No installed packages found'),
                        )
                        : PackageListView(packages: packages),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ),
      ],
    );
  }
}
