import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import 'package:egy/app/di/injection.dart';
import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/core/widgets/authenticated_scaffold.dart';
import 'package:egy/core/widgets/content_fade.dart';
import 'package:egy/features/properties/presentation/widgets/listing_card.dart';

import '../cubit/favorites_cubit.dart';

/// Saved properties follow the current Firebase account across routes.
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cubit = sl<FavoritesCubit>();
    return AuthenticatedScaffold(
      title: l.favorites,
      child: BlocBuilder<FavoritesCubit, FavoritesState>(
        bloc: cubit,
        builder: (context, state) => ContentFade(
          child: KeyedSubtree(
            key: ValueKey((
              state.runtimeType,
              state is FavoritesReady
                  ? state.items.map((item) => item.id).join(',')
                  : null,
            )),
            child: switch (state) {
              FavoritesLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              FavoritesError() => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l.favoritesUnavailable, textAlign: TextAlign.center),
                    TextButton(
                      onPressed: cubit.reload,
                      child: Text(l.retryButton),
                    ),
                  ],
                ),
              ),
              FavoritesReady(:final items) =>
                items.isEmpty
                    ? Center(child: Text(l.favoritesEmpty))
                    : ListView.builder(
                        key: const PageStorageKey('favorites_list'),
                        padding: const EdgeInsets.all(24),
                        itemCount: items.length,
                        itemBuilder: (context, index) =>
                            ListingCard(property: items[index]),
                      ),
            },
          ),
        ),
      ),
    );
  }
}
