import 'package:material_ui/material_ui.dart';

/// Multicolour Google G, kept upright in both layout directions.
class GoogleLogo extends StatelessWidget {
  const GoogleLogo({super.key});

  @override
  Widget build(BuildContext context) => const ExcludeSemantics(
    child: SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GooglePainter()),
    ),
  );
}

// Brand artwork uses Google's own palette rather than application UI colours.
class _GooglePainter extends CustomPainter {
  const _GooglePainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    final blue = Path()
      ..moveTo(21.6, 12.23)
      ..cubicTo(21.6, 11.52, 21.54, 10.84, 21.42, 10.18)
      ..lineTo(12, 10.18)
      ..lineTo(12, 14.06)
      ..lineTo(17.38, 14.06)
      ..cubicTo(17.15, 15.31, 16.44, 16.37, 15.38, 17.08)
      ..lineTo(15.38, 19.6)
      ..lineTo(18.62, 19.6)
      ..cubicTo(20.51, 17.86, 21.6, 15.3, 21.6, 12.23)
      ..close();
    final green = Path()
      ..moveTo(12, 22)
      ..cubicTo(14.7, 22, 16.96, 21.1, 18.62, 19.6)
      ..lineTo(15.38, 17.08)
      ..cubicTo(14.48, 17.68, 13.33, 18.05, 12, 18.05)
      ..cubicTo(9.4, 18.05, 7.19, 16.29, 6.4, 13.93)
      ..lineTo(3.05, 13.93)
      ..lineTo(3.05, 16.52)
      ..cubicTo(4.7, 19.77, 8.08, 22, 12, 22)
      ..close();
    final yellow = Path()
      ..moveTo(6.4, 13.93)
      ..cubicTo(6.2, 13.33, 6.08, 12.68, 6.08, 12)
      ..cubicTo(6.08, 11.32, 6.2, 10.67, 6.4, 10.07)
      ..lineTo(6.4, 7.48)
      ..lineTo(3.05, 7.48)
      ..cubicTo(2.38, 8.84, 2, 10.37, 2, 12)
      ..cubicTo(2, 13.63, 2.38, 15.16, 3.05, 16.52)
      ..close();
    final red = Path()
      ..moveTo(12, 5.95)
      ..cubicTo(13.47, 5.95, 14.79, 6.46, 15.83, 7.46)
      ..lineTo(18.7, 4.59)
      ..cubicTo(16.96, 2.96, 14.7, 2, 12, 2)
      ..cubicTo(8.08, 2, 4.7, 4.23, 3.05, 7.48)
      ..lineTo(6.4, 10.07)
      ..cubicTo(7.19, 7.71, 9.4, 5.95, 12, 5.95)
      ..close();
    canvas.drawPath(blue, Paint()..color = const Color(0xFF4285F4));
    canvas.drawPath(green, Paint()..color = const Color(0xFF34A853));
    canvas.drawPath(yellow, Paint()..color = const Color(0xFFFBBC05));
    canvas.drawPath(red, Paint()..color = const Color(0xFFEA4335));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
