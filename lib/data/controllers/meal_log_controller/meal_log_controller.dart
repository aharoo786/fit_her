import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../values/constants.dart';
import '../../../widgets/toasts.dart';
import '../../Repos/home_repo/home_repo.dart';
import '../../models/meal_log/meal_log.dart';

/// Drives the home meal-log tile (Phase 2D), the options sheet, and the
/// 7-day edit history screen. Holds today's three meal rows and the most
/// recent upsert's prior state for the undo flow (Section 6.5).
class MealLogController extends GetxController {
  final HomeRepo homeRepo;
  final SharedPreferences sharedPreferences;

  MealLogController({
    required this.homeRepo,
    required this.sharedPreferences,
  });

  String get _token =>
      sharedPreferences.getString(Constants.accessToken) ?? '';

  /// Today's three meals, indexed by mealType. Pending-default rows are
  /// synthesised client-side when the server hasn't seen a log yet —
  /// upserts replace them on save.
  final RxMap<MealType, MealLog> todayMeals = <MealType, MealLog>{}.obs;
  final RxBool loading = false.obs;
  final RxString errorMessage = ''.obs;

  /// Drives the home meal-log card's accordion state. The Nutrition stat
  /// card on the same screen toggles this Rx (its right arrow rotates
  /// from → to ↓), and the meal-log card animates open/closed in
  /// response. Defaults to collapsed so tapping "Log {meal} →" has a
  /// visible effect.
  final RxBool todayMealsExpanded = false.obs;

  void toggleTodayMeals() {
    todayMealsExpanded.value = !todayMealsExpanded.value;
  }

  void openTodayMeals() {
    todayMealsExpanded.value = true;
  }

  /// Snapshot of the last meal that was upserted. Used by the undo
  /// snackbar to revert. Only valid for ~5 seconds; cleared after.
  MealLog? _lastUpsertPrevious;

  String _todayDate() {
    final now = DateTime.now();
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '${now.year}-$m-$d';
  }

  /// Fetches today's three meal logs. Synthesises pending rows for any
  /// meal that hasn't been logged yet so the home tile always shows
  /// three slots.
  Future<void> loadToday() async {
    if (loading.value) return;
    loading.value = true;
    errorMessage.value = '';
    try {
      final response = await homeRepo.listMealLogs(
        accessToken: _token,
        from: _todayDate(),
        to: _todayDate(),
      );
      final body = response.body;
      if (body is! Map ||
          body['status'] != '1' ||
          body['data']?['mealLogs'] is! List) {
        errorMessage.value = 'Could not load meal log';
        _seedPending();
        return;
      }
      final list = (body['data']['mealLogs'] as List)
          .whereType<Map>()
          .map((m) => MealLog.fromJson(Map<String, dynamic>.from(m)))
          .toList();

      final next = <MealType, MealLog>{};
      for (final t in MealType.values) {
        next[t] = list.firstWhereOrNull((m) => m.mealType == t) ??
            _pendingFor(t);
      }
      todayMeals.assignAll(next);
    } catch (e) {
      errorMessage.value = 'Could not load meal log';
      _seedPending();
    } finally {
      loading.value = false;
    }
  }

  void _seedPending() {
    final next = <MealType, MealLog>{};
    for (final t in MealType.values) {
      next[t] = _pendingFor(t);
    }
    todayMeals.assignAll(next);
  }

  MealLog _pendingFor(MealType t) => MealLog(
        date: _todayDate(),
        mealType: t,
        status: MealStatus.pending,
        editable: true,
      );

  /// Upserts the meal log. Stashes the previous state so the undo
  /// snackbar can revert. Returns true on success.
  Future<bool> upsertToday({
    required MealType mealType,
    required MealStatus status,
    String? reasonCode,
    String? alternativeText,
  }) async {
    final previous = todayMeals[mealType];
    final body = <String, dynamic>{
      'date': _todayDate(),
      'mealType': mealTypeToString(mealType),
      'status': mealStatusToString(status),
      if (reasonCode != null) 'reasonCode': reasonCode,
      if (alternativeText != null) 'alternativeText': alternativeText,
    };
    try {
      final response = await homeRepo.upsertMealLog(
        accessToken: _token,
        body: body,
      );
      final responseBody = response.body;
      if (responseBody is Map && responseBody['status'] == '1') {
        _lastUpsertPrevious = previous;
        await loadToday();
        return true;
      }
      CustomToast.failToast(msg: 'Could not save. Please try again.');
      return false;
    } catch (_) {
      CustomToast.failToast(msg: 'Could not save. Please try again.');
      return false;
    }
  }

  /// Reverts the last upsert. If the previous state was a synthesised
  /// pending row, we send `pending` to the server (it will create a
  /// pending row or no-op). After 5s the snapshot is cleared so undo
  /// only affects the most recent action.
  Future<bool> undoLast() async {
    final prev = _lastUpsertPrevious;
    if (prev == null) return false;
    _lastUpsertPrevious = null;
    return upsertToday(
      mealType: prev.mealType,
      status: prev.status,
      reasonCode: prev.reasonCode,
      alternativeText: prev.alternativeText,
    );
  }

  void clearUndoSnapshot() {
    _lastUpsertPrevious = null;
  }

  /// History fetch for the edit-history screen. Server enforces the
  /// 7-day edit window and returns `editable` per row.
  Future<List<MealLog>> loadHistory({String? from, String? to}) async {
    try {
      final response = await homeRepo.listMealLogs(
        accessToken: _token,
        from: from,
        to: to,
      );
      final body = response.body;
      if (body is! Map ||
          body['status'] != '1' ||
          body['data']?['mealLogs'] is! List) {
        return const [];
      }
      return (body['data']['mealLogs'] as List)
          .whereType<Map>()
          .map((m) => MealLog.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    } catch (_) {
      return const [];
    }
  }
}
