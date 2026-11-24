import 'package:egy/features/authentication/presentation/widgets/auth_result_cache.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:egy/app/app.dart';
import 'package:egy/app/di/injection.dart';
import 'package:egy/app/router/app_router.dart';
import 'package:egy/app/router/route_names.dart';
import 'package:egy/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:egy/features/authentication/presentation/cubit/session_cubit.dart';
import 'package:egy/features/authentication/presentation/widgets/auth_action_button.dart';
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
  testWidgets(
    'two failures then success preserve the form, gate navigation and reuse the navy layer',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({});
      final repository = SessionTestRepository()..remainingFailures = 2;
      final session = SessionCubit(repository);
      sl.registerSingleton<SessionCubit>(session);
      sl.registerFactory<AuthCubit>(
        () => AuthCubit(repository, session: session),
      );
      registerTestHome();
      final router = createAppRouter(
        session: session,
        initialLocation: RoutePaths.login,
      );
      await tester.pumpWidget(
        App(prefs: await SharedPreferences.getInstance(), router: router),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('auth_email')),
        'nour@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('auth_password')),
        'preserved-value',
      );
      final emailContext = tester.element(find.byKey(const Key('auth_email')));
      final auth = emailContext.read<AuthCubit>();
      final motion = AuthMotionScope.of(emailContext)!;
      final navy = tester.element(find.byKey(const Key('session_header_clip')));
      final logo = tester.element(find.byKey(const Key('auth_logo')));
      await auth.signIn('nour@example.com', 'wrong');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 521));
      await tester.pump();
      expect(motion.phase, AuthMotionPhase.failureResult);
      await tester.pump();
      expect(
        tester.getSize(find.byKey(const Key('brand_header_geometry'))).height,
        844,
      );
      final failed = tester.widget<Lottie>(
        find.byKey(const Key('assets/lottie/Failed.json')),
      );
      expect(failed.repeat, isFalse);
      expect(failed.controller, same(motion.result));
      expect(
        tester.widget<AuthActionButton>(find.byType(AuthActionButton)).loading,
        isFalse,
      );
      motion.result.value = 1;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 521));
      expect(motion.phase, AuthMotionPhase.idle);
      expect(find.byKey(const Key('auth_inline_error')), findsOneWidget);
      expect(
        tester
            .widget<TextFormField>(find.byKey(const Key('auth_password')))
            .controller!
            .text,
        'preserved-value',
      );
      await auth.signIn('nour@example.com', 'wrong-again');
      await tester.pump();
      expect(motion.shake.isAnimating, isTrue);
      expect(motion.cover.value, 0);
      expect(find.byKey(const Key('assets/lottie/Failed.json')), findsNothing);
      expect(find.byKey(const Key('auth_inline_error')), findsOneWidget);
      await auth.signIn('nour@example.com', 'correct');
      await tester.pump();
      expect(auth.state, isA<AuthSuccess>());
      expect(session.state.awaitingFeedback, isTrue);
      expect(router.routeInformationProvider.value.uri.path, RoutePaths.login);
      await tester.pump(const Duration(milliseconds: 521));
      await tester.pump();
      expect(motion.phase, AuthMotionPhase.successResult);
      await tester.pump();
      final done = tester.widget<Lottie>(
        find.byKey(const Key('assets/lottie/done.json')),
      );
      expect(done.repeat, isFalse);
      expect(done.controller, same(motion.result));
      expect(
        tester.widget<AuthActionButton>(find.byType(AuthActionButton)).loading,
        isFalse,
      );
      expect(
        identical(
          navy,
          tester.element(find.byKey(const Key('session_header_clip'))),
        ),
        isTrue,
      );
      motion.result.value = 1;
      await tester.pump();
      await tester.pump();
      expect(router.routeInformationProvider.value.uri.path, RoutePaths.home);
      expect(motion.cover.value, 1);
      await tester.pump(const Duration(milliseconds: 300));
      expect(motion.home.value, inExclusiveRange(0, 1));
      expect(
        identical(
          navy,
          tester.element(find.byKey(const Key('session_header_clip'))),
        ),
        isTrue,
      );
      expect(
        identical(logo, tester.element(find.byKey(const Key('auth_logo')))),
        isTrue,
      );
      await tester.pumpAndSettle();
      expect(motion.home.value, 1);
      expect(repository.attempts, 3);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      router.dispose();
      await tester.runAsync(() async {
        await session.close();
        await repository.dispose();
      });
    },
  );
}
