import 'package:material_ui/material_ui.dart';

import 'package:egy/app/theme/app_colors.dart';

/// Displays an accessible typing bubble while a response is pending.
class ChatTypingIndicator extends StatefulWidget {
  const ChatTypingIndicator({super.key, required this.label});
  final String label;

  @override
  State<ChatTypingIndicator> createState() => _ChatTypingIndicatorState();
}

class _ChatTypingIndicatorState extends State<ChatTypingIndicator>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      _controller.value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: widget.label,
    liveRegion: true,
    child: Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        key: const Key('chat_typing_indicator'),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (index) {
              final phase = (_controller.value - index / 3) % 1;
              final opacity = MediaQuery.disableAnimationsOf(context)
                  ? 1.0
                  : .35 + .65 * (1 - (phase * 2 - 1).abs());
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Opacity(
                  opacity: opacity,
                  child: const CircleAvatar(
                    radius: 4,
                    backgroundColor: AppColors.primaryGold,
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    ),
  );
}
