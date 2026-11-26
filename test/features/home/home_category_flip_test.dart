import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:egy/features/home/presentation/widgets/home_category_flip.dart';
import 'package:egy/features/properties/domain/entities/property_category.dart';

void main() {
  for (final direction in TextDirection.values) {
    testWidgets('category flip follows index changes in ${direction.name}', (
      tester,
    ) async {
      final selected = ValueNotifier(PropertyCategory.residentialSale);
      addTearDown(selected.dispose);
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(),
          child: Directionality(
            textDirection: direction,
            child: Center(
              child: SizedBox(
                width: 240,
                height: 160,
                child: ValueListenableBuilder(
                  valueListenable: selected,
                  builder: (_, category, _) => HomeCategoryFlip(
                    category: category,
                    child: Center(child: Text(category.code)),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      double rotation(PropertyCategory category) {
        final transform = find.ancestor(
          of: find.text(category.code),
          matching: find.byType(Transform),
        );
        return tester.widget<Transform>(transform.first).transform.entry(0, 2);
      }

      const next = PropertyCategory.commercialRent;
      const previous = PropertyCategory.residentialRent;
      final forward = direction == TextDirection.ltr ? -1 : 1;
      selected.value = next;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      expect(rotation(next) * forward, greaterThan(0));

      selected.value = previous;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      expect(rotation(previous) * forward, lessThan(0));

      await tester.pumpAndSettle();
      expect(find.text(next.code), findsNothing);
      expect(find.text(previous.code), findsOneWidget);
      expect(rotation(previous), 0);
    });
  }
}
