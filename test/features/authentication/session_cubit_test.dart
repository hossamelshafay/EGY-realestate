import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:egy/app/router/route_names.dart';
import 'package:egy/app/router/session_redirect.dart';
import 'package:egy/features/authentication/domain/entities/auth_user.dart';
import 'package:egy/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:egy/features/authentication/presentation/cubit/session_cubit.dart';
import 'package:egy/features/splash/presentation/cubit/splash_cubit.dart';
import '../../support/session_repository.dart';

void main() {
  test(
    'early Firebase event waits for registration profile before redirecting',
    () async {
      final repository = SessionTestRepository()
        ..authenticationGate = Completer<void>();
      final session = SessionCubit(repository);
      final auth = AuthCubit(repository, session: session);
      final pending = auth.register('Nour', 'nour@example.com', 'password');
      expect(session.state.user, isNotNull);
      expect(session.state.authenticating, isTrue);
      expect(sessionRedirect(session.state, RoutePaths.register), isNull);
      repository.authenticationGate!.complete();
      await pending;
      expect(session.state.authenticating, isFalse);
      expect(session.state.user!.name, 'Nour');
      expect(
        sessionRedirect(session.state, RoutePaths.register),
        RoutePaths.home,
      );
      expect(sessionRedirect(session.state, RoutePaths.home), isNull);
      await auth.close();
      await session.close();
      await repository.dispose();
    },
  );
  test(
    'success after multiple failures holds routing until feedback completion',
    () async {
      final repository = SessionTestRepository()..remainingFailures = 2;
      final session = SessionCubit(repository);
      final auth = AuthCubit(repository, session: session)
        ..attachFeedback(true);
      await auth.signIn('nour@example.com', 'wrong');
      expect((auth.state as AuthError).attempt, 1);
      await auth.signIn('nour@example.com', 'wrong-again');
      expect((auth.state as AuthError).attempt, 2);
      await auth.signIn('nour@example.com', 'correct');
      expect(auth.state, isA<AuthSuccess>());
      expect(repository.attempts, 3);
      expect(session.state.authenticating, isFalse);
      expect(session.state.awaitingFeedback, isTrue);
      expect(sessionRedirect(session.state, RoutePaths.login), isNull);
      repository.restore(repository.currentUser);
      expect(session.state.awaitingFeedback, isTrue);
      session.completeFeedback();
      expect(sessionRedirect(session.state, RoutePaths.login), RoutePaths.home);
      await auth.close();
      await session.close();
      await repository.dispose();
    },
  );
  test(
    'guard protects Home and logout failure retains the current user',
    () async {
      final repository = SessionTestRepository(user: const AuthUser(id: '1'))
        ..failLogout = true;
      final session = SessionCubit(repository);
      await session.signOut();
      expect(session.state.error, isTrue);
      expect(session.state.user, isNotNull);
      repository.failLogout = false;
      await session.signOut();
      expect(sessionRedirect(session.state, RoutePaths.home), RoutePaths.login);
      await session.close();
      await repository.dispose();
    },
  );
  test(
    'returning signed-in user bypasses onboarding even without its preference',
    () async {
      SharedPreferences.setMockInitialValues({});
      final repository = SessionTestRepository(user: const AuthUser(id: '1'));
      final splash = SplashCubit(
        await SharedPreferences.getInstance(),
        authRepository: repository,
      );
      splash.onAnimationComplete();
      expect((splash.state as SplashDone).destination, SplashDestination.home);
      await splash.close();
      await repository.dispose();
    },
  );
}
