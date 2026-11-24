import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

import 'package:egy/app/di/injection.dart';
import 'package:egy/app/localization/app_localization_config.dart';
import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/theme/app_theme.dart';
import 'package:egy/core/widgets/session_page.dart';
import 'package:egy/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:egy/features/authentication/presentation/pages/auth_page.dart';
import 'package:egy/features/authentication/presentation/widgets/asymmetric_auth_clipper.dart';
import 'package:egy/features/authentication/presentation/widgets/auth_motion_scope.dart';
import 'package:egy/features/authentication/presentation/widgets/auth_shell_motion.dart';
import '../../support/catalog_repository.dart';
import 'auth_cubit_test.dart' show FakeAuthRepository;

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  setUp(() {
    sl.registerFactory<AuthCubit>(() => AuthCubit(FakeAuthRepository()));
    registerTestHome();
  });
  tearDown(() => sl.reset());

  Widget scene({String code = 'en', AuthPageMode? mode, double keyboard = 0}) =>
      MaterialApp(
        theme: AppTheme.light,
        locale: Locale(code),
        localizationsDelegates: AppLocalizationConfig.delegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(viewInsets: EdgeInsets.only(bottom: keyboard)),
          child: child!,
        ),
        home: SessionPage(authMode: mode),
      );

  for (final code in ['en', 'ar']) {
    testWidgets(
      'registration curve reserves full field extent and scrolls away $code',
      (tester) async {
        tester.view.physicalSize = const Size(360, 440);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(scene(code: code, mode: AuthPageMode.register));
        await tester.pumpAndSettle();
        final header = find.byKey(
          const Key('brand_header_geometry'),
          skipOffstage: false,
        );
        final field = find.byKey(const Key('auth_name'));
        final height = tester.getSize(header).height;
        final logo = tester.element(find.byKey(const Key('auth_logo')));
        expect(
          tester.getTopLeft(field).dy,
          greaterThanOrEqualTo(tester.getBottomLeft(header).dy),
        );
        expect(find.byType(SingleChildScrollView), findsNothing);
        final scroll = tester
            .widget<CustomScrollView>(find.byKey(const Key('session_scroll')))
            .controller!;
        scroll.jumpTo(scroll.position.maxScrollExtent);
        await tester.pump();
        expect(tester.getBottomLeft(header).dy, lessThanOrEqualTo(0));
        scroll.jumpTo(0);
        await tester.pump();
        expect(tester.getTopLeft(header).dy, 0);
        expect(tester.getSize(header).height, height);
        await tester.pumpWidget(
          scene(code: code, mode: AuthPageMode.register, keyboard: 180),
        );
        await tester.pumpAndSettle();
        expect(tester.getSize(header).height, height);
        expect(tester.element(find.byKey(const Key('auth_logo'))), same(logo));
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }

  testWidgets(
    'failure feedback returns the same scrolled header without moving fields',
    (tester) async {
      tester.view.physicalSize = const Size(360, 440);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(scene(mode: AuthPageMode.register));
      await tester.pumpAndSettle();
      final field = find.byKey(const Key('auth_email'));
      final header = find.byKey(const Key('session_header_clip'));
      final navy = tester.element(header);
      final motion = AuthMotionScope.read(tester.element(field))!;
      final scroll = tester
          .widget<CustomScrollView>(find.byKey(const Key('session_scroll')))
          .controller!;
      scroll.jumpTo(80);
      await tester.pump();
      await tester.fling(
        find.byKey(const Key('session_scroll')),
        const Offset(0, -40),
        500,
      );
      await tester.pump(const Duration(milliseconds: 16));
      final capturedOffset = scroll.offset;
      final fieldTop = tester.getTopLeft(field).dy;
      final expanding = motion.showFailure('invalid-credential', 1);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 521));
      await expanding;
      expect(motion.phase, AuthMotionPhase.failureResult);
      expect(
        tester
            .getSize(
              find.byKey(
                const Key('brand_header_geometry'),
                skipOffstage: false,
              ),
            )
            .height,
        440,
      );
      expect(tester.element(header), same(navy));
      motion.result.value = 1;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 521));
      expect(motion.phase, AuthMotionPhase.idle);
      expect(scroll.offset, capturedOffset);
      expect(tester.element(header), same(navy));
      // Inline error occupies its own space; the header returns to its exact origin.
      expect(
        tester
            .getTopLeft(
              find.byKey(
                const Key('brand_header_geometry'),
                skipOffstage: false,
              ),
            )
            .dy,
        -capturedOffset,
      );
      expect(tester.getTopLeft(field).dy, greaterThanOrEqualTo(fieldTop));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'Login morphs to symmetric Reset using the same header and saved email',
    (tester) async {
      await tester.pumpWidget(scene(mode: AuthPageMode.login));
      await tester.pumpAndSettle();
      final logo = tester.element(find.byKey(const Key('auth_logo')));
      await tester.enterText(
        find.byKey(const Key('auth_email')),
        'kept@example.com',
      );
      await tester.pumpWidget(scene(mode: AuthPageMode.reset));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 375));
      final clip = find.byKey(const Key('session_header_clip'));
      expect(
        (tester.widget<ClipPath>(clip).clipper! as AsymmetricAuthClipper).reset,
        inExclusiveRange(0, 1),
      );
      await tester.pumpAndSettle();
      expect(
        (tester.widget<ClipPath>(clip).clipper! as AsymmetricAuthClipper).reset,
        1,
      );
      expect(tester.element(find.byKey(const Key('auth_logo'))), same(logo));
      expect(
        tester
            .widget<TextFormField>(find.byKey(const Key('auth_email')))
            .controller!
            .text,
        'kept@example.com',
      );
      expect(find.byKey(const Key('auth_name')), findsNothing);
      expect(find.byKey(const Key('auth_language_en')), findsNothing);
      expect(find.byKey(const Key('auth_language_ar')), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'compact assistant is inside Home header and shares its primary scroll',
    (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(scene());
      await tester.pumpAndSettle();
      final header = find.byKey(
        const Key('brand_header_geometry'),
        skipOffstage: false,
      );
      final banner = find.byKey(const Key('home_assistant_banner'));
      expect(find.ancestor(of: banner, matching: header), findsOneWidget);
      expect(
        tester.getBottomLeft(banner).dy,
        lessThan(tester.getBottomLeft(header).dy - 20),
      );
      final robot = find.descendant(
        of: banner,
        matching: find.byKey(const Key('home_robot')),
      );
      expect(tester.getSize(robot), const Size(51, 75));
      expect(find.byType(CustomScrollView), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsNothing);
      final scroll = tester
          .widget<CustomScrollView>(find.byKey(const Key('session_scroll')))
          .controller!;
      final height = tester.getSize(header).height;
      scroll.jumpTo(height + 12);
      await tester.pump();
      expect(tester.getBottomLeft(header).dy, lessThan(0));
      scroll.jumpTo(0);
      await tester.pump();
      expect(tester.getTopLeft(header).dy, 0);
      expect(tester.getSize(header).height, height);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
