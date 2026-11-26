import 'package:material_ui/material_ui.dart';

import 'package:egy/app/theme/app_colors.dart';
import 'package:egy/app/theme/app_dimensions.dart';

/// Outlined secondary action button (transparent background, navy border).
///
/// Used for Cancel, Reset, and other non-primary actions.
/// When [onPressed] is `null` the button is visually disabled.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  /// Visible label text.
  final String label;

  /// Tap handler. Pass `null` to disable the button.
  final VoidCallback? onPressed;

  /// When `true`, shows a loading spinner and suppresses tap events.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppDimensions.buttonHeight,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          disabledForegroundColor: AppColors.textTertiary,
          side: BorderSide(
            color: onPressed != null
                ? Theme.of(context).colorScheme.onSurface
                : AppColors.borderLight,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.onSurface,
                  strokeWidth: 2,
                ),
              )
            : Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: onPressed != null
                      ? Theme.of(context).colorScheme.onSurface
                      : AppColors.textTertiary,
                ),
              ),
      ),
    );
  }
}
