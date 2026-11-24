import 'package:flutter/widgets.dart';

/// Shared coordinates keep the sun and fixed logo reveal in lockstep.
abstract final class SplashSunMotion {
  static Offset center(double ms) {
    final travel = Curves.easeInOutCubic.transform(
      ((ms - 2200) / 1300).clamp(0.0, 1.0),
    );
    final u = 1 - travel;
    return Offset(
      u * u * 440 + 2 * u * travel * 240 + travel * travel * 72,
      u * u * 145 - 2 * u * travel * 100 + travel * travel * 123,
    );
  }

  /// The leading edge crosses the fixed logo spanning x=88 through x=312.
  static double reveal(double ms) =>
      ((312 - (center(ms).dx - 13)) / 224).clamp(0.0, 1.0);
}

/// Clips right to left without moving or resizing the official logo image.
class SunLogoClipper extends CustomClipper<Rect> {
  const SunLogoClipper(this.progress);
  final double progress;
  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(size.width * (1 - progress), 0, size.width, size.height);
  @override
  bool shouldReclip(SunLogoClipper old) => old.progress != progress;
}
