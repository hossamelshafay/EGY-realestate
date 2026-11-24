import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/theme/app_colors.dart';
import '../cubit/home_cubit.dart';
import 'home_categories.dart';
import 'home_filters_sheet.dart';
import 'home_palette.dart';

/// Rounded search and the reference's four compact category cards.
class HomeDiscovery extends StatelessWidget {
  const HomeDiscovery({super.key});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide.none,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                key: const Key('home_search'),
                onChanged: context.read<HomeCubit>().search,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: HomePalette.ink(context),
                ),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: l.homeSearchHint,
                  hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: HomePalette.muted(context),
                  ),
                  fillColor: HomePalette.fill(context),
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  border: border,
                  enabledBorder: border,
                  focusedBorder: border.copyWith(
                    borderSide: const BorderSide(color: AppColors.primaryGold),
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.primaryGold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
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
