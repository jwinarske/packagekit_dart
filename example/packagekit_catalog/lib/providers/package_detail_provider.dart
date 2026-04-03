import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packagekit_dart/packagekit_dart.dart';

import '../models/view_models.dart';
import 'packagekit_provider.dart';

final selectedPackageProvider = StateProvider<PackageListItem?>((ref) => null);

final packageDetailProvider = FutureProvider.autoDispose
    .family<PkPackageDetail?, String>((ref, packageId) async {
      final connState = ref.watch(packageKitProvider);
      if (connState is! PkConnected) return null;

      final client = connState.client;
      final tx = client.getDetails([packageId]);
      PkPackageDetail? detail;
      await for (final d in tx.details) {
        detail = d;
      }
      await tx.result;
      return detail;
    });
