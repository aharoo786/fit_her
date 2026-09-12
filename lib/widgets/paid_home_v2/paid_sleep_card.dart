import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/controllers/paid_home_controller/paid_home_controller.dart';
import '../../data/models/home_dashboard/home_dashboard_model.dart';
import '../new_home/phase_theme.dart';
import 'sleep_log_modal.dart';

/// Sleep card: three quick-log presets (6h / 7h / 8h) + tap-card to open
/// the full slider modal for a custom value.
///
/// Mirrors PaidWaterCard's layout: header pinned top, action buttons pinned
/// bottom, Spacer in between — so both cards always match height inside an
/// IntrinsicHeight Row.
class PaidSleepCard extends StatefulWidget {
  final HomeDashboardModel dashboard;

  const PaidSleepCard({Key? key, required this.dashboard}) : super(key: key);

  @override
  State<PaidSleepCard> createState() => _PaidSleepCardState();
}

class _PaidSleepCardState extends State<PaidSleepCard> {
  final PaidHomeController _controller = Get.find<PaidHomeController>();

  Future<void> _onQuickLog(double hours) async {
    if (_controller.isSavingSleep.value) return;

    // Capture pre-log values to detect the goal-reached transition —
    // mirrors PaidWaterCard._onTap.
    final s = widget.dashboard.sleep;
    final prevHours = s?.hoursToday;
    final target = s?.targetHours;
    final wasUnderGoal =
        target != null && target > 0 && (prevHours == null || prevHours < target);

    final success = await _controller.logSleep(hours);
    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Couldn't save sleep"),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (wasUnderGoal) {
      final newHours = _controller.dashboard.value?.sleep?.hoursToday;
      if (newHours != null && newHours >= target) {
        showSleepGoalReachedDialog(context);
      }
    }
  }

  void _openModal() {
    SleepLogModal.show(
      context: context,
      dashboard: widget.dashboard,
      initialHours: widget.dashboard.sleep?.hoursToday,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = PhaseTheme.forPhaseString(widget.dashboard.cycle?.phase);
    final s = widget.dashboard.sleep;
    final hoursToday = s?.hoursToday;
    final targetHours = s?.targetHours;
    final hasTarget = targetHours != null && targetHours > 0;
    final hasHours = hoursToday != null;
    final fillFraction = (hasHours && hasTarget)
        ? (hoursToday / targetHours).clamp(0.0, 1.0)
        : 0.0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // Tap anywhere on the card (not on a button) opens the slider modal.
      onTap: _openModal,
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
          mainAxisSize: MainAxisSize.max,
          children: [
            // ── Header ──
            _buildHeaderRow(hoursToday, targetHours, hasHours, hasTarget),
            if (hasHours && hasTarget) ...[
              const SizedBox(height: 6),
              _buildProgressBar(fillFraction),
            ],
            // ── Middle: delta text (mirrors water's remaining text) ──
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
            // ── Spacer keeps buttons at the bottom ──
            const Spacer(),
            // ── Quick-log preset buttons ──
            _buildButtonRow(theme),
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
          heightFactor: 1.0,
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

  Widget _buildButtonRow(PhaseTheme theme) {
    return Obx(() {
      final saving = _controller.isSavingSleep.value;
      return Opacity(
        opacity: saving ? 0.6 : 1.0,
        child: IgnorePointer(
          ignoring: saving,
          child: Row(
            children: [
              Expanded(
                child: _SleepButton(
                  label: '6h',
                  accent: theme.accent,
                  // GestureDetector absorbs tap so it doesn't bubble to the
                  // outer card GestureDetector (which opens the modal).
                  onTap: () => _onQuickLog(6.0),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _SleepButton(
                  label: '7h',
                  accent: theme.accent,
                  onTap: () => _onQuickLog(7.0),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _SleepButton(
                  label: '8h',
                  accent: theme.accent,
                  onTap: () => _onQuickLog(8.0),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  String _formatDelta(double deltaHours) {
    final arrow = deltaHours >= 0 ? '↑' : '↓';
    final abs = deltaHours.abs().toStringAsFixed(1);
    return '$arrow ${abs}h vs last week';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick-log button — same visual spec as PaidWaterCard._ActionButton
// ─────────────────────────────────────────────────────────────────────────────

class _SleepButton extends StatelessWidget {
  final String label;
  final Color accent;
  final VoidCallback onTap;

  const _SleepButton({
    required this.label,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // absorb the tap so it doesn't open the modal.
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: accent.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accent.withOpacity(0.40), width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: accent,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Goal-reached celebration dialog — sleep counterpart to PaidWaterCard's
// _showGoalReachedDialog/_GoalReachedDialog. Public (not prefixed with _)
// so SleepLogModal can also trigger it when a save via the slider crosses
// the same under-goal -> goal-reached threshold.
// ─────────────────────────────────────────────────────────────────────────────

void showSleepGoalReachedDialog(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'dismiss',
    barrierColor: Colors.black.withOpacity(0.45),
    transitionDuration: const Duration(milliseconds: 380),
    transitionBuilder: (_, anim, __, child) {
      return ScaleTransition(
        scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
        child: FadeTransition(opacity: anim, child: child),
      );
    },
    pageBuilder: (_, __, ___) => const _SleepGoalReachedDialog(),
  );
}

class _SleepGoalReachedDialog extends StatefulWidget {
  const _SleepGoalReachedDialog();

  @override
  State<_SleepGoalReachedDialog> createState() =>
      _SleepGoalReachedDialogState();
}

class _SleepGoalReachedDialogState extends State<_SleepGoalReachedDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceCtrl;
  late final Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _bounceAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _bounceCtrl, curve: Curves.elasticOut),
    );
    _bounceCtrl.forward();
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF4F2FB), Color(0xFFE0DAF5)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6D6DC5).withOpacity(0.18),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _bounceAnim,
              child: const Text(
                '🌙',
                style: TextStyle(fontSize: 56, height: 1),
              ),
            ),
            const SizedBox(height: 6),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('✨', style: TextStyle(fontSize: 14)),
                SizedBox(width: 6),
                Text('✨', style: TextStyle(fontSize: 18)),
                SizedBox(width: 6),
                Text('✨', style: TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Sleep Goal\nReached!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF201A3A),
                height: 1.25,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Well rested! You've hit your sleep\ngoal for today. Your body thanks you! 💤",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xFF4A4A7A),
                height: 1.55,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6D6DC5),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Sweet dreams! 🌿',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
