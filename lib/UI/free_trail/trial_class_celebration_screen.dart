import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/controllers/home_controller/home_controller.dart';
import '../plans_module/all_plans.dart';
import 'trial_summary_screen.dart';

/// Shown once after each trial class that counts (HomeController
/// _maybeCelebrate). "Class 1 of 3 done 🎉" with progress dots; when the
/// class goal is reached it becomes "Goal complete" with the upgrade
/// option. She can always keep joining classes until the trial ends.
class TrialClassCelebrationScreen extends StatelessWidget {
  final int attended;
  final int goal;
  const TrialClassCelebrationScreen({
    super.key,
    required this.attended,
    required this.goal,
  });

  static const _kInk = Color(0xFF163220);
  static const _kHero2 = Color(0xFF24502F);
  static const _kAccent = Color(0xFF6DC55A);

  @override
  Widget build(BuildContext context) {
    final done = attended >= goal;
    final shown = attended > goal ? goal : attended;
    final left = goal - attended;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_kInk, _kHero2],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              children: [
                const Spacer(),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.4, end: 1),
                  duration: const Duration(milliseconds: 650),
                  curve: Curves.elasticOut,
                  builder: (_, v, child) => Transform.scale(scale: v, child: child),
                  child: Container(
                    width: 120,
                    height: 120,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      shape: BoxShape.circle,
                      border: Border.all(color: _kAccent.withOpacity(0.6), width: 2),
                    ),
                    child: Text(done ? '🏆' : '🎉', style: const TextStyle(fontSize: 56)),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  done ? 'Goal complete!' : 'Class $shown of $goal done',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  done
                      ? "You joined all $goal classes of your trial. That's real commitment, and it shows 💚"
                      : left == 1
                          ? 'Amazing work. Just one more class to reach your goal.'
                          : 'Amazing work. $left more classes to reach your goal.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14.5,
                    height: 1.5,
                    color: Colors.white.withOpacity(0.82),
                  ),
                ),
                const SizedBox(height: 26),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(goal, (i) {
                    final on = i < shown;
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 300 + i * 120),
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      width: on ? 30 : 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: on ? _kAccent : Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    );
                  }),
                ),
                const Spacer(),
                if (done) ...[
                  _button(
                    label: 'Keep going with a plan',
                    filled: true,
                    onTap: () {
                      // Last day: summary + offer. Otherwise the plans.
                      final ends = Get.find<HomeController>().trialEndsAt;
                      final lastDay = ends != null &&
                          ends.difference(DateTime.now()).inHours < 24;
                      if (lastDay) {
                        Get.off(() => const TrialSummaryScreen());
                      } else {
                        Get.off(() => OurPlansScreen());
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  _button(
                    label: 'You can keep joining classes until your trial ends',
                    filled: false,
                    onTap: () => Get.back(),
                  ),
                ] else
                  _button(
                    label: 'Continue',
                    filled: true,
                    onTap: () => Get.back(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _button({
    required String label,
    required bool filled,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: filled
          ? ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kAccent,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : TextButton(
              onPressed: onTap,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.75),
                ),
              ),
            ),
    );
  }
}
