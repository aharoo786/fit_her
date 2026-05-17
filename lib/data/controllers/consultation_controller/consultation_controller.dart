import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../values/constants.dart';
import '../../../widgets/toasts.dart';
import '../../Repos/home_repo/home_repo.dart';
import '../../models/consultation/dietitian_availability.dart';
import '../../models/consultation/pre_consultation_profile.dart';

/// Glue between the consultation-flow pop-ups (Phase 2C) and the new
/// Phase 1B endpoints. Kept thin: each method is one network call +
/// envelope-aware result. Heavier UX state (in-flight submission flags,
/// optimistic state) lives inside the sheets that own it.
class ConsultationController extends GetxController {
  final HomeRepo homeRepo;
  final SharedPreferences sharedPreferences;

  ConsultationController({
    required this.homeRepo,
    required this.sharedPreferences,
  });

  String get _token =>
      sharedPreferences.getString(Constants.accessToken) ?? '';

  // ── Pre-consultation profile ─────────────────────────────────────────

  /// Loads the user's pre-consultation profile (creates an empty draft
  /// row server-side on first call). Returns null on any failure — the
  /// form sheets fall back to a fresh blank state in that case.
  Future<PreConsultationProfile?> loadProfile() async {
    try {
      final response = await homeRepo.getPreConsultationProfile(
        accessToken: _token,
      );
      final body = response.body;
      if (body is! Map ||
          body['status'] != '1' ||
          body['data']?['profile'] is! Map) {
        return null;
      }
      return PreConsultationProfile.fromJson(
        Map<String, dynamic>.from(body['data']['profile'] as Map),
      );
    } catch (_) {
      return null;
    }
  }

  /// Per-step PATCH (Decision 5). Returns true on `status:"1"`. The
  /// caller passes the partial body — controller doesn't second-guess
  /// what fields belong to the current step.
  Future<bool> patchProfile(Map<String, dynamic> body) async {
    try {
      final response = await homeRepo.patchPreConsultationProfile(
        accessToken: _token,
        body: body,
      );
      final json = response.body;
      // apiProvider.putData returns the http.Response; body may already
      // be Map (we set application/json) or raw String — accept both.
      final parsed = json is String ? jsonDecode(json) : json;
      return parsed is Map && parsed['status'] == '1';
    } catch (_) {
      return false;
    }
  }

  // ── Popup state acks ─────────────────────────────────────────────────

  Future<void> dismissPopup(
    String variable, {
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await homeRepo.dismissPopup(
        accessToken: _token,
        variable: variable,
        metadata: metadata,
      );
    } catch (_) {
      // Server-side state is the source of truth for re-eligibility.
      // A failed dismiss just means the popup may show again next
      // dashboard fetch — acceptable.
    }
  }

  Future<void> completePopup(
    String variable, {
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await homeRepo.completePopup(
        accessToken: _token,
        variable: variable,
        metadata: metadata,
      );
    } catch (_) {
      // Completion is idempotent — controllers that perform a domain
      // action (submit review, submit progress) ALSO retire the popup
      // server-side. This call is a belt-and-braces backup.
    }
  }

  // ── Booking calendar ─────────────────────────────────────────────────

  /// Loads dietitian availability for the next 14 days (server-side
  /// default) or a custom range. Returns null on failure — sheet shows
  /// an inline error state instead of a stale list.
  Future<DietitianAvailability?> loadAvailability({
    required int dietitianId,
    String? from,
    String? to,
  }) async {
    try {
      final response = await homeRepo.getDietitianAvailability(
        accessToken: _token,
        dietitianId: dietitianId,
        from: from,
        to: to,
      );
      final body = response.body;
      if (body is! Map ||
          body['status'] != '1' ||
          body['data'] is! Map) {
        return null;
      }
      return DietitianAvailability.fromJson(
        Map<String, dynamic>.from(body['data'] as Map),
      );
    } catch (_) {
      return null;
    }
  }

  /// Books a consultation. Returns true on success — caller decides what
  /// to do next (close sheet, retire popup, show toast).
  Future<bool> bookConsultation({
    required String date,        // YYYY-MM-DD
    required int userId,
    required int dietitianId,
    required int timeSlotId,     // SlotDiet.id
    required int userPlanId,
    required String kind,        // "initial" | "followup"
  }) async {
    try {
      final response = await homeRepo.bookConsultation(
        accessToken: _token,
        body: {
          'date': date,
          'userId': userId,
          // Backend column has the historical typo `dietitionId` (kept
          // per CLAUDE.md instruction). Don't "fix" it here.
          'dietitionId': dietitianId,
          'timeSlotId': timeSlotId,
          'userPlanId': userPlanId,
          'kind': kind,
        },
      );
      final body = response.body;
      final ok = body is Map && body['status'] == '1';
      if (!ok && body is Map) {
        CustomToast.failToast(
            msg: body['message']?.toString() ?? 'Could not book');
      }
      return ok;
    } catch (_) {
      CustomToast.failToast(msg: 'Could not book. Please try again.');
      return false;
    }
  }

  // ── Progress submission (Day 15 / Day 30) ───────────────────────────

  /// Body must match ProgressSubmission.toJson(). Server is idempotent
  /// on (userPlanId, cycle) — re-opening the sheet overwrites the prior
  /// submission. Photos are NEVER part of this body (Section 10).
  Future<bool> submitProgress(Map<String, dynamic> body) async {
    try {
      final response = await homeRepo.submitProgress(
        accessToken: _token,
        body: body,
      );
      final responseBody = response.body;
      final ok = responseBody is Map && responseBody['status'] == '1';
      if (!ok && responseBody is Map) {
        CustomToast.failToast(
            msg: responseBody['message']?.toString() ??
                'Could not submit progress');
      }
      return ok;
    } catch (_) {
      CustomToast.failToast(msg: 'Could not submit progress.');
      return false;
    }
  }

  // ── Day 7 review ─────────────────────────────────────────────────────

  /// Submits a Day 7 review. Body must match Day7Review.toJson(). The
  /// server hook computes flagged + flagReasons (Decision 6 thresholds:
  /// adherence < 40, pain reported, severe side effects, satisfaction
  /// < 2). Client never overrides the flag. Returns true on success.
  Future<bool> submitDay7Review(Map<String, dynamic> body) async {
    try {
      final response = await homeRepo.submitDay7Review(
        accessToken: _token,
        body: body,
      );
      final responseBody = response.body;
      final ok = responseBody is Map && responseBody['status'] == '1';
      if (!ok && responseBody is Map) {
        CustomToast.failToast(
            msg: responseBody['message']?.toString() ??
                'Could not submit review');
      }
      return ok;
    } catch (_) {
      CustomToast.failToast(msg: 'Could not submit review.');
      return false;
    }
  }

  // ── Escalations ──────────────────────────────────────────────────────

  /// User self-reports a medical concern (FAB / popup CTA). Opens a
  /// MEDICAL escalation server-side which fans out to admin + dietitian.
  Future<bool> openMedicalConcern({
    String? description,
    int? severity,
  }) async {
    try {
      final response = await homeRepo.openEscalation(
        accessToken: _token,
        trigger: 'MEDICAL',
        severity: severity != null && severity >= 4 ? 'high' : 'medium',
        payload: {
          if (description != null) 'description': description,
          if (severity != null) 'severity': severity,
        },
      );
      final body = response.body;
      final ok = body is Map && body['status'] == '1';
      if (!ok) {
        CustomToast.failToast(msg: 'Could not send. Please try again.');
      }
      return ok;
    } catch (_) {
      CustomToast.failToast(msg: 'Could not send. Please try again.');
      return false;
    }
  }

  /// User self-reports their plan is delayed past Day 3. Opens a
  /// PLAN_DELAYED escalation; backend already auto-creates one when the
  /// SLA breach is detected, so this is the user-driven path.
  Future<bool> reportPlanDelayed({String? reason}) async {
    try {
      final response = await homeRepo.openEscalation(
        accessToken: _token,
        trigger: 'PLAN_DELAYED',
        severity: 'medium',
        payload: {
          if (reason != null) 'reason': reason,
        },
      );
      return response.body is Map && response.body['status'] == '1';
    } catch (_) {
      return false;
    }
  }

  /// Reports the dietitian didn't show up at the consultation slot.
  Future<bool> reportConsultantNoShow({
    required int appointmentId,
    String? reason,
  }) async {
    try {
      final response = await homeRepo.reportConsultationNoShow(
        accessToken: _token,
        appointmentId: appointmentId,
        reason: reason,
      );
      return response.body is Map && response.body['status'] == '1';
    } catch (_) {
      return false;
    }
  }
}
