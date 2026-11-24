import 'package:material_ui/material_ui.dart';

import 'package:egy/app/theme/app_colors.dart';

/// Compact directional action shared by the banner and AI tool cards.
class HomeCircleAction extends StatelessWidget {
  const HomeCircleAction({
    super.key,
    required this.label,
    required this.onPressed,
  });
  final String label;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => IconButton.filled(
    tooltip: label,
    onPressed: onPressed,
    style: IconButton.styleFrom(
      backgroundColor: AppColors.primaryGold,
      foregroundColor: AppColors.primaryNavy,
      minimumSize: const Size(40, 40),
      padding: const EdgeInsets.all(8),
    ),
    icon: const Icon(Icons.arrow_forward_rounded, size: 22),
  );
}
