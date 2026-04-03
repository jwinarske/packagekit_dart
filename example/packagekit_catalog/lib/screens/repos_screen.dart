import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/packages_provider.dart';

class ReposScreen extends ConsumerWidget {
  const ReposScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repos = ref.watch(reposProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                'Repositories',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Spacer(),
              repos.whenOrNull(
                    data:
                        (r) => Text(
                          '${r.length} repositories',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                  ) ??
                  const SizedBox.shrink(),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: repos.when(
            data:
                (repoList) =>
                    repoList.isEmpty
                        ? const Center(child: Text('No repositories found'))
                        : ListView.builder(
                          itemCount: repoList.length,
                          itemExtent: 80,
                          itemBuilder: (context, index) {
                            final repo = repoList[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              leading: Icon(
                                repo.enabled
                                    ? Icons.check_circle
                                    : Icons.cancel_outlined,
                                color:
                                    repo.enabled ? Colors.green : Colors.grey,
                                size: 28,
                              ),
                              title: Text(
                                repo.repoId,
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  repo.description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 15,
                                    height: 1.4,
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              trailing: Text(
                                repo.enabled ? 'Enabled' : 'Disabled',
                                style: TextStyle(
                                  fontSize: 15,
                                  color:
                                      repo.enabled ? Colors.green : Colors.grey,
                                ),
                              ),
                            );
                          },
                        ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ),
      ],
    );
  }
}
