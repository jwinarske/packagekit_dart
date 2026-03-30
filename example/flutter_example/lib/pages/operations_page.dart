import 'package:flutter/material.dart';
import 'package:packagekit_dart/packagekit_dart.dart';

/// Demonstrates: installPackages, removePackages, installFiles,
/// acceptEula, PkTransaction.eulaRequired, PkTransaction.repoSigRequired,
/// PkEulaRequired, PkRepoSigRequired, PkRequireRestart,
/// PkMessage, PkErrorCode, PkTransactionFlag (allowReinstall, allowDowngrade,
/// justReinstall, onlyDownload), PkException, PkServiceUnavailableException,
/// simulateInstall/simulateRemove with full plan display.
class OperationsPage extends StatefulWidget {
  final PkClient client;
  const OperationsPage({super.key, required this.client});

  @override
  State<OperationsPage> createState() => _OperationsPageState();
}

class _OperationsPageState extends State<OperationsPage> {
  final _pkgController = TextEditingController();
  final _fileController = TextEditingController();
  final _log = <_LogEntry>[];
  bool _busy = false;
  PkTransaction? _activeTx;

  void _addLog(String text, {bool isError = false}) {
    if (mounted) {
      setState(
          () => _log.insert(0, _LogEntry(text, isError: isError)));
    }
  }

  void _listenTransaction(PkTransaction tx, String label) {
    _activeTx = tx;

    tx.packages.listen((pkg) {
      _addLog('[$label] Package: ${pkg.id.name} ${pkg.id.version} '
          '(${pkg.info.name})');
    });

    tx.progress.listen((p) {
      if (!p.isItem && mounted) {
        setState(() {}); // Trigger rebuild for progress display
      }
    });

    tx.messages.listen((m) {
      _addLog('[$label] Message(type=${m.type}): ${m.details}');
    });

    tx.errors.listen((e) {
      _addLog('[$label] Error(code=${e.code}): ${e.details}', isError: true);
    });

    tx.eulaRequired.listen((e) async {
      _addLog('[$label] EULA required: ${e.eulaId} from ${e.vendorName}');
      final accept = await _showEulaDialog(e);
      if (accept) {
        _addLog('[$label] Accepting EULA: ${e.eulaId}');
        final acceptTx = widget.client.acceptEula(e.eulaId);
        await acceptTx.result;
      }
    });

    tx.repoSigRequired.listen((s) {
      _addLog('[$label] Repo signature required: ${s.repositoryName}\n'
          '  Key: ${s.keyId} (${s.keyUserId})\n'
          '  Fingerprint: ${s.keyFingerprint}\n'
          '  URL: ${s.keyUrl}\n'
          '  Timestamp: ${s.keyTimestamp}\n'
          '  Type: ${s.type}');
    });

    tx.requireRestart.listen((r) {
      _addLog('[$label] Restart required: type=${r.type} '
          'pkg=${r.packageId}');
    });
  }

  Future<bool> _showEulaDialog(PkEulaRequired eula) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('EULA: ${eula.vendorName}'),
            content: SizedBox(
              width: 400,
              height: 300,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Package: ${eula.packageId}'),
                    Text('EULA ID: ${eula.eulaId}'),
                    const SizedBox(height: 12),
                    Text(eula.licenseAgreement),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Decline')),
              FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Accept')),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _resolveAndInstall() async {
    final name = _pkgController.text.trim();
    if (name.isEmpty) return;

    setState(() => _busy = true);
    _addLog('Resolving "$name"...');

    // Step 1: resolve name -> package IDs
    final resolved = <String>[];
    try {
      final tx = widget.client.resolve([name],
          filters: [PkFilter.notInstalled, PkFilter.newest]);
      await for (final pkg in tx.packages) {
        resolved.add(pkg.id.raw);
        _addLog('Resolved: ${pkg.id}');
      }
      await tx.result;
    } on PkTransactionException catch (e) {
      _addLog('Resolve failed: ${e.exit.name}', isError: true);
      setState(() => _busy = false);
      return;
    }

    if (resolved.isEmpty) {
      _addLog('Package not found: $name', isError: true);
      setState(() => _busy = false);
      return;
    }

    // Step 2: simulate install
    _addLog('Simulating install...');
    try {
      final plan = await widget.client.simulateInstall(resolved);
      _addLog('Install plan: $plan');
      if (plan.installing.isNotEmpty) {
        _addLog('  New: ${plan.installing.map((p) => p.id.name).join(", ")}');
      }
      if (plan.updating.isNotEmpty) {
        _addLog('  Update: ${plan.updating.map((p) => p.id.name).join(", ")}');
      }
      if (plan.removing.isNotEmpty) {
        _addLog('  Remove: ${plan.removing.map((p) => p.id.name).join(", ")}');
      }
    } on PkTransactionException catch (e) {
      _addLog('Simulate failed: ${e.message}', isError: true);
    }

    // Step 3: actual install
    if (!mounted) {
      setState(() => _busy = false);
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Install Package'),
        content: Text('Install ${resolved.length} package(s)?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Install')),
        ],
      ),
    );

    if (confirm == true && mounted) {
      _addLog('Installing...');
      final tx = widget.client.installPackages(resolved,
          flags: [PkTransactionFlag.onlyTrusted]);
      _listenTransaction(tx, 'install');

      try {
        final result = await tx.result;
        _addLog('Install complete: ${result.exit.name} '
            '(${result.runtimeMs}ms)');
      } on PkTransactionException catch (e) {
        _addLog('Install failed: ${e.exit.name} (${e.runtimeMs}ms)',
            isError: true);
      }
    }

    if (mounted) setState(() => _busy = false);
  }

  Future<void> _resolveAndRemove() async {
    final name = _pkgController.text.trim();
    if (name.isEmpty) return;

    setState(() => _busy = true);
    _addLog('Resolving "$name" for removal...');

    final resolved = <String>[];
    try {
      final tx =
          widget.client.resolve([name], filters: [PkFilter.installed]);
      await for (final pkg in tx.packages) {
        resolved.add(pkg.id.raw);
        _addLog('Found installed: ${pkg.id}');
      }
      await tx.result;
    } on PkTransactionException catch (e) {
      _addLog('Resolve failed: ${e.exit.name}', isError: true);
      setState(() => _busy = false);
      return;
    }

    if (resolved.isEmpty) {
      _addLog('Package not installed: $name', isError: true);
      setState(() => _busy = false);
      return;
    }

    // Simulate removal
    _addLog('Simulating removal...');
    try {
      final plan =
          await widget.client.simulateRemove(resolved, autoremove: true);
      _addLog('Remove plan: $plan');
    } on PkTransactionException catch (e) {
      _addLog('Simulate remove failed: ${e.message}', isError: true);
    }

    if (!mounted) {
      setState(() => _busy = false);
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Package'),
        content: Text('Remove ${resolved.length} package(s)?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Remove')),
        ],
      ),
    );

    if (confirm == true && mounted) {
      _addLog('Removing...');
      final tx = widget.client.removePackages(resolved,
          autoremove: true, flags: [PkTransactionFlag.onlyTrusted]);
      _listenTransaction(tx, 'remove');

      try {
        final result = await tx.result;
        _addLog('Remove complete: ${result.exit.name} '
            '(${result.runtimeMs}ms)');
      } on PkTransactionException catch (e) {
        _addLog('Remove failed: ${e.exit.name} (${e.runtimeMs}ms)',
            isError: true);
      }
    }

    if (mounted) setState(() => _busy = false);
  }

  Future<void> _installLocalFile() async {
    final path = _fileController.text.trim();
    if (path.isEmpty) return;

    setState(() => _busy = true);
    _addLog('Installing local file: $path');

    final tx = widget.client.installFiles([path],
        flags: [PkTransactionFlag.onlyTrusted]);
    _listenTransaction(tx, 'installFile');

    try {
      final result = await tx.result;
      _addLog('Install file complete: ${result.exit.name} '
          '(${result.runtimeMs}ms)');
    } on PkTransactionException catch (e) {
      _addLog('Install file failed: ${e.exit.name} (${e.runtimeMs}ms)',
          isError: true);
    }

    if (mounted) setState(() => _busy = false);
  }

  void _cancelOperation() {
    _activeTx?.cancel();
    _addLog('Cancel requested');
  }

  @override
  void dispose() {
    _pkgController.dispose();
    _fileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Package Operations'),
        actions: [
          if (_busy)
            IconButton(
              onPressed: _cancelOperation,
              icon: const Icon(Icons.cancel),
              tooltip: 'Cancel operation',
            ),
          IconButton(
            onPressed: () => setState(() => _log.clear()),
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear log',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Package name operations
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _pkgController,
                        decoration: const InputDecoration(
                          hintText: 'Package name (e.g. htop)',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _busy ? null : _resolveAndInstall,
                      child: const Text('Install'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: _busy ? null : _resolveAndRemove,
                      child: const Text('Remove'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Local file install
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _fileController,
                        decoration: const InputDecoration(
                          hintText: 'Local .rpm/.deb path',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: _busy ? null : _installLocalFile,
                      child: const Text('Install File'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_busy)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: LinearProgressIndicator(),
            ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Text('Operation Log',
                    style: Theme.of(context).textTheme.titleSmall),
                const Spacer(),
                Text('${_log.length} entries',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _log.length,
              itemBuilder: (ctx, i) {
                final entry = _log[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  child: Text(
                    entry.text,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: entry.isError
                          ? Theme.of(context).colorScheme.error
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LogEntry {
  final String text;
  final bool isError;
  const _LogEntry(this.text, {this.isError = false});
}
