import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

/// "Your booked consultation" card. Shown at the top of the Diet tab
/// whenever `ConsultationController.upcomingAppointment` is non-null —
/// i.e. the user has a pending/confirmed/in-progress booking. Lets her
/// see what she booked (date, time, dietitian, status) without hunting
/// for it, and gives Reschedule/Cancel so a mistake or change of plans
/// doesn't require contacting support.
///
/// Self-contained and reactive off the controller: the caller just
/// drops `const UpcomingConsultationCard()` into the tree and calls
/// `ConsultationController.loadUpcomingAppointment()` once (e.g. on tab
/// build + pull-to-refresh) — this widget renders nothing until that
/// resolves to a non-null booking.
class UpcomingConsultationCard extends StatelessWidget {
  const UpcomingConsultationCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ConsultationController>();
    return Obx(() {
      final appt = ctrl.upcomingAppointment.value;
      if (appt == null) return const SizedBox.shrink();
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
                    child: const Icon(Icons.event_available_rounded,
                        color: _kAccent, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appt.kind == 'followup'
                              ? 'FOLLOW-UP CONSULTATION'
                              : 'CONSULTATION BOOKED',
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
                          _formatWhen(appt),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _kHeroDark,
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
                  _StatusPill(status: appt.status),
                ],
              ),
              if (appt.canModify) ...[
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
              ] else if (appt.status == 'In Progress') ...[
                const SizedBox(height: 10),
                const Text(
                  'Session in progress — your dietitian has started this '
                  'consultation.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: _kBodyMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  String _formatWhen(UpcomingAppointment appt) {
    final hasTime = appt.slotStart != null && appt.slotStart!.isNotEmpty;
    final time = hasTime
        ? ' · ${appt.slotStart}${(appt.slotEnd != null && appt.slotEnd!.isNotEmpty) ? '–${appt.slotEnd}' : ''}'
        : '';
    return '${appt.date}$time';
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
          'This cancels your ${appt.date} consultation'
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
}

class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final isPending = status == 'pending';
    final isLive = status == 'In Progress';
    final bg = isPending ? _kPendingBg : _kAccent;
    final fg = isPending ? _kPendingTint : _kAccent;
    final label = isPending ? 'PENDING' : (isLive ? 'LIVE' : 'CONFIRMED');
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
