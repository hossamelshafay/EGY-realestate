import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/router/route_names.dart';
import 'package:egy/app/theme/app_colors.dart';
import 'package:egy/core/widgets/ai/ai_labels.dart';

import '../../domain/entities/property_listing.dart';
import '../property_type_label.dart';
import 'property_hero.dart';
import 'property_photo.dart';

/// Listing facts from the catalog, with absent optional fields omitted.
class PropertyDetailsContent extends StatelessWidget {
  const PropertyDetailsContent({super.key, required this.property});
  final PropertyListing property;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final price = property.price;
    final primary = PropertyHero.imageUrl(property);
    final photos = property.images
        .where((url) => url != primary && PropertyPhoto.isValidUrl(url))
        .toSet();
    final amenities = property.amenities
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${propertyTypeLabel(l, property.propertyType)} · ${aiCategoryLabel(l, property.category)}',
          style: theme.textTheme.labelLarge?.copyWith(
            color: AppColors.secondaryGold,
            letterSpacing: .6,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          property.title,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        if (property.location.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: AppColors.primaryGold,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(property.location)),
            ],
          ),
        ],
        if (price != null && price.isFinite && price > 0) ...[
          const SizedBox(height: 16),
          Text(
            '${NumberFormat.decimalPattern(l.localeName).format(price)} ${property.category.endsWith('rent') ? l.aiMonthly : l.aiCurrency}',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Divider(height: 1),
        ),
        Wrap(
          spacing: 24,
          runSpacing: 16,
          children: [
            if (property.bedrooms case final count?
                when count.isFinite && count >= 0)
              _fact(Icons.bed_outlined, l.homeBeds(count.toInt())),
            if (property.bathrooms case final count?
                when count.isFinite && count >= 0)
              _fact(Icons.bathtub_outlined, l.homeBaths(count.toInt())),
            if (property.size case final area? when area.isFinite && area > 0)
              _fact(Icons.square_foot_rounded, l.homeArea(area.toInt())),
          ],
        ),
        if (property.description case final description?
            when description.trim().isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(l.propertyDescription, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            description,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.7),
          ),
        ],
        if (amenities.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(l.propertyAmenities, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final amenity in amenities)
                _fact(Icons.check_circle_outline_rounded, amenity),
            ],
          ),
        ],
        if (photos.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(l.propertyPhotos, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          SizedBox(
            height: 124,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, index) => ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 176,
                  child: PropertyPhoto(url: photos.elementAt(index)),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => context.pushNamed(
            RouteNames.recommendationResults,
            queryParameters: {'similar': '${property.id}'},
          ),
          icon: const Icon(Icons.compare_arrows_rounded),
          label: Text(l.aiSimilar),
        ),
      ],
    );
  }

  Widget _fact(IconData icon, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: AppColors.secondaryGold, size: 22),
      const SizedBox(width: 8),
      Flexible(child: Text(label)),
    ],
  );
}
