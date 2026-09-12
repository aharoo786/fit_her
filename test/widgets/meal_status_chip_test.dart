import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_zone_2/data/models/meal_log/meal_log.dart';
import 'package:fitness_zone_2/widgets/v2/meal_status_chip.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('MealStatusChip', () {
    testWidgets('followed status shows "Followed" label and check icon', (tester) async {
      await tester.pumpWidget(_wrap(const MealStatusChip(status: MealStatus.followed)));
      expect(find.text('Followed'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('alternative status shows "Alternative" label', (tester) async {
      await tester.pumpWidget(_wrap(const MealStatusChip(status: MealStatus.alternative)));
      expect(find.text('Alternative'), findsOneWidget);
      expect(find.byIcon(Icons.swap_horiz_rounded), findsOneWidget);
    });

    testWidgets('skipped status shows "Skipped" label', (tester) async {
      await tester.pumpWidget(_wrap(const MealStatusChip(status: MealStatus.skipped)));
      expect(find.text('Skipped'), findsOneWidget);
    });

    testWidgets('pending status shows "Pending" label with outlined (bordered) container', (tester) async {
      await tester.pumpWidget(_wrap(const MealStatusChip(status: MealStatus.pending)));
      expect(find.text('Pending'), findsOneWidget);

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull); // only "pending" gets an outline
    });

    testWidgets('non-pending statuses have no border', (tester) async {
      await tester.pumpWidget(_wrap(const MealStatusChip(status: MealStatus.followed)));
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNull);
    });

    testWidgets('dense mode uses smaller font size', (tester) async {
      await tester.pumpWidget(
        _wrap(const MealStatusChip(status: MealStatus.followed, dense: true)),
      );
      final text = tester.widget<Text>(find.text('Followed'));
      expect(text.style?.fontSize, 10);
    });

    testWidgets('non-dense mode uses the larger font size', (tester) async {
      await tester.pumpWidget(
        _wrap(const MealStatusChip(status: MealStatus.followed, dense: false)),
      );
      final text = tester.widget<Text>(find.text('Followed'));
      expect(text.style?.fontSize, 11);
    });
  });
}
