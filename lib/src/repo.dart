// repo.dart — repository types.

/// Repository detail from the RepoDetail signal.
class PkRepoDetail {
  /// The repository identifier (e.g. "fedora", "updates").
  final String repoId;

  /// Human-readable repository description.
  final String description;

  /// Whether this repository is currently enabled.
  final bool enabled;

  /// Creates a [PkRepoDetail] instance.
  const PkRepoDetail({
    required this.repoId,
    required this.description,
    required this.enabled,
  });
}

/// EULA requirement from the EulaRequired signal.
class PkEulaRequired {
  /// Unique identifier for this EULA.
  final String eulaId;

  /// The package identifier that requires EULA acceptance.
  final String packageId;

  /// The vendor name.
  final String vendorName;

  /// The full license agreement text.
  final String licenseAgreement;

  /// Creates a [PkEulaRequired] instance.
  const PkEulaRequired({
    required this.eulaId,
    required this.packageId,
    required this.vendorName,
    required this.licenseAgreement,
  });
}

/// Repository signature requirement from the RepoSignatureRequired signal.
class PkRepoSigRequired {
  /// The package identifier that requires signature verification.
  final String packageId;

  /// The repository name.
  final String repositoryName;

  /// URL where the signing key can be downloaded.
  final String keyUrl;

  /// User ID of the signing key.
  final String keyUserId;

  /// Short key ID.
  final String keyId;

  /// Full key fingerprint.
  final String keyFingerprint;

  /// Human-readable timestamp of the key.
  final String keyTimestamp;

  /// Signature type (PK_SIGTYPE_ENUM_*).
  final int type;

  /// Creates a [PkRepoSigRequired] instance.
  const PkRepoSigRequired({
    required this.packageId,
    required this.repositoryName,
    required this.keyUrl,
    required this.keyUserId,
    required this.keyId,
    required this.keyFingerprint,
    required this.keyTimestamp,
    required this.type,
  });
}
