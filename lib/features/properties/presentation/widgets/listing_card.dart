import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/router/route_names.dart';
import 'package:egy/app/theme/app_colors.dart';
import 'package:egy/core/widgets/ai/ai_labels.dart';
import 'package:egy/features/favorites/presentation/widgets/favorite_button.dart';

import '../../domain/entities/property_listing.dart';
import '../property_type_label.dart';
import 'property_photo.dart';

/// Real catalog card reused by discovery, favorites, recommendations, and chat.
class ListingCard extends StatelessWidget {
  const ListingCard({
    super.key,
    required this.property,
    this.onSimilar,
    this.showDetails = true,
  });

  final PropertyListing property;
  final VoidCallback? onSimilar;
  final bool showDetails;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final number = NumberFormat.decimalPattern(
      Localizations.localeOf(context).languageCode,
    );
    final text = Theme.of(context).textTheme;
    return Card(
      key: ValueKey('listing_${property.id}'),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              SizedBox(
                width: double.infinity,
                child: PropertyPhoto(url: property.imageUrl, height: 160),
              ),
              PositionedDirectional(
                top: 8,
                end: 8,
                child: FavoriteButton(property, filled: true),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(property.title, style: text.titleMedium),
                const SizedBox(height: 8),
                Text(property.location),
                const SizedBox(height: 8),
                Text(
                  '${propertyTypeLabel(l, property.propertyType)} · ${aiCategoryLabel(l, property.category)}',
                ),
                const SizedBox(height: 8),
                Text(
                  property.price == null
                      ? l.aiMissingPrice
                      : '${number.format(property.price)} ${property.category.endsWith('rent') ? l.aiMonthly : l.aiCurrency}',
                  style: text.titleLarge?.copyWith(
                    color: AppColors.primaryGold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    if (property.bedrooms case final beds?)
                      Text(l.homeBeds(beds.toInt())),
                    if (property.bathrooms case final baths?)
                      Text(l.homeBaths(baths.toInt())),
                    if (property.size case final size?)
                      Text(l.homeArea(size.toInt())),
                  ],
                ),
                Wrap(
                  children: [
                    if (showDetails && GoRouter.maybeOf(context) != null)
                      TextButton(
                        onPressed: () => context.pushNamed(
                          RouteNames.propertyDetails,
                          pathParameters: {'id': '${property.id}'},
                        ),
                        child: Text(l.propertyDetails),
                      ),
                    if (onSimilar != null)
                      TextButton(
                        onPressed: onSimilar,
                        child: Text(l.aiSimilar),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
