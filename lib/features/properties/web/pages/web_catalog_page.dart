import 'package:egy/app/di/injection.dart';
import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/core/web/web_breakpoints.dart';
import 'package:egy/core/web/web_property_card.dart';
import 'package:egy/core/widgets/skeleton/app_skeleton.dart';
import 'package:egy/features/home/presentation/cubit/home_cubit.dart';
import 'package:egy/features/properties/domain/entities/property_category.dart';
import 'package:egy/features/properties/domain/repositories/catalog_repository.dart';
import 'package:egy/features/properties/presentation/cubit/catalog_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// Dedicated responsive Property Catalog & Explorer page for Flutter Web.
class WebCatalogPage extends StatefulWidget {
  const WebCatalogPage({
    super.key,
    this.catalogCubit,
    this.homeCubit,
    this.initialCategory = PropertyCategory.residentialSale,
  });

  final CatalogCubit? catalogCubit;
  final HomeCubit? homeCubit;
  final PropertyCategory initialCategory;

  @override
  State<WebCatalogPage> createState() => _WebCatalogPageState();
}

class _WebCatalogPageState extends State<WebCatalogPage> {
  late final CatalogCubit _catalogCubit;
  late final HomeCubit _homeCubit;
  late final bool _ownsCatalog;
  late final bool _ownsHome;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ownsCatalog = widget.catalogCubit == null;
    _ownsHome = widget.homeCubit == null;
    _catalogCubit =
        widget.catalogCubit ??
        (CatalogCubit(
          sl<CatalogRepository>(),
          widget.initialCategory,
          limit: 12,
        )..refresh());
    _homeCubit = widget.homeCubit ?? sl<HomeCubit>();
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (_ownsCatalog) _catalogCubit.close();
    if (_ownsHome) _homeCubit.close();
    super.dispose();
  }

  String _categoryLabel(AppLocalizations l10n, PropertyCategory category) =>
      switch (category) {
        PropertyCategory.residentialSale => l10n.homeResidentialSale,
        PropertyCategory.residentialRent => l10n.homeResidentialRent,
        PropertyCategory.commercialSale => l10n.homeCommercialSale,
        PropertyCategory.commercialRent => l10n.homeCommercialRent,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _catalogCubit),
        BlocProvider.value(value: _homeCubit),
      ],
      child: SingleChildScrollView(
        child: WebPageContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WebSectionHeader(
                title: l10n.homeFeatured,
                subtitle: l10n.homeDiscover,
                trailing: OutlinedButton.icon(
                  onPressed: () => _catalogCubit.refresh(),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(l10n.retryButton),
                ),
              ),
              const SizedBox(height: 20),
              WebSurfaceCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: _homeCubit.search,
                            decoration: InputDecoration(
                              hintText: l10n.homeSearchHint,
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded),
                                      onPressed: () {
                                        _searchController.clear();
                                        _homeCubit.search('');
                                        setState(() {});
                                      },
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    BlocBuilder<CatalogCubit, CatalogState>(
                      builder: (context, catState) => Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final category in PropertyCategory.values)
                            ChoiceChip(
                              label: Text(_categoryLabel(l10n, category)),
                              selected: catState.category == category,
                              onSelected: (_) => _catalogCubit.select(category),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              BlocBuilder<CatalogCubit, CatalogState>(
                builder: (context, catState) {
                  if (catState is CatalogLoading) {
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final cols = WebBreakpoints.gridColumns(
                          constraints.maxWidth,
                        );
                        return SkeletonShimmer(
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: cols * 2,
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
                  if (catState is CatalogError) {
                    return WebSurfaceCard(
                      child: Column(
                        children: [
                          Text(l10n.somethingWentWrong),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: () => _catalogCubit.refresh(),
                            child: Text(l10n.retryButton),
                          ),
                        ],
                      ),
                    );
                  }

                  final ready = catState as CatalogReady;
                  return BlocBuilder<HomeCubit, HomeReady>(
                    builder: (context, filterState) {
                      final filtered = filterState.filter(ready.items);
                      if (filtered.isEmpty) {
                        return WebSurfaceCard(
                          child: Column(
                            children: [
                              Text(l10n.noResultsFound),
                              const SizedBox(height: 6),
                              Text(l10n.noResultsFoundSubtitle),
                            ],
                          ),
                        );
                      }
                      return Column(
                        children: [
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final cols = WebBreakpoints.gridColumns(
                                constraints.maxWidth,
                              );
                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filtered.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: cols,
                                      crossAxisSpacing: 20,
                                      mainAxisSpacing: 20,
                                      childAspectRatio: 0.92,
                                    ),
                                itemBuilder: (context, index) =>
                                    WebPropertyCard(property: filtered[index]),
                              );
                            },
                          ),
                          if (!ready.exhausted) ...[
                            const SizedBox(height: 24),
                            OutlinedButton(
                              onPressed: () =>
                                  _catalogCubit.prefetch(filterState.matches),
                              child: Text(l10n.aiLoadMore),
                            ),
                          ],
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
