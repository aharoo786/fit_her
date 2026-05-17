import 'package:get/get.dart';

import '../../../values/constants.dart';
import '../../api_provider/api_provider.dart';
import '../../models/diet_plan_v2/diet_plan_v2_models.dart';

/// Thrown when the backend returns `status: "0"` or an unexpected
/// payload shape. Carries the user-facing message + optional validation
/// errors from the AI service so the screen can render specifics
/// (e.g. "validation failed: ...") instead of a generic toast.
class DietPlanApiException implements Exception {
  final String message;
  final List<String> validationErrors;
  final int? statusCode;

  DietPlanApiException(
    this.message, {
    this.validationErrors = const [],
    this.statusCode,
  });

  @override
  String toString() => 'DietPlanApiException: $message';
}

/// Repository for the dietitian/admin-side diet-plan endpoints.
///
/// Mirrors `partner_backend/routes/Admin/dietPlan.js`:
///   POST   /admin/diet-plan/generate
///   GET    /admin/diet-plan/drafts
///   GET    /admin/diet-plan/user/:userId/list?status=
///   GET    /admin/diet-plan/:id
///   POST   /admin/diet-plan/:id/activate
///   POST   /admin/diet-plan/:id/cancel
///   PATCH  /admin/diet-plan/meal/:mealId
///
/// Methods return parsed models (or `Future<List<...>>`) and throw
/// [DietPlanApiException] on backend `status: "0"` or transport errors.
/// Screen code never has to reach into `response.body` directly.
class DietPlanAdminRepository extends GetxService {
  final ApiProvider apiProvider;
  DietPlanAdminRepository({required this.apiProvider});

  Map<String, String> _headers(String accessToken) => {
        'accessToken': accessToken,
      };

  /// POST /admin/diet-plan/generate
  Future<DietPlanV2> generatePlan({
    required String accessToken,
    required int userId,
    required int userPlanId,
    int planDays = 7,
    int? mealsPerDay,
  }) async {
    final body = <String, dynamic>{
      'userId': userId,
      'userPlanId': userPlanId,
      'planDays': planDays,
      if (mealsPerDay != null) 'mealsPerDay': mealsPerDay,
    };
    final res = await _safe(() => apiProvider.postData(
          Constants.dietPlanAdminGenerate,
          body: body,
          headers: _headers(accessToken),
        ));
    return _extractPlan(res);
  }

  /// GET /admin/diet-plan/:id
  Future<DietPlanV2> getPlanById({
    required String accessToken,
    required int id,
  }) async {
    final path = Constants.dietPlanAdminById.replaceFirst('{id}', '$id');
    final res = await _safe(() => apiProvider.getData(
          path,
          headers: _headers(accessToken),
        ));
    return _extractPlan(res);
  }

  /// POST /admin/diet-plan/:id/activate
  Future<DietPlanV2> activatePlan({
    required String accessToken,
    required int id,
  }) async {
    final path = Constants.dietPlanAdminActivate.replaceFirst('{id}', '$id');
    final res = await _safe(() => apiProvider.postData(
          path,
          body: const {},
          headers: _headers(accessToken),
        ));
    return _extractPlan(res);
  }

  /// POST /admin/diet-plan/:id/cancel
  Future<DietPlanV2> cancelPlan({
    required String accessToken,
    required int id,
    String? reason,
  }) async {
    final path = Constants.dietPlanAdminCancel.replaceFirst('{id}', '$id');
    final body = <String, dynamic>{};
    if (reason != null && reason.trim().isNotEmpty) body['reason'] = reason;
    final res = await _safe(() => apiProvider.postData(
          path,
          body: body,
          headers: _headers(accessToken),
        ));
    return _extractPlan(res);
  }

  /// GET /admin/diet-plan/user/:userId/list?status=...
  Future<List<DietPlanV2>> listPlansForUser({
    required String accessToken,
    required int userId,
    DietPlanStatusV2? status,
  }) async {
    final path =
        Constants.dietPlanAdminUserList.replaceFirst('{userId}', '$userId');
    final query =
        status != null ? {'status': dietPlanStatusToString(status)} : null;
    final res = await _safe(() => apiProvider.getData(
          path,
          query: query,
          headers: _headers(accessToken),
        ));
    return _extractPlans(res);
  }

  /// GET /admin/diet-plan/drafts
  Future<List<DietPlanV2>> listMyDrafts({required String accessToken}) async {
    final res = await _safe(() => apiProvider.getData(
          Constants.dietPlanAdminDrafts,
          headers: _headers(accessToken),
        ));
    return _extractPlans(res);
  }

  /// PATCH /admin/diet-plan/meal/:mealId
  /// Returns the freshly-saved meal. The backend also returns the
  /// updated parent day (with recomputed totalCalories) — exposed as
  /// the second tuple slot so the screen can refresh both at once.
  Future<({DietPlanMealV2 meal, DietPlanDayV2 day})> updateMeal({
    required String accessToken,
    required int mealId,
    String? foodName,
    int? calories,
    String? time,
    String? notes,
    MealTypeV2? mealType,
  }) async {
    final body = <String, dynamic>{};
    if (foodName != null) body['foodName'] = foodName;
    if (calories != null) body['calories'] = calories;
    if (time != null) body['time'] = time;
    if (notes != null) body['notes'] = notes;
    if (mealType != null) body['mealType'] = mealType.wire;

    if (body.isEmpty) {
      throw DietPlanApiException('At least one field must be provided');
    }

    final path = Constants.dietPlanAdminUpdateMeal
        .replaceFirst('{mealId}', '$mealId');
    final res = await _safe(() => apiProvider.patchData(
          path,
          body: body,
          headers: _headers(accessToken),
        ));
    final data = _expectOk(res);
    final mealJson = data['meal'];
    final dayJson = data['day'];
    if (mealJson is! Map || dayJson is! Map) {
      throw DietPlanApiException('updateMeal response missing meal/day');
    }
    return (
      meal: DietPlanMealV2.fromJson(Map<String, dynamic>.from(mealJson)),
      day: DietPlanDayV2.fromJson(Map<String, dynamic>.from(dayJson)),
    );
  }

  // ─── Internals ─────────────────────────────────────────────────────────

  /// Wraps a transport call so socket errors / parse exceptions surface
  /// as [DietPlanApiException] with a friendly message instead of
  /// leaking raw stack traces to the UI.
  Future<Response> _safe(Future<Response> Function() fn) async {
    try {
      return await fn();
    } on DietPlanApiException {
      rethrow;
    } catch (e) {
      throw DietPlanApiException(
        'Network error — check your connection and try again',
      );
    }
  }

  /// Confirm the envelope says success and return the inner `data`.
  Map<String, dynamic> _expectOk(Response res) {
    final body = res.body;
    if (body is! Map) {
      throw DietPlanApiException(
        'Unexpected server response',
        statusCode: res.statusCode,
      );
    }
    if (body['status']?.toString() != '1') {
      final validation = body['data'] is Map &&
              (body['data']['validation'] is Map) &&
              ((body['data']['validation'] as Map)['errors'] is List)
          ? List<String>.from(
              ((body['data']['validation'] as Map)['errors'] as List)
                  .map((e) => e.toString()),
            )
          : const <String>[];
      throw DietPlanApiException(
        body['message']?.toString() ?? 'Request failed',
        statusCode: res.statusCode,
        validationErrors: validation,
      );
    }
    final data = body['data'];
    return data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
  }

  DietPlanV2 _extractPlan(Response res) {
    final data = _expectOk(res);
    final raw = data['dietPlan'];
    if (raw is! Map) {
      throw DietPlanApiException('Server response missing dietPlan');
    }
    return DietPlanV2.fromJson(Map<String, dynamic>.from(raw));
  }

  List<DietPlanV2> _extractPlans(Response res) {
    final data = _expectOk(res);
    final raw = data['plans'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((p) => DietPlanV2.fromJson(Map<String, dynamic>.from(p)))
        .toList();
  }
}
