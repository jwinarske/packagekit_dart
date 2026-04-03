import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/shell.dart';
import 'theme/app_theme.dart';

class PackageKitCatalogApp extends ConsumerWidget {
  const PackageKitCatalogApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'PackageKit Catalog',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const AppShell(),
    );
  }
}
