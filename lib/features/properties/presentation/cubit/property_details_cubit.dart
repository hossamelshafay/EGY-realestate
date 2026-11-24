import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:egy/core/errors/failures.dart';

import '../../domain/entities/property_listing.dart';
import '../../domain/repositories/catalog_repository.dart';

sealed class PropertyDetailsState {
  const PropertyDetailsState();
}

final class PropertyDetailsLoading extends PropertyDetailsState {
  const PropertyDetailsLoading();
}

final class PropertyDetailsReady extends PropertyDetailsState {
  const PropertyDetailsReady(this.property);
  final PropertyListing property;
}

final class PropertyDetailsError extends PropertyDetailsState {
  const PropertyDetailsError(this.failure);
  final Failure failure;
}

/// Loads the current catalog facts when a property is opened.
class PropertyDetailsCubit extends Cubit<PropertyDetailsState> {
  PropertyDetailsCubit(this._repository, this.id)
    : super(const PropertyDetailsLoading());

  final CatalogRepository _repository;
  final int id;

  Future<void> load() async {
    emit(const PropertyDetailsLoading());
    try {
      if (id <= 0) throw const ServerFailure('property', statusCode: 404);
      final property = await _repository.details(id);
      if (!isClosed) emit(PropertyDetailsReady(property));
    } on Failure catch (failure) {
      if (!isClosed) emit(PropertyDetailsError(failure));
    }
  }
}
