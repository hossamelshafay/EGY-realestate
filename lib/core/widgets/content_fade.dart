import 'package:material_ui/material_ui.dart';

/// Fades keyed content changes and keeps outgoing content non-interactive.
class ContentFade extends StatelessWidget {
  const ContentFade({
    super.key,
    required this.child,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 300),
      layoutBuilder: (current, previous) => Stack(
        alignment: alignment,
        children: [
          for (final outgoing in previous)
            ExcludeFocus(
              child: ExcludeSemantics(child: IgnorePointer(child: outgoing)),
            ),
          ?current,
        ],
      ),
      child: child,
    );
  }
}

/// Fades newly inserted content without restarting existing siblings.
class ContentFadeIn extends StatelessWidget {
  const ContentFadeIn({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 220),
      tween: Tween(begin: 0, end: 1),
      curve: Curves.easeOut,
      builder: (context, value, child) => Opacity(opacity: value, child: child),
      child: child,
    );
  }
}
