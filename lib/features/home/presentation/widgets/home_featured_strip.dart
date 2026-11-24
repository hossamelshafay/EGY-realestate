part of 'home_featured_pages.dart';

void _prefetchListings(BuildContext context) {
  final filters = context.read<HomeCubit>();
  unawaited(
    context.read<CatalogCubit>().prefetch(
      (item) => filters.state.matches(item),
    ),
  );
}

/// Presents an overlapping deck that retains its front card across prefetches.
class HomeFeaturedPages extends StatefulWidget {
  const HomeFeaturedPages({
    super.key,
    required this.catalog,
    required this.filters,
    required this.cardHeight,
  });

  final CatalogReady catalog;
  final HomeReady filters;
  final double cardHeight;

  @override
  State<HomeFeaturedPages> createState() => _HomeFeaturedPagesState();
}

bool _isOnScreen(BuildContext context, RenderBox? viewport) {
  final box = context.findRenderObject();
  if (box is! RenderBox ||
      !box.hasSize ||
      viewport == null ||
      !viewport.hasSize) {
    return true;
  }
  return (box.localToGlobal(Offset.zero) & box.size).overlaps(
    viewport.localToGlobal(Offset.zero) & viewport.size,
  );
}

class _FeaturedEmpty extends StatelessWidget {
  const _FeaturedEmpty({this.onRetry});
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l.noResultsFound, textAlign: TextAlign.center),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: Text(l.retryButton)),
        ],
      ),
    );
  }
}

class _FeaturedStrip extends StatelessWidget {
  const _FeaturedStrip({
    required this.front,
    required this.behind,
    required this.cardHeight,
    required this.motion,
    required this.direction,
    required this.progress,
    required this.onPointer,
    required this.onDrag,
    required this.onRelease,
    required this.onCancel,
    required this.onNext,
    required this.onPrevious,
  });

  final PropertyListing front;
  final PropertyListing? behind;
  final double cardHeight;
  final Animation<double> motion;
  final int direction;
  final ValueListenable<double> progress;
  final void Function(int pointer, bool down) onPointer;
  final ValueChanged<double> onDrag, onRelease;
  final VoidCallback onCancel;
  final VoidCallback? onNext, onPrevious;

  @override
  Widget build(BuildContext context) {
    final sign = Directionality.of(context) == TextDirection.ltr ? 1.0 : -1.0;
    final l = MaterialLocalizations.of(context);
    return Column(
      children: [
        SizedBox(
          key: const Key('home_featured_pages'),
          height: cardHeight,
          child: LayoutBuilder(
            builder: (context, bounds) {
              final width = bounds.maxWidth;
              return Semantics(
                customSemanticsActions: {
                  CustomSemanticsAction(label: l.nextPageTooltip): ?onNext,
                  CustomSemanticsAction(label: l.previousPageTooltip):
                      ?onPrevious,
                },
                child: Listener(
                  onPointerDown: (event) => onPointer(event.pointer, true),
                  onPointerUp: (event) => onPointer(event.pointer, false),
                  onPointerCancel: (event) => onPointer(event.pointer, false),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    dragStartBehavior: DragStartBehavior.down,
                    onHorizontalDragUpdate: (event) =>
                        onDrag(-sign * event.delta.dx / width),
                    onHorizontalDragEnd: (event) =>
                        onRelease(-sign * (event.primaryVelocity ?? 0)),
                    onHorizontalDragCancel: onCancel,
                    child: ClipRect(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (behind case final back?)
                            _FeaturedLayer(
                              key: ValueKey(back.id),
                              property: back,
                              motion: motion,
                              sign: sign,
                              travel: width,
                              inFront: false,
                            ),
                          _FeaturedLayer(
                            key: ValueKey(front.id),
                            property: front,
                            motion: motion,
                            sign: sign,
                            travel: width * direction,
                            inFront: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        if (!MediaQuery.disableAnimationsOf(context))
          ExcludeSemantics(child: _FeaturedProgress(progress)),
      ],
    );
  }
}

class _FeaturedLayer extends StatelessWidget {
  const _FeaturedLayer({
    super.key,
    required this.property,
    required this.motion,
    required this.sign,
    required this.travel,
    required this.inFront,
  });

  final PropertyListing property;
  final Animation<double> motion;
  final double sign, travel;
  final bool inFront;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(end: 16),
    child: AnimatedBuilder(
      animation: motion,
      child: RepaintBoundary(child: HomeFeaturedCard(property: property)),
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
