import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/router/route_names.dart';
import 'package:egy/app/theme/app_colors.dart';
import 'package:egy/core/widgets/ai/ai_labels.dart';
import 'package:egy/features/favorites/presentation/widgets/favorite_button.dart';
import 'package:egy/features/properties/domain/entities/property_listing.dart';
import 'package:egy/features/properties/presentation/property_type_label.dart';
import 'package:egy/features/properties/presentation/widgets/property_photo.dart';

/// Full-bleed Home card using the same facts and saved state as the catalog.
class HomeFeaturedCard extends StatelessWidget {
  const HomeFeaturedCard({super.key, required this.property});
  final PropertyListing property;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final price = NumberFormat.decimalPattern(
      l.localeName,
    ).format(property.price);
    return ClipRRect(
      key: ValueKey('featured_${property.id}'),
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        fit: StackFit.expand,
        children: [
          PropertyPhoto(url: property.imageUrl),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.transparent,
                  AppColors.primaryNavy.withValues(alpha: .3),
                  AppColors.primaryNavy,
                ],
                stops: const [0, .38, 1],
              ),
            ),
          ),
          if (GoRouter.maybeOf(context) != null)
            Material(
              color: AppColors.transparent,
              child: InkWell(
                onTap: () => context.pushNamed(
                  RouteNames.propertyDetails,
                  pathParameters: {'id': '${property.id}'},
                ),
              ),
            ),
          PositionedDirectional(
            top: 12,
            start: 12,
            child: FavoriteButton(property, filled: true),
          ),
          PositionedDirectional(
            top: 16,
            start: 68,
            end: 16,
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 190),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  aiCategoryLabel(l, property.category),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: text.labelMedium?.copyWith(
                    color: AppColors.primaryNavy,
                  ),
                ),
              ),
            ),
          ),
          PositionedDirectional(
            start: 16,
            end: 16,
            bottom: 16,
            child: IgnorePointer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    propertyTypeLabel(l, property.propertyType),
                    style: text.labelLarge?.copyWith(color: AppColors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    property.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleLarge?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    property.location,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodySmall?.copyWith(color: AppColors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    property.price == null
                        ? l.aiMissingPrice
                        : '$price ${property.category.endsWith('rent') ? l.aiMonthly : l.aiCurrency}',
                    style: text.titleLarge?.copyWith(
                      color: AppColors.primaryGold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      if (property.bedrooms case final value?)
                        _detail(
                          context,
                          Icons.bed_outlined,
                          l.homeBeds(value.toInt()),
                        ),
                      if (property.bathrooms case final value?)
                        _detail(
                          context,
                          Icons.bathtub_outlined,
                          l.homeBaths(value.toInt()),
                        ),
                      if (property.size case final value?)
                        _detail(
                          context,
                          Icons.square_foot_rounded,
                          l.homeArea(value.toInt()),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detail(BuildContext context, IconData icon, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 18, color: AppColors.white),
      const SizedBox(width: 4),
      Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppColors.white),
      ),
    ],
  );
}
