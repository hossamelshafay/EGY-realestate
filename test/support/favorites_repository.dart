import 'dart:async';

import 'package:egy/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:egy/features/properties/domain/entities/property_listing.dart';

class TestFavoritesRepository implements FavoritesRepository {
  final _records = <String, Map<int, PropertyListing>>{};
  final _changes = StreamController<String>.broadcast(sync: true);

  List<PropertyListing> _forUser(String uid) =>
      _records[uid]?.values.toList() ?? [];

  @override
  Stream<List<PropertyListing>> watch(String uid) => Stream.multi((listener) {
    final changes = _changes.stream
        .where((value) => value == uid)
        .listen(
          (_) => listener.addSync(_forUser(uid)),
          onDone: listener.closeSync,
        );
    listener.onCancel = changes.cancel;
    listener.add(_forUser(uid));
  });

  @override
  Future<void> save(String uid, PropertyListing property) async {
    _records.putIfAbsent(uid, () => {})[property.id] = property;
    _changes.add(uid);
  }

  @override
  Future<void> remove(String uid, int propertyId) async {
    _records[uid]?.remove(propertyId);
    _changes.add(uid);
  }

  Future<void> close() => _changes.close();
}
