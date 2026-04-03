import 'package:packagekit_dart/packagekit_dart.dart';

class PackageListItem {
  final PkPackage package;
  final PkPackageDetail? detail;

  const PackageListItem({required this.package, this.detail});

  String get name => package.id.name;
  String get version => package.id.version;
  String get summary => package.summary;
  PkInfo get info => package.info;
  bool get isInstalled => package.info == PkInfo.installed;
}

sealed class PkConnectionState {}

class PkConnecting extends PkConnectionState {}

class PkConnected extends PkConnectionState {
  final PkClient client;
  PkConnected(this.client);
}

class PkConnectionFailed extends PkConnectionState {
  final String error;
  PkConnectionFailed(this.error);
}

class PackageOperation {
  final String packageName;
  final OperationType type;
  final Stream<PkProgress>? progress;
  final Future<PkTransactionResult>? result;

  const PackageOperation({
    required this.packageName,
    required this.type,
    this.progress,
    this.result,
  });
}

enum OperationType { install, remove, update }
