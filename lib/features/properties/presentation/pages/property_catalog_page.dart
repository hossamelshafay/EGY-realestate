import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import 'package:egy/app/di/injection.dart';
import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/core/widgets/ai/ai_feedback.dart';
import 'package:egy/core/widgets/ai/ai_labels.dart';
import 'package:egy/core/widgets/authenticated_scaffold.dart';
import 'package:egy/core/widgets/content_fade.dart';

import '../../domain/entities/property_category.dart';
import '../cubit/catalog_cubit.dart';
import '../widgets/listing_card.dart';

/// Bounded, refreshable property list for the category selected on Home.
class PropertyCatalogPage extends StatelessWidget {
  const PropertyCatalogPage({super.key, required this.category});
  final PropertyCategory category;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return BlocProvider(
      key: ValueKey(category),
      create: (_) => CatalogCubit(sl(), category, limit: 15)..refresh(),
      child: AuthenticatedScaffold(
        title: l.homeViewAll,
        subtitle: aiCategoryLabel(l, category.code),
        child: BlocBuilder<CatalogCubit, CatalogState>(
          builder: (context, state) {
            final refresh = context.read<CatalogCubit>().refresh;
            return ContentFade(
              child: KeyedSubtree(
                key: ValueKey(state.runtimeType),
                child: switch (state) {
                  CatalogLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  CatalogError(:final failure) => Center(
                    child: AiFeedback(failure: failure, onRetry: refresh),
                  ),
                  CatalogReady(:final items) => RefreshIndicator(
                    onRefresh: refresh,
                    child: ListView.builder(
                      key: const Key('property_catalog_list'),
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      itemCount: items.isEmpty ? 1 : items.length,
                      itemBuilder: (context, index) => items.isEmpty
                          ? Center(child: Text(l.noResultsFound))
                          : ListingCard(property: items[index]),
                    ),
                  ),
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
