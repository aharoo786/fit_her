// Basic widget test for PaidCycleCard — the card we just started
// pairing with Meals/Nutrition on the paid home screen. It takes a
// plain HomeDashboardModel (no GetX controller lookups inside), so it
// can be tested in isolation with no mocking.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_zone_2/data/models/home_dashboard/home_dashboard_model.dart';
import 'package:fitness_zone_2/widgets/paid_home_v2/paid_cycle_card.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: child),
    );

void main() {
  group('PaidCycleCard', () {
    testWidgets('renders cycle day + phase label when cycle data exists',
        (tester) async {
      const dashboard = HomeDashboardModel(
        cycle: CycleInfo(
          cycleDay: 14,
          phase: 'ovulation',
          phaseLabel: 'Ovulation',
          periodInDays: 14,
        ),
      );

      await tester.pumpWidget(_wrap(const PaidCycleCard(dashboard: dashboard)));

      expect(find.text('14'), findsOneWidget);
      expect(find.text('Ovulation'), findsOneWidget);
      expect(find.textContaining('Period in'), findsOneWidget);
    });

    testWidgets('collapses to nothing when cycleDay is null', (tester) async {
      const dashboard = HomeDashboardModel(cycle: CycleInfo(cycleDay: null));

      await tester.pumpWidget(_wrap(const PaidCycleCard(dashboard: dashboard)));

      // No cycle content should be on screen, and the widget should
      // occupy zero size (SizedBox.shrink), not just be visually empty.
      expect(find.byType(Container), findsNothing);
      final size = tester.getSize(find.byType(PaidCycleCard));
      expect(size, Size.zero);
    });

    testWidgets('collapses to nothing when cycle itself is null',
        (tester) async {
      const dashboard = HomeDashboardModel(cycle: null);

      await tester.pumpWidget(_wrap(const PaidCycleCard(dashboard: dashboard)));

      expect(find.byType(Container), findsNothing);
    });

    testWidgets('period-line wording matches days-until-period',
        (tester) async {
      const today = HomeDashboardModel(
        cycle: CycleInfo(cycleDay: 1, phase: 'menstrual', periodInDays: 0),
      );
      await tester.pumpWidget(_wrap(const PaidCycleCard(dashboard: today)));
      expect(find.text('Period today'), findsOneWidget);
    });
  });
}
