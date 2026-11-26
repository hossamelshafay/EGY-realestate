import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/localization/app_localization_config.dart';
import 'package:egy/features/properties/domain/entities/property_listing.dart';
import 'package:egy/features/properties/presentation/widgets/property_details_content.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  for (final locale in ['en', 'ar']) {
    testWidgets(
      'details wraps real facts at narrow width and large text $locale',
      (tester) async {
        tester.view.physicalSize = const Size(320, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            locale: Locale(locale),
            localizationsDelegates: AppLocalizationConfig.delegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(1.8)),
              child: child!,
            ),
            home: const Scaffold(
              body: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: PropertyDetailsContent(
                  property: PropertyListing(
                    id: 1,
                    title: 'Full property title',
                    location: 'Cairo',
                    category: 'buy',
                    propertyType: 'Apartment',
                    price: 1250000,
                    bedrooms: 0,
                    bathrooms: 2,
                    size: 125,
                    description: 'Full description from the listing.',
                    amenities: [
                      'A long amenity name that must wrap without overflow',
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        expect(find.text('Full property title'), findsOneWidget);
        expect(find.text('Full description from the listing.'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
