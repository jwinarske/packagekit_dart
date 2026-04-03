## 0.3.0

- Extract TransactionDispatcher and dispatchManagerEvent for testable
  message dispatch without a live daemon
- 102 unit tests covering all codec discriminators, model constructors,
  enum round-trips, dispatcher paths, and error handling
- ~98% coverage on testable Dart code (FFI glue excluded)
- Remove unused generated sdbus-cpp proxy headers and D-Bus XML interfaces
- Remove go_router; use index-based navigation for instant screen switching
- Fix CI: add libclang-rt-19-dev for ASAN, exclude test/ from clang-tidy,
  add dart pub get before format check, add flutter analyze step
- Lower Dart coverage threshold to 10% (FFI-heavy package)
- Add Flutter example screenshot to README
- Fix detail pane overlay on screen switch and package selection

## 0.2.0

- Native build hook (`hook/build.dart`) using `package:hooks` and
  `package:code_assets` — automatically compiles libpackagekit_nc.so via
  CMake at build time and bundles it as a CodeAsset
- Auto-clone sdbus-cpp at pinned commit when submodule is unavailable
  (pub.dev installs)
- Flutter example app (`example/packagekit_catalog/`) — Material 3 desktop
  catalog with Riverpod state management, GoRouter navigation, search,
  installed packages, updates, and repository views
- Codecov integration with 60% threshold enforcement
- Dart and C++ coverage collection in CI

## 0.1.0

- Initial release
- PkClient with async stream-based API for PackageKit D-Bus operations
- Query methods: searchName, searchDetails, searchFiles, resolve, getPackages,
  getUpdates, getDetails, getUpdateDetail, getFiles, getRepoList, dependsOn,
  requiredBy, getDistroUpgrades
- Write methods: installPackages, removePackages, updatePackages, refreshCache,
  downloadPackages, installFiles, repoEnable, acceptEula
- Simulate-first pattern: simulateInstall, simulateRemove, simulateUpdate
  returning PkInstallPlan with full dependency resolution
- Typed enums: PkFilter, PkTransactionFlag, PkInfo, PkStatus, PkExit, PkError
- Domain models: PkPackage, PkPackageDetail, PkUpdateDetail, PkRepoDetail,
  PkFiles, PkProgress, PkInstallPlan
- Daemon event monitoring: UpdatesChanged, RepoListChanged
- Native bridge using sdbus-cpp v2 with glaze binary encoding
- Supports APT, DNF, Zypper, and other PackageKit backends
