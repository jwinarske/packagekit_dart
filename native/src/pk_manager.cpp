// pk_manager.cpp — PkManager implementation.
//
// Connects to the system bus, creates a proxy for org.freedesktop.PackageKit,
// subscribes to daemon signals, and runs the sdbus event loop on a dedicated
// thread. All signal handlers post to the Dart events port.

#include "pk_manager.h"

#include <cstring>
#include <utility>

#include "pk_transaction.h"

static constexpr const char* PK_SERVICE = "org.freedesktop.PackageKit";
static constexpr const char* PK_PATH = "/org/freedesktop/PackageKit";
static constexpr const char* PK_IFACE = "org.freedesktop.PackageKit";

// Manager event discriminators (not used for transaction signals).
static constexpr uint8_t kManagerProps = 0x0C;
static constexpr uint8_t kUpdatesChanged = 0xD0;
static constexpr uint8_t kRepoListChanged = 0xD1;
static constexpr uint8_t kNetworkStateChanged = 0xD2;

PkManager::PkManager(Dart_Port events_port) : events_port_(events_port) {
    conn_ = sdbus::createSystemBusConnection();

    manager_proxy_ =
        sdbus::createProxy(*conn_, sdbus::ServiceName{PK_SERVICE}, sdbus::ObjectPath{PK_PATH});

    registerManagerSignals();

    // Start the event loop on a dedicated thread.
    event_thread_ = std::thread([this]() { conn_->enterEventLoop(); });
}

PkManager::~PkManager() {
    if (conn_) {
        conn_->leaveEventLoop();
    }
    if (event_thread_.joinable()) {
        event_thread_.join();
    }
}

void PkManager::registerManagerSignals() {
    manager_proxy_->uponSignal("UpdatesChanged").onInterface(PK_IFACE).call([this]() {
        onUpdatesChanged();
    });

    manager_proxy_->uponSignal("RepoListChanged").onInterface(PK_IFACE).call([this]() {
        onRepoListChanged();
    });

    manager_proxy_->uponSignal("NetworkStateChanged")
        .onInterface(PK_IFACE)
        .call([this](const uint32_t& state) { onNetworkStateChanged(state); });

    manager_proxy_->uponSignal("TransactionListChanged")
        .onInterface(PK_IFACE)
        .call([this](const std::vector<std::string>& txs) { onTransactionListChanged(txs); });
}

void PkManager::readProperties() {
    PkManagerProps props{};

    props.backendName =
        manager_proxy_->getProperty("BackendName").onInterface(PK_IFACE).get<std::string>();
    props.backendDescription =
        manager_proxy_->getProperty("BackendDescription").onInterface(PK_IFACE).get<std::string>();
    props.backendAuthor =
        manager_proxy_->getProperty("BackendAuthor").onInterface(PK_IFACE).get<std::string>();
    props.roles = manager_proxy_->getProperty("Roles").onInterface(PK_IFACE).get<uint64_t>();
    props.filters = manager_proxy_->getProperty("Filters").onInterface(PK_IFACE).get<uint64_t>();
    props.groups = manager_proxy_->getProperty("Groups").onInterface(PK_IFACE).get<uint64_t>();
    props.mimeTypes = manager_proxy_->getProperty("MimeTypes")
                          .onInterface(PK_IFACE)
                          .get<std::vector<std::string>>();
    props.distroId =
        manager_proxy_->getProperty("DistroId").onInterface(PK_IFACE).get<std::string>();
    props.networkState =
        manager_proxy_->getProperty("NetworkState").onInterface(PK_IFACE).get<uint32_t>();
    props.locked = manager_proxy_->getProperty("Locked").onInterface(PK_IFACE).get<bool>();
    props.versionMajor =
        manager_proxy_->getProperty("VersionMajor").onInterface(PK_IFACE).get<uint32_t>();
    props.versionMinor =
        manager_proxy_->getProperty("VersionMinor").onInterface(PK_IFACE).get<uint32_t>();
    props.versionMicro =
        manager_proxy_->getProperty("VersionMicro").onInterface(PK_IFACE).get<uint32_t>();

    post(kManagerProps, props);
}

sdbus::ObjectPath PkManager::createTransaction() {
    sdbus::ObjectPath path;
    manager_proxy_->callMethod("CreateTransaction").onInterface(PK_IFACE).storeResultsTo(path);
    return path;
}

PkTransactionBridge* PkManager::createTransactionBridge(Dart_Port tx_port) {
    auto path = createTransaction();
    return new PkTransactionBridge(*conn_, std::move(path), tx_port);
}

// ── Signal handlers ──────────────────────────────────────────────────────────

void PkManager::onUpdatesChanged() {
    postEvent(kUpdatesChanged);
}

void PkManager::onRepoListChanged() {
    postEvent(kRepoListChanged);
}

void PkManager::onNetworkStateChanged(uint32_t state) {
    // Encode as a single-byte discriminator + uint32 payload.
    std::vector<uint8_t> buf;
    buf.push_back(kNetworkStateChanged);
    glz::detail::encode_field(buf, state);

    Dart_CObject obj;
    obj.type = Dart_CObject_kTypedData;
    obj.value.as_typed_data.type = Dart_TypedData_kUint8;
    obj.value.as_typed_data.length = static_cast<intptr_t>(buf.size());
    obj.value.as_typed_data.values = buf.data();
    Dart_PostCObject_DL(events_port_, &obj);
}

void PkManager::onTransactionListChanged(const std::vector<std::string>& /*txs*/) {
    // Transaction list changes are informational; not forwarded to Dart.
    // The Dart layer tracks transactions it created.
}

// ── Post helpers ─────────────────────────────────────────────────────────────

template <typename T>
void PkManager::post(uint8_t discriminator, const T& value) {
    auto payload = glz::encode(value);

    std::vector<uint8_t> buf;
    buf.reserve(1 + payload.size());
    buf.push_back(discriminator);
    buf.insert(buf.end(), payload.begin(), payload.end());

    Dart_CObject obj;
    obj.type = Dart_CObject_kTypedData;
    obj.value.as_typed_data.type = Dart_TypedData_kUint8;
    obj.value.as_typed_data.length = static_cast<intptr_t>(buf.size());
    obj.value.as_typed_data.values = buf.data();
    Dart_PostCObject_DL(events_port_, &obj);
}

void PkManager::postEvent(uint8_t event_byte) {
    Dart_CObject obj;
    obj.type = Dart_CObject_kTypedData;
    obj.value.as_typed_data.type = Dart_TypedData_kUint8;
    obj.value.as_typed_data.length = 1;
    obj.value.as_typed_data.values = &event_byte;
    Dart_PostCObject_DL(events_port_, &obj);
}

// Explicit template instantiation for PkManagerProps.
template void PkManager::post<PkManagerProps>(uint8_t, const PkManagerProps&);
