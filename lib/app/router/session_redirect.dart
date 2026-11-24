import 'package:egy/features/authentication/presentation/cubit/session_cubit.dart';

import 'route_names.dart';

/// A sign-in operation owns its route until the repository operation completes.
String? sessionRedirect(SessionState? session, String path) {
  if (path == RoutePaths.splash || path == RoutePaths.onboarding) return null;
  final auth =
      path == RoutePaths.login ||
      path == RoutePaths.register ||
      path == RoutePaths.forgotPassword;
  if (session?.user == null) return auth ? null : RoutePaths.login;
  if (auth &&
      session?.authenticating != true &&
      session?.awaitingFeedback != true) {
    return RoutePaths.home;
  }
  return null;
}
