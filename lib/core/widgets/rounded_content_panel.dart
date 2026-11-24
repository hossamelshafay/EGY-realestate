import 'package:material_ui/material_ui.dart';

import 'package:egy/app/theme/app_colors.dart';
import 'package:egy/app/theme/app_dimensions.dart';

/// White content panel with 24 px top-corner radius.
///
/// Sits below the [AppHeader] in the standard navy-header + white-panel layout.
/// Wraps [child] in an [Expanded] container so it fills all remaining space.
class RoundedContentPanel extends StatelessWidget {
  const RoundedContentPanel({super.key, required this.child});

  /// The scrollable or static content to display inside the panel.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppDimensions.radiusXl),
            topRight: Radius.circular(AppDimensions.radiusXl),
          ),
        ),
        child: child,
      ),
    );
  }
}
