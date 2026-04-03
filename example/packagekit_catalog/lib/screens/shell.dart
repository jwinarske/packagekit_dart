import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/view_models.dart';
import '../providers/package_detail_provider.dart';
import '../providers/packagekit_provider.dart';
import '../providers/packages_provider.dart';
import '../widgets/package_detail.dart';
import '../widgets/sidebar.dart';
import 'catalog_screen.dart';
import 'installed_screen.dart';
import 'repos_screen.dart';
import 'updates_screen.dart';

final screenIndexProvider = StateProvider<int>((ref) => 0);

const _screens = [
  CatalogScreen(),
  InstalledScreen(),
  UpdatesScreen(),
  ReposScreen(),
];

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connState = ref.watch(packageKitProvider);
    final selected = ref.watch(selectedPackageProvider);
    final screenIndex = ref.watch(screenIndexProvider);

    return Scaffold(
      body: switch (connState) {
        PkConnecting() => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Connecting to PackageKit...'),
            ],
          ),
        ),
        PkConnectionFailed(:final error) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Connection failed: $error'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed:
                    () => ref.read(packageKitProvider.notifier).reconnect(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        PkConnected() => Row(
          children: [
            AppSidebar(
              currentIndex: screenIndex,
              onNavigate: (index) {
                ref.read(selectedPackageProvider.notifier).state = null;
                ref.read(searchQueryProvider.notifier).state = '';
                ref.read(screenIndexProvider.notifier).state = index;
              },
            ),
            const VerticalDivider(width: 1),
            Expanded(child: _screens[screenIndex]),
            if (selected != null) ...[
              const VerticalDivider(width: 1),
              SizedBox(
                width: 320,
                child: PackageDetailPanel(
                  key: ValueKey(selected.package.id.raw),
                  item: selected,
                ),
              ),
            ],
          ],
        ),
      },
    );
  }
}
