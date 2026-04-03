import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    stderr.writeln('FlutterError: ${details.exception}');
  };
  runApp(const ProviderScope(child: PackageKitCatalogApp()));
}
