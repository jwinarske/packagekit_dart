// pk_manager.h
//
// PkManager wraps org.freedesktop.PackageKit on the system bus.
// Owns the sdbus connection and runs the event loop on a dedicated thread.
// All PkTransactionBridge instances share the same connection.

#pragma once
#include <sdbus-c++/sdbus-c++.h>

#include <atomic>
#include <memory>
#include <string>
#include <thread>

#include "dart_api_dl.h"
#include "pk_types.h"

class PkTransactionBridge;

class PkManager {
   public:
    // Connects to the system bus, starts the event loop thread.
    explicit PkManager(Dart_Port events_port);
    ~PkManager();

    PkManager(const PkManager&) = delete;
    PkManager& operator=(const PkManager&) = delete;

    // Read daemon properties and post as PkManagerProps (0x0C) to events_port.
    void readProperties();

    // Create a transaction and return its object path.
    sdbus::ObjectPath createTransaction();

    // Convenience: create + wrap in a PkTransactionBridge for Dart.
    PkTransactionBridge* createTransactionBridge(Dart_Port tx_port);

    sdbus::IConnection& connection() {
        return *conn_;
    }

   private:
    void registerManagerSignals();
    void onUpdatesChanged();
    void onRepoListChanged();
    void onNetworkStateChanged(uint32_t state);
    void onTransactionListChanged(const std::vector<std::string>& txs);

    // Post a glaze-encoded payload to Dart with the given discriminator.
    template <typename T>
    void post(uint8_t discriminator, const T& value);

    // Post a single-byte event (e.g. UpdatesChanged = 0xD0, RepoListChanged = 0xD1).
    void postEvent(uint8_t event_byte);

    std::unique_ptr<sdbus::IConnection> conn_;
    std::unique_ptr<sdbus::IProxy> manager_proxy_;
    std::thread event_thread_;
    Dart_Port events_port_;
};
