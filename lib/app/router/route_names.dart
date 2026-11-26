/// Named route identifiers for the EGY DEVELOPMENT application.
///
/// Use these constants with [GoRouter.go], [GoRouter.push], and
/// [GoRouterState.name] to avoid magic strings scattered across the codebase.
abstract final class RouteNames {
  // ── Auth ────────────────────────────────────────────────────────────────────
  static const String splash = 'splash';
  static const String onboarding = 'onboarding';
  static const String login = 'login';
  static const String register = 'register';
  static const String forgotPassword = 'forgotPassword';

  // ── Main ────────────────────────────────────────────────────────────────────
  static const String home = 'home';

  // ── Features ────────────────────────────────────────────────────────────────
  static const String recommendations = 'recommendations';
  static const String recommendationResults = 'recommendationResults';
  static const String pricePrediction = 'pricePrediction';
  static const String pricePredictionResult = 'pricePredictionResult';
  static const String aiChat = 'aiChat';
  static const String favorites = 'favorites';
  static const String propertyCatalog = 'propertyCatalog';
  static const String propertyDetails = 'propertyDetails';

  // ── Settings ────────────────────────────────────────────────────────────────
  static const String settings = 'settings';
  static const String profile = 'profile';
  static const String changeAvatar = 'changeAvatar';
  static const String deleteAccount = 'deleteAccount';
  static const String editProfile = 'editProfile';
  static const String changeEmail = 'changeEmail';
  static const String changePassword = 'changePassword';
}

/// URL path segments for every route.
///
/// Paths are defined separately from names so that the URL structure can be
/// changed without touching call sites that reference [RouteNames].
abstract final class RoutePaths {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Authenticated shell
  static const String home = '/home';
  static const String recommendations = '/recommendations';
  static const String recommendationResults = '/recommendations/results';
  static const String pricePrediction = '/price-prediction';
  static const String pricePredictionResult = '/price-prediction/result';
  static const String aiChat = '/ai-chat';
  static const String favorites = '/favorites';
  static const String propertyCatalog = '/properties';
  static const String propertyDetails = '/properties/:id';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String changeAvatar = '/settings/avatar';
  static const String deleteAccount = '/settings/delete-account';
  static const String editProfile = '/settings/profile';
  static const String changeEmail = '/settings/change-email';
  static const String changePassword = '/settings/change-password';
}
