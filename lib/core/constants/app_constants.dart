/// App-wide non-API constants for EGY DEVELOPMENT.
abstract final class AppConstants {
  /// Minimum splash display duration in milliseconds.
  static const int splashDurationMs = 2000;

  /// SharedPreferences key: whether onboarding has been completed.
  static const String prefOnboardingDone = 'onboarding_done';

  /// SharedPreferences key: the user's preferred locale code ('en' or 'ar').
  static const String prefLocale = 'locale';

  /// Maximum number of chat session messages kept in memory.
  static const int chatMaxMessages = 200;

  /// Recommended property card count per page (for pagination when supported).
  static const int pageSize = 20;
}
