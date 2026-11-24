import 'package:material_ui/material_ui.dart';

import 'package:egy/app/theme/app_colors.dart';
import 'package:egy/core/widgets/primary_button.dart';

/// Generic error state view with an icon, message, and optional retry button.
///
/// [message] should be a localised string from the caller.
/// [onRetry] is optional — omit it for non-retriable errors.
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Retry',
  });

  /// Human-readable error description.
  final String message;

  /// If provided, shows a [PrimaryButton] that calls this callback.
  final VoidCallback? onRetry;

  /// Label for the retry button (localise at the call site).
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: AppColors.destructiveRed.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              PrimaryButton(
                label: retryLabel,
                onPressed: onRetry,
                variant: PrimaryButtonVariant.navy,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
