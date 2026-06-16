// library_loader.dart — DynamicLibrary.open() resolution.

import 'dart:ffi';
import 'dart:io';

import 'package:path/path.dart' as p;

/// Optional explicit path to `libpackagekit_nc.so`, set by
/// [setPackagekitLibraryPath]. Takes precedence over every other resolution
/// strategy. Must be set before the first `PkClient` use (the library handle
/// is loaded lazily on first access).
String? _overridePath;

/// Override the path used to load the native `libpackagekit_nc` library.
///
/// Useful for consumers that depend on `packagekit_dart` via a path/git
/// dependency: they can point the loader at a prebuilt `libpackagekit_nc.so`
/// without setting the `PK_NC_LIB` environment variable. No effect once the
/// library has already been loaded.
void setPackagekitLibraryPath(String path) => _overridePath = path;

DynamicLibrary loadPackagekitNc() {
  // 0. Explicit programmatic override.
  if (_overridePath != null && _overridePath!.isNotEmpty) {
    return DynamicLibrary.open(_overridePath!);
  }

  // 1. Environment variable override.
  final envPath = Platform.environment['PK_NC_LIB'];
  if (envPath != null && envPath.isNotEmpty) {
    return DynamicLibrary.open(envPath);
  }

  // 2. Search relative to the running executable.
  //    Covers standalone Dart, Flutter bundle, and various layouts.
  final exeDir = p.dirname(Platform.resolvedExecutable);
  final candidates = [
    p.join(exeDir, 'libpackagekit_nc.so'),
    p.join(exeDir, 'lib', 'libpackagekit_nc.so'),
    // Flutter Linux bundle: executable is in bundle/, lib is bundle/lib/.
    // In debug mode Platform.resolvedExecutable may resolve outside bundle/.
    p.join(exeDir, '..', 'bundle', 'lib', 'libpackagekit_nc.so'),
  ];

  for (final path in candidates) {
    if (File(path).existsSync()) {
      return DynamicLibrary.open(path);
    }
  }

  // 3. System library path fallback.
  return DynamicLibrary.open('libpackagekit_nc.so');
}
