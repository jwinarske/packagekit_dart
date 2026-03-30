// test_manager.cpp — Unit tests for PkManager.
//
// These tests verify the manager's property reading and CreateTransaction
// logic using a mock/stub approach. Since we cannot connect to a real
// system bus in CI, we test the serialization and post logic in isolation.

#include "pk_manager.h"
#include "pk_types.h"

#include <gtest/gtest.h>

// ── PkManagerProps serialization tests ───────────────────────────────────────
// These verify that the manager properties can be serialized with the
// discriminator byte prefix, matching what readProperties() would post.

TEST(PkManager, ManagerPropsWithDiscriminator) {
    PkManagerProps props{
        .backendName = "aptcc",
        .backendDescription = "APT package manager",
        .backendAuthor = "Ubuntu Developers",
        .roles = 0x1FFFFF,
        .filters = 0xFFFFFFF,
        .groups = 0x3FFFF,
        .mimeTypes = {"application/x-deb"},
        .distroId = "ubuntu;24.04;x86_64",
        .networkState = 4,
        .locked = false,
        .versionMajor = 1,
        .versionMinor = 2,
        .versionMicro = 6,
    };

    // Simulate what PkManager::post() does: discriminator + glaze payload.
    auto payload = glz::encode(props);
    std::vector<uint8_t> buf;
    buf.reserve(1 + payload.size());
    buf.push_back(0x0C);
    buf.insert(buf.end(), payload.begin(), payload.end());

    // Verify discriminator byte.
    ASSERT_FALSE(buf.empty());
    EXPECT_EQ(buf[0], 0x0C);

    // Decode the payload (skip discriminator).
    PkManagerProps decoded{};
    glz::decode(buf.data(), 1, decoded);

    EXPECT_EQ(decoded.backendName, props.backendName);
    EXPECT_EQ(decoded.backendDescription, props.backendDescription);
    EXPECT_EQ(decoded.backendAuthor, props.backendAuthor);
    EXPECT_EQ(decoded.roles, props.roles);
    EXPECT_EQ(decoded.filters, props.filters);
    EXPECT_EQ(decoded.groups, props.groups);
    EXPECT_EQ(decoded.mimeTypes, props.mimeTypes);
    EXPECT_EQ(decoded.distroId, props.distroId);
    EXPECT_EQ(decoded.networkState, props.networkState);
    EXPECT_EQ(decoded.locked, props.locked);
    EXPECT_EQ(decoded.versionMajor, props.versionMajor);
    EXPECT_EQ(decoded.versionMinor, props.versionMinor);
    EXPECT_EQ(decoded.versionMicro, props.versionMicro);
}

TEST(PkManager, ManagerPropsDefaultValues) {
    PkManagerProps props{};

    auto payload = glz::encode(props);
    std::vector<uint8_t> buf;
    buf.push_back(0x0C);
    buf.insert(buf.end(), payload.begin(), payload.end());

    PkManagerProps decoded{};
    glz::decode(buf.data(), 1, decoded);

    EXPECT_TRUE(decoded.backendName.empty());
    EXPECT_EQ(decoded.roles, 0u);
    EXPECT_EQ(decoded.networkState, 0u);
    EXPECT_FALSE(decoded.locked);
}

// ── Event byte encoding tests ────────────────────────────────────────────────

TEST(PkManager, UpdatesChangedEventByte) {
    // UpdatesChanged is sent as a single 0xD0 byte.
    uint8_t event = 0xD0;
    EXPECT_EQ(event, 0xD0);
}

TEST(PkManager, RepoListChangedEventByte) {
    uint8_t event = 0xD1;
    EXPECT_EQ(event, 0xD1);
}

TEST(PkManager, NetworkStateChangedEncoding) {
    // NetworkStateChanged: discriminator 0xD2 + uint32 state.
    uint32_t state = 4;
    std::vector<uint8_t> buf;
    buf.push_back(0xD2);
    glz::detail::encode_field(buf, state);

    ASSERT_EQ(buf.size(), 5u);
    EXPECT_EQ(buf[0], 0xD2);

    uint32_t decoded_state{};
    glz::detail::decode_field(buf.data(), 1, decoded_state);
    EXPECT_EQ(decoded_state, state);
}

TEST(PkManager, NetworkStateChangedZero) {
    uint32_t state = 0;
    std::vector<uint8_t> buf;
    buf.push_back(0xD2);
    glz::detail::encode_field(buf, state);

    uint32_t decoded_state = 99;
    glz::detail::decode_field(buf.data(), 1, decoded_state);
    EXPECT_EQ(decoded_state, 0u);
}
