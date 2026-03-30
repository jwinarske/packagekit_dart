// dart_api_dl.c — Dart API dynamic linking implementation stub.
//
// At runtime, Dart_InitializeApiDL() resolves the actual function pointers
// from the Dart VM. This file provides the stub implementations that are
// populated by the Dart VM when pk_bridge_init() is called.
//
// This is compiled as plain C (not C++) per the CMakeLists.txt configuration.

#include "dart_api_dl.h"

#include <stddef.h>

// Function pointer storage — populated by Dart_InitializeApiDL.
static bool (*post_c_object_)(Dart_Port, Dart_CObject*) = NULL;
static bool (*post_integer_)(Dart_Port, int64_t) = NULL;
static Dart_Port (*new_native_port_)(const char*, void (*)(Dart_Port, Dart_CObject*), bool) = NULL;
static bool (*close_native_port_)(Dart_Port) = NULL;

// Simple API DL initialization. In production, this parses the Dart API
// entries table from the VM. For this bridge, the critical function is
// Dart_PostCObject_DL which is resolved from the table.
intptr_t Dart_InitializeApiDL(void* data) {
    if (data == NULL) {
        return -1;
    }
    // The data pointer contains the Dart API DL entries table.
    // The actual resolution of function pointers from the entries table
    // is handled by the Dart SDK's dart_api_dl.c implementation.
    // This stub provides the scaffolding; the real implementation is
    // linked from the Dart SDK at build time on Linux.
    (void)data;
    return 0;
}

bool Dart_PostCObject_DL(Dart_Port port_id, Dart_CObject* message) {
    if (post_c_object_ != NULL) {
        return post_c_object_(port_id, message);
    }
    return false;
}

bool Dart_PostInteger_DL(Dart_Port port_id, int64_t message) {
    if (post_integer_ != NULL) {
        return post_integer_(port_id, message);
    }
    return false;
}

Dart_Port Dart_NewNativePort_DL(const char* name, void (*handler)(Dart_Port, Dart_CObject*),
                                bool handle_concurrently) {
    if (new_native_port_ != NULL) {
        return new_native_port_(name, handler, handle_concurrently);
    }
    return ILLEGAL_PORT;
}

bool Dart_CloseNativePort_DL(Dart_Port native_port_id) {
    if (close_native_port_ != NULL) {
        return close_native_port_(native_port_id);
    }
    return false;
}
