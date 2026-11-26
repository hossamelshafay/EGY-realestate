import 'dart:ui' show ImageFilter;

import 'package:material_ui/material_ui.dart';

import 'package:egy/app/router/screen_handoff.dart';
import 'package:egy/core/widgets/session_morph_scope.dart';

/// Uses the shell handoff when present and a local clock on a direct entry.
class HomeStage extends StatefulWidget {
  const HomeStage({
    super.key,
    required this.stage,
    required this.child,
    this.blur = true,
  });
  final int stage;
  final bool blur;
  final Widget child;

  @override
  State<HomeStage> createState() => _HomeStageState();
}

class _HomeStageState extends State<HomeStage>
    with SingleTickerProviderStateMixin {
  late final _entry = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 760),
  );
  bool? _useSharedClock;

  double _sharedProgress(BuildContext context) {
    final scope = SessionMorphScope.of(context);
    final handoff = HandoffScope.of(context);
    final shared = handoff?.incoming == true ? handoff?.notifier?.value : null;
    return (scope?.notifier?.value ?? 1.0).clamp(0.0, shared ?? 1.0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final progress = _sharedProgress(context);
    final reduced = MediaQuery.disableAnimationsOf(context);
    _useSharedClock ??= progress < 1;
    if (reduced) {
      _entry.value = 1;
    } else if (!_useSharedClock! && _entry.isDismissed && widget.stage > 0) {
      _entry.forward();
    }
  }

  @override
  void dispose() {
    _entry.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shared = _sharedProgress(context);
    final reduced = MediaQuery.disableAnimationsOf(context);
    final begin = .24 + widget.stage * .12;
    final interval = Interval(
      begin,
      (begin + .36).clamp(0.0, 1.0),
      curve: Curves.easeOutCubic,
    );
    return AnimatedBuilder(
      animation: _entry,
      child: widget.child,
      builder: (context, child) {
        final t = reduced
            ? 1.0
            : _useSharedClock! || widget.stage == 0
            ? shared
            : _entry.value;
        return HomeBlurFade(
          blur: widget.blur,
          opacityKey: ValueKey('home_stage_${widget.stage}'),
          progress: interval.transform(t),
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - interval.transform(t))),
            child: child,
          ),
        );
      },
    );
  }
}

/// Reveals a layer with a small, bounded blur that is disabled at rest.
class HomeBlurFade extends StatelessWidget {
  const HomeBlurFade({
    super.key,
    required this.progress,
    required this.child,
    this.opacityKey,
    this.blur = true,
  });

  final double progress;
  final Key? opacityKey;
  final bool blur;
  final Widget child;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    ignoring: progress < .95,
    child: Opacity(
      key: opacityKey,
      opacity: progress,
      child: ImageFiltered(
        enabled: blur && progress > 0 && progress < .92,
        imageFilter: ImageFilter.blur(
          sigmaX: (1 - progress) * 3,
          sigmaY: (1 - progress) * 3,
        ),
        child: child,
      ),
    ),
  );
}
