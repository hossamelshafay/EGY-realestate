import 'package:egy/app/di/injection.dart';
import 'package:egy/features/home/presentation/cubit/home_cubit.dart';
import 'package:egy/features/properties/domain/entities/property_category.dart';
import 'package:egy/features/properties/domain/entities/property_listing.dart';
import 'package:egy/features/properties/domain/repositories/catalog_repository.dart';

PropertyListing testListing(int id, PropertyCategory category) =>
    PropertyListing(
      id: id,
      title: 'Test listing $id',
      category: category.code,
      propertyType: id.isOdd ? 'Apartment' : 'Villa',
      location: 'New Cairo',
      city: 'Cairo',
      price: 1000000,
      size: 130,
      bedrooms: 3,
      bathrooms: 2,
    );

class TestCatalogRepository implements CatalogRepository {
  final requests = <(PropertyCategory, int, List<int>)>[];

  @override
  Future<List<PropertyListing>> sample(
    PropertyCategory category, {
    required int limit,
    List<int> excluding = const [],
  }) async {
    requests.add((category, limit, List.of(excluding)));
    return Iterable.generate(90, (i) => 1 + category.index * 100 + i)
        .where((id) => !excluding.contains(id))
        .take(limit)
        .map((id) => testListing(id, category))
        .toList();
  }

  @override
  Future<PropertyListing> details(int id) async =>
      testListing(id, PropertyCategory.values[(id - 1) ~/ 100]);
}

TestCatalogRepository registerTestHome() {
  final repository = TestCatalogRepository();
  sl.registerSingleton<CatalogRepository>(repository);
  sl.registerFactory<HomeCubit>(HomeCubit.new);
  return repository;
}
