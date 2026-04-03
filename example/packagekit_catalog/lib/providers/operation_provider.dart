import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/view_models.dart';
import 'packagekit_provider.dart';

final operationProvider =
    StateNotifierProvider<OperationNotifier, PackageOperation?>(
      (ref) => OperationNotifier(ref),
    );

class OperationNotifier extends StateNotifier<PackageOperation?> {
  final Ref _ref;

  OperationNotifier(this._ref) : super(null);

  Future<void> installPackages(List<String> packageIds) async {
    final connState = _ref.read(packageKitProvider);
    if (connState is! PkConnected) return;

    final name = packageIds.first.split(';').first;
    final tx = connState.client.installPackages(packageIds);
    state = PackageOperation(
      packageName: name,
      type: OperationType.install,
      progress: tx.progress,
      result: tx.result,
    );

    try {
      await tx.result;
    } finally {
      state = null;
    }
  }

  Future<void> removePackages(List<String> packageIds) async {
    final connState = _ref.read(packageKitProvider);
    if (connState is! PkConnected) return;

    final name = packageIds.first.split(';').first;
    final tx = connState.client.removePackages(packageIds);
    state = PackageOperation(
      packageName: name,
      type: OperationType.remove,
      progress: tx.progress,
      result: tx.result,
    );

    try {
      await tx.result;
    } finally {
      state = null;
    }
  }

  Future<void> updatePackages(List<String> packageIds) async {
    final connState = _ref.read(packageKitProvider);
    if (connState is! PkConnected) return;

    final name = packageIds.first.split(';').first;
    final tx = connState.client.updatePackages(packageIds);
    state = PackageOperation(
      packageName: name,
      type: OperationType.update,
      progress: tx.progress,
      result: tx.result,
    );

    try {
      await tx.result;
    } finally {
      state = null;
    }
  }
}
