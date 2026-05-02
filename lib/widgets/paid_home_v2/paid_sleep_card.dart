import 'package:flutter/material.dart';

import '../../data/models/home_dashboard/home_dashboard_model.dart';
import 'sleep_log_modal.dart';

/// Sleep card: display-only summary of today's sleep hours + week delta.
/// Progress bar uses the universal green gradient (same across all phases).
/// When hoursToday is null, renders a "Not logged today" state with no
/// bar and no delta.
class PaidSleepCard extends StatelessWidget {
  final HomeDashboardModel dashboard;

  const PaidSleepCard({Key? key, required this.dashboard}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = dashboard.sleep;
    final hoursToday = s?.hoursToday;
    final targetHours = s?.targetHours;
    final hasTarget = targetHours != null && targetHours > 0;
    final hasHours = hoursToday != null;

    final fillFraction = (hasHours && hasTarget)
        ? (hoursToday / targetHours).clamp(0.0, 1.0)
        : 0.0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => SleepLogModal.show(
        context: context,
        dashboard: dashboard,
        initialHours: hoursToday,
      ),
      child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD8EDD4), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF163220).withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeaderRow(hoursToday, targetHours, hasHours, hasTarget),
          if (hasHours && hasTarget) ...[
            const SizedBox(height: 6),
            _buildProgressBar(fillFraction),
          ],
          if (!hasHours) ...[
            const SizedBox(height: 6),
            const Text(
              'Tap to log\nlast night →',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF9AB09A),
                height: 1.4,
              ),
            ),
          ],
          if (hasHours && s?.weekDeltaHours != null) ...[
            const SizedBox(height: 5),
            Text(
              _formatDelta(s!.weekDeltaHours!),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: s.weekDeltaHours! >= 0
                    ? const Color(0xFF6DC55A)
                    : const Color(0xFF9AB09A),
              ),
            ),
          ],
        ],
      ),
      ),
    );
  }

  Widget _buildHeaderRow(
      double? hoursToday, int? targetHours, bool hasHours, bool hasTarget) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          '🌙 Sleep',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Color(0xFF9AB09A),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              hasHours ? hoursToday!.toStringAsFixed(1) : '—',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Color(0xFF163220),
              ),
            ),
            Text(
              hasTarget ? 'h/${targetHours}h' : 'h',
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w400,
                color: Color(0xFF9AB09A),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressBar(double fraction) {
    return Container(
      height: 3,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFD8EDD4),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: fraction,
          heightFactor: 1.0, // Forces child to 100% of parent's 3 px height.
          child: const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6DC55A), Color(0xFFA8F0C0)],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDelta(double deltaHours) {
    final arrow = deltaHours >= 0 ? '↑' : '↓';
    final abs = deltaHours.abs().toStringAsFixed(1);
    return '$arrow ${abs}h vs last week';
  }
}
