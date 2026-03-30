// pk_bridge.cpp — C ABI entry points for Dart FFI.
// Wraps PkManager and PkTransactionBridge as opaque void* handles.

#include "pk_bridge.h"

#include <cstring>
#include <string>
#include <vector>

#include "pk_manager.h"
#include "pk_transaction.h"

// Helper: convert C string array to std::vector<std::string>.
static std::vector<std::string> to_vec(const char* const* arr, int n) {
    std::vector<std::string> v;
    v.reserve(n);
    for (int i = 0; i < n; ++i) {
        v.emplace_back(arr[i]);
    }
    return v;
}

static auto* mgr(void* h) {
    return static_cast<PkManager*>(h);
}
static auto* tx(void* h) {
    return static_cast<PkTransactionBridge*>(h);
}

// ── Init ─────────────────────────────────────────────────────────────────────

void pk_bridge_init(void* dart_api_dl_data) {
    Dart_InitializeApiDL(dart_api_dl_data);
}

// ── Manager ──────────────────────────────────────────────────────────────────

void* pk_manager_create(Dart_Port events_port) {
    return new PkManager(events_port);
}

void pk_manager_destroy(void* handle) {
    delete mgr(handle);
}

void pk_manager_read_properties(void* handle) {
    mgr(handle)->readProperties();
}

// ── Transaction ──────────────────────────────────────────────────────────────

void* pk_transaction_create(void* manager, Dart_Port tx_port) {
    return mgr(manager)->createTransactionBridge(tx_port);
}

void pk_transaction_destroy(void* handle) {
    delete tx(handle);
}

void pk_transaction_set_hints(void* handle, const char* locale) {
    tx(handle)->setHints(locale ? locale : "en_US.UTF-8");
}

// ── Query methods ────────────────────────────────────────────────────────────

void pk_search_name(void* handle, uint64_t filter, const char* const* values, int n_values) {
    tx(handle)->searchName(filter, to_vec(values, n_values));
}

void pk_search_details(void* handle, uint64_t filter, const char* const* values, int n_values) {
    tx(handle)->searchDetails(filter, to_vec(values, n_values));
}

void pk_search_files(void* handle, uint64_t filter, const char* const* values, int n_values) {
    tx(handle)->searchFiles(filter, to_vec(values, n_values));
}

void pk_search_groups(void* handle, uint64_t filter, const char* const* values, int n_values) {
    tx(handle)->searchGroups(filter, to_vec(values, n_values));
}

void pk_get_packages(void* handle, uint64_t filter) {
    tx(handle)->getPackages(filter);
}

void pk_get_updates(void* handle, uint64_t filter) {
    tx(handle)->getUpdates(filter);
}

void pk_resolve(void* handle, uint64_t filter, const char* const* ids, int n_ids) {
    tx(handle)->resolve(filter, to_vec(ids, n_ids));
}

void pk_get_details(void* handle, const char* const* ids, int n_ids) {
    tx(handle)->getDetails(to_vec(ids, n_ids));
}

void pk_get_update_detail(void* handle, const char* const* ids, int n_ids) {
    tx(handle)->getUpdateDetail(to_vec(ids, n_ids));
}

void pk_get_files(void* handle, const char* const* ids, int n_ids) {
    tx(handle)->getFiles(to_vec(ids, n_ids));
}

void pk_get_repo_list(void* handle, uint64_t filter) {
    tx(handle)->getRepoList(filter);
}

void pk_depends_on(void* handle, uint64_t filter, const char* const* ids, int n_ids,
                   bool recursive) {
    tx(handle)->dependsOn(filter, to_vec(ids, n_ids), recursive);
}

void pk_required_by(void* handle, uint64_t filter, const char* const* ids, int n_ids,
                    bool recursive) {
    tx(handle)->requiredBy(filter, to_vec(ids, n_ids), recursive);
}

void pk_get_distro_upgrades(void* handle) {
    tx(handle)->getDistroUpgrades();
}

void pk_get_old_transactions(void* handle, uint32_t number) {
    tx(handle)->getOldTransactions(number);
}

// ── Write methods ────────────────────────────────────────────────────────────

void pk_install_packages(void* handle, uint64_t flags, const char* const* ids, int n_ids) {
    tx(handle)->installPackages(flags, to_vec(ids, n_ids));
}

void pk_remove_packages(void* handle, uint64_t flags, const char* const* ids, int n_ids,
                        bool allow_deps, bool autoremove) {
    tx(handle)->removePackages(flags, to_vec(ids, n_ids), allow_deps, autoremove);
}

void pk_update_packages(void* handle, uint64_t flags, const char* const* ids, int n_ids) {
    tx(handle)->updatePackages(flags, to_vec(ids, n_ids));
}

void pk_refresh_cache(void* handle, bool force) {
    tx(handle)->refreshCache(force);
}

void pk_download_packages(void* handle, bool store_in_cache, const char* const* ids, int n_ids) {
    tx(handle)->downloadPackages(store_in_cache, to_vec(ids, n_ids));
}

void pk_install_files(void* handle, uint64_t flags, const char* const* paths, int n_paths) {
    tx(handle)->installFiles(flags, to_vec(paths, n_paths));
}

void pk_repo_enable(void* handle, const char* repo_id, bool enabled) {
    tx(handle)->repoEnable(repo_id, enabled);
}

void pk_accept_eula(void* handle, const char* eula_id) {
    tx(handle)->acceptEula(eula_id);
}

void pk_cancel(void* handle) {
    tx(handle)->cancel();
}
