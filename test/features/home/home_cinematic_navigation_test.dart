import 'dart:ui' show ImageFilter;

import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:egy/app/app.dart';
import 'package:egy/app/di/injection.dart';
import 'package:egy/app/router/app_router.dart';
import 'package:egy/app/router/route_names.dart';
import 'package:egy/features/authentication/domain/entities/auth_user.dart';
import 'package:egy/features/authentication/presentation/cubit/session_cubit.dart';
import 'package:egy/features/properties/presentation/pages/property_details_page.dart';

import '../../support/catalog_repository.dart';
import '../../support/session_repository.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets(
    'search expands and opens the real details route, then restores the query',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final authentication = SessionTestRepository(
        user: const AuthUser(id: 'home-user', email: 'test@example.com'),
      );
      final session = SessionCubit(authentication);
      sl.registerSingleton(session);
      registerTestHome();
      SharedPreferences.setMockInitialValues({});
      final router = createAppRouter(
        session: session,
        initialLocation: RoutePaths.home,
      );

      addTearDown(() async {
        router.dispose();
        await sl.reset();
        await session.close();
        await authentication.dispose();
      });
      await tester.pumpWidget(
        App(prefs: await SharedPreferences.getInstance(), router: router),
      );
      await tester.pumpAndSettle();

      final trigger = find.byKey(const Key('home_search'));
      final input = find.byKey(const Key('home_search_query'));
      final close = find.byKey(const Key('home_search_close'));
      await tester.tap(trigger);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 160));
      expect(find.byType(BackdropFilter), findsOneWidget);
      expect(
        tester.widget<BackdropFilter>(find.byType(BackdropFilter)).filter,
        isA<ImageFilter>(),
      );
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(input).controller!.text, isEmpty);
      await tester.enterText(input, 'New Cairo');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('home_search_result_1')));
      await tester.pumpAndSettle();

      final details = tester.widget<PropertyDetailsPage>(
        find.byType(PropertyDetailsPage),
      );
      expect(details.id, 1);
      expect(details.preview?.property.id, 1);
      expect(find.text('Test listing 1'), findsOneWidget);
      expect(find.byKey(const Key('authenticated_reveal')), findsOneWidget);

      router.pop();
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(input).controller!.text, 'New Cairo');
      await tester.tap(close);
      await tester.pumpAndSettle();
      expect(input, findsNothing);
      expect(find.byType(BackdropFilter), findsNothing);
      await tester.tap(trigger);
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(input).controller!.text, 'New Cairo');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
