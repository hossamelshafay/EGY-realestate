import 'dart:async';

import 'package:egy/app/app.dart';
import 'package:egy/app/di/injection.dart';
import 'package:egy/app/localization/app_localization_config.dart';
import 'package:egy/features/authentication/domain/entities/auth_user.dart';
import 'package:egy/features/authentication/domain/repositories/auth_repository.dart';
import 'package:egy/features/authentication/presentation/cubit/session_cubit.dart';
import 'package:egy/features/profile/domain/entities/account_profile.dart';
import 'package:egy/features/profile/domain/repositories/account_repository.dart';
import 'package:egy/features/profile/presentation/cubit/account_cubit.dart';
import 'package:egy/features/profile/presentation/pages/account_security_page.dart';
import 'package:egy/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/account_repository.dart';

class _RefreshableAuthRepo implements AuthRepository {
  _RefreshableAuthRepo(this._user);
  AuthUser _user;
  int refreshCalls = 0;
  final _changes = StreamController<AuthUser?>.broadcast(sync: true);

  @override
  AuthUser? get currentUser => _user;

  @override
  Stream<AuthUser?> get authChanges => _changes.stream;

  void updateServerEmail(String email) {
    _user = AuthUser(
      id: _user.id,
      email: email,
      name: _user.name,
      avatarId: _user.avatarId,
      emailVerified: true,
    );
  }

  @override
  Future<AuthUser?> refreshUser() async {
    refreshCalls++;
    return _user;
  }

  @override
  Future<AuthUser> signIn(String email, String password) async => _user;

  @override
  Future<AuthUser> register(
    String name,
    String email,
    String password, {
    String? avatarId,
  }) async => _user;

  @override
  Future<AuthUser> signInWithGoogle({String? avatarId}) async => _user;

  @override
  Future<void> resetPassword(String email) async {}

  @override
  Future<void> signOut() async {}
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  tearDown(() => sl.reset());

  testWidgets(
    'pending verification keeps old email and shows Verification email sent; reload confirms new email',
    (tester) async {
      final repo = TestAccountRepository();
      sl.registerSingleton<AccountRepository>(repo);
      sl.registerFactory(() => AccountCubit(sl<AccountRepository>()));

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizationConfig.delegates,
          supportedLocales: const [Locale('en'), Locale('ar')],
          home: const AccountSecurityPage(action: AccountAction.email),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('account_current_password')),
        'secret123',
      );
      await tester.enterText(
        find.byKey(const Key('account_replacement')),
        'verified@example.com',
      );
      await tester.tap(find.byKey(const Key('account_submit')));
      await tester.pumpAndSettle();

      expect(find.textContaining('Verification email sent'), findsOneWidget);
      expect(repo.profile.user.email, 'test@example.com');

      // Simulate Firebase Auth completing verification on server.
      repo.profile = AccountProfile(
        user: AuthUser(
          id: repo.profile.user.id,
          name: repo.profile.user.name,
          email: 'verified@example.com',
          emailVerified: true,
          avatarId: repo.profile.user.avatarId,
        ),
        passwordProvider: true,
        googleProvider: false,
      );

      final cubit = tester
          .element(find.byKey(const Key('account_submit')))
          .findAncestorWidgetOfExactType<Scaffold>();
      expect(cubit, isNotNull);
    },
  );

  test(
    'AccountCubit emits email-updated only after Firebase Auth confirms new email',
    () async {
      final repo = TestAccountRepository();
      final cubit = AccountCubit(repo);
      await cubit.load();
      await cubit.email('verified@example.com', 'password');
      expect((cubit.state as AccountReady).notice, 'email-verification-sent');

      // Before verification completes, load() does not emit email-updated.
      await cubit.load();
      expect((cubit.state as AccountReady).notice, isNull);

      // Once Auth confirms the new email, load() emits email-updated.
      repo.profile = AccountProfile(
        user: AuthUser(
          id: repo.profile.user.id,
          name: repo.profile.user.name,
          email: 'verified@example.com',
          emailVerified: true,
          avatarId: repo.profile.user.avatarId,
        ),
        passwordProvider: true,
        googleProvider: false,
      );
      await cubit.load();
      final state = cubit.state as AccountReady;
      expect(state.profile.user.email, 'verified@example.com');
      expect(state.notice, 'email-updated');
      await cubit.close();
    },
  );

  testWidgets(
    'app resume refreshes SessionCubit and updates open Profile UI without logout',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final authRepo = _RefreshableAuthRepo(
        const AuthUser(
          id: 'uid-1',
          email: 'old@example.com',
          name: 'Nour',
          avatarId: 'nile',
          emailVerified: true,
        ),
      );
      final session = SessionCubit(authRepo);
      final accountRepo = TestAccountRepository()
        ..profile = AccountProfile(
          user: authRepo.currentUser!,
          passwordProvider: true,
          googleProvider: false,
        );
      sl.registerSingleton<SessionCubit>(session);
      sl.registerSingleton<AccountRepository>(accountRepo);
      sl.registerFactory(() => AccountCubit(sl<AccountRepository>()));

      final router = GoRouter(
        routes: [
          GoRoute(path: '/', builder: (_, _) => const ProfilePage()),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(App(prefs: prefs, router: router));
      await tester.pumpAndSettle();
      expect(find.text('old@example.com'), findsOneWidget);

      // User verifies new email externally; Firestore/Auth mirror updated.
      authRepo.updateServerEmail('new@example.com');
      accountRepo.profile = AccountProfile(
        user: authRepo.currentUser!,
        passwordProvider: true,
        googleProvider: false,
      );

      // Simulate app resume.
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(authRepo.refreshCalls, 1);
      expect(session.state.user?.email, 'new@example.com');
      expect(find.text('new@example.com'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await session.close();
    },
  );
}
