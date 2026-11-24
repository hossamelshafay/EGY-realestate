import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/router/route_names.dart';
import 'package:egy/app/theme/app_colors.dart';
import 'package:egy/core/widgets/ai/ai_feedback.dart';
import 'package:egy/core/widgets/content_fade.dart';
import 'package:egy/features/properties/presentation/cubit/catalog_cubit.dart';

import '../cubit/home_cubit.dart';
import 'home_featured_pages.dart';
import 'home_palette.dart';

/// The existing horizontal feature strip, driven by a server sample.
class HomeFeaturedCarousel extends StatelessWidget {
  const HomeFeaturedCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final catalog = context.watch<CatalogCubit>().state;
    final filters = context.watch<HomeCubit>().state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l.homeFeatured,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: HomePalette.ink(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              key: const Key('home_view_all'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryGold,
              ),
              onPressed: () => context.pushNamed(
                RouteNames.propertyCatalog,
                queryParameters: {'category': catalog.category.code},
              ),
              child: Row(
                children: [
                  Text(l.homeViewAll),
                  const Icon(Icons.chevron_right_rounded, size: 20),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, bounds) {
            final scale = MediaQuery.textScalerOf(context).scale(12) / 12;
            final height =
                (bounds.maxWidth * .82).clamp(260.0, 440.0) +
                (scale - 1).clamp(0.0, 2.0) * 140;
            return SizedBox(
              height: height + 40,
              child: ContentFade(
                child: KeyedSubtree(
                  key: ValueKey((
                    catalog.category,
                    catalog.runtimeType,
                    filters.filterKey,
                  )),
                  child: switch (catalog) {
                    CatalogLoading() => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    CatalogError(:final failure) => Center(
                      child: AiFeedback(
                        failure: failure,
                        onRetry: context.read<CatalogCubit>().refresh,
                      ),
                    ),
                    CatalogReady() => HomeFeaturedPages(
                      catalog: catalog,
                      filters: filters,
                      cardHeight: height,
                    ),
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
