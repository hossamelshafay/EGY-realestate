import 'package:go_router/go_router.dart';
import 'localization/app_localization_config.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'localization/locale_cubit.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

/// Root application widget.
///
/// Receives [prefs] from [main] after [SharedPreferences.getInstance()] has
/// completed so that [LocaleCubit] can restore the saved locale immediately.
///
/// Provides:
/// - [MaterialApp.router] wired to [appRouter] (go_router).
/// - Light theme via [AppTheme.light]; dark stub provided but NOT activated.
/// - Flutter localizations for English and Arabic with RTL support.
/// - [LocaleCubit] for runtime locale switching and persistence.
class App extends StatelessWidget {
  const App({super.key, required this.prefs, this.router});

  final SharedPreferences prefs;
  final GoRouter? router;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<SharedPreferences>.value(
      value: prefs,
      child: BlocProvider<LocaleCubit>(
        create: (_) => LocaleCubit(prefs)..loadSavedLocale(),
        child: BlocBuilder<LocaleCubit, LocaleState>(
          builder: (context, localeState) {
            return MaterialApp.router(
              title: 'EGY Development',
              debugShowCheckedModeBanner: false,

              // ── Theme ────────────────────────────────────────────────────────
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              // Dark mode is architecturally supported but NOT activated.
              themeMode: ThemeMode.light,

              // ── Router ───────────────────────────────────────────────────────
              routerConfig: router ?? appRouter,

              // ── Localization ─────────────────────────────────────────────────
              locale: localeState.locale,
              localizationsDelegates: AppLocalizationConfig.delegates,
              supportedLocales: LocaleCubit.supportedLocales,
            );
          },
        ),
      ),
    );
  }
}
