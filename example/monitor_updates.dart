// example/monitor_updates.dart — watch for daemon UpdatesChanged signals.
// Runs indefinitely, printing when the daemon reports new updates are available.
// Useful for system tray indicators or background update checkers.

import 'dart:async';
import 'package:packagekit_dart/packagekit_dart.dart';

Future<void> main() async {
  final client = await PkClient.connect();
  print('Backend: ${client.properties?.backendName}');
  print('Monitoring for update notifications... (Ctrl+C to stop)\n');

  await for (final event in client.daemonEvents) {
    switch (event) {
      case PkUpdatesChangedEvent():
        print('[${DateTime.now()}] Updates changed - new updates available');
      case PkRepoListChangedEvent():
        print('[${DateTime.now()}] Repository list changed');
      case PkNetworkStateChangedEvent(:final state):
        print('[${DateTime.now()}] Network state changed: $state');
      case PkPropsEvent():
        break; // initial properties, ignore
    }
  }

  await client.close();
}
