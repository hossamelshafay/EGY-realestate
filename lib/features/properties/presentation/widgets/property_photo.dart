import 'package:material_ui/material_ui.dart';

import 'package:egy/app/theme/app_colors.dart';

/// Displays the listing's own image with the same fallback across screens.
class PropertyPhoto extends StatelessWidget {
  const PropertyPhoto({super.key, this.url, this.height});

  final String? url;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(url ?? '');
    final fallback = ColoredBox(
      color: AppColors.secondaryNavy,
      child: SizedBox(
        height: height,
        child: const Center(
          child: Icon(
            Icons.home_work_outlined,
            size: 48,
            color: AppColors.primaryGold,
          ),
        ),
      ),
    );
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      return fallback;
    }
    return Image.network(
      uri.toString(),
      height: height,
      fit: BoxFit.cover,
      cacheWidth: 960,
      excludeFromSemantics: true,
      errorBuilder: (_, _, _) => fallback,
    );
  }
}
