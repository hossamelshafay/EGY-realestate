import 'dart:ui' show lerpDouble;
import 'package:material_ui/material_ui.dart';

/// Morphs the card's rounded rectangle into a continuous convex image edge.
class PropertyImageClipper extends CustomClipper<Path> {
  const PropertyImageClipper({required this.radius, required this.curve});
  final double radius;
  final double curve;

  @override
  Path getClip(Size size) {
    final r = radius.clamp(0.0, size.shortestSide / 2);
    final depth = size.height * .085 * curve;
    final bottom = size.height - depth;
    return Path()
      ..moveTo(r, 0)
      ..lineTo(size.width - r, 0)
      ..quadraticBezierTo(size.width, 0, size.width, r)
      ..lineTo(size.width, bottom - r)
      ..quadraticBezierTo(size.width, bottom, size.width - r, bottom)
      ..quadraticBezierTo(size.width / 2, size.height + depth, r, bottom)
      ..quadraticBezierTo(0, bottom, 0, bottom - r)
      ..lineTo(0, r)
      ..quadraticBezierTo(0, 0, r, 0)
      ..close();
  }

  static PropertyImageClipper lerp(
    PropertyImageClipper from,
    PropertyImageClipper to,
    double t,
  ) => PropertyImageClipper(
    radius: lerpDouble(from.radius, to.radius, t)!,
    curve: lerpDouble(from.curve, to.curve, t)!,
  );

  @override
  bool shouldReclip(PropertyImageClipper old) =>
      old.radius != radius || old.curve != curve;
}
