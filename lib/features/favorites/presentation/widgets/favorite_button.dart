import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import 'package:egy/app/di/injection.dart';
import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/theme/app_colors.dart';
import 'package:egy/features/properties/domain/entities/property_listing.dart';

import '../cubit/favorites_cubit.dart';

/// A shared toggle that listens to the same saved IDs on every listing screen.
class FavoriteButton extends StatelessWidget {
  const FavoriteButton(this.property, {super.key, this.filled = false});

  final PropertyListing property;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (!sl.isRegistered<FavoritesCubit>()) return const SizedBox.shrink();
    final cubit = sl<FavoritesCubit>();
    return BlocSelector<FavoritesCubit, FavoritesState, (bool, bool)>(
      bloc: cubit,
      selector: (state) => (
        state is FavoritesReady,
        state is FavoritesReady && state.ids.contains(property.id),
      ),
      builder: (context, value) {
        final (ready, saved) = value;
        final icon = Icon(
          saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        );
        final tooltip = saved ? l.homeUnsave : l.homeSave;
        Future<void> toggle() async {
          final error = await cubit.toggle(property);
          if (error != null && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l.favoritesUnavailable),
                action: SnackBarAction(
                  label: l.retryButton,
                  onPressed: cubit.reload,
                ),
              ),
            );
          }
        }

        final key = ValueKey('favorite_${property.id}');
        return filled
            ? IconButton.filled(
                key: key,
                tooltip: tooltip,
                onPressed: ready ? toggle : null,
                icon: icon,
                isSelected: saved,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.primaryNavy,
                ),
              )
            : IconButton(
                key: key,
                tooltip: tooltip,
                onPressed: ready ? toggle : null,
                icon: icon,
                isSelected: saved,
              );
      },
    );
  }
}
