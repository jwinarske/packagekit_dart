// pk_bridge.cpp — C ABI entry points for Dart FFI.
// Stub: full implementation in PR 6.

#include "pk_bridge.h"
#include "pk_manager.h"

void pk_bridge_init(void* dart_api_dl_data) {
    Dart_InitializeApiDL(dart_api_dl_data);
}

void* pk_manager_create(Dart_Port events_port) {
    return new PkManager(events_port);
}

void pk_manager_destroy(void* handle) {
    delete static_cast<PkManager*>(handle);
}

void pk_manager_read_properties(void* handle) {
    static_cast<PkManager*>(handle)->readProperties();
}

// Transaction stubs — full implementation in PR 5/6.
void* pk_transaction_create(void* /*manager*/, Dart_Port /*tx_port*/) {
    return nullptr;
}
void pk_transaction_destroy(void* /*handle*/) {}
void pk_transaction_set_hints(void* /*handle*/, const char* /*locale*/) {}

void pk_search_name(void* /*h*/, uint64_t /*f*/, const char* const* /*v*/, int /*n*/) {}
void pk_search_details(void* /*h*/, uint64_t /*f*/, const char* const* /*v*/, int /*n*/) {}
void pk_search_files(void* /*h*/, uint64_t /*f*/, const char* const* /*v*/, int /*n*/) {}
void pk_search_groups(void* /*h*/, uint64_t /*f*/, const char* const* /*v*/, int /*n*/) {}
void pk_get_packages(void* /*h*/, uint64_t /*f*/) {}
void pk_get_updates(void* /*h*/, uint64_t /*f*/) {}
void pk_resolve(void* /*h*/, uint64_t /*f*/, const char* const* /*v*/, int /*n*/) {}
void pk_get_details(void* /*h*/, const char* const* /*v*/, int /*n*/) {}
void pk_get_update_detail(void* /*h*/, const char* const* /*v*/, int /*n*/) {}
void pk_get_files(void* /*h*/, const char* const* /*v*/, int /*n*/) {}
void pk_get_repo_list(void* /*h*/, uint64_t /*f*/) {}
void pk_depends_on(void* /*h*/, uint64_t /*f*/, const char* const* /*v*/, int /*n*/, bool /*r*/) {}
void pk_required_by(void* /*h*/, uint64_t /*f*/, const char* const* /*v*/, int /*n*/, bool /*r*/) {}
void pk_get_distro_upgrades(void* /*h*/) {}
void pk_get_old_transactions(void* /*h*/, uint32_t /*n*/) {}
void pk_install_packages(void* /*h*/, uint64_t /*f*/, const char* const* /*v*/, int /*n*/) {}
void pk_remove_packages(void* /*h*/, uint64_t /*f*/, const char* const* /*v*/, int /*n*/,
                        bool /*d*/, bool /*a*/) {}
void pk_update_packages(void* /*h*/, uint64_t /*f*/, const char* const* /*v*/, int /*n*/) {}
void pk_refresh_cache(void* /*h*/, bool /*f*/) {}
void pk_download_packages(void* /*h*/, bool /*s*/, const char* const* /*v*/, int /*n*/) {}
void pk_install_files(void* /*h*/, uint64_t /*f*/, const char* const* /*v*/, int /*n*/) {}
void pk_repo_enable(void* /*h*/, const char* /*r*/, bool /*e*/) {}
void pk_accept_eula(void* /*h*/, const char* /*e*/) {}
void pk_cancel(void* /*h*/) {}
