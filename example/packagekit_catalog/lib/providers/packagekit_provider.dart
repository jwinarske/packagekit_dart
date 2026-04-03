import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packagekit_dart/packagekit_dart.dart';

import '../models/view_models.dart';

final packageKitProvider =
    StateNotifierProvider<PackageKitNotifier, PkConnectionState>(
      (ref) => PackageKitNotifier(),
    );

class PackageKitNotifier extends StateNotifier<PkConnectionState> {
  PackageKitNotifier() : super(PkConnecting()) {
    _connect();
  }

  PkClient? _client;
  PkClient? get client => _client;

  Future<void> _connect() async {
    try {
      _client = await PkClient.connect();
      state = PkConnected(_client!);
    } on Object catch (e) {
      state = PkConnectionFailed(e.toString());
    }
  }

  Future<void> reconnect() async {
    state = PkConnecting();
    await _connect();
  }

  @override
  void dispose() {
    _client?.close();
    super.dispose();
  }
}
