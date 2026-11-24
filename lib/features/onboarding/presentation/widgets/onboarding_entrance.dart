import 'package:material_ui/material_ui.dart';
import 'package:egy/app/router/app_motion.dart';
import 'package:egy/app/router/screen_handoff.dart';

/// Owns a single entrance clock independent of locale and PageView rebuilds.
class OnboardingEntrance extends StatefulWidget {
  const OnboardingEntrance({
    super.key,
    required this.enabled,
    required this.child,
  });
  final bool enabled;
  final Widget child;

  @override
  State<OnboardingEntrance> createState() => _OnboardingEntranceState();
}

class _OnboardingEntranceState extends State<OnboardingEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
    value: widget.enabled ? 0 : 1,
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context) ||
        HandoffScope.of(context)?.notifier != null) {
      _clock.value = 1;
      _started = true;
    } else if (!_started) {
      _started = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _clock.forward();
      });
    }
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = HandoffScope.of(context);
    return _EntranceScope(
      notifier: _clock,
      sharedProgress: scope?.incoming == true ? scope?.notifier?.value : null,
      child: widget.child,
    );
  }
}

class _EntranceScope extends InheritedNotifier<AnimationController> {
  const _EntranceScope({
    required super.notifier,
    required super.child,
    this.sharedProgress,
  });
  final double? sharedProgress;

  @override
  bool updateShouldNotify(covariant _EntranceScope oldWidget) =>
      super.updateShouldNotify(oldWidget) ||
      sharedProgress != oldWidget.sharedProgress;
}

/// Paint-only stagger layered outside the existing finger-driven transforms.
/// Stages: illustration, title, description, then controls and swipe hint.
class OnboardingEntranceStage extends StatelessWidget {
  const OnboardingEntranceStage({
    super.key,
    required this.stage,
    this.enabled = true,
    required this.child,
  });
  final int stage;
  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_EntranceScope>();
    final clock = scope?.notifier;
    if (!enabled || clock == null) {
      return RouteMotionStage(stage: stage, child: child);
    }
    final begin = switch (stage) {
      0 => .18,
      1 => .38,
      2 => .53,
      _ => .75,
    };
    final end = switch (stage) {
      0 => .58,
      1 => .73,
      2 => .85,
      _ => 1.0,
    };
    final progress = Interval(begin, end, curve: Curves.easeOutCubic).transform(
      MediaQuery.disableAnimationsOf(context)
          ? 1
          : scope?.sharedProgress ?? clock.value,
    );
    return RouteMotionStage(
      stage: stage,
      child: IgnorePointer(
        ignoring: progress == 0,
        child: Opacity(
          key: ValueKey('onboarding_entrance_$stage'),
          opacity: progress,
          child: Transform.translate(
            offset: Offset(0, stage < 3 ? 16 * (1 - progress) : 0),
            child: Transform.scale(
              scale: stage == 0 ? .94 + .06 * progress : 1,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
