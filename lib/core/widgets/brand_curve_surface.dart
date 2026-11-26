import 'package:material_ui/material_ui.dart';
import 'brand_header_clipper.dart';
import 'curve_divider.dart';

/// Internal pages share the brand's exact quadratic geometry and 32px proportion.
class BrandCurveSurface extends StatelessWidget {
  const BrandCurveSurface({super.key, required this.child, this.clipKey});
  final Widget child;
  final Key? clipKey;

  @override
  Widget build(BuildContext context) => CurveDivider(
    clipper: const BrandHeaderClipper(32),
    child: ClipPath(
      key: clipKey,
      clipper: const BrandHeaderClipper(32),
      child: child,
    ),
  );
}
