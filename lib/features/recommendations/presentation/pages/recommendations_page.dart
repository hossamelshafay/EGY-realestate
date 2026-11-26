import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/router/route_names.dart';
import 'package:egy/app/theme/app_colors.dart';
import 'package:egy/core/widgets/authenticated_scaffold.dart';
import 'package:egy/core/widgets/ai/ai_feedback.dart';
import 'package:egy/core/widgets/content_fade.dart';
import 'package:egy/core/widgets/skeleton/app_skeleton.dart';
import '../cubit/recommendations_cubit.dart';
import 'package:egy/features/properties/presentation/widgets/listing_card.dart';
import '../widgets/recommendation_filters.dart';

/// Search, load-more pagination and similar listings from the real backend.
class RecommendationsPage extends StatelessWidget {
  const RecommendationsPage({super.key, this.similarTo});
  final int? similarTo;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cubit = context.read<RecommendationsCubit>();
    return AuthenticatedScaffold(
      title: similarTo == null ? l.recommendations : l.aiSimilar,
      subtitle: l.aiRecommendationsSubtitle,
      child: RefreshIndicator(
        onRefresh: cubit.retry,
        child: ListView(
          key: const Key('recommendation_list'),
          padding: const EdgeInsets.all(24),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            if (similarTo == null) ...[
              RecommendationFilters(onSearch: cubit.search),
              const SizedBox(height: 24),
            ],
            BlocBuilder<RecommendationsCubit, RecommendationsState>(
              builder: (context, state) => ContentFade(
                child: KeyedSubtree(
                  key: ValueKey(state.runtimeType),
                  child: _results(context, state, cubit),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _results(
    BuildContext context,
    RecommendationsState state,
    RecommendationsCubit cubit,
  ) {
    final l = AppLocalizations.of(context);
    if (state is RecommendationsError) {
      return AiFeedback(failure: state.failure, onRetry: cubit.retry);
    }
    if (state is! RecommendationsReady) {
      return const SkeletonListingList(count: 3);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${l.aiFound}: ${state.total}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        if (state.items.isEmpty) Text(l.noResultsFound),
        for (final property in state.items)
          ContentFadeIn(
            key: ValueKey(property.id),
            child: ListingCard(
              borderGlow: AppColors.white,
              property: property,
              onSimilar: () => context.pushNamed(
                RouteNames.recommendationResults,
                queryParameters: {'similar': '${property.id}'},
              ),
            ),
          ),
        if (state.failure != null)
          AiFeedback(failure: state.failure!, onRetry: cubit.more),
        if (state.loadingMore)
          const SkeletonShimmer(child: SkeletonListingCard())
        else if (!state.similar && state.items.length < state.total)
          TextButton(
            key: const Key('recommendation_more'),
            onPressed: cubit.more,
            child: Text(l.aiLoadMore),
          ),
      ],
    );
  }
}
