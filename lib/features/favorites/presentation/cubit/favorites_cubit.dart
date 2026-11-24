import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:egy/core/errors/failures.dart';
import 'package:egy/features/authentication/presentation/cubit/session_cubit.dart';
import 'package:egy/features/properties/domain/entities/property_listing.dart';

import '../../domain/repositories/favorites_repository.dart';

sealed class FavoritesState {
  const FavoritesState(this.uid);
  final String? uid;
}

final class FavoritesLoading extends FavoritesState {
  const FavoritesLoading(super.uid);
}

final class FavoritesError extends FavoritesState {
  const FavoritesError(super.uid, this.failure);
  final Failure failure;
}

final class FavoritesReady extends FavoritesState {
  FavoritesReady(super.uid, List<PropertyListing> items)
    : items = List.unmodifiable(items),
      ids = Set.unmodifiable(items.map((item) => item.id));

  final List<PropertyListing> items;
  final Set<int> ids;
}

/// One app-wide view of the current user's favorites; stale events are ignored.
class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit(this._repository, this._session)
    : super(const FavoritesLoading(null)) {
    _auth = _session.stream.listen((session) {
      if (session.user?.id != state.uid) reload();
    });
    reload();
  }

  final FavoritesRepository _repository;
  final SessionCubit _session;
  late final StreamSubscription<SessionState> _auth;
  StreamSubscription<List<PropertyListing>>? _items;
  final _pending = <int>{};
  int _revision = 0;

  void reload() {
    final revision = ++_revision;
    final uid = _session.state.user?.id;
    unawaited(_items?.cancel());
    _items = null;
    _pending.clear();
    if (uid == null) {
      emit(const FavoritesLoading(null));
      return;
    }
    emit(FavoritesLoading(uid));
    _items = _repository
        .watch(uid)
        .listen(
          (items) {
            if (!isClosed && _revision == revision) {
              emit(FavoritesReady(uid, items));
            }
          },
          onError: (Object error) {
            if (!isClosed && _revision == revision) {
              emit(
                FavoritesError(
                  uid,
                  error is Failure ? error : const ServerFailure('favorites'),
                ),
              );
            }
          },
        );
  }

  Future<Failure?> toggle(PropertyListing item) async {
    final current = state;
    final uid = _session.state.user?.id;
    if (current is! FavoritesReady || uid == null || uid != current.uid) {
      return const ServerFailure('favorites');
    }
    if (!_pending.add(item.id)) return null;
    final revision = _revision;
    try {
      if (current.ids.contains(item.id)) {
        await _repository.remove(uid, item.id);
      } else {
        await _repository.save(uid, item);
      }
      return null;
    } on Failure catch (failure) {
      return revision == _revision ? failure : null;
    } finally {
      if (revision == _revision) _pending.remove(item.id);
    }
  }

  @override
  Future<void> close() async {
    await _auth.cancel();
    await _items?.cancel();
    await super.close();
  }
}
