// Example: search for packages by name.
//
// Build the native library first:
//   cmake -B build native/ -GNinja -DCMAKE_BUILD_TYPE=Release
//   cmake --build build --parallel
//
// Run with:
//   PK_NC_LIB=$(pwd)/build/libpackagekit_nc.so dart run example/example.dart

import 'package:packagekit_dart/packagekit_dart.dart';

Future<void> main() async {
  final client = await PkClient.connect();
  print('Backend: ${client.properties?.backendName}');

  // Search for packages
  final tx = client.searchName('firefox');
  await for (final pkg in tx.packages) {
    final state = pkg.info == PkInfo.installed ? '[installed]' : '[available]';
    print('${pkg.id.name.padRight(40)} ${pkg.id.version.padRight(20)} $state');
  }
  await tx.result;

  await client.close();
}
