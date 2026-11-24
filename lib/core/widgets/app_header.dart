import 'package:material_ui/material_ui.dart';

import 'package:egy/app/theme/app_colors.dart';
import 'package:egy/app/theme/app_dimensions.dart';

/// Navy gradient header used across most screens.
///
/// Displays the [title] on a [AppColors.navyGradient] background.
/// Optionally shows a leading back button ([onBack]) and a trailing [action].
/// Set [showDrawerToggle] to `true` on the Home screen to show a hamburger icon
/// instead of the back arrow.
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.onBack,
    this.onDrawerToggle,
    this.action,
    this.showDrawerToggle = false,
    this.minHeight = AppDimensions.headerMinHeight,
  });

  /// Screen title rendered in white.
  final String title;

  /// If provided, a white back-arrow button is shown on the leading side.
  final VoidCallback? onBack;

  /// Called when the drawer hamburger icon is tapped.
  /// Only active when [showDrawerToggle] is `true`.
  final VoidCallback? onDrawerToggle;

  /// Optional trailing widget (e.g., an [IconButton]).
  final Widget? action;

  /// When `true`, renders a hamburger icon instead of a back arrow.
  final bool showDrawerToggle;

  /// Minimum header height in logical pixels.
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: minHeight),
      decoration: const BoxDecoration(gradient: AppColors.navyGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.base,
            vertical: AppDimensions.md,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Leading ────────────────────────────────────────────────────
              if (showDrawerToggle)
                _NavIconButton(
                  icon: Icons.menu_rounded,
                  onTap: onDrawerToggle,
                  semanticLabel: 'Open navigation menu',
                )
              else if (onBack != null)
                _NavIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: onBack,
                  semanticLabel: 'Go back',
                )
              else
                const SizedBox(
                  width: AppDimensions.iconSizeLg + AppDimensions.sm,
                ),

              // ── Title ──────────────────────────────────────────────────────
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.textOnDark,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),

              // ── Trailing ───────────────────────────────────────────────────
              if (action != null)
                action!
              else
                const SizedBox(
                  width: AppDimensions.iconSizeLg + AppDimensions.sm,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Reusable icon button styled for the navy header.
class _NavIconButton extends StatelessWidget {
  const _NavIconButton({
    required this.icon,
    required this.semanticLabel,
    this.onTap,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: AppColors.white, size: AppDimensions.iconSizeMd),
      tooltip: semanticLabel,
      style: IconButton.styleFrom(
        minimumSize: const Size(
          AppDimensions.iconSizeLg + AppDimensions.sm,
          AppDimensions.iconSizeLg + AppDimensions.sm,
        ),
      ),
    );
  }
}
