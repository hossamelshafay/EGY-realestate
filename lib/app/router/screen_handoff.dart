import 'package:flutter/widgets.dart';

/// Shared paint progress owned by the outgoing screen's animation clock.
class ScreenHandoff extends ValueNotifier<double> {
  ScreenHandoff({this.fromSplash = false}) : super(0);
  final bool fromSplash;
}

/// Each route identifies which side of the same handoff it paints.
class HandoffScope extends InheritedNotifier<ScreenHandoff> {
  const HandoffScope({
    super.key,
    required ScreenHandoff? handoff,
    required this.incoming,
    required super.child,
  }) : super(notifier: handoff);
  final bool incoming;

  static HandoffScope? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HandoffScope>();
}

/// Only the destination background blends; screen contents animate separately.
class HandoffSurface extends StatelessWidget {
  const HandoffSurface({super.key, required this.color, required this.child});
  final Color color;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final scope = HandoffScope.of(context);
    final t =
        !MediaQuery.disableAnimationsOf(context) &&
            scope != null &&
            scope.incoming
        ? scope.notifier?.value ?? 1.0
        : 1.0;
    final opacity = Interval(.05, .7, curve: Curves.easeInCubic).transform(t);
    return PopScope(
      canPop: t >= 1,
      child: IgnorePointer(
        ignoring: t < 1,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: Opacity(
                key: const Key('handoff_background'),
                opacity: opacity,
                child: ColoredBox(color: color),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

/// Common intervals used by both outgoing widgets and incoming content.
abstract final class HandoffTiming {
  static double enter(double t, double begin, double end) =>
      Interval(begin, end, curve: Curves.easeOutCubic).transform(t);
  static double leave(double t, int stage) => Interval(
    stage * .08,
    .34 + stage * .08,
    curve: Curves.easeInOutCubic,
  ).transform(t);
}
