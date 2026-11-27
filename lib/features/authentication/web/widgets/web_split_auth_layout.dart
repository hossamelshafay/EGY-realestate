import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/localization/locale_cubit.dart';
import 'package:egy/app/theme/app_colors.dart';
import 'package:egy/app/theme/theme_cubit.dart';
import 'package:egy/core/web/web_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// 50/50 Split-Screen desktop authentication layout for Flutter Web.
///
/// Left panel: solid `AppColors.primaryNavy` with centered `assets/img/logo.png`
/// (no curved headers or illustrations).
/// Right panel: clean surface with centered form constrained to 440px.
/// Collapses cleanly to a single column on narrow viewports (< 900px).
class WebSplitAuthLayout extends StatelessWidget {
  const WebSplitAuthLayout({
    super.key,
    required this.form,
  });

  final Widget form;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isSplit = width >= 900;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final rightBg = isDark ? WebPalette.darkBackground : WebPalette.lightCard;
    final webTheme = isDark ? WebTheme.dark(theme) : WebTheme.light(theme);

    if (!isSplit) {
      return Theme(
        data: webTheme,
        child: Scaffold(
          backgroundColor: rightBg,
          body: SafeArea(
            child: Column(
              children: [
                _CompactNavyHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 28,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: form,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Theme(
      data: webTheme,
      child: Scaffold(
        backgroundColor: rightBg,
        body: Row(
        children: [
          const Expanded(
            flex: 1,
            child: _NavyBrandPanel(),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: rightBg,
              child: Column(
                children: [
                  const _AuthTopControls(),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 24,
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: form,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _NavyBrandPanel extends StatelessWidget {
  const _NavyBrandPanel();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Container(
      color: AppColors.primaryNavy,
      padding: const EdgeInsets.all(48),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/img/logo.png',
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 28),
              Text(
                l10n.appName,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.welcomeTagline,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.78),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactNavyHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      color: AppColors.primaryNavy,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Image.asset(
            'assets/img/logo.png',
            width: 36,
            height: 36,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.appName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const _AuthTopControls(onDark: true),
        ],
      ),
    );
  }
}

class _AuthTopControls extends StatelessWidget {
  const _AuthTopControls({this.onDark = false});

  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeCubit = context.watch<ThemeCubit>();
    final localeCubit = context.watch<LocaleCubit>();
    final isDark = themeCubit.state.mode == ThemeMode.dark;
    final isArabic = localeCubit.state.locale.languageCode == 'ar';
    final fg = onDark ? Colors.white : Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: onDark
          ? EdgeInsets.zero
          : const EdgeInsets.only(top: 16, right: 20, left: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: onDark ? MainAxisSize.min : MainAxisSize.max,
        children: [
          IconButton(
            tooltip: isDark ? l10n.themeLight : l10n.themeDark,
            color: fg,
            onPressed: () =>
                themeCubit.select(isDark ? ThemeMode.light : ThemeMode.dark),
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
          ),
          TextButton(
            onPressed: () =>
                localeCubit.setLocale(Locale(isArabic ? 'en' : 'ar')),
            style: TextButton.styleFrom(foregroundColor: fg),
            child: Text(
              isArabic ? l10n.languageEnglish : l10n.languageArabic,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
