import 'package:material_ui/material_ui.dart';
import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/theme/app_colors.dart';
import 'package:egy/core/errors/failures.dart';

/// Safe localized errors; server details and tokens never reach the UI.
class AiFeedback extends StatelessWidget {
  const AiFeedback({super.key, required this.failure, this.onRetry});
  final Failure failure;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final message = switch (failure) {
      UnauthenticatedFailure() => l.aiSignIn,
      NetworkFailure() => l.authNetwork,
      ServerFailure(statusCode: 422) => l.aiInvalidInput,
      ServerFailure(statusCode: 429) => l.aiRateLimit,
      _ => l.aiUnavailable,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.destructiveRed),
          ),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: Text(l.retryButton)),
        ],
      ),
    );
  }
}
