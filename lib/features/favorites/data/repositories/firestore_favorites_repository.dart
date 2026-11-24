import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:egy/core/errors/failures.dart';
import 'package:egy/features/properties/data/models/property_listing_model.dart';
import 'package:egy/features/properties/domain/entities/property_listing.dart';

import '../../domain/repositories/favorites_repository.dart';

/// Stores user-owned listing snapshots for offline reads without catalog calls.
class FirestoreFavoritesRepository implements FavoritesRepository {
  FirestoreFavoritesRepository(this._firestore, this._auth);
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, Object?>> _collection(String uid) {
    if (_auth.currentUser?.uid != uid) throw const UnauthenticatedFailure();
    return _firestore.collection('users').doc(uid).collection('favorites');
  }

  @override
  Stream<List<PropertyListing>> watch(String uid) async* {
    try {
      await for (final snapshot in _collection(
        uid,
      ).orderBy('addedAt', descending: true).snapshots()) {
        if (_auth.currentUser?.uid != uid) return;
        yield List.unmodifiable(
          snapshot.docs.map((doc) {
            final data = doc.data();
            final raw = PropertyListingModel.decode(
              data['propertySnapshot'],
              allowMissing: true,
            );
            if (data['propertyId'] != raw.id || doc.id != '${raw.id}') {
              throw const FormatException('Invalid favorite ID');
            }
            return raw;
          }),
        );
      }
    } on Failure {
      rethrow;
    } catch (_) {
      throw const ServerFailure('favorites');
    }
  }

  @override
  Future<void> save(String uid, PropertyListing property) async {
    try {
      final doc = _collection(uid).doc('${property.id}');
      await _firestore.runTransaction((transaction) async {
        if (_auth.currentUser?.uid != uid) throw const UnauthenticatedFailure();
        if ((await transaction.get(doc)).exists) return;
        transaction.set(doc, {
          'propertyId': property.id,
          'addedAt': FieldValue.serverTimestamp(),
          'propertySnapshot': PropertyListingModel.encode(property),
        });
      });
    } on Failure {
      rethrow;
    } catch (_) {
      throw const ServerFailure('favorites');
    }
  }

  @override
  Future<void> remove(String uid, int propertyId) async {
    try {
      await _collection(uid).doc('$propertyId').delete();
    } on Failure {
      rethrow;
    } catch (_) {
      throw const ServerFailure('favorites');
    }
  }
}
