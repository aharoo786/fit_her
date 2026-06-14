import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:fitness_zone_2/UI/auth_module/result_screen.dart' show openWhatsAppChat;
import 'package:fitness_zone_2/UI/auth_module/sign_up_screen/goal_screen.dart';
import 'package:fitness_zone_2/UI/auth_module/sign_up_screen/sign_up_screen_questions.dart';
import 'package:fitness_zone_2/data/controllers/auth_controller/auth_controller.dart';
import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/UI/dashboard_module/profile_screen/notification_settings_screen.dart';
import 'package:fitness_zone_2/UI/dashboard_module/profile_screen/personal_details_screen.dart';
import 'package:fitness_zone_2/UI/plans_module/all_plans.dart';
import 'package:fitness_zone_2/data/Repos/cycle_repo/cycle_data_repository.dart';
import 'package:fitness_zone_2/data/Repos/plan_freeze_repo/plan_freeze_repository.dart';
import 'package:fitness_zone_2/data/controllers/paid_home_controller/paid_home_controller.dart';
import 'package:fitness_zone_2/data/services/cycle_engine.dart';
import 'package:fitness_zone_2/values/constants.dart';
import 'package:fitness_zone_2/widgets/new_home/phase_theme.dart';

/// Profile screen — rebuilt to match `new screens/Profile_Final_3Screens.html`
/// V1 design (mint hero with avatar + day/phase chip, overlapping stats
/// card, dark subscription card, weekly-progression attendance, menu list,
/// sign-out).
///
/// API contract preserved exactly: every `authController.*` reference, the
/// cycle-phase fetch, the "Update Details" navigation flow, the logout /
/// delete dialogs, and the notification-settings route are all untouched.
/// Stats / Attendance / Member-since use placeholders today — backend
/// endpoints to ship later.
class ProfileScreenUser extends StatefulWidget {
  const ProfileScreenUser({super.key});

  @override
  State<ProfileScreenUser> createState() => _ProfileScreenUserState();
}

class _ProfileScreenUserState extends State<ProfileScreenUser> {
  final AuthController authController = Get.find();

  // Cache the cycle-phase fetch so the FutureBuilder doesn't re-fire on
  // every rebuild. The chip would briefly flash through its loading state
  // (an empty SizedBox) every time the screen rebuilt, which made it look
  // like the phase wasn't displaying at all.
  late final Future<Map<String, dynamic>?> _phaseFuture = _fetchCyclePhase();

  // Tracks the freeze sheet's local "selected days" state without forcing
  // a full screen rebuild — only the sheet's StatefulBuilder reads it.
  int _freezeSelectedDays = 7;
  bool _freezeBusy = false;

  // Unpaid (status == false) users see a stripped-down profile: no stats,
  // no subscription card, no attendance — just identity + an "Explore
  // plans" CTA + the menu. They have nothing to show on those surfaces yet.
  bool get _isPaid => authController.logInUser?.status == true;

  // ─── API-touching helpers (UNCHANGED — do not modify) ──────────────────

  void _showLogoutDialog(BuildContext context, TextTheme textTheme) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Log Out", style: textTheme.headlineSmall),
        content: Text("Are you sure you want to logout?",
            style: textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel", style: textTheme.bodyMedium),
          ),
          TextButton(
            onPressed: () => authController.logout(),
            child: Text("Logout", style: textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    Get.defaultDialog(
      title: "Alert",
      content: const Text("Do you really want to delete your account?"),
      onConfirm: () {
        Get.back();
        authController.deleteUser();
      },
      onCancel: () {},
    );
  }

  Future<Map<String, dynamic>?> _fetchCyclePhase() async {
    // 1. Prefer the paid-home dashboard — server already computes phase +
    //    day there, so no fetch + no parsing risk. Works whenever the
    //    paid home has loaded at least once this session.
    if (Get.isRegistered<PaidHomeController>()) {
      final dash = Get.find<PaidHomeController>().dashboard.value;
      final card = dash?.cycleCard;
      if (card != null &&
          card.phase != null &&
          card.phase!.isNotEmpty &&
          card.cycleDay != null) {
        return {'phase': card.phase!, 'day': card.cycleDay!};
      }
    }

    // 2. Fall back to the direct CycleDataRepository call. Lenient on
    //    `dataProvided` (backends have shipped this as int 1, bool true,
    //    and string "1" at different times) and tolerant of parse errors.
    try {
      final repo = Get.find<CycleDataRepository>();
      final token =
          authController.sharedPreferences.getString(Constants.accessToken) ??
              '';
      final response = await repo.getCycleData(accessToken: token);
      final body = response.body;
      if (body == null || body['status'] != '1' || body['data'] == null) {
        return null;
      }
      final data = body['data'];
      final provided = data['dataProvided'];
      final hasProvided =
          provided == 1 || provided == true || provided == '1';
      final last = data['lastPeriodDate'];
      if (!hasProvided || last == null) return null;
      final cycleInfo = CycleEngine.calculate(
        lastPeriodDate: DateTime.parse(last.toString()),
        cycleLength: data['averageCycleLength'] ?? 28,
      );
      if (cycleInfo != null) {
        return {'phase': cycleInfo.phase, 'day': cycleInfo.cycleDay};
      }
    } catch (_) {
      // Network blip / parse error — show the "Add cycle data" CTA so the
      // user has a path forward instead of a silent failure.
    }
    return null;
  }

  // ─── Design tokens (from Profile_Final_3Screens.html V1) ───────────────

  static const _kCanvas = Color(0xFFF9FCF7);
  static const _kMintHero = Color(0xFFE8F4E0);
  static const _kMintRingA = Color(0xFFC8E8BC);
  static const _kMintRingB = Color(0xFFD4EBC4);
  static const _kCardBg = Colors.white;
  static const _kCardBorder = Color(0xFFEFF4EC);
  static const _kIconWashBg = Color(0xFFF6FBF3);
  static const _kTextPrimary = Color(0xFF1A3A22);
  static const _kTextMuted = Color(0xFF5A7258);
  static const _kSage = Color(0xFF7A8C78);
  static const _kAccent = Color(0xFF6DC55A);
  static const _kAccentSoft = Color(0xFFA8F0C0);
  static const _kHeroDark = Color(0xFF1A3A22);
  static const _kStreak = Color(0xFFFAC775);
  static const _kDanger = Color(0xFFD85A30);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: _kCanvas,
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _heroBlock(context),
            // Everything below shifts up 30px so the stats card visually
            // overlaps the mint hero by 30 — matches the HTML mockup's
            // `margin:-30px 20px 16px` on the stats card. We compensate
            // for the layout-vs-visual offset with the final SizedBox.
            Transform.translate(
              offset: const Offset(0, -30),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_isPaid) ...[
                      _statsCard(),
                      const SizedBox(height: 16),
                      _subscriptionCard(),
                      const SizedBox(height: 16),
                      _attendanceCard(),
                    ] else
                      _explorePlansCard(),
                    const SizedBox(height: 16),
                    _menuCard(context, textTheme),
                    const SizedBox(height: 12),
                    _signOutLink(context, textTheme),
                    // 30 to compensate for the -30 transform above so
                    // scroll content doesn't end 30px short.
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Hero block (mint bg, status-bar safe, rounded bottom) ─────────────
  Widget _heroBlock(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    return Container(
      decoration: const BoxDecoration(
        color: _kMintHero,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Decorative ring top-right (mint mockup detail).
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: _kMintRingA,
              ),
              foregroundDecoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _kMintRingA.withOpacity(0.5),
              ),
            ),
          ),
          // Decorative ring bottom-left.
          Positioned(
            bottom: -20,
            left: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: _kMintRingB,
              ),
              foregroundDecoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _kMintRingB.withOpacity(0.5),
              ),
            ),
          ),
          // Content — status bar safe.
          Padding(
            padding: EdgeInsets.only(top: topInset),
            child: Column(
              children: [
                _topBar(),
                const SizedBox(height: 4),
                _heroIdentity(),
                // 50px of mint bg below the chip → the stats card's
                // Transform(-30) overlays the bottom 30 of this padding.
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          _circleIconButton(
            icon: Icons.arrow_back,
            onTap: () => Get.back(),
          ),
          const Spacer(),
          const Text(
            'Profile',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _kTextPrimary,
            ),
          ),
          const Spacer(),
          _circleIconButton(
            icon: Icons.settings_outlined,
            onTap: () =>
                Get.to(() => const NotificationSettingsScreen()),
          ),
        ],
      ),
    );
  }

  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _kTextPrimary.withOpacity(0.05),
              offset: const Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Icon(icon, size: 16, color: _kTextPrimary),
      ),
    );
  }

  // Avatar + name + member-since + day/phase chip.
  Widget _heroIdentity() {
    final firstName = authController.editFirstName.text.trim();
    final lastName = authController.editLastName.text.trim();
    final fullName =
        [firstName, lastName].where((s) => s.isNotEmpty).join(' ').trim();
    final initial = (firstName.isNotEmpty
            ? firstName[0]
            : (lastName.isNotEmpty ? lastName[0] : 'U'))
        .toUpperCase();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _avatarWithBadge(initial),
          const SizedBox(height: 16),
          Text(
            fullName.isEmpty ? 'My Profile' : fullName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: _kTextPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            // Placeholder — backend doesn't surface User.createdAt on the
            // LoginModel today. Wire through when available.
            'Member',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: _kTextMuted,
            ),
          ),
          const SizedBox(height: 14),
          _phaseChip(),
        ],
      ),
    );
  }

  Widget _avatarWithBadge(String initial) {
    return SizedBox(
      width: 92,
      height: 92,
      child: Stack(
        children: [
          // Avatar — initial inside a gradient circle with white border.
          Container(
            width: 92,
            height: 92,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_kAccent, _kAccentSoft],
              ),
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: _kTextPrimary.withOpacity(0.12),
                  offset: const Offset(0, 8),
                  blurRadius: 24,
                ),
              ],
            ),
            child: Text(
              initial,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          // Camera badge — bottom-right. Hooked to the existing
          // Update-Details flow so users can change their profile data.
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Get.to(() => GoalScreen(
                    initialGoal:
                        Get.find<AuthController>().mainGoal.value,
                    onNext: (goal) {
                      Get.off(() =>
                          SignUpScreenQuestions(selectedGoal: goal));
                    },
                  )),
              child: Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kHeroDark,
                  border: Border.all(color: _kMintHero, width: 3),
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _phaseChip() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _phaseFuture,
      builder: (_, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const SizedBox(height: 30);
        }
        if (snap.data == null) {
          // No cycle data yet — keep a subtle placeholder so the layout
          // doesn't collapse under the avatar.
          return _chip(text: 'Add cycle data', icon: Icons.add_circle_outline);
        }
        final phase = snap.data!['phase'] as String;
        final day = snap.data!['day'] as int;
        final theme = PhaseTheme.forPhaseString(phase);
        final label = 'Day $day · ${theme.phaseLabel} ${theme.emoji}';
        return _chip(text: label);
      },
    );
  }

  Widget _chip({required String text, IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: _kMintRingA, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: _kAccent),
            const SizedBox(width: 6),
          ] else ...[
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: _kAccent,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _kTextPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Stats card (3 columns, overlaps hero by -30) ──────────────────────
  Widget _statsCard() {
    // Backend doesn't expose attendance counters yet; show em-dashes so
    // the surface is shaped correctly and ready to wire when ready.
    return _card(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        children: [
          Expanded(child: _statColumn(value: '—', label: 'Classes')),
          _statDivider(),
          Expanded(
            child: _statColumn(
              value: '— 🔥',
              label: 'Streak',
              valueColor: _kStreak,
            ),
          ),
          _statDivider(),
          Expanded(
            child: _statColumn(
              value: '—',
              label: 'Workouts',
              valueColor: _kAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statColumn({
    required String value,
    required String label,
    Color? valueColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: valueColor ?? _kTextPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: _kSage,
          ),
        ),
      ],
    );
  }

  Widget _statDivider() => Container(
        width: 1,
        height: 36,
        color: _kCardBorder,
      );

  // ─── Explore-plans card (shown to unpaid users in place of the
  //     subscription card). Same dark surface as the paid version so the
  //     visual rhythm stays consistent, but no plan name, no Active pill,
  //     no Next-billing row, no Freeze button — just a single CTA into
  //     OurPlansScreen (same destination as paid "Manage").
  Widget _explorePlansCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _kHeroDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'YOUR PLAN',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.5),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Explore plans',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Unlock phase-matched live classes, AI insights, and your hormonal dashboard.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              height: 1.5,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          _subscriptionPrimaryButton(
            'Browse plans →',
            onTap: () => Get.to<dynamic>(() => OurPlansScreen()),
          ),
        ],
      ),
    );
  }

  // ─── Subscription card (dark) ──────────────────────────────────────────
  Widget _subscriptionCard() {
    final homeController = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : null;
    final plans = homeController?.userHomeData?.userAllPlans ?? const [];
    final plan = plans.isNotEmpty ? plans.first : null;
    final planName = plan?.title ?? 'FitHer Plus';
    // Some users have priceData populated, others only the flat `price`
    // field (string). Fall through both before giving up — was showing
    // "—" for users with `plan.price = "3500"` and null priceData.
    String _amount() {
      if (plan == null) return '—';
      final p1 = plan.priceData?.priceAmount;
      if (p1 != null && p1.trim().isNotEmpty && p1 != 'N/A') {
        return 'PKR $p1';
      }
      final p2 = plan.price.trim();
      if (p2.isNotEmpty && p2 != 'null' && p2 != '0') {
        return 'PKR $p2';
      }
      return '—';
    }
    final amountText = _amount();
    final nextBilling = plan?.expireDate;
    final nextBillingText = nextBilling != null
        ? _formatShortDate(nextBilling)
        : '—';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _kHeroDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CURRENT PLAN',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withOpacity(0.5),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      planName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              _activePill(),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.08)),
                bottom: BorderSide(color: Colors.white.withOpacity(0.08)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _subRowLabelled(
                    label: 'Next billing',
                    value: nextBillingText,
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _subRowLabelled(
                      label: 'Amount',
                      value: amountText,
                      alignRight: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _subscriptionSecondaryButton(
                  '❄  Freeze plan',
                  onTap: _showFreezeSheet,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _subscriptionPrimaryButton(
                  'Manage',
                  // "Manage" opens the existing plan-selection flow:
                  // OurPlansScreen → plan pick → payment options (manual
                  // upload or online) — the same path used elsewhere in
                  // the app (paywall, plans timeline banner, etc.).
                  onTap: () => Get.to<dynamic>(() => OurPlansScreen()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _activePill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: _kAccent.withOpacity(0.15),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: _kAccent.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _kAccent,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'ACTIVE',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: _kAccent,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _subRowLabelled({
    required String label,
    required String value,
    bool alignRight = false,
  }) {
    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 10,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _subscriptionSecondaryButton(String label, {VoidCallback? onTap}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _subscriptionPrimaryButton(String label, {VoidCallback? onTap}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _kAccent,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ─── Attendance card (weekly progression bars) ─────────────────────────
  Widget _attendanceCard() {
    // Placeholder data — replace when GET /users/attendance/monthly ships.
    final weeks = <_WeekRow>[
      const _WeekRow(label: 'Week 1', completed: 0, target: 7),
      const _WeekRow(label: 'Week 2', completed: 0, target: 7),
      const _WeekRow(label: 'Week 3', completed: 0, target: 7),
      const _WeekRow(label: 'This wk', completed: 0, target: 7),
    ];
    return _card(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ATTENDANCE',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _kSage,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '— of 30 days',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _kTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _kIconWashBg,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Text(
                  '—%',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: _kAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < weeks.length; i++) ...[
            _weekBar(weeks[i]),
            if (i < weeks.length - 1) const SizedBox(height: 10),
          ],
          const SizedBox(height: 14),
          Container(height: 1, color: _kCardBorder),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Track each week of activity',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: _kSage,
                  ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  // F4 Activity History screen ships in a follow-up.
                },
                child: const Text(
                  'View all →',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _kAccent,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _weekBar(_WeekRow row) {
    final pct = row.target == 0
        ? 0.0
        : (row.completed / row.target).clamp(0.0, 1.0).toDouble();
    return Row(
      children: [
        SizedBox(
          width: 48,
          child: Text(
            row.label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: _kSage,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: _kCardBorder,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: pct,
                child: Container(
                  decoration: BoxDecoration(
                    color: _kAccent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 30,
          child: Text(
            '${row.completed}/${row.target}',
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _kTextPrimary,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Menu list (4 rows: Personal details, Notifications, Reports, Help) ─
  Widget _menuCard(BuildContext context, TextTheme textTheme) {
    final rows = <_MenuItem>[
      _MenuItem(
        icon: Icons.person_outline,
        label: 'Personal details',
        onTap: () => Get.to(() => PersonalDetailsScreen()),
      ),
      _MenuItem(
        icon: Icons.notifications_none,
        label: 'Notifications',
        onTap: () => Get.to(() => const NotificationSettingsScreen()),
      ),
      _MenuItem(
        icon: Icons.description_outlined,
        label: 'My reports',
        onTap: () {
          // No reports screen yet — leave as a no-op so the row is tappable
          // but doesn't navigate to a half-built surface.
        },
      ),
      _MenuItem(
        icon: Icons.help_outline,
        label: 'Help centre',
        // Same admin WhatsApp number used by result_screen.dart's contact
        // CTA — keep the number in one place until we add a config var.
        onTap: () => _showHelpSheet(context, textTheme),
      ),
    ];

    return _card(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            _menuRow(rows[i]),
            if (i < rows.length - 1)
              Container(height: 1, color: _kCardBorder),
          ],
        ],
      ),
    );
  }

  Widget _menuRow(_MenuItem item) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _kIconWashBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, size: 14, color: _kAccent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _kTextPrimary,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 14, color: Color(0xFFC8DEC4)),
          ],
        ),
      ),
    );
  }

  // ─── Freeze sheet (pause plan via PlanFreezeRepository.freeze) ─────────
  // Mirrors the freeze action in V2AssignedPlanCard but as a focused
  // bottom sheet — pick 7 / 14 / 30 days, hit Pause, snackbar on result.
  // The backend enforces the per-plan budget; we surface its error message
  // verbatim on rejection (e.g. "Exceeded freeze budget").
  void _showFreezeSheet() {
    // Reset the in-memory selection each time the sheet opens.
    _freezeSelectedDays = 7;
    _freezeBusy = false;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (innerCtx, setSheetState) {
            final options = const [7, 14, 30];
            Widget dayChip(int days) {
              final selected = days == _freezeSelectedDays;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _freezeBusy
                      ? null
                      : () =>
                          setSheetState(() => _freezeSelectedDays = days),
                  child: Container(
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? _kHeroDark : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected ? _kHeroDark : _kCardBorder,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '$days days',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: selected ? Colors.white : _kTextPrimary,
                      ),
                    ),
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: _kCardBorder,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Pause your plan',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _kTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Your plan resumes automatically after the selected '
                      'pause window. Subject to your remaining freeze budget.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: _kSage,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        for (int i = 0; i < options.length; i++) ...[
                          dayChip(options[i]),
                          if (i < options.length - 1) const SizedBox(width: 8),
                        ],
                      ],
                    ),
                    const SizedBox(height: 18),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _freezeBusy
                          ? null
                          : () async {
                              setSheetState(() => _freezeBusy = true);
                              final ok =
                                  await _runFreeze(_freezeSelectedDays);
                              if (Navigator.of(sheetCtx).canPop()) {
                                Navigator.of(sheetCtx).pop();
                              }
                              if (ok) {
                                // Refresh home so the new plan status shows
                                // on next dashboard read. Best-effort.
                                if (Get.isRegistered<HomeController>()) {
                                  Get.find<HomeController>()
                                      .getUserHomeFunc();
                                }
                              }
                            },
                      child: Container(
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _freezeBusy
                              ? _kAccent.withOpacity(0.5)
                              : _kAccent,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          _freezeBusy
                              ? 'Pausing…'
                              : 'Pause for $_freezeSelectedDays days',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _freezeBusy
                          ? null
                          : () => Navigator.of(sheetCtx).pop(),
                      child: Container(
                        height: 46,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border:
                              Border.all(color: _kCardBorder, width: 1),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _kTextPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<bool> _runFreeze(int days) async {
    try {
      final repo = Get.find<PlanFreezeRepository>();
      final token =
          authController.sharedPreferences.getString(Constants.accessToken) ??
              '';
      final res = await repo.freeze(accessToken: token, days: days);
      final ok = res.body != null && res.body['status'] == '1';
      Get.snackbar(
        ok ? 'Plan paused' : 'Could not freeze',
        res.body?['message']?.toString() ?? '',
        snackPosition: SnackPosition.BOTTOM,
      );
      return ok;
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  // ─── Help sheet (Text admin on WhatsApp) ───────────────────────────────
  void _showHelpSheet(BuildContext context, TextTheme textTheme) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _kCardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Need help?',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _kTextPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Reach out to our team — we usually reply within a few hours.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: _kSage,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Get.back<dynamic>();
                openWhatsAppChat('923264986911');
              },
              child: Container(
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366), // WhatsApp green
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Message admin on WhatsApp',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Get.back<dynamic>(),
              child: Container(
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _kCardBorder, width: 1),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _kTextPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Sign-out link (red text) ──────────────────────────────────────────
  Widget _signOutLink(BuildContext context, TextTheme textTheme) {
    return Column(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _showLogoutDialog(context, textTheme),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Text(
              'Sign out',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _kDanger,
              ),
            ),
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _showDeleteDialog,
          child: const Padding(
            padding: EdgeInsets.only(top: 4, bottom: 10),
            child: Text(
              'Delete account',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _kSage,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Shared building blocks ────────────────────────────────────────────
  Widget _card({required Widget child, EdgeInsets? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kCardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: _kTextPrimary.withOpacity(0.08),
            offset: const Offset(0, 8),
            blurRadius: 24,
          ),
        ],
      ),
      child: child,
    );
  }

  String _formatShortDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class _WeekRow {
  final String label;
  final int completed;
  final int target;
  const _WeekRow({
    required this.label,
    required this.completed,
    required this.target,
  });
}
