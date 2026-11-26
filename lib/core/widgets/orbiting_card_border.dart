import 'dart:ui' show PathMetric;

import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

/// Paint-only perimeter accent. Scroll visibility and accessibility gate its clock.
class OrbitingCardBorder extends StatefulWidget {
  const OrbitingCardBorder({
    super.key,
    required this.child,
    required this.color,
    this.radius = 12,
    this.period = const Duration(seconds: 7),
  });
  final Widget child;
  final Color color;
  final double radius;
  final Duration period;

  @override
  State<OrbitingCardBorder> createState() => _OrbitingCardBorderState();
}

class _OrbitingCardBorderState extends State<OrbitingCardBorder>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final _clock = AnimationController(vsync: this, duration: widget.period);
  ScrollPosition? _position;
  bool _enabled = true;
  bool _foreground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _enabled =
        !MediaQuery.disableAnimationsOf(context) &&
        TickerMode.valuesOf(context).enabled;
    _position?.removeListener(_visibility);
    _position = Scrollable.maybeOf(context)?.position;
    _position?.addListener(_visibility);
    WidgetsBinding.instance.addPostFrameCallback((_) => _visibility());
  }

  @override
  void didUpdateWidget(OrbitingCardBorder oldWidget) {
    super.didUpdateWidget(oldWidget);
    _clock.duration = widget.period;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _visibility();
  }

  void _visibility() {
    if (!mounted) return;
    final box = context.findRenderObject();
    var visible = false;
    if (box is RenderBox && box.hasSize && box.attached) {
      final viewport = RenderAbstractViewport.maybeOf(box);
      final bounds = viewport is RenderBox
          ? MatrixUtils.transformRect(
              (viewport as RenderBox).getTransformTo(null),
              Offset.zero & (viewport as RenderBox).size,
            )
          : Offset.zero & MediaQuery.sizeOf(context);
      visible = MatrixUtils.transformRect(
        box.getTransformTo(null),
        Offset.zero & box.size,
      ).overlaps(bounds);
    }
    if (_enabled && _foreground && visible) {
      if (!_clock.isAnimating) _clock.repeat();
    } else {
      _clock.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _position?.removeListener(_visibility);
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: CustomPaint(
      foregroundPainter: OrbitingBorderPainter(
        progress: _clock,
        color: widget.color,
        radius: widget.radius,
      ),
      child: RepaintBoundary(child: widget.child),
    ),
  );
}

/// Samples arc length along the real rounded rectangle, including every corner.
class OrbitingBorderPainter extends CustomPainter {
  OrbitingBorderPainter({
    required this.progress,
    required this.color,
    required this.radius,
  }) : super(repaint: progress);
  final Animation<double> progress;
  final Color color;
  final double radius;
  Size? _size;
  PathMetric? _metric;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.shortestSide < 8) return;
    if (_size != size) {
      _size = size;
      _metric =
          (Path()..addRRect(
                RRect.fromRectAndRadius(
                  (Offset.zero & size).deflate(3),
                  Radius.circular((radius - 3).clamp(0, size.shortestSide / 2)),
                ),
              ))
              .computeMetrics()
              .first;
    }
    final metric = _metric!;
    final distance = progress.value * metric.length;
    final paint = Paint();
    for (var index = 12; index >= 0; index--) {
      final point = metric
          .getTangentForOffset((distance - index * 3) % metric.length)!
          .position;
      final strength = 1 - index / 13;
      paint.color = color.withValues(alpha: .22 * strength);
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(point, 3.5 * strength, paint);
      paint.maskFilter = null;
      paint.color = color.withValues(alpha: strength * .9);
      canvas.drawCircle(point, index == 0 ? 2 : 1.2 * strength, paint);
    }
  }

  @override
  bool shouldRepaint(OrbitingBorderPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.radius != radius ||
      oldDelegate.progress != progress;
}
