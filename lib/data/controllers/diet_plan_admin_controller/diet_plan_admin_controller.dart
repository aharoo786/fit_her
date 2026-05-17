import 'package:get/get.dart';

import '../../Repos/diet_plan_v2/diet_plan_admin_repository.dart';
import '../../models/diet_plan_v2/diet_plan_v2_models.dart';
import '../../../values/constants.dart';
import '../auth_controller/auth_controller.dart';

/// Drives the dietitian-side diet-plan surfaces (Phase E).
///
/// Phase E.2 only consumes [drafts] + [loadDrafts]. Subsequent phases
/// (review/edit, generate, history) hang their state off this same
/// controller so a single Get instance owns the lifecycle.
class DietPlanAdminController extends GetxController {
  final DietPlanAdminRepository repo;
  final AuthController auth;

  DietPlanAdminController({required this.repo, required this.auth});

  // ─── Phase E.2 — drafts dashboard state ────────────────────────────────

  /// All drafts authored by the calling dietitian (status = draft).
  final RxList<DietPlanV2> drafts = <DietPlanV2>[].obs;

  /// True during the *initial* load — the screen shows a centered
  /// spinner. Pull-to-refresh uses [isRefreshing] instead so the list
  /// stays visible.
  final RxBool isLoading = false.obs;

  /// True while a pull-to-refresh is in flight.
  final RxBool isRefreshing = false.obs;

  /// User-facing error message. Cleared on success / `clearError()`.
  final RxnString errorMessage = RxnString();

  // ─── Phase E.3 — generate-plan state ───────────────────────────────────

  /// True while the AI generation request is in flight (~20–40s).
  final RxBool isGenerating = false.obs;

  /// Last generation's user-facing error. Surfaces inline above the
  /// "Try again" button on the generate screen.
  final RxnString generationError = RxnString();

  /// Most recent successful generation. Held so subsequent screens
  /// (Phase E.4 review) can navigate without a re-fetch.
  final Rxn<DietPlanV2> lastGeneratedPlan = Rxn<DietPlanV2>();

  // ─── Phase E.4 — review/edit screen state ──────────────────────────────

  /// The plan currently being reviewed. Replaced (not mutated) on every
  /// edit/activate/cancel so Obx callers re-render cleanly.
  final Rxn<DietPlanV2> currentPlan = Rxn<DietPlanV2>();
  final RxBool isPlanLoading = false.obs;
  final RxnString planError = RxnString();

  /// id of the meal currently mid-PATCH. Drives the per-row spinner so
  /// only the row being saved goes "loading" — everything else stays
  /// interactive.
  final RxnInt savingMealId = RxnInt();
  final RxBool isActivating = false.obs;
  final RxBool isCancelling = false.obs;

  // ─── Phase E.5 — user plan history ─────────────────────────────────────

  /// All plans (any status) for the user currently being viewed.
  final RxList<DietPlanV2> userHistory = <DietPlanV2>[].obs;
  final RxBool isHistoryLoading = false.obs;
  final RxnString historyError = RxnString();

  /// `null` = "All statuses". Set to a specific status to filter the
  /// list — the screen's chip row writes to this via [loadHistoryForUser].
  final Rxn<DietPlanStatusV2> historyStatusFilter = Rxn<DietPlanStatusV2>();

  /// User the current [userHistory] belongs to. Lets a screen detect
  /// stale data ("we navigated to a different user, this list is for
  /// the previous one") without rolling its own bookkeeping.
  final RxnInt historyTargetUserId = RxnInt();

  String get _token =>
      auth.sharedPreferences.getString(Constants.accessToken) ?? '';

  @override
  void onInit() {
    super.onInit();
    loadDrafts();
  }

  /// Fetch drafts from the backend. `refresh:true` is the pull-to-
  /// refresh variant — keeps the existing list visible and toggles
  /// [isRefreshing] instead of [isLoading].
  Future<void> loadDrafts({bool refresh = false}) async {
    if (refresh) {
      isRefreshing.value = true;
    } else {
      isLoading.value = true;
    }
    errorMessage.value = null;
    try {
      final list = await repo.listMyDrafts(accessToken: _token);
      drafts.assignAll(list);
    } on DietPlanApiException catch (e) {
      errorMessage.value = e.message;
      // On a refresh failure we keep the stale list; on initial-load
      // failure the empty list is the right state for the error UI.
      if (!refresh) drafts.clear();
    } catch (e) {
      errorMessage.value =
          'Network error — check your connection and try again';
      if (!refresh) drafts.clear();
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  void clearError() {
    errorMessage.value = null;
  }

  void clearGenerationError() {
    generationError.value = null;
  }

  /// Trigger an AI generation for the given client + plan window. On
  /// success, refreshes [drafts] so the dashboard reflects the new
  /// draft without a manual pull-to-refresh. Returns the saved plan,
  /// or null on failure (caller checks [generationError]).
  Future<DietPlanV2?> generatePlan({
    required int userId,
    required int userPlanId,
    required int planDays,
    required int mealsPerDay,
  }) async {
    isGenerating.value = true;
    generationError.value = null;
    try {
      final plan = await repo.generatePlan(
        accessToken: _token,
        userId: userId,
        userPlanId: userPlanId,
        planDays: planDays,
        mealsPerDay: mealsPerDay,
      );
      lastGeneratedPlan.value = plan;
      // Background refresh; failure here is non-fatal — the new draft
      // will land on next open of the dashboard.
      await loadDrafts(refresh: true);
      return plan;
    } on DietPlanApiException catch (e) {
      generationError.value = e.message;
      return null;
    } catch (e) {
      generationError.value = 'Something went wrong: ${e.toString()}';
      return null;
    } finally {
      isGenerating.value = false;
    }
  }

  // ─── Phase E.4 methods ────────────────────────────────────────────────

  Future<void> loadPlanById(int id) async {
    isPlanLoading.value = true;
    planError.value = null;
    try {
      currentPlan.value = await repo.getPlanById(
        accessToken: _token,
        id: id,
      );
    } on DietPlanApiException catch (e) {
      planError.value = e.message;
    } catch (e) {
      planError.value = 'Could not load plan — please try again';
    } finally {
      isPlanLoading.value = false;
    }
  }

  /// Patch one meal on the currently-loaded plan. Splices the response
  /// (server-recomputed `day.totalCalories`) into [currentPlan] without
  /// re-fetching. Returns true on success, false otherwise (caller can
  /// keep the edit sheet open on failure).
  Future<bool> updateMealOnCurrentPlan({
    required int mealId,
    String? foodName,
    int? calories,
    String? time,
    String? notes,
    MealTypeV2? mealType,
  }) async {
    final plan = currentPlan.value;
    if (plan == null) return false;

    savingMealId.value = mealId;
    try {
      final result = await repo.updateMeal(
        accessToken: _token,
        mealId: mealId,
        foodName: foodName,
        calories: calories,
        time: time,
        notes: notes,
        mealType: mealType,
      );

      // Splice updated meal + day total into the plan tree.
      final updatedDays = plan.days.map((day) {
        if (day.id != result.day.id) return day;
        final updatedMeals = day.meals
            .map((m) => m.id == result.meal.id ? result.meal : m)
            .toList();
        return day.copyWith(
          totalCalories: result.day.totalCalories,
          meals: updatedMeals,
        );
      }).toList();
      currentPlan.value = plan.copyWith(days: updatedDays);
      return true;
    } on DietPlanApiException catch (e) {
      Get.snackbar('Update failed', e.message,
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } catch (_) {
      Get.snackbar(
        'Update failed',
        'Network error — try again',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      savingMealId.value = null;
    }
  }

  Future<bool> activateCurrentPlan() async {
    final plan = currentPlan.value;
    if (plan == null) return false;
    isActivating.value = true;
    try {
      final updated =
          await repo.activatePlan(accessToken: _token, id: plan.id);
      currentPlan.value = updated;
      // Keep the drafts dashboard in sync — the just-activated plan
      // should disappear from the drafts list.
      await loadDrafts(refresh: true);
      return true;
    } on DietPlanApiException catch (e) {
      Get.snackbar('Activation failed', e.message,
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } catch (_) {
      Get.snackbar(
        'Activation failed',
        'Network error — try again',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isActivating.value = false;
    }
  }

  Future<bool> cancelCurrentPlan({String? reason}) async {
    final plan = currentPlan.value;
    if (plan == null) return false;
    isCancelling.value = true;
    try {
      final updated = await repo.cancelPlan(
        accessToken: _token,
        id: plan.id,
        reason: reason,
      );
      currentPlan.value = updated;
      // Either a draft is gone OR an active plan flipped to cancelled —
      // dashboard should reflect both.
      await loadDrafts(refresh: true);
      return true;
    } on DietPlanApiException catch (e) {
      Get.snackbar('Cancellation failed', e.message,
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } catch (_) {
      Get.snackbar(
        'Cancellation failed',
        'Network error — try again',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isCancelling.value = false;
    }
  }

  // ─── Phase E.5 method ─────────────────────────────────────────────────

  /// Load the full plan history for [userId], optionally filtered by
  /// [status]. Re-fires whenever the chip filter changes.
  Future<void> loadHistoryForUser(
    int userId, {
    DietPlanStatusV2? status,
  }) async {
    historyTargetUserId.value = userId;
    historyStatusFilter.value = status;
    isHistoryLoading.value = true;
    historyError.value = null;
    try {
      final plans = await repo.listPlansForUser(
        accessToken: _token,
        userId: userId,
        status: status,
      );
      userHistory.assignAll(plans);
    } on DietPlanApiException catch (e) {
      historyError.value = e.message;
      userHistory.clear();
    } catch (_) {
      historyError.value =
          'Network error — check your connection and try again';
      userHistory.clear();
    } finally {
      isHistoryLoading.value = false;
    }
  }
}
