import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_text_styles.dart';

/// Application [ThemeData] definitions.
///
/// Light theme is the only currently approved mode.
/// A dark theme stub is provided architecturally but must NOT be activated
/// until the owner explicitly approves a dark mode implementation phase.
abstract final class AppTheme {
  // ── Light theme ────────────────────────────────────────────────────────────

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: _lightColorScheme,
    textTheme: AppTextStyles.textTheme,
    scaffoldBackgroundColor: AppColors.offWhite,
    appBarTheme: _appBarTheme,
    elevatedButtonTheme: _elevatedButtonTheme,
    outlinedButtonTheme: _outlinedButtonTheme,
    textButtonTheme: _textButtonTheme,
    inputDecorationTheme: _inputDecorationTheme,
    chipTheme: _chipTheme,
    cardTheme: _cardTheme,
    dividerTheme: const DividerThemeData(
      color: AppColors.borderLight,
      thickness: 1,
      space: 1,
    ),
    iconTheme: const IconThemeData(
      color: AppColors.textSecondary,
      size: AppDimensions.iconSizeMd,
    ),
  );

  // ── Dark theme stub ────────────────────────────────────────────────────────
  // DO NOT activate until a dark mode phase is explicitly approved.
  // This stub prevents runtime errors if dark mode is accidentally requested.
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryNavy,
      brightness: Brightness.dark,
    ),
  );

  // ── Color scheme ───────────────────────────────────────────────────────────

  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    // Primary — navy
    primary: AppColors.primaryNavy,
    onPrimary: AppColors.white,
    primaryContainer: AppColors.secondaryNavy,
    onPrimaryContainer: AppColors.white,
    // Secondary — gold
    secondary: AppColors.primaryGold,
    onSecondary: AppColors.white,
    secondaryContainer: AppColors.secondaryGold,
    onSecondaryContainer: AppColors.white,
    // Error — red
    error: AppColors.destructiveRed,
    onError: AppColors.white,
    errorContainer: Color(0xFFFEE2E2),
    onErrorContainer: AppColors.destructiveRed,
    // Surface
    surface: AppColors.white,
    onSurface: AppColors.textPrimary,
    surfaceContainerHighest: AppColors.offWhite,
    onSurfaceVariant: AppColors.textSecondary,
    // Outline
    outline: AppColors.borderLight,
    outlineVariant: AppColors.chipInactive,
  );

  // ── AppBar ─────────────────────────────────────────────────────────────────

  static const AppBarTheme _appBarTheme = AppBarTheme(
    backgroundColor: AppColors.primaryNavy,
    foregroundColor: AppColors.white,
    elevation: 0,
    centerTitle: false,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  // ── Buttons ────────────────────────────────────────────────────────────────

  static final ElevatedButtonThemeData _elevatedButtonTheme =
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGold,
          foregroundColor: AppColors.white,
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
          shape: const StadiumBorder(),
          textStyle: AppTextStyles.textTheme.labelLarge,
          elevation: 0,
        ),
      );

  static final OutlinedButtonThemeData _outlinedButtonTheme =
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryNavy,
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
          shape: const StadiumBorder(),
          side: const BorderSide(color: AppColors.primaryNavy),
          textStyle: AppTextStyles.textTheme.labelLarge?.copyWith(
            color: AppColors.primaryNavy,
          ),
        ),
      );

  static final TextButtonThemeData _textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.infoBlue,
      textStyle: AppTextStyles.textTheme.bodyMedium?.copyWith(
        color: AppColors.infoBlue,
        fontWeight: FontWeight.w500,
      ),
    ),
  );

  // ── Input fields ───────────────────────────────────────────────────────────

  static final InputDecorationTheme
  _inputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: AppColors.inputFill,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppDimensions.base,
      vertical: AppDimensions.md,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      borderSide: const BorderSide(color: AppColors.borderLight),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      borderSide: const BorderSide(color: AppColors.borderLight),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      borderSide: const BorderSide(color: AppColors.primaryNavy, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      borderSide: const BorderSide(color: AppColors.destructiveRed),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      borderSide: const BorderSide(color: AppColors.destructiveRed, width: 1.5),
    ),
    hintStyle: AppTextStyles.textTheme.bodyMedium?.copyWith(
      color: AppColors.textTertiary,
    ),
    errorStyle: AppTextStyles.textTheme.bodySmall?.copyWith(
      color: AppColors.destructiveRed,
    ),
  );

  // ── Chips ──────────────────────────────────────────────────────────────────

  static final ChipThemeData _chipTheme = ChipThemeData(
    backgroundColor: AppColors.chipInactive,
    selectedColor: AppColors.primaryGold,
    labelStyle: AppTextStyles.textTheme.labelMedium,
    side: BorderSide.none,
    shape: const StadiumBorder(),
    padding: const EdgeInsets.symmetric(
      horizontal: AppDimensions.sm,
      vertical: AppDimensions.xs,
    ),
  );

  // ── Cards ──────────────────────────────────────────────────────────────────

  static final CardThemeData _cardTheme = CardThemeData(
    color: AppColors.white,
    elevation: AppDimensions.cardElevation,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
    ),
    clipBehavior: Clip.antiAlias,
    margin: EdgeInsets.zero,
  );
}
