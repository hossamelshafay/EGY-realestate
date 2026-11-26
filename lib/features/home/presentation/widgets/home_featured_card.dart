import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:egy/app/theme/app_colors.dart';
import 'package:egy/features/favorites/presentation/widgets/favorite_button.dart';
import 'package:egy/features/properties/domain/entities/property_listing.dart';
import 'package:egy/features/properties/presentation/widgets/property_hero.dart';

/// The front and rear layers use the same concise listing summary.
class HomeFeaturedCard extends StatefulWidget {
  const HomeFeaturedCard({
    super.key,
    required this.property,
    required this.inFront,
  });

  final PropertyListing property;
  final bool inFront;

  @override
  State<HomeFeaturedCard> createState() => _HomeFeaturedCardState();
}

class _HomeFeaturedCardState extends State<HomeFeaturedCard> {
  final _photoTag = Object();

  @override
  Widget build(BuildContext context) {
    final property = widget.property;
    final inFront = widget.inFront;
    final text = Theme.of(context).textTheme;
    final preview = PropertyPreview(property, _photoTag);
    return ClipRRect(
      key: ValueKey('featured_${property.id}'),
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        fit: StackFit.expand,
        children: [
          PropertyHero(property: property, tag: inFront ? preview.tag : null),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.transparent,
                  AppColors.primaryNavy.withValues(alpha: .32),
                  AppColors.primaryNavy,
                ],
                stops: const [0, .40, 1],
              ),
            ),
          ),
          PositionedDirectional(
            start: 16,
            end: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: text.titleLarge?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (property.location.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    property.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodyMedium?.copyWith(color: AppColors.white),
                  ),
                ],
                if (property.description case final description?
                    when description.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodySmall?.copyWith(color: AppColors.white),
                  ),
                ],
              ],
            ),
          ),
          if (inFront && GoRouter.maybeOf(context) != null)
            Material(
              color: AppColors.transparent,
              child: InkWell(onTap: () => preview.open(context)),
            ),
          PositionedDirectional(
            top: 12,
            start: 12,
            child: FavoriteButton(property, filled: true),
          ),
        ],
      ),
    );
  }
}
