import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/controllers/consultation_controller/consultation_controller.dart';
import '../../data/controllers/paid_home_controller/paid_home_controller.dart';
import '../../data/models/consultation/pending_popup.dart';
import '../diet_screen/diet_module.dart';
import 'popups/book_initial_reminder_sheet.dart';
import 'popups/consultant_no_show_sheet.dart';
import 'popups/daily_log_reminder_sheet.dart';
import 'popups/day7_review_sheet.dart';
import 'popups/early_checkin_sheet.dart';
import 'popups/inactivity_reminder_sheet.dart';
import 'popups/medical_concern_sheet.dart';
import 'popups/photo_privacy_notice_sheet.dart';
import 'popups/plan_delayed_sheet.dart';
import 'popups/pre_consultation_form_sheet.dart';
import 'popups/progress_submission_sheet.dart';
import 'popups/renew_plan_sheet.dart';

/// Watches `paidHomeController.dashboard.value.pendingPopups` and fires
/// the highest-priority popup that hasn't already been shown in this
/// app session. Sits at the root of paid-user surfaces; when a popup
/// closes, refetches the dashboard so the next eligible popup (if any)
/// surfaces on the next reactive tick.
///
/// Best-effort: when a popup needs context the orchestrator can't
/// derive (e.g. dietitianId for a booking), it dismisses silently and
/// moves on. Building each sheet's surface lookup is the consumer
/// screen's responsibility — paid_home_screen_v2 hooks the right
/// callbacks below.
class PendingPopupOrchestrator extends StatefulWidget {
  final Widget child;

  /// Hooks for routing popups that lead to other screens. The home
  /// screen wires these to its own navigation logic so the orchestrator
  /// stays decoupled from app navigation.
  final VoidCallback? onOpenChat;
  final VoidCallback? onOpenFaq;
  final VoidCallback? onOpenWorkoutSchedule;
  final VoidCallback? onOpenRenewalPlans;
  final VoidCallback? onOpenDailyCheckin;

  const PendingPopupOrchestrator({
    Key? key,
    required this.child,
    this.onOpenChat,
    this.onOpenFaq,
    this.onOpenWorkoutSchedule,
    this.onOpenRenewalPlans,
    this.onOpenDailyCheckin,
  }) : super(key: key);

  @override
  State<PendingPopupOrchestrator> createState() =>
      _PendingPopupOrchestratorState();
}

class _PendingPopupOrchestratorState extends State<PendingPopupOrchestrator> {
  Worker? _worker;
  bool _showing = false;

  // Persisted-across-sessions cooldown so a popup that fired once doesn't
  // refire every time the user lands on Home. Server still owns long-term
  // eligibility (dismissCount caps, completedAt, etc.); this is a local
  // floor on cadence so the UI doesn't become a popup carousel.
  static const String _kShownPrefix = 'popup_shown_';
  static const Duration _defaultCooldown = Duration(hours: 24);

  // Per-popup overrides for cases where the default 24h is wrong:
  //   - Reminders that should nag faster get a shorter window
  //   - Non-urgent nudges that already have server-side cadence get a longer one
  // Server-side gates (e.g. POPUP_BOOK_INITIAL_REMINDER's 2-day lastShownAt)
  // still apply on top — this map only widens the local floor where needed.
  static const Map<String, Duration> _perPopupCooldown = {
    'POPUP_CONSULTANT_NO_SHOW': Duration(minutes: 15),
    'POPUP_PLAN_DELAYED': Duration(hours: 12),
    'POPUP_BOOK_INITIAL_REMINDER': Duration(days: 2),
    'POPUP_INACTIVITY_REMINDER': Duration(days: 3),
    'POPUP_RENEW_PLAN': Duration(days: 7),
    'POPUP_DAILY_LOG_REMINDER': Duration(hours: 20),
  };

  // In-memory cache mirroring SharedPreferences. Key = variable[+cycle],
  // value = epoch millis when the popup was last shown on this device.
  final Map<String, int> _shownAt = {};
  bool _shownLoaded = false;

  Future<void> _loadShown() async {
    if (_shownLoaded) return;
    final prefs = await SharedPreferences.getInstance();
    for (final key in prefs.getKeys()) {
      if (!key.startsWith(_kShownPrefix)) continue;
      final ts = prefs.getInt(key);
      if (ts == null) continue;
      _shownAt[key.substring(_kShownPrefix.length)] = ts;
    }
    _shownLoaded = true;
  }

  // Cycle-aware key so Day7/Day15/Day30 popups don't block each other and
  // a new cycle of the same popup type can re-fire after the previous one
  // expired its cooldown.
  String _composeKey(PendingPopup p) {
    final cycle = (p.metadata?['cycle'] ?? '').toString();
    return cycle.isEmpty ? p.variable : '${p.variable}_$cycle';
  }

  bool _wasRecentlyShown(PendingPopup p) {
    final key = _composeKey(p);
    final ts = _shownAt[key];
    if (ts == null) return false;
    final cooldown = _perPopupCooldown[p.variable] ?? _defaultCooldown;
    final shownAt = DateTime.fromMillisecondsSinceEpoch(ts);
    return DateTime.now().difference(shownAt) < cooldown;
  }

  Future<void> _markShown(PendingPopup p) async {
    final key = _composeKey(p);
    final ts = DateTime.now().millisecondsSinceEpoch;
    _shownAt[key] = ts;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_kShownPrefix$key', ts);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadShown();
      final paid = Get.find<PaidHomeController>();
      // Fire on every dashboard change. ever() de-duplicates per-tick;
      // _showing guards against re-entry while a sheet is already up.
      _worker = ever(paid.dashboard, (_) => _maybeShowNext());
      // First tick — if dashboard is already loaded.
      _maybeShowNext();
    });
  }

  @override
  void dispose() {
    _worker?.dispose();
    super.dispose();
  }

  Future<void> _maybeShowNext() async {
    if (_showing) return;
    await _loadShown();
    final paid = Get.find<PaidHomeController>();
    final dashboard = paid.dashboard.value;
    if (dashboard == null) return;
    final list = dashboard.pendingPopups;
    if (list.isEmpty) return;

    // First popup not within its per-popup cooldown — list is already
    // priority-sorted server-side.
    final next = list.firstWhereOrNull(
      (p) => !_wasRecentlyShown(p),
    );
    if (next == null) return;

    await _markShown(next);
    _showing = true;
    try {
      await _dispatch(next);
    } catch (_) {
      // Swallow; orchestrator is best-effort.
    } finally {
      _showing = false;
    }

    // Refresh the dashboard so the next eligible popup (or the empty
    // state) shows up on the next reactive tick.
    try {
      await paid.refreshDashboard();
    } catch (_) {}
  }

  Future<void> _dispatch(PendingPopup p) async {
    final ctrl = Get.find<ConsultationController>();
    final meta = p.metadata ?? const {};

    int? _readInt(String key) {
      final v = meta[key];
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    String? _readStr(String key) {
      final v = meta[key];
      return v is String ? v : null;
    }

    switch (p.variable) {
      case 'POPUP_DAILY_LOG_REMINDER':
        await DailyLogReminderSheet.show(
          onLogNow: widget.onOpenDailyCheckin ?? () {},
        );
        break;

      case 'POPUP_EARLY_CHECKIN':
        await EarlyCheckinSheet.show(
          onOpenChat: widget.onOpenChat ?? () {},
          onOpenFaq: widget.onOpenFaq ?? () {},
        );
        break;

      case 'POPUP_INACTIVITY_REMINDER':
        await InactivityReminderSheet.show(
          onViewClasses: widget.onOpenWorkoutSchedule ?? () {},
        );
        break;

      case 'POPUP_PLAN_DELAYED':
        await PlanDelayedSheet.show();
        break;

      case 'POPUP_CONSULTANT_NO_SHOW':
        final apptId = _readInt('appointmentId');
        if (apptId == null) {
          // Without an appointment id we can't report — just silently
          // dismiss server-side and skip.
          await ctrl.dismissPopup(p.variable);
          break;
        }
        await ConsultantNoShowSheet.show(appointmentId: apptId);
        break;

      case 'POPUP_RENEW_PLAN':
        await RenewPlanSheet.show(
          onViewPlans: widget.onOpenRenewalPlans ?? () {},
        );
        break;

      case 'POPUP_PHOTO_PRIVACY_NOTICE':
        await PhotoPrivacyNoticeSheet.show();
        break;

      case 'POPUP_MEDICAL_CONCERN':
        // User-driven; orchestrator only ever sees this if the eligibility
        // helper opportunistically queues it (rare). Show it.
        await MedicalConcernSheet.show();
        break;

      case 'POPUP_BOOK_INITIAL_REMINDER':
        await BookInitialReminderSheet.show(
          // Per UX direction: "Book now" hands off to the existing
          // Diet consultation flow (DietScreen) — the surface users
          // already know. The reminder sheet itself retires the popup
          // (calls completePopup) before invoking onBookNow, so even
          // if the user backs out of DietScreen without booking, the
          // reminder won't re-fire in the same session.
          onBookNow: () => Get.to<dynamic>(
              () => DietScreen(fromBottomBar: false)),
        );
        break;

      case 'POPUP_BOOK_INITIAL_CONSULTATION':
      case 'POPUP_BOOK_FOLLOWUP_CONSULTATION':
        // Per UX direction: route booking pop-ups to the existing
        // DietScreen (the "Consultation" entry already in the app)
        // instead of the standalone BookConsultationSheet. The Phase
        // 1B `kind` field on Appointments stays NULL for bookings made
        // through this surface; downstream code should fall back to
        // "first appointment for the plan = initial, rest = followup"
        // when kind is missing.
        await ctrl.completePopup(p.variable);
        Get.to<dynamic>(() => DietScreen(fromBottomBar: false));
        break;

      case 'POPUP_PRE_CONSULTATION_FORM':
        final planType = _readStr('planType') ?? 'diet';
        await PreConsultationFormSheet.show(planType: planType);
        break;

      case 'POPUP_DAY7_REVIEW':
        final userPlanId = _readInt('userPlanId');
        final cycle = _readInt('cycle') ?? 1;
        final planType = _readStr('planType') ?? 'diet';
        if (userPlanId == null) {
          await ctrl.dismissPopup(p.variable);
          break;
        }
        await Day7ReviewSheet.show(
          planType: planType,
          userPlanId: userPlanId,
          cycle: cycle,
        );
        break;

      case 'POPUP_DAY15_PROGRESS':
      case 'POPUP_DAY30_PROGRESS':
        final userPlanId = _readInt('userPlanId');
        final cycle = p.variable == 'POPUP_DAY15_PROGRESS' ? 15 : 30;
        final planType = _readStr('planType') ?? 'diet';
        if (userPlanId == null) {
          await ctrl.dismissPopup(p.variable);
          break;
        }
        await ProgressSubmissionSheet.show(
          planType: planType,
          userPlanId: userPlanId,
          cycle: cycle,
        );
        break;

      default:
        // Unknown variable — eligibility helper added a popup we don't
        // know how to render. Dismiss server-side so it doesn't keep
        // returning, then move on.
        await ctrl.dismissPopup(p.variable);
        break;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
