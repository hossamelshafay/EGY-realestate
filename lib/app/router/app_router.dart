import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:egy/core/web/web_app_shell.dart';
import 'package:egy/features/authentication/web/pages/web_auth_page.dart';
import 'package:egy/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:egy/features/favorites/web/pages/web_favorites_page.dart';
import 'package:egy/features/home/web/pages/web_home_page.dart';
import 'package:egy/features/profile/web/pages/web_profile_page.dart';
import 'package:egy/features/profile/web/pages/web_settings_page.dart';
import 'package:egy/features/properties/web/pages/web_catalog_page.dart';
import 'package:egy/features/properties/web/pages/web_property_details_page.dart';
import 'package:egy/features/profile/presentation/pages/settings_page.dart';
import 'package:egy/features/profile/presentation/pages/profile_page.dart';
import 'package:egy/features/profile/presentation/pages/account_security_page.dart';
import 'package:egy/app/di/injection.dart';
import 'package:egy/features/authentication/presentation/cubit/session_cubit.dart';
import 'package:egy/core/widgets/session_page.dart';

import 'package:egy/features/home/presentation/widgets/drawer_scaffold.dart';
import 'package:egy/features/favorites/presentation/pages/favorites_page.dart';
import 'package:egy/features/properties/domain/entities/property_category.dart';
import 'package:egy/features/properties/presentation/pages/property_catalog_page.dart';
import 'package:egy/features/properties/presentation/pages/property_details_page.dart';
import 'package:egy/features/properties/presentation/widgets/property_hero.dart';

import 'package:egy/features/authentication/presentation/pages/auth_page.dart';
import 'package:egy/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:egy/features/splash/presentation/pages/splash_page.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'route_names.dart';
import 'app_motion.dart';
import 'screen_handoff.dart';
import 'session_redirect.dart';
import 'ai_destination.dart';

/// Application router.
///
/// Defines every named route and its path.
/// Authentication changes refresh the protected-route guard.
///
/// Auth and Home retain one session page so redirects cannot replace the logo.
/// Future feature destinations remain localized placeholders.
final GoRouter appRouter = createAppRouter(
  session: sl.isRegistered<SessionCubit>() ? sl<SessionCubit>() : null,
);

/// A factory keeps auth-stream routing independently testable.
GoRouter createAppRouter({
  SessionCubit? session,
  String initialLocation = RoutePaths.splash,
  bool isWeb = kIsWeb,
}) {
  final refresh = _SessionRefresh(session);
  final effectiveInitial =
      isWeb &&
          (initialLocation == RoutePaths.splash ||
              initialLocation == RoutePaths.onboarding)
      ? (session?.state.user == null ? RoutePaths.login : RoutePaths.home)
      : initialLocation;

  if (isWeb) {
    return GoRouter(
      refreshListenable: refresh,
      redirect: (context, state) =>
          sessionRedirect(session?.state, state.uri.path, isWeb: true),
      initialLocation: effectiveInitial,
      debugLogDiagnostics: false,
      routes: _webRoutes(session: session),
    );
  }

  return GoRouter(
    refreshListenable: refresh,
    redirect: (context, state) =>
        sessionRedirect(session?.state, state.uri.path, isWeb: false),
    initialLocation: effectiveInitial,
    debugLogDiagnostics: false,
    routes: [
      // ── Splash ────────────────────────────────────────────────────────────────
      GoRoute(
        name: RouteNames.splash,
        path: RoutePaths.splash,
        pageBuilder: (context, state) => AppMotion.page(
          context: context,
          key: state.pageKey,
          duration: AppMotion.splashOverlap,
          child: const SplashPageWrapper(),
        ),
      ),

      // ── Onboarding ────────────────────────────────────────────────────────────
      GoRoute(
        name: RouteNames.onboarding,
        path: RoutePaths.onboarding,
        pageBuilder: (context, state) {
          final handoff = state.extra is ScreenHandoff
              ? state.extra! as ScreenHandoff
              : null;
          return AppMotion.page(
            context: context,
            key: const ValueKey('onboarding'),
            child: HandoffScope(
              handoff: handoff,
              incoming: true,
              child: OnboardingPage(fromSplash: handoff != null),
            ),
          );
        },
      ),

      // ── Authentication ────────────────────────────────────────────────────────
      ShellRoute(
        pageBuilder: (context, state, child) => AppMotion.page(
          context: context,
          key: const ValueKey('session_shell'),
          child: DrawerScaffold(
            enabled: !{
              RoutePaths.login,
              RoutePaths.register,
              RoutePaths.forgotPassword,
            }.contains(state.uri.path),
            child: child,
          ),
        ),
        routes: [
          GoRoute(
            name: RouteNames.login,
            path: RoutePaths.login,
            pageBuilder: (context, state) => AppMotion.page(
              context: context,
              key: const ValueKey('auth_shell'),
              child: HandoffScope(
                handoff: state.extra is ScreenHandoff
                    ? state.extra! as ScreenHandoff
                    : null,
                incoming: true,
                child: const SessionPage(authMode: AuthPageMode.login),
              ),
            ),
          ),
          GoRoute(
            name: RouteNames.register,
            path: RoutePaths.register,
            pageBuilder: (context, state) => AppMotion.page(
              context: context,
              key: const ValueKey('auth_shell'),
              child: HandoffScope(
                handoff: state.extra is ScreenHandoff
                    ? state.extra! as ScreenHandoff
                    : null,
                incoming: true,
                child: const SessionPage(authMode: AuthPageMode.register),
              ),
            ),
          ),
          GoRoute(
            name: RouteNames.forgotPassword,
            path: RoutePaths.forgotPassword,
            pageBuilder: (context, state) => AppMotion.page(
              context: context,
              key: const ValueKey('auth_shell'),
              child: HandoffScope(
                handoff: state.extra is ScreenHandoff
                    ? state.extra! as ScreenHandoff
                    : null,
                incoming: true,
                child: const SessionPage(authMode: AuthPageMode.reset),
              ),
            ),
          ),

          // ── Main ──────────────────────────────────────────────────────────────────
          GoRoute(
            name: RouteNames.home,
            path: RoutePaths.home,
            pageBuilder: (context, state) => AppMotion.page(
              context: context,
              key: const ValueKey('auth_shell'),
              child: HandoffScope(
                handoff:
                    state.extra is ScreenHandoff &&
                        (state.extra! as ScreenHandoff).fromSplash &&
                        (state.extra! as ScreenHandoff).value < 1
                    ? state.extra! as ScreenHandoff
                    : null,
                incoming: true,
                child: const SessionPage(),
              ),
            ),
          ),

          // ── Features ──────────────────────────────────────────────────────────────
          _internalRoute(
            name: RouteNames.recommendations,
            path: RoutePaths.recommendations,
            builder: (context, _) => AiDestination.recommendations(),
          ),
          _internalRoute(
            name: RouteNames.recommendationResults,
            path: RoutePaths.recommendationResults,
            builder: (context, state) => AiDestination.recommendations(
              similarTo: int.tryParse(
                state.uri.queryParameters['similar'] ?? '',
              ),
            ),
          ),
          _internalRoute(
            name: RouteNames.pricePrediction,
            path: RoutePaths.pricePrediction,
            builder: (context, _) => AiDestination.prediction(),
          ),
          _internalRoute(
            name: RouteNames.pricePredictionResult,
            path: RoutePaths.pricePredictionResult,
            builder: (context, _) => AiDestination.prediction(),
          ),
          _internalRoute(
            name: RouteNames.aiChat,
            path: RoutePaths.aiChat,
            builder: (context, _) => AiDestination.chat(),
          ),
          _internalRoute(
            name: RouteNames.favorites,
            path: RoutePaths.favorites,
            builder: (context, _) => const FavoritesPage(),
          ),
          _internalRoute(
            name: RouteNames.propertyCatalog,
            path: RoutePaths.propertyCatalog,
            builder: (context, state) => PropertyCatalogPage(
              category:
                  PropertyCategory.fromCode(
                    state.uri.queryParameters['category'],
                  ) ??
                  PropertyCategory.residentialSale,
            ),
          ),
          _internalRoute(
            name: RouteNames.propertyDetails,
            path: RoutePaths.propertyDetails,
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
              final preview = state.extra;
              return PropertyDetailsPage(
                id: id,
                preview: preview is PropertyPreview && preview.property.id == id
                    ? preview
                    : null,
              );
            },
          ),

          // ── Settings ──────────────────────────────────────────────────────────────
          _internalRoute(
            name: RouteNames.profile,
            path: RoutePaths.profile,
            builder: (context, _) => const ProfilePage(),
          ),
          _internalRoute(
            name: RouteNames.changeAvatar,
            path: RoutePaths.changeAvatar,
            builder: (context, _) => const ProfilePage(edit: true),
          ),
          _internalRoute(
            name: RouteNames.deleteAccount,
            path: RoutePaths.deleteAccount,
            builder: (context, _) =>
                const AccountSecurityPage(action: AccountAction.delete),
          ),
          _internalRoute(
            name: RouteNames.settings,
            path: RoutePaths.settings,
            builder: (context, _) => const SettingsPage(),
          ),
          _internalRoute(
            name: RouteNames.editProfile,
            path: RoutePaths.editProfile,
            builder: (context, _) => const ProfilePage(edit: true),
          ),
          _internalRoute(
            name: RouteNames.changeEmail,
            path: RoutePaths.changeEmail,
            builder: (context, _) =>
                const AccountSecurityPage(action: AccountAction.email),
          ),
          _internalRoute(
            name: RouteNames.changePassword,
            path: RoutePaths.changePassword,
            builder: (context, _) =>
                const AccountSecurityPage(action: AccountAction.password),
          ),
        ],
      ),
    ],
  );
}

GoRoute _internalRoute({
  required String name,
  required String path,
  required GoRouterWidgetBuilder builder,
}) => GoRoute(
  name: name,
  path: path,
  pageBuilder: (context, state) => AppMotion.authenticatedPage(
    context: context,
    key: state.pageKey,
    child: builder(context, state),
  ),
);

List<RouteBase> _webRoutes({SessionCubit? session}) => [
  GoRoute(
    name: RouteNames.login,
    path: RoutePaths.login,
    pageBuilder: (context, state) => NoTransitionPage(
      key: state.pageKey,
      child: const WebAuthPage(mode: WebAuthMode.login),
    ),
  ),
  GoRoute(
    name: RouteNames.register,
    path: RoutePaths.register,
    pageBuilder: (context, state) => NoTransitionPage(
      key: state.pageKey,
      child: const WebAuthPage(mode: WebAuthMode.register),
    ),
  ),
  GoRoute(
    name: RouteNames.forgotPassword,
    path: RoutePaths.forgotPassword,
    pageBuilder: (context, state) => NoTransitionPage(
      key: state.pageKey,
      child: const WebAuthPage(mode: WebAuthMode.forgotPassword),
    ),
  ),
  ShellRoute(
    builder: (context, state, child) {
      final effectiveSession =
          session ??
          (sl.isRegistered<SessionCubit>() ? sl<SessionCubit>() : null);
      final shell = WebAppShell(currentPath: state.uri.path, child: child);
      final providers = [
        if (effectiveSession != null)
          BlocProvider<SessionCubit>.value(value: effectiveSession),
        if (sl.isRegistered<FavoritesCubit>())
          BlocProvider<FavoritesCubit>.value(value: sl<FavoritesCubit>()),
      ];
      if (providers.isEmpty) return shell;
      return MultiBlocProvider(providers: providers, child: shell);
    },
    routes: [
      GoRoute(
        name: RouteNames.home,
        path: RoutePaths.home,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const WebHomePage(),
        ),
      ),
      GoRoute(
        name: RouteNames.recommendations,
        path: RoutePaths.recommendations,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: AiDestination.recommendations(
            isWeb: true,
            similarTo: int.tryParse(
              state.uri.queryParameters['similarTo'] ??
                  state.uri.queryParameters['similar'] ??
                  '',
            ),
          ),
        ),
      ),
      GoRoute(
        name: RouteNames.recommendationResults,
        path: RoutePaths.recommendationResults,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: AiDestination.recommendations(
            isWeb: true,
            similarTo: int.tryParse(
              state.uri.queryParameters['similarTo'] ??
                  state.uri.queryParameters['similar'] ??
                  '',
            ),
          ),
        ),
      ),
      GoRoute(
        name: RouteNames.pricePrediction,
        path: RoutePaths.pricePrediction,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: AiDestination.prediction(isWeb: true),
        ),
      ),
      GoRoute(
        name: RouteNames.pricePredictionResult,
        path: RoutePaths.pricePredictionResult,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: AiDestination.prediction(isWeb: true),
        ),
      ),
      GoRoute(
        name: RouteNames.aiChat,
        path: RoutePaths.aiChat,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: AiDestination.chat(isWeb: true),
        ),
      ),
      GoRoute(
        name: RouteNames.favorites,
        path: RoutePaths.favorites,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const WebFavoritesPage(),
        ),
      ),
      GoRoute(
        name: RouteNames.propertyCatalog,
        path: RoutePaths.propertyCatalog,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: WebCatalogPage(
            initialCategory:
                PropertyCategory.fromCode(
                  state.uri.queryParameters['category'],
                ) ??
                PropertyCategory.residentialSale,
          ),
        ),
      ),
      GoRoute(
        name: RouteNames.propertyDetails,
        path: RoutePaths.propertyDetails,
        pageBuilder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return NoTransitionPage(
            key: state.pageKey,
            child: WebPropertyDetailsPage(id: id),
          );
        },
      ),
      GoRoute(
        name: RouteNames.profile,
        path: RoutePaths.profile,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const WebProfilePage(),
        ),
      ),
      GoRoute(
        name: RouteNames.changeAvatar,
        path: RoutePaths.changeAvatar,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const WebProfilePage(),
        ),
      ),
      GoRoute(
        name: RouteNames.editProfile,
        path: RoutePaths.editProfile,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const WebProfilePage(),
        ),
      ),
      GoRoute(
        name: RouteNames.settings,
        path: RoutePaths.settings,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const WebSettingsPage(),
        ),
      ),
      GoRoute(
        name: RouteNames.changeEmail,
        path: RoutePaths.changeEmail,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const WebSettingsPage(),
        ),
      ),
      GoRoute(
        name: RouteNames.changePassword,
        path: RoutePaths.changePassword,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const WebSettingsPage(),
        ),
      ),
      GoRoute(
        name: RouteNames.deleteAccount,
        path: RoutePaths.deleteAccount,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const WebSettingsPage(),
        ),
      ),
    ],
  ),
];

// ── Shared placeholder ────────────────────────────────────────────────────────

/// Temporary placeholder rendered for all unimplemented routes.
///
/// REMOVE each instance as the corresponding real screen is introduced.
/// Do NOT use this widget outside of [appRouter].
class _SessionRefresh extends ChangeNotifier {
  _SessionRefresh(this._session);

  final SessionCubit? _session;
  StreamSubscription<SessionState>? _subscription;

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    if (_subscription != null) return;
    var previous = _session?.state;
    _subscription = _session?.stream.listen((state) {
      final changed =
          (state.user == null) != (previous?.user == null) ||
          state.authenticating != previous?.authenticating ||
          state.awaitingFeedback != previous?.awaitingFeedback;
      previous = state;
      if (changed) notifyListeners();
    });
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (hasListeners) return;
    unawaited(_subscription?.cancel());
    _subscription = null;
  }
}
