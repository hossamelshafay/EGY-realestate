import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/router/route_names.dart';
import 'package:egy/app/theme/app_colors.dart';
import 'package:egy/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:egy/features/properties/domain/entities/property_listing.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

/// Clean, desktop-proportioned property card for Flutter Web grids.
class WebPropertyCard extends StatelessWidget {
  const WebPropertyCard({
    super.key,
    required this.property,
    this.onTap,
    this.compact = false,
  });

  final PropertyListing property;
  final VoidCallback? onTap;
  final bool compact;

  static String formatPrice(AppLocalizations l10n, PropertyListing item) {
    final price = item.price;
    if (price == null) return l10n.aiMissingPrice;
    final formatted = NumberFormat('#,##0').format(price.round());
    final isRent = item.category.contains('rent');
    return isRent ? '$formatted ${l10n.aiMonthly}' : l10n.homePrice(formatted);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final image = property.imageUrl ?? property.images.firstOrNull;

    final favoritesState = context.watch<FavoritesCubit?>()?.state;
    final isSaved =
        favoritesState is FavoritesReady &&
        favoritesState.ids.contains(property.id);

    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap:
            onTap ??
            () => context.pushNamed(
              RouteNames.propertyDetails,
              pathParameters: {'id': '${property.id}'},
            ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: scheme.outlineVariant.withValues(
                alpha: isDark ? 0.35 : 0.6,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 10,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (image != null && image.isNotEmpty)
                      Image.network(
                        image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _PlaceholderImage(),
                      )
                    else
                      _PlaceholderImage(),
                    PositionedDirectional(
                      top: 10,
                      start: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryNavy.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          property.propertyType,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    if (favoritesState is FavoritesReady)
                      PositionedDirectional(
                        top: 8,
                        end: 8,
                        child: Material(
                          color: Colors.black.withValues(alpha: 0.45),
                          shape: const CircleBorder(),
                          child: IconButton(
                            tooltip: isSaved ? l10n.homeUnsave : l10n.homeSave,
                            onPressed: () =>
                                context.read<FavoritesCubit>().toggle(property),
                            icon: Icon(
                              isSaved
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: isSaved
                                  ? AppColors.primaryGold
                                  : Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(compact ? 12 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formatPrice(l10n, property),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isDark
                            ? AppColors.primaryGold
                            : AppColors.primaryNavy,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      property.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 15,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            property.localizedCity ?? property.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: compact ? 8 : 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 4,
                      children: [
                        if (property.bedrooms != null)
                          _SpecChip(
                            icon: Icons.bed_outlined,
                            label: l10n.homeBeds(property.bedrooms!.round()),
                          ),
                        if (property.bathrooms != null)
                          _SpecChip(
                            icon: Icons.bathtub_outlined,
                            label: l10n.homeBaths(property.bathrooms!.round()),
                          ),
                        if (property.size != null)
                          _SpecChip(
                            icon: Icons.square_foot_rounded,
                            label: l10n.homeArea(property.size!.round()),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryNavy.withValues(alpha: 0.12),
      child: Center(
        child: Icon(
          Icons.apartment_rounded,
          size: 40,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _SpecChip extends StatelessWidget {
  const _SpecChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
        ),
      ],
    );
  }
}
