import 'package:material_ui/material_ui.dart';
import 'package:egy/app/theme/app_colors.dart';
import 'package:egy/app/router/screen_handoff.dart';
import 'package:egy/core/widgets/session_morph_scope.dart';
import 'package:egy/core/widgets/session_scroll_scope.dart';

import 'auth_entrance.dart';
import 'auth_header.dart';
import 'auth_motion_scope.dart';

/// Persistent scrollable frame connecting independent branding and form surfaces.
class AuthShell extends StatelessWidget {
  const AuthShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.compact,
    required this.child,
  });
  final String title;
  final String subtitle;
  final bool compact;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    if (SessionMorphScope.of(context) != null) {
      final motion = AuthMotionScope.of(context);
      final opacity = motion?.formOpacity ?? 1.0;
      final panel = SafeArea(
        key: const Key('auth_form_panel'),
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 464),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(24, 28, 24, 24),
              child: child,
            ),
          ),
        ),
      );
      return Opacity(
        key: const Key('auth_form_motion'),
        opacity: opacity,
        child: Transform.translate(
          offset: Offset(0, -16 * (1 - opacity)),
          child: SessionScrollScope.contains(context)
              ? panel
              : SingleChildScrollView(child: panel),
        ),
      );
    }

    return HandoffSurface(
      color: Theme.of(context).colorScheme.surface,
      child: Scaffold(
        backgroundColor: AppColors.transparent,
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            children: [
              AuthEntranceStage(
                stage: 0,
                child: AnimatedBrandHeader(
                  title: title,
                  subtitle: subtitle,
                  compact: compact,
                ),
              ),
              // A single white boundary backed by navy follows the animated header.
              ColoredBox(
                color: AppColors.primaryNavy.withValues(
                  alpha: _panelProgress(context),
                ),
                child: Container(
                  key: const Key('auth_form_panel'),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withValues(
                      alpha: _panelProgress(context),
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 464),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                            24,
                            28,
                            24,
                            24,
                          ),
                          child: child,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _panelProgress(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return 1;
    final scope = HandoffScope.of(context);
    return HandoffTiming.enter(scope?.notifier?.value ?? 1, .22, .72);
  }
}
