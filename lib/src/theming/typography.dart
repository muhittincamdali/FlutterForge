/// Application typography configuration.
///
/// Defines the text styles and typography scale for the application
/// following Material 3 type system.
library;

import 'package:flutter/material.dart';

/// Application typography configuration.
class AppTypography {
  AppTypography._();

  /// The font family used throughout the app.
  static const String fontFamily = 'Inter';

  /// The fallback font families.
  static const List<String> fontFamilyFallback = [
    'Roboto',
    'Helvetica Neue',
    'Arial',
    'sans-serif',
  ];

  /// Main text theme for the application.
  static TextTheme get textTheme => const TextTheme(
        // Display styles
        displayLarge: TextStyle(
          fontFamily: fontFamily,
          fontFamilyFallback: fontFamilyFallback,
          fontSize: 57,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.25,
          height: 1.12,
        ),
        displayMedium: TextStyle(
          fontFamily: fontFamily,
          fontFamilyFallback: fontFamilyFallback,
          fontSize: 45,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.16,
        ),
        displaySmall: TextStyle(
          fontFamily: fontFamily,
          fontFamilyFallback: fontFamilyFallback,
          fontSize: 36,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.22,
        ),

        // Headline styles
        headlineLarge: TextStyle(
          fontFamily: fontFamily,
          fontFamilyFallback: fontFamilyFallback,
          fontSize: 32,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.25,
        ),
        headlineMedium: TextStyle(
          fontFamily: fontFamily,
          fontFamilyFallback: fontFamilyFallback,
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.29,
        ),
        headlineSmall: TextStyle(
          fontFamily: fontFamily,
          fontFamilyFallback: fontFamilyFallback,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.33,
        ),

        // Title styles
        titleLarge: TextStyle(
          fontFamily: fontFamily,
          fontFamilyFallback: fontFamilyFallback,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.27,
        ),
        titleMedium: TextStyle(
          fontFamily: fontFamily,
          fontFamilyFallback: fontFamilyFallback,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
          height: 1.50,
        ),
        titleSmall: TextStyle(
          fontFamily: fontFamily,
          fontFamilyFallback: fontFamilyFallback,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          height: 1.43,
        ),

        // Body styles
        bodyLarge: TextStyle(
          fontFamily: fontFamily,
          fontFamilyFallback: fontFamilyFallback,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          height: 1.50,
        ),
        bodyMedium: TextStyle(
          fontFamily: fontFamily,
          fontFamilyFallback: fontFamilyFallback,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          height: 1.43,
        ),
        bodySmall: TextStyle(
          fontFamily: fontFamily,
          fontFamilyFallback: fontFamilyFallback,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          height: 1.33,
        ),

        // Label styles
        labelLarge: TextStyle(
          fontFamily: fontFamily,
          fontFamilyFallback: fontFamilyFallback,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.43,
        ),
        labelMedium: TextStyle(
          fontFamily: fontFamily,
          fontFamilyFallback: fontFamilyFallback,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.33,
        ),
        labelSmall: TextStyle(
          fontFamily: fontFamily,
          fontFamilyFallback: fontFamilyFallback,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.45,
        ),
      );

  /// Custom text styles for specific use cases.
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.6,
  );

  /// Button text style.
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.43,
  );

  /// Link text style.
  static const TextStyle link = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.25,
    height: 1.43,
    decoration: TextDecoration.underline,
  );

  /// Code/monospace text style.
  static const TextStyle code = TextStyle(
    fontFamily: 'JetBrains Mono',
    fontFamilyFallback: ['Fira Code', 'Consolas', 'monospace'],
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
  );

  /// Quote text style.
  static const TextStyle quote = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    letterSpacing: 0.5,
    height: 1.6,
  );
}

/// Extension methods for text style modifications.
extension TextStyleExtension on TextStyle {
  /// Makes the text style bold.
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);

  /// Makes the text style semi-bold.
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);

  /// Makes the text style medium weight.
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);

  /// Makes the text style italic.
  TextStyle get italic => copyWith(fontStyle: FontStyle.italic);

  /// Applies underline decoration.
  TextStyle get underline => copyWith(decoration: TextDecoration.underline);

  /// Applies line-through decoration.
  TextStyle get lineThrough => copyWith(decoration: TextDecoration.lineThrough);

  /// Sets a specific color.
  TextStyle withColor(Color color) => copyWith(color: color);

  /// Sets a specific font size.
  TextStyle withSize(double size) => copyWith(fontSize: size);

  /// Sets a specific letter spacing.
  TextStyle withLetterSpacing(double spacing) =>
      copyWith(letterSpacing: spacing);

  /// Sets a specific line height.
  TextStyle withHeight(double height) => copyWith(height: height);
}
