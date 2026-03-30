import 'dart:async';

import 'package:flutter/material.dart';
import 'package:packagekit_dart/packagekit_dart.dart';

import 'detail_sheet.dart';

/// Demonstrates: searchName, searchDetails, searchFiles, resolve,
/// PkFilter (combine, installed/notInstalled/newest), PkPackage, PkPackageId,
/// PkInfo, PkTransaction.packages stream, PkTransaction.cancel,
/// PkTransaction.progress stream, PkProgress, PkStatus.
class SearchPage extends StatefulWidget {
  final PkClient client;
  const SearchPage({super.key, required this.client});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

enum _SearchMode { name, details, files, resolve }

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  _SearchMode _mode = _SearchMode.name;
  bool _filterInstalled = false;
  bool _filterNewest = false;
  final _results = <PkPackage>[];
  bool _searching = false;
  String? _error;
  String _statusLabel = '';
  int _progressPct = -1;
  PkTransaction? _activeTx;

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _results.clear();
      _searching = true;
      _error = null;
      _statusLabel = '';
      _progressPct = -1;
    });

    final filters = <PkFilter>[
      if (_filterInstalled) PkFilter.installed,
      if (!_filterInstalled) PkFilter.none,
      if (_filterNewest) PkFilter.newest,
    ];

    final PkTransaction tx;
    switch (_mode) {
      case _SearchMode.name:
        tx = widget.client.searchName(query, filters: filters);
      case _SearchMode.details:
        tx = widget.client.searchDetails(query, filters: filters);
      case _SearchMode.files:
        tx = widget.client.searchFiles(query, filters: filters);
      case _SearchMode.resolve:
        tx = widget.client.resolve([query], filters: filters);
    }
    _activeTx = tx;

    // Listen to progress stream for status/percentage updates
    tx.progress.listen((p) {
      if (!mounted) return;
      setState(() {
        _statusLabel = p.status.name;
        _progressPct = p.percentageKnown ? p.percentage : -1;
      });
    });

    // Listen to error stream
    tx.errors.listen((e) {
      if (mounted) setState(() => _error = e.details);
    });

    await for (final pkg in tx.packages) {
      if (!mounted) return;
      setState(() => _results.add(pkg));
    }

    try {
      await tx.result;
    } on PkTransactionException catch (e) {
      if (mounted) setState(() => _error = '${e.exit.name}: ${e.message}');
    }

    if (mounted) {
      setState(() {
        _searching = false;
        _activeTx = null;
      });
    }
  }

  void _cancelSearch() {
    _activeTx?.cancel();
  }

  String _infoLabel(PkInfo info) => switch (info) {
        PkInfo.installed => 'installed',
        PkInfo.available => 'available',
        PkInfo.blocked => 'blocked',
        _ => info.name,
      };

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Packages')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: _mode == _SearchMode.files
                              ? '/usr/bin/...'
                              : 'Package name...',
                          border: const OutlineInputBorder(),
                          suffixIcon: _searching
                              ? IconButton(
                                  icon: const Icon(Icons.cancel),
                                  onPressed: _cancelSearch,
                                  tooltip: 'Cancel search',
                                )
                              : IconButton(
                                  icon: const Icon(Icons.search),
                                  onPressed: _search,
                                ),
                        ),
                        onSubmitted: (_) => _search(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      SegmentedButton<_SearchMode>(
                        segments: const [
                          ButtonSegment(
                              value: _SearchMode.name, label: Text('Name')),
                          ButtonSegment(
                              value: _SearchMode.details,
                              label: Text('Details')),
                          ButtonSegment(
                              value: _SearchMode.files, label: Text('Files')),
                          ButtonSegment(
                              value: _SearchMode.resolve,
                              label: Text('Resolve')),
                        ],
                        selected: {_mode},
                        onSelectionChanged: (s) =>
                            setState(() => _mode = s.first),
                      ),
                      const SizedBox(width: 12),
                      FilterChip(
                        label: const Text('Installed'),
                        selected: _filterInstalled,
                        onSelected: (v) =>
                            setState(() => _filterInstalled = v),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Newest'),
                        selected: _filterNewest,
                        onSelected: (v) => setState(() => _filterNewest = v),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_searching)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                  const SizedBox(width: 8),
                  Text(_statusLabel),
                  if (_progressPct >= 0) Text(' $_progressPct%'),
                  const Spacer(),
                  Text('${_results.length} results'),
                ],
              ),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(_error!,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.error)),
            ),
          Expanded(
            child: _results.isEmpty && !_searching
                ? const Center(child: Text('Search for packages above'))
                : ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (ctx, i) {
                      final pkg = _results[i];
                      return ListTile(
                        title: Text(pkg.id.name),
                        subtitle: Text(
                            '${pkg.id.version} (${pkg.id.arch})\n${pkg.summary}'),
                        isThreeLine: true,
                        trailing: Chip(
                          label: Text(_infoLabel(pkg.info)),
                          backgroundColor:
                              pkg.info == PkInfo.installed
                                  ? Colors.green.withValues(alpha: 0.15)
                                  : null,
                        ),
                        onTap: () => showDetailSheet(
                            context, widget.client, pkg.id.raw),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
