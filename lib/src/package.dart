// package.dart

import 'enums.dart';

/// Parsed PackageKit package identifier: "name;version;arch;data".
class PkPackageId {
  final String name;
  final String version;
  final String arch;

  /// Backend-specific source identifier, e.g. "fedora", "@System", "flathub".
  final String data;

  const PkPackageId({
    required this.name,
    required this.version,
    required this.arch,
    required this.data,
  });

  factory PkPackageId.parse(String id) {
    final parts = id.split(';');
    if (parts.length != 4) throw FormatException('Invalid package_id: $id');
    return PkPackageId(
        name: parts[0], version: parts[1], arch: parts[2], data: parts[3]);
  }

  String get raw => '$name;$version;$arch;$data';

  @override
  String toString() => '$name-$version.$arch';
}

/// A package returned by Package signals.
class PkPackage {
  final PkInfo info;
  final PkPackageId id;
  final String summary;

  const PkPackage({
    required this.info,
    required this.id,
    required this.summary,
  });
}

/// Detailed information returned by the Details signal.
class PkPackageDetail {
  final PkPackageId id;
  final String summary;
  final String description;
  final String url;
  final String license;
  final String group;
  final int size; // bytes; 0 if unknown

  const PkPackageDetail({
    required this.id,
    required this.summary,
    required this.description,
    required this.url,
    required this.license,
    required this.group,
    required this.size,
  });

  String get sizeFormatted => size == 0
      ? 'unknown'
      : size >= 1 << 30
          ? '${(size / (1 << 30)).toStringAsFixed(1)} GiB'
          : size >= 1 << 20
              ? '${(size / (1 << 20)).toStringAsFixed(1)} MiB'
              : '${(size / 1024).toStringAsFixed(1)} KiB';
}
