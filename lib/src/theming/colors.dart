/// Application color definitions.
///
/// Defines the color palette for the application including
/// Material 3 color scheme and custom colors.
library;

import 'package:flutter/material.dart';

/// Application color palette.
class AppColors {
  AppColors._();

  // Brand colors
  /// Primary brand color.
  static const Color primary = Color(0xFF6366F1);

  /// Secondary brand color.
  static const Color secondary = Color(0xFF8B5CF6);

  /// Tertiary brand color.
  static const Color tertiary = Color(0xFFEC4899);

  // Light theme colors
  /// Light theme primary.
  static const Color lightPrimary = Color(0xFF6366F1);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightPrimaryContainer = Color(0xFFE0E7FF);
  static const Color lightOnPrimaryContainer = Color(0xFF1E1B4B);

  /// Light theme secondary.
  static const Color lightSecondary = Color(0xFF8B5CF6);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightSecondaryContainer = Color(0xFFEDE9FE);
  static const Color lightOnSecondaryContainer = Color(0xFF2E1065);

  /// Light theme tertiary.
  static const Color lightTertiary = Color(0xFFEC4899);
  static const Color lightOnTertiary = Color(0xFFFFFFFF);
  static const Color lightTertiaryContainer = Color(0xFFFCE7F3);
  static const Color lightOnTertiaryContainer = Color(0xFF831843);

  /// Light theme error.
  static const Color lightError = Color(0xFFDC2626);
  static const Color lightOnError = Color(0xFFFFFFFF);
  static const Color lightErrorContainer = Color(0xFFFEE2E2);
  static const Color lightOnErrorContainer = Color(0xFF7F1D1D);

  /// Light theme surfaces.
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightOnBackground = Color(0xFF1F2937);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightOnSurface = Color(0xFF1F2937);
  static const Color lightSurfaceVariant = Color(0xFFF3F4F6);
  static const Color lightOnSurfaceVariant = Color(0xFF6B7280);
  static const Color lightOutline = Color(0xFFD1D5DB);
  static const Color lightOutlineVariant = Color(0xFFE5E7EB);

  // Dark theme colors
  /// Dark theme primary.
  static const Color darkPrimary = Color(0xFF818CF8);
  static const Color darkOnPrimary = Color(0xFF1E1B4B);
  static const Color darkPrimaryContainer = Color(0xFF3730A3);
  static const Color darkOnPrimaryContainer = Color(0xFFE0E7FF);

  /// Dark theme secondary.
  static const Color darkSecondary = Color(0xFFA78BFA);
  static const Color darkOnSecondary = Color(0xFF2E1065);
  static const Color darkSecondaryContainer = Color(0xFF5B21B6);
  static const Color darkOnSecondaryContainer = Color(0xFFEDE9FE);

  /// Dark theme tertiary.
  static const Color darkTertiary = Color(0xFFF472B6);
  static const Color darkOnTertiary = Color(0xFF831843);
  static const Color darkTertiaryContainer = Color(0xFFBE185D);
  static const Color darkOnTertiaryContainer = Color(0xFFFCE7F3);

  /// Dark theme error.
  static const Color darkError = Color(0xFFF87171);
  static const Color darkOnError = Color(0xFF7F1D1D);
  static const Color darkErrorContainer = Color(0xFFB91C1C);
  static const Color darkOnErrorContainer = Color(0xFFFEE2E2);

  /// Dark theme surfaces.
  static const Color darkBackground = Color(0xFF111827);
  static const Color darkOnBackground = Color(0xFFF9FAFB);
  static const Color darkSurface = Color(0xFF1F2937);
  static const Color darkOnSurface = Color(0xFFF9FAFB);
  static const Color darkSurfaceVariant = Color(0xFF374151);
  static const Color darkOnSurfaceVariant = Color(0xFF9CA3AF);
  static const Color darkOutline = Color(0xFF4B5563);
  static const Color darkOutlineVariant = Color(0xFF374151);

  // Semantic colors
  /// Success color.
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color successDark = Color(0xFF16A34A);

  /// Warning color.
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFFD97706);

  /// Info color.
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color infoDark = Color(0xFF2563EB);

  // Neutral colors
  /// Gray scale.
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);

  // Light color scheme
  /// Light theme color scheme.
  static ColorScheme get lightColorScheme => const ColorScheme(
        brightness: Brightness.light,
        primary: lightPrimary,
        onPrimary: lightOnPrimary,
        primaryContainer: lightPrimaryContainer,
        onPrimaryContainer: lightOnPrimaryContainer,
        secondary: lightSecondary,
        onSecondary: lightOnSecondary,
        secondaryContainer: lightSecondaryContainer,
        onSecondaryContainer: lightOnSecondaryContainer,
        tertiary: lightTertiary,
        onTertiary: lightOnTertiary,
        tertiaryContainer: lightTertiaryContainer,
        onTertiaryContainer: lightOnTertiaryContainer,
        error: lightError,
        onError: lightOnError,
        errorContainer: lightErrorContainer,
        onErrorContainer: lightOnErrorContainer,
        surface: lightSurface,
        onSurface: lightOnSurface,
        surfaceContainerHighest: lightSurfaceVariant,
        onSurfaceVariant: lightOnSurfaceVariant,
        outline: lightOutline,
        outlineVariant: lightOutlineVariant,
      );

  // Dark color scheme
  /// Dark theme color scheme.
  static ColorScheme get darkColorScheme => const ColorScheme(
        brightness: Brightness.dark,
        primary: darkPrimary,
        onPrimary: darkOnPrimary,
        primaryContainer: darkPrimaryContainer,
        onPrimaryContainer: darkOnPrimaryContainer,
        secondary: darkSecondary,
        onSecondary: darkOnSecondary,
        secondaryContainer: darkSecondaryContainer,
        onSecondaryContainer: darkOnSecondaryContainer,
        tertiary: darkTertiary,
        onTertiary: darkOnTertiary,
        tertiaryContainer: darkTertiaryContainer,
        onTertiaryContainer: darkOnTertiaryContainer,
        error: darkError,
        onError: darkOnError,
        errorContainer: darkErrorContainer,
        onErrorContainer: darkOnErrorContainer,
        surface: darkSurface,
        onSurface: darkOnSurface,
        surfaceContainerHighest: darkSurfaceVariant,
        onSurfaceVariant: darkOnSurfaceVariant,
        outline: darkOutline,
        outlineVariant: darkOutlineVariant,
      );

  // Gradient presets
  /// Primary gradient.
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Secondary gradient.
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, tertiary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Tertiary gradient.
  static const LinearGradient tertiaryGradient = LinearGradient(
    colors: [tertiary, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
