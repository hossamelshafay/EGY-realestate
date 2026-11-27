import 'package:egy/app/di/injection.dart';
import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/router/route_names.dart';
import 'package:egy/app/theme/app_colors.dart';
import 'package:egy/core/web/web_breakpoints.dart';
import 'package:egy/core/web/web_property_card.dart';
import 'package:egy/core/widgets/skeleton/app_skeleton.dart';
import 'package:egy/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:egy/features/properties/domain/entities/property_listing.dart';
import 'package:egy/features/properties/domain/repositories/catalog_repository.dart';
import 'package:egy/features/properties/presentation/cubit/property_details_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Dedicated two-column desktop Property Details page for Flutter Web.
class WebPropertyDetailsPage extends StatefulWidget {
  const WebPropertyDetailsPage({
    super.key,
    required this.id,
    this.cubit,
  });

  final int id;
  final PropertyDetailsCubit? cubit;

  @override
  State<WebPropertyDetailsPage> createState() => _WebPropertyDetailsPageState();
}

class _WebPropertyDetailsPageState extends State<WebPropertyDetailsPage> {
  late final PropertyDetailsCubit _cubit;
  late final bool _ownsCubit;
  int _selectedImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _ownsCubit = widget.cubit == null;
    _cubit =
        widget.cubit ??
        (PropertyDetailsCubit(sl<CatalogRepository>(), widget.id)..load());
  }

  @override
  void dispose() {
    if (_ownsCubit) _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider.value(
      value: _cubit,
      child: SingleChildScrollView(
        child: WebPageContainer(
          child: BlocBuilder<PropertyDetailsCubit, PropertyDetailsState>(
            builder: (context, state) {
              if (state is PropertyDetailsLoading) {
                return const SkeletonShimmer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SkeletonBox(
                        width: double.infinity,
                        height: 360,
                        radius: 16,
                      ),
                      SizedBox(height: 20),
                      SkeletonBox(
                        width: double.infinity,
                        height: 180,
                        radius: 16,
                      ),
                    ],
                  ),
                );
              }
              if (state is PropertyDetailsError) {
                return WebSurfaceCard(
                  child: Column(
                    children: [
                      Text(l10n.somethingWentWrong),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => _cubit.load(),
                        child: Text(l10n.retryButton),
                      ),
                    ],
                  ),
                );
              }

              final property = (state as PropertyDetailsReady).property;
              final photos = <String>[
                if (property.imageUrl != null && property.imageUrl!.isNotEmpty)
                  property.imageUrl!,
                for (final img in property.images)
                  if (img.isNotEmpty && img != property.imageUrl) img,
              ];
              final activePhoto =
                  photos.isEmpty
                      ? null
                      : photos[_selectedImageIndex.clamp(0, photos.length - 1)];
              final isWide = MediaQuery.sizeOf(context).width >= 960;

              final gallery = _GallerySection(
                photos: photos,
                activePhoto: activePhoto,
                selectedIndex: _selectedImageIndex,
                onSelect: (i) => setState(() => _selectedImageIndex = i),
              );

              final info = _InfoSection(property: property);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton.icon(
                    onPressed: () => context.canPop()
                        ? context.pop()
                        : context.go(RoutePaths.propertyCatalog),
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: Text(l10n.back),
                  ),
                  const SizedBox(height: 16),
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 7, child: gallery),
                        const SizedBox(width: 28),
                        Expanded(flex: 5, child: info),
                      ],
                    )
                  else ...[
                    gallery,
                    const SizedBox(height: 24),
                    info,
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _GallerySection extends StatelessWidget {
  const _GallerySection({
    required this.photos,
    required this.activePhoto,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<String> photos;
  final String? activePhoto;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: AspectRatio(
            aspectRatio: 16 / 10,
            child: activePhoto != null
                ? Image.network(
                    activePhoto!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _GalleryFallback(),
                  )
                : _GalleryFallback(),
          ),
        ),
        if (photos.length > 1) ...[
          const SizedBox(height: 16),
          Text(
            l10n.propertyPhotos,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 82,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final selected = index == selectedIndex;
                return InkWell(
                  onTap: () => onSelect(index),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 116,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? AppColors.primaryGold
                            : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      photos[index],
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _GalleryFallback(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _GalleryFallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryNavy.withValues(alpha: 0.1),
      child: Center(
        child: Icon(
          Icons.apartment_rounded,
          size: 56,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.property});

  final PropertyListing property;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final favoritesState = context.watch<FavoritesCubit?>()?.state;
    final isSaved =
        favoritesState is FavoritesReady &&
        favoritesState.ids.contains(property.id);

    return WebSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              property.propertyType,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isDark ? AppColors.primaryGold : AppColors.primaryNavy,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            property.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  property.localizedCity ?? property.location,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            WebPropertyCard.formatPrice(l10n, property),
            style: theme.textTheme.headlineSmall?.copyWith(
              color: isDark ? AppColors.primaryGold : AppColors.primaryNavy,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              if (property.bedrooms != null)
                _SpecPill(
                  icon: Icons.bed_outlined,
                  label: l10n.homeBeds(property.bedrooms!.round()),
                ),
              if (property.bathrooms != null)
                _SpecPill(
                  icon: Icons.bathtub_outlined,
                  label: l10n.homeBaths(property.bathrooms!.round()),
                ),
              if (property.size != null)
                _SpecPill(
                  icon: Icons.square_foot_rounded,
                  label: l10n.homeArea(property.size!.round()),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              if (favoritesState is FavoritesReady)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        context.read<FavoritesCubit>().toggle(property),
                    icon: Icon(
                      isSaved
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                    ),
                    label: Text(isSaved ? l10n.homeUnsave : l10n.homeSave),
                  ),
                ),
              if (favoritesState is FavoritesReady) const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => context.push(
                    '${RoutePaths.recommendations}?similarTo=${property.id}',
                  ),
                  icon: const Icon(Icons.auto_awesome_outlined),
                  label: Text(l10n.aiSimilar),
                ),
              ),
            ],
          ),
          if (property.description != null &&
              property.description!.trim().isNotEmpty) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              l10n.propertyDescription,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              property.description!,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.55),
            ),
          ],
          if (property.amenities.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              l10n.propertyAmenities,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final amenity in property.amenities)
                  Chip(label: Text(amenity)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SpecPill extends StatelessWidget {
  const _SpecPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: scheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
