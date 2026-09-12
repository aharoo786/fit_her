import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/controllers/paid_home_controller/paid_home_controller.dart';
import '../../data/models/home_dashboard/home_dashboard_model.dart';
import '../new_home/phase_theme.dart';

/// Water card: progress display + two tap-to-log buttons.
/// Designed to fill its parent height (works inside an IntrinsicHeight Row).
/// When goal transitions from under → reached on a tap, shows a motivational
/// celebration dialog.
class PaidWaterCard extends StatefulWidget {
  final HomeDashboardModel dashboard;

  const PaidWaterCard({Key? key, required this.dashboard}) : super(key: key);

  @override
  State<PaidWaterCard> createState() => _PaidWaterCardState();
}

class _PaidWaterCardState extends State<PaidWaterCard> {
  final PaidHomeController _controller = Get.find<PaidHomeController>();

  Future<void> _onTap(int amountMl) async {
    if (_controller.isLoggingWater.value) return;

    // Capture pre-tap values to detect the goal-reached transition.
    final prevConsumed = widget.dashboard.hydration?.consumedMl ?? 0;
    final target = widget.dashboard.hydration?.targetMl ?? 0;
    final wasUnderGoal = target > 0 && prevConsumed < target;

    final success = await _controller.logWater(amountMl);
    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Couldn't log water"),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Show celebration popup when goal is reached for the first time this tap.
    if (wasUnderGoal) {
      final newConsumed =
          _controller.dashboard.value?.hydration?.consumedMl ?? 0;
      if (newConsumed >= target) {
        _showGoalReachedDialog(context);
      }
    }
  }

  void _showGoalReachedDialog(BuildContext ctx) {
    showGeneralDialog(
      context: ctx,
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
      pageBuilder: (_, __, ___) => const _GoalReachedDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = PhaseTheme.forPhaseString(widget.dashboard.cycle?.phase);
    final h = widget.dashboard.hydration;

    final consumedMl = h?.consumedMl;
    final targetMl = h?.targetMl;
    final remainingMl = h?.remainingMl;

    final hasTarget = targetMl != null && targetMl > 0;
    final fillFraction = (hasTarget && consumedMl != null)
        ? (consumedMl / targetMl).clamp(0.0, 1.0)
        : 0.0;
    final goalReached =
        hasTarget && consumedMl != null && consumedMl >= targetMl;
    final overGoal =
        hasTarget && consumedMl != null && consumedMl > targetMl;

    final String remainingText;
    if (overGoal) {
      remainingText = 'Goal reached! ${_formatL(consumedMl)}L today';
    } else if (goalReached) {
      remainingText = 'Goal reached!';
    } else {
      remainingText = '${remainingMl ?? 0}ml remaining';
    }

    return Container(
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
        // max so the column fills the IntrinsicHeight-constrained height,
        // letting Spacer push the action buttons to the bottom.
        mainAxisSize: MainAxisSize.max,
        children: [
          _buildHeaderRow(consumedMl, targetMl, hasTarget),
          const SizedBox(height: 6),
          if (hasTarget) _buildProgressBar(fillFraction, goalReached),
          if (hasTarget) const SizedBox(height: 5),
          if (hasTarget)
            Text(
              remainingText,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: goalReached
                    ? const Color(0xFF6DC55A)
                    : const Color(0xFFE24B4A),
              ),
            ),
          // Spacer pushes buttons to the bottom so both cards align.
          const Spacer(),
          _buildButtonRow(theme),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(int? consumedMl, int? targetMl, bool hasTarget) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          '💧 Water',
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
              consumedMl != null ? _formatL(consumedMl) : '—',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Color(0xFF163220),
              ),
            ),
            Text(
              hasTarget
                  ? 'L/${_formatL(targetMl!, stripTrailingZero: true)}L'
                  : 'L',
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

  Widget _buildProgressBar(double fraction, bool goalReached) {
    return Container(
      height: 3,
      decoration: BoxDecoration(
        color: const Color(0xFFD8EDD4),
        borderRadius: BorderRadius.circular(3),
        boxShadow: goalReached
            ? [
                BoxShadow(
                  color: const Color(0xFF6DC55A).withOpacity(0.5),
                  blurRadius: 6,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
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
      ),
    );
  }

  Widget _buildButtonRow(PhaseTheme theme) {
    return Obx(() {
      final saving = _controller.isLoggingWater.value;
      return Opacity(
        opacity: saving ? 0.6 : 1.0,
        child: IgnorePointer(
          ignoring: saving,
          child: Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: '+200ml',
                  accent: theme.accent,
                  onTap: () => _onTap(200),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _ActionButton(
                  label: '+500ml',
                  accent: theme.accent,
                  onTap: () => _onTap(500),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  static String _formatL(int ml, {bool stripTrailingZero = false}) {
    final liters = ml / 1000.0;
    final s = liters.toStringAsFixed(1);
    if (stripTrailingZero && s.endsWith('.0')) {
      return s.substring(0, s.length - 2);
    }
    return s;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Action button
// ─────────────────────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final String label;
  final Color accent;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
// Goal-reached celebration dialog
// ─────────────────────────────────────────────────────────────────────────────

class _GoalReachedDialog extends StatefulWidget {
  const _GoalReachedDialog();

  @override
  State<_GoalReachedDialog> createState() => _GoalReachedDialogState();
}

class _GoalReachedDialogState extends State<_GoalReachedDialog>
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
            colors: [Color(0xFFF4FBF2), Color(0xFFE0F5DA)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6DC55A).withOpacity(0.18),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated water drop emoji
            ScaleTransition(
              scale: _bounceAnim,
              child: const Text(
                '💧',
                style: TextStyle(fontSize: 56, height: 1),
              ),
            ),
            const SizedBox(height: 6),
            // Sparkles row
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
            // Headline
            const Text(
              'Hydration Goal\nReached!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF163220),
                height: 1.25,
              ),
            ),
            const SizedBox(height: 10),
            // Body
            const Text(
              "Amazing work! You've hit your daily\nwater goal. Your body is glowing! 💪",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xFF4A7A4A),
                height: 1.55,
              ),
            ),
            const SizedBox(height: 24),
            // CTA button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6DC55A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Keep it up! 🌿',
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
