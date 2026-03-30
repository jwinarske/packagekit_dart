// transaction.dart

import 'dart:async';

import 'details.dart';
import 'enums.dart';
import 'package.dart';
import 'repo.dart';

/// Live transaction progress.
class PkProgress {
  final String packageId;
  final PkStatus status;

  /// 0-100; 101 means unknown (backend hasn't reported yet).
  final int percentage;

  /// True if this is a per-item progress (ItemProgress signal) rather than
  /// the overall transaction progress (Progress signal).
  final bool isItem;

  const PkProgress({
    required this.packageId,
    required this.status,
    required this.percentage,
    required this.isItem,
  });

  bool get percentageKnown => percentage <= 100;

  String get progressLabel =>
      percentageKnown ? '$percentage%  [$status]' : '[${status.name}]';
}

/// Transaction completion result.
class PkTransactionResult {
  final PkExit exit;
  final int runtimeMs;
  const PkTransactionResult({required this.exit, required this.runtimeMs});
  bool get success => exit == PkExit.success;
}

/// The resolved install/remove/update plan from a simulate transaction.
///
/// Produced by [PkClient.simulateInstall], [PkClient.simulateRemove], and
/// [PkClient.simulateUpdate]. Contains the full set of packages that *would*
/// be changed if the corresponding real transaction were executed now.
///
/// **TOCTOU note:** the plan reflects the package database at the moment
/// simulate ran. The subsequent real transaction re-resolves from scratch
/// and may install different versions or additional/fewer dependencies if
/// the database changed in the interval.
class PkInstallPlan {
  final List<PkPackage> installing;
  final List<PkPackage> updating;
  final List<PkPackage> removing;
  final List<PkPackage> reinstalling;
  final List<PkPackage> downgrading;
  final List<PkPackage> obsoleting;

  const PkInstallPlan({
    required this.installing,
    required this.updating,
    required this.removing,
    required this.reinstalling,
    required this.downgrading,
    required this.obsoleting,
  });

  List<String> get allIds => [
        ...installing,
        ...updating,
        ...reinstalling,
        ...downgrading,
      ].map((p) => p.id.raw).toList();

  bool get isEmpty =>
      installing.isEmpty &&
      updating.isEmpty &&
      removing.isEmpty &&
      reinstalling.isEmpty &&
      downgrading.isEmpty &&
      obsoleting.isEmpty;

  int get changeCount =>
      installing.length +
      updating.length +
      removing.length +
      reinstalling.length +
      downgrading.length +
      obsoleting.length;

  @override
  String toString() => 'PkInstallPlan('
      '+${installing.length} ↑${updating.length} -${removing.length}'
      '${obsoleting.isNotEmpty ? " obs:${obsoleting.length}" : ""})';
}

/// Build a [PkInstallPlan] from the Package signals emitted by a simulate
/// transaction.
PkInstallPlan planFromPackages(List<PkPackage> pkgs) {
  final installing = <PkPackage>[];
  final updating = <PkPackage>[];
  final removing = <PkPackage>[];
  final reinstalling = <PkPackage>[];
  final downgrading = <PkPackage>[];
  final obsoleting = <PkPackage>[];

  for (final p in pkgs) {
    switch (p.info) {
      case PkInfo.installing:
        installing.add(p);
      case PkInfo.updating:
        updating.add(p);
      case PkInfo.removing:
        removing.add(p);
      case PkInfo.reinstalling:
        reinstalling.add(p);
      case PkInfo.downgrading:
        downgrading.add(p);
      case PkInfo.obsoleting:
        obsoleting.add(p);
      default:
        installing.add(p);
    }
  }
  return PkInstallPlan(
    installing: installing,
    updating: updating,
    removing: removing,
    reinstalling: reinstalling,
    downgrading: downgrading,
    obsoleting: obsoleting,
  );
}

/// A live PackageKit transaction.
class PkTransaction {
  final Stream<PkPackage> packages;
  final Stream<PkPackageDetail> details;
  final Stream<PkUpdateDetail> updateDetails;
  final Stream<PkRepoDetail> repoDetails;
  final Stream<PkFiles> files;
  final Stream<PkProgress> progress;
  final Stream<PkMessage> messages;
  final Stream<PkEulaRequired> eulaRequired;
  final Stream<PkRepoSigRequired> repoSigRequired;
  final Stream<PkRequireRestart> requireRestart;
  final Stream<PkErrorCode> errors;
  final Future<PkTransactionResult> result;
  final void Function() cancel;

  const PkTransaction({
    required this.packages,
    required this.details,
    required this.updateDetails,
    required this.repoDetails,
    required this.files,
    required this.progress,
    required this.messages,
    required this.eulaRequired,
    required this.repoSigRequired,
    required this.requireRestart,
    required this.errors,
    required this.result,
    required this.cancel,
  });
}
