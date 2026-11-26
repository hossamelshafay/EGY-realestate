import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/theme/app_colors.dart';
import 'package:egy/core/widgets/ai/ai_labels.dart';
import 'package:egy/core/widgets/orbiting_card_border.dart';
import 'package:egy/features/favorites/presentation/widgets/favorite_button.dart';

import '../../domain/entities/property_listing.dart';
import '../property_type_label.dart';
import 'property_hero.dart';

/// Real catalog card reused by discovery, favorites, recommendations, and chat.
class ListingCard extends StatefulWidget {
  const ListingCard({
    super.key,
    required this.property,
    this.onSimilar,
    this.showDetails = true,
    this.borderGlow,
  });

  final PropertyListing property;
  final VoidCallback? onSimilar;
  final bool showDetails;
  final Color? borderGlow;

  @override
  State<ListingCard> createState() => _ListingCardState();
}

class _ListingCardState extends State<ListingCard> {
  final _photoTag = Object();

  @override
  Widget build(BuildContext context) {
    final property = widget.property;
    final onSimilar = widget.onSimilar;
    final preview = PropertyPreview(property, _photoTag);
    final l = AppLocalizations.of(context);
    final number = NumberFormat.decimalPattern(
      Localizations.localeOf(context).languageCode,
    );
    final text = Theme.of(context).textTheme;
    final card = Card(
      key: ValueKey('listing_${property.id}'),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              SizedBox(
                width: double.infinity,
                height: 160,
                child: PropertyHero(
                  property: property,
                  tag: preview.tag,
                  radius: 0,
                ),
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
                Text(
                  property.title,
                  style: text.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(property.location),
                if (property.description case final description?
                    when description.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
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
                    if (widget.showDetails && GoRouter.maybeOf(context) != null)
                      TextButton(
                        onPressed: () => preview.open(context),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: widget.borderGlow != null
          ? OrbitingCardBorder(color: widget.borderGlow!, child: card)
          : card,
    );
  }
}
