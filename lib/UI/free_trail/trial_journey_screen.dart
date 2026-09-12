import 'dart:math' as math;

import 'package:fitness_zone_2/UI/dashboard_module/bottom_bar_screen/bottom_bar_screen.dart';
import 'package:fitness_zone_2/UI/free_trail/trial_completion_screen.dart';
import 'package:fitness_zone_2/data/api_provider/api_provider.dart';
import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/utils/app_clock.dart';
import 'package:fitness_zone_2/values/constants.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:fitness_zone_2/widgets/circular_progress.dart';
import 'package:fitness_zone_2/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TrialJourneyScreen extends StatefulWidget {
  const TrialJourneyScreen({super.key});

  @override
  State<TrialJourneyScreen> createState() => _TrialJourneyScreenState();
}

class _TrialJourneyScreenState extends State<TrialJourneyScreen> {
  final HomeController homeController = Get.find();
  int _classStart = 1;

  @override
  void initState() {
    super.initState();
    _loadJourney();
  }

  Future<void> _loadJourney() async {
    await homeController.getMyTrialJourney();
    if (homeController.trialJourney == null) {
      // Bug 1 fix: confirm before starting so the 3-day clock only begins when
      // the user explicitly opts in. Without this, simply navigating here
      // silently creates a TrialJourney and starts the 3-day window.
      final confirmed = await _confirmStartTrial();
      if (!confirmed) {
        Get.back();
        return;
      }
      await homeController.startTrial();
      await homeController.getMyTrialJourney();
    }
    await _loadNotificationPreference();
  }

  Future<bool> _confirmStartTrial() async {
    if (!mounted) return false;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Start your free 3-day trial?',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
        content: const Text(
          'Once started, your 3-day pass will be active immediately.\n\n'
          'You can join any live class during your trial. '
          'You must join within 10 minutes of the class start time.',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Not now',
              style: TextStyle(fontFamily: 'Poppins', color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Start trial',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
    return result == true;
  }

  Future<void> _loadNotificationPreference() async {
    final token =
        homeController.sharedPreferences.getString(Constants.accessToken) ?? "";
    if (token.isEmpty) return;

    final response = await Get.find<ApiProvider>().getData(
      '/users/notification_preferences',
      headers: {'accessToken': token},
    );

    final data = response.body?['data'];
    if (!mounted || data is! Map) return;
    setState(() {
      _classStart = data['classStart'] ?? 1;
    });
  }

  Future<void> _saveClassStartPreference(bool value) async {
    final token =
        homeController.sharedPreferences.getString(Constants.accessToken) ?? "";
    if (token.isEmpty) return;

    setState(() {
      _classStart = value ? 1 : 0;
    });

    await Get.find<ApiProvider>().postData(
      '/users/notification_preferences',
      body: {'classStart': _classStart},
      headers: {'accessToken': token},
    );
  }

  DateTime? get _startedAt {
    final raw = homeController.trialJourney?["startedAt"];
    return raw == null ? null : DateTime.tryParse(raw.toString());
  }

  DateTime? get _endsAt => _startedAt?.add(const Duration(days: 3));

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
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(() {
        Get.back();
      }, text: "3-Day Trial"),
      body: Obx(() {
        if (!homeController.trialLoad.value) {
          return const CircularProgress();
        }

        return RefreshIndicator(
          onRefresh: _loadJourney,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                _isActive
                    ? "Your 3-day pass is active"
                    : "Your trial has ended",
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isActive
                    ? "Join any live workout class during your trial. You do not need to book a trial slot first."
                    : "You can continue by reviewing your trial and choosing a plan.",
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.28)),
                  color: Colors.green.withOpacity(0.08),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isActive
                          ? "$_daysLeft day${_daysLeft == 1 ? '' : 's'} left"
                          : "Trial complete",
                      style: textTheme.titleMedium?.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Free-trial users can join classes only until 10 minutes after the class start time.",
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.notifications_active_outlined),
                title: Text(
                  "Class starting notifications",
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: const Text(
                  "Turn this off if frequent class-start alerts feel distracting during your trial.",
                ),
                value: _classStart == 1,
                onChanged: _saveClassStartPreference,
              ),
              const SizedBox(height: 20),
              if (_isActive)
                CustomButton(
                  text: "Browse Classes",
                  onPressed: () {
                    Get.offAll(() => BottomBarScreen(index: 1));
                  },
                )
              else
                CustomButton(
                  text: "Continue to Review & Subscription",
                  onPressed: () {
                    Get.to(() => const TrialCompletionScreen());
                  },
                ),
            ],
          ),
        );
      }),
    );
  }
}
