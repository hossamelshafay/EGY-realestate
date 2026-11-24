import 'dart:ui' show lerpDouble;
import 'package:egy/features/home/presentation/widgets/home_assistant_banner.dart';
import 'package:egy/features/home/presentation/widgets/home_stage.dart';
import 'package:material_ui/material_ui.dart';

import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/theme/app_colors.dart';
import 'package:egy/features/authentication/presentation/widgets/asymmetric_auth_clipper.dart';
import 'package:egy/features/authentication/presentation/widgets/auth_entrance.dart';
import 'package:egy/features/authentication/presentation/widgets/auth_motion_scope.dart';
import 'package:egy/features/authentication/presentation/widgets/auth_result_animation.dart';
import 'session_header_metrics.dart';

/// The same clipped navy surface and image survive every auth/result/Home phase.
class SharedSessionHeader extends StatefulWidget {
  const SharedSessionHeader({
    super.key,
    required this.metrics,
    required this.onMenu,
  });
  final SessionHeaderMetrics metrics;
  final VoidCallback onMenu;
  @override
  State<SharedSessionHeader> createState() => _SharedSessionHeaderState();
}

class _SharedSessionHeaderState extends State<SharedSessionHeader> {
  late final Widget _logo = Image.asset(
    'assets/img/logo.png',
    key: const Key('auth_logo'),
    fit: BoxFit.contain,
  );
  @override
  Widget build(BuildContext context) {
    final m = widget.metrics;
    final motion = AuthMotionScope.of(context)!;
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context).textTheme;
    final authOpacity =
        (1 - m.home) * (1 - motion.cover.value) * (1 - motion.fold);
    final homeOpacity = ((m.home - .25) / .6).clamp(0.0, 1.0);
    return ClipPath(
      key: const Key('session_header_clip'),
      clipper: AsymmetricAuthClipper(
        reset: motion.reset,
        mirror: motion.mirror,
        fold: motion.fold,
        expansion: motion.cover.value,
        home: m.home,
      ),
      child: SizedBox(
        key: const Key('brand_header_geometry'),
        width: double.infinity,
        height: m.height,
        child: ColoredBox(
          color: AppColors.primaryNavy,
          child: Stack(
            children: [
              Positioned.fromRect(
                rect: m.logo,
                child: Opacity(
                  opacity: 1 - motion.cover.value * (1 - m.home),
                  child: AuthEntranceStage(stage: 1, scale: true, child: _logo),
                ),
              ),
              Positioned(
                top: m.top + 88 - 16 * motion.mirror - 16 * motion.fold,
                left: lerpDouble(
                  24 + (m.width * .36 - 48) * motion.mirror,
                  24,
                  motion.reset,
                ),
                width: lerpDouble(m.width * .64, m.width - 48, motion.reset),
                child: Opacity(
                  opacity: authOpacity,
                  child: Column(
                    children: [
                      Text(
                        m.title,
                        textAlign: TextAlign.center,
                        style: theme.headlineLarge?.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        m.subtitle,
                        textAlign: TextAlign.center,
                        style: theme.bodyMedium?.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              PositionedDirectional(
                top: m.top + 64,
                start: 24,
                end: 24,
                child: Opacity(
                  opacity: homeOpacity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 48),
                        child: Text(
                          m.welcome,
                          key: const Key('home_greeting'),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.headlineMedium?.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l.homeMember,
                        style: theme.bodySmall?.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              PositionedDirectional(
                top: m.top + 60,
                end: 12,
                child: IgnorePointer(
                  ignoring: m.home < 1 || motion.busy,
                  child: Opacity(
                    opacity: homeOpacity,
                    child: IconButton(
                      key: const Key('home_menu'),
                      tooltip: l.homeMenu,
                      onPressed: widget.onMenu,
                      icon: const Icon(
                        Icons.menu_rounded,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
              PositionedDirectional(
                top: m.bannerTop,
                start: 16,
                end: 16,
                child: IgnorePointer(
                  ignoring: m.home < 1 || motion.busy,
                  child: Opacity(
                    opacity: homeOpacity,
                    child: const HomeStage(
                      stage: 0,
                      child: RepaintBoundary(
                        child: HomeAssistantBanner(compact: true),
                      ),
                    ),
                  ),
                ),
              ),
              if (motion.showingResult)
                const Positioned.fill(child: AuthResultAnimation()),
            ],
          ),
        ),
      ),
    );
  }
}
