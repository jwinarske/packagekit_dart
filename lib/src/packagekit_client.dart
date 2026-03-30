// packagekit_client.dart
//
// PkClient is the top-level API entry point.

import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';
import 'dart:typed_data';

import 'details.dart';
import 'enums.dart';
import 'exceptions.dart';
import 'ffi/bindings.dart';
import 'ffi/codec.dart';
import 'ffi/types.dart';
import 'package.dart';
import 'repo.dart';
import 'transaction.dart';

/// Daemon-level events from the manager.
sealed class PkDaemonEvent {}

class PkPropsEvent extends PkDaemonEvent {
  final PkManagerProps props;
  PkPropsEvent(this.props);
}

class PkUpdatesChangedEvent extends PkDaemonEvent {}

class PkRepoListChangedEvent extends PkDaemonEvent {}

class PkNetworkStateChangedEvent extends PkDaemonEvent {
  final int state;
  PkNetworkStateChangedEvent(this.state);
}

class PkClient {
  final Object _managerHandle;
  final ReceivePort _eventsPort;
  final StreamController<PkDaemonEvent> _daemonEvents =
      StreamController.broadcast();

  PkClient._(this._managerHandle, this._eventsPort) {
    _eventsPort.listen(_onManagerEvent);
  }

  static bool _initialized = false;

  /// Connect to the PackageKit daemon on the system bus.
  static Future<PkClient> connect() async {
    if (!_initialized) {
      PkBindings.init(NativeApi.initializeApiDLData);
      _initialized = true;
    }
    final port = ReceivePort('packagekit.manager');
    final handle = PkBindings.managerCreate(port.sendPort.nativePort);
    if ((handle as Pointer).address == 0) {
      port.close();
      throw const PkServiceUnavailableException(
          'Failed to connect to org.freedesktop.PackageKit on the system bus.');
    }
    final client = PkClient._(handle, port);
    await client._loadProperties();
    return client;
  }

  // ── Daemon property access ──────────────────────────────────────────────

  PkManagerProps? _props;
  PkManagerProps? get properties => _props;
  Stream<PkDaemonEvent> get daemonEvents => _daemonEvents.stream;

  // ── Query operations ────────────────────────────────────────────────────

  PkTransaction searchName(
    String query, {
    List<PkFilter> filters = const [PkFilter.none],
  }) =>
      _startQuery(
          (h) => PkBindings.searchName(h, PkFilter.combine(filters), [query]));

  PkTransaction searchDetails(
    String query, {
    List<PkFilter> filters = const [PkFilter.none],
  }) =>
      _startQuery((h) =>
          PkBindings.searchDetails(h, PkFilter.combine(filters), [query]));

  PkTransaction searchFiles(
    String path, {
    List<PkFilter> filters = const [PkFilter.none],
  }) =>
      _startQuery(
          (h) => PkBindings.searchFiles(h, PkFilter.combine(filters), [path]));

  PkTransaction getPackages({
    List<PkFilter> filters = const [PkFilter.installed],
  }) =>
      _startQuery((h) => PkBindings.getPackages(h, PkFilter.combine(filters)));

  PkTransaction getUpdates({
    List<PkFilter> filters = const [PkFilter.none],
  }) =>
      _startQuery((h) => PkBindings.getUpdates(h, PkFilter.combine(filters)));

  PkTransaction resolve(
    List<String> names, {
    List<PkFilter> filters = const [PkFilter.none],
  }) =>
      _startQuery(
          (h) => PkBindings.resolve(h, PkFilter.combine(filters), names));

  PkTransaction getDetails(List<String> packageIds) =>
      _startQuery((h) => PkBindings.getDetails(h, packageIds));

  PkTransaction getUpdateDetail(List<String> packageIds) =>
      _startQuery((h) => PkBindings.getUpdateDetail(h, packageIds));

  PkTransaction getFiles(List<String> packageIds) =>
      _startQuery((h) => PkBindings.getFiles(h, packageIds));

  PkTransaction getRepoList({
    List<PkFilter> filters = const [PkFilter.none],
  }) =>
      _startQuery((h) => PkBindings.getRepoList(h, PkFilter.combine(filters)));

  PkTransaction dependsOn(
    List<String> packageIds, {
    List<PkFilter> filters = const [PkFilter.none],
    bool recursive = false,
  }) =>
      _startQuery((h) => PkBindings.dependsOn(
          h, PkFilter.combine(filters), packageIds, recursive));

  PkTransaction requiredBy(
    List<String> packageIds, {
    List<PkFilter> filters = const [PkFilter.none],
    bool recursive = false,
  }) =>
      _startQuery((h) => PkBindings.requiredBy(
          h, PkFilter.combine(filters), packageIds, recursive));

  PkTransaction getDistroUpgrades() =>
      _startQuery((h) => PkBindings.getDistroUpgrades(h));

  // ── Dependency resolution ───────────────────────────────────────────────

  Future<PkInstallPlan> simulateInstall(
    List<String> packageIds, {
    List<PkTransactionFlag> flags = const [PkTransactionFlag.onlyTrusted],
  }) =>
      _collectPlan(_startQuery((h) => PkBindings.installPackages(
          h,
          PkTransactionFlag.combine([...flags, PkTransactionFlag.simulate]),
          packageIds)));

  Future<PkInstallPlan> simulateRemove(
    List<String> packageIds, {
    bool allowDeps = false,
    bool autoremove = false,
    List<PkTransactionFlag> flags = const [PkTransactionFlag.onlyTrusted],
  }) =>
      _collectPlan(_startQuery((h) => PkBindings.removePackages(
          h,
          PkTransactionFlag.combine([...flags, PkTransactionFlag.simulate]),
          packageIds,
          allowDeps,
          autoremove)));

  Future<PkInstallPlan> simulateUpdate(
    List<String> packageIds, {
    List<PkTransactionFlag> flags = const [PkTransactionFlag.onlyTrusted],
  }) =>
      _collectPlan(_startQuery((h) => PkBindings.updatePackages(
          h,
          PkTransactionFlag.combine([...flags, PkTransactionFlag.simulate]),
          packageIds)));

  Future<PkInstallPlan> _collectPlan(PkTransaction tx) async {
    final pkgs = <PkPackage>[];
    await for (final pkg in tx.packages) {
      pkgs.add(pkg);
    }
    await tx.result;
    return planFromPackages(pkgs);
  }

  // ── Write operations ────────────────────────────────────────────────────

  PkTransaction installPackages(
    List<String> packageIds, {
    List<PkTransactionFlag> flags = const [PkTransactionFlag.onlyTrusted],
  }) =>
      _startQuery((h) => PkBindings.installPackages(
          h, PkTransactionFlag.combine(flags), packageIds));

  PkTransaction removePackages(
    List<String> packageIds, {
    bool allowDeps = false,
    bool autoremove = false,
    List<PkTransactionFlag> flags = const [PkTransactionFlag.onlyTrusted],
  }) =>
      _startQuery((h) => PkBindings.removePackages(h,
          PkTransactionFlag.combine(flags), packageIds, allowDeps, autoremove));

  PkTransaction updatePackages(
    List<String> packageIds, {
    List<PkTransactionFlag> flags = const [PkTransactionFlag.onlyTrusted],
  }) =>
      _startQuery((h) => PkBindings.updatePackages(
          h, PkTransactionFlag.combine(flags), packageIds));

  PkTransaction refreshCache({bool force = false}) =>
      _startQuery((h) => PkBindings.refreshCache(h, force));

  PkTransaction installFiles(
    List<String> paths, {
    List<PkTransactionFlag> flags = const [PkTransactionFlag.onlyTrusted],
  }) =>
      _startQuery((h) =>
          PkBindings.installFiles(h, PkTransactionFlag.combine(flags), paths));

  PkTransaction downloadPackages(
    List<String> packageIds, {
    bool storeInCache = true,
  }) =>
      _startQuery(
          (h) => PkBindings.downloadPackages(h, storeInCache, packageIds));

  PkTransaction repoEnable(String repoId, {required bool enabled}) =>
      _startQuery((h) => PkBindings.repoEnable(h, repoId, enabled));

  PkTransaction acceptEula(String eulaId) =>
      _startQuery((h) => PkBindings.acceptEula(h, eulaId));

  // ── Lifecycle ───────────────────────────────────────────────────────────

  Future<void> close() async {
    PkBindings.managerDestroy(_managerHandle);
    _eventsPort.close();
    await _daemonEvents.close();
  }

  // ── Internal ────────────────────────────────────────────────────────────

  Future<void> _loadProperties() async {
    final c = Completer<void>();
    _daemonEvents.stream
        .where((e) => e is PkPropsEvent)
        .first
        .then((_) {
      if (!c.isCompleted) c.complete();
    });
    PkBindings.managerReadProperties(_managerHandle);
    await c.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        if (!c.isCompleted) c.complete();
      },
    );
  }

  PkTransaction _startQuery(void Function(Object txHandle) invoke) {
    final port = ReceivePort('packagekit.tx');

    final pkgs = StreamController<PkPackage>();
    final dets = StreamController<PkPackageDetail>();
    final updDets = StreamController<PkUpdateDetail>();
    final repos = StreamController<PkRepoDetail>();
    final fls = StreamController<PkFiles>();
    final prog = StreamController<PkProgress>();
    final msgs = StreamController<PkMessage>();
    final eula = StreamController<PkEulaRequired>();
    final sig = StreamController<PkRepoSigRequired>();
    final restart = StreamController<PkRequireRestart>();
    final errs = StreamController<PkErrorCode>();
    final done = Completer<PkTransactionResult>();

    void close() {
      for (final c in [
        pkgs,
        dets,
        updDets,
        repos,
        fls,
        prog,
        msgs,
        eula,
        sig,
        restart,
        errs
      ]) {
        if (!c.isClosed) c.close();
      }
      port.close();
    }

    port.listen((dynamic msg) {
      if (msg is! Uint8List) return;
      final disc = msg[0];
      switch (disc) {
        case 0x01:
          pkgs.add(GlazeCodec.decode<PkPackage>(msg, 1));
        case 0x02:
          prog.add(GlazeCodec.decode<PkProgress>(msg, 1));
        case 0x03:
          dets.add(GlazeCodec.decode<PkPackageDetail>(msg, 1));
        case 0x04:
          updDets.add(GlazeCodec.decode<PkUpdateDetail>(msg, 1));
        case 0x05:
          repos.add(GlazeCodec.decode<PkRepoDetail>(msg, 1));
        case 0x06:
          fls.add(GlazeCodec.decode<PkFiles>(msg, 1));
        case 0x07:
          errs.add(GlazeCodec.decode<PkErrorCode>(msg, 1));
        case 0x08:
          msgs.add(GlazeCodec.decode<PkMessage>(msg, 1));
        case 0x09:
          eula.add(GlazeCodec.decode<PkEulaRequired>(msg, 1));
        case 0x0A:
          sig.add(GlazeCodec.decode<PkRepoSigRequired>(msg, 1));
        case 0x0B:
          restart.add(GlazeCodec.decode<PkRequireRestart>(msg, 1));
        case 0x20:
          final result = GlazeCodec.decode<PkFinished>(msg, 1);
          final exit = PkExit.fromInt(result.exitCode);
          if (!done.isCompleted) {
            if (exit == PkExit.success) {
              done.complete(
                  PkTransactionResult(exit: exit, runtimeMs: result.runtimeMs));
            } else {
              done.completeError(PkTransactionException(
                  'Transaction failed: ${exit.name}',
                  exit: exit,
                  runtimeMs: result.runtimeMs));
            }
          }
        case 0xFF:
          // Delay close so buffered stream events drain first.
          Future.microtask(close);
      }
    });

    final txHandle =
        PkBindings.transactionCreate(_managerHandle, port.sendPort.nativePort);
    if ((txHandle as Pointer).address == 0) {
      close();
      done.completeError(const PkServiceUnavailableException(
          'Failed to create PackageKit transaction.'));
    } else {
      PkBindings.transactionSetHints(txHandle, 'en_US.UTF-8');
      invoke(txHandle);
    }

    return PkTransaction(
      packages: pkgs.stream,
      details: dets.stream,
      updateDetails: updDets.stream,
      repoDetails: repos.stream,
      files: fls.stream,
      progress: prog.stream,
      messages: msgs.stream,
      eulaRequired: eula.stream,
      repoSigRequired: sig.stream,
      requireRestart: restart.stream,
      errors: errs.stream,
      result: done.future,
      cancel: () => PkBindings.transactionCancel(txHandle),
    );
  }

  void _onManagerEvent(dynamic msg) {
    if (msg is! Uint8List) return;
    switch (msg[0]) {
      case 0x0C:
        _props = GlazeCodec.decode<PkManagerProps>(msg, 1);
        _daemonEvents.add(PkPropsEvent(_props!));
      case 0xD0:
        _daemonEvents.add(PkUpdatesChangedEvent());
      case 0xD1:
        _daemonEvents.add(PkRepoListChangedEvent());
      case 0xD2:
        final state = msg.buffer
            .asByteData(msg.offsetInBytes)
            .getUint32(1, Endian.little);
        _daemonEvents.add(PkNetworkStateChangedEvent(state));
    }
  }
}
