import 'package:material_ui/material_ui.dart';

import 'package:egy/app/theme/app_colors.dart';
import 'package:egy/app/theme/app_dimensions.dart';

/// Variant that controls the visual style of a [PrimaryButton].
enum PrimaryButtonVariant {
  /// Gold gradient background — used for Search, Predict, and similar CTAs.
  gold,

  /// Navy solid background — used for Register and other dark-primary actions.
  navy,

  /// Info-blue background — used for Login and link-style primary actions.
  /// See approved design references before applying.
  blue,
}

/// Full-width primary action button with gradient or solid background.
///
/// Choose [variant] based on the design reference for each screen:
/// - [PrimaryButtonVariant.gold] — gold gradient CTA (Search, Predict).
/// - [PrimaryButtonVariant.navy] — solid navy (Register).
/// - [PrimaryButtonVariant.blue] — info blue (Login).
///
/// When [onPressed] is `null` the button is visually disabled.
/// While [isLoading] is `true` a spinner replaces the label text.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.variant = PrimaryButtonVariant.gold,
  });

  /// Visible label text.
  final String label;

  /// Tap handler. Pass `null` to disable the button.
  final VoidCallback? onPressed;

  /// When `true`, shows a loading spinner and suppresses tap events.
  final bool isLoading;

  /// Visual colour scheme. Defaults to [PrimaryButtonVariant.gold].
  final PrimaryButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null && !isLoading;
    final foreground =
        Theme.of(context).brightness == Brightness.dark &&
            variant == PrimaryButtonVariant.gold
        ? AppColors.primaryNavy
        : AppColors.white;
    return SizedBox(
      width: double.infinity,
      height: AppDimensions.buttonHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: enabled && variant == PrimaryButtonVariant.gold
              ? AppColors.goldGradient
              : null,
          color: enabled ? _solidColor() : AppColors.chipInactive,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: ElevatedButton(
          onPressed: enabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
          ),
          child: isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: foreground,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: foreground),
                ),
        ),
      ),
    );
  }

  /// Returns a solid fill colour for non-gold variants, or `null` when gold
  /// (the gradient is applied via [DecoratedBox]).
  Color? _solidColor() {
    return switch (variant) {
      PrimaryButtonVariant.gold => null,
      PrimaryButtonVariant.navy => AppColors.primaryNavy,
      PrimaryButtonVariant.blue => AppColors.infoBlue,
    };
  }
}
