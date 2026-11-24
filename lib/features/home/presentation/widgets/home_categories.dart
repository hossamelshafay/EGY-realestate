import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/theme/app_colors.dart';
import 'package:egy/features/properties/domain/entities/property_category.dart';
import 'package:egy/features/properties/presentation/cubit/catalog_cubit.dart';

import 'home_palette.dart';

/// Four catalog categories, mirrored by ambient Directionality.
class HomeCategories extends StatelessWidget {
  const HomeCategories({super.key});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final selected = context.select(
      (CatalogCubit cubit) => cubit.state.category,
    );
    final labels = [
      l.homeResidentialSale,
      l.homeResidentialRent,
      l.homeCommercialSale,
      l.homeCommercialRent,
    ];
    final kinds = [
      l.homeResidential,
      l.homeResidential,
      l.homeCommercial,
      l.homeCommercial,
    ];
    final intents = [
      l.homeForSale,
      l.homeForRent,
      l.homeForSale,
      l.homeForRent,
    ];
    const icons = [
      Icons.storefront_outlined,
      Icons.home_outlined,
      Icons.apartment_rounded,
      Icons.business_outlined,
    ];
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 300);
    Widget cards() => LayoutBuilder(
      builder: (context, constraints) {
        final step = (constraints.maxWidth + 8) / 4;
        return Stack(
          children: [
            Positioned.fill(
              child: Row(
                children: [
                  for (var i = 0; i < 4; i++)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(
                          end: i == 3 ? 0 : 8,
                        ),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: HomePalette.fill(context),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            AnimatedPositionedDirectional(
              key: const Key('home_category_highlight'),
              duration: duration,
              curve: Curves.easeInOutCubic,
              start: selected.index * step,
              width: step - 8,
              top: 0,
              bottom: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.primaryGold,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < 4; i++)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(
                          end: i == 3 ? 0 : 8,
                        ),
                        child: Material(
                          key: ValueKey('home_category_$i'),
                          color: AppColors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              if (i == selected.index) return;
                              context.read<CatalogCubit>().select(
                                PropertyCategory.values[i],
                              );
                            },
                            child: Semantics(
                              label: labels[i],
                              excludeSemantics: true,
                              selected: i == selected.index,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 12,
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      icons[i],
                                      size: 28,
                                      color: i == selected.index
                                          ? AppColors.primaryNavy
                                          : AppColors.primaryGold,
                                    ),
                                    const SizedBox(height: 8),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        kinds[i],
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium
                                            ?.copyWith(
                                              color: i == selected.index
                                                  ? AppColors.primaryNavy
                                                  : HomePalette.ink(context),
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        intents[i],
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: i == selected.index
                                                  ? AppColors.primaryNavy
                                                  : HomePalette.ink(context),
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
    if (MediaQuery.textScalerOf(context).scale(12) > 17) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(width: 440, child: cards()),
      );
    }
    return cards();
  }
}
