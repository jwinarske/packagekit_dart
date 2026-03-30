import 'dart:async';

import 'package:flutter/material.dart';
import 'package:packagekit_dart/packagekit_dart.dart';

import 'detail_sheet.dart';

/// Demonstrates: getUpdates, getUpdateDetail, simulateUpdate, updatePackages,
/// downloadPackages, PkUpdateDetail (cveUrls, bugzillaUrls, vendorUrls,
/// changelog, updateText, restart, state, issued, updated, updates, obsoletes),
/// PkTransactionFlag (onlyTrusted, simulate, onlyDownload),
/// PkTransaction.progress, PkTransaction.messages, PkTransaction.errors,
/// PkTransaction.requireRestart, PkTransaction.result, PkTransactionResult,
/// PkExit, PkError, getDistroUpgrades.
class UpdatesPage extends StatefulWidget {
  final PkClient client;
  const UpdatesPage({super.key, required this.client});

  @override
  State<UpdatesPage> createState() => _UpdatesPageState();
}

class _UpdatesPageState extends State<UpdatesPage> {
  final _updates = <PkPackage>[];
  final _updateDetails = <String, PkUpdateDetail>{};
  bool _loading = false;
  String? _error;
  String _statusText = '';

  // Track live operation progress
  String? _opLabel;
  int _opProgress = -1;
  final _messages = <String>[];
  bool _restartRequired = false;

  Future<void> _loadUpdates() async {
    setState(() {
      _updates.clear();
      _updateDetails.clear();
      _loading = true;
      _error = null;
      _statusText = 'Checking for updates...';
    });

    // getUpdates
    final tx = widget.client.getUpdates();

    tx.progress.listen((p) {
      if (mounted) setState(() => _statusText = p.progressLabel);
    });

    tx.errors.listen((e) {
      if (mounted) setState(() => _error = e.details);
    });

    await for (final pkg in tx.packages) {
      if (!mounted) return;
      setState(() => _updates.add(pkg));
    }

    try {
      await tx.result;
    } on PkTransactionException catch (e) {
      if (mounted) setState(() => _error = '${e.exit.name}: ${e.message}');
    }

    // Fetch update details for each
    if (_updates.isNotEmpty) {
      setState(() => _statusText = 'Fetching update details...');
      try {
        final ids = _updates.map((u) => u.id.raw).toList();
        final detTx = widget.client.getUpdateDetail(ids);
        await for (final ud in detTx.updateDetails) {
          if (!mounted) return;
          setState(() => _updateDetails[ud.packageId] = ud);
        }
        await detTx.result;
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _loading = false;
        _statusText = '${_updates.length} updates available';
      });
    }
  }

  Future<void> _simulateUpdateAll() async {
    if (_updates.isEmpty) return;
    final ids = _updates.map((u) => u.id.raw).toList();

    setState(() {
      _opLabel = 'Simulating update...';
      _opProgress = -1;
    });

    try {
      final plan = await widget.client.simulateUpdate(ids);
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Update Plan'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${plan.changeCount} total changes:'),
                  if (plan.updating.isNotEmpty)
                    Text('  Updating: ${plan.updating.length}'),
                  if (plan.installing.isNotEmpty)
                    Text('  Installing: ${plan.installing.length}'),
                  if (plan.removing.isNotEmpty)
                    Text('  Removing: ${plan.removing.length}'),
                  if (plan.obsoleting.isNotEmpty)
                    Text('  Obsoleting: ${plan.obsoleting.length}'),
                  if (plan.downgrading.isNotEmpty)
                    Text('  Downgrading: ${plan.downgrading.length}'),
                  if (plan.reinstalling.isNotEmpty)
                    Text('  Reinstalling: ${plan.reinstalling.length}'),
                  const SizedBox(height: 8),
                  if (plan.allIds.isNotEmpty)
                    Text('Package IDs:\n${plan.allIds.take(20).join('\n')}',
                        style: const TextStyle(fontSize: 11)),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
          ],
        ),
      );
    } on PkTransactionException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Simulate failed: ${e.exit.name}')));
      }
    }

    if (mounted) setState(() => _opLabel = null);
  }

  Future<void> _downloadAll() async {
    if (_updates.isEmpty) return;
    final ids = _updates.map((u) => u.id.raw).toList();

    setState(() {
      _opLabel = 'Downloading packages...';
      _opProgress = -1;
      _messages.clear();
    });

    final tx = widget.client.downloadPackages(ids);

    tx.progress.listen((p) {
      if (!mounted) return;
      setState(() {
        _opProgress = p.percentageKnown ? p.percentage : -1;
        _opLabel = 'Downloading... ${p.progressLabel}';
      });
    });

    tx.messages.listen((m) {
      if (mounted) setState(() => _messages.add(m.details));
    });

    try {
      final result = await tx.result;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Download complete in ${result.runtimeMs}ms')));
      }
    } on PkTransactionException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Download failed: ${e.exit.name}')));
      }
    }

    if (mounted) setState(() => _opLabel = null);
  }

  Future<void> _applyUpdates() async {
    if (_updates.isEmpty) return;
    final ids = _updates.map((u) => u.id.raw).toList();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Apply Updates'),
        content: Text('Update ${ids.length} packages?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Update')),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    setState(() {
      _opLabel = 'Updating...';
      _opProgress = -1;
      _messages.clear();
      _restartRequired = false;
    });

    final tx = widget.client.updatePackages(ids,
        flags: [PkTransactionFlag.onlyTrusted]);

    tx.progress.listen((p) {
      if (!mounted) return;
      setState(() {
        _opProgress = p.percentageKnown ? p.percentage : -1;
        _opLabel = 'Updating... ${p.progressLabel}';
      });
    });

    tx.messages.listen((m) {
      if (mounted) setState(() => _messages.add('[msg] ${m.details}'));
    });

    tx.errors.listen((e) {
      if (mounted) setState(() => _messages.add('[error] ${e.details}'));
    });

    tx.requireRestart.listen((r) {
      if (mounted) {
        setState(() {
          _restartRequired = true;
          _messages.add('[restart] type=${r.type} pkg=${r.packageId}');
        });
      }
    });

    try {
      final result = await tx.result;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Update complete in ${result.runtimeMs}ms'
                '${_restartRequired ? " (restart required)" : ""}')));
      }
    } on PkTransactionException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Update failed: ${e.exit.name}')));
      }
    }

    if (mounted) setState(() => _opLabel = null);
  }

  Future<void> _checkDistroUpgrades() async {
    setState(() => _opLabel = 'Checking distro upgrades...');

    final pkgs = <PkPackage>[];
    final tx = widget.client.getDistroUpgrades();
    await for (final pkg in tx.packages) {
      pkgs.add(pkg);
    }

    try {
      await tx.result;
    } catch (_) {}

    if (!mounted) return;

    setState(() => _opLabel = null);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Distribution Upgrades'),
        content: pkgs.isEmpty
            ? const Text('No distribution upgrades available.')
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final p in pkgs) Text('${p.id.name} ${p.id.version}'),
                ],
              ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Updates'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _checkDistroUpgrades,
            icon: const Icon(Icons.system_update),
            tooltip: 'Check distro upgrades',
          ),
          IconButton(
            onPressed: _loading ? null : _loadUpdates,
            icon: const Icon(Icons.refresh),
            tooltip: 'Check for updates',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_opLabel != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      const SizedBox.square(
                          dimension: 16,
                          child:
                              CircularProgressIndicator(strokeWidth: 2)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_opLabel!)),
                    ],
                  ),
                  if (_opProgress >= 0)
                    LinearProgressIndicator(value: _opProgress / 100),
                ],
              ),
            ),
          if (_messages.isNotEmpty)
            Container(
              height: 80,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView(
                children: [
                  for (final m in _messages)
                    Text(m, style: const TextStyle(fontSize: 11)),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Text(_statusText),
                const Spacer(),
                if (_updates.isNotEmpty) ...[
                  OutlinedButton(
                    onPressed: _opLabel != null ? null : _simulateUpdateAll,
                    child: const Text('Simulate'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: _opLabel != null ? null : _downloadAll,
                    child: const Text('Download'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _opLabel != null ? null : _applyUpdates,
                    child: const Text('Update All'),
                  ),
                ],
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
            child: _updates.isEmpty && !_loading
                ? const Center(
                    child: Text('Tap refresh to check for updates'))
                : ListView.builder(
                    itemCount: _updates.length,
                    itemBuilder: (ctx, i) {
                      final pkg = _updates[i];
                      final ud = _updateDetails[pkg.id.raw];
                      final severity = switch (pkg.info) {
                        PkInfo.security => 'SECURITY',
                        PkInfo.bugfix => 'bugfix',
                        PkInfo.enhancement => 'enhancement',
                        PkInfo.important => 'important',
                        _ => pkg.info.name,
                      };
                      return ListTile(
                        title: Text(pkg.id.name),
                        subtitle: Text(
                          '${pkg.id.version} [$severity]\n'
                          '${pkg.summary}'
                          '${ud != null && ud.cveUrls.isNotEmpty ? "\nCVEs: ${ud.cveUrls.join(", ")}" : ""}',
                        ),
                        isThreeLine: true,
                        leading: Icon(
                          pkg.info == PkInfo.security
                              ? Icons.security
                              : Icons.update,
                          color: pkg.info == PkInfo.security
                              ? Colors.red
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
