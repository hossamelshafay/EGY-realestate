import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:egy/app/localization/generated/app_localizations.dart';
import 'app_colors.dart';
import 'theme_cubit.dart';
import 'theme_reveal.dart';

/// Explicit Light/Dark controls, measured at the actual tapped button.
class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key, this.onNavy = false, this.compact = false});
  final bool onNavy;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (context.findAncestorWidgetOfExactType<BlocProvider<ThemeCubit>>() ==
        null) {
      return const SizedBox.shrink();
    }
    final l = AppLocalizations.of(context);
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        if (compact) {
          final dark = state.mode == ThemeMode.dark;
          return Builder(
            builder: (toggle) => IconButton(
              key: const Key('theme_toggle'),
              tooltip: dark ? l.themeLight : l.themeDark,
              color: onNavy
                  ? AppColors.white
                  : Theme.of(context).colorScheme.onSurface,
              icon: Icon(
                dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              ),
              onPressed: () => ThemeReveal.select(
                toggle,
                dark ? ThemeMode.light : ThemeMode.dark,
              ),
            ),
          );
        }
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final mode in [ThemeMode.light, ThemeMode.dark])
              Builder(
                builder: (toggle) => IconButton(
                  key: ValueKey('theme_${mode.name}'),
                  tooltip: mode == ThemeMode.dark ? l.themeDark : l.themeLight,
                  isSelected: state.mode == mode,
                  color: onNavy ? AppColors.white : null,
                  selectedIcon: Icon(
                    mode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
                    color: AppColors.primaryGold,
                  ),
                  icon: Icon(
                    mode == ThemeMode.dark
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                  ),
                  onPressed: () => ThemeReveal.select(toggle, mode),
                ),
              ),
          ],
        );
      },
    );
  }
}
