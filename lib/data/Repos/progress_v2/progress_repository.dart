import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../values/constants.dart';
import '../../api_provider/api_provider.dart';
import '../../models/progress_v2/progress_models.dart';

/// Phase D — Repository for the Progress hub. One method per Phase B
/// endpoint. Each method:
///   * reads the access token from SharedPreferences (matches HomeRepo's
///     self-contained pattern — controller doesn't have to thread it),
///   * sends `?period=…&asOf=…` query params,
///   * applies a 15-second timeout so a hung endpoint never blocks the UI,
///   * returns `null` on any failure (network error, timeout, malformed
///     body, status != "1") — controllers translate null → error state.
///
/// All six methods follow the same shape so the controller can call them
/// uniformly via `Future.wait`.
class ProgressRepository extends GetxService {
  final ApiProvider apiProvider;

  ProgressRepository({required this.apiProvider});

  /// 15s timeout per call. Brief §4.2 budgeted summary < 300ms server-side;
  /// 15s gives generous headroom for slow networks before we error-state.
  static const Duration _timeout = Duration(seconds: 15);

  // ───────── private plumbing ────────────────────────────────────────────

  String _token() {
    final prefs = Get.find<SharedPreferences>();
    return prefs.getString(Constants.accessToken) ?? '';
  }

  Map<String, String> _query(String period, String? asOf) => {
        'period': period,
        if (asOf != null && asOf.isNotEmpty) 'asOf': asOf,
      };

  Future<Map<String, dynamic>?> _getData(
    String url, {
    required String period,
    String? asOf,
    Map<String, String>? extraQuery,
  }) async {
    try {
      final token = _token();
      if (token.isEmpty) return null;
      final response = await apiProvider
          .getData(
            url,
            query: {..._query(period, asOf), ...?extraQuery},
            headers: {'accessToken': token},
          )
          .timeout(_timeout);
      final body = response.body;
      if (body is! Map) return null;
      if (body['status'] != '1') return null;
      final data = body['data'];
      if (data is! Map) return null;
      return Map<String, dynamic>.from(data);
    } catch (e) {
      // Caller maps null → error UI. Avoid throwing across the boundary.
      debugPrint('[ProgressRepository] $url failed: $e');
      return null;
    }
  }

  // ───────── public methods (one per endpoint) ───────────────────────────

  /// B1 — Hero block: user, cycle, goal+pace, 4 stat tiles.
  Future<ProgressSummary?> getSummary({required String period, String? asOf}) async {
    final data = await _getData(Constants.progressSummary, period: period, asOf: asOf);
    if (data == null) return null;
    return ProgressSummary.fromJson(data);
  }

  /// B2 — Weight history + phase segments + projection.
  Future<WeightTrend?> getWeight({required String period, String? asOf}) async {
    final data = await _getData(Constants.progressWeight, period: period, asOf: asOf);
    if (data == null) return null;
    return WeightTrend.fromJson(data);
  }

  /// B3 — 4 rings (classes / sleep / water / goal).
  Future<GlanceData?> getGlance({required String period, String? asOf}) async {
    final data = await _getData(Constants.progressGlance, period: period, asOf: asOf);
    if (data == null) return null;
    return GlanceData.fromJson(data);
  }

  /// B4 — Water averages + phase tip.
  Future<HydrationData?> getHydration({required String period, String? asOf}) async {
    final data = await _getData(Constants.progressHydration, period: period, asOf: asOf);
    if (data == null) return null;
    return HydrationData.fromJson(data);
  }

  /// B5 — 4 symptom rows with period-over-period deltas.
  Future<SymptomsData?> getSymptoms({required String period, String? asOf}) async {
    final data = await _getData(Constants.progressSymptoms, period: period, asOf: asOf);
    if (data == null) return null;
    return SymptomsData.fromJson(data);
  }

  /// B6 — Top-N static insights for the hub.
  Future<InsightsHubData?> getInsightsHub({
    required String period,
    String? asOf,
    int limit = 3,
  }) async {
    final data = await _getData(
      Constants.progressInsightsHub,
      period: period,
      asOf: asOf,
      extraQuery: {'limit': limit.toString()},
    );
    if (data == null) return null;
    return InsightsHubData.fromJson(data);
  }

  /// Phase E — opt-in toggle. Sets the user's feature flag server-side.
  /// Returns true on success. The local LoginModel + SharedPreferences are
  /// updated by the caller (controller) so the UI re-routes immediately
  /// without waiting for a re-login.
  Future<bool> setFeatureFlag({required String flag, required bool value}) async {
    try {
      final token = _token();
      if (token.isEmpty) return false;
      final response = await apiProvider
          .postData(
            Constants.setFeatureFlag,
            body: {'flag': flag, 'value': value},
            headers: {'accessToken': token},
          )
          .timeout(_timeout);
      final body = response.body;
      if (body is! Map) return false;
      return body['status'] == '1';
    } catch (e) {
      debugPrint('[ProgressRepository.setFeatureFlag] $e');
      return false;
    }
  }
}
