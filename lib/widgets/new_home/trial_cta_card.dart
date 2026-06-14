import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../UI/plans_module/all_plans.dart';
import '../../data/controllers/auth_controller/auth_controller.dart';

/// Conversion banner shown on the unpaid home + unpaid progress preview.
///
/// Two states (driven by [AuthController.trialActivated]):
///   • idle      → "3 days free · then PKR 3500/month" + "Start 3-day free
///                 trial →". Tapping the button shows the "Trial activated"
///                 dialog, flips the local flag, and the card re-renders.
///   • activated → "Trial active · 3 days remaining" + "Explore more plans
///                 →" which routes to `OurPlansScreen`.
///
/// The flag is local-only (see [AuthController.activateTrial]) so this is a
/// demo / commercial-preview flow, not a real subscription activation.
class TrialCtaCard extends StatelessWidget {
  const TrialCtaCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return Obx(() {
      final active = auth.trialActivated.value;
      return active ? const _ActivatedCard() : const _IdleCard();
    });
  }
}

// ─── Idle (pre-activation) — original "Start 3-day free trial" copy. ───
class _IdleCard extends StatelessWidget {
  const _IdleCard();

  static const _accent = Color(0xFF6DC55A);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF163220), Color(0xFF1A3A28)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _accent.withOpacity(0.32), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF163220).withOpacity(0.18),
            offset: const Offset(0, 8),
            blurRadius: 24,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.22),
                  border:
                      Border.all(color: _accent.withOpacity(0.4), width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.work_outline,
                  color: _accent,
                  size: 14,
                ),
              ),
              const SizedBox(width: 9),
              const Flexible(
                child: Text(
                  '3 days free · then PKR 3500/month',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: _accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Unlock phase-matched live classes, AI insights, and your hormonal dashboard.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _onStartTrial(context),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _accent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Start 3-day free trial →',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Cancel anytime · No card charged today',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                color: Colors.white.withOpacity(0.35),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onStartTrial(BuildContext context) {
    final auth = Get.find<AuthController>();
    Get.dialog<void>(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Text('🎉',
                      style: TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Your trial is activated',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF163220),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "You're in. Live classes, AI insights, and your hormonal "
                'dashboard are unlocked for the next 3 days.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  height: 1.5,
                  color: Color(0xFF6F8B7A),
                ),
              ),
              const SizedBox(height: 18),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  auth.activateTrial();
                  Get.back<void>();
                },
                child: Container(
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _accent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "Let's go →",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}

// ─── Activated — "Explore more plans" CTA into OurPlansScreen. ────────
class _ActivatedCard extends StatelessWidget {
  const _ActivatedCard();

  static const _accent = Color(0xFF6DC55A);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF163220), Color(0xFF1A3A28)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _accent.withOpacity(0.32), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF163220).withOpacity(0.18),
            offset: const Offset(0, 8),
            blurRadius: 24,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.22),
                  border:
                      Border.all(color: _accent.withOpacity(0.4), width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('✨',
                    style: TextStyle(fontSize: 13)),
              ),
              const SizedBox(width: 9),
              const Flexible(
                child: Text(
                  'Trial active · 3 days remaining',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: _accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "You're enjoying full access. Pick a plan to keep your insights, classes, and dashboard after the trial ends.",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Get.to<dynamic>(() => OurPlansScreen()),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _accent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Explore more plans →',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Cancel anytime · No card charged today',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                color: Colors.white.withOpacity(0.35),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
