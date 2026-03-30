// types.dart — Dart-side struct mirrors for glaze wire types.

/// Manager properties snapshot (discriminator 0x0C).
class PkManagerProps {
  final String backendName;
  final String backendDescription;
  final String backendAuthor;
  final int roles;
  final int filters;
  final int groups;
  final List<String> mimeTypes;
  final String distroId;
  final int networkState;
  final bool locked;
  final int versionMajor;
  final int versionMinor;
  final int versionMicro;

  const PkManagerProps({
    required this.backendName,
    required this.backendDescription,
    required this.backendAuthor,
    required this.roles,
    required this.filters,
    required this.groups,
    required this.mimeTypes,
    required this.distroId,
    required this.networkState,
    required this.locked,
    required this.versionMajor,
    required this.versionMinor,
    required this.versionMicro,
  });
}

/// Finished marker (discriminator 0x20).
class PkFinished {
  final int exitCode;
  final int runtimeMs;

  const PkFinished({required this.exitCode, required this.runtimeMs});
}
