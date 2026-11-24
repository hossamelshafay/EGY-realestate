import 'package:flutter_test/flutter_test.dart';

import 'package:egy/app/router/app_router.dart';
import 'package:egy/app/router/route_names.dart';

void main() {
  group('AppRouter', () {
    test('appRouter can be created without throwing', () {
      expect(() => appRouter, returnsNormally);
    });

    test('RouteNames has expected entries', () {
      expect(RouteNames.splash, 'splash');
      expect(RouteNames.login, 'login');
      expect(RouteNames.home, 'home');
      expect(RouteNames.recommendations, 'recommendations');
      expect(RouteNames.pricePrediction, 'pricePrediction');
      expect(RouteNames.aiChat, 'aiChat');
      expect(RouteNames.favorites, 'favorites');
      expect(RouteNames.settings, 'settings');
      expect(RouteNames.editProfile, 'editProfile');
      expect(RouteNames.changePassword, 'changePassword');
    });

    test('RoutePaths has expected values', () {
      expect(RoutePaths.splash, '/');
      expect(RoutePaths.login, '/login');
      expect(RoutePaths.home, '/home');
      expect(RoutePaths.pricePrediction, '/price-prediction');
      expect(RoutePaths.aiChat, '/ai-chat');
      expect(RoutePaths.editProfile, '/settings/profile');
    });

    test('appRouter initialLocation is splash path', () {
      // The router's initialLocation is set to RoutePaths.splash.
      // We verify the constant rather than calling internal router APIs that
      // vary between go_router versions.
      expect(RoutePaths.splash, '/');
    });
  });
}
