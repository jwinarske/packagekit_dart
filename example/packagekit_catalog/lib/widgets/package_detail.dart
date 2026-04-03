import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packagekit_dart/packagekit_dart.dart';

import '../models/view_models.dart';
import '../providers/operation_provider.dart';
import '../providers/package_detail_provider.dart';
import 'status_badge.dart';

class PackageDetailPanel extends ConsumerWidget {
  final PackageListItem item;

  const PackageDetailPanel({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(packageDetailProvider(item.package.id.raw));
    final operation = ref.watch(operationProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 24),
                onPressed:
                    () =>
                        ref.read(selectedPackageProvider.notifier).state = null,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                item.version,
                style: const TextStyle(
                  fontSize: 17,
                  fontFamily: 'monospace',
                  height: 1.4,
                ),
              ),
              StatusBadge(info: item.info),
            ],
          ),
          const SizedBox(height: 12),
          Text(item.summary, style: const TextStyle(fontSize: 17, height: 1.5)),
          const Divider(height: 32),
          detailAsync.when(
            data:
                (detail) =>
                    detail != null
                        ? _DetailContent(detail: detail)
                        : const SizedBox.shrink(),
            loading:
                () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                ),
            error: (e, _) => Text('Error loading details: $e'),
          ),
          const SizedBox(height: 20),
          if (operation != null)
            _OperationProgress(operation: operation)
          else
            _ActionButtons(item: item),
        ],
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  final PkPackageDetail detail;

  const _DetailContent({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (detail.description.isNotEmpty) ...[
          Text(
            'Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.4,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            detail.description,
            style: const TextStyle(fontSize: 16, height: 1.6),
          ),
          const SizedBox(height: 16),
        ],
        _InfoRow(label: 'License', value: detail.license),
        _InfoRow(label: 'Group', value: detail.group),
        _InfoRow(label: 'Size', value: detail.sizeFormatted),
        if (detail.url.isNotEmpty) _InfoRow(label: 'URL', value: detail.url),
        _InfoRow(label: 'Arch', value: detail.id.arch),
        _InfoRow(label: 'Source', value: detail.id.data),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.5,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends ConsumerWidget {
  final PackageListItem item;

  const _ActionButtons({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = item.package.id.raw;

    return Row(
      children: [
        if (item.isInstalled) ...[
          OutlinedButton.icon(
            onPressed:
                () => ref.read(operationProvider.notifier).removePackages([id]),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Remove', style: TextStyle(fontSize: 17)),
          ),
        ] else ...[
          FilledButton.icon(
            onPressed:
                () =>
                    ref.read(operationProvider.notifier).installPackages([id]),
            icon: const Icon(Icons.download),
            label: const Text('Install', style: TextStyle(fontSize: 17)),
          ),
        ],
      ],
    );
  }
}

class _OperationProgress extends StatelessWidget {
  final PackageOperation operation;

  const _OperationProgress({required this.operation});

  @override
  Widget build(BuildContext context) {
    final label = switch (operation.type) {
      OperationType.install => 'Installing',
      OperationType.remove => 'Removing',
      OperationType.update => 'Updating',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label ${operation.packageName}...',
          style: const TextStyle(fontSize: 17, height: 1.4),
        ),
        const SizedBox(height: 10),
        if (operation.progress != null)
          StreamBuilder<PkProgress>(
            stream: operation.progress,
            builder: (context, snapshot) {
              final progress = snapshot.data;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (progress != null && progress.percentageKnown)
                    LinearProgressIndicator(value: progress.percentage / 100)
                  else
                    const LinearProgressIndicator(),
                  if (progress != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        progress.progressLabel,
                        style: const TextStyle(fontSize: 15, height: 1.4),
                      ),
                    ),
                ],
              );
            },
          )
        else
          const LinearProgressIndicator(),
      ],
    );
  }
}
