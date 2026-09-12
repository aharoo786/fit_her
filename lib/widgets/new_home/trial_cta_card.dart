import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../UI/free_trail/trial_journey_screen.dart';
import '../../UI/plans_module/all_plans.dart';
import '../../data/controllers/auth_controller/auth_controller.dart';
import '../../data/controllers/home_controller/home_controller.dart';

/// Shows the trial-start confirmation dialog.
/// Shared by [TrialCtaCard] and [HeroLiveSection] so either entry-point
/// triggers the same flow: confirm → POST /trial/start → TrialJourneyScreen.
void showTrialStartDialog() {
  const accent = Color(0xFF6DC55A);
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
                  color: accent.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Text('🎉', style: TextStyle(fontSize: 28)),
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
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF4FBF2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accent.withOpacity(0.25), width: 1),
              ),
              child: Column(
                children: const [
                  _TrialInfoRow(icon: '⏱', text: 'Join within 10 minutes of a class starting'),
                  SizedBox(height: 6),
                  _TrialInfoRow(icon: '💬', text: 'Chat & consult with your trainer live'),
                  SizedBox(height: 6),
                  _TrialInfoRow(icon: '📱', text: 'Video link opens automatically when class goes live'),
                ],
              ),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                Get.back<void>();
                final home = Get.find<HomeController>();
                final started = await home.startTrial();
                if (started) {
                  auth.activateTrial();
                  Get.to<void>(() => const TrialJourneyScreen());
                }
              },
              child: Container(
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent,
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

/// Conversion banner shown on the unpaid home + unpaid progress preview.
///
/// Two states (driven by [AuthController.trialActivated]):
///   • idle      → "3 days free · then PKR 3500/month" + "Start 3-day free
///                 trial →". Tapping the button shows a confirmation dialog;
///                 on confirm it calls [HomeController.startTrial] (creates
///                 a TrialJourney row on the backend) then navigates to
///                 [TrialJourneyScreen]. The local [AuthController.trialActivated]
///                 flag is also set so the card shows "activated" if the user
///                 navigates back to this screen later.
///   • activated → "Trial active · 3 days remaining" + "Explore more plans
///                 →" which routes to `OurPlansScreen`.
class TrialCtaCard extends StatelessWidget {
  const TrialCtaCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final home = Get.find<HomeController>();
    return Obx(() {
      final active = auth.trialActivated.value;
      if (!active) return const _IdleCard();
      // Compute real days remaining from the TrialJourney startedAt timestamp
      // so the chip stays accurate instead of always showing "3 days".
      // Falls back to null when the journey hasn't loaded yet (shows "Trial active").
      int? daysLeft;
      final rawStart = home.trialJourney?['startedAt'];
      if (rawStart != null) {
        final startedAt = DateTime.tryParse(rawStart.toString());
        if (startedAt != null) {
          final endsAt = startedAt.add(const Duration(days: 3));
          final hours = endsAt.difference(DateTime.now()).inHours;
          daysLeft = hours > 0 ? (hours / 24).ceil() : 0;
        }
      }
      return _ActivatedCard(daysLeft: daysLeft);
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

  void _onStartTrial(BuildContext context) => showTrialStartDialog();
}

// ─── Small info row used inside the trial-start confirmation dialog. ────
class _TrialInfoRow extends StatelessWidget {
  const _TrialInfoRow({required this.icon, required this.text});

  final String icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 13)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              height: 1.45,
              color: Color(0xFF3D5E46),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Activated — "Explore more plans" CTA into OurPlansScreen. ────────
class _ActivatedCard extends StatelessWidget {
  /// Real days left computed from [TrialJourney.startedAt].
  /// Null means the journey data hasn't loaded yet — shows "Trial active"
  /// without a day count rather than a stale "3 days remaining".
  final int? daysLeft;

  const _ActivatedCard({this.daysLeft});

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
              Flexible(
                child: Text(
                  daysLeft == null
                      ? 'Trial active'
                      : daysLeft! > 0
                          ? 'Trial active · $daysLeft day${daysLeft == 1 ? '' : 's'} remaining'
                          : 'Trial ended · choose a plan',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
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
          Text(
            // Bug fix: this used to say "You're enjoying full access" even
            // once the trial had ended — directly contradicting the
            // headline right above it ("Trial ended · choose a plan").
            // Now it matches whichever state the headline is showing.
            (daysLeft != null && daysLeft! <= 0)
                ? "Your free trial has ended. Pick a plan to get back to your insights, classes, and dashboard."
                : "You're enjoying full access. Pick a plan to keep your insights, classes, and dashboard after the trial ends.",
            style: const TextStyle(
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
