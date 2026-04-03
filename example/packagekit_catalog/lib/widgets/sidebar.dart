import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packagekit_dart/packagekit_dart.dart';

import '../models/view_models.dart';
import '../providers/packagekit_provider.dart';

class AppSidebar extends ConsumerWidget {
  final int currentIndex;
  final void Function(int index) onNavigate;

  const AppSidebar({
    super.key,
    required this.currentIndex,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connState = ref.watch(packageKitProvider);
    final backendName =
        connState is PkConnected
            ? connState.client.properties?.backendName ?? 'Unknown'
            : '...';

    return SizedBox(
      width: 280,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PackageKit',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  'Backend: $backendName',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _NavItem(
            icon: Icons.search,
            label: 'Catalog',
            index: 0,
            currentIndex: currentIndex,
            onTap: onNavigate,
          ),
          _NavItem(
            icon: Icons.inventory_2,
            label: 'Installed',
            index: 1,
            currentIndex: currentIndex,
            onTap: onNavigate,
          ),
          _NavItem(
            icon: Icons.system_update_alt,
            label: 'Updates',
            index: 2,
            currentIndex: currentIndex,
            onTap: onNavigate,
          ),
          _NavItem(
            icon: Icons.dns,
            label: 'Repositories',
            index: 3,
            currentIndex: currentIndex,
            onTap: onNavigate,
          ),
          const Spacer(),
          if (connState is PkConnected) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: _DaemonInfo(client: connState.client),
            ),
          ],
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;
  final void Function(int) onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = currentIndex == index;
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(
        icon,
        color: selected ? colorScheme.primary : null,
        size: 28,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 20,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          color: selected ? colorScheme.primary : null,
        ),
      ),
      selected: selected,
      selectedTileColor: colorScheme.primaryContainer.withAlpha(80),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      onTap: () => onTap(index),
    );
  }
}

class _DaemonInfo extends StatelessWidget {
  final PkClient client;

  const _DaemonInfo({required this.client});

  @override
  Widget build(BuildContext context) {
    final props = client.properties;
    if (props == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Distro: ${props.distroId}',
          style: Theme.of(context).textTheme.labelSmall,
        ),
        Text(
          'Version: ${props.versionMajor}.${props.versionMinor}.${props.versionMicro}',
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}
