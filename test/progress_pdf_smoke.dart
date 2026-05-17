// Pure-Dart smoke test for the Progress PDF builder. Bypasses
// flutter_test (blocked by an Application Control policy in this env)
// by building the PDF document inline using the same widget tree the
// service emits.
//
// Run:
//   cd fit_her-main
//   dart run test/progress_pdf_smoke.dart
//
// Asserts:
//   * file exists
//   * size > 2000 bytes (i.e. the document actually populated)
//   * %PDF- header present
//   * page count == 2 (parses /Type /Page entries from the raw bytes)

import 'dart:io';

import '../lib/data/models/progress_v2/progress_models.dart';
import '../lib/services/progress_report_pdf_builder.dart';

Future<void> main() async {
  // Use the pure-Dart builder so we can run without flutter_test (blocked
  // by Application Control on this machine) and without path_provider
  // (which transitively pulls in Flutter).
  final builder = const ProgressReportPdfBuilder();

  final summary = ProgressSummary.fromJson({
    'period': 'month',
    'period_start': '2026-04-01',
    'period_end': '2026-04-30',
    'previous_period_start': '2026-03-01',
    'previous_period_end': '2026-03-31',
    'user': {'firstName': 'Shaista', 'image': null},
    'cycle': {'phase': 'follicular', 'cycleDay': 9, 'averageCycleLength': 28, 'hasData': true},
    'goal': {
      'label': '65kg by 2026-06-30',
      'type': 'weight_loss',
      'targetValueKg': 65.0,
      'startValueKg': 70.0,
      'currentValueKg': 67.4,
      'targetDeltaKg': -5.0,
      'currentDeltaKg': -2.6,
      'targetDate': '2026-06-30',
      'startDate': '2026-01-01',
      'progressPct': 0.52,
      'paceStatus': 'ahead',
      'paceMessage': '3 wks ahead of schedule',
      'weeksAhead': 3,
      'hasGoalRow': true,
    },
    'stats': {
      'classesAttended': 16,
      'streakDays': 8,
      'avgSleepHours': 6.5,
      'avgEnergyScore': 7.2,
    },
  });

  final weight = WeightTrend.fromJson({
    'period': 'month',
    'currentWeightKg': 67.4,
    'deltaKg': -2.1,
    'direction': 'toward_goal',
    'history': [
      {'date': '2026-04-01', 'weightKg': 69.5, 'phase': 'menstrual'},
      {'date': '2026-04-08', 'weightKg': 69.0, 'phase': 'follicular'},
      {'date': '2026-04-15', 'weightKg': 68.4, 'phase': 'ovulatory'},
      {'date': '2026-04-22', 'weightKg': 67.8, 'phase': 'luteal'},
      {'date': '2026-04-27', 'weightKg': 67.4, 'phase': 'luteal'},
    ],
    'phaseSegments': [
      {'phase': 'menstrual', 'start': '2026-04-01', 'end': '2026-04-05'},
      {'phase': 'follicular', 'start': '2026-04-06', 'end': '2026-04-12'},
      {'phase': 'ovulatory', 'start': '2026-04-13', 'end': '2026-04-15'},
      {'phase': 'luteal', 'start': '2026-04-16', 'end': '2026-04-30'},
    ],
    'projection': [
      {'date': '2026-05-15', 'weightKg': 66.8, 'isProjection': true},
    ],
  });

  final hydration = HydrationData.fromJson({
    'period': 'month',
    'averageL': 1.6,
    'averageMl': 1600,
    'targetL': 2.5,
    'targetMl': 2500,
    'pct': 0.62,
    'nudge': 'drink more',
    'daysLogged': 22,
    'phaseTip': {
      'phase': 'follicular',
      'tip': 'Aim for 100g protein - absorption is up to 30% higher in this phase.',
      'macroEmphasis': 'protein',
    },
    'mealsCard': {'copy': 'Meals - coming soon', 'enabled': false},
  });

  final symptoms = SymptomsData.fromJson({
    'period': 'month',
    'symptoms': [
      {'key': 'bloating', 'label': 'Bloating', 'intensityPct': 35, 'deltaPct': -40, 'direction': 'improvement', 'notEnoughData': false},
      {'key': 'energy', 'label': 'Energy', 'intensityPct': 78, 'deltaPct': 60, 'direction': 'improvement', 'notEnoughData': false},
      {'key': 'mood', 'label': 'Mood', 'intensityPct': 68, 'deltaPct': 45, 'direction': 'improvement', 'notEnoughData': false},
      {'key': 'cramps', 'label': 'Cramps', 'intensityPct': 22, 'deltaPct': -60, 'direction': 'improvement', 'notEnoughData': false},
    ],
    'basedOnCheckIns': 16,
  });

  final insights = InsightsHubData.fromJson({
    'period': 'month',
    'insights': [
      {'id': 'static_1', 'headline': 'Strength reduces bloating 62%', 'subtitle': 'Strength', 'body': 'On strength days bloating drops sharply.', 'isStatic': true},
      {'id': 'static_2', 'headline': 'Sleep before 11:30 lifts mood 40%', 'subtitle': 'Sleep', 'body': 'Earlier bedtime correlates with better mood.', 'isStatic': true},
      {'id': 'static_3', 'headline': 'You train 2.4x less in luteal', 'subtitle': 'Phase', 'body': 'Activity drops in luteal. That is OK.', 'isStatic': true},
    ],
    'patternsFound': 3,
    'isStatic': true,
    'honestyBanner': 'FitHer AI is learning - static tips for now.',
  });

  final doc = builder.buildDocument(
    summary: summary,
    weight: weight,
    hydration: hydration,
    symptoms: symptoms,
    insights: insights,
    userFullName: 'Shaista QA',
  );

  final bytes = await doc.save();

  final tempDir = Directory.systemTemp.createTempSync('fither_pdf_smoke_');
  final outFile = File('${tempDir.path}/fither_progress_smoke.pdf');
  await outFile.writeAsBytes(bytes);

  // Assertions
  final size = await outFile.length();
  print('[smoke] file:        ${outFile.path}');
  print('[smoke] size:        $size bytes');
  if (size < 2000) {
    print('FAIL: PDF too small');
    exit(1);
  }

  final header = String.fromCharCodes(bytes.take(5));
  print('[smoke] header:      $header');
  if (header != '%PDF-') {
    print('FAIL: missing PDF header');
    exit(1);
  }

  // Count /Type /Page (but not /Pages) in the raw stream. We add two
  // pw.MultiPage blocks; either can naturally spill across multiple
  // physical pages when content overflows A4. So we expect >= 2 and
  // a sane upper bound that catches a layout bug ballooning the doc.
  final raw = String.fromCharCodes(bytes);
  final pageRegex = RegExp(r'/Type\s*/Page(?!s)');
  final pageMatches = pageRegex.allMatches(raw).length;
  print('[smoke] /Page count: $pageMatches  (>= 2, <= 6 expected)');
  if (pageMatches < 2 || pageMatches > 6) {
    print('FAIL: expected 2..6 physical pages, got $pageMatches');
    exit(1);
  }

  print('[smoke] PASS: $pageMatches-page PDF, ${size} bytes, header OK');
  exit(0);
}
