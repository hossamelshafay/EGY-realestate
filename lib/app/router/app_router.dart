import 'dart:async';
import 'package:egy/app/di/injection.dart';
import 'package:egy/features/authentication/presentation/cubit/session_cubit.dart';
import 'package:egy/core/widgets/session_page.dart';
import 'package:egy/core/widgets/authenticated_scaffold.dart';
import 'package:egy/features/home/presentation/widgets/drawer_scaffold.dart';
import 'package:egy/features/favorites/presentation/pages/favorites_page.dart';
import 'package:egy/features/properties/domain/entities/property_category.dart';
import 'package:egy/features/properties/presentation/pages/property_catalog_page.dart';
import 'package:egy/features/properties/presentation/pages/property_details_page.dart';
import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/features/authentication/presentation/pages/auth_page.dart';
import 'package:egy/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:egy/features/splash/presentation/pages/splash_page.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
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
}) {
  final refresh = _SessionRefresh(session);
  return GoRouter(
    refreshListenable: refresh,
    redirect: (context, state) =>
        sessionRedirect(session?.state, state.uri.path),
    initialLocation: initialLocation,
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
            builder: (context, state) => PropertyDetailsPage(
              id: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
            ),
          ),

          // ── Settings ──────────────────────────────────────────────────────────────
          _internalRoute(
            name: RouteNames.settings,
            path: RoutePaths.settings,
            builder: (context, _) => _PlaceholderScreen(
              title: AppLocalizations.of(context).settings,
            ),
          ),
          _internalRoute(
            name: RouteNames.editProfile,
            path: RoutePaths.editProfile,
            builder: (context, _) => _PlaceholderScreen(
              title: AppLocalizations.of(context).editProfile,
            ),
          ),
          _internalRoute(
            name: RouteNames.changeEmail,
            path: RoutePaths.changeEmail,
            builder: (context, _) => _PlaceholderScreen(
              title: AppLocalizations.of(context).changeEmail,
            ),
          ),
          _internalRoute(
            name: RouteNames.changePassword,
            path: RoutePaths.changePassword,
            builder: (context, _) => _PlaceholderScreen(
              title: AppLocalizations.of(context).changePassword,
            ),
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

// ── Shared placeholder ────────────────────────────────────────────────────────

/// Temporary placeholder rendered for all unimplemented routes.
///
/// REMOVE each instance as the corresponding real screen is introduced.
/// Do NOT use this widget outside of [appRouter].
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AuthenticatedScaffold(
      title: title,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.construction_rounded,
              size: 48,
              color: AppColors.primaryGold,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).homeFeaturePending,
              style: AppTextStyles.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

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
