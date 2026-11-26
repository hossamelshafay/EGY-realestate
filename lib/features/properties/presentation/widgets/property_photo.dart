import 'package:material_ui/material_ui.dart';

import 'package:egy/app/theme/app_colors.dart';
import 'package:egy/core/widgets/skeleton/app_skeleton.dart';

/// Displays the listing's own image with the same fallback across screens.
class PropertyPhoto extends StatelessWidget {
  const PropertyPhoto({super.key, this.url, this.height});

  final String? url;
  final double? height;

  /// Only displays images from valid HTTPS URLs.
  static bool isValidUrl(String? url) {
    final uri = Uri.tryParse(url ?? '');
    return uri != null && uri.scheme == 'https' && uri.host.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
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
    if (!isValidUrl(url)) {
      return fallback;
    }
    return Image.network(
      url!,
      height: height,
      fit: BoxFit.cover,
      cacheWidth: 960,
      excludeFromSemantics: true,
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : SkeletonShimmer(
              child: SkeletonBox(height: height ?? 160, radius: 0),
            ),
      errorBuilder: (_, _, _) => fallback,
    );
  }
}
