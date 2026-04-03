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
