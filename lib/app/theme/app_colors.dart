import 'package:material_ui/material_ui.dart';

/// Semantic color tokens for EGY DEVELOPMENT.
///
/// Never use raw hex values in widget code — always reference a token here.
/// All values are derived from the approved design references in
/// `docs/design_references/`.
abstract final class AppColors {
  static const avatarSkinLight = Color(0xFFF2CBA8);
  static const avatarSkinMedium = Color(0xFFD4A078);
  static const avatarSkinDeep = Color(0xFF9C684C);
  static const avatarRose = Color(0xFF9B5967);
  static const avatarTeal = Color(0xFF397F82);
  static const darkCanvas = Color(0xFF101820);
  static const darkSurface = Color(0xFF18232E);
  static const darkInput = Color(0xFF22313F);
  static const darkOutline = Color(0xFF526170);
  static const darkText = Color(0xFFF0F2F5);
  static const darkMuted = Color(0xFFB9C4CE);
  static const Color transparent = Color(0x00000000);
  // ── Primary palette ────────────────────────────────────────────────────────
  static const Color primaryNavy = Color(0xFF031A2D);
  static const Color secondaryNavy = Color(0xFF06233E);
  static const Color primaryGold = Color(0xFFE5A11A);
  static const Color secondaryGold = Color(0xFFD4941A);
  static const Color white = Color(0xFFFFFFFF);
  static const Color splashSurface = Color(0xFFFAF6EE);
  static const Color welcomeSurface = Color(0xFFF5F5FC);
  static const Color onboardingSurface = Color(0xFFFAF3F1);
  static const Color onboardingGold = Color(0xFFD98700);
  static const Color onboardingNavy = Color(0xFF123D67);
  static const Color indicatorInactive = Color(0xFFC9C6C8);
  static const Color offWhite = Color(0xFFF7F8FA);

  // ── Text ───────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF031A2D);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // ── Semantic ───────────────────────────────────────────────────────────────
  static const Color destructiveRed = Color(0xFFDC2626);
  static const Color successGreen = Color(0xFF16A34A);
  static const Color infoBlue = Color(0xFF2563EB);

  // ── Surface ────────────────────────────────────────────────────────────────
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color inputFill = Color(0xFFF3F4F6);
  static const Color chipInactive = Color(0xFFE5E7EB);

  // ── Shimmer ────────────────────────────────────────────────────────────────
  static const Color shimmerBase = Color(0xFFE5E7EB);
  static const Color shimmerHighlight = Color(0xFFF3F4F6);

  // ── Gradients ──────────────────────────────────────────────────────────────

  /// Gold gradient — used on CTA buttons. Check design reference per screen
  /// before applying; not every primary action uses gold.
  static const LinearGradient goldGradient = LinearGradient(
    colors: [primaryGold, secondaryGold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Navy gradient — used on headers and the navigation drawer.
  static const LinearGradient navyGradient = LinearGradient(
    colors: [primaryNavy, secondaryNavy],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
