import 'package:material_ui/material_ui.dart';

/// Information settles after the image flight starts, using the route's clock.
class DetailsEntrance extends StatelessWidget {
  const DetailsEntrance({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final animation = ModalRoute.of(context)?.animation;
    if (animation == null || MediaQuery.disableAnimationsOf(context)) {
      return child;
    }
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final progress = const Interval(
          .3,
          1,
          curve: Curves.easeOutCubic,
        ).transform(animation.value);
        return Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - progress)),
            child: child,
          ),
        );
      },
    );
  }
}
