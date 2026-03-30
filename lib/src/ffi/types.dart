// types.dart — Dart-side struct mirrors for glaze wire types.

/// Manager properties snapshot (discriminator 0x0C).
class PkManagerProps {
  /// Name of the active backend (e.g. "apt", "dnf", "zypp").
  final String backendName;

  /// Human-readable backend description.
  final String backendDescription;

  /// Backend author name.
  final String backendAuthor;

  /// Bitfield of PK_ROLE_ENUM_* values the backend supports.
  final int roles;

  /// Bitfield of PK_FILTER_ENUM_* values the backend supports.
  final int filters;

  /// Bitfield of PK_GROUP_ENUM_* values the backend supports.
  final int groups;

  /// MIME types the backend can handle (e.g. "application/x-rpm").
  final List<String> mimeTypes;

  /// Distribution ID string (e.g. "fedora;39;x86_64").
  final String distroId;

  /// Current network state (PK_NETWORK_ENUM_*).
  final int networkState;

  /// Whether the daemon is currently locked by another transaction.
  final bool locked;

  /// PackageKit daemon major version.
  final int versionMajor;

  /// PackageKit daemon minor version.
  final int versionMinor;

  /// PackageKit daemon micro version.
  final int versionMicro;

  /// Creates a [PkManagerProps] instance.
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
  /// The exit code (PK_EXIT_ENUM_*).
  final int exitCode;

  /// Wall-clock runtime in milliseconds.
  final int runtimeMs;

  /// Creates a [PkFinished] instance.
  const PkFinished({required this.exitCode, required this.runtimeMs});
}
