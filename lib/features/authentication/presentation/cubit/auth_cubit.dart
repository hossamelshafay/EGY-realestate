import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:egy/core/errors/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import 'session_cubit.dart';

sealed class AuthState {
  const AuthState();
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthSuccess extends AuthState {
  const AuthSuccess();
}

final class AuthResetSent extends AuthState {
  const AuthResetSent();
}

final class AuthError extends AuthState {
  const AuthError(this.code, {this.attempt = 1});
  final int attempt;
  final String code;
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this.repository, {this.session}) : super(const AuthInitial());
  final AuthRepository repository;
  final SessionCubit? session;
  int _failures = 0;
  bool _feedbackAttached = false;

  /// A mounted shared shell owns success feedback before routing is released.
  void attachFeedback(bool attached) => _feedbackAttached = attached;
  Future<void> _run(
    Future<void> Function() action, {
    bool reset = false,
  }) async {
    if (state is AuthLoading) return;
    if (!reset) session?.beginAuthentication();
    emit(const AuthLoading());
    var success = false;
    try {
      await action();
      success = !reset;
      if (!isClosed) emit(reset ? const AuthResetSent() : const AuthSuccess());
    } on AuthFailure catch (e) {
      if (!isClosed) {
        emit(
          AuthError(
            e.message,
            attempt: e.message == 'cancelled' || reset ? 0 : ++_failures,
          ),
        );
      }
    } catch (_) {
      if (!isClosed) {
        emit(AuthError('unknown', attempt: reset ? 0 : ++_failures));
      }
    } finally {
      if (!reset) {
        session?.finishAuthentication(
          deferNavigation: success && _feedbackAttached,
        );
      }
    }
  }

  Future<void> signIn(String email, String password) => _run(() async {
    await repository.signIn(email.trim(), password);
  });
  Future<void> register(String name, String email, String password) =>
      _run(() async {
        await repository.register(name.trim(), email.trim(), password);
      });
  Future<void> google() => _run(() async {
    await repository.signInWithGoogle();
  });
  Future<void> resetPassword(String email) =>
      _run(() => repository.resetPassword(email.trim()), reset: true);
}
