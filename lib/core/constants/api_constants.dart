/// Backend API base URL and endpoint path constants.
///
/// The base URL is configured at build time via `--dart-define`:
///
/// ```
/// flutter run --dart-define=API_BASE_URL=https://your-backend.example.com
/// ```
///
/// A physical Android debug build can use explicit IPv4 loopback with
/// `adb reverse`. Otherwise use the host LAN IP, emulator host address, or
/// a deployed HTTPS URL as appropriate.
abstract final class ApiConstants {
  /// Explicit deployment/device address; an empty value disables API requests.
  static const String baseUrl = String.fromEnvironment('API_BASE_URL');

  // ── Endpoints ──────────────────────────────────────────────────────────────
  static const String health = '/api/health';
  static const String predict = '/api/predict';
  static const String predictOptions = '/api/predict/options';
  static const String chat = '/api/chat';
  static const String recommendationsSearch = '/api/recommendations/search';
  static const String recommendationsSimilar = '/api/recommendations/similar';
  static const String recommendationsById = '/api/recommendations';
  static const String recommendationsBatch = '/api/recommendations/batch';
  static const String catalogSample = '/api/recommendations/catalog/sample';
  static const String recommendationsFeatured =
      '/api/recommendations/featured/list';
}
