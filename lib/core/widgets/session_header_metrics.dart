import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:material_ui/material_ui.dart';

import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/features/authentication/presentation/pages/auth_page_mode.dart';
import 'package:egy/features/authentication/presentation/widgets/auth_shell_motion.dart';

import 'session_text_measurements.dart';

/// Shared layout numbers keep body position attached to the single navy surface.
class SessionHeaderMetrics {
  SessionHeaderMetrics(
    BuildContext context,
    Size viewport,
    AuthShellMotion motion,
    String? name, {
    required SessionTextMeasurements measurements,
  }) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context).textTheme;
    top = MediaQuery.paddingOf(context).top;
    width = viewport.width;
    viewportHeight = viewport.height;
    home = Curves.easeInOutCubic.transform(motion.home.value);
    title = motion.visibleMode == AuthPageMode.register
        ? l.createAccount
        : motion.visibleMode == AuthPageMode.reset
        ? l.resetTitle
        : l.logIn;
    subtitle = motion.visibleMode == AuthPageMode.register
        ? l.authJoin
        : motion.visibleMode == AuthPageMode.reset
        ? l.authResetDescription
        : l.authWelcome;
    welcome = name == null || name.trim().isEmpty
        ? l.homeWelcome
        : l.homeWelcomeName(name.trim().split(' ').first);
    double measure(
      String text,
      TextStyle? style,
      double maxWidth, {
      int? maxLines,
    }) =>
        measurements.height(context, text, style, maxWidth, maxLines: maxLines);
    final authWidth = motion.visibleMode == AuthPageMode.reset
        ? width - 48
        : width * .64;

    final authHeight =
        top +
        148 -
        28 * motion.mirror +
        measure(title, theme.headlineLarge, authWidth) +
        measure(subtitle, theme.bodyMedium, authWidth);
    auth = lerpDouble(authHeight, top + 104, motion.fold)!;
    bannerTop =
        top +
        64 +
        math.max(
          48.0,
          measure(welcome, theme.headlineMedium, width - 136, maxLines: 2),
        ) +
        4 +
        measure(l.homeMember, theme.bodySmall, width - 48) +
        12;
    // Reserve measured text/robot extent, CTA pill, padding, and corner clearance.
    final bannerTextWidth = math.max(
      1.0,
      width - 32 - 30 - 56 - 10 - 2,
    );
    final bannerTextHeight =
        measure(
          l.homeAssistantTitle,
          theme.titleLarge?.copyWith(fontSize: 16),
          bannerTextWidth,
        ) +
        4 +
        measure(
          l.homeAssistantBannerDescription,
          theme.bodySmall?.copyWith(fontSize: 11.5),
          bannerTextWidth,
        );
    final ctaHeight =
        measure(
          l.homeAssistantCta,
          theme.labelMedium,
          bannerTextWidth,
          maxLines: 1,
        ) +
        14;
    bannerHeight = math.max(88.0, bannerTextHeight + ctaHeight + 8) + 26;
    final settledHome = bannerTop + bannerHeight + 24;
    height = lerpDouble(
      lerpDouble(auth, viewport.height, motion.cover.value),
      settledHome,
      home,
    )!;
    final side = lerpDouble(
      width * (.36 + .28 * motion.mirror),
      width / 2,
      motion.reset,
    )!;
    final centre = lerpDouble(
      lerpDouble(side, width / 2, motion.fold),
      width / 2,
      home,
    )!;
    final logoWidth = lerpDouble(lerpDouble(104, 88, motion.fold), 80, home)!;
    logo = Rect.fromLTWH(
      centre - logoWidth / 2,
      top +
          lerpDouble(
            lerpDouble(20 - 8 * motion.mirror, 12, motion.fold),
            12,
            home,
          )!,
      logoWidth,
      lerpDouble(
        lerpDouble(56 - 8 * motion.mirror, 44, motion.fold),
        44,
        home,
      )!,
    );
  }
  late final double top,
      width,
      home,
      auth,
      height,
      viewportHeight,
      bannerTop,
      bannerHeight;
  late final Rect logo;
  late final String title, subtitle, welcome;
}
