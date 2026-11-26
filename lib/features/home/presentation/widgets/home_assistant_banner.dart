import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/router/route_names.dart';
import 'package:egy/app/theme/app_colors.dart';

/// Premium horizontally composed AI Assistant entry card on Home.
class HomeAssistantBanner extends StatefulWidget {
  const HomeAssistantBanner({super.key, this.compact = false});
  final bool compact;

  @override
  State<HomeAssistantBanner> createState() => _HomeAssistantBannerState();
}

class _HomeAssistantBannerState extends State<HomeAssistantBanner> {
  bool _pressed = false;

  void _openChat() => context.pushNamed(RouteNames.aiChat);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final reduced = MediaQuery.disableAnimationsOf(context);
    final compact = widget.compact;

    return AnimatedScale(
      scale: _pressed && !reduced ? 0.985 : 1.0,
      duration: reduced
          ? Duration.zero
          : const Duration(milliseconds: 140),
      curve: Curves.easeOutCubic,
      child: Material(
        color: AppColors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          key: const Key('home_assistant_banner'),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: [
                AppColors.onboardingNavy,
                AppColors.secondaryNavy,
                AppColors.primaryNavy,
              ],
            ),
            border: Border.all(
              color: AppColors.primaryGold.withValues(
                alpha: isDark ? 0.55 : 0.45,
              ),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGold.withValues(
                  alpha: isDark ? 0.14 : 0.10,
                ),
                blurRadius: compact ? 14 : 20,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: AppColors.primaryNavy.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            onTap: _openChat,
            onHighlightChanged: (active) {
              if (_pressed != active) setState(() => _pressed = active);
            },
            borderRadius: BorderRadius.circular(24),
            splashColor: AppColors.primaryGold.withValues(alpha: 0.14),
            highlightColor: AppColors.primaryGold.withValues(alpha: 0.08),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                16,
                compact ? 12 : 16,
                14,
                compact ? 12 : 16,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.auto_awesome_rounded,
                              size: 15,
                              color: AppColors.primaryGold,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                l.homeAssistantTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: compact ? 16 : 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l.homeAssistantBannerDescription,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.white.withValues(alpha: 0.84),
                            fontSize: compact ? 11.5 : 12.5,
                            height: 1.35,
                          ),
                        ),
                        SizedBox(height: compact ? 8 : 12),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerStart,
                          child: _CtaPill(label: l.homeAssistantCta),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  _AssistantBadge(compact: compact, reduced: reduced),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CtaPill extends StatelessWidget {
  const _CtaPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('home_assistant_cta'),
      padding: const EdgeInsetsDirectional.fromSTEB(12, 6, 10, 6),
      decoration: BoxDecoration(
        gradient: AppColors.goldGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withValues(alpha: 0.28),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.primaryNavy,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.arrow_forward_rounded,
            size: 14,
            color: AppColors.primaryNavy,
          ),
        ],
      ),
    );
  }
}

class _AssistantBadge extends StatelessWidget {
  const _AssistantBadge({required this.compact, required this.reduced});
  final bool compact;
  final bool reduced;

  @override
  Widget build(BuildContext context) {
    final size = widgetSize(compact);
    return Transform.flip(
      key: const Key('home_robot'),
      flipX: Directionality.of(context) == TextDirection.rtl,
      child: ExcludeSemantics(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: reduced ? 1.0 : 0.0, end: 1.0),
          duration: reduced
              ? Duration.zero
              : const Duration(milliseconds: 650),
          curve: Curves.easeOutCubic,
          builder: (context, t, child) => Transform.translate(
            offset: Offset(0, (1 - t) * 4),
            child: Opacity(opacity: 0.4 + 0.6 * t, child: child),
          ),
          child: Container(
            width: size,
            height: size + 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: RadialGradient(
                colors: [
                  AppColors.primaryGold.withValues(alpha: 0.24),
                  AppColors.primaryGold.withValues(alpha: 0.04),
                ],
                radius: 0.9,
              ),
              border: Border.all(
                color: AppColors.primaryGold.withValues(alpha: 0.28),
              ),
            ),
            child: const FittedBox(
              fit: BoxFit.contain,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: _ModernBotMark(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static double widgetSize(bool compact) => compact ? 56.0 : 72.0;
}

class _ModernBotMark extends StatelessWidget {
  const _ModernBotMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 62,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.primaryGold,
              shape: BoxShape.circle,
            ),
          ),
          Container(width: 2.5, height: 5, color: AppColors.primaryGold),
          Container(
            width: 52,
            height: 36,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGold.withValues(alpha: 0.22),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primaryNavy,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (var eye = 0; eye < 2; eye++)
                    Container(
                      width: 6,
                      height: 9,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 34,
            height: 8,
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }
}
