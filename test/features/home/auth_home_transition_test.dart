import 'package:egy/features/authentication/presentation/widgets/auth_result_cache.dart';
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:egy/app/app.dart';
import 'package:egy/app/di/injection.dart';
import 'package:egy/app/router/app_router.dart';
import 'package:egy/app/router/route_names.dart';
import 'package:egy/app/router/screen_handoff.dart';
import 'package:egy/app/localization/app_localization_config.dart';
import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/core/widgets/session_page.dart';
import 'package:egy/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:egy/features/authentication/presentation/cubit/session_cubit.dart';
import 'package:egy/features/authentication/presentation/pages/auth_page.dart';
import 'package:egy/features/authentication/presentation/widgets/auth_header.dart';
import 'package:egy/features/authentication/presentation/widgets/asymmetric_auth_clipper.dart';
import 'package:egy/features/authentication/presentation/widgets/auth_motion_scope.dart';
import 'package:egy/features/authentication/presentation/widgets/auth_shell_motion.dart';
import '../../support/catalog_repository.dart';
import '../../support/session_repository.dart';

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await Future.wait([
      AuthResultCache.instance.composition(AuthResultCache.success),
      AuthResultCache.instance.composition(AuthResultCache.failure),
    ]);
  });
  tearDown(() => sl.reset());
  for (final method in ['email', 'register', 'google', 'email_handoff']) {
    testWidgets('$method preserves the logo while header and content morph', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({});
      final repository = SessionTestRepository()
        ..authenticationGate = Completer<void>();
      final session = SessionCubit(repository);
      sl.registerSingleton<SessionCubit>(session);
      sl.registerFactory<AuthCubit>(
        () => AuthCubit(repository, session: session),
      );
      registerTestHome();
      final path = method == 'register'
          ? RoutePaths.register
          : RoutePaths.login;
      final router = createAppRouter(
        session: session,
        initialLocation: method == 'email_handoff'
            ? RoutePaths.onboarding
            : path,
      );
      await tester.pumpWidget(
        App(prefs: await SharedPreferences.getInstance(), router: router),
      );
      await tester.pumpAndSettle();
      final previousHandoff = method == 'email_handoff'
          ? (ScreenHandoff()..value = 1)
          : null;
      if (previousHandoff != null) {
        router.pushNamed<void>(RouteNames.login, extra: previousHandoff);
        await tester.pumpAndSettle();
      }
      final logo = tester.element(find.byKey(const Key('auth_logo')));
      final auth = tester
          .element(find.byKey(const Key('auth_email')))
          .read<AuthCubit>();
      final operation = method.startsWith('email')
          ? auth.signIn('nour@example.com', 'password')
          : method == 'register'
          ? auth.register('Nour', 'nour@example.com', 'password')
          : auth.google();
      await tester.pump();
      expect(router.state.uri.path, path);
      repository.authenticationGate!.complete();
      await operation;
      await tester.pump();
      expect(router.state.uri.path, path);
      expect(session.state.awaitingFeedback, isTrue);
      final motion = AuthMotionScope.of(
        tester.element(find.byKey(const Key('auth_email'))),
      )!;
      expect(find.byKey(const Key('assets/lottie/done.json')), findsNothing);
      await tester.pump(const Duration(milliseconds: 521));
      await tester.pump();
      expect(motion.phase, AuthMotionPhase.successResult);
      await tester.pump();
      expect(
        tester.getSize(find.byKey(const Key('brand_header_geometry'))).height,
        844,
      );
      expect(find.byKey(const Key('assets/lottie/done.json')), findsOneWidget);
      expect(router.state.uri.path, path);
      expect(motion.result.isAnimating, isTrue);
      await tester.pump(); // Establish the result ticker's first timestamp.
      final playback = motion.result.duration!;
      const lastFrame = Duration(milliseconds: 1);
      await tester.pump(playback - lastFrame);
      expect(router.state.uri.path, path);
      expect(session.state.awaitingFeedback, isTrue);
      await tester.pump(lastFrame * 2);
      await tester.pump();
      await tester.pump();
      expect(router.state.uri.path, RoutePaths.home);
      double shape() =>
          (tester
                      .widget<ClipPath>(
                        find.byKey(const Key('session_header_clip')),
                      )
                      .clipper!
                  as AsymmetricAuthClipper)
              .home;
      expect(shape(), 0);
      expect(
        tester
            .widget<Opacity>(find.byKey(const ValueKey('home_stage_0')))
            .opacity,
        0,
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(shape(), inExclusiveRange(0, 1));
      expect(find.byType(AuthPage, skipOffstage: false), findsOneWidget);
      expect(find.byKey(const Key('auth_form_motion')), findsNothing);
      expect(
        tester
            .widget<Opacity>(
              find.byKey(const Key('auth_form_motion'), skipOffstage: false),
            )
            .opacity,
        0,
      );
      expect(
        tester
            .widget<Opacity>(find.byKey(const ValueKey('home_stage_0')))
            .opacity,
        greaterThan(0),
      );
      expect(
        identical(logo, tester.element(find.byKey(const Key('auth_logo')))),
        isTrue,
      );
      await tester.pumpAndSettle();
      expect(shape(), 1);
      expect(find.byType(AuthPage, skipOffstage: false), findsNothing);
      expect(
        identical(logo, tester.element(find.byKey(const Key('auth_logo')))),
        isTrue,
      );
      repository.restore(repository.currentUser);
      await tester.pump(const Duration(milliseconds: 100));
      expect(shape(), 1);
      expect(find.byKey(const Key('home_search')), findsOneWidget);
      await session.signOut();
      await tester.pumpAndSettle();
      expect(router.state.uri.path, RoutePaths.login);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      router.dispose();
      await tester.runAsync(() async {
        await session.close();
        await repository.dispose();
      });
      previousHandoff?.dispose();
    });
  }
  testWidgets(
    'reduced motion settles the persistent shell without replaying the logo',
    (tester) async {
      final repository = SessionTestRepository();
      sl.registerFactory<AuthCubit>(() => AuthCubit(repository));
      registerTestHome();
      Widget scene(bool home) => MaterialApp(
        localizationsDelegates: AppLocalizationConfig.delegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: SessionPage(authMode: home ? null : AuthPageMode.login),
        ),
      );
      await tester.pumpWidget(scene(false));
      await tester.pumpAndSettle();
      final logo = tester.element(find.byKey(const Key('auth_logo')));
      await tester.pumpWidget(scene(true));
      await tester.pumpAndSettle();
      final clip = tester.widget<ClipPath>(
        find.byKey(const Key('session_header_clip')),
      );
      expect((clip.clipper! as AsymmetricAuthClipper).home, 1);
      expect(
        identical(logo, tester.element(find.byKey(const Key('auth_logo')))),
        isTrue,
      );
      expect(tester.hasRunningAnimations, isFalse);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await repository.dispose();
    },
  );
  test('corner geometry is continuous from concave through flat to convex', () {
    const size = Size(360, 240);
    final concave = const BrandHeaderClipper(32, morph: 0).getClip(size);
    final middle = const BrandHeaderClipper(32, morph: .5).getClip(size);
    final convex = const BrandHeaderClipper(32, morph: 1).getClip(size);
    expect(concave.contains(const Offset(180, 230)), isFalse);
    expect(concave.contains(const Offset(359, 220)), isTrue);
    expect(middle.contains(const Offset(180, 223)), isTrue);
    expect(middle.contains(const Offset(359, 223)), isTrue);
    expect(convex.contains(const Offset(180, 230)), isTrue);
    expect(convex.contains(const Offset(359, 230)), isFalse);
  });
}
