import 'package:flutter/material.dart';
import 'package:packagekit_dart/packagekit_dart.dart';

/// Demonstrates: getRepoList, repoEnable, PkRepoDetail (repoId, description,
/// enabled), PkTransaction.repoDetails stream, PkFilter.notSource.
class ReposPage extends StatefulWidget {
  final PkClient client;
  const ReposPage({super.key, required this.client});

  @override
  State<ReposPage> createState() => _ReposPageState();
}

class _ReposPageState extends State<ReposPage> {
  final _repos = <PkRepoDetail>[];
  bool _loading = false;
  String? _error;
  bool _hideSource = false;

  Future<void> _load() async {
    setState(() {
      _repos.clear();
      _loading = true;
      _error = null;
    });

    final filters = <PkFilter>[
      if (_hideSource) PkFilter.notSource,
      if (!_hideSource) PkFilter.none,
    ];

    final tx = widget.client.getRepoList(filters: filters);

    await for (final repo in tx.repoDetails) {
      if (!mounted) return;
      setState(() => _repos.add(repo));
    }

    try {
      await tx.result;
    } on PkTransactionException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _toggleRepo(PkRepoDetail repo) async {
    final enable = !repo.enabled;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${enable ? "Enable" : "Disable"} Repository'),
        content: Text(
            '${enable ? "Enable" : "Disable"} "${repo.description}" (${repo.repoId})?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(enable ? 'Enable' : 'Disable')),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    try {
      final tx = widget.client.repoEnable(repo.repoId, enabled: enable);
      await tx.result;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Repository ${repo.repoId} ${enable ? "enabled" : "disabled"}')));
        _load(); // Refresh the list
      }
    } on PkTransactionException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: ${e.message}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Repositories'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Hide source repos'),
                  selected: _hideSource,
                  onSelected: (v) => setState(() => _hideSource = v),
                ),
                const Spacer(),
                Text('${_repos.length} repos'),
              ],
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(_error!,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          Expanded(
            child: _repos.isEmpty && !_loading
                ? const Center(
                    child: Text('Tap refresh to load repositories'))
                : ListView.builder(
                    itemCount: _repos.length,
                    itemBuilder: (ctx, i) {
                      final repo = _repos[i];
                      return SwitchListTile(
                        title: Text(repo.description),
                        subtitle: Text(repo.repoId),
                        value: repo.enabled,
                        onChanged: (_) => _toggleRepo(repo),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
