import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

import 'package:egy/app/di/injection.dart';
import 'package:egy/app/localization/app_localization_config.dart';
import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/router/app_router.dart';
import 'package:egy/app/router/route_names.dart';
import 'package:egy/app/theme/app_theme.dart';
import 'package:egy/features/authentication/domain/entities/auth_user.dart';
import 'package:egy/features/authentication/presentation/cubit/session_cubit.dart';

import '../../support/catalog_repository.dart';
import '../../support/session_repository.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  tearDown(() => sl.reset());

  for (final (locale, size, theme, reduced) in [
    ('en', const Size(393, 851), ThemeMode.light, false),
    ('ar', const Size(320, 640), ThemeMode.dark, false),
    ('en', const Size(430, 932), ThemeMode.light, true),
  ]) {
    testWidgets(
      'reveal, Back and internal header in $locale / $theme / reduced=$reduced',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        registerTestHome();
        final auth = SessionTestRepository(
          user: const AuthUser(
            id: 'phase-1a',
            email: 'navigation@example.test',
          ),
        );
        final session = SessionCubit(auth);
        sl.registerSingleton(session);
        final router = createAppRouter(
          session: session,
          initialLocation: RoutePaths.home,
        );
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: theme,
            locale: Locale(locale),
            localizationsDelegates: AppLocalizationConfig.delegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                disableAnimations: reduced,
                textScaler: TextScaler.linear(locale == 'ar' ? 1.25 : 1),
              ),
              child: child!,
            ),
          ),
        );
        await tester.pumpAndSettle();

        final homeScroll = tester
            .widget<CustomScrollView>(find.byKey(const Key('session_scroll')))
            .controller!;
        homeScroll.jumpTo(36);
        await tester.pump();
        final homeMenu = find.byKey(const Key('home_menu'));
        final header = find.byKey(const Key('session_header_clip'));
        final headerElement = tester.element(header);
        final menu = find.byKey(const Key('reveal_menu'));
        final barrier = find.byKey(const Key('reveal_dismiss'));
        final sign = locale == 'ar' ? -1 : 1;
        final outside = Offset(
          sign == 1 ? size.width - 20 : 20,
          size.height / 2,
        );

        double revealOffset() =>
            tester
                .widget<Transform>(find.byKey(const ValueKey('reveal_offset')))
                .transform
                .getTranslation()
                .x *
            sign;

        expect(revealOffset(), 0);
        expect(menu, findsNothing);
        await tester.tap(homeMenu);
        await tester.pump();
        if (!reduced) {
          await tester.pump(const Duration(milliseconds: 75));
          expect(revealOffset(), greaterThan(0));
        }
        await tester.pumpAndSettle();
        expect(menu, findsOneWidget);
        expect(barrier, findsOneWidget);
        final openOffset = revealOffset();
        expect(openOffset, inInclusiveRange(size.width * .65, 304));
        if (!reduced) {
          await tester.dragFrom(outside, Offset(-sign * 136.0, 0));
        } else {
          await tester.tapAt(outside);
        }
        await tester.pumpAndSettle();
        expect(revealOffset(), 0);
        expect(menu, findsNothing);
        expect(homeScroll.offset, 36);

        await tester.tap(homeMenu);
        await tester.pumpAndSettle();
        await tester.tapAt(outside);
        await tester.pumpAndSettle();
        expect(menu, findsNothing);

        await tester.tap(homeMenu);
        await tester.pumpAndSettle();
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(router.state.uri.path, RoutePaths.home);
        expect(menu, findsNothing);
        expect(revealOffset(), 0);

        await tester.tap(homeMenu);
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(find.byKey(const ValueKey('reveal_settings')), 120,
          scrollable: find.descendant(of: find.byKey(const Key('reveal_menu')),
            matching: find.byType(Scrollable)).first);
        await tester.tap(find.byKey(const ValueKey('reveal_settings')));
        await tester.pump();
        if (!reduced) {
          await tester.pump(const Duration(milliseconds: 230));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 65));
        }
        final internalHeader = find.byKey(const Key('authenticated_header'));
        expect(internalHeader, findsOneWidget);
        expect(router.state.uri.path, RoutePaths.settings);
        if (reduced) {
          expect(
            find.byKey(const Key('authenticated_route_fade')),
            findsNothing,
          );
        } else {
          expect(tester.getTopLeft(internalHeader).dx * sign, greaterThan(0));
          final motion = tester.widget<FadeTransition>(
            find.byKey(const Key('authenticated_route_fade')),
          );
          expect(motion.opacity.value, inExclusiveRange(0.0, 1.0));
          expect(header, findsOneWidget);
        }
        await tester.pumpAndSettle();
        final sizeOfHeader = tester.getSize(internalHeader);
        final path = tester
            .widget<ClipPath>(internalHeader)
            .clipper!
            .getClip(sizeOfHeader);
        expect(path.contains(Offset(1, sizeOfHeader.height - 12)), isTrue);
        expect(
          path.contains(
            Offset(sizeOfHeader.width / 2, sizeOfHeader.height - 4),
          ),
          isFalse,
        );
        final scaffold = find
            .ancestor(of: internalHeader, matching: find.byType(Scaffold))
            .first;
        final expectedSurface =
            (theme == ThemeMode.dark ? AppTheme.dark : AppTheme.light)
                .colorScheme
                .surface;
        expect(
          tester.widget<Scaffold>(scaffold).backgroundColor,
          expectedSurface,
        );

        await tester.tap(find.byKey(const Key('authenticated_reveal')));
        await tester.pumpAndSettle();
        expect(menu, findsOneWidget);
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(router.state.uri.path, RoutePaths.settings);
        expect(menu, findsNothing);
        await tester.binding.handlePopRoute();
        await tester.pump();
        if (!reduced) {
          await tester.pump(const Duration(milliseconds: 65));
          expect(tester.getTopLeft(internalHeader).dx * sign, greaterThan(0));
          final motion = tester.widget<FadeTransition>(
            find.byKey(const Key('authenticated_route_fade')),
          );
          expect(motion.opacity.value, inExclusiveRange(0.0, 1.0));
          expect(header, findsOneWidget);
        }
        await tester.pumpAndSettle();
        expect(router.state.uri.path, RoutePaths.home);
        expect(identical(tester.element(header), headerElement), isTrue);
        expect(homeScroll.offset, 36);
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(const SizedBox.shrink());
        router.dispose();
        await tester.runAsync(() async {
          await session.close();
          await auth.dispose();
        });
      },
    );
  }
}
