import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/router/route_names.dart';
import 'package:egy/core/web/web_breakpoints.dart';
import 'package:egy/core/web/web_property_card.dart';
import 'package:egy/core/widgets/skeleton/app_skeleton.dart';
import 'package:egy/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Dedicated responsive Favorites page for Flutter Web.
class WebFavoritesPage extends StatelessWidget {
  const WebFavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      child: WebPageContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WebSectionHeader(
              title: l10n.favorites,
              subtitle: l10n.homeDiscover,
            ),
            const SizedBox(height: 24),
            BlocBuilder<FavoritesCubit, FavoritesState>(
              builder: (context, state) {
                if (state is FavoritesLoading) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final cols = WebBreakpoints.gridColumns(
                        constraints.maxWidth,
                      );
                      return SkeletonShimmer(
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: cols,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: cols,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20,
                                childAspectRatio: 0.92,
                              ),
                          itemBuilder: (_, _) => const SkeletonBox(
                            width: double.infinity,
                            height: 260,
                            radius: 16,
                          ),
                        ),
                      );
                    },
                  );
                }

                if (state is FavoritesError) {
                  return WebSurfaceCard(
                    child: Column(
                      children: [
                        Text(l10n.favoritesUnavailable),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () =>
                              context.read<FavoritesCubit>().reload(),
                          child: Text(l10n.retryButton),
                        ),
                      ],
                    ),
                  );
                }

                final items = (state as FavoritesReady).items;
                if (items.isEmpty) {
                  return WebSurfaceCard(
                    child: Column(
                      children: [
                        Icon(
                          Icons.favorite_border_rounded,
                          size: 44,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.favoritesEmpty,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () =>
                              context.go(RoutePaths.propertyCatalog),
                          child: Text(l10n.homeViewAll),
                        ),
                      ],
                    ),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final cols = WebBreakpoints.gridColumns(
                      constraints.maxWidth,
                    );
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.92,
                      ),
                      itemBuilder: (context, index) =>
                          WebPropertyCard(property: items[index]),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
