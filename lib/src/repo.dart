// repo.dart — repository types.

/// Repository detail from the RepoDetail signal.
class PkRepoDetail {
  final String repoId;
  final String description;
  final bool enabled;

  const PkRepoDetail({
    required this.repoId,
    required this.description,
    required this.enabled,
  });
}

/// EULA requirement from the EulaRequired signal.
class PkEulaRequired {
  final String eulaId;
  final String packageId;
  final String vendorName;
  final String licenseAgreement;

  const PkEulaRequired({
    required this.eulaId,
    required this.packageId,
    required this.vendorName,
    required this.licenseAgreement,
  });
}

/// Repository signature requirement from the RepoSignatureRequired signal.
class PkRepoSigRequired {
  final String packageId;
  final String repositoryName;
  final String keyUrl;
  final String keyUserId;
  final String keyId;
  final String keyFingerprint;
  final String keyTimestamp;
  final int type;

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
