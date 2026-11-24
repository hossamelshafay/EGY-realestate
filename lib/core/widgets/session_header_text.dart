import 'package:egy/core/widgets/safe_animated_size.dart';
import 'package:material_ui/material_ui.dart';

/// Preserves the existing Auth title/locale transition without replacing its logo.
class SessionHeaderText extends StatelessWidget {
  const SessionHeaderText({super.key, required this.text, required this.style});
  final String text;
  final TextStyle? style;
  @override
  Widget build(BuildContext context) {
    final duration = Duration(
      milliseconds: MediaQuery.disableAnimationsOf(context) ? 0 : 450,
    );
    return SafeAnimatedSize(
      duration: duration,
      curve: Curves.easeInOutCubic,
      child: AnimatedSwitcher(
        duration: duration,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0, .08),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
        child: Text(
          text,
          key: ValueKey(text),
          style: style,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
