part of 'home_featured_pages.dart';

class _FeaturedLayer extends StatelessWidget {
  const _FeaturedLayer({
    super.key,
    required this.property,
    required this.motion,
    required this.entrance,
    required this.sign,
    required this.travel,
    required this.inFront,
  });

  final PropertyListing property;
  final Animation<double> motion;
  final Animation<double> entrance;
  final double sign, travel;
  final bool inFront;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(end: 16),
    child: AnimatedBuilder(
      animation: motion,
      child: AnimatedBuilder(
        animation: entrance,
        child: RepaintBoundary(
          child: HomeFeaturedCard(property: property, inFront: inFront),
        ),
        builder: (context, child) => HomeBlurFade(
          progress:
              (inFront
                      ? const Interval(.42, .80, curve: Curves.easeOutCubic)
                      : const Interval(.62, 1, curve: Curves.easeOutCubic))
                  .transform(entrance.value),
          child: child!,
        ),
      ),
      builder: (context, child) {
        final progress = motion.value;
        final offset = inFront ? -travel * progress : 16 * (1 - progress);
        final layer = Transform.translate(
          offset: Offset(sign * offset, 0),
          child: Transform.scale(
            scaleY: inFront ? 1 : .94 + .06 * progress,
            child: child,
          ),
        );
        if (inFront) {
          return IgnorePointer(
            key: const Key('home_featured_front'),
            ignoring: progress > 0,
            child: layer,
          );
        }
        return ExcludeSemantics(
          child: ExcludeFocus(child: IgnorePointer(child: layer)),
        );
      },
    ),
  );
}
