// details.dart — update detail and file list types.

/// Update detail from the UpdateDetail signal.
class PkUpdateDetail {
  final String packageId;
  final List<String> updates;
  final List<String> obsoletes;
  final List<String> vendorUrls;
  final List<String> bugzillaUrls;
  final List<String> cveUrls;
  final int restart;
  final String updateText;
  final String changelog;
  final int state;
  final String issued;
  final String updated;

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
  final String packageId;
  final List<String> files;

  const PkFiles({required this.packageId, required this.files});
}

/// Message from the daemon (Message signal).
class PkMessage {
  final int type;
  final String details;

  const PkMessage({required this.type, required this.details});
}

/// Error code from the ErrorCode signal.
class PkErrorCode {
  final int code;
  final String details;

  const PkErrorCode({required this.code, required this.details});
}

/// Restart requirement from the RequireRestart signal.
class PkRequireRestart {
  final int type;
  final String packageId;

  const PkRequireRestart({required this.type, required this.packageId});
}
