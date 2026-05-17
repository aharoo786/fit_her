import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/controllers/paid_home_controller/paid_home_controller.dart';
import '../../data/models/home_dashboard/home_dashboard_model.dart';
import '../new_home/phase_theme.dart';

/// Water card: progress display + two tap-to-log buttons.
/// Progress bar uses the universal green gradient (same across all phases —
/// hydration isn't phase-driven). Buttons are phase-tinted since they're
/// interactive actions.
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
    final success = await _controller.logWater(amountMl);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Couldn't log water"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme =
        PhaseTheme.forPhaseString(widget.dashboard.cycle?.phase);
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

    // Remaining/achievement text. Three states:
    //   - under goal:         "{remainingMl}ml remaining"    (red)
    //   - exactly at goal:    "Goal reached!"                (green)
    //   - over goal:          "Goal reached! {total}L today" (green)
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
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(height: 8),
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
    // Outer Container owns the optional glow. Inner ClipRRect clips the
    // gradient fill to rounded corners. Splitting shadow and clip is the
    // standard Flutter pattern — clipBehavior on a Container with a shadow
    // would swallow the glow.
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

  /// 250 → "0.3"; 2000 with `stripTrailingZero:true` → "2"; else "2.0".
  static String _formatL(int ml, {bool stripTrailingZero = false}) {
    final liters = ml / 1000.0;
    final s = liters.toStringAsFixed(1);
    if (stripTrailingZero && s.endsWith('.0')) {
      return s.substring(0, s.length - 2);
    }
    return s;
  }
}

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
