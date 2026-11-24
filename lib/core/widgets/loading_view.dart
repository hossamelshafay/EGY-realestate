import 'package:material_ui/material_ui.dart';

import 'package:egy/app/theme/app_colors.dart';

/// Centered loading indicator shown while async data is being fetched.
///
/// Optionally displays a [message] below the spinner (should be localised
/// by the caller).
class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message});

  /// Optional message rendered below the spinner.
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.primaryNavy),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
