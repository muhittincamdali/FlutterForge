import 'package:flutter/material.dart';

/// The light and dark themes, both derived from one seed colour.
abstract final class AppTheme {
  static const Color seed = Color(0xFF0A84FF);

  static final ThemeData light = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: seed),
  );

  static final ThemeData dark = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    ),
  );
}
