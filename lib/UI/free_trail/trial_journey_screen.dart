import 'dart:math' as math;

import 'package:fitness_zone_2/UI/dashboard_module/bottom_bar_screen/bottom_bar_screen.dart';
import 'package:fitness_zone_2/UI/free_trail/trial_summary_screen.dart';
import 'package:fitness_zone_2/UI/free_trail/trial_onboarding_screen.dart';
import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/utils/app_clock.dart';
import 'package:fitness_zone_2/widgets/circular_progress.dart';
import 'package:fitness_zone_2/widgets/toasts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' show DateFormat;

/// "My trial" screen. No booking and no Day 1/2/3 ladder any more:
///   * days left
///   * class goal progress ("2 of 3 classes done"), any class counts
///   * her next class and her reminder times (changeable here)
///   * how trial classes work
/// If she has no trial yet, she's sent to trial onboarding: the trial
/// only starts once her form is done.
class TrialJourneyScreen extends StatefulWidget {
  const TrialJourneyScreen({super.key});

  @override
  State<TrialJourneyScreen> createState() => _TrialJourneyScreenState();
}

class _TrialJourneyScreenState extends State<TrialJourneyScreen> {
  final HomeController homeController = Get.find();

  static const Color _kBg = Color(0xFFE8F4E0);
  static const Color _kInk = Color(0xFF163220);
  static const Color _kInkSoft = Color(0xFF6F8B7A);
  static const Color _kAccent = Color(0xFF6DC55A);
  static const Color _kBorder = Color(0xFFD8EDD4);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await homeController.getMyTrialJourney();
    if (!mounted) return;
    if (homeController.trialJourney == null) {
      Get.off(() => const TrialOnboardingScreen());
      return;
    }
    await homeController.loadTrialClasses();
    if (mounted) setState(() {});
  }

  DateTime? get _startedAt {
    final raw = homeController.trialJourney?["startedAt"];
    return raw == null ? null : DateTime.tryParse(raw.toString())?.toLocal();
  }

  DateTime? get _endsAt => _startedAt?.add(homeController.kTrialLength);

  bool get _isActive {
    final endsAt = _endsAt;
    return endsAt != null && AppClock.now().isBefore(endsAt);
  }

  int get _daysLeft {
    final endsAt = _endsAt;
    if (endsAt == null) return 0;
    final hours = endsAt.difference(AppClock.now()).inHours;
    return math.max(0, (hours / 24).ceil());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Obx(() {
          if (!homeController.trialLoad.value) {
            return const Center(child: CircularProgress());
          }
          // Touch the Rx values so progress / classes rebuild live.
          final goal = homeController.classGoal.value;
          final attended = homeController.classesAttended.value;
          homeController.trialClassData.value;

          return RefreshIndicator(
            color: _kAccent,
            onRefresh: _load,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: [
                _header(),
                const SizedBox(height: 20),
                Text(
                  _isActive ? 'Your free trial is on 💚' : 'Your trial has ended',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _kInk,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _isActive
                      ? 'Join any live class you like. No booking needed.'
                      : 'Your plan and progress are saved. Continue anytime.',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    height: 1.5,
                    color: _kInkSoft,
                  ),
                ),
                const SizedBox(height: 18),
                _daysCard(),
                const SizedBox(height: 12),
                _goalCard(attended, goal),
                if (_isActive) ...[
                  const SizedBox(height: 12),
                  _nextClassCard(),
                  const SizedBox(height: 12),
                  _remindersCard(),
                  const SizedBox(height: 12),
                  TrialClassRulesCard(
                    joinWindowMinutes: homeController.joinWindowMinutes.value,
                  ),
                ],
                const SizedBox(height: 22),
                _mainButton(),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Get.back(),
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: _kBorder),
            ),
            child: const Icon(Icons.arrow_back_rounded, size: 18, color: _kInk),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '${homeController.trialDays.value}-Day Free Trial',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: _kInk,
          ),
        ),
      ],
    );
  }

  Widget _daysCard() {
    final ends = _endsAt;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_kInk, Color(0xFF24502F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _kAccent.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text('⏱', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isActive
                      ? '$_daysLeft day${_daysLeft == 1 ? '' : 's'} left'
                      : 'Trial complete',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: _kAccent,
                  ),
                ),
                if (ends != null)
                  Text(
                    '${_isActive ? 'Ends' : 'Ended'} ${DateFormat('EEEE, h:mm a').format(ends)}',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.72),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _goalCard(int attended, int goal) {
    final shown = math.min(attended, goal);
    final reached = attended >= goal;
    return _whiteCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(reached ? '🏆' : '💪', style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  reached ? 'Goal complete!' : '$shown of $goal classes done',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _kInk,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(goal, (i) {
              final on = i < shown;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: i == goal - 1 ? 0 : 6),
                  height: 8,
                  decoration: BoxDecoration(
                    color: on ? _kAccent : _kBorder,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          Text(
            reached
                ? 'You can keep joining classes until your trial ends.'
                : 'Any live class counts once you stay ${homeController.attendanceMinutes.value} minutes.',
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: _kInkSoft),
          ),
        ],
      ),
    );
  }

  Widget _nextClassCard() {
    final next = homeController.nextTrialClass();
    if (next == null) return const SizedBox.shrink();
    final c = next.data;
    final trainer = c['trainer'] is Map ? '${(c['trainer'] as Map)['name'] ?? ''}'.trim() : '';
    return _whiteCard(
      Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF7E4),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text('🏋️‍♀️', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NEXT CLASS · ${next.label.toUpperCase()}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: _kAccent,
                    letterSpacing: 0.6,
                  ),
                ),
                Text(
                  '${c['type'] ?? 'Live class'}${trainer.isEmpty ? '' : ' with $trainer'}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _kInk,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _remindersCard() {
    final picked = homeController.trialClasses.where((c) => c['picked'] == true).toList();
    return _whiteCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  '🔔  Your class reminders',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _kInk,
                  ),
                ),
              ),
              TextButton(
                onPressed: _openReminderPicker,
                child: const Text(
                  'Change',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    color: _kAccent,
                  ),
                ),
              ),
            ],
          ),
          if (picked.isEmpty)
            const Text(
              'No reminders yet. Pick a class time so we can remind you.',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 12.5, color: _kInkSoft),
            )
          else
            ...picked.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '${c['startLocal']}  ·  ${c['type']}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _kInk,
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  Future<void> _openReminderPicker() async {
    final classes = homeController.trialClasses;
    if (classes.isEmpty) {
      await homeController.loadTrialClasses();
    }
    final selected = homeController.trialClasses
        .where((c) => c['picked'] == true)
        .map((c) => c['slotId'] as int)
        .toSet();
    final showPk = homeController.trialClassData.value?['showsPakistanTime'] == true;
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _kBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          builder: (ctx, scroll) => Column(
            children: [
              Expanded(
                child: ListView(
                  controller: scroll,
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                  children: [
                    const Text(
                      'Pick your class times ⏰',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _kInk,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "We'll remind you before each one. You can still join any class.",
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 12.5, color: _kInkSoft),
                    ),
                    const SizedBox(height: 14),
                    ...homeController.trialClasses.map((c) {
                      final id = c['slotId'] as int;
                      return TrialClassCard(
                        data: c,
                        selected: selected.contains(id),
                        showPakistanTime: showPk,
                        onTap: () => setSheet(() {
                          if (!selected.remove(id)) selected.add(id);
                        }),
                      );
                    }),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: selected.isEmpty
                        ? null
                        : () async {
                            final ok = await homeController.updateTrialReminderSlots(
                                replace: selected);
                            if (ok) {
                              Get.back();
                              CustomToast.successToast(msg: 'Reminders updated');
                            } else {
                              CustomToast.failToast(msg: 'Could not save. Please try again.');
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kAccent,
                      disabledBackgroundColor: _kAccent.withOpacity(0.35),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      selected.isEmpty ? 'Pick at least one' : 'Save reminders',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  Widget _mainButton() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (_isActive) {
          Get.offAll(() => BottomBarScreen(index: 1));
        } else {
          Get.to(() => const TrialSummaryScreen());
        }
      },
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _kAccent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _kAccent.withOpacity(0.33),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          _isActive ? 'See live classes' : 'See my trial summary',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _whiteCard(Widget child) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _kBorder),
        ),
        child: child,
      );
}
