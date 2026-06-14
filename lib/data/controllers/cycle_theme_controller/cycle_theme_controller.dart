import 'package:fitness_zone_2/values/constants.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../widgets/new_home/phase_theme.dart';

/// Single source of truth for the current cycle phase and its visual theme.
///
/// Registered globally in get_di.dart so any screen can react via:
///   Obx(() => Get.find<CycleThemeController>().theme.value.accent)
///
/// Update points (call [update] after any cycle data change):
///   • PaidHomeController.loadDashboard() — server-computed phase
///   • CycleSettingsScreen._save()        — client-computed phase after save
///   • UnpaidHomeScreenV2._fetchCycleInfo() — client-computed phase on load
///
/// Falls back to follicular (app's brand green) when no cycle data exists.
class CycleThemeController extends GetxController {
  final SharedPreferences _prefs;

  CycleThemeController({required SharedPreferences prefs}) : _prefs = prefs;

  /// Reactive phase theme — UI wraps reads in Obx() to auto-rebuild.
  final Rx<PhaseTheme> theme = PhaseTheme.follicular.obs;

  /// Reactive phase enum — useful when only the enum value is needed.
  final Rx<CyclePhase> phase = CyclePhase.follicular.obs;

  @override
  void onInit() {
    super.onInit();
    // Restore last known phase immediately from SharedPreferences so the
    // correct colors show on cold start without waiting for any API call.
    final saved = _prefs.getString(Constants.lastKnownPhase);
    if (saved != null) _applyPhaseString(saved);
  }

  /// Call this with the raw phase string from any data source
  /// ("menstrual", "follicular", "ovulatory", "luteal", or null).
  void setPhase(String? phaseString) {
    _applyPhaseString(phaseString);
    // Persist so the next cold start restores immediately.
    if (phaseString != null && phaseString.isNotEmpty) {
      _prefs.setString(Constants.lastKnownPhase, phaseString);
    }
  }

  void _applyPhaseString(String? raw) {
    final p = parseCyclePhase(raw);
    phase.value = p;
    theme.value = PhaseTheme.forPhase(p);
  }
}
