// Demonstrates the pattern for testing a GetX controller with a real
// (in-memory, fake-backed) SharedPreferences instance instead of a real
// device — no mocking framework needed since shared_preferences ships
// its own test double (`setMockInitialValues`). CycleThemeController was
// picked as the first controller test because it has exactly one
// dependency (SharedPreferences) and no network/repo calls, making it
// the cleanest place to prove out the pattern before tackling the
// heavier controllers (MealLogController, DietPlanUserController, etc.)
// in a later pass — see the audit report's test-strategy section.
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitness_zone_2/data/controllers/cycle_theme_controller/cycle_theme_controller.dart';
import 'package:fitness_zone_2/widgets/new_home/phase_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CycleThemeController.onInit — cold-start restore', () {
    test('no saved phase falls back to follicular (the brand default)', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final ctrl = CycleThemeController(prefs: prefs);
      ctrl.onInit();

      expect(ctrl.phase.value, CyclePhase.follicular);
      expect(ctrl.theme.value, PhaseTheme.forPhase(CyclePhase.follicular));
    });

    test('restores a previously saved phase immediately on cold start', () async {
      SharedPreferences.setMockInitialValues({'lastKnownPhase': 'luteal'});
      final prefs = await SharedPreferences.getInstance();
      final ctrl = CycleThemeController(prefs: prefs);
      ctrl.onInit();

      expect(ctrl.phase.value, CyclePhase.luteal);
      expect(ctrl.theme.value, PhaseTheme.forPhase(CyclePhase.luteal));
    });

    test('an unrecognized saved string falls back to follicular, not a crash', () async {
      SharedPreferences.setMockInitialValues({'lastKnownPhase': 'garbage'});
      final prefs = await SharedPreferences.getInstance();
      final ctrl = CycleThemeController(prefs: prefs);
      expect(() => ctrl.onInit(), returnsNormally);
      expect(ctrl.phase.value, CyclePhase.follicular);
    });
  });

  group('CycleThemeController.setPhase', () {
    test('updates both phase and theme reactively', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final ctrl = CycleThemeController(prefs: prefs);
      ctrl.onInit();

      ctrl.setPhase('ovulatory');

      expect(ctrl.phase.value, CyclePhase.ovulatory);
      expect(ctrl.theme.value, PhaseTheme.forPhase(CyclePhase.ovulatory));
    });

    test('persists the new phase so the next cold start restores it', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final ctrl = CycleThemeController(prefs: prefs);
      ctrl.onInit();

      ctrl.setPhase('menstrual');
      expect(prefs.getString('lastKnownPhase'), 'menstrual');

      // Simulate app restart: a fresh controller reading the same prefs.
      final restarted = CycleThemeController(prefs: prefs);
      restarted.onInit();
      expect(restarted.phase.value, CyclePhase.menstrual);
    });

    test('null/empty phase string does not persist (keeps last saved value)', () async {
      SharedPreferences.setMockInitialValues({'lastKnownPhase': 'luteal'});
      final prefs = await SharedPreferences.getInstance();
      final ctrl = CycleThemeController(prefs: prefs);
      ctrl.onInit();

      ctrl.setPhase(null);
      // Visual state falls back to follicular (parseCyclePhase(null)),
      // but the persisted pref is untouched per the `if (phaseString !=
      // null && phaseString.isNotEmpty)` guard.
      expect(ctrl.phase.value, CyclePhase.follicular);
      expect(prefs.getString('lastKnownPhase'), 'luteal');
    });
  });
}
