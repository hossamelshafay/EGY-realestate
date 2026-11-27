import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:egy/features/authentication/presentation/cubit/session_cubit.dart';

import 'route_names.dart';

/// Pure guard for unit testing and router configuration.
String? sessionRedirect(
  SessionState? session,
  String path, {
  bool isWeb = kIsWeb,
}) {
  if (path == RoutePaths.splash || path == RoutePaths.onboarding) {
    if (!isWeb) return null;
    return session?.user == null ? RoutePaths.login : RoutePaths.home;
  }
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
