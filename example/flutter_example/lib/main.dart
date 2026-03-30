import 'package:flutter/material.dart';
import 'package:packagekit_dart/packagekit_dart.dart';

import 'pages/daemon_info_page.dart';
import 'pages/search_page.dart';
import 'pages/installed_page.dart';
import 'pages/updates_page.dart';
import 'pages/repos_page.dart';
import 'pages/operations_page.dart';

void main() {
  runApp(const PackageKitExampleApp());
}

class PackageKitExampleApp extends StatelessWidget {
  const PackageKitExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PackageKit Example',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PkClient? _client;
  String? _error;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _connect();
  }

  Future<void> _connect() async {
    try {
      final client = await PkClient.connect();
      if (mounted) setState(() => _client = client);
    } on PkServiceUnavailableException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  @override
  void dispose() {
    _client?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('PackageKit Example')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Failed to connect to PackageKit',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    setState(() => _error = null);
                    _connect();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_client == null) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Connecting to PackageKit daemon...'),
            ],
          ),
        ),
      );
    }

    final pages = [
      DaemonInfoPage(client: _client!),
      SearchPage(client: _client!),
      InstalledPage(client: _client!),
      UpdatesPage(client: _client!),
      ReposPage(client: _client!),
      OperationsPage(client: _client!),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.info_outline), label: 'Daemon'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined), label: 'Installed'),
          NavigationDestination(icon: Icon(Icons.update), label: 'Updates'),
          NavigationDestination(
              icon: Icon(Icons.storage_outlined), label: 'Repos'),
          NavigationDestination(
              icon: Icon(Icons.build_outlined), label: 'Operations'),
        ],
      ),
    );
  }
}
