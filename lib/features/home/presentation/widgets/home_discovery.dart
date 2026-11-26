import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/theme/app_colors.dart';

import '../cubit/home_cubit.dart';
import 'home_categories.dart';
import 'home_filters_sheet.dart';
import 'home_palette.dart';
import 'home_search_route.dart';

/// Search entry point and compact category filters.
class HomeDiscovery extends StatelessWidget {
  const HomeDiscovery({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final query = context.select((HomeCubit cubit) => cubit.state.query);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Builder(
                builder: (anchor) => Material(
                  color: HomePalette.fill(context),
                  borderRadius: BorderRadius.circular(24),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    key: const Key('home_search'),
                    onTap: () => HomeSearchRoute.open(anchor),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 56),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search_rounded,
                              color: AppColors.primaryGold,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                query.isEmpty ? l.homeSearchHint : query,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: HomePalette.ink(context)),
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
            const SizedBox(width: 8),
            SizedBox(
              width: 52,
              height: 56,
              child: IconButton(
                key: const Key('home_filters'),
                tooltip: l.homeFilters,
                style: IconButton.styleFrom(
                  backgroundColor: HomePalette.fill(context),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () => HomeFiltersSheet.show(context),
                icon: const Icon(
                  Icons.filter_alt_outlined,
                  color: AppColors.primaryGold,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const HomeCategories(),
      ],
    );
  }
}
