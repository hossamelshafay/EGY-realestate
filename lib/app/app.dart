import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'di/injection.dart';
import 'localization/app_localization_config.dart';
import 'localization/locale_cubit.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_cubit.dart';
import 'theme/theme_reveal.dart';
import 'package:egy/features/authentication/presentation/cubit/session_cubit.dart';

/// One router and persistent device preferences span all authentication states.
class App extends StatefulWidget {
  const App({super.key, required this.prefs, this.router});
  final SharedPreferences prefs;
  final GoRouter? router;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && sl.isRegistered<SessionCubit>()) {
      unawaited(sl<SessionCubit>().refresh());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepositoryProvider.value(
    value: widget.prefs,
    child: MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LocaleCubit(widget.prefs)..loadSavedLocale()),
        BlocProvider(create: (_) => ThemeCubit(widget.prefs)),
      ],
      child: BlocBuilder<LocaleCubit, LocaleState>(
        builder: (context, locale) => BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, mode) => MaterialApp.router(
            title: 'EGY Development',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: mode.mode,
            themeAnimationDuration: Duration.zero,
            routerConfig: widget.router ?? appRouter,
            locale: locale.locale,
            localizationsDelegates: AppLocalizationConfig.delegates,
            supportedLocales: LocaleCubit.supportedLocales,
            builder: (context, child) => ThemeReveal(
              router: widget.router ?? appRouter,
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    ),
  );
}
