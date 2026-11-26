export 'package:egy/core/widgets/brand_header_clipper.dart';
import 'package:egy/core/widgets/safe_animated_size.dart';
import 'package:material_ui/material_ui.dart';
import 'package:egy/app/theme/app_colors.dart';
import 'auth_entrance.dart';

/// The same image element remains mounted while its size and position adapt.
class AnimatedBrandHeader extends StatelessWidget {
  const AnimatedBrandHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.compact,
  });
  final String title;
  final String subtitle;
  final bool compact;
  @override
  Widget build(BuildContext context) {
    final duration = Duration(
      milliseconds: MediaQuery.disableAnimationsOf(context) ? 0 : 450,
    );
    return TweenAnimationBuilder<double>(
      tween: Tween(end: compact ? 1 : 0),
      duration: duration,
      curve: Curves.easeInOutCubic,
      builder: (context, value, child) => SizedBox(
        key: const Key('brand_header_geometry'),
        width: double.infinity,
        child: ColoredBox(
          color: AppColors.primaryNavy,
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              24,
              MediaQuery.paddingOf(context).top + 32 - 12 * value,
              24,
              32 - 8 * value,
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 56 - 8 * value,
                  child: AuthEntranceStage(
                    stage: 1,
                    scale: true,
                    child: Transform.scale(scale: .88, child: child),
                  ),
                ),
                const SizedBox(height: 20),
                AuthEntranceStage(
                  stage: 2,
                  child: SafeAnimatedSize(
                    duration: duration,
                    curve: Curves.easeInOutCubic,
                    child: AnimatedSwitcher(
                      duration: duration,
                      transitionBuilder: _transition,
                      child: Text(
                        title,
                        key: ValueKey(title),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(color: AppColors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                AuthEntranceStage(
                  stage: 2,
                  child: SafeAnimatedSize(
                    duration: duration,
                    curve: Curves.easeInOutCubic,
                    child: AnimatedSwitcher(
                      duration: duration,
                      transitionBuilder: _transition,
                      child: Text(
                        subtitle,
                        key: ValueKey(subtitle),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      child: Image.asset(
        'assets/img/logo.png',
        key: const Key('auth_logo'),
        fit: BoxFit.contain,
      ),
    );
  }

  static Widget _transition(Widget child, Animation<double> animation) =>
      FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, .08),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      );
}
