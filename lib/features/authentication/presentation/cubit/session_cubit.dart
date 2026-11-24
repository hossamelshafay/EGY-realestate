import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Session state also holds the short auth-operation routing lock.
sealed class SessionState {
  const SessionState({
    this.user,
    this.authenticating = false,
    this.signingOut = false,
    this.awaitingFeedback = false,
    this.error = false,
  });
  final AuthUser? user;
  final bool authenticating;
  final bool signingOut;
  final bool awaitingFeedback;
  final bool error;
}

/// A restored or updated Firebase session mapped through the repository.
final class SessionReady extends SessionState {
  const SessionReady({
    super.user,
    super.authenticating,
    super.signingOut,
    super.awaitingFeedback,
    super.error,
  });
}

/// Shares Firebase session changes with routing and the Home navigation shell.
class SessionCubit extends Cubit<SessionState> {
  SessionCubit(this._repository)
    : super(SessionReady(user: _repository.currentUser)) {
    _subscription = _repository.authChanges.listen(
      (user) {
        emit(
          SessionReady(
            user: user,
            authenticating: state.authenticating,
            signingOut: state.signingOut,
            awaitingFeedback: state.awaitingFeedback,
          ),
        );
      },
      onError: (Object error, StackTrace trace) {
        emit(
          SessionReady(
            user: state.user,
            error: true,
            authenticating: state.authenticating,
            awaitingFeedback: state.awaitingFeedback,
            signingOut: state.signingOut,
          ),
        );
      },
    );
  }
  final AuthRepository _repository;
  late final StreamSubscription<AuthUser?> _subscription;

  /// Prevent early Firebase events from replacing an unfinished sign-in form.
  void beginAuthentication() =>
      emit(SessionReady(user: state.user, authenticating: true));

  /// Refresh displayName after registration has finished updating the profile.
  void finishAuthentication({bool deferNavigation = false}) {
    if (isClosed) return;
    emit(
      SessionReady(
        user: _repository.currentUser,
        awaitingFeedback: deferNavigation && _repository.currentUser != null,
      ),
    );
  }

  /// Release navigation only after the full-screen result has completed.
  void completeFeedback() {
    if (!isClosed) emit(SessionReady(user: _repository.currentUser));
  }

  /// Uses the existing auth repository for both Firebase and Google sign-out.
  Future<void> signOut() async {
    if (state.signingOut) return;
    emit(SessionReady(user: state.user, signingOut: true));
    try {
      await _repository.signOut();
      if (!isClosed) emit(const SessionReady());
    } catch (_) {
      if (!isClosed) {
        emit(SessionReady(user: _repository.currentUser, error: true));
      }
    }
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
