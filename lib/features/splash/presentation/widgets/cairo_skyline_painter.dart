import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:egy/app/theme/app_colors.dart';

import 'splash_sun_motion.dart';
import 'package:egy/app/router/screen_handoff.dart';

/// Paints the EGY Cairo skyline splash animation.
///
/// A single [clock] drives the entire 5-second sequence through these phases:
///
///   0 – 800 ms   : Ground-line fades in; ground mist appears.
///   0 – 1 600 ms : Pyramid construction — masonry courses appear; skyline
///                  rises; pyramids build from base to tip.
///   800 – 2 600 ms: Cairo skyline buildings descend in staggered sequence.
///  1 400 – 2 600 ms: Nile slides in from the right.
///  2 200 – 2 900 ms: Sun leads the logo along a curved right-to-left arc.
///  2 900 – 3 400 ms: Pyramids settle into the skyline.
///  3 200 – 3 700 ms: EGY logo cue (handled by SplashPage overlay).
///  3 700 – 4 100 ms: Sun and logo hold their final composition.
///  4 100 – 5 000 ms: Full scene fades out → SplashCubit.onAnimationComplete.
///
/// This is a pure [CustomPainter] — no dependency on the widget tree.
class CairoSkylinePainter extends CustomPainter {
  CairoSkylinePainter(
    this.clock,
    this.reduced, {
    this.handoff,
    this.dark = false,
  });
  final bool dark;
  Color get _navy => dark ? AppColors.darkMuted : navy;
  final ScreenHandoff? handoff;
  double _exit(int stage) =>
      reduced ? 0 : HandoffTiming.leave(handoff?.value ?? 0, stage);

  @override
  void addListener(VoidCallback listener) {
    clock.addListener(listener);
    handoff?.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    clock.removeListener(listener);
    handoff?.removeListener(listener);
  }

  final Animation<double> clock;
  final bool reduced;

  // ── Palette ────────────────────────────────────────────────────────────────
  static const navy = Color(0xff223c52);
  static const slate = Color(0xff758997);
  static const mist = Color(0xffb5c0bf);
  static const gold = Color(0xffc89e60);
  static const sand = Color(0xffdfc79f);
  static const ivory = Color(0xFFFAF6EE); // matches @color/egy_splash_bg

  // ── Layout constants ───────────────────────────────────────────────────────
  /// Y coordinate of the ground line in the 400-unit canvas.
  static const ground = 197.0;

  // ── Main paint ─────────────────────────────────────────────────────────────
  @override
  void paint(Canvas canvas, Size size) {
    // All timing is in milliseconds over a 5 000 ms timeline.
    final ms = clock.value * 5000;
    // Reduced-motion: jump to a fully settled, pre-exit frame.
    final t = reduced ? 3600.0 : ms;

    const alpha = 1.0;

    canvas.save();
    canvas.scale(size.width / 400);

    final ink = _Ink(canvas, alpha);

    // ── Ground mist / horizon line (0 – 800 ms) ───────────────────────────
    final groundIn = _ease(t, 0, 800);
    ink.oval(
      16,
      ground - 1,
      385,
      ground + 4,
      slate,
      .13 * groundIn * (1 - _exit(4)),
    );

    // ── Pyramids with construction animation (0 – 1 600 ms) ───────────────
    // Three pyramids, staggered:  right → middle → left (viewer-left = oldest).
    _buildPyramid(
      ink,
      canvas,
      t,
      ms,
      x: 73,
      apex: 116,
      width: 56,
      height: 35,
      buildStart: 80,
    );
    _buildPyramid(
      ink,
      canvas,
      t,
      ms,
      x: 18,
      apex: 77,
      width: 68,
      height: 45,
      buildStart: 240,
    );
    _buildPyramid(
      ink,
      canvas,
      t,
      ms,
      x: 47,
      apex: 99,
      width: 74,
      height: 52,
      buildStart: 440,
    );

    // ── Cairo skyline buildings (800 – 2 600 ms) ──────────────────────────
    _land(ink, t, 800, 174, _Shape.tower);
    _land(ink, t, 1050, 144, _Shape.terrace);
    _land(ink, t, 1250, 200, _Shape.apartments);
    _land(ink, t, 1430, 234, _Shape.mosque);
    _land(ink, t, 1620, 274, _Shape.arcade);
    _land(ink, t, 1820, 302, _Shape.apartments);

    // ── Sun (2 200 – 2 900 ms, fades from 3 700 ms) ───────────────────────
    final sunLight = _ease(t, 2200, 2500);
    if (sunLight > 0) {
      final center = SplashSunMotion.center(t);
      final ink = _Ink(canvas, 1 - _exit(3));
      final shrink = 1 - .12 * _exit(3);
      ink.disc(center, 20 * shrink, gold, .12 * sunLight);
      ink.disc(center, 13 * shrink, gold, .60 * sunLight);
    }

    final river = _ease(t, 1400, 2600);
    if (river > 0) {
      final ink = _Ink(canvas, 1 - _exit(2));
      canvas.save();
      canvas.translate(0, 8 * _exit(2));
      canvas.scale(1 - .03 * _exit(2));
      canvas.translate(140 * (1 - river), 0);
      final water = Path()
        ..moveTo(51, 208)
        ..cubicTo(108, 196, 190, 201, 259, 202)
        ..quadraticBezierTo(324, 205, 361, 201)
        ..cubicTo(337, 215, 257, 208, 208, 216)
        ..cubicTo(149, 225, 103, 212, 51, 208)
        ..close();
      ink.path(water, mist, .52 * river);
      ink.line(85, 207, 132, 207, ivory, 1.2, river);
      ink.line(169, 212, 210, 212, gold, 1, .6 * river);
      ink.line(273, 206, 307, 206, ivory, 1, river);
      canvas.restore();
    }

    canvas.restore();
  }

  // ── Pyramid construction ──────────────────────────────────────────────────

  /// Reveals staggered masonry courses, clipped to each pyramid silhouette.
  void _buildPyramid(
    _Ink baseInk,
    Canvas canvas,
    double t,
    double ms, {
    required double x,
    required double apex,
    required double width,
    required double height,
    required double buildStart,
  }) {
    final exit = _exit((buildStart / 200).round());
    final ink = _Ink(canvas, baseInk.alpha * (1 - exit));
    final progress = _phase(t, buildStart, buildStart + 1100);
    if (progress <= 0) return;
    final outline = Path()
      ..moveTo(x, ground)
      ..lineTo(apex, ground - height)
      ..lineTo(x + width, ground)
      ..close();
    canvas.save();
    canvas.translate(apex, ground);
    canvas.scale(1 - .06 * exit);
    canvas.translate(-apex, -ground);
    canvas.clipPath(outline);
    final rows = (height / 6).ceil();
    for (var row = 0; row < rows; row++) {
      final columns = (width / 9).ceil() + 1;
      for (var column = 0; column < columns; column++) {
        final order = (row + column / columns) / rows;
        final appear = ((progress - order * .85) / .15).clamp(0.0, 1.0);
        if (appear == 0) continue;
        final bx = x + column * 9 - (row.isOdd ? 4.5 : 0);
        final by = ground - (row + 1) * 6;
        ink.rect(
          bx,
          by + (1 - appear) * 3,
          8.6,
          5.6,
          bx > apex ? gold : sand,
          appear,
        );
      }
    }
    canvas.restore();
  }

  void _land(_Ink i, double t, double start, double x, _Shape shape) {
    final exit = _exit(((start - 800) / 300).round().clamp(0, 4));
    final p = _phase(t, start, start + 320);
    if (p <= 0) return;
    final fall = _ease(p, 0, .65);
    final settle = _phase(p, .65, 1);
    final pop = math.sin(math.pi * settle);
    i.c.save();
    i.c.translate(x, ground - (1 - fall) * 32);
    i.c.scale(
      (1 + .020 * pop) * (1 - .06 * exit),
      (1 + .028 * pop) * (1 - .06 * exit),
    );
    final item = _Ink(i.c, i.alpha * _ease(p, 0, .45) * (1 - exit));
    _architecture(item, shape);
    if (pop > 0) {
      item.oval(-12, -2, 12, 1, gold, .22 * pop);
    }
    i.c.restore();
    _dust(i, x, settle, 14);
  }

  void _architecture(_Ink i, _Shape shape) {
    switch (shape) {
      case _Shape.tower:
        final stem = Path()
          ..moveTo(-6, 0)
          ..quadraticBezierTo(-2, -40, -4, -72)
          ..lineTo(4, -72)
          ..quadraticBezierTo(2, -40, 6, 0)
          ..close();
        i.path(stem, navy);
        i.c.save();
        i.c.clipPath(stem);
        for (var y = -76.0; y < 8; y += 9) {
          i.line(-6, y, 6, y + 12, sand, .7);
          i.line(6, y, -6, y + 12, sand, .7);
        }
        i.c.restore();
        i.rect(-7, -78, 14, 7, navy);
        i.rect(-8, -77, 16, 2, gold);
        i.rect(-4, -81, 8, 3, slate);
        i.line(0, -81, 0, -94, _navy, 1.3);
      case _Shape.mosque:
        i.rect(-24, -15, 48, 15, navy);
        i.path(
          Path()
            ..moveTo(-15, -15)
            ..quadraticBezierTo(-15, -25, -6, -29)
            ..quadraticBezierTo(-2, -31, 0, -35)
            ..quadraticBezierTo(2, -31, 6, -29)
            ..quadraticBezierTo(15, -25, 15, -15)
            ..close(),
          _navy,
        );
        i.line(0, -34, 0, -40, gold, 1);
        for (final x in [-21.0, 21.0]) {
          i.rect(x - 1.6, -35, 3.2, 35, navy);
          i.rect(x - 2.8, -31, 5.6, 2, gold);
          i.path(
            Path()
              ..moveTo(x - 2, -35)
              ..lineTo(x, -44)
              ..lineTo(x + 2, -35)
              ..close(),
            _navy,
          );
        }
        for (final x in [-10.0, 0.0, 10.0]) {
          i.path(
            Path()
              ..moveTo(x - 2, 0)
              ..lineTo(x - 2, -6)
              ..quadraticBezierTo(x, -12, x + 2, -6)
              ..lineTo(x + 2, 0)
              ..close(),
            slate,
          );
        }
      case _Shape.terrace:
      case _Shape.apartments:
      case _Shape.arcade:
        final h = switch (shape) {
          _Shape.terrace => 18.0,
          _Shape.arcade => 24.0,
          _ => 34.0,
        };
        i.rect(-13, -h, 26, h, slate);
        i.rect(7, -h, 6, h, _navy, .45);
        i.rect(-10, -h - 3, 17, 3, mist);
        for (var y = -h + 5; y < -2; y += 7) {
          for (var x = -9.0; x < 6; x += 6) {
            i.rect(x, y, 2.5, 3, sand, .75);
          }
        }
    }
  }

  // ── Dust helper ──────────────────────────────────────────────────────────

  void _dust(_Ink i, double x, double p, double radius) {
    if (p <= 0 || p >= 1) return;
    final arc = math.sin(math.pi * p);
    for (var n = 0; n < 5; n++) {
      final side = n.isEven ? -1 : 1;
      final spread = radius * (.2 + .15 * n + .3 * p);
      i.disc(
        Offset(x + side * spread, ground - arc * (1.5 + n % 3)),
        .8 + .4 * arc,
        gold,
        arc * .30,
      );
    }
  }

  @override
  bool shouldRepaint(CairoSkylinePainter old) =>
      old.clock != clock ||
      old.reduced != reduced ||
      old.handoff != handoff ||
      old.dark != dark;
}

// ── Top-level interpolation helpers ──────────────────────────────────────────

double _phase(double ms, double start, double end) =>
    ((ms - start) / (end - start)).clamp(0.0, 1.0).toDouble();

double _ease(double ms, double start, double end) =>
    Curves.easeInOutCubic.transform(_phase(ms, start, end));

// ── Building shape enum ───────────────────────────────────────────────────────

enum _Shape { tower, terrace, mosque, apartments, arcade }

// ── Drawing helper ────────────────────────────────────────────────────────────

/// Applies per-call opacity on top of a global scene [alpha] so the entire
/// scene can fade without needing an offscreen layer.
class _Ink {
  _Ink(this.c, this.alpha);

  final Canvas c;
  final double alpha;
  final Paint brush = Paint();

  Paint fill(Color color, double opacity) =>
      brush..color = color.withAlpha((255 * alpha * opacity).round());

  void path(Path p, Color col, [double a = 1]) => c.drawPath(p, fill(col, a));

  void rect(
    double x,
    double y,
    double w,
    double h,
    Color col, [
    double a = 1,
  ]) => c.drawRect(Rect.fromLTWH(x, y, w, h), fill(col, a));

  void oval(
    double l,
    double t,
    double r,
    double b,
    Color col, [
    double a = 1,
  ]) => c.drawOval(Rect.fromLTRB(l, t, r, b), fill(col, a));

  void disc(Offset center, double r, Color col, [double a = 1]) =>
      c.drawCircle(center, r, fill(col, a));

  void line(
    double x,
    double y,
    double u,
    double v,
    Color col,
    double width, [
    double a = 1,
  ]) =>
      c.drawLine(Offset(x, y), Offset(u, v), fill(col, a)..strokeWidth = width);
}
