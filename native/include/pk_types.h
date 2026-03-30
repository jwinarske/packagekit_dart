// pk_types.h — wire types for native_comms Channel B payloads.
// All structs glaze-encode into the kExternalTypedData buffer posted
// via Dart_PostCObject_DL. Discriminator byte at offset 0:
//   0x01 = PkPackage        (Package signal)
//   0x02 = PkProgress       (Progress / ItemProgress / StatusChanged)
//   0x03 = PkDetails        (Details signal)
//   0x04 = PkUpdateDetail   (UpdateDetail signal)
//   0x05 = PkRepoDetail     (RepoDetail signal)
//   0x06 = PkFiles          (Files signal)
//   0x07 = PkErrorCode      (ErrorCode signal)
//   0x08 = PkMessage        (Message signal)
//   0x09 = PkEulaRequired   (EulaRequired signal)
//   0x0A = PkRepoSigRequired(RepoSignatureRequired signal)
//   0x0B = PkRequireRestart (RequireRestart signal)
//   0x0C = PkManagerProp    (daemon properties snapshot)
//   0x20 = Finished (exit code u8 + runtime u32 follow)
//   0xFF = stream done sentinel (after Finished)

#pragma once
#include <cstdint>
#include <string>
#include <vector>

#include "glaze_meta.h"

// ── PkPackage ────────────────────────────────────────────────────────────────
// Emitted by the Package signal. info is PkInfoEnum (uint32).
struct PkPackage {
    uint32_t info{};        // PK_INFO_ENUM_*
    std::string packageId;  // "name;version;arch;data"
    std::string summary;
};
template <>
struct glz::meta<PkPackage> {
    static constexpr auto fields = std::make_tuple(glz::field("info", &PkPackage::info),
                                                   glz::field("packageId", &PkPackage::packageId),
                                                   glz::field("summary", &PkPackage::summary));
};

// ── PkProgress ───────────────────────────────────────────────────────────────
// Combines Progress, ItemProgress, and StatusChanged into one type.
// When emitted from StatusChanged, packageId and percentage are zero/empty.
struct PkProgress {
    std::string packageId;
    uint32_t status{};      // PK_STATUS_ENUM_*
    uint32_t percentage{};  // 0–100; 101 = unknown
    bool isItem{};          // true = ItemProgress signal
};
template <>
struct glz::meta<PkProgress> {
    static constexpr auto fields = std::make_tuple(
        glz::field("packageId", &PkProgress::packageId), glz::field("status", &PkProgress::status),
        glz::field("percentage", &PkProgress::percentage),
        glz::field("isItem", &PkProgress::isItem));
};

// ── PkDetails ────────────────────────────────────────────────────────────────
struct PkDetails {
    std::string packageId;
    std::string summary;
    std::string description;
    std::string url;
    std::string license;
    std::string group;
    uint64_t size{};  // bytes
};
template <>
struct glz::meta<PkDetails> {
    static constexpr auto fields = std::make_tuple(
        glz::field("packageId", &PkDetails::packageId), glz::field("summary", &PkDetails::summary),
        glz::field("description", &PkDetails::description), glz::field("url", &PkDetails::url),
        glz::field("license", &PkDetails::license), glz::field("group", &PkDetails::group),
        glz::field("size", &PkDetails::size));
};

// ── PkUpdateDetail ───────────────────────────────────────────────────────────
struct PkUpdateDetail {
    std::string packageId;
    std::vector<std::string> updates;
    std::vector<std::string> obsoletes;
    std::vector<std::string> vendorUrls;
    std::vector<std::string> bugzillaUrls;
    std::vector<std::string> cveUrls;
    uint32_t restart{};
    std::string updateText;
    std::string changelog;
    uint32_t state{};
    std::string issued;
    std::string updated;
};
template <>
struct glz::meta<PkUpdateDetail> {
    static constexpr auto fields = std::make_tuple(
        glz::field("packageId", &PkUpdateDetail::packageId),
        glz::field("updates", &PkUpdateDetail::updates),
        glz::field("obsoletes", &PkUpdateDetail::obsoletes),
        glz::field("vendorUrls", &PkUpdateDetail::vendorUrls),
        glz::field("bugzillaUrls", &PkUpdateDetail::bugzillaUrls),
        glz::field("cveUrls", &PkUpdateDetail::cveUrls),
        glz::field("restart", &PkUpdateDetail::restart),
        glz::field("updateText", &PkUpdateDetail::updateText),
        glz::field("changelog", &PkUpdateDetail::changelog),
        glz::field("state", &PkUpdateDetail::state), glz::field("issued", &PkUpdateDetail::issued),
        glz::field("updated", &PkUpdateDetail::updated));
};

// ── PkRepoDetail ─────────────────────────────────────────────────────────────
struct PkRepoDetail {
    std::string repoId;
    std::string description;
    bool enabled{};
};
template <>
struct glz::meta<PkRepoDetail> {
    static constexpr auto fields =
        std::make_tuple(glz::field("repoId", &PkRepoDetail::repoId),
                        glz::field("description", &PkRepoDetail::description),
                        glz::field("enabled", &PkRepoDetail::enabled));
};

// ── PkFiles ──────────────────────────────────────────────────────────────────
struct PkFiles {
    std::string packageId;
    std::vector<std::string> files;
};
template <>
struct glz::meta<PkFiles> {
    static constexpr auto fields = std::make_tuple(glz::field("packageId", &PkFiles::packageId),
                                                   glz::field("files", &PkFiles::files));
};

// ── PkErrorCode ──────────────────────────────────────────────────────────────
struct PkErrorCode {
    uint32_t code{};  // PK_ERROR_ENUM_*
    std::string details;
};
template <>
struct glz::meta<PkErrorCode> {
    static constexpr auto fields = std::make_tuple(glz::field("code", &PkErrorCode::code),
                                                   glz::field("details", &PkErrorCode::details));
};

// ── PkMessage ────────────────────────────────────────────────────────────────
struct PkMessage {
    uint32_t type{};  // PK_MESSAGE_ENUM_*
    std::string details;
};
template <>
struct glz::meta<PkMessage> {
    static constexpr auto fields = std::make_tuple(glz::field("type", &PkMessage::type),
                                                   glz::field("details", &PkMessage::details));
};

// ── PkEulaRequired ───────────────────────────────────────────────────────────
struct PkEulaRequired {
    std::string eulaId;
    std::string packageId;
    std::string vendorName;
    std::string licenseAgreement;
};
template <>
struct glz::meta<PkEulaRequired> {
    static constexpr auto fields =
        std::make_tuple(glz::field("eulaId", &PkEulaRequired::eulaId),
                        glz::field("packageId", &PkEulaRequired::packageId),
                        glz::field("vendorName", &PkEulaRequired::vendorName),
                        glz::field("licenseAgreement", &PkEulaRequired::licenseAgreement));
};

// ── PkRepoSignatureRequired ──────────────────────────────────────────────────
struct PkRepoSigRequired {
    std::string packageId;
    std::string repositoryName;
    std::string keyUrl;
    std::string keyUserId;
    std::string keyId;
    std::string keyFingerprint;
    std::string keyTimestamp;
    uint32_t type{};
};
template <>
struct glz::meta<PkRepoSigRequired> {
    static constexpr auto fields =
        std::make_tuple(glz::field("packageId", &PkRepoSigRequired::packageId),
                        glz::field("repositoryName", &PkRepoSigRequired::repositoryName),
                        glz::field("keyUrl", &PkRepoSigRequired::keyUrl),
                        glz::field("keyUserId", &PkRepoSigRequired::keyUserId),
                        glz::field("keyId", &PkRepoSigRequired::keyId),
                        glz::field("keyFingerprint", &PkRepoSigRequired::keyFingerprint),
                        glz::field("keyTimestamp", &PkRepoSigRequired::keyTimestamp),
                        glz::field("type", &PkRepoSigRequired::type));
};

// ── PkRequireRestart ─────────────────────────────────────────────────────────
struct PkRequireRestart {
    uint32_t type{};  // PK_RESTART_ENUM_*
    std::string packageId;
};
template <>
struct glz::meta<PkRequireRestart> {
    static constexpr auto fields =
        std::make_tuple(glz::field("type", &PkRequireRestart::type),
                        glz::field("packageId", &PkRequireRestart::packageId));
};

// ── PkManagerProps ───────────────────────────────────────────────────────────
struct PkManagerProps {
    std::string backendName;
    std::string backendDescription;
    std::string backendAuthor;
    uint64_t roles{};
    uint64_t filters{};
    uint64_t groups{};
    std::vector<std::string> mimeTypes;
    std::string distroId;
    uint32_t networkState{};
    bool locked{};
    uint32_t versionMajor{};
    uint32_t versionMinor{};
    uint32_t versionMicro{};
};
template <>
struct glz::meta<PkManagerProps> {
    static constexpr auto fields =
        std::make_tuple(glz::field("backendName", &PkManagerProps::backendName),
                        glz::field("backendDescription", &PkManagerProps::backendDescription),
                        glz::field("backendAuthor", &PkManagerProps::backendAuthor),
                        glz::field("roles", &PkManagerProps::roles),
                        glz::field("filters", &PkManagerProps::filters),
                        glz::field("groups", &PkManagerProps::groups),
                        glz::field("mimeTypes", &PkManagerProps::mimeTypes),
                        glz::field("distroId", &PkManagerProps::distroId),
                        glz::field("networkState", &PkManagerProps::networkState),
                        glz::field("locked", &PkManagerProps::locked),
                        glz::field("versionMajor", &PkManagerProps::versionMajor),
                        glz::field("versionMinor", &PkManagerProps::versionMinor),
                        glz::field("versionMicro", &PkManagerProps::versionMicro));
};
