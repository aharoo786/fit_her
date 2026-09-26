import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../data/controllers/diet_contoller/diet_controller.dart';
import '../../data/models/diet_appointments.dart' as diet_models;
import '../../values/my_colors.dart';
import '../../widgets/circular_progress.dart';
import 'dietitian_v2/client_consultation_screen.dart';
import 'dietitian_v2/plans_to_deliver_screen.dart';

/// The native equivalent of the "Start a session" card in the standalone
/// dietitian-link-tool.html web page — reachable now by tapping the
/// "Consultations today" tile on the dashboard, instead of needing a
/// separate browser tool. Lists every upcoming, still-relevant booking
/// (not only today's — a session can be started whenever it makes
/// sense, not just on its exact calendar day) and lets her flip a
/// confirmed one to "In Progress" so the client's Join Meeting button
/// turns green, without leaving the app.
class TodaySessionsScreen extends StatelessWidget {
  TodaySessionsScreen({super.key});
  final DietController dietController = Get.find();

  List<diet_models.Appointment> _upcomingAppointments() {
    final appts = dietController.dietAppointmentsModel?.appointments ?? [];
    final filtered = appts
        .where((a) =>
            a.status != 'canceled' &&
            a.status != 'canceledByUser' &&
            a.status != 'completed')
        .toList();
    filtered.sort((a, b) => a.date.compareTo(b.date));
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(
        () {
          Get.back();
        },
        text: "Your Consultations",
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Text(
              "Start any confirmed session whenever it's time — the client's "
              "Join Meeting button turns green as soon as you do.",
              style: textTheme.bodySmall!.copyWith(
                  fontWeight: FontWeight.w400,
                  height: 1.6,
                  color: Colors.black.withOpacity(0.4)),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Obx(() {
                if (!dietController.appointmentLoad.value) {
                  return CircularProgress();
                }
                final upcomingAppts = _upcomingAppointments();
                if (upcomingAppts.isEmpty) {
                  return Center(
                    child: Text(
                      "No upcoming consultations yet.",
                      style: textTheme.bodyMedium!.copyWith(
                          color: Colors.black.withOpacity(0.4)),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: upcomingAppts.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _SessionRow(appointment: upcomingAppts[index]);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  final diet_models.Appointment appointment;
  const _SessionRow({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final DietController dietController = Get.find();
    final clientName = appointment.clientUser == null
        ? 'Client'
        : "${appointment.clientUser!.firstName} ${appointment.clientUser!.lastName}"
            .trim();
    final timeRange = appointment.slotDiet == null
        ? ''
        : "${appointment.slotDiet!.start ?? '?'} – ${appointment.slotDiet!.end ?? '?'}";
    // The list now spans more than just today, so each row needs its
    // own date, not only its time — otherwise two different days'
    // bookings look identical.
    final now = DateTime.now();
    final apptDate = appointment.date;
    final isToday = apptDate.year == now.year &&
        apptDate.month == now.month &&
        apptDate.day == now.day;
    final dateLabel =
        isToday ? 'Today' : DateFormat('EEE, MMM d').format(apptDate);
    final status = appointment.status;
    final isConfirmed = status == 'confirmed';
    final isLive = status == 'In Progress';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clientName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: MyColors.textColor,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        timeRange.isEmpty
                            ? dateLabel
                            : "$dateLabel · $timeRange",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black.withOpacity(0.45),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: status),
            ],
          ),
          const SizedBox(height: 12),
          if (isConfirmed)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC0392B),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () =>
                    dietController.startAppointmentSession(appointment.id),
                child: const Text(
                  'Start session',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            )
          else if (isLive)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF2F8A3A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Live — the client can join now',
                style: TextStyle(
                    color: Color(0xFF2F8A3A), fontWeight: FontWeight.w600),
              ),
            )
          else
            Text(
              status == 'pending'
                  ? 'Waiting on your confirmation — see Requests.'
                  : status == 'completed'
                      ? 'Completed'
                      : status,
              style: TextStyle(
                fontSize: 12.5,
                color: Colors.black.withOpacity(0.45),
              ),
            ),
          // Same three actions the client's profile screen has always
          // had (Join call / Completed / Cancel) — available right here
          // too, once there's an actual live-or-confirmed session to
          // act on, so ending or canceling a consultation doesn't mean
          // leaving this list to go find the client's profile.
          if (isConfirmed || isLive) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MiniAction(
                  icon: Icons.phone_outlined,
                  label: 'Join call',
                  color: MyColors.textColor,
                  bg: Colors.black.withOpacity(0.05),
                  onTap: () =>
                      dietController.openMeetLink(appointment.resolvedMeetLink),
                ),
                // Review and edit her pre-consultation form live during
                // the call. Whatever is saved here feeds the AI plan.
                _MiniAction(
                  icon: Icons.assignment_outlined,
                  label: 'Client form',
                  color: MyColors.textColor,
                  bg: Colors.black.withOpacity(0.05),
                  onTap: () => Get.to(() => ClientConsultationScreen(
                        userId: appointment.userId,
                        clientName: clientName,
                      )),
                ),
                _MiniAction(
                  icon: Icons.done_all_rounded,
                  label: 'Completed',
                  color: MyColors.textColor,
                  bg: Colors.white,
                  bordered: true,
                  onTap: () => _markCompleted(dietController, appointment),
                ),
                _MiniAction(
                  icon: Icons.close_rounded,
                  label: 'Cancel',
                  color: const Color(0xFFC0392B),
                  bg: const Color(0xFFFBEAEA),
                  onTap: () => _confirmCancel(context, dietController, appointment),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Ends the consultation, then points the dietitian straight at the
/// next step: her plan is now due within 48 hours.
Future<void> _markCompleted(
  DietController dietController,
  diet_models.Appointment appointment,
) async {
  final ok = await dietController.setAppointmentStatusInline(
      appointment.id, 'completed');
  if (!ok) return;
  dietController.clientsOfDietFunc();
  final goNow = await Get.dialog<bool>(
    AlertDialog(
      title: const Text('Consultation completed'),
      content: const Text(
        'Her plan is now due within 48 hours. Want to create it now?',
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back<bool>(result: false),
          child: const Text('Later'),
        ),
        TextButton(
          onPressed: () => Get.back<bool>(result: true),
          child: const Text('Create plan'),
        ),
      ],
    ),
  );
  if (goNow == true) {
    Get.to(() => const PlansToDeliverScreen());
  }
}

Future<void> _confirmCancel(
  BuildContext context,
  DietController dietController,
  diet_models.Appointment appointment,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Cancel this consultation?'),
      content: const Text(
        "This cancels the session for the client. They'll need to book a new time if they still want one.",
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
  if (confirmed == true) {
    await dietController.setAppointmentStatusInline(appointment.id, 'canceled');
  }
}

/// Small pill action button — Join call / Completed / Cancel, same
/// shape as ClientDetailsScreen's _MiniActionChip but private to this
/// file (Dart's underscore privacy is per-file, not shareable across
/// screens).
class _MiniAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;
  final bool bordered;
  final VoidCallback onTap;

  const _MiniAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
    required this.onTap,
    this.bordered = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: bordered
              ? Border.all(color: Colors.black.withOpacity(0.1))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isLive = status == 'In Progress';
    final isConfirmed = status == 'confirmed';
    final bg = isLive
        ? const Color(0xFF2F8A3A).withOpacity(0.12)
        : isConfirmed
            ? MyColors.buttonColor.withOpacity(0.12)
            : Colors.black.withOpacity(0.06);
    final fg = isLive
        ? const Color(0xFF2F8A3A)
        : isConfirmed
            ? MyColors.buttonColor
            : Colors.black.withOpacity(0.5);
    final label = isLive ? 'LIVE' : status.toUpperCase();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: fg,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
