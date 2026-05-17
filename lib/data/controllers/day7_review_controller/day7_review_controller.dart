import 'package:get/get.dart';

import '../../Repos/diet_plan_v2/diet_plan_admin_repository.dart'
    show DietPlanApiException;
import '../../Repos/diet_plan_v2/diet_plan_user_repository.dart';
import '../../models/diet_plan_v2/day7_review_model.dart';
import '../../../values/constants.dart';
import '../auth_controller/auth_controller.dart';
import '../diet_plan_user_controller/diet_plan_user_controller.dart';

/// Phase G.3 — drives the Day 7 check-in banner + screen.
///
/// Eligibility note — there is no GET endpoint for "should this popup
/// fire" today. The backend exposes only POST dismiss / POST complete
/// for popup state. We compute eligibility client-side off:
///   • `todaysDayNumber >= 7` (the user has lived through at least a
///     week of the plan)
///   • a per-(userPlanId, cycle) "submitted-or-dismissed" flag in
///     SharedPreferences so the banner doesn't re-appear on the next
///     screen visit after the user has already responded.
///
/// The server is still authoritative for the popup-state row — submit
/// stamps `completedAt`, dismiss bumps `dismissCount` — so the next
/// device the user logs in on will get the same answer once we add a
/// proper eligibility GET. Until then, the local flag covers the
/// dominant single-device case.
class Day7ReviewController extends GetxController {
  final DietPlanUserRepository repo;
  final AuthController auth;

  Day7ReviewController({required this.repo, required this.auth});

  final RxBool isEligible = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxnString submissionError = RxnString();

  Worker? _planWatcher;

  @override
  void onInit() {
    super.onInit();
    // Re-check whenever the active plan reloads (login, refresh,
    // dietitian activates a new plan). The check is cheap and
    // idempotent — the SharedPrefs flag stops the banner from
    // re-appearing once the user has responded.
    final dietCtrl = _findDietPlanCtrl();
    if (dietCtrl != null) {
      _planWatcher = ever(dietCtrl.activePlan, (_) => checkEligibility());
    }
    checkEligibility();
  }

  @override
  void onClose() {
    _planWatcher?.dispose();
    super.onClose();
  }

  String get _token =>
      auth.sharedPreferences.getString(Constants.accessToken) ?? '';

  /// SharedPrefs key — per (userPlanId, cycle). Once flipped, the
  /// banner stays hidden for that cycle on this device.
  String _suppressKey(int userPlanId, int cycle) =>
      'day7_review_done_${userPlanId}_$cycle';

  /// Re-evaluate eligibility against the current plan + local
  /// suppression flag. Idempotent — safe to call from onInit, on app
  /// resume, and after submit/dismiss.
  Future<void> checkEligibility() async {
    final dietCtrl = _findDietPlanCtrl();
    if (dietCtrl == null) {
      isEligible.value = false;
      return;
    }
    final plan = dietCtrl.activePlan.value;
    final today = dietCtrl.todaysDayNumber;
    if (plan == null || today == null) {
      isEligible.value = false;
      return;
    }
    if (today < 7) {
      isEligible.value = false;
      return;
    }
    // Plan-ended state has its own follow-up CTA (Phase F.3).
    if (dietCtrl.planHasEnded) {
      isEligible.value = false;
      return;
    }
    final userPlanId = plan.userPlanId;
    if (userPlanId == null) {
      isEligible.value = false;
      return;
    }
    final suppressed = auth.sharedPreferences
            .getBool(_suppressKey(userPlanId, currentCycle)) ??
        false;
    isEligible.value = !suppressed;
  }

  /// MVP — only cycle 1 is wired. The dietitian dashboard treats cycle
  /// 1 / cycle 2 separately (latestPlanDeliveredAt anchor) but the
  /// user-facing banner is single-cycle for now. Bump this when cycle
  /// 2 wiring lands.
  int get currentCycle => 1;

  /// POST the review. On success: snackbar elsewhere, here we just
  /// flip suppression + isEligible so the banner disappears.
  Future<bool> submit(Day7ReviewSubmission submission) async {
    isSubmitting.value = true;
    submissionError.value = null;
    try {
      await repo.submitDay7Review(
        accessToken: _token,
        submission: submission,
      );
      await _markSubmittedOrDismissed(
        userPlanId: submission.userPlanId,
        cycle: submission.cycle,
      );
      isEligible.value = false;
      return true;
    } on DietPlanApiException catch (e) {
      submissionError.value = e.message;
      return false;
    } catch (_) {
      submissionError.value =
          "Network error — check your connection and try again";
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// User tapped X on the banner — increment server-side dismissCount
  /// and locally suppress this cycle. Server failure doesn't block
  /// the local hide; we'd rather not nag than block the UX on a
  /// network blip.
  Future<void> dismiss() async {
    final dietCtrl = _findDietPlanCtrl();
    final userPlanId = dietCtrl?.activePlan.value?.userPlanId;
    isEligible.value = false;
    if (userPlanId != null) {
      await _markSubmittedOrDismissed(
        userPlanId: userPlanId,
        cycle: currentCycle,
      );
    }
    try {
      await repo.dismissPopup(
        accessToken: _token,
        popupVariable: Constants.day7ReviewPopupVariable,
      );
    } catch (_) {
      // Silent — local flag already flipped, banner is gone.
    }
  }

  Future<void> _markSubmittedOrDismissed({
    required int userPlanId,
    required int cycle,
  }) async {
    await auth.sharedPreferences
        .setBool(_suppressKey(userPlanId, cycle), true);
  }

  DietPlanUserController? _findDietPlanCtrl() {
    if (!Get.isRegistered<DietPlanUserController>()) return null;
    return Get.find<DietPlanUserController>();
  }
}
