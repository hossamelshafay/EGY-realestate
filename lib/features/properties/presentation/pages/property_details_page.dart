import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:egy/app/di/injection.dart';
import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/router/route_names.dart';
import 'package:egy/core/widgets/ai/ai_feedback.dart';
import 'package:egy/core/widgets/authenticated_scaffold.dart';
import 'package:egy/core/widgets/content_fade.dart';

import '../cubit/property_details_cubit.dart';
import '../widgets/listing_card.dart';

/// Displays current listing data and a synchronized favorite control.
class PropertyDetailsPage extends StatelessWidget {
  const PropertyDetailsPage({super.key, required this.id});
  final int id;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return BlocProvider(
      key: ValueKey(id),
      create: (_) => PropertyDetailsCubit(sl(), id)..load(),
      child: AuthenticatedScaffold(
        title: l.propertyDetails,
        child: BlocBuilder<PropertyDetailsCubit, PropertyDetailsState>(
          builder: (context, state) => ContentFade(
            child: KeyedSubtree(
              key: ValueKey(state.runtimeType),
              child: switch (state) {
                PropertyDetailsLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                PropertyDetailsError(:final failure) => Center(
                  child: AiFeedback(
                    failure: failure,
                    onRetry: context.read<PropertyDetailsCubit>().load,
                  ),
                ),
                PropertyDetailsReady(:final property) => ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    ListingCard(
                      property: property,
                      showDetails: false,
                      onSimilar: () => context.pushNamed(
                        RouteNames.recommendationResults,
                        queryParameters: {'similar': '${property.id}'},
                      ),
                    ),
                  ],
                ),
              },
            ),
          ),
        ),
      ),
    );
  }
}
