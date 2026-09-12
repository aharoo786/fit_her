// Pure logic extracted from SocketController so it can be unit tested
// without a live socket connection, GetX bindings, or SharedPreferences.
// SocketController's private methods delegate to these — see
// test/notifications/socket_time_block_test.dart for the test suite,
// and the audit report for the known discrepancy vs. the backend's
// TIME_BLOCK_HOURS windows in crownjobfunction.js (client has no
// midnight-wrap handling for 'night', backend does).

/// Whether a class starting at [slotStart] falls inside the user's
/// preferred notification [timeBlock] ('morning'|'afternoon'|'evening'|
/// 'night'|'all'). Fails open (returns true — i.e. "show the
/// notification") for 'all', missing/empty [slotStart], or any parse
/// error, so a formatting surprise never silently swallows a real
/// class reminder.
///
/// [slotStart] accepts either 12h ("8:00 AM" / "08:00 PM") or 24h
/// ("08:00") formatted strings.
bool isSlotTimeInPreferredBlock(String timeBlock, String? slotStart) {
  if (timeBlock == 'all') return true;
  if (slotStart == null || slotStart.isEmpty) return true;

  try {
    int hour;
    final upper = slotStart.toUpperCase().trim();

    if (upper.contains('AM') || upper.contains('PM')) {
      // 12h format: "8:00 AM" or "08:00 PM"
      final isPm = upper.contains('PM');
      final timePart = upper.replaceAll('AM', '').replaceAll('PM', '').trim();
      final parts = timePart.split(':');
      hour = int.parse(parts[0]);
      if (isPm && hour != 12) hour += 12;
      if (!isPm && hour == 12) hour = 0;
    } else {
      // 24h format: "08:00"
      final parts = slotStart.split(':');
      hour = int.parse(parts[0]);
    }

    switch (timeBlock) {
      case 'morning':
        return hour >= 6 && hour < 11;
      case 'afternoon':
        return hour >= 11 && hour < 16;
      case 'evening':
        return hour >= 16 && hour < 20;
      case 'night':
        return hour >= 20 && hour < 23;
      default:
        return true;
    }
  } catch (_) {
    return true;
  }
}

/// Local-notification title for a class-slot status change.
String classReminderTitleForStatus(String? status) {
  switch (status) {
    case 'Cancelled':
      return 'Class Cancelled';
    case 'In Progress':
      return 'Sweat Now, Selfies Later 💪';
    default:
      return 'Class Link Added';
  }
}

/// Local-notification body for a class-slot status change.
String classReminderBodyForStatus(String? status) {
  switch (status) {
    case 'Cancelled':
      return 'Sorry, your upcoming class has been cancelled.';
    case 'In Progress':
      return 'Join the session now.';
    default:
      return 'Join the session now.';
  }
}
