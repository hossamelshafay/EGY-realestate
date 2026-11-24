part of 'reveal_navigation.dart';

class _RevealSurface extends StatelessWidget {
  const _RevealSurface({
    required this.animation,
    required this.visible,
    required this.menu,
    required this.onDismiss,
    required this.onDrag,
    required this.onDragEnd,
    required this.onDragCancel,
    required this.child,
  });

  final Animation<double> animation;
  final bool visible;
  final Widget? menu;
  final VoidCallback onDismiss;
  final ValueChanged<double>? onDrag, onDragEnd;
  final VoidCallback? onDragCancel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final sign = Directionality.of(context) == TextDirection.ltr ? 1.0 : -1.0;
    final barrierLabel = MaterialLocalizations.of(
      context,
    ).modalBarrierDismissLabel;
    return LayoutBuilder(
      builder: (context, bounds) {
        final width = math.min(304.0, bounds.maxWidth * .77);
        return Stack(
          fit: StackFit.expand,
          children: [
            if (visible)
              GestureDetector(
                excludeFromSemantics: true,
                onTap: onDismiss,
                child: const DecoratedBox(
                  decoration: BoxDecoration(gradient: AppColors.navyGradient),
                ),
              ),
            if (visible && menu != null)
              PositionedDirectional(
                start: 0,
                top: 0,
                bottom: 0,
                width: width,
                child: FocusScope(child: menu!),
              ),
            AnimatedBuilder(
              key: const ValueKey('reveal_foreground'),
              animation: animation,
              child: ExcludeFocus(
                excluding: visible,
                child: ExcludeSemantics(
                  excluding: visible,
                  child: RepaintBoundary(child: child),
                ),
              ),
              builder: (context, child) {
                final progress = animation.value;
                return Transform.translate(
                  key: const ValueKey('reveal_offset'),
                  offset: Offset(sign * width * progress, 0),
                  child: Transform.scale(
                    scale: 1 - .055 * progress,
                    alignment: AlignmentDirectional.centerStart,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24 * progress),
                      clipBehavior: progress == 0 ? Clip.none : Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          child!,
                          if (visible)
                            GestureDetector(
                              excludeFromSemantics: true,
                              onHorizontalDragUpdate:
                                  onDrag == null || width == 0
                                  ? null
                                  : (details) => onDrag!(
                                      sign * details.delta.dx / width,
                                    ),
                              onHorizontalDragEnd: onDragEnd == null
                                  ? null
                                  : (details) => onDragEnd!(
                                      sign * (details.primaryVelocity ?? 0),
                                    ),
                              onHorizontalDragCancel: onDragCancel,
                              child: ModalBarrier(
                                key: const Key('reveal_dismiss'),
                                color: AppColors.primaryNavy.withValues(
                                  alpha: .16 * progress,
                                ),
                                onDismiss: onDismiss,
                                semanticsLabel: barrierLabel,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
