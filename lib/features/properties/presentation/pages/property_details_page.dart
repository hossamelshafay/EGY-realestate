import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:egy/app/di/injection.dart';
import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/router/route_names.dart';
import 'package:egy/app/theme/app_colors.dart';
import 'package:egy/core/widgets/ai/ai_feedback.dart';
import 'package:egy/core/widgets/reveal_navigation.dart';
import 'package:egy/core/widgets/skeleton/app_skeleton.dart';
import 'package:egy/features/favorites/presentation/widgets/favorite_button.dart';

import '../../domain/entities/property_listing.dart';
import '../cubit/property_details_cubit.dart';
import '../widgets/property_details_content.dart';
import '../widgets/property_hero.dart';
import '../widgets/property_photo.dart';
import '../widgets/details_entrance.dart';

/// Shows current listing data and keeps an image available throughout loading.
class PropertyDetailsPage extends StatelessWidget {
  const PropertyDetailsPage({super.key, required this.id, this.preview});
  final int id;
  final PropertyPreview? preview;

  @override
  Widget build(BuildContext context) => BlocProvider(
    key: ValueKey(id),
    create: (_) => PropertyDetailsCubit(sl(), id)..load(),
    child: BlocBuilder<PropertyDetailsCubit, PropertyDetailsState>(
      builder: (context, state) {
        final property = switch (state) {
          PropertyDetailsReady(:final property) => property,
          _ => preview?.property,
        };
        final theme = Theme.of(context);
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            backgroundColor: theme.colorScheme.surface,
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 880),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: SizedBox(
                            width: double.infinity,
                            height: (MediaQuery.sizeOf(context).height * .52)
                                .clamp(300.0, 560.0),
                            child: property == null
                                ? const PropertyPhoto()
                                : PropertyHero(
                                    property: property,
                                    tag: preview?.tag,
                                    radius: 0,
                                    curved: true,
                                  ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: SafeArea(
                            top: false,
                            minimum: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (property != null)
                                  DetailsEntrance(
                                    key: ValueKey('details_content_$id'),
                                    child: PropertyDetailsContent(
                                      property: property,
                                    ),
                                  ),
                                if (state is PropertyDetailsLoading)
                                  const SkeletonDetailsBody(),
                                if (state case PropertyDetailsError(
                                  :final failure,
                                ))
                                  AiFeedback(
                                    failure: failure,
                                    onRetry: context
                                        .read<PropertyDetailsCubit>()
                                        .load,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned.fill(
                      bottom: null,
                      child: _DetailsToolbar(property: property),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

class _DetailsToolbar extends StatelessWidget {
  const _DetailsToolbar({required this.property});
  final PropertyListing? property;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primaryNavy.withValues(alpha: .45),
            AppColors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: AppBar(
          primary: false,
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.transparent,
          surfaceTintColor: AppColors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          foregroundColor: AppColors.white,
          leading: Padding(
            padding: const EdgeInsets.all(4),
            child: IconButton.filled(
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primaryNavy.withValues(alpha: .72),
              ),
              tooltip: l.back,
              icon: const BackButtonIcon(),
              onPressed: () {
                final router = GoRouter.maybeOf(context);
                if (router == null) {
                  Navigator.maybePop(context);
                } else if (router.canPop()) {
                  router.pop();
                } else {
                  router.goNamed(RouteNames.home);
                }
              },
            ),
          ),
          actions: [
            if (property case final listing?)
              FavoriteButton(listing, filled: true),
            if (RevealNavigation.availableOf(context))
              IconButton(
                key: const Key('authenticated_reveal'),
                tooltip: l.homeMenu,
                onPressed: () => RevealNavigation.open(context),
                icon: const Icon(Icons.menu_rounded),
              ),
          ],
        ),
      ),
    );
  }
}
