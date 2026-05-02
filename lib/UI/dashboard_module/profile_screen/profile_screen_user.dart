import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:fitness_zone_2/UI/auth_module/sign_up_screen/goal_screen.dart';
import 'package:fitness_zone_2/UI/auth_module/sign_up_screen/sign_up_screen_questions.dart';
import 'package:fitness_zone_2/data/controllers/auth_controller/auth_controller.dart';
import 'package:fitness_zone_2/UI/dashboard_module/profile_screen/notification_settings_screen.dart';
import 'package:fitness_zone_2/values/my_imgs.dart';
import 'package:fitness_zone_2/data/Repos/cycle_repo/cycle_data_repository.dart';
import 'package:fitness_zone_2/data/services/cycle_engine.dart';
import 'package:fitness_zone_2/values/constants.dart';
import 'package:fitness_zone_2/widgets/new_home/phase_theme.dart';

/// Profile — visual rewrite to match the Paid Home V2 / Progress V2
/// aesthetic (cream body, white cards with mint border + soft shadow,
/// dark hero, phase-aware accent, .lbl small-caps section labels).
///
/// API contract preserved exactly: every `authController.*` reference,
/// the cycle-phase fetch, the "Update Details" navigation flow, the
/// logout/delete dialogs, and the notification settings route are
/// untouched. Only the visual shell changed.
class ProfileScreenUser extends StatelessWidget {
  ProfileScreenUser({super.key});

  final AuthController authController = Get.find();

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
    final repo = Get.find<CycleDataRepository>();
    final token =
        authController.sharedPreferences.getString(Constants.accessToken) ?? '';
    final response = await repo.getCycleData(accessToken: token);
    if (response.body != null &&
        response.body['status'] == '1' &&
        response.body['data'] != null &&
        response.body['data']['dataProvided'] == 1 &&
        response.body['data']['lastPeriodDate'] != null) {
      final data = response.body['data'];
      final cycleInfo = CycleEngine.calculate(
        lastPeriodDate: DateTime.parse(data['lastPeriodDate']),
        cycleLength: data['averageCycleLength'] ?? 28,
      );
      if (cycleInfo != null) {
        return {'phase': cycleInfo.phase, 'day': cycleInfo.cycleDay};
      }
    }
    return null;
  }

  // ─── Display palette (mirrors Progress V2 / Paid Home V2) ──────────────

  static const _kCream = Color(0xFFEAF7E4);
  static const _kCardBorder = Color(0xFFD8EDD4);
  static const _kTextPrimary = Color(0xFF163220);
  static const _kTextMuted = Color(0xFF6F8B7A);
  static const _kSage = Color(0xFF9AB09A);
  static const _kHeroDark = Color(0xFF163220);
  static const _kAccent = Color(0xFF6DC55A);
  static const _kDanger = Color(0xFFE07B7B);

  // Subtitle copy per phase — kept (extra "subtitle" key beyond the hub
  // PhaseTheme since profile shows a more verbose tagline than the home).
  static const Map<String, String> _phaseSubtitle = {
    'menstrual': 'Rest and recover. Your body is renewing itself.',
    'follicular': 'Energy is rising. Great time to be active.',
    'ovulatory': 'You are at your peak. Go all out today.',
    'luteal': 'Wind down gently. Listen to your body.',
  };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: _kCream,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _topBar(),
              const SizedBox(height: 8),
              _hero(),
              const SizedBox(height: 12),
              FutureBuilder<Map<String, dynamic>?>(
                future: _fetchCyclePhase(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data == null) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _cyclePhaseCard(
                      phase: snapshot.data!['phase'] as String,
                      day: snapshot.data!['day'] as int,
                    ),
                  );
                },
              ),
              _personalInfoCard(),
              const SizedBox(height: 12),
              _notificationsTile(),
              const SizedBox(height: 18),
              _primaryAction(
                label: 'Update Details',
                onTap: () => Get.to(() => GoalScreen(
                      initialGoal:
                          Get.find<AuthController>().mainGoal.value,
                      onNext: (goal) {
                        Get.off(() =>
                            SignUpScreenQuestions(selectedGoal: goal));
                      },
                    )),
              ),
              const SizedBox(height: 8),
              _neutralAction(
                label: 'Logout',
                onTap: () => _showLogoutDialog(context, textTheme),
              ),
              const SizedBox(height: 8),
              _dangerAction(
                label: 'Delete Account',
                onTap: _showDeleteDialog,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Top bar ───────────────────────────────────────────────────────────

  Widget _topBar() {
    return Row(
      children: [
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          icon: const Icon(Icons.arrow_back, color: _kTextPrimary, size: 22),
          onPressed: () => Get.back(),
        ),
        const Spacer(),
        const Text(
          'Profile',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _kSage,
            letterSpacing: 0.84, // ~.07em at 12px
          ),
        ),
        const Spacer(),
        const SizedBox(width: 36),
      ],
    );
  }

  // ─── Hero (dark card with avatar + name + email) ───────────────────────

  Widget _hero() {
    final firstName = authController.editFirstName.text;
    final lastName = authController.editLastName.text;
    final email = authController.editEmail.text;
    final fullName = [firstName, lastName]
        .where((s) => s.trim().isNotEmpty)
        .join(' ')
        .trim();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        color: _kHeroDark,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF163220).withOpacity(0.12),
            offset: const Offset(0, 6),
            blurRadius: 18,
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _kAccent.withOpacity(0.28),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    MyImgs.userProfileIcon,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _kAccent,
                  shape: BoxShape.circle,
                  border: Border.all(color: _kHeroDark, width: 2),
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 12),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  fullName.isEmpty ? 'My Profile' : fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.55),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Cycle phase card (white, accent-tinted strip) ─────────────────────

  Widget _cyclePhaseCard({required String phase, required int day}) {
    final theme = PhaseTheme.forPhaseString(phase);
    final subtitle = _phaseSubtitle[phase.toLowerCase()] ?? '';

    return Container(
      padding: const EdgeInsets.fromLTRB(15, 13, 15, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kCardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF163220).withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardLabel('Cycle Phase'),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(theme.emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          theme.phaseLabel,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: _kTextPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.accent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Day $day',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: theme.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: _kTextMuted,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Personal info card (label/value rows) ─────────────────────────────

  Widget _personalInfoCard() {
    final rows = <_InfoRowData>[
      _InfoRowData('First Name', authController.editFirstName.text),
      _InfoRowData('Last Name', authController.editLastName.text),
      _InfoRowData('Email', authController.editEmail.text),
      _InfoRowData('Age', authController.editAge.text),
      _InfoRowData('Height', authController.editHeight.text),
      _InfoRowData('Weight', authController.editWeight.text),
      _InfoRowData('BMI', authController.editBmi.text),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(15, 13, 15, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kCardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF163220).withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardLabel('Personal Info'),
          const SizedBox(height: 6),
          for (int i = 0; i < rows.length; i++) ...[
            _InfoRow(data: rows[i]),
            if (i < rows.length - 1)
              const Divider(height: 1, thickness: 1, color: Color(0xFFF0F6EE)),
          ],
        ],
      ),
    );
  }

  // ─── Notifications row ─────────────────────────────────────────────────

  Widget _notificationsTile() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Get.to(() => const NotificationSettingsScreen()),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _kCardBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF163220).withOpacity(0.05),
              offset: const Offset(0, 2),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _kAccent.withOpacity(0.13),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.notifications_outlined,
                color: _kAccent,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _kTextPrimary,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: _kSage, size: 20),
          ],
        ),
      ),
    );
  }

  // ─── Action buttons ────────────────────────────────────────────────────

  Widget _primaryAction({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _kAccent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _kAccent.withOpacity(0.30),
              offset: const Offset(0, 4),
              blurRadius: 14,
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  Widget _neutralAction({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kCardBorder, width: 1),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _kTextPrimary,
          ),
        ),
      ),
    );
  }

  Widget _dangerAction({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 44,
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _kDanger,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

/// Small-caps section label — mirrors `.lbl9` in the HTML mockup
/// (9px weight 700 sage, .07em letter-spacing). Slightly bigger here
/// (10px) since profile sections are denser than home cards.
class _CardLabel extends StatelessWidget {
  final String text;
  const _CardLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: Color(0xFF9AB09A),
        letterSpacing: 0.7, // ~.07em at 10px
      ),
    );
  }
}

class _InfoRowData {
  final String label;
  final String value;
  const _InfoRowData(this.label, this.value);
}

class _InfoRow extends StatelessWidget {
  final _InfoRowData data;
  const _InfoRow({required this.data});

  @override
  Widget build(BuildContext context) {
    final value = data.value.trim().isEmpty ? '—' : data.value;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              data.label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6F8B7A),
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF163220),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
