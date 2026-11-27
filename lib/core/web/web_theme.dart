import 'package:egy/app/theme/app_colors.dart';
import 'package:material_ui/material_ui.dart';

/// Semantic color tokens dedicated exclusively to the Flutter Web experience.
///
/// Mobile continues using [AppTheme.light] and [AppTheme.dark] untouched.
abstract final class WebPalette {
  // Light Mode
  static const Color lightBackground = Color(0xFFF5F7FA);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightInput = Color(0xFFEEF2F6);
  static const Color lightBorder = Color(0xFFCBD5E1);
  static const Color lightTextPrimary = Color(0xFF031A2D);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightHover = Color(0xFFE2E8F0);

  // Dark Mode
  static const Color darkBackground = Color(0xFF0D1722);
  static const Color darkCard = Color(0xFF172737);
  static const Color darkInput = Color(0xFF243648);
  static const Color darkBorder = Color(0xFF33485C);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFFB4C2D1);
  static const Color darkGold = Color(0xFFEAA81C);
  static const Color darkHover = Color(0xFF2B3F54);
}

/// Web-only [ThemeData] overrides with accessible Light and Dark contrast,
/// bounded desktop button sizing, and consistent surface hierarchy.
abstract final class WebTheme {
  static ThemeData light(ThemeData base) {
    final textTheme = _applyTextColors(
      base.textTheme,
      primary: WebPalette.lightTextPrimary,
      secondary: WebPalette.lightTextSecondary,
    );
    return base.copyWith(
      scaffoldBackgroundColor: WebPalette.lightBackground,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primaryNavy,
        onPrimary: Colors.white,
        secondary: AppColors.primaryGold,
        onSecondary: AppColors.primaryNavy,
        surface: WebPalette.lightCard,
        onSurface: WebPalette.lightTextPrimary,
        surfaceContainerHighest: WebPalette.lightInput,
        onSurfaceVariant: WebPalette.lightTextSecondary,
        outline: WebPalette.lightBorder,
        outlineVariant: WebPalette.lightBorder,
      ),
      textTheme: textTheme,
      cardColor: WebPalette.lightCard,
      dividerColor: WebPalette.lightBorder,
      dividerTheme: const DividerThemeData(
        color: WebPalette.lightBorder,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(
        color: WebPalette.lightTextSecondary,
        size: 22,
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: WebPalette.lightInput,
        hintStyle: const TextStyle(color: WebPalette.lightTextSecondary),
        labelStyle: const TextStyle(color: WebPalette.lightTextSecondary),
        prefixIconColor: WebPalette.lightTextSecondary,
        suffixIconColor: WebPalette.lightTextSecondary,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: WebPalette.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primaryNavy,
            width: 1.8,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryNavy,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: (base.elevatedButtonTheme.style ?? const ButtonStyle()).copyWith(
          minimumSize: const WidgetStatePropertyAll(Size(0, 44)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryNavy,
          minimumSize: const Size(0, 44),
          side: const BorderSide(color: WebPalette.lightBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryNavy,
          textStyle: textTheme.labelLarge?.copyWith(
            color: AppColors.primaryNavy,
          ),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: WebPalette.lightInput,
        selectedColor: AppColors.primaryNavy,
        labelStyle: const TextStyle(color: WebPalette.lightTextPrimary),
        secondaryLabelStyle: const TextStyle(color: Colors.white),
        side: const BorderSide(color: WebPalette.lightBorder),
      ),
    );
  }

  static ThemeData dark(ThemeData base) {
    final textTheme = _applyTextColors(
      base.textTheme,
      primary: WebPalette.darkTextPrimary,
      secondary: WebPalette.darkTextSecondary,
    );
    return base.copyWith(
      scaffoldBackgroundColor: WebPalette.darkBackground,
      colorScheme: base.colorScheme.copyWith(
        primary: WebPalette.darkGold,
        onPrimary: AppColors.primaryNavy,
        primaryContainer: WebPalette.darkInput,
        onPrimaryContainer: WebPalette.darkTextPrimary,
        secondary: WebPalette.darkGold,
        onSecondary: AppColors.primaryNavy,
        surface: WebPalette.darkCard,
        onSurface: WebPalette.darkTextPrimary,
        surfaceContainerHighest: WebPalette.darkInput,
        onSurfaceVariant: WebPalette.darkTextSecondary,
        outline: WebPalette.darkBorder,
        outlineVariant: WebPalette.darkBorder,
      ),
      textTheme: textTheme,
      cardColor: WebPalette.darkCard,
      dividerColor: WebPalette.darkBorder,
      dividerTheme: const DividerThemeData(
        color: WebPalette.darkBorder,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(
        color: WebPalette.darkTextSecondary,
        size: 22,
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: WebPalette.darkInput,
        hintStyle: const TextStyle(color: WebPalette.darkTextSecondary),
        labelStyle: const TextStyle(color: WebPalette.darkTextSecondary),
        prefixIconColor: WebPalette.darkTextSecondary,
        suffixIconColor: WebPalette.darkTextSecondary,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: WebPalette.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: WebPalette.darkGold,
            width: 1.8,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: WebPalette.darkGold,
          foregroundColor: AppColors.primaryNavy,
          minimumSize: const Size(0, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: (base.elevatedButtonTheme.style ?? const ButtonStyle()).copyWith(
          backgroundColor: const WidgetStatePropertyAll(WebPalette.darkGold),
          foregroundColor: const WidgetStatePropertyAll(AppColors.primaryNavy),
          minimumSize: const WidgetStatePropertyAll(Size(0, 44)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: WebPalette.darkTextPrimary,
          minimumSize: const Size(0, 44),
          side: const BorderSide(color: WebPalette.darkBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: WebPalette.darkGold,
          textStyle: textTheme.labelLarge?.copyWith(
            color: WebPalette.darkGold,
          ),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: WebPalette.darkInput,
        selectedColor: WebPalette.darkGold,
        labelStyle: const TextStyle(color: WebPalette.darkTextPrimary),
        secondaryLabelStyle: const TextStyle(color: AppColors.primaryNavy),
        side: const BorderSide(color: WebPalette.darkBorder),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: WebPalette.darkCard,
        surfaceTintColor: Colors.transparent,
        textStyle: textTheme.bodyMedium,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: WebPalette.darkCard,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
    );
  }

  static TextTheme _applyTextColors(
    TextTheme base, {
    required Color primary,
    required Color secondary,
  }) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(color: primary),
      headlineLarge: base.headlineLarge?.copyWith(color: primary),
      headlineMedium: base.headlineMedium?.copyWith(color: primary),
      headlineSmall: base.headlineSmall?.copyWith(color: primary),
      titleLarge: base.titleLarge?.copyWith(color: primary),
      titleMedium: base.titleMedium?.copyWith(color: primary),
      titleSmall: base.titleSmall?.copyWith(color: primary),
      bodyLarge: base.bodyLarge?.copyWith(color: primary),
      bodyMedium: base.bodyMedium?.copyWith(color: primary),
      bodySmall: base.bodySmall?.copyWith(color: secondary),
      labelLarge: base.labelLarge?.copyWith(color: primary),
      labelMedium: base.labelMedium?.copyWith(color: primary),
      labelSmall: base.labelSmall?.copyWith(color: secondary),
    );
  }
}
