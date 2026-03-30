// test_types.cpp — glaze roundtrip tests for every pk_types.h struct.
// Encodes each struct to bytes, decodes it back, and verifies field equality.

#include <gtest/gtest.h>

#include <cstring>

#include "pk_types.h"

// ── PkPackage ────────────────────────────────────────────────────────────────

TEST(PkTypes, PkPackageRoundtrip) {
    PkPackage orig{
        .info = 2,
        .packageId = "bash;5.1.8-1;x86_64;fedora",
        .summary = "The GNU Bourne Again shell",
    };
    auto buf = glz::encode(orig);
    PkPackage decoded{};
    glz::decode(buf.data(), 0, decoded);

    EXPECT_EQ(decoded.info, orig.info);
    EXPECT_EQ(decoded.packageId, orig.packageId);
    EXPECT_EQ(decoded.summary, orig.summary);
}

TEST(PkTypes, PkPackageEmpty) {
    PkPackage orig{};
    auto buf = glz::encode(orig);
    PkPackage decoded{};
    glz::decode(buf.data(), 0, decoded);

    EXPECT_EQ(decoded.info, 0u);
    EXPECT_TRUE(decoded.packageId.empty());
    EXPECT_TRUE(decoded.summary.empty());
}

// ── PkProgress ───────────────────────────────────────────────────────────────

TEST(PkTypes, PkProgressRoundtrip) {
    PkProgress orig{
        .packageId = "vim;9.0-1;x86_64;updates",
        .status = 10,
        .percentage = 42,
        .isItem = true,
    };
    auto buf = glz::encode(orig);
    PkProgress decoded{};
    glz::decode(buf.data(), 0, decoded);

    EXPECT_EQ(decoded.packageId, orig.packageId);
    EXPECT_EQ(decoded.status, orig.status);
    EXPECT_EQ(decoded.percentage, orig.percentage);
    EXPECT_EQ(decoded.isItem, orig.isItem);
}

TEST(PkTypes, PkProgressStatusOnly) {
    PkProgress orig{
        .packageId = "",
        .status = 3,
        .percentage = 101,
        .isItem = false,
    };
    auto buf = glz::encode(orig);
    PkProgress decoded{};
    glz::decode(buf.data(), 0, decoded);

    EXPECT_TRUE(decoded.packageId.empty());
    EXPECT_EQ(decoded.status, 3u);
    EXPECT_EQ(decoded.percentage, 101u);
    EXPECT_FALSE(decoded.isItem);
}

// ── PkDetails ────────────────────────────────────────────────────────────────

TEST(PkTypes, PkDetailsRoundtrip) {
    PkDetails orig{
        .packageId = "firefox;115.0-1;x86_64;fedora",
        .summary = "Mozilla Firefox Web browser",
        .description = "A free and open source web browser.",
        .url = "https://www.mozilla.org/firefox/",
        .license = "MPL-2.0",
        .group = "Applications/Internet",
        .size = 98765432,
    };
    auto buf = glz::encode(orig);
    PkDetails decoded{};
    glz::decode(buf.data(), 0, decoded);

    EXPECT_EQ(decoded.packageId, orig.packageId);
    EXPECT_EQ(decoded.summary, orig.summary);
    EXPECT_EQ(decoded.description, orig.description);
    EXPECT_EQ(decoded.url, orig.url);
    EXPECT_EQ(decoded.license, orig.license);
    EXPECT_EQ(decoded.group, orig.group);
    EXPECT_EQ(decoded.size, orig.size);
}

// ── PkUpdateDetail ───────────────────────────────────────────────────────────

TEST(PkTypes, PkUpdateDetailRoundtrip) {
    PkUpdateDetail orig{
        .packageId = "openssl;3.1.1-1;x86_64;updates",
        .updates = {"openssl;3.1.0-1;x86_64;fedora"},
        .obsoletes = {},
        .vendorUrls = {"https://vendor.example.com"},
        .bugzillaUrls = {"https://bugzilla.example.com/123"},
        .cveUrls = {"https://cve.example.com/CVE-2023-1234"},
        .restart = 1,
        .updateText = "Security update for OpenSSL",
        .changelog = "- Fixed CVE-2023-1234",
        .state = 8,
        .issued = "2023-06-15T10:00:00Z",
        .updated = "2023-06-16T12:00:00Z",
    };
    auto buf = glz::encode(orig);
    PkUpdateDetail decoded{};
    glz::decode(buf.data(), 0, decoded);

    EXPECT_EQ(decoded.packageId, orig.packageId);
    EXPECT_EQ(decoded.updates, orig.updates);
    EXPECT_EQ(decoded.obsoletes, orig.obsoletes);
    EXPECT_EQ(decoded.vendorUrls, orig.vendorUrls);
    EXPECT_EQ(decoded.bugzillaUrls, orig.bugzillaUrls);
    EXPECT_EQ(decoded.cveUrls, orig.cveUrls);
    EXPECT_EQ(decoded.restart, orig.restart);
    EXPECT_EQ(decoded.updateText, orig.updateText);
    EXPECT_EQ(decoded.changelog, orig.changelog);
    EXPECT_EQ(decoded.state, orig.state);
    EXPECT_EQ(decoded.issued, orig.issued);
    EXPECT_EQ(decoded.updated, orig.updated);
}

TEST(PkTypes, PkUpdateDetailEmptyVectors) {
    PkUpdateDetail orig{
        .packageId = "pkg;1.0;x86_64;repo",
    };
    auto buf = glz::encode(orig);
    PkUpdateDetail decoded{};
    glz::decode(buf.data(), 0, decoded);

    EXPECT_EQ(decoded.packageId, orig.packageId);
    EXPECT_TRUE(decoded.updates.empty());
    EXPECT_TRUE(decoded.obsoletes.empty());
    EXPECT_TRUE(decoded.vendorUrls.empty());
    EXPECT_TRUE(decoded.bugzillaUrls.empty());
    EXPECT_TRUE(decoded.cveUrls.empty());
}

// ── PkRepoDetail ─────────────────────────────────────────────────────────────

TEST(PkTypes, PkRepoDetailRoundtrip) {
    PkRepoDetail orig{
        .repoId = "fedora",
        .description = "Fedora 41 - x86_64",
        .enabled = true,
    };
    auto buf = glz::encode(orig);
    PkRepoDetail decoded{};
    glz::decode(buf.data(), 0, decoded);

    EXPECT_EQ(decoded.repoId, orig.repoId);
    EXPECT_EQ(decoded.description, orig.description);
    EXPECT_EQ(decoded.enabled, orig.enabled);
}

TEST(PkTypes, PkRepoDetailDisabled) {
    PkRepoDetail orig{
        .repoId = "rpmfusion-nonfree",
        .description = "RPM Fusion for Fedora - Nonfree",
        .enabled = false,
    };
    auto buf = glz::encode(orig);
    PkRepoDetail decoded{};
    glz::decode(buf.data(), 0, decoded);

    EXPECT_FALSE(decoded.enabled);
}

// ── PkFiles ──────────────────────────────────────────────────────────────────

TEST(PkTypes, PkFilesRoundtrip) {
    PkFiles orig{
        .packageId = "bash;5.1.8-1;x86_64;fedora",
        .files = {"/usr/bin/bash", "/usr/share/man/man1/bash.1.gz", "/etc/skel/.bashrc"},
    };
    auto buf = glz::encode(orig);
    PkFiles decoded{};
    glz::decode(buf.data(), 0, decoded);

    EXPECT_EQ(decoded.packageId, orig.packageId);
    EXPECT_EQ(decoded.files, orig.files);
}

TEST(PkTypes, PkFilesEmpty) {
    PkFiles orig{.packageId = "empty;1.0;noarch;test"};
    auto buf = glz::encode(orig);
    PkFiles decoded{};
    glz::decode(buf.data(), 0, decoded);

    EXPECT_EQ(decoded.packageId, orig.packageId);
    EXPECT_TRUE(decoded.files.empty());
}

// ── PkErrorCode ──────────────────────────────────────────────────────────────

TEST(PkTypes, PkErrorCodeRoundtrip) {
    PkErrorCode orig{
        .code = 12,
        .details = "Package not found: nonexistent",
    };
    auto buf = glz::encode(orig);
    PkErrorCode decoded{};
    glz::decode(buf.data(), 0, decoded);

    EXPECT_EQ(decoded.code, orig.code);
    EXPECT_EQ(decoded.details, orig.details);
}

// ── PkMessage ────────────────────────────────────────────────────────────────

TEST(PkTypes, PkMessageRoundtrip) {
    PkMessage orig{
        .type = 3,
        .details = "Cache is out of date",
    };
    auto buf = glz::encode(orig);
    PkMessage decoded{};
    glz::decode(buf.data(), 0, decoded);

    EXPECT_EQ(decoded.type, orig.type);
    EXPECT_EQ(decoded.details, orig.details);
}

// ── PkEulaRequired ───────────────────────────────────────────────────────────

TEST(PkTypes, PkEulaRequiredRoundtrip) {
    PkEulaRequired orig{
        .eulaId = "eula-123",
        .packageId = "proprietary;1.0;x86_64;vendor",
        .vendorName = "ExampleCorp",
        .licenseAgreement = "You agree to the terms...",
    };
    auto buf = glz::encode(orig);
    PkEulaRequired decoded{};
    glz::decode(buf.data(), 0, decoded);

    EXPECT_EQ(decoded.eulaId, orig.eulaId);
    EXPECT_EQ(decoded.packageId, orig.packageId);
    EXPECT_EQ(decoded.vendorName, orig.vendorName);
    EXPECT_EQ(decoded.licenseAgreement, orig.licenseAgreement);
}

// ── PkRepoSigRequired ───────────────────────────────────────────────────────

TEST(PkTypes, PkRepoSigRequiredRoundtrip) {
    PkRepoSigRequired orig{
        .packageId = "kernel;6.5-1;x86_64;updates",
        .repositoryName = "updates",
        .keyUrl = "https://keys.example.com/RPM-GPG-KEY",
        .keyUserId = "Fedora (41) <fedora-41-primary@fedoraproject.org>",
        .keyId = "0x12345678",
        .keyFingerprint = "ABCD1234EFGH5678",
        .keyTimestamp = "2023-01-01",
        .type = 1,
    };
    auto buf = glz::encode(orig);
    PkRepoSigRequired decoded{};
    glz::decode(buf.data(), 0, decoded);

    EXPECT_EQ(decoded.packageId, orig.packageId);
    EXPECT_EQ(decoded.repositoryName, orig.repositoryName);
    EXPECT_EQ(decoded.keyUrl, orig.keyUrl);
    EXPECT_EQ(decoded.keyUserId, orig.keyUserId);
    EXPECT_EQ(decoded.keyId, orig.keyId);
    EXPECT_EQ(decoded.keyFingerprint, orig.keyFingerprint);
    EXPECT_EQ(decoded.keyTimestamp, orig.keyTimestamp);
    EXPECT_EQ(decoded.type, orig.type);
}

// ── PkRequireRestart ─────────────────────────────────────────────────────────

TEST(PkTypes, PkRequireRestartRoundtrip) {
    PkRequireRestart orig{
        .type = 2,
        .packageId = "kernel;6.5-1;x86_64;updates",
    };
    auto buf = glz::encode(orig);
    PkRequireRestart decoded{};
    glz::decode(buf.data(), 0, decoded);

    EXPECT_EQ(decoded.type, orig.type);
    EXPECT_EQ(decoded.packageId, orig.packageId);
}

// ── PkManagerProps ───────────────────────────────────────────────────────────

TEST(PkTypes, PkManagerPropsRoundtrip) {
    PkManagerProps orig{
        .backendName = "dnf",
        .backendDescription = "DNF package manager",
        .backendAuthor = "Fedora Project",
        .roles = 0x1FFFFF,
        .filters = 0xFFFFFFF,
        .groups = 0x3FFFF,
        .mimeTypes = {"application/x-rpm", "application/x-deb"},
        .distroId = "fedora;41;x86_64",
        .networkState = 4,
        .locked = false,
        .versionMajor = 1,
        .versionMinor = 2,
        .versionMicro = 6,
    };
    auto buf = glz::encode(orig);
    PkManagerProps decoded{};
    glz::decode(buf.data(), 0, decoded);

    EXPECT_EQ(decoded.backendName, orig.backendName);
    EXPECT_EQ(decoded.backendDescription, orig.backendDescription);
    EXPECT_EQ(decoded.backendAuthor, orig.backendAuthor);
    EXPECT_EQ(decoded.roles, orig.roles);
    EXPECT_EQ(decoded.filters, orig.filters);
    EXPECT_EQ(decoded.groups, orig.groups);
    EXPECT_EQ(decoded.mimeTypes, orig.mimeTypes);
    EXPECT_EQ(decoded.distroId, orig.distroId);
    EXPECT_EQ(decoded.networkState, orig.networkState);
    EXPECT_EQ(decoded.locked, orig.locked);
    EXPECT_EQ(decoded.versionMajor, orig.versionMajor);
    EXPECT_EQ(decoded.versionMinor, orig.versionMinor);
    EXPECT_EQ(decoded.versionMicro, orig.versionMicro);
}

TEST(PkTypes, PkManagerPropsDefaults) {
    PkManagerProps orig{};
    auto buf = glz::encode(orig);
    PkManagerProps decoded{};
    glz::decode(buf.data(), 0, decoded);

    EXPECT_TRUE(decoded.backendName.empty());
    EXPECT_EQ(decoded.roles, 0u);
    EXPECT_EQ(decoded.filters, 0u);
    EXPECT_TRUE(decoded.mimeTypes.empty());
    EXPECT_FALSE(decoded.locked);
    EXPECT_EQ(decoded.versionMajor, 0u);
}
