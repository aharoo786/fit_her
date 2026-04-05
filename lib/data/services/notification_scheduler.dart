import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Schedules local notifications for morning nudge and weekly check-in.
///
/// Works alongside [NotificationServices] which handles FCM push notifications.
/// Uses the same Android channel ('high_importance_channel') for consistency.
class NotificationScheduler {
  NotificationScheduler._();

  static const int morningNudgeId = 1001;
  static const int weeklyCheckinId = 6001;

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// Initializes timezone data. Must be called once at app startup.
  static Future<void> initialize() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
    _initialized = true;
    debugPrint('🔔 NotificationScheduler initialized, timezone: $timeZoneName');
  }

  /// Schedules the morning nudge at 8:00 AM daily.
  ///
  /// Lock screen safe — no cycle/health data in title or body.
  /// If [enabled] is false, cancels the existing notification.
  static Future<void> scheduleMorningNudge({
    required bool enabled,
  }) async {
    if (!enabled) {
      await _plugin.cancel(morningNudgeId);
      return;
    }

    final scheduledDate = _nextOccurrence(8, 0);

    try {
      debugPrint('🔔 Scheduling morning nudge for: $scheduledDate');
      await _plugin.zonedSchedule(
        morningNudgeId,
        'Your daily insight is ready',
        'Open FitHer to see today\'s recommendations',
        scheduledDate,
        _notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint('🔔 Morning nudge scheduled successfully');
    } catch (e) {
      debugPrint('🔔 ERROR scheduling morning nudge: $e');
    }
  }

  /// Schedules the weekly check-in reminder for Sunday at 7:00 PM.
  ///
  /// Suppressed if user already completed weekly check-in this week.
  /// If [enabled] is false or [alreadyDoneThisWeek] is true, cancels it.
  static Future<void> scheduleWeeklyCheckin({
    required bool enabled,
    required bool alreadyDoneThisWeek,
  }) async {
    if (!enabled || alreadyDoneThisWeek) {
      await _plugin.cancel(weeklyCheckinId);
      return;
    }

    final scheduledDate = _nextDayOfWeek(DateTime.sunday, 19, 0);

    await _plugin.zonedSchedule(
      weeklyCheckinId,
      'Weekly check-in time',
      '1 minute to update your trends. Your report gets better with every check-in.',
      scheduledDate,
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  /// Returns true if the current local time falls within quiet hours.
  ///
  /// Handles midnight crossing correctly (e.g. 22:00 to 07:00).
  static bool isQuietHours(String quietStart, String quietEnd) {
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;

    final startParts = quietStart.split(':');
    final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);

    final endParts = quietEnd.split(':');
    final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

    if (startMinutes > endMinutes) {
      // Spans midnight: e.g. 22:00 to 07:00
      return currentMinutes >= startMinutes || currentMinutes < endMinutes;
    } else {
      return currentMinutes >= startMinutes && currentMinutes < endMinutes;
    }
  }

  /// Reschedules all notifications based on current preferences.
  ///
  /// Called on every app open to ensure notifications reflect current state.
  /// [prefs] should contain keys: morningNudge, weeklyCheckin, quietStart, quietEnd.
  static Future<void> rescheduleAll({
    required Map<String, dynamic> prefs,
    required bool weeklyCheckinDone,
  }) async {
    await initialize();

    final morningEnabled = prefs['morningNudge'] == 1;
    final weeklyEnabled = prefs['weeklyCheckin'] == 1;

    await scheduleMorningNudge(enabled: morningEnabled);
    await scheduleWeeklyCheckin(
      enabled: weeklyEnabled,
      alreadyDoneThisWeek: weeklyCheckinDone,
    );
  }

  /// Cancels all scheduled notifications managed by this scheduler.
  static Future<void> cancelAll() async {
    await _plugin.cancel(morningNudgeId);
    await _plugin.cancel(weeklyCheckinId);
  }

  /// Cancels a single notification by ID.
  static Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  // ── Private helpers ──────────────────────────────────────

  /// Returns the next occurrence of the given hour:minute in local timezone.
  /// If the time has already passed today, returns tomorrow.
  static tz.TZDateTime _nextOccurrence(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// Returns the next occurrence of a specific day of week at hour:minute.
  /// If that day/time has already passed this week, returns next week.
  static tz.TZDateTime _nextDayOfWeek(int weekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var daysUntil = weekday - now.weekday;
    if (daysUntil < 0) daysUntil += 7;

    var scheduled = tz.TZDateTime(
      tz.local, now.year, now.month, now.day + daysUntil, hour, minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 7));
    }
    return scheduled;
  }

  /// Notification details using the existing high_importance_channel.
  static NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        channelDescription: 'This channel is used for important notifications.',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }
}
