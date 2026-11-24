import 'package:flutter_test/flutter_test.dart';
import 'package:egy/core/errors/failures.dart';
import 'package:egy/features/authentication/domain/entities/auth_user.dart';
import 'package:egy/features/authentication/domain/repositories/auth_repository.dart';
import 'package:egy/features/authentication/presentation/cubit/auth_cubit.dart';

class FakeAuthRepository implements AuthRepository {
  bool fail = false;
  String? email;
  @override
  AuthUser? get currentUser => null;
  @override
  Stream<AuthUser?> get authChanges => const Stream.empty();
  @override
  Future<AuthUser> signIn(String email, String password) async {
    this.email = email;
    if (fail) throw const AuthFailure('invalid-credential');
    return const AuthUser(id: '1');
  }

  @override
  Future<AuthUser> register(String name, String email, String password) =>
      signIn(email, password);
  @override
  Future<AuthUser> signInWithGoogle() => signIn('', '');
  @override
  Future<void> resetPassword(String email) async {
    this.email = email;
  }

  @override
  Future<void> signOut() async {}
}

void main() {
  test('sign in emits loading and success, trimming email', () async {
    final repository = FakeAuthRepository();
    final cubit = AuthCubit(repository);
    final states = <AuthState>[];
    final subscription = cubit.stream.listen(states.add);
    await cubit.signIn(' user@example.com ', 'password');
    await Future<void>.delayed(Duration.zero);
    expect(states.map((s) => s.runtimeType), [AuthLoading, AuthSuccess]);
    expect(repository.email, 'user@example.com');
    await subscription.cancel();
    await cubit.close();
  });
  test('failure is exposed as an error code', () async {
    final repository = FakeAuthRepository()..fail = true;
    final cubit = AuthCubit(repository);
    await cubit.signIn('user@example.com', 'bad');
    expect((cubit.state as AuthError).code, 'invalid-credential');
    await cubit.close();
  });
  test('reset reports completion', () async {
    final repository = FakeAuthRepository();
    final cubit = AuthCubit(repository);
    await cubit.resetPassword(' user@example.com ');
    expect(cubit.state, isA<AuthResetSent>());
    expect(repository.email, 'user@example.com');
    await cubit.close();
  });
  test('registration completes', () async {
    final cubit = AuthCubit(FakeAuthRepository());
    await cubit.register('Name', 'user@example.com', 'password');
    expect(cubit.state, isA<AuthSuccess>());
    await cubit.close();
  });
}
