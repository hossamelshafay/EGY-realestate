import 'package:egy/core/errors/failures.dart';
import 'package:egy/core/network/api_result.dart';
import 'package:egy/features/properties/domain/entities/property_listing.dart';
import '../../domain/entities/recommendation_search.dart';
import '../../domain/repositories/recommendation_repository.dart';
import '../datasources/recommendation_remote_datasource.dart';

/// Validates requests and converts API errors into domain failures.
class RecommendationRepositoryImpl implements RecommendationRepository {
  RecommendationRepositoryImpl(this.source);
  final RecommendationRemoteDatasource source;

  @override
  Future<RecommendationSearch> search(RecommendationQuery query) =>
      guardApi(() {
        if (!query.isValid) throw const ServerFailure('input', statusCode: 422);
        return source.search(query);
      });

  @override
  Future<List<PropertyListing>> similar(int propertyId, {int limit = 6}) =>
      guardApi(() {
        if (propertyId <= 0 || limit < 1 || limit > 20) {
          throw const ServerFailure('input', statusCode: 422);
        }
        return source.similar(propertyId, limit);
      });
}
