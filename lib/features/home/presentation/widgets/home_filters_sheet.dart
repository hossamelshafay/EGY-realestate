import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/features/properties/domain/entities/property_listing.dart';
import 'package:egy/features/properties/presentation/cubit/catalog_cubit.dart';
import 'package:egy/features/properties/presentation/property_type_label.dart';
import '../cubit/home_cubit.dart';
import 'home_palette.dart';

/// Refines the currently loaded featured sample.
abstract final class HomeFiltersSheet {
  static void show(BuildContext context) {
    final cubit = context.read<HomeCubit>();
    final catalog = context.read<CatalogCubit>().state;
    final items = catalog is CatalogReady
        ? catalog.items
        : const <PropertyListing>[];
    final types = {
      ...items.map((item) => item.propertyType),
      ?cubit.state.type,
    }.toList()..sort();
    final cities = {
      ...items.map((item) => item.city).whereType<String>(),
      ?cubit.state.location,
    }.toList()..sort();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: HomePalette.surface(context),
      isScrollControlled: true,
      builder: (context) =>
          BlocProvider.value(value: cubit, child: _Filters(types, cities)),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters(this.types, this.cities);
  final List<String> types, cities;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: BlocBuilder<HomeCubit, HomeReady>(
            builder: (context, state) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l.homeFilters,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: HomePalette.ink(context),
                  ),
                ),
                const SizedBox(height: 16),
                Text(l.homePropertyType),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text(l.homeAll),
                      selected: state.type == null,
                      onSelected: (_) =>
                          context.read<HomeCubit>().filterType(null),
                    ),
                    for (final type in types)
                      ChoiceChip(
                        label: Text(propertyTypeLabel(l, type)),
                        selected: state.type == type,
                        onSelected: (value) => context
                            .read<HomeCubit>()
                            .filterType(value ? type : null),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  key: ValueKey(state.location),
                  initialValue: cities.contains(state.location)
                      ? state.location
                      : null,
                  isExpanded: true,
                  dropdownColor: HomePalette.surface(context),
                  decoration: InputDecoration(labelText: l.homeLocation),
                  hint: Text(l.homeAllLocations),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(l.homeAllLocations),
                    ),
                    for (final location in cities)
                      DropdownMenuItem(value: location, child: Text(location)),
                  ],
                  onChanged: context.read<HomeCubit>().filterLocation,
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l.close),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
