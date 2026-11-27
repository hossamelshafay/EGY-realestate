import 'package:egy/app/di/injection.dart';
import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/router/route_names.dart';
import 'package:egy/app/theme/app_colors.dart';
import 'package:egy/core/web/web_breakpoints.dart';
import 'package:egy/core/web/web_property_card.dart';
import 'package:egy/core/widgets/skeleton/app_skeleton.dart';
import 'package:egy/features/authentication/presentation/cubit/session_cubit.dart';
import 'package:egy/features/home/presentation/cubit/home_search_cubit.dart';
import 'package:egy/features/properties/domain/entities/property_category.dart';
import 'package:egy/features/properties/domain/entities/property_listing.dart';
import 'package:egy/features/properties/domain/repositories/catalog_repository.dart';
import 'package:egy/features/properties/presentation/cubit/catalog_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Dedicated responsive desktop Home page for Flutter Web.
class WebHomePage extends StatefulWidget {
  const WebHomePage({
    super.key,
    this.catalogCubit,
    this.searchCubit,
  });

  final CatalogCubit? catalogCubit;
  final HomeSearchCubit? searchCubit;

  @override
  State<WebHomePage> createState() => _WebHomePageState();
}

class _WebHomePageState extends State<WebHomePage> {
  late final CatalogCubit _catalogCubit;
  late final HomeSearchCubit _searchCubit;
  late final bool _ownsCatalog;
  late final bool _ownsSearch;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ownsCatalog = widget.catalogCubit == null;
    _ownsSearch = widget.searchCubit == null;
    _catalogCubit =
        widget.catalogCubit ??
        (CatalogCubit(
          sl<CatalogRepository>(),
          PropertyCategory.residentialSale,
          limit: 6,
        )..refresh());
    _searchCubit = widget.searchCubit ?? sl<HomeSearchCubit>();
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (_ownsCatalog) _catalogCubit.close();
    if (_ownsSearch) _searchCubit.close();
    super.dispose();
  }

  String _categoryLabel(AppLocalizations l10n, PropertyCategory category) =>
      switch (category) {
        PropertyCategory.residentialSale => l10n.homeResidentialSale,
        PropertyCategory.residentialRent => l10n.homeResidentialRent,
        PropertyCategory.commercialSale => l10n.homeCommercialSale,
        PropertyCategory.commercialRent => l10n.homeCommercialRent,
      };

  void _runSearch(List<PropertyListing> sample, PropertyCategory category) {
    final l10n = AppLocalizations.of(context);
    _searchCubit.search(
      text: _searchController.text,
      category: category,
      sample: sample,
      typeLabels: {
        l10n.homeApartment.toLowerCase(): 'Apartment',
        l10n.homeVilla.toLowerCase(): 'Villa',
        l10n.homeStudio.toLowerCase(): 'Studio',
      },
      type: null,
      city: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = context.select<SessionCubit, dynamic>((c) => c.state.user);
    final userName = (user?.name as String?)?.trim();
    final greeting = (userName != null && userName.isNotEmpty)
        ? l10n.homeWelcomeName(userName)
        : l10n.homeWelcome;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _catalogCubit),
        BlocProvider.value(value: _searchCubit),
      ],
      child: SingleChildScrollView(
        child: WebPageContainer(
          child: BlocBuilder<CatalogCubit, CatalogState>(
            builder: (context, catalogState) {
              final sample = catalogState is CatalogReady
                  ? catalogState.items
                  : const <PropertyListing>[];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _WebHeroBanner(
                    greeting: greeting,
                    subtitle: l10n.homeDiscover,
                    controller: _searchController,
                    onSearchChanged: (_) =>
                        _runSearch(sample, catalogState.category),
                    onExploreTap: () => context.go(RoutePaths.propertyCatalog),
                    onAiTap: () => context.go(RoutePaths.recommendations),
                  ),
                  const SizedBox(height: 24),
                  _SearchResultsStrip(
                    query: _searchController.text,
                    onClear: () {
                      _searchController.clear();
                      _runSearch(sample, catalogState.category);
                      setState(() {});
                    },
                  ),
                  WebSectionHeader(
                    title: l10n.homeAiTools,
                    subtitle: l10n.welcomeTagline,
                  ),
                  const SizedBox(height: 16),
                  _AiToolsGrid(),
                  const SizedBox(height: 36),
                  WebSectionHeader(
                    title: l10n.homeFeatured,
                    trailing: TextButton.icon(
                      onPressed: () => context.go(RoutePaths.propertyCatalog),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      label: Text(l10n.homeViewAll),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final cat in PropertyCategory.values)
                        ChoiceChip(
                          label: Text(_categoryLabel(l10n, cat)),
                          selected: catalogState.category == cat,
                          onSelected: (_) => _catalogCubit.select(cat),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _FeaturedGrid(state: catalogState),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _WebHeroBanner extends StatelessWidget {
  const _WebHeroBanner({
    required this.greeting,
    required this.subtitle,
    required this.controller,
    required this.onSearchChanged,
    required this.onExploreTap,
    required this.onAiTap,
  });

  final String greeting;
  final String subtitle;
  final TextEditingController controller;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onExploreTap;
  final VoidCallback onAiTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = WebBreakpoints.isCompact(width);

    return Container(
      padding: EdgeInsets.all(isCompact ? 24 : 40),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppColors.primaryGold,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style:
                (isCompact
                        ? theme.textTheme.headlineSmall
                        : theme.textTheme.headlineMedium)
                    ?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: TextField(
                  controller: controller,
                  onChanged: onSearchChanged,
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: l10n.homeSearchHint,
                    hintStyle: const TextStyle(color: Colors.black54),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.primaryNavy,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: onExploreTap,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  foregroundColor: AppColors.primaryNavy,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                icon: const Icon(Icons.explore_outlined),
                label: Text(l10n.homeViewAll),
              ),
              OutlinedButton.icon(
                onPressed: onAiTap,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                icon: const Icon(Icons.auto_awesome_outlined),
                label: Text(l10n.recommendations),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SearchResultsStrip extends StatelessWidget {
  const _SearchResultsStrip({
    required this.query,
    required this.onClear,
  });

  final String query;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    if (query.trim().isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<HomeSearchCubit, HomeSearchState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WebSectionHeader(
                title: l10n.homeSearchSuggestions,
                trailing: TextButton(
                  onPressed: onClear,
                  child: Text(l10n.close),
                ),
              ),
              const SizedBox(height: 12),
              if (state is HomeSearchLoading && state.items.isEmpty)
                const LinearProgressIndicator()
              else if (state.items.isEmpty)
                WebSurfaceCard(
                  child: Text(l10n.noResultsFound),
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final cols = WebBreakpoints.gridColumns(
                      constraints.maxWidth,
                    );
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.items.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.92,
                      ),
                      itemBuilder: (context, index) =>
                          WebPropertyCard(property: state.items[index]),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class _AiToolsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cards = [
      _AiToolData(
        icon: Icons.auto_awesome_rounded,
        title: l10n.recommendations,
        description: l10n.homeHybridDescription,
        route: RoutePaths.recommendations,
      ),
      _AiToolData(
        icon: Icons.analytics_outlined,
        title: l10n.homePredictorTitle,
        description: l10n.homePriceDescription,
        route: RoutePaths.pricePrediction,
      ),
      _AiToolData(
        icon: Icons.chat_bubble_outline_rounded,
        title: l10n.homeAssistantTitle,
        description: l10n.homeAssistantBannerDescription,
        route: RoutePaths.aiChat,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = WebBreakpoints.gridColumns(constraints.maxWidth);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            mainAxisExtent: 158,
          ),
          itemBuilder: (context, index) {
            final card = cards[index];
            return InkWell(
              onTap: () => context.go(card.route),
              borderRadius: BorderRadius.circular(16),
              child: WebSurfaceCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (Theme.of(context).brightness == Brightness.dark
                                ? AppColors.primaryGold
                                : AppColors.primaryNavy)
                            .withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        card.icon,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.primaryGold
                            : AppColors.primaryNavy,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      card.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        card.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _AiToolData {
  const _AiToolData({
    required this.icon,
    required this.title,
    required this.description,
    required this.route,
  });

  final IconData icon;
  final String title;
  final String description;
  final String route;
}

class _FeaturedGrid extends StatelessWidget {
  const _FeaturedGrid({required this.state});

  final CatalogState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (state is CatalogLoading) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final cols = WebBreakpoints.gridColumns(constraints.maxWidth);
          return SkeletonShimmer(
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cols * 2,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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

    if (state is CatalogError) {
      return WebSurfaceCard(
        child: Column(
          children: [
            Text(l10n.somethingWentWrong),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => context.read<CatalogCubit>().refresh(),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.retryButton),
            ),
          ],
        ),
      );
    }

    final items = (state as CatalogReady).items;
    if (items.isEmpty) {
      return WebSurfaceCard(child: Text(l10n.noResultsFound));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = WebBreakpoints.gridColumns(constraints.maxWidth);
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
  }
}
