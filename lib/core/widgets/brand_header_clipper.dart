import 'package:material_ui/material_ui.dart';

/// Edge shapes supported by branding; authentication uses concave corners.
enum BrandHeaderShape { concave, convex }

/// Corner cutouts leave the centre horizontal; this is not a wave.
class BrandHeaderClipper extends CustomClipper<Path> {
  const BrandHeaderClipper(
    this.radius, {
    this.shape = BrandHeaderShape.concave,
    this.morph,
  });
  final double radius;
  final BrandHeaderShape shape;
  final double? morph;
  @override
  Path getClip(Size size) {
    final r = radius.clamp(0.0, size.width / 2);
    final p = (morph ?? (shape == BrandHeaderShape.convex ? 1.0 : 0.0)).clamp(
      0.0,
      1.0,
    );
    final edge = size.height - r * p;
    final centre = size.height - r * (1 - p);
    return Path()
      ..lineTo(size.width, 0)
      ..lineTo(size.width, edge)
      ..quadraticBezierTo(size.width, centre, size.width - r, centre)
      ..lineTo(r, centre)
      ..quadraticBezierTo(0, centre, 0, edge)
      ..close();
  }

  @override
  bool shouldReclip(BrandHeaderClipper old) =>
      old.radius != radius || old.shape != shape || old.morph != morph;
}
