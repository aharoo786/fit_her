import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/controllers/consultation_controller/consultation_controller.dart';
import '../../../data/models/consultation/upcoming_appointment.dart';
import '../../../widgets/toasts.dart';
import '../../../widgets/v2/v2_buttons.dart';
import 'book_consultation_sheet.dart';

const Color _kHeroDark = Color(0xFF163220);
const Color _kSage = Color(0xFF9AB09A);
const Color _kBodyMuted = Color(0xFF6F8B7A);
const Color _kAccent = Color(0xFF6DC55A);
const Color _kCardBorder = Color(0xFFD8EDD4);
const Color _kPendingTint = Color(0xFFB8790A);
const Color _kPendingBg = Color(0xFFFAC775);

// Join Meeting button stages.
const Color _kGreyBtn = Color(0xFFC9D6CE);
const Color _kGreyBtnText = Color(0xFF6F8B7A);
const Color _kYellowBtn = Color(0xFFFFC940);
const Color _kYellowBtnText = Color(0xFF6B4E00);
const Color _kGreenBtn = _kAccent;

// "Missed session" card — a soft coral, distinct from the amber
// "waiting on her" notice and the green "all done" success state.
const Color _kMissedTint = Color(0xFFC0392B);
const Color _kMissedBg = Color(0xFFF6D9D6);

/// How long before the scheduled start time the one-time "be on time"
/// caution popup fires.
const int _kCautionMinutesBefore = 15;

/// How often the card polls the server while a booking is confirmed or
/// in progress — the dietitian can add a link, hit Start, or the
/// auto-end cron can mark it completed at any moment, all server-side,
/// so this is a real refetch (not just a UI rebuild off cached data).
const Duration _kPollInterval = Duration(seconds: 20);

/// "Your booked consultation" card. Shown at the top of the Diet tab
/// whenever `ConsultationController.upcomingAppointment` is non-null.
///
/// Flow: while `pending`, Reschedule/Cancel as before. Once the
/// dietitian confirms, Reschedule is replaced by a 4-stage "Join
/// Meeting" button — grey (no link yet) -> yellow (link's in, waiting
/// for her to start) -> green (session is live, tap to join) -> a
/// post-completion "your plan will be delivered in 2 working days"
/// state. A one-time caution popup fires ~15 minutes before the
/// scheduled start so she doesn't get caught off guard.
///
/// Self-contained and reactive off the controller: the caller just
/// drops `const UpcomingConsultationCard()` into the tree and calls
/// `ConsultationController.loadUpcomingAppointment()` once (e.g. on tab
/// build + pull-to-refresh) — this widget renders nothing until that
/// resolves to a non-null booking.
class UpcomingConsultationCard extends StatefulWidget {
  const UpcomingConsultationCard({super.key});

  @override
  State<UpcomingConsultationCard> createState() =>
      _UpcomingConsultationCardState();
}

class _UpcomingConsultationCardState extends State<UpcomingConsultationCard> {
  Timer? _pollTimer;
  bool _cautionCheckInFlight = false;

  @override
  void initState() {
    super.initState();
    _pollTimer = Timer.periodic(_kPollInterval, (_) => _onTick());
    // Also run one check right away in case the app was opened already
    // inside the 15-minute caution window.
    WidgetsBinding.instance.addPostFrameCallback((_) => _onTick());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _onTick() {
    if (!mounted) return;
    final ctrl = Get.find<ConsultationController>();
    final appt = ctrl.upcomingAppointment.value;
    if (appt == null) return;
    if (appt.status == 'confirmed' || appt.status == 'In Progress') {
      ctrl.loadUpcomingAppointment();
    }
    _maybeShowCautionPopup(appt);
  }

  /// Combines `appt.date` ("2026-09-16") + `appt.slotStart` ("3:30 PM")
  /// into a real local DateTime. Wall-clock strings, same as everywhere
  /// else in this flow — assumes the device's local time is the
  /// consultation's timezone, which holds for this app's user base.
  DateTime? _scheduledStart(UpcomingAppointment appt) {
    final start = appt.slotStart?.trim();
    if (appt.date.trim().isEmpty || start == null || start.isEmpty) {
      return null;
    }
    try {
      return DateFormat('yyyy-MM-dd h:mm a').parse('${appt.date} $start');
    } catch (_) {
      return null;
    }
  }

  Future<void> _maybeShowCautionPopup(UpcomingAppointment appt) async {
    if (appt.status != 'confirmed') return;
    if (_cautionCheckInFlight) return;
    final scheduled = _scheduledStart(appt);
    if (scheduled == null) return;
    final now = DateTime.now();
    final windowStart =
        scheduled.subtract(const Duration(minutes: _kCautionMinutesBefore));
    if (now.isBefore(windowStart) || now.isAfter(scheduled)) return;

    _cautionCheckInFlight = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'consultation_caution_shown_${appt.id}';
      if (prefs.getBool(key) == true) return;
      await prefs.setBool(key, true);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Your session is coming up'),
          content: const Text(
            "Please be on time and don't delay — once your dietitian "
            'starts the session, this button will turn green. Tap it '
            'then to join.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Got it'),
            ),
          ],
        ),
      );
    } finally {
      _cautionCheckInFlight = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ConsultationController>();
    return Obx(() {
      final appt = ctrl.upcomingAppointment.value;
      if (appt == null) return const SizedBox.shrink();
      final isCompleted = appt.status == 'completed';
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: _kAccent.withOpacity(0.14),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      (appt.noShow || appt.expired)
                          ? Icons.event_busy_rounded
                          : (isCompleted
                              ? Icons.task_alt_rounded
                              : Icons.event_available_rounded),
                      color: _kAccent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appt.noShow
                              ? 'SESSION MISSED'
                              : (appt.expired
                                  ? 'BOOKING EXPIRED'
                                  : (isCompleted
                                      ? 'CONSULTATION COMPLETE'
                                      : (appt.kind == 'followup'
                                          ? 'FOLLOW-UP CONSULTATION'
                                          : 'CONSULTATION BOOKED'))),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: _kSage,
                            letterSpacing: 0.7,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _friendlyDate(appt.date),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: _kBodyMuted,
                          ),
                        ),
                        if (_formatTimeRange(appt).isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 1),
                            child: Text(
                              _formatTimeRange(appt),
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: _kHeroDark,
                              ),
                            ),
                          ),
                        if (appt.dietitianName != null &&
                            appt.dietitianName!.trim().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              'with ${appt.dietitianName}',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12.5,
                                color: _kBodyMuted,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusPill(
                    status: appt.status,
                    noShow: appt.noShow,
                    expired: appt.expired,
                  ),
                ],
              ),
              if (appt.expired) ...[
                const SizedBox(height: 14),
                _ExpiredCard(
                  onRebook: () => _onRebookAfterNoShow(context, ctrl, appt),
                ),
              ] else if (appt.noShow) ...[
                const SizedBox(height: 14),
                _NoShowCard(
                  onRebook: () => _onRebookAfterNoShow(context, ctrl, appt),
                ),
              ] else if (isCompleted) ...[
                const SizedBox(height: 14),
                _DeliveryTimeline(),
              ] else if (appt.canModify) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: V2SecondaryButton(
                        label: 'Reschedule',
                        onPressed: () => _onReschedule(context, ctrl, appt),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: V2GhostButton(
                        label: 'Cancel',
                        onPressed: () => _onCancel(context, ctrl, appt),
                      ),
                    ),
                  ],
                ),
              ] else if (appt.status == 'confirmed' ||
                  appt.status == 'In Progress') ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _JoinMeetingButton(
                        appt: appt,
                        onTap: () => _onJoinMeetingTap(context, appt),
                      ),
                    ),
                    if (appt.status == 'confirmed') ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: V2GhostButton(
                          label: 'Cancel',
                          onPressed: () => _onCancel(context, ctrl, appt),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  /// "2026-09-16" -> "Today" / "Tomorrow" / "Wed, Sep 16" (adds the year
  /// only when it isn't the current one) — a single friendly line instead
  /// of the raw ISO date, which used to wrap mid-word inside the card's
  /// narrow column.
  String _friendlyDate(String isoDate) {
    final parsed = DateTime.tryParse(isoDate);
    if (parsed == null) return isoDate;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(parsed.year, parsed.month, parsed.day);
    final diff = target.difference(today).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    final pattern = parsed.year == now.year ? 'EEE, MMM d' : 'EEE, MMM d, yyyy';
    return DateFormat(pattern).format(parsed);
  }

  /// "3:30 PM" + "4:30 PM" -> "3:30 – 4:30 PM" (drops the repeated AM/PM
  /// when both ends share it) so the time range reads as one short line
  /// instead of "3:30 PM–4:30 PM" running into the date above it.
  String _formatTimeRange(UpcomingAppointment appt) {
    final start = appt.slotStart;
    final end = appt.slotEnd;
    if (start == null || start.trim().isEmpty) return '';
    if (end == null || end.trim().isEmpty) return start.trim();
    final suffix = RegExp(r'^(.*?)\s*(AM|PM)$', caseSensitive: false);
    final startMatch = suffix.firstMatch(start.trim());
    final endMatch = suffix.firstMatch(end.trim());
    if (startMatch != null &&
        endMatch != null &&
        startMatch.group(2)!.toUpperCase() == endMatch.group(2)!.toUpperCase()) {
      return '${startMatch.group(1)} – ${end.trim()}';
    }
    return '${start.trim()} – ${end.trim()}';
  }

  Future<void> _onReschedule(
    BuildContext context,
    ConsultationController ctrl,
    UpcomingAppointment appt,
  ) async {
    await BookConsultationSheet.show(
      popupVariable: 'POPUP_RESCHEDULE_CONSULTATION',
      dietitianId: appt.dietitianId,
      dietitianName: appt.dietitianName,
      userId: appt.userId,
      userPlanId: appt.userPlanId,
      kind: appt.kind ?? 'initial',
      rescheduleAppointmentId: appt.id,
    );
    // Whichever way the sheet was dismissed — booked a new slot, or the
    // user backed out — reload so the card reflects the true server
    // state rather than assuming success.
    await ctrl.loadUpcomingAppointment();
  }

  Future<void> _onCancel(
    BuildContext context,
    ConsultationController ctrl,
    UpcomingAppointment appt,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel consultation?'),
        content: Text(
          'This cancels your ${_friendlyDate(appt.date)} consultation'
          '${(appt.dietitianName != null && appt.dietitianName!.trim().isNotEmpty) ? ' with ${appt.dietitianName}' : ''}. '
          "You'll need to book a new slot if you change your mind.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep it'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Cancel it', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final ok = await ctrl.cancelAppointment(appt.id);
    if (ok) {
      CustomToast.successToast(msg: 'Consultation canceled.');
    }
  }

  Future<void> _onJoinMeetingTap(
      BuildContext context, UpcomingAppointment appt) async {
    final hasLink = appt.dietitionLink != null &&
        appt.dietitionLink!.trim().isNotEmpty;
    final isLive = appt.status == 'In Progress';

    if (isLive && hasLink) {
      final uri = Uri.tryParse(appt.dietitionLink!.trim());
      if (uri == null || !await launchUrl(uri)) {
        CustomToast.failToast(msg: "Couldn't open the meeting link.");
      }
      return;
    }

    // Not yet joinable — grey or yellow. Give a short, specific reason
    // instead of just not responding to the tap.
    final message = hasLink
        ? "Your dietitian hasn't started the session yet — this will "
            "turn green the moment she does. Tap it then to join."
        : "Your dietitian hasn't shared the meeting link yet — check "
            "back closer to your session time.";
    CustomToast.failToast(
      bgcolor: _kHeroDark,
      textColor: Colors.white,
      msg: message,
    );
  }

  /// This is a fresh booking, not a reschedule — the missed appointment
  /// is already resolved (canceled) server-side, so there's nothing to
  /// reschedule against. Reuses the same sheet the normal "book a
  /// consultation" flow uses, just without `rescheduleAppointmentId`.
  Future<void> _onRebookAfterNoShow(
    BuildContext context,
    ConsultationController ctrl,
    UpcomingAppointment appt,
  ) async {
    await BookConsultationSheet.show(
      popupVariable: appt.kind == 'followup'
          ? 'POPUP_BOOK_FOLLOWUP_CONSULTATION'
          : 'POPUP_BOOK_INITIAL_CONSULTATION',
      dietitianId: appt.dietitianId,
      dietitianName: appt.dietitianName,
      userId: appt.userId,
      userPlanId: appt.userPlanId,
      kind: appt.kind ?? 'initial',
    );
    await ctrl.loadUpcomingAppointment();
  }
}

/// The 4th "state" isn't drawn by this widget at all — once
/// `appt.status == 'completed'`, the button row is replaced entirely by
/// `_DeliveryTimeline` in the parent's build method.
class _JoinMeetingButton extends StatelessWidget {
  final UpcomingAppointment appt;
  final VoidCallback onTap;

  const _JoinMeetingButton({required this.appt, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasLink =
        appt.dietitionLink != null && appt.dietitionLink!.trim().isNotEmpty;
    final isLive = appt.status == 'In Progress';

    late final Color bg;
    late final Color fg;
    late final String label;
    late final IconData icon;

    if (isLive) {
      bg = _kGreenBtn;
      fg = Colors.white;
      label = 'Join Meeting';
      icon = Icons.videocam_rounded;
    } else if (hasLink) {
      bg = _kYellowBtn;
      fg = _kYellowBtnText;
      label = 'Join Meeting';
      icon = Icons.hourglass_top_rounded;
    } else {
      bg = _kGreyBtn;
      fg = _kGreyBtnText;
      label = 'Join Meeting';
      icon = Icons.videocam_off_rounded;
    }

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shown in place of the button row when `appt.noShow` is true — the
/// dietitian never joined (client reported it, or 24h passed with no
/// Meet attendance found), the booking has already been canceled
/// server-side, and this is a real resolution instead of the card
/// silently vanishing or leaving a dead grey/yellow button behind.
class _NoShowCard extends StatelessWidget {
  final VoidCallback onRebook;
  const _NoShowCard({required this.onRebook});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kMissedBg.withOpacity(0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kMissedTint.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.event_busy_rounded,
                  color: _kMissedTint, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Your dietitian wasn't able to join this session",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: _kMissedTint,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      "It's been canceled — book a new time whenever "
                      "works for you, free of charge.",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11.5,
                        color: _kBodyMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: V2SecondaryButton(
              label: 'Rebook — it\'s free',
              onPressed: onRebook,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown in place of the button row when `appt.expired` is true — the
/// dietitian never confirmed the booking at all before its scheduled
/// time passed, it's already been auto-canceled server-side, and this
/// tells the client plainly to book a new time instead of leaving a
/// "PENDING" card sitting there forever with a dead Reschedule/Cancel
/// row and no explanation.
class _ExpiredCard extends StatelessWidget {
  final VoidCallback onRebook;
  const _ExpiredCard({required this.onRebook});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kMissedBg.withOpacity(0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kMissedTint.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.event_busy_rounded,
                  color: _kMissedTint, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Your dietitian didn't confirm this booking in time",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: _kMissedTint,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      "It's been canceled — book a new time whenever "
                      "works for you, free of charge.",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11.5,
                        color: _kBodyMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: V2SecondaryButton(
              label: 'Reschedule — it\'s free',
              onPressed: onRebook,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown in place of the button row once `status == 'completed'` — the
/// short window the backend keeps returning a just-finished appointment
/// for, purely so this message has somewhere to land instead of the
/// card just vanishing the instant the session ends.
class _DeliveryTimeline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kAccent.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kAccent.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: _kAccent, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your plan will be delivered in 2 working days',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: _kHeroDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _TimelineStep(
            label: 'Session completed',
            done: true,
            isLast: false,
          ),
          _TimelineStep(
            label: "Dietitian prepares your plan",
            done: false,
            isLast: false,
          ),
          _TimelineStep(
            label: 'Plan delivered to you',
            done: false,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final String label;
  final bool done;
  final bool isLast;

  const _TimelineStep({
    required this.label,
    required this.done,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? _kAccent : _kAccent.withOpacity(0.25),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: _kAccent.withOpacity(0.25),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11.5,
                fontWeight: done ? FontWeight.w700 : FontWeight.w500,
                color: done ? _kHeroDark : _kBodyMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;
  final bool noShow;
  final bool expired;
  const _StatusPill({
    required this.status,
    this.noShow = false,
    this.expired = false,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = status == 'pending';
    final isLive = status == 'In Progress';
    final isCompleted = status == 'completed';
    final bg = (noShow || expired)
        ? _kMissedBg
        : (isPending ? _kPendingBg : _kAccent);
    final fg = (noShow || expired)
        ? _kMissedTint
        : (isPending ? _kPendingTint : _kAccent);
    final label = noShow
        ? 'MISSED'
        : (expired
            ? 'EXPIRED'
            : (isPending
                ? 'PENDING'
                : (isLive ? 'LIVE' : (isCompleted ? 'DONE' : 'CONFIRMED'))));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg.withOpacity(0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          color: fg,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kCardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: _kHeroDark.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 10,
          ),
        ],
      ),
      child: child,
    );
  }
}
