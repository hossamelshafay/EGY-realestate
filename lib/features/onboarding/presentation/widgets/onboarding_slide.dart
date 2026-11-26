import 'package:material_ui/material_ui.dart';
import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/router/route_names.dart';
import 'package:egy/app/theme/app_colors.dart';
import '../cubit/onboarding_cubit.dart';
import 'onboarding_assets.dart';
import 'onboarding_entrance.dart';
import 'package:egy/app/router/app_motion.dart';

/// A single onboarding slide whose every visual element is driven by [motion].
///
/// [motion] is `(controller.page - index)` clamped to [-1, 1]:
/// - 0  → this slide is fully centred
/// - +1 → this slide has scrolled fully upward (exiting above)
/// - -1 → this slide has not yet arrived (waiting below)
class OnboardingSlide extends StatelessWidget {
  const OnboardingSlide({
    super.key,
    required this.index,
    required this.title,
    required this.description,
    required this.motion,
    required this.pageController,
    required this.state,
    required this.onFinish,
  });

  final int index;
  final String title, description;

  /// Fractional offset from [-1, 1]. Positive = scrolled upward (exiting).
  final double motion;
  final PageController pageController;
  final OnboardingState state;
  final Future<void> Function(String) onFinish;

  // ── Motion helpers ─────────────────────────────────────────────────────────

  /// Image: slides up (exiting) or down-then-up (entering), scales slightly,
  /// and fades out as it moves away.
  double get _illustrationOffset => motion * 72;
  double get _illustrationScale => 1.0 - motion.abs() * 0.07;
  double get _illustrationOpacity => (1.0 - motion.abs() * 1.3).clamp(0.0, 1.0);

  /// Title fades out faster than the illustration (staggered lead).
  double get _titleOpacity => (1.0 - motion.abs() * 1.6).clamp(0.0, 1.0);
  double get _titleOffset => motion * 36;

  /// Description fades even earlier (staggered behind title).
  double get _descOpacity => (1.0 - motion.abs() * 2.0).clamp(0.0, 1.0);
  double get _descOffset => motion * 20;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(
            child: Padding(
              // Extra bottom padding so indicators overlay doesn't overlap buttons
              padding: const EdgeInsets.fromLTRB(24, 44, 24, 72),
              child: Column(
                children: [
                  // ── Illustration ─────────────────────────────────────────
                  Expanded(
                    child: OnboardingEntranceStage(
                      key: ValueKey('onboarding_illustration_$index'),
                      stage: 0,
                      enabled: index == 0,
                      child: Transform.translate(
                        offset: Offset(0, _illustrationOffset),
                        child: Transform.scale(
                          scale: _illustrationScale,
                          child: Opacity(
                            opacity: _illustrationOpacity,
                            child: Image.asset(
                              OnboardingAssets.illustrations[index],
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Title ────────────────────────────────────────────────
                  OnboardingEntranceStage(
                    stage: 1,
                    enabled: index == 0,
                    child: Transform.translate(
                      offset: Offset(0, _titleOffset),
                      child: Opacity(
                        opacity: _titleOpacity,
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: text.headlineLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── Description ──────────────────────────────────────────
                  OnboardingEntranceStage(
                    stage: 2,
                    enabled: index == 0,
                    child: Transform.translate(
                      offset: Offset(0, _descOffset),
                      child: Opacity(
                        opacity: _descOpacity,
                        child: Text(
                          description,
                          textAlign: TextAlign.center,
                          style: text.bodyLarge,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── CTA area ─────────────────────────────────────────────
                  if (index < 2) ...[
                    OnboardingEntranceStage(
                      stage: 3,
                      enabled: index == 0,
                      child: Opacity(
                        opacity: _descOpacity,
                        child: Icon(
                          Icons.keyboard_double_arrow_up,
                          color: AppColors.onboardingGold,
                          size: 32,
                        ),
                      ),
                    ),
                    OnboardingEntranceStage(
                      stage: 3,
                      enabled: index == 0,
                      child: Opacity(
                        opacity: _descOpacity,
                        child: Text(l.swipeUp, style: text.titleMedium),
                      ),
                    ),
                  ] else ...[
                    if (state is OnboardingReady &&
                        (state as OnboardingReady).error)
                      Text(
                        l.somethingWentWrong,
                        style: text.bodyMedium?.copyWith(
                          color: AppColors.destructiveRed,
                        ),
                      ),
                    RouteMotionStage(
                      stage: 3,
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          key: const Key('log_in'),
                          onPressed: state is OnboardingSaving
                              ? null
                              : () => onFinish(RouteNames.login),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primaryGold,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            minimumSize: const Size(0, 56),
                          ),
                          child: Text(l.logIn),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    RouteMotionStage(
                      stage: 3,
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          key: const Key('create_account'),
                          onPressed: state is OnboardingSaving
                              ? null
                              : () => onFinish(RouteNames.register),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppColors.white.withValues(
                              alpha: 0,
                            ),
                            foregroundColor: AppColors.primaryGold,
                            side: const BorderSide(
                              color: AppColors.primaryGold,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            minimumSize: const Size(0, 56),
                          ),
                          child: Text(l.createAccount),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
