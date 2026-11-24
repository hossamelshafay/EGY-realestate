import 'package:material_ui/material_ui.dart';

import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:egy/app/router/route_names.dart';
import 'home_circle_action.dart';

/// Compact assistant entry embedded below the Home greeting.
class HomeAssistantBanner extends StatelessWidget {
  const HomeAssistantBanner({super.key, this.compact = false});
  final bool compact;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      key: const Key('home_assistant_banner'),
      padding: EdgeInsetsDirectional.fromSTEB(
        12,
        compact ? 12 : 16,
        12,
        compact ? 12 : 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryGold.withValues(alpha: .65)),
        boxShadow: compact
            ? const []
            : [
                BoxShadow(
                  color: AppColors.primaryGold.withValues(alpha: .08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        children: [
          Transform.scale(
            scale: compact ? .8 : 1,
            child: HomeCircleAction(
              label: l.homeAssistantTitle,
              onPressed: () => context.pushNamed(RouteNames.aiChat),
            ),
          ),
          SizedBox(width: compact ? 8 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.homeAssistantTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.white,
                    fontSize: compact ? 16 : null,
                  ),
                ),
                SizedBox(height: compact ? 4 : 6),
                Text(
                  l.homeAssistantBannerDescription,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.white.withValues(alpha: .9),
                    fontSize: compact ? 11 : null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Transform.flip(
            key: const Key('home_robot'),
            flipX: Directionality.of(context) == TextDirection.rtl,
            child: SizedBox(
              width: compact ? 51 : 68,
              height: compact ? 75 : 100,
              child: const FittedBox(child: _FriendlyRobot()),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small native shapes avoid a heavy illustration dependency or animated blur.
class _FriendlyRobot extends StatelessWidget {
  const _FriendlyRobot();
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: 68,
      height: 100,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            AppColors.primaryGold.withValues(alpha: .22),
            AppColors.transparent,
          ],
          radius: .85,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 4,
            height: 10,
            decoration: BoxDecoration(
              color: AppColors.primaryGold,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Container(
            width: 64,
            height: 48,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.secondaryNavy,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (var eye = 0; eye < 2; eye++)
                    Container(
                      width: 7,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 48,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.offWhite,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
                bottom: Radius.circular(8),
              ),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              size: 14,
              color: AppColors.primaryGold,
            ),
          ),
        ],
      ),
    ),
  );
}
