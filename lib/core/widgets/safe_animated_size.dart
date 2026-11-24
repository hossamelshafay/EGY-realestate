import 'package:flutter/widgets.dart';

/// Avoids zero-duration layout re-entry while preserving normal size animation.
class SafeAnimatedSize extends StatelessWidget {
  const SafeAnimatedSize({
    super.key,
    required this.duration,
    required this.child,
    this.curve = Curves.linear,
    this.alignment = Alignment.center,
  });
  final Duration duration;
  final Widget child;
  final Curve curve;
  final AlignmentGeometry alignment;
  @override
  Widget build(BuildContext context) => duration == Duration.zero
      ? child
      : AnimatedSize(
          duration: duration,
          curve: curve,
          alignment: alignment,
          child: child,
        );
}
