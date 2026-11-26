import 'package:material_ui/material_ui.dart';
import 'package:egy/app/theme/app_colors.dart';

/// Draws only the existing bottom boundary; never outlines top or side edges.
class CurveDivider extends StatelessWidget {
  const CurveDivider({super.key, required this.clipper, required this.child});
  final CustomClipper<Path> clipper;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? CustomPaint(foregroundPainter: _DividerPainter(clipper), child: child)
      : child;
}

class _DividerPainter extends CustomPainter {
  _DividerPainter(this.clipper);
  final CustomClipper<Path> clipper;
  @override
  void paint(Canvas canvas, Size size) {
    final metrics = clipper.getClip(size).computeMetrics().iterator;
    if (!metrics.moveNext()) return;
    final metric = metrics.current;
    // Brand/auth paths trace top, right, bottom right-to-left, then close left.
    double? start;
    var end = metric.length;
    for (double offset = size.width; offset < metric.length; offset += .75) {
      final point = metric.getTangentForOffset(offset)!.position;
      if (start == null && point.dx < size.width - .01) start = offset - .75;
      if (start != null && point.dx <= .01) {
        end = offset;
        break;
      }
    }
    if (start == null) return;
    canvas.drawPath(
      metric.extractPath(start, end),
      Paint()
        ..color = AppColors.white.withValues(alpha: .8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(_DividerPainter old) => clipper != old.clipper;
}
