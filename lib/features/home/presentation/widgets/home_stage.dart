import 'package:material_ui/material_ui.dart';

import 'package:egy/core/widgets/session_morph_scope.dart';
import 'package:egy/app/router/screen_handoff.dart';

/// Home sections overlap the departing form on the persistent shell clock.
class HomeStage extends StatelessWidget {
  const HomeStage({super.key, required this.stage, required this.child});
  final int stage;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final scope = SessionMorphScope.of(context);
    final handoff = HandoffScope.of(context);
    final shared = handoff?.incoming == true ? handoff?.notifier?.value : null;
    final t = MediaQuery.disableAnimationsOf(context)
        ? 1.0
        : (scope?.notifier?.value ?? 1.0).clamp(0.0, shared ?? 1.0);
    final begin = .24 + stage * .12;
    final progress = Interval(
      begin,
      (begin + .36).clamp(0.0, 1.0),
      curve: Curves.easeOutCubic,
    ).transform(t);
    return IgnorePointer(
      ignoring: progress < 1,
      child: Opacity(
        key: ValueKey('home_stage_$stage'),
        opacity: progress,
        child: Transform.translate(
          offset: Offset(0, 16 * (1 - progress)),
          child: child,
        ),
      ),
    );
  }
}
