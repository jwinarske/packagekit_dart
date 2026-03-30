// glaze_meta.h — lightweight compile-time struct reflection for native_comms
// Channel B payloads. Provides glz::meta<T> and glz::field() used by pk_types.h
// to describe struct fields for glaze binary serialization.
//
// This header is vendored from native_comms. The actual glaze encode/decode
// is handled by the native_comms codec; this file only provides the metadata
// declarations that pk_types.h depends on.

#pragma once

#include <cstddef>
#include <cstdint>
#include <cstring>
#include <string>
#include <tuple>
#include <vector>

namespace glz {

// Field descriptor: a name + member pointer pair.
template <typename T, typename MemberPtr>
struct FieldDescriptor {
    const char* name;
    MemberPtr ptr;
};

template <typename T, typename MemberPtr>
constexpr auto field(const char* name, MemberPtr ptr) {
    return FieldDescriptor<T, MemberPtr>{name, ptr};
}

// Overload for deduced class type from member pointer.
template <typename C, typename M>
constexpr auto field(const char* name, M C::* ptr) {
    return FieldDescriptor<C, M C::*>{name, ptr};
}

// meta<T> — specialize for each struct to list its fields.
// Default: empty (no fields).
template <typename T>
struct meta {
    static constexpr auto fields = std::make_tuple();
};

// ── Binary encode/decode helpers ────────────────────────────────────────────

namespace detail {

inline void write_bytes(std::vector<uint8_t>& buf, const void* data, size_t n) {
    const auto* p = static_cast<const uint8_t*>(data);
    buf.insert(buf.end(), p, p + n);
}

inline size_t read_bytes(const uint8_t* buf, size_t offset, void* out, size_t n) {
    std::memcpy(out, buf + offset, n);
    return offset + n;
}

// Encode primitives
inline void encode_field(std::vector<uint8_t>& buf, uint8_t v) {
    buf.push_back(v);
}
inline void encode_field(std::vector<uint8_t>& buf, bool v) {
    buf.push_back(v ? 1 : 0);
}
inline void encode_field(std::vector<uint8_t>& buf, uint32_t v) {
    write_bytes(buf, &v, sizeof(v));
}
inline void encode_field(std::vector<uint8_t>& buf, uint64_t v) {
    write_bytes(buf, &v, sizeof(v));
}
inline void encode_field(std::vector<uint8_t>& buf, const std::string& s) {
    auto len = static_cast<uint32_t>(s.size());
    write_bytes(buf, &len, sizeof(len));
    write_bytes(buf, s.data(), s.size());
}
inline void encode_field(std::vector<uint8_t>& buf, const std::vector<std::string>& v) {
    auto count = static_cast<uint32_t>(v.size());
    write_bytes(buf, &count, sizeof(count));
    for (const auto& s : v) {
        encode_field(buf, s);
    }
}

// Decode primitives
inline size_t decode_field(const uint8_t* buf, size_t offset, uint8_t& v) {
    v = buf[offset];
    return offset + 1;
}
inline size_t decode_field(const uint8_t* buf, size_t offset, bool& v) {
    v = buf[offset] != 0;
    return offset + 1;
}
inline size_t decode_field(const uint8_t* buf, size_t offset, uint32_t& v) {
    return read_bytes(buf, offset, &v, sizeof(v));
}
inline size_t decode_field(const uint8_t* buf, size_t offset, uint64_t& v) {
    return read_bytes(buf, offset, &v, sizeof(v));
}
inline size_t decode_field(const uint8_t* buf, size_t offset, std::string& s) {
    uint32_t len{};
    offset = read_bytes(buf, offset, &len, sizeof(len));
    s.assign(reinterpret_cast<const char*>(buf + offset), len);
    return offset + len;
}
inline size_t decode_field(const uint8_t* buf, size_t offset, std::vector<std::string>& v) {
    uint32_t count{};
    offset = read_bytes(buf, offset, &count, sizeof(count));
    v.resize(count);
    for (uint32_t i = 0; i < count; ++i) {
        offset = decode_field(buf, offset, v[i]);
    }
    return offset;
}

template <typename T, typename Tuple, std::size_t... I>
void encode_impl(std::vector<uint8_t>& buf, const T& obj, const Tuple& fields,
                 std::index_sequence<I...>) {
    (encode_field(buf, obj.*(std::get<I>(fields).ptr)), ...);
}

template <typename T, typename Tuple, std::size_t... I>
size_t decode_impl(const uint8_t* buf, size_t offset, T& obj, const Tuple& fields,
                   std::index_sequence<I...>) {
    ((offset = decode_field(buf, offset, obj.*(std::get<I>(fields).ptr))), ...);
    return offset;
}

}  // namespace detail

// Encode a struct to a byte buffer using its meta<T>::fields.
template <typename T>
std::vector<uint8_t> encode(const T& obj) {
    std::vector<uint8_t> buf;
    constexpr auto fields = meta<T>::fields;
    constexpr auto N = std::tuple_size_v<decltype(fields)>;
    detail::encode_impl(buf, obj, fields, std::make_index_sequence<N>{});
    return buf;
}

// Decode a struct from a byte buffer using its meta<T>::fields.
// Returns the offset past the consumed bytes.
template <typename T>
size_t decode(const uint8_t* buf, size_t offset, T& obj) {
    constexpr auto fields = meta<T>::fields;
    constexpr auto N = std::tuple_size_v<decltype(fields)>;
    return detail::decode_impl(buf, offset, obj, fields, std::make_index_sequence<N>{});
}

}  // namespace glz
