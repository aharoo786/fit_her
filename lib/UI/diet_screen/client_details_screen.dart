import 'package:fitness_zone_2/UI/diet_screen/add_user_diet.dart';
import 'package:fitness_zone_2/UI/diet_screen/dietitian_v2/generate_plan_screen.dart';
import 'package:fitness_zone_2/UI/diet_screen/dietitian_v2/user_plan_history_screen.dart';
import 'package:fitness_zone_2/data/controllers/diet_contoller/diet_controller.dart';
import 'package:fitness_zone_2/data/controllers/workout_controller/work_out_controller.dart';
import 'package:fitness_zone_2/data/models/diet_appointments.dart';
import 'package:fitness_zone_2/data/models/get_clients_diet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../widgets/app_bar_widget.dart';
import '../dashboard_module/session_screen/session_screen.dart';

// ── Shared v2 design tokens ─────────────────────────────────────────────
// Same palette as dietitian_home_screen.dart / clients_screen.dart /
// flagged_reviews_screen.dart, so this — the screen a dietitian actually
// lands on the most, tapped from every client card — finally reads as
// part of the same app instead of the old bright-green banner, a pile of
// mismatched pill-button colors, and a lavender "History" card that
// matched nothing else.
const Color _kBg = Color(0xFFE8F4E0);
const Color _kInk = Color(0xFF163220);
const Color _kInkSoft = Color(0xFF6F8B7A);
const Color _kAccent = Color(0xFF6DC55A);
const Color _kAccentBg = Color(0xFFEAF7E4);
const Color _kBorder = Color(0xFFD8EDD4);
const Color _kAlert = Color(0xFFE24B4A);
const Color _kAlertBg = Color(0xFFFBEAEA);

class ClientDetailsScreen extends StatelessWidget {
  ClientDetailsScreen(
      {super.key,
      required this.clientUser,
      this.slotDiet,
      this.planId,
      this.appointmentId,
      this.status});

  final ClientUser clientUser;
  final SlotDiet? slotDiet;
  final int? planId;
  final int? appointmentId;
  final String? status;

  // Placeholder until real per-client weekly adherence is wired up
  // server-side (tracked alongside the consultation-profile plumbing
  // work) — kept visually honest as a sample rather than implying it's
  // live data for every client.
  final List<_ChartData> chartData = const [
    _ChartData('M', 100),
    _ChartData('T', 80),
    _ChartData('W', 50),
    _ChartData('T', 100),
    _ChartData('F', 70),
    _ChartData('S', 100),
    _ChartData('S', 60),
  ];

  String get _initial {
    final n = clientUser.firstName.trim();
    return n.isEmpty ? '?' : n.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: HelpingWidgets().appBarWidget(
        () => Get.back(),
        text: 'Client',
        backGroundColor: _kBg,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _profileCard(),
          const SizedBox(height: 14),
          if (slotDiet != null) ...[
            _appointmentCard(),
            const SizedBox(height: 14),
          ],
          _actionsRow(),
          const SizedBox(height: 16),
          _notesCard(context),
          const SizedBox(height: 20),
          const Text(
            "This week's progress",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: _kInk,
            ),
          ),
          const SizedBox(height: 10),
          _progressCard(),
        ],
      ),
    );
  }

  // ── Profile header ───────────────────────────────────────────────────
  Widget _profileCard() {
    return _Card(
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _kAccentBg,
              shape: BoxShape.circle,
              border: Border.all(color: _kAccent.withOpacity(0.4), width: 1.5),
            ),
            child: Text(
              _initial,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: _kInk,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "${clientUser.firstName} ${clientUser.lastName}",
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 17,
              color: _kInk,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            clientUser.email,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12.5,
              color: _kInkSoft,
            ),
          ),
        ],
      ),
    );
  }

  // ── Today's appointment (only when opened from an appointment) ───────
  Widget _appointmentCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's appointment",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
              color: _kInk,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniActionChip(
                icon: Icons.phone_outlined,
                label: 'Join call',
                color: _kInk,
                bg: _kAccentBg,
                onTap: () {
                  Get.to(() => SessionScreen(
                        link: slotDiet?.dietitionLink,
                        slotId: slotDiet?.id ?? 0,
                        isDiet: true,
                        userId: clientUser.id,
                        token: "",
                      ));
                  Get.find<WorkOutController>()
                      .getFreeTrialUserDetails(slotDiet!.id.toString());
                },
              ),
              _MiniActionChip(
                icon: Icons.check_circle_outline,
                label: 'Confirm',
                color: _kInk,
                bg: Colors.white,
                bordered: true,
                onTap: () => Get.find<DietController>().updateAppointmentStatus(
                    appointmentId ?? 0, "confirmed",
                    isFromAppointment: true),
              ),
              _MiniActionChip(
                icon: Icons.done_all_rounded,
                label: 'Completed',
                color: _kInk,
                bg: Colors.white,
                bordered: true,
                onTap: () => Get.find<DietController>().updateAppointmentStatus(
                    appointmentId ?? 0, "completed",
                    isFromAppointment: true),
              ),
              _MiniActionChip(
                icon: Icons.close_rounded,
                label: 'Cancel',
                color: _kAlert,
                bg: _kAlertBg,
                onTap: () => Get.find<DietController>().updateAppointmentStatus(
                    appointmentId ?? 0, "canceled",
                    isFromAppointment: true),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Current status: ${(status?.capitalizeFirst ?? "—")}',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _kInkSoft,
            ),
          ),
        ],
      ),
    );
  }

  // ── Diet Plan / Generate Plan / Plan History ─────────────────────────
  Widget _actionsRow() {
    final tiles = <Widget>[
      if (planId != null)
        Expanded(
          child: _ActionTile(
            icon: Icons.description_outlined,
            label: 'Diet Plan',
            onTap: () => Get.to(() => AddUserDiet(
                userId: clientUser.id.toString(), planId: planId.toString())),
          ),
        ),
      if (planId != null) const SizedBox(width: 10),
      if (planId != null)
        Expanded(
          child: _ActionTile(
            icon: Icons.auto_awesome,
            label: 'Generate Plan',
            accent: true,
            onTap: () => Get.to(() => GeneratePlanScreen(
                  userId: clientUser.id,
                  userPlanId: planId!,
                  userDisplayName:
                      '${clientUser.firstName} ${clientUser.lastName}',
                )),
          ),
        ),
      if (planId != null) const SizedBox(width: 10),
      Expanded(
        child: _ActionTile(
          icon: Icons.history_rounded,
          label: 'Plan History',
          onTap: () => Get.to(() => UserPlanHistoryScreen(
                userId: clientUser.id,
                userDisplayName:
                    '${clientUser.firstName} ${clientUser.lastName}',
              )),
        ),
      ),
    ];
    return Row(children: tiles);
  }

  // ── Notes / history ──────────────────────────────────────────────────
  Widget _notesCard(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          iconColor: _kInkSoft,
          collapsedIconColor: _kInkSoft,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Notes & history',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                  color: _kInk,
                ),
              ),
              GestureDetector(
                onTap: () => _showAddNoteDialog(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _kAccentBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 14, color: _kInk),
                      SizedBox(width: 3),
                      Text(
                        'Add',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: _kInk,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          children: const [
            _NoteLine('Diet preference: vegetarian, no dairy'),
            _NoteLine('Medical history: PCOS, lactose intolerant'),
            _NoteLine("Past diets: tried keto — didn't stick"),
          ],
        ),
      ),
    );
  }

  void _showAddNoteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Add a note',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            color: _kInk,
          ),
        ),
        content: const Text(
          'Add anything worth remembering about this client here.',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: _kInkSoft,
            fontSize: 13,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: _kInk,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Weekly progress chart ────────────────────────────────────────────
  Widget _progressCard() {
    return _Card(
      child: SizedBox(
        height: 190,
        child: SfCartesianChart(
          plotAreaBorderWidth: 0,
          primaryXAxis: CategoryAxis(
            majorGridLines: const MajorGridLines(width: 0),
            axisLine: const AxisLine(width: 0),
            labelStyle: const TextStyle(
              fontFamily: 'Poppins',
              color: _kInkSoft,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          primaryYAxis: NumericAxis(
            minimum: 0,
            maximum: 100,
            interval: 20,
            labelFormat: '{value}%',
            majorGridLines: MajorGridLines(width: 0.6, color: _kBorder),
            axisLine: const AxisLine(width: 0),
            majorTickLines: const MajorTickLines(size: 0),
            labelStyle: const TextStyle(
              fontFamily: 'Poppins',
              color: _kInkSoft,
              fontSize: 11,
            ),
          ),
          series: <CartesianSeries<_ChartData, String>>[
            ColumnSeries<_ChartData, String>(
              dataSource: chartData,
              xValueMapper: (_ChartData data, _) => data.day,
              yValueMapper: (_ChartData data, _) => data.percentage,
              color: _kAccent,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
              width: 0.55,
              spacing: 0.25,
              dataLabelSettings: const DataLabelSettings(isVisible: false),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Local widgets ──────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const _Card({required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(
            color: _kInk.withOpacity(0.04),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool accent;
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: accent ? _kInk : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent ? _kInk : _kBorder),
          boxShadow: [
            BoxShadow(
              color: _kInk.withOpacity(0.04),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: _kAccent, size: 20),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 11.5,
                color: accent ? Colors.white : _kInk,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;
  final bool bordered;
  final VoidCallback onTap;
  const _MiniActionChip({
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
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: bordered ? Border.all(color: _kBorder) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
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

class _NoteLine extends StatelessWidget {
  final String text;
  const _NoteLine(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 8),
            width: 5,
            height: 5,
            decoration:
                const BoxDecoration(color: _kAccent, shape: BoxShape.circle),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12.5,
                color: _kInkSoft,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartData {
  const _ChartData(this.day, this.percentage);

  final String day;
  final double percentage;
}
