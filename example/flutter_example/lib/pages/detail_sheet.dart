import 'package:flutter/material.dart';
import 'package:packagekit_dart/packagekit_dart.dart';

/// Demonstrates: getDetails, getFiles, dependsOn, requiredBy, getUpdateDetail,
/// PkPackageDetail, PkFiles, PkUpdateDetail, simulateInstall, simulateRemove,
/// PkInstallPlan, PkTransactionException.
void showDetailSheet(BuildContext context, PkClient client, String packageId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollController) =>
          _DetailSheet(client: client, packageId: packageId, sc: scrollController),
    ),
  );
}

class _DetailSheet extends StatefulWidget {
  final PkClient client;
  final String packageId;
  final ScrollController sc;

  const _DetailSheet(
      {required this.client, required this.packageId, required this.sc});

  @override
  State<_DetailSheet> createState() => _DetailSheetState();
}

class _DetailSheetState extends State<_DetailSheet> {
  PkPackageDetail? _detail;
  List<String>? _files;
  List<PkPackage>? _deps;
  List<PkPackage>? _rdeps;
  PkUpdateDetail? _updateDetail;
  PkInstallPlan? _installPlan;
  PkInstallPlan? _removePlan;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final ids = [widget.packageId];

    // Fetch details
    try {
      final tx = widget.client.getDetails(ids);
      await for (final d in tx.details) {
        if (mounted) setState(() => _detail = d);
      }
      await tx.result;
    } catch (_) {}

    // Fetch files
    try {
      final tx = widget.client.getFiles(ids);
      await for (final f in tx.files) {
        if (mounted) setState(() => _files = f.files);
      }
      await tx.result;
    } catch (_) {}

    // Fetch dependencies
    try {
      final deps = <PkPackage>[];
      final tx = widget.client.dependsOn(ids);
      await for (final pkg in tx.packages) {
        deps.add(pkg);
      }
      await tx.result;
      if (mounted) setState(() => _deps = deps);
    } catch (_) {}

    // Fetch reverse dependencies
    try {
      final rdeps = <PkPackage>[];
      final tx = widget.client.requiredBy(ids);
      await for (final pkg in tx.packages) {
        rdeps.add(pkg);
      }
      await tx.result;
      if (mounted) setState(() => _rdeps = rdeps);
    } catch (_) {}

    // Fetch update detail (may be empty if not an update)
    try {
      final tx = widget.client.getUpdateDetail(ids);
      await for (final ud in tx.updateDetails) {
        if (mounted) setState(() => _updateDetail = ud);
      }
      await tx.result;
    } catch (_) {}

    // Simulate install
    try {
      final plan = await widget.client.simulateInstall(ids);
      if (mounted) setState(() => _installPlan = plan);
    } on PkTransactionException catch (e) {
      if (mounted) setState(() => _error = 'simulateInstall: ${e.message}');
    } catch (_) {}

    // Simulate remove
    try {
      final plan = await widget.client.simulateRemove(ids);
      if (mounted) setState(() => _removePlan = plan);
    } on PkTransactionException catch (e) {
      if (mounted && _error == null) {
        setState(() => _error = 'simulateRemove: ${e.message}');
      }
    } catch (_) {}

    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final pkgId = PkPackageId.parse(widget.packageId);
    final theme = Theme.of(context);

    return ListView(
      controller: widget.sc,
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Text(pkgId.name,
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text('${pkgId.version} (${pkgId.arch}) - ${pkgId.data}',
            style: theme.textTheme.bodyMedium),
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          ),

        // Details section
        if (_detail != null) ...[
          const SizedBox(height: 16),
          _Section('Details'),
          _Row('Summary', _detail!.summary),
          _Row('Description', _detail!.description),
          _Row('License', _detail!.license),
          _Row('URL', _detail!.url),
          _Row('Group', _detail!.group),
          _Row('Size', _detail!.sizeFormatted),
        ],

        // Update detail section
        if (_updateDetail != null) ...[
          const SizedBox(height: 16),
          _Section('Update Detail'),
          _Row('Update Text', _updateDetail!.updateText),
          _Row('Changelog', _updateDetail!.changelog),
          _Row('Issued', _updateDetail!.issued),
          _Row('Updated', _updateDetail!.updated),
          if (_updateDetail!.cveUrls.isNotEmpty)
            _Row('CVEs', _updateDetail!.cveUrls.join('\n')),
          if (_updateDetail!.bugzillaUrls.isNotEmpty)
            _Row('Bugs', _updateDetail!.bugzillaUrls.join('\n')),
          if (_updateDetail!.vendorUrls.isNotEmpty)
            _Row('Vendor', _updateDetail!.vendorUrls.join('\n')),
          _Row('Restart Type', '${_updateDetail!.restart}'),
          _Row('State', '${_updateDetail!.state}'),
        ],

        // Simulate install plan
        if (_installPlan != null && !_installPlan!.isEmpty) ...[
          const SizedBox(height: 16),
          _Section('Install Plan (${_installPlan!.changeCount} changes)'),
          for (final p in _installPlan!.installing)
            _PlanTile('+', p, Colors.green),
          for (final p in _installPlan!.updating)
            _PlanTile('^', p, Colors.blue),
          for (final p in _installPlan!.removing)
            _PlanTile('-', p, Colors.red),
          for (final p in _installPlan!.reinstalling)
            _PlanTile('=', p, Colors.orange),
          for (final p in _installPlan!.downgrading)
            _PlanTile('v', p, Colors.purple),
          for (final p in _installPlan!.obsoleting)
            _PlanTile('x', p, Colors.grey),
        ],

        // Simulate remove plan
        if (_removePlan != null && !_removePlan!.isEmpty) ...[
          const SizedBox(height: 16),
          _Section('Remove Plan (${_removePlan!.changeCount} changes)'),
          for (final p in _removePlan!.removing)
            _PlanTile('-', p, Colors.red),
          for (final p in _removePlan!.obsoleting)
            _PlanTile('x', p, Colors.grey),
        ],

        // Dependencies
        if (_deps != null && _deps!.isNotEmpty) ...[
          const SizedBox(height: 16),
          _Section('Dependencies (${_deps!.length})'),
          for (final d in _deps!.take(50))
            ListTile(
              dense: true,
              title: Text(d.id.name),
              subtitle: Text(d.id.version),
              trailing: Text(d.info.name),
            ),
          if (_deps!.length > 50)
            Text('... and ${_deps!.length - 50} more'),
        ],

        // Reverse dependencies
        if (_rdeps != null && _rdeps!.isNotEmpty) ...[
          const SizedBox(height: 16),
          _Section('Required By (${_rdeps!.length})'),
          for (final d in _rdeps!.take(50))
            ListTile(
              dense: true,
              title: Text(d.id.name),
              subtitle: Text(d.id.version),
              trailing: Text(d.info.name),
            ),
          if (_rdeps!.length > 50)
            Text('... and ${_rdeps!.length - 50} more'),
        ],

        // Files
        if (_files != null && _files!.isNotEmpty) ...[
          const SizedBox(height: 16),
          _Section('Files (${_files!.length})'),
          for (final f in _files!.take(100))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child:
                  Text(f, style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
            ),
          if (_files!.length > 100)
            Text('... and ${_files!.length - 100} more'),
        ],

        if (_error != null) ...[
          const SizedBox(height: 16),
          Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
        ],
        const SizedBox(height: 32),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  const _Section(this.title);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
      );
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 100,
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  final String prefix;
  final PkPackage pkg;
  final Color color;
  const _PlanTile(this.prefix, this.pkg, this.color);

  @override
  Widget build(BuildContext context) => ListTile(
        dense: true,
        leading: CircleAvatar(
          radius: 12,
          backgroundColor: color.withValues(alpha: 0.2),
          child: Text(prefix,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 14)),
        ),
        title: Text(pkg.id.name),
        subtitle: Text(pkg.id.version),
      );
}
