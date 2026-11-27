import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/core/web/web_breakpoints.dart';
import 'package:egy/core/web/web_property_card.dart';
import 'package:egy/core/widgets/skeleton/app_skeleton.dart';
import 'package:egy/features/recommendations/domain/entities/recommendation_search.dart';
import 'package:egy/features/recommendations/presentation/cubit/recommendations_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// Dedicated responsive AI Recommendations page for Flutter Web.
class WebRecommendationsPage extends StatefulWidget {
  const WebRecommendationsPage({super.key, this.similarTo});

  final int? similarTo;

  @override
  State<WebRecommendationsPage> createState() => _WebRecommendationsPageState();
}

class _WebRecommendationsPageState extends State<WebRecommendationsPage> {
  String _category = 'all';
  final _typeController = TextEditingController();
  final _cityController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();

  @override
  void dispose() {
    _typeController.dispose();
    _cityController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final minPrice = double.tryParse(_minPriceController.text.trim());
    final maxPrice = double.tryParse(_maxPriceController.text.trim());
    final query = RecommendationQuery(
      category: _category,
      propertyType: _typeController.text.trim().isEmpty
          ? 'all'
          : _typeController.text.trim(),
      city: _cityController.text.trim().isEmpty
          ? 'all'
          : _cityController.text.trim(),
      minPrice: minPrice,
      maxPrice: maxPrice,
      limit: 9,
    );
    if (!query.isValid) return;
    context.read<RecommendationsCubit>().search(query);
  }

  void _clearFilters() {
    setState(() {
      _category = 'all';
      _typeController.clear();
      _cityController.clear();
      _minPriceController.clear();
      _maxPriceController.clear();
    });
    context.read<RecommendationsCubit>().search(
      const RecommendationQuery(limit: 9),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 960;

    final filterPanel = WebSurfaceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.homeFilters,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: InputDecoration(labelText: l10n.aiCategory),
            items: [
              DropdownMenuItem(value: 'all', child: Text(l10n.aiAll)),
              DropdownMenuItem(
                value: 'buy',
                child: Text(l10n.homeResidentialSale),
              ),
              DropdownMenuItem(
                value: 'rent',
                child: Text(l10n.homeResidentialRent),
              ),
              DropdownMenuItem(
                value: 'commercial_buy',
                child: Text(l10n.homeCommercialSale),
              ),
              DropdownMenuItem(
                value: 'commercial_rent',
                child: Text(l10n.homeCommercialRent),
              ),
            ],
            onChanged: (v) {
              if (v != null) setState(() => _category = v);
            },
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _typeController,
            decoration: InputDecoration(labelText: l10n.aiTypeOptional),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _cityController,
            decoration: InputDecoration(labelText: l10n.aiCity),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _minPriceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l10n.aiMinimumPrice),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _maxPriceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l10n.aiMaximumPrice),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _applyFilters,
            icon: const Icon(Icons.search_rounded),
            label: Text(l10n.search),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _clearFilters,
            child: Text(l10n.aiReset),
          ),
        ],
      ),
    );

    final resultsPanel =
        BlocBuilder<RecommendationsCubit, RecommendationsState>(
          builder: (context, state) {
            if (state is RecommendationsInitial ||
                state is RecommendationsLoading) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final cols = WebBreakpoints.gridColumns(
                    constraints.maxWidth,
                    expanded: isWide ? 2 : 3,
                  );
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

            if (state is RecommendationsError) {
              return WebSurfaceCard(
                child: Column(
                  children: [
                    Text(l10n.somethingWentWrong),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () {
                        final cubit = context.read<RecommendationsCubit>();
                        if (widget.similarTo != null) {
                          cubit.similar(widget.similarTo!);
                        } else {
                          cubit.search();
                        }
                      },
                      child: Text(l10n.retryButton),
                    ),
                  ],
                ),
              );
            }

            final ready = state as RecommendationsReady;
            if (ready.items.isEmpty) {
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (ready.similar)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: WebSurfaceCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome_outlined, size: 20),
                          const SizedBox(width: 10),
                          Expanded(child: Text(l10n.aiSimilar)),
                          TextButton(
                            onPressed: _clearFilters,
                            child: Text(l10n.aiAll),
                          ),
                        ],
                      ),
                    ),
                  ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final cols = WebBreakpoints.gridColumns(
                      constraints.maxWidth,
                      expanded: isWide ? 2 : 3,
                    );
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: ready.items.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.92,
                      ),
                      itemBuilder: (context, index) =>
                          WebPropertyCard(property: ready.items[index]),
                    );
                  },
                ),
                if (!ready.similar && ready.items.length < ready.total) ...[
                  const SizedBox(height: 24),
                  Center(
                    child: OutlinedButton(
                      onPressed: ready.loadingMore
                          ? null
                          : () => context.read<RecommendationsCubit>().more(),
                      child: ready.loadingMore
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.aiLoadMore),
                    ),
                  ),
                ],
              ],
            );
          },
        );

    return SingleChildScrollView(
      child: WebPageContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WebSectionHeader(
              title: l10n.recommendations,
              subtitle: l10n.aiRecommendationsSubtitle,
            ),
            const SizedBox(height: 24),
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 320, child: filterPanel),
                  const SizedBox(width: 28),
                  Expanded(child: resultsPanel),
                ],
              )
            else ...[
              filterPanel,
              const SizedBox(height: 24),
              resultsPanel,
            ],
          ],
        ),
      ),
    );
  }
}
