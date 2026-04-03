import 'package:flutter/material.dart';

import '../models/view_models.dart';
import 'status_badge.dart';

class PackageRow extends StatelessWidget {
  final PackageListItem item;
  final bool selected;
  final VoidCallback onTap;

  const PackageRow({
    super.key,
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      selected: selected,
      selectedTileColor: colorScheme.primaryContainer.withAlpha(60),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Row(
        children: [
          Expanded(
            child: Text(
              item.name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 8),
          StatusBadge(info: item.info),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Row(
          children: [
            Text(
              item.version,
              style: const TextStyle(
                fontSize: 15,
                fontFamily: 'monospace',
                height: 1.4,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.summary,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}
