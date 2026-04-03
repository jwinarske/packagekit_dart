import 'package:flutter/material.dart';

import 'colors.dart';

class AppTheme {
  AppTheme._();

  static const _textTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 64),
    displayMedium: TextStyle(fontSize: 52),
    displaySmall: TextStyle(fontSize: 42),
    headlineLarge: TextStyle(fontSize: 38),
    headlineMedium: TextStyle(fontSize: 34),
    headlineSmall: TextStyle(fontSize: 30),
    titleLarge: TextStyle(fontSize: 28),
    titleMedium: TextStyle(fontSize: 24),
    titleSmall: TextStyle(fontSize: 20),
    bodyLarge: TextStyle(fontSize: 22),
    bodyMedium: TextStyle(fontSize: 20),
    bodySmall: TextStyle(fontSize: 18),
    labelLarge: TextStyle(fontSize: 20),
    labelMedium: TextStyle(fontSize: 18),
    labelSmall: TextStyle(fontSize: 16),
  );

  static const _noTransitions = PageTransitionsTheme(
    builders: {
      TargetPlatform.linux: _NoTransitionBuilder(),
      TargetPlatform.windows: _NoTransitionBuilder(),
      TargetPlatform.macOS: _NoTransitionBuilder(),
    },
  );

  static ThemeData light() => ThemeData(
    useMaterial3: true,
    colorSchemeSeed: AppColors.seed,
    brightness: Brightness.light,
    textTheme: _textTheme,
    pageTransitionsTheme: _noTransitions,
  );

  static ThemeData dark() => ThemeData(
    useMaterial3: true,
    colorSchemeSeed: AppColors.seed,
    brightness: Brightness.dark,
    textTheme: _textTheme,
    pageTransitionsTheme: _noTransitions,
  );
}

class _NoTransitionBuilder extends PageTransitionsBuilder {
  const _NoTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => child;
}
