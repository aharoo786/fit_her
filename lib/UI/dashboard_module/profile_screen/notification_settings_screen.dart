import 'package:fitness_zone_2/data/api_provider/api_provider.dart';
import 'package:fitness_zone_2/data/controllers/auth_controller/auth_controller.dart';
import 'package:fitness_zone_2/data/Repos/checkin_repo/checkin_repository.dart';
import 'package:fitness_zone_2/data/services/notification_scheduler.dart';
import 'package:fitness_zone_2/theme/app_colors.dart';
import 'package:fitness_zone_2/values/constants.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _isLoading = true;

  int _morningNudge = 1;
  int _classPrep = 1;
  int _classStart = 1;
  int _missedRecovery = 1;
  int _trainerCancelled = 1;
  int _weeklyCheckin = 1;
  String _quietStart = '22:00';
  String _quietEnd = '07:00';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final authController = Get.find<AuthController>();
    final token = authController.sharedPreferences.getString(Constants.accessToken) ?? '';
    final apiProvider = Get.find<ApiProvider>();

    final response = await apiProvider.getData(
      '/users/notification_preferences',
      headers: {'accessToken': token},
    );

    if (response.body != null &&
        response.body['status'] == '1' &&
        response.body['data'] != null) {
      final data = response.body['data'];
      if (mounted) {
        setState(() {
          _morningNudge = data['morningNudge'] ?? 1;
          _classPrep = data['classPrep'] ?? 1;
          _classStart = data['classStart'] ?? 1;
          _missedRecovery = data['missedRecovery'] ?? 1;
          _trainerCancelled = data['trainerCancelled'] ?? 1;
          _weeklyCheckin = data['weeklyCheckin'] ?? 1;
          _quietStart = data['quietStart'] ?? '22:00';
          _quietEnd = data['quietEnd'] ?? '07:00';
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _savePreferences() async {
    final authController = Get.find<AuthController>();
    final token = authController.sharedPreferences.getString(Constants.accessToken) ?? '';
    final apiProvider = Get.find<ApiProvider>();

    final body = {
      'morningNudge': _morningNudge,
      'classPrep': _classPrep,
      'classStart': _classStart,
      'missedRecovery': _missedRecovery,
      'trainerCancelled': _trainerCancelled,
      'weeklyCheckin': _weeklyCheckin,
      'quietStart': _quietStart,
      'quietEnd': _quietEnd,
    };

    await apiProvider.postData(
      '/users/notification_preferences',
      body: body,
      headers: {'accessToken': token},
    );

    // Check weekly check-in status for reschedule
    bool weeklyDone = false;
    final checkinRepo = Get.find<CheckinRepository>();
    final weeklyResponse = await checkinRepo.getWeeklyCheckinsRecent(accessToken: token);
    if (weeklyResponse.body != null &&
        weeklyResponse.body['status'] == '1' &&
        weeklyResponse.body['data'] is List) {
      final checkins = weeklyResponse.body['data'] as List;
      if (checkins.isNotEmpty) {
        final latest = checkins.first;
        final weekDate = latest['weekDate'] as String?;
        if (weekDate != null) {
          final now = DateTime.now();
          final monday = now.subtract(Duration(days: now.weekday - 1));
          final mondayStr = '${monday.year}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';
          weeklyDone = weekDate == mondayStr;
        }
      }
    }

    await NotificationScheduler.rescheduleAll(
      prefs: body,
      weeklyCheckinDone: weeklyDone,
    );
  }

  void _onToggle(String key, bool value) {
    setState(() {
      switch (key) {
        case 'morningNudge':
          _morningNudge = value ? 1 : 0;
          break;
        case 'classPrep':
          _classPrep = value ? 1 : 0;
          break;
        case 'classStart':
          _classStart = value ? 1 : 0;
          break;
        case 'missedRecovery':
          _missedRecovery = value ? 1 : 0;
          break;
        case 'trainerCancelled':
          _trainerCancelled = value ? 1 : 0;
          break;
        case 'weeklyCheckin':
          _weeklyCheckin = value ? 1 : 0;
          break;
      }
    });
    _savePreferences();
  }

  Future<void> _pickTime({required bool isStart}) async {
    final parts = (isStart ? _quietStart : _quietEnd).split(':');
    final initial = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        if (isStart) {
          _quietStart = formatted;
        } else {
          _quietEnd = formatted;
        }
      });
      _savePreferences();
    }
  }

  String _formatTimeDisplay(String time24) {
    final parts = time24.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$displayHour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(() {
        Get.back();
      }, text: "Notifications"),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : ListView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              children: [
                Text(
                  'Notification Types',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 12.h),
                _buildToggleRow(
                  icon: Icons.wb_sunny_outlined,
                  title: 'Daily Insights',
                  description: 'Morning nudge with your daily energy forecast',
                  value: _morningNudge == 1,
                  onChanged: (v) => _onToggle('morningNudge', v),
                ),
                _buildToggleRow(
                  icon: Icons.fitness_center_outlined,
                  title: 'Class Reminders (45 min)',
                  description: 'Get ready reminder before your session',
                  value: _classPrep == 1,
                  onChanged: (v) => _onToggle('classPrep', v),
                ),
                _buildToggleRow(
                  icon: Icons.notifications_active_outlined,
                  title: 'Class Starting (10 min)',
                  description: 'Final call when your session is about to start',
                  value: _classStart == 1,
                  onChanged: (v) => _onToggle('classStart', v),
                ),
                _buildToggleRow(
                  icon: Icons.refresh_outlined,
                  title: 'Missed Session',
                  description: 'Alternative suggestion if you miss your class',
                  value: _missedRecovery == 1,
                  onChanged: (v) => _onToggle('missedRecovery', v),
                ),
                _buildToggleRow(
                  icon: Icons.cancel_outlined,
                  title: 'Session Cancellations',
                  description: 'Immediate alert if your trainer cancels',
                  value: _trainerCancelled == 1,
                  onChanged: (v) => _onToggle('trainerCancelled', v),
                ),
                _buildToggleRow(
                  icon: Icons.calendar_today_outlined,
                  title: 'Weekly Check-in',
                  description: 'Sunday reminder to update your weight and trends',
                  value: _weeklyCheckin == 1,
                  onChanged: (v) => _onToggle('weeklyCheckin', v),
                ),
                SizedBox(height: 24.h),
                Text(
                  'Quiet Hours',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'No notifications during these hours (except cancellations)',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.sp,
                    color: AppColors.textHint,
                  ),
                ),
                SizedBox(height: 12.h),
                _buildTimeRow(
                  label: 'From',
                  value: _formatTimeDisplay(_quietStart),
                  onTap: () => _pickTime(isStart: true),
                ),
                SizedBox(height: 8.h),
                _buildTimeRow(
                  label: 'To',
                  value: _formatTimeDisplay(_quietEnd),
                  onTap: () => _pickTime(isStart: false),
                ),
              ],
            ),
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 22.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    description,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12.sp,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRow({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(Icons.chevron_right, color: AppColors.textHint, size: 20.sp),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
