import 'package:material_ui/material_ui.dart';

import 'package:egy/features/properties/domain/entities/property_category.dart';

/// Flips the outgoing category and introduces the next along the same axis.
class HomeCategoryFlip extends StatefulWidget {
  const HomeCategoryFlip({
    super.key,
    required this.category,
    required this.child,
  });

  final PropertyCategory category;
  final Widget child;

  @override
  State<HomeCategoryFlip> createState() => _HomeCategoryFlipState();
}

class _HomeCategoryFlipState extends State<HomeCategoryFlip> {
  int _direction = 1;

  @override
  void didUpdateWidget(HomeCategoryFlip oldWidget) {
    super.didUpdateWidget(oldWidget);
    final difference = widget.category.index - oldWidget.category.index;
    if (difference != 0) _direction = difference.sign;
  }

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    final direction =
        _direction * (Directionality.of(context) == TextDirection.ltr ? 1 : -1);
    final categoryKey = ValueKey(widget.category);
    return AnimatedSwitcher(
      duration: reduced ? Duration.zero : const Duration(milliseconds: 360),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (current, previous) => Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.hardEdge,
        children: [
          if (!reduced && previous.isNotEmpty) previous.last,
          ?current,
        ],
      ),
      transitionBuilder: (child, animation) {
        final outgoing = child.key != categoryKey;
        final side = outgoing ? -direction : direction;
        return AnimatedBuilder(
          animation: animation,
          child: ExcludeSemantics(
            excluding: outgoing,
            child: ExcludeFocus(
              excluding: outgoing,
              child: IgnorePointer(
                ignoring: outgoing,
                child: HeroMode(enabled: !outgoing, child: child),
              ),
            ),
          ),
          builder: (context, child) {
            final t = reduced ? 1.0 : animation.value;
            return Opacity(
              opacity: t,
              child: FractionalTranslation(
                translation: Offset(side * (1 - t) * .12, 0),
                child: Transform(
                  alignment: side > 0
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, .001)
                    ..rotateY(-side * (1 - t) * .48),
                  child: child,
                ),
              ),
            );
          },
        );
      },
      child: KeyedSubtree(key: categoryKey, child: widget.child),
    );
  }
}
