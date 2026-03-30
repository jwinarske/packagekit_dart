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
