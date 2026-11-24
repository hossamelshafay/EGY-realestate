import 'package:material_ui/material_ui.dart';

import 'package:egy/app/theme/app_colors.dart';

/// Home-only surfaces follow the active theme without changing global theme state.
abstract final class HomePalette {
  static bool dark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;
  static Color canvas(BuildContext context) => dark(context)
      ? Theme.of(context).scaffoldBackgroundColor
      : AppColors.offWhite;
  static Color surface(BuildContext context) =>
      dark(context) ? Theme.of(context).colorScheme.surface : AppColors.white;
  static Color fill(BuildContext context) => dark(context)
      ? Theme.of(context).colorScheme.surfaceContainerHighest
      : AppColors.inputFill;
  static Color ink(BuildContext context) => dark(context)
      ? Theme.of(context).colorScheme.onSurface
      : AppColors.textPrimary;
  static Color muted(BuildContext context) => dark(context)
      ? Theme.of(context).colorScheme.onSurfaceVariant
      : AppColors.textSecondary;
  static Color outline(BuildContext context) => dark(context)
      ? Theme.of(context).colorScheme.outlineVariant
      : AppColors.borderLight;
}
