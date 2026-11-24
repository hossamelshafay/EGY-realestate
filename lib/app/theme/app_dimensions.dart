/// Spacing and sizing constants for EGY DEVELOPMENT.
///
/// Based on a 4 px grid. Use these tokens instead of raw numeric literals so
/// that layout changes propagate consistently across the app.
abstract final class AppDimensions {
  // ── Spacing ────────────────────────────────────────────────────────────────
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  // ── Border radius ──────────────────────────────────────────────────────────
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;

  /// Top-corner radius of the white content panel beneath the navy header.
  static const double radiusXl = 24;
  static const double radiusFull = 999;

  // ── Component sizes ────────────────────────────────────────────────────────
  static const double buttonHeight = 52;
  static const double textFieldHeight = 52;
  static const double cardElevation = 2;
  static const double propertyCardImageHeight = 180;
  static const double iconSizeSm = 20;
  static const double iconSizeMd = 24;
  static const double iconSizeLg = 32;
  static const double drawerWidth = 280;
  static const double headerMinHeight = 200;
}
