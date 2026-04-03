import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/operation_provider.dart';
import '../providers/packages_provider.dart';
import '../widgets/package_list.dart';

class UpdatesScreen extends ConsumerWidget {
  const UpdatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updates = ref.watch(updatesProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text('Updates', style: Theme.of(context).textTheme.headlineSmall),
              const Spacer(),
              updates.whenOrNull(
                    data:
                        (pkgs) =>
                            pkgs.isEmpty
                                ? null
                                : FilledButton.icon(
                                  onPressed: () {
                                    final ids =
                                        pkgs
                                            .map((p) => p.package.id.raw)
                                            .toList();
                                    ref
                                        .read(operationProvider.notifier)
                                        .updatePackages(ids);
                                  },
                                  icon: const Icon(Icons.system_update_alt),
                                  label: const Text('Update All'),
                                ),
                  ) ??
                  const SizedBox.shrink(),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: updates.when(
            data:
                (packages) =>
                    packages.isEmpty
                        ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 64,
                                color: Colors.green,
                              ),
                              SizedBox(height: 16),
                              Text('All packages are up to date'),
                            ],
                          ),
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
