/// Application theming configuration.
///
/// Provides complete theme setup for Material 3 with support
/// for light and dark themes, custom colors, and typography.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'colors.dart';
import 'typography.dart';

/// Theme mode provider.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

/// Main theme configuration class.
class AppTheme {
  AppTheme._();

  /// Light theme configuration.
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: AppColors.lightColorScheme,
      textTheme: AppTypography.textTheme,
      appBarTheme: _appBarTheme(Brightness.light),
      cardTheme: _cardTheme(Brightness.light),
      elevatedButtonTheme: _elevatedButtonTheme(Brightness.light),
      outlinedButtonTheme: _outlinedButtonTheme(Brightness.light),
      textButtonTheme: _textButtonTheme(Brightness.light),
      inputDecorationTheme: _inputDecorationTheme(Brightness.light),
      bottomNavigationBarTheme: _bottomNavTheme(Brightness.light),
      navigationBarTheme: _navigationBarTheme(Brightness.light),
      floatingActionButtonTheme: _fabTheme(Brightness.light),
      chipTheme: _chipTheme(Brightness.light),
      dialogTheme: _dialogTheme(Brightness.light),
      snackBarTheme: _snackBarTheme(Brightness.light),
      bottomSheetTheme: _bottomSheetTheme(Brightness.light),
      dividerTheme: _dividerTheme(Brightness.light),
      listTileTheme: _listTileTheme(Brightness.light),
      switchTheme: _switchTheme(Brightness.light),
      checkboxTheme: _checkboxTheme(Brightness.light),
      radioTheme: _radioTheme(Brightness.light),
      sliderTheme: _sliderTheme(Brightness.light),
      progressIndicatorTheme: _progressIndicatorTheme(Brightness.light),
      tabBarTheme: _tabBarTheme(Brightness.light),
      tooltipTheme: _tooltipTheme(Brightness.light),
      popupMenuTheme: _popupMenuTheme(Brightness.light),
      scaffoldBackgroundColor: AppColors.lightBackground,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      pageTransitionsTheme: _pageTransitionsTheme,
    );
  }

  /// Dark theme configuration.
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: AppColors.darkColorScheme,
      textTheme: AppTypography.textTheme,
      appBarTheme: _appBarTheme(Brightness.dark),
      cardTheme: _cardTheme(Brightness.dark),
      elevatedButtonTheme: _elevatedButtonTheme(Brightness.dark),
      outlinedButtonTheme: _outlinedButtonTheme(Brightness.dark),
      textButtonTheme: _textButtonTheme(Brightness.dark),
      inputDecorationTheme: _inputDecorationTheme(Brightness.dark),
      bottomNavigationBarTheme: _bottomNavTheme(Brightness.dark),
      navigationBarTheme: _navigationBarTheme(Brightness.dark),
      floatingActionButtonTheme: _fabTheme(Brightness.dark),
      chipTheme: _chipTheme(Brightness.dark),
      dialogTheme: _dialogTheme(Brightness.dark),
      snackBarTheme: _snackBarTheme(Brightness.dark),
      bottomSheetTheme: _bottomSheetTheme(Brightness.dark),
      dividerTheme: _dividerTheme(Brightness.dark),
      listTileTheme: _listTileTheme(Brightness.dark),
      switchTheme: _switchTheme(Brightness.dark),
      checkboxTheme: _checkboxTheme(Brightness.dark),
      radioTheme: _radioTheme(Brightness.dark),
      sliderTheme: _sliderTheme(Brightness.dark),
      progressIndicatorTheme: _progressIndicatorTheme(Brightness.dark),
      tabBarTheme: _tabBarTheme(Brightness.dark),
      tooltipTheme: _tooltipTheme(Brightness.dark),
      popupMenuTheme: _popupMenuTheme(Brightness.dark),
      scaffoldBackgroundColor: AppColors.darkBackground,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      pageTransitionsTheme: _pageTransitionsTheme,
    );
  }

  static AppBarTheme _appBarTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: true,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      foregroundColor: isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface,
      titleTextStyle: AppTypography.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  static CardTheme _cardTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark
              ? AppColors.darkOutline.withOpacity(0.2)
              : AppColors.lightOutline.withOpacity(0.2),
        ),
      ),
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme(Brightness brightness) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: AppTypography.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide(
          color: isDark ? AppColors.darkOutline : AppColors.lightOutline,
        ),
        textStyle: AppTypography.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static TextButtonThemeData _textButtonTheme(Brightness brightness) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: AppTypography.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static InputDecorationTheme _inputDecorationTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkOutline : AppColors.lightOutline;

    return InputDecorationTheme(
      filled: true,
      fillColor: isDark
          ? AppColors.darkSurfaceVariant.withOpacity(0.5)
          : AppColors.lightSurfaceVariant.withOpacity(0.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? AppColors.darkError : AppColors.lightError,
        ),
      ),
      hintStyle: AppTypography.textTheme.bodyLarge?.copyWith(
        color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant,
      ),
    );
  }

  static BottomNavigationBarThemeData _bottomNavTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      selectedItemColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
      unselectedItemColor: isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant,
      selectedLabelStyle: AppTypography.textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: AppTypography.textTheme.labelSmall,
    );
  }

  static NavigationBarThemeData _navigationBarTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return NavigationBarThemeData(
      elevation: 0,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      indicatorColor: isDark
          ? AppColors.darkPrimaryContainer
          : AppColors.lightPrimaryContainer,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppTypography.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
          );
        }
        return AppTypography.textTheme.labelSmall;
      }),
    );
  }

  static FloatingActionButtonThemeData _fabTheme(Brightness brightness) {
    return FloatingActionButtonThemeData(
      elevation: 2,
      highlightElevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  static ChipThemeData _chipTheme(Brightness brightness) {
    return ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  static DialogTheme _dialogTheme(Brightness brightness) {
    return DialogTheme(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    );
  }

  static SnackBarThemeData _snackBarTheme(Brightness brightness) {
    return SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  static BottomSheetThemeData _bottomSheetTheme(Brightness brightness) {
    return const BottomSheetThemeData(
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
  }

  static DividerThemeData _dividerTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return DividerThemeData(
      thickness: 1,
      space: 1,
      color: isDark
          ? AppColors.darkOutline.withOpacity(0.2)
          : AppColors.lightOutline.withOpacity(0.2),
    );
  }

  static ListTileThemeData _listTileTheme(Brightness brightness) {
    return ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  static SwitchThemeData _switchTheme(Brightness brightness) {
    return const SwitchThemeData();
  }

  static CheckboxThemeData _checkboxTheme(Brightness brightness) {
    return CheckboxThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  static RadioThemeData _radioTheme(Brightness brightness) {
    return const RadioThemeData();
  }

  static SliderThemeData _sliderTheme(Brightness brightness) {
    return const SliderThemeData(
      showValueIndicator: ShowValueIndicator.always,
    );
  }

  static ProgressIndicatorThemeData _progressIndicatorTheme(Brightness brightness) {
    return const ProgressIndicatorThemeData(
      linearTrackColor: Colors.transparent,
    );
  }

  static TabBarTheme _tabBarTheme(Brightness brightness) {
    return TabBarTheme(
      labelStyle: AppTypography.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: AppTypography.textTheme.labelLarge,
      indicatorSize: TabBarIndicatorSize.label,
    );
  }

  static TooltipThemeData _tooltipTheme(Brightness brightness) {
    return TooltipThemeData(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  static PopupMenuThemeData _popupMenuTheme(Brightness brightness) {
    return PopupMenuThemeData(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  static const _pageTransitionsTheme = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
    },
  );
}

/// Theme extension for custom properties.
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  /// Creates a new [AppThemeExtension].
  const AppThemeExtension({
    required this.success,
    required this.warning,
    required this.info,
  });

  /// Success color.
  final Color success;

  /// Warning color.
  final Color warning;

  /// Info color.
  final Color info;

  @override
  ThemeExtension<AppThemeExtension> copyWith({
    Color? success,
    Color? warning,
    Color? info,
  }) {
    return AppThemeExtension(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
    );
  }

  @override
  ThemeExtension<AppThemeExtension> lerp(
    covariant ThemeExtension<AppThemeExtension>? other,
    double t,
  ) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}
