import 'dart:async';

import 'package:flutter/material.dart';
import 'package:packagekit_dart/packagekit_dart.dart';

/// Demonstrates: PkClient.properties, PkManagerProps, PkClient.daemonEvents,
/// PkDaemonEvent sealed class (PkPropsEvent, PkUpdatesChangedEvent,
/// PkRepoListChangedEvent, PkNetworkStateChangedEvent), refreshCache.
class DaemonInfoPage extends StatefulWidget {
  final PkClient client;
  const DaemonInfoPage({super.key, required this.client});

  @override
  State<DaemonInfoPage> createState() => _DaemonInfoPageState();
}

class _DaemonInfoPageState extends State<DaemonInfoPage> {
  PkManagerProps? _props;
  final _events = <String>[];
  StreamSubscription<PkDaemonEvent>? _sub;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _props = widget.client.properties;
    _sub = widget.client.daemonEvents.listen(_onEvent);
  }

  void _onEvent(PkDaemonEvent event) {
    if (!mounted) return;
    setState(() {
      switch (event) {
        case PkPropsEvent(:final props):
          _props = props;
          _events.insert(0, 'PropsChanged: backend=${props.backendName}');
        case PkUpdatesChangedEvent():
          _events.insert(0, 'UpdatesChanged');
        case PkRepoListChangedEvent():
          _events.insert(0, 'RepoListChanged');
        case PkNetworkStateChangedEvent(:final state):
          _events.insert(0, 'NetworkStateChanged: $state');
      }
    });
  }

  Future<void> _refreshCache() async {
    setState(() => _refreshing = true);
    try {
      final tx = widget.client.refreshCache(force: true);
      await tx.result;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cache refreshed successfully')));
      }
    } on PkTransactionException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Refresh failed: ${e.exit.name}')));
      }
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final props = _props;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daemon Info'),
        actions: [
          IconButton(
            onPressed: _refreshing ? null : _refreshCache,
            icon: _refreshing
                ? const SizedBox.square(
                    dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.refresh),
            tooltip: 'Refresh package cache',
          ),
        ],
      ),
      body: props == null
          ? const Center(child: Text('No properties available'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SectionHeader('Backend'),
                _PropTile('Name', props.backendName),
                _PropTile('Description', props.backendDescription),
                _PropTile('Author', props.backendAuthor),
                const Divider(),
                _SectionHeader('Daemon'),
                _PropTile('Version',
                    '${props.versionMajor}.${props.versionMinor}.${props.versionMicro}'),
                _PropTile('Distribution', props.distroId),
                _PropTile('Locked', props.locked ? 'Yes' : 'No'),
                _PropTile('Network State', '${props.networkState}'),
                _PropTile('MIME Types', props.mimeTypes.join(', ')),
                const Divider(),
                _SectionHeader('Supported Filters (bitfield)'),
                _PropTile('Filters', '0x${props.filters.toRadixString(16)}'),
                _PropTile('Roles', '0x${props.roles.toRadixString(16)}'),
                _PropTile('Groups', '0x${props.groups.toRadixString(16)}'),
                const Divider(),
                _SectionHeader('Daemon Events (live)'),
                if (_events.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('No events received yet. '
                        'Try refreshing the cache or toggling a repo.'),
                  ),
                for (final e in _events.take(50))
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.event, size: 16),
                    title: Text(e, style: const TextStyle(fontSize: 13)),
                  ),
              ],
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 4),
        child: Text(title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
      );
}

class _PropTile extends StatelessWidget {
  final String label;
  final String value;
  const _PropTile(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: 160,
                child: Text(label,
                    style: const TextStyle(fontWeight: FontWeight.w500))),
            Expanded(child: SelectableText(value)),
          ],
        ),
      );
}
