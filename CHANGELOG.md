## 0.3.2

- Point `repository` and `issue_tracker` at the jwinarske fork, fixing
  pub.dev repository verification.

## 0.3.1

- Add `WhatProvides` (native `pk_what_provides`, FFI binding, and
  `PkClient.whatProvides`) — resolve capabilities / provides / file paths
  (e.g. `pkg-config`, provided by `pkgconf-pkg-config`), matching `dnf`/`apt`
  install behavior. Mirrors the existing `Resolve` path.
- Add `setPackagekitLibraryPath()` to point the native-library loader at a
  prebuilt `libpackagekit_nc.so`, taking precedence over `PK_NC_LIB`. Useful
  for path/git dependencies that ship or build the `.so` outside the build
  hook.

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
