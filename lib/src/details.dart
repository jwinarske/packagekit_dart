// details.dart — update detail and file list types.

/// Update detail from the UpdateDetail signal.
class PkUpdateDetail {
  /// The package identifier string ("name;version;arch;data").
  final String packageId;

  /// Package IDs that this update replaces.
  final List<String> updates;

  /// Package IDs that this update obsoletes.
  final List<String> obsoletes;

  /// Vendor advisory URLs.
  final List<String> vendorUrls;

  /// Bugzilla / bug-tracker URLs related to this update.
  final List<String> bugzillaUrls;

  /// CVE URLs related to this update.
  final List<String> cveUrls;

  /// Restart type required after applying this update (PK_RESTART_ENUM_*).
  final int restart;

  /// Human-readable description of the update.
  final String updateText;

  /// Changelog text for this update.
  final String changelog;

  /// Update state (PK_UPDATE_STATE_ENUM_*).
  final int state;

  /// ISO 8601 date when the update was issued.
  final String issued;

  /// ISO 8601 date when the update was last modified.
  final String updated;

  /// Creates an update detail instance.
  const PkUpdateDetail({
    required this.packageId,
    required this.updates,
    required this.obsoletes,
    required this.vendorUrls,
    required this.bugzillaUrls,
    required this.cveUrls,
    required this.restart,
    required this.updateText,
    required this.changelog,
    required this.state,
    required this.issued,
    required this.updated,
  });
}

/// Files owned by a package, from the Files signal.
class PkFiles {
  /// The package identifier string.
  final String packageId;

  /// Absolute paths of files owned by the package.
  final List<String> files;

  /// Creates a file list instance.
  const PkFiles({required this.packageId, required this.files});
}

/// Message from the daemon (Message signal).
class PkMessage {
  /// Message type (PK_MESSAGE_ENUM_*).
  final int type;

  /// Human-readable message text.
  final String details;

  /// Creates a daemon message instance.
  const PkMessage({required this.type, required this.details});
}

/// Error code from the ErrorCode signal.
class PkErrorCode {
  /// Numeric error code (PK_ERROR_ENUM_*).
  final int code;

  /// Human-readable error description.
  final String details;

  /// Creates an error code instance.
  const PkErrorCode({required this.code, required this.details});
}

/// Restart requirement from the RequireRestart signal.
class PkRequireRestart {
  /// Restart type (PK_RESTART_ENUM_*).
  final int type;

  /// The package identifier that requires a restart.
  final String packageId;

  /// Creates a restart requirement instance.
  const PkRequireRestart({required this.type, required this.packageId});
}
