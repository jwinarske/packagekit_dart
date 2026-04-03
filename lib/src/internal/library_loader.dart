// library_loader.dart — DynamicLibrary.open() resolution.

import 'dart:ffi';
import 'dart:io';

import 'package:path/path.dart' as p;

DynamicLibrary loadPackagekitNc() {
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
