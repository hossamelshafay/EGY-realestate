import 'package:egy/app/localization/app_localization_config.dart';
import 'package:egy/app/theme/theme_cubit.dart';
import 'package:egy/features/home/presentation/widgets/home_header_controls.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  for (final language in ['en', 'ar']) {
    testWidgets('greeting remains centered with directional controls in $language', (tester) async {
      tester.view.physicalSize = const Size(320, 600); tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize); addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({}); final cubit = ThemeCubit(await SharedPreferences.getInstance());
      addTearDown(cubit.close);
      var menu = false;
      await tester.pumpWidget(BlocProvider.value(value: cubit, child: MaterialApp(locale: Locale(language),
        localizationsDelegates: AppLocalizationConfig.delegates, supportedLocales: const [Locale('en'), Locale('ar')],
        home: Scaffold(body: HomeHeaderControls(greeting: 'Welcome', onMenu: () => menu = true)))));
      await tester.pumpAndSettle();
      final toggle = tester.getCenter(find.byKey(const Key('theme_toggle')));
      final hamburger = tester.getCenter(find.byKey(const Key('home_menu')));
      expect(language == 'en' ? toggle.dx < hamburger.dx : toggle.dx > hamburger.dx, isTrue);
      expect(tester.getCenter(find.byKey(const Key('home_greeting'))).dx, closeTo(160, .1));
      expect(tester.getSize(find.byKey(const Key('theme_toggle'))).width, greaterThanOrEqualTo(48));
      await tester.tap(find.byKey(const Key('home_menu'))); expect(menu, isTrue);
      expect(tester.takeException(), isNull);
    });
  }
}
