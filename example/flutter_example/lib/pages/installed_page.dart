import 'package:flutter/material.dart';
import 'package:packagekit_dart/packagekit_dart.dart';

import 'detail_sheet.dart';

/// Demonstrates: getPackages with PkFilter.installed, PkFilter.combine,
/// PkFilter.gui/notGui/development/notDevelopment/application/free_/source,
/// PkTransaction.packages stream, PkPackage, PkPackageId.parse/.raw/.toString.
class InstalledPage extends StatefulWidget {
  final PkClient client;
  const InstalledPage({super.key, required this.client});

  @override
  State<InstalledPage> createState() => _InstalledPageState();
}

class _InstalledPageState extends State<InstalledPage> {
  final _packages = <PkPackage>[];
  bool _loading = false;
  String? _error;

  // Demonstrate various PkFilter values
  bool _guiOnly = false;
  bool _devOnly = false;
  bool _appOnly = false;

  Future<void> _load() async {
    setState(() {
      _packages.clear();
      _loading = true;
      _error = null;
    });

    final filters = <PkFilter>[
      PkFilter.installed,
      if (_guiOnly) PkFilter.gui,
      if (_devOnly) PkFilter.development,
      if (_appOnly) PkFilter.application,
    ];

    final tx = widget.client.getPackages(filters: filters);

    tx.errors.listen((e) {
      if (mounted) setState(() => _error = e.details);
    });

    await for (final pkg in tx.packages) {
      if (!mounted) return;
      setState(() => _packages.add(pkg));
    }

    try {
      final result = await tx.result;
      if (mounted && result.success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Loaded ${_packages.length} packages in ${result.runtimeMs}ms')));
      }
    } on PkTransactionException catch (e) {
      if (mounted) setState(() => _error = '${e.exit.name} (${e.runtimeMs}ms)');
    }

    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Installed Packages'),
        actions: [
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          IconButton(
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.download),
            tooltip: 'Load installed packages',
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
                  label: const Text('GUI'),
                  selected: _guiOnly,
                  onSelected: (v) => setState(() => _guiOnly = v),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Development'),
                  selected: _devOnly,
                  onSelected: (v) => setState(() => _devOnly = v),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Application'),
                  selected: _appOnly,
                  onSelected: (v) => setState(() => _appOnly = v),
                ),
                const Spacer(),
                Text('${_packages.length} packages'),
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
            child: _packages.isEmpty && !_loading
                ? const Center(
                    child: Text('Tap the download button to load packages'))
                : ListView.builder(
                    itemCount: _packages.length,
                    itemBuilder: (ctx, i) {
                      final pkg = _packages[i];
                      return ListTile(
                        title: Text(pkg.id.name),
                        subtitle: Text(
                            '${pkg.id.version} (${pkg.id.arch}) - ${pkg.id.data}'),
                        trailing: Text(pkg.info.name,
                            style: const TextStyle(fontSize: 12)),
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
