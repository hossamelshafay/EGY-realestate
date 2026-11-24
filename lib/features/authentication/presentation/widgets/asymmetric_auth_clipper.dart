import 'dart:ui' show lerpDouble;

import 'package:flutter/widgets.dart';

import 'auth_header.dart';

/// Cubic valley traced from slate_login_curve.png, mirrored for registration.
/// Home delegates to its existing clipper, preserving the approved endpoint.
class AsymmetricAuthClipper extends CustomClipper<Path> {
  const AsymmetricAuthClipper({
    required this.mirror,
    required this.fold,
    required this.expansion,
    required this.home,
    this.reset = 0,
  });
  final double mirror, fold, expansion, home, reset;
  static const _login = [
    Offset(0, .84),
    Offset(.12, .96),
    Offset(.23, 1),
    Offset(.36, 1),
    Offset(.58, 1),
    Offset(.82, .8),
    Offset(1, .32),
  ];
  static const _register = [
    Offset(0, .32),
    Offset(.18, .8),
    Offset(.42, 1),
    Offset(.64, 1),
    Offset(.77, 1),
    Offset(.88, .96),
    Offset(1, .84),
  ];

  /// Normalized boundary samples also make mirror symmetry testable.
  List<Offset> get points => List.generate(7, (i) {
    final p = Offset.lerp(_login[i], _register[i], mirror)!;
    final y = lerpDouble(p.dy, .94, fold)!;
    return Offset(p.dx, lerpDouble(y, 1, expansion)!);
  });

  @override
  Path getClip(Size size) {
    if (home >= 1) {
      return const BrandHeaderClipper(
        32,
        shape: BrandHeaderShape.convex,
      ).getClip(size);
    }
    final p = points
        .map((p) => Offset(p.dx * size.width, p.dy * size.height))
        .toList();
    if (home > 0) {
      // During success the cover stays full while its corners form Home's exact path.
      final r = 32 * home;
      return Path()
        ..lineTo(size.width, 0)
        ..lineTo(size.width, size.height - r)
        ..quadraticBezierTo(
          size.width,
          size.height,
          size.width - r,
          size.height,
        )
        ..lineTo(r, size.height)
        ..quadraticBezierTo(0, size.height, 0, size.height - r)
        ..close();
    }
    // De Casteljau subdivision preserves the exact approved asymmetric curve.
    final a = Offset.lerp(p[0], p[1], .5)!;
    final b = Offset.lerp(p[1], p[2], .5)!;
    final c = Offset.lerp(p[2], p[3], .5)!;
    final d = Offset.lerp(a, b, .5)!;
    final e = Offset.lerp(b, c, .5)!;
    final asymmetric = [
      p[0],
      a,
      d,
      Offset.lerp(d, e, .5)!,
      e,
      c,
      p[3],
      p[4],
      p[5],
      p[6],
    ];
    final w = size.width, h = size.height;
    final r = 32.0.clamp(0.0, size.shortestSide / 2);
    // The old Reset panel has symmetric inward cutouts (not Home's convex end).
    final symmetric = [
      Offset(0, h),
      Offset(0, h - 2 * r / 3),
      Offset(r / 3, h - r),
      Offset(r, h - r),
      Offset(r + (w - 2 * r) / 3, h - r),
      Offset(r + 2 * (w - 2 * r) / 3, h - r),
      Offset(w - r, h - r),
      Offset(w - r / 3, h - r),
      Offset(w, h - 2 * r / 3),
      Offset(w, h),
    ];
    final curve = List.generate(10, (i) {
      final y = lerpDouble(symmetric[i].dy, .94 * h, fold)!;
      return Offset.lerp(
        asymmetric[i],
        Offset(symmetric[i].dx, lerpDouble(y, h, expansion)!),
        reset,
      )!;
    });
    final path = Path()
      ..lineTo(w, 0)
      ..lineTo(curve[9].dx, curve[9].dy);
    for (var i = 9; i >= 3; i -= 3) {
      path.cubicTo(
        curve[i - 1].dx,
        curve[i - 1].dy,
        curve[i - 2].dx,
        curve[i - 2].dy,
        curve[i - 3].dx,
        curve[i - 3].dy,
      );
    }
    return path..close();
  }

  @override
  bool shouldReclip(AsymmetricAuthClipper old) =>
      old.mirror != mirror ||
      old.fold != fold ||
      old.expansion != expansion ||
      old.home != home ||
      old.reset != reset;
}
