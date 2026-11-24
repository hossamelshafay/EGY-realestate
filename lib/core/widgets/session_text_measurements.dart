import 'package:flutter/widgets.dart';

/// Bounded cache avoids laying out unchanged localized text on animation ticks.
class SessionTextMeasurements {
  final _heights = <Object, double>{};
  double height(
    BuildContext context,
    String text,
    TextStyle? style,
    double width, {
    int? maxLines,
  }) {
    final direction = Directionality.of(context);
    final scaler = MediaQuery.textScalerOf(context);
    final key = (text, style, width, direction, scaler, maxLines);
    final cached = _heights[key];
    if (cached != null) return cached;
    if (_heights.length >= 32) _heights.clear();
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: direction,
      textScaler: scaler,
      maxLines: maxLines,
    )..layout(maxWidth: width);
    final height = painter.height;
    painter.dispose();
    _heights[key] = height;
    return height;
  }
}
