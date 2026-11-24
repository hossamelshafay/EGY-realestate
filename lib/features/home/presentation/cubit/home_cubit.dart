import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:egy/features/properties/domain/entities/property_listing.dart';

sealed class HomeState {
  const HomeState();
}

/// Local refinements of the current featured sample.
final class HomeReady extends HomeState {
  const HomeReady({this.query = '', this.type, this.location});
  final String query;
  final String? type, location;
  (String, String?, String?) get filterKey =>
      (query.trim().toLowerCase(), type, location);

  List<PropertyListing> filter(List<PropertyListing> items) {
    final (text, _, _) = filterKey;
    if (text.isEmpty && type == null && location == null) return items;
    return items.where(matches).toList(growable: false);
  }

  bool matches(PropertyListing item) =>
      (type == null || item.propertyType == type) &&
      (location == null || item.city == location) &&
      '${item.title} ${item.location}'.toLowerCase().contains(filterKey.$1);
}

/// Retains the existing Home search and local filter interactions.
class HomeCubit extends Cubit<HomeReady> {
  HomeCubit() : super(const HomeReady());

  void search(String query) =>
      emit(HomeReady(query: query, type: state.type, location: state.location));

  void filterType(String? type) =>
      emit(HomeReady(query: state.query, type: type, location: state.location));

  void filterLocation(String? location) =>
      emit(HomeReady(query: state.query, type: state.type, location: location));

  void clearFilters() => emit(HomeReady(query: state.query));
}
