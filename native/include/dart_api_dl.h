// dart_api_dl.h — Dart API dynamic linking header (from native_comms).
//
// This is the standard Dart FFI native API header that provides:
//   - Dart_Port        (int64_t send port identifier)
//   - Dart_CObject     (C representation of Dart objects)
//   - Dart_PostCObject_DL()  (post a CObject to a Dart SendPort)
//   - Dart_InitializeApiDL() (initialize dynamic linking)
//
// The actual Dart SDK dart_api_dl.h is included at build time from the
// Dart SDK. This shim header provides the declarations needed for
// compilation without requiring the full Dart SDK headers at dev time.

#pragma once

#ifdef __cplusplus
extern "C" {
#endif

#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

// Dart port identifier.
typedef int64_t Dart_Port;

// Sentinel for invalid port.
#define ILLEGAL_PORT ((Dart_Port)0)

// Dart_CObject types.
typedef enum {
    Dart_CObject_kNull = 0,
    Dart_CObject_kBool,
    Dart_CObject_kInt32,
    Dart_CObject_kInt64,
    Dart_CObject_kDouble,
    Dart_CObject_kString,
    Dart_CObject_kArray,
    Dart_CObject_kTypedData,
    Dart_CObject_kExternalTypedData,
    Dart_CObject_kSendPort,
    Dart_CObject_kCapability,
    Dart_CObject_kNativePointer,
    Dart_CObject_kUnsupported,
    Dart_CObject_kNumberOfTypes,
} Dart_CObject_Type;

// Dart typed data types.
typedef enum {
    Dart_TypedData_kByteData = 0,
    Dart_TypedData_kInt8,
    Dart_TypedData_kUint8,
    Dart_TypedData_kUint8Clamped,
    Dart_TypedData_kInt16,
    Dart_TypedData_kUint16,
    Dart_TypedData_kInt32,
    Dart_TypedData_kUint32,
    Dart_TypedData_kInt64,
    Dart_TypedData_kUint64,
    Dart_TypedData_kFloat32,
    Dart_TypedData_kFloat64,
    Dart_TypedData_kFloat32x4,
    Dart_TypedData_kInvalid,
} Dart_TypedData_Type;

typedef void (*Dart_HandleFinalizer)(void* isolate_callback_data, void* peer);

// Forward declaration.
typedef struct _Dart_CObject Dart_CObject;

struct _Dart_CObject {
    Dart_CObject_Type type;
    union {
        bool as_bool;
        int32_t as_int32;
        int64_t as_int64;
        double as_double;
        const char* as_string;
        struct {
            intptr_t length;
            Dart_CObject** values;
        } as_array;
        struct {
            Dart_TypedData_Type type;
            intptr_t length;
            const uint8_t* values;
        } as_typed_data;
        struct {
            Dart_TypedData_Type type;
            intptr_t length;
            uint8_t* data;
            void* peer;
            Dart_HandleFinalizer callback;
        } as_external_typed_data;
        struct {
            Dart_Port id;
            Dart_Port origin_id;
        } as_send_port;
        struct {
            int64_t id;
        } as_capability;
        struct {
            void* ptr;
            intptr_t size;
            Dart_HandleFinalizer callback;
        } as_native_pointer;
    } value;
};

// Initialize the Dart API dynamic linking. Must be called once at startup
// with the NativeApi.initializeApiDLData pointer from Dart.
intptr_t Dart_InitializeApiDL(void* data);

// Post a CObject message to the given Dart SendPort.
// Returns true if the message was posted successfully.
bool Dart_PostCObject_DL(Dart_Port port_id, Dart_CObject* message);

// Post an integer to a Dart SendPort.
bool Dart_PostInteger_DL(Dart_Port port_id, int64_t message);

// Create a new native port.
Dart_Port Dart_NewNativePort_DL(const char* name,
                                 void (*handler)(Dart_Port, Dart_CObject*),
                                 bool handle_concurrently);

// Close a native port.
bool Dart_CloseNativePort_DL(Dart_Port native_port_id);

#ifdef __cplusplus
}
#endif
