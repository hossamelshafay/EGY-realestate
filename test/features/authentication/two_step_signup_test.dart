import 'dart:async';

import 'package:egy/app/di/injection.dart';
import 'package:egy/app/localization/app_localization_config.dart';
import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/router/route_names.dart';
import 'package:egy/app/theme/app_theme.dart';
import 'package:egy/core/errors/failures.dart';
import 'package:egy/features/authentication/domain/entities/auth_user.dart';
import 'package:egy/features/authentication/domain/repositories/auth_repository.dart';
import 'package:egy/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:egy/features/authentication/presentation/pages/auth_page.dart';
import 'package:egy/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

class _RecordingRegisterRepo implements AuthRepository {
  int registerCalls = 0;
  String? lastName;
  String? lastEmail;
  String? lastAvatarId;
  String? errorCode;
  Completer<void>? gate;

  @override
  AuthUser? get currentUser => null;
  @override
  Stream<AuthUser?> get authChanges => const Stream.empty();
  @override
  Future<AuthUser?> refreshUser() async => null;
  @override
  Future<AuthUser> signIn(String email, String password) async =>
      const AuthUser(id: 'u1');
  @override
  Future<AuthUser> register(
    String name,
    String email,
    String password, {
    String? avatarId,
  }) async {
    registerCalls++;
    lastName = name;
    lastEmail = email;
    lastAvatarId = avatarId;
    if (gate != null) await gate!.future;
    if (errorCode != null) throw AuthFailure(errorCode!);
    return AuthUser(id: 'u1', name: name, email: email, avatarId: avatarId);
  }

  @override
  Future<AuthUser> signInWithGoogle({String? avatarId}) async =>
      const AuthUser(id: 'u1');
  @override
  Future<void> resetPassword(String email) async {}
  @override
  Future<void> signOut() async {}
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  tearDown(() => sl.reset());

  Widget buildApp({
    required _RecordingRegisterRepo repo,
    bool dark = false,
    Locale locale = const Locale('en'),
  }) {
    sl.registerFactory<AuthCubit>(() => AuthCubit(repo));
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const AuthPage(mode: AuthPageMode.register),
        ),
        GoRoute(
          name: RouteNames.home,
          path: RoutePaths.home,
          builder: (_, _) => const SizedBox.shrink(),
        ),
      ],
    );
    return MaterialApp.router(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      locale: locale,
      localizationsDelegates: AppLocalizationConfig.delegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }

  testWidgets(
    'Step 1 validates, preserves data on Back, and registers on Step 2 with selected avatar',
    (tester) async {
      tester.view.physicalSize = const Size(420, 1050);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repo = _RecordingRegisterRepo();
      await tester.pumpWidget(buildApp(repo: repo));
      await tester.pumpAndSettle();

      // Step 1 has no avatar picker and shows Continue.
      expect(find.byKey(const Key('signup_step_2')), findsNothing);
      expect(find.text('Continue'), findsOneWidget);

      // Invalid submission stays on Step 1 and does not call register.
      await tester.ensureVisible(find.byKey(const Key('auth_submit')));
      await tester.tap(find.byKey(const Key('auth_submit')));
      await tester.pump();
      expect(find.byKey(const Key('signup_step_2')), findsNothing);
      expect(repo.registerCalls, 0);

      // Fill valid Step 1 fields and tap Continue.
      await tester.enterText(find.byKey(const Key('auth_name')), 'Noura Ali');
      await tester.enterText(
        find.byKey(const Key('auth_email')),
        'noura@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('auth_password')),
        'secret123',
      );
      await tester.enterText(
        find.byKey(const Key('auth_confirm_password')),
        'secret123',
      );
      await tester.ensureVisible(find.byKey(const Key('auth_submit')));
      await tester.tap(find.byKey(const Key('auth_submit')));
      await tester.pumpAndSettle();

      // Now on Step 2; still 0 register calls.
      expect(find.byKey(const Key('signup_step_2')), findsOneWidget);
      expect(find.text('Step 2 of 2'), findsOneWidget);
      expect(find.text('Choose Your Avatar'), findsOneWidget);
      expect(repo.registerCalls, 0);

      // Select avatar and verify large preview updates.
      await tester.ensureVisible(find.byKey(const ValueKey('avatar_yasmin')));
      await tester.tap(find.byKey(const ValueKey('avatar_yasmin')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<ProfileAvatar>(find.byKey(const ValueKey('preview_yasmin')))
            .avatarId,
        'yasmin',
      );

      // Go back to Step 1 -> entered fields preserved -> forward to Step 2.
      await tester.ensureVisible(find.byKey(const Key('signup_back')));
      await tester.tap(find.byKey(const Key('signup_back')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('signup_step_2')), findsNothing);
      expect(
        tester
            .widget<TextFormField>(find.byKey(const Key('auth_name')))
            .controller!
            .text,
        'Noura Ali',
      );
      await tester.ensureVisible(find.byKey(const Key('auth_submit')));
      await tester.tap(find.byKey(const Key('auth_submit')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('signup_step_2')), findsOneWidget);

      // Tap Create Account -> register called with selected avatar.
      await tester.ensureVisible(find.byKey(const Key('auth_submit')));
      await tester.tap(find.byKey(const Key('auth_submit')));
      await tester.pumpAndSettle();
      expect(repo.registerCalls, 1);
      expect(repo.lastName, 'Noura Ali');
      expect(repo.lastEmail, 'noura@example.com');
      expect(repo.lastAvatarId, 'yasmin');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('duplicate email error and dark Arabic RTL render cleanly', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(420, 1050);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repo = _RecordingRegisterRepo()..errorCode = 'email-already-in-use';
    await tester.pumpWidget(
      buildApp(repo: repo, dark: true, locale: const Locale('ar')),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('auth_name')), 'نورا');
    await tester.enterText(
      find.byKey(const Key('auth_email')),
      'dup@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('auth_password')),
      'secret123',
    );
    await tester.enterText(
      find.byKey(const Key('auth_confirm_password')),
      'secret123',
    );
    await tester.ensureVisible(find.byKey(const Key('auth_submit')));
    await tester.tap(find.byKey(const Key('auth_submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('signup_step_2')), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('auth_submit')));
    await tester.tap(find.byKey(const Key('auth_submit')));
    await tester.pumpAndSettle();

    expect(repo.registerCalls, 1);
    expect(tester.takeException(), isNull);
  });
}
