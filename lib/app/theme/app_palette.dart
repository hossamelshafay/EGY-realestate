import 'package:material_ui/material_ui.dart';
import 'app_colors.dart';

/// Legacy light surfaces retain their colors while participating in app theming.
abstract final class AppPalette {
  static Color canvas(BuildContext context, Color light) =>
      Theme.of(context).brightness == Brightness.dark
      ? AppColors.darkCanvas
      : light;
}
