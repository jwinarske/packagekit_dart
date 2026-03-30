// pk_bridge.h — C ABI exported to Dart FFI.
//
// All handles are opaque void*.
// All results delivered via Dart_PostCObject_DL (kExternalTypedData).
//
// Message discriminator byte at offset 0 (see pk_types.h):
//   0x01 = PkPackage         0x02 = PkProgress    0x03 = PkDetails
//   0x04 = PkUpdateDetail    0x05 = PkRepoDetail  0x06 = PkFiles
//   0x07 = PkErrorCode       0x08 = PkMessage     0x09 = PkEulaRequired
//   0x0A = PkRepoSigRequired 0x0B = PkRequireRestart
//   0x0C = PkManagerProps    0x20 = Finished
//   0xFF = stream sentinel
//
// PackageKit handles polkit internally via packagekitd. No special
// privilege escalation is needed in the bridge code.

#pragma once
#include "dart_api_dl.h"
#include <stdbool.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

// Initialise Dart API dynamic linking. Call once at startup.
void pk_bridge_init(void* dart_api_dl_data);

// ── Manager ──────────────────────────────────────────────────────────────────
// events_port receives: 0x0C PkManagerProps on connect, then
//   UpdatesChanged / RepoListChanged / NetworkStateChanged daemon signals.
void* pk_manager_create(Dart_Port events_port);
void  pk_manager_destroy(void* handle);
void  pk_manager_read_properties(void* handle);

// ── Transaction ───────────────────────────────────────────────────────────────
// tx_port receives: discriminator-tagged glaze payloads for every signal
// the transaction emits, then 0x20 Finished and 0xFF sentinel.
// The bridge destroys itself after posting the sentinel (Destroy signal).
void* pk_transaction_create(void* manager, Dart_Port tx_port);
void  pk_transaction_destroy(void* handle);   // only needed on error paths

// Must call before any method. Sets locale, background, plural-signals hints.
void  pk_transaction_set_hints(void* handle, const char* locale);

// ── Query methods ─────────────────────────────────────────────────────────────
void pk_search_name(void* handle, uint64_t filter,
                    const char* const* values, int n_values);
void pk_search_details(void* handle, uint64_t filter,
                       const char* const* values, int n_values);
void pk_search_files(void* handle, uint64_t filter,
                     const char* const* values, int n_values);
void pk_search_groups(void* handle, uint64_t filter,
                      const char* const* values, int n_values);
void pk_get_packages(void* handle, uint64_t filter);
void pk_get_updates(void* handle, uint64_t filter);
void pk_resolve(void* handle, uint64_t filter,
                const char* const* ids, int n_ids);
void pk_get_details(void* handle, const char* const* ids, int n_ids);
void pk_get_update_detail(void* handle, const char* const* ids, int n_ids);
void pk_get_files(void* handle, const char* const* ids, int n_ids);
void pk_get_repo_list(void* handle, uint64_t filter);
void pk_depends_on(void* handle, uint64_t filter,
                   const char* const* ids, int n_ids, bool recursive);
void pk_required_by(void* handle, uint64_t filter,
                    const char* const* ids, int n_ids, bool recursive);
void pk_get_distro_upgrades(void* handle);
void pk_get_old_transactions(void* handle, uint32_t number);

// ── Write methods (polkit handled by packagekitd) ──────────────────────────
void pk_install_packages(void* handle, uint64_t flags,
                         const char* const* ids, int n_ids);
void pk_remove_packages(void* handle, uint64_t flags,
                        const char* const* ids, int n_ids,
                        bool allow_deps, bool autoremove);
void pk_update_packages(void* handle, uint64_t flags,
                        const char* const* ids, int n_ids);
void pk_refresh_cache(void* handle, bool force);
void pk_download_packages(void* handle, bool store_in_cache,
                          const char* const* ids, int n_ids);
void pk_install_files(void* handle, uint64_t flags,
                      const char* const* paths, int n_paths);
void pk_repo_enable(void* handle, const char* repo_id, bool enabled);
void pk_accept_eula(void* handle, const char* eula_id);
void pk_cancel(void* handle);

#ifdef __cplusplus
}
#endif
