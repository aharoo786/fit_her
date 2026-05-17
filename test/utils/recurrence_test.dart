import 'package:fitness_zone_2/utils/slot_ui_state.dart';
import 'package:fitness_zone_2/utils/slot_input_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Simulate: today is Saturday 8:30 PM PKT (after the 7-7:50 PM class ended).
  final now = DateTime(2026, 5, 2, 20, 30);

  group('Recurring weekly slot — Saturday 7 PM class', () {
    // Same SlotInput shape the screen builds via buildSlotInput.
    // status carries over from today's session because the row is shared.
    SlotInput buildFor(DateTime selectedDate, String status) {
      return SlotInput(
        status: status,
        start: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 19, 0),
        end:   DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 19, 50),
        trainerLink: null,
      );
    }
    const access = UserAccessInput(isFrozen: false, remainingDays: 30);

    test('Tonight (after end) — status=Completed → past', () {
      final state = resolveSlotUIState(
        slot: buildFor(DateTime(2026, 5, 2), 'Completed'),
        now: now, user: access);
      expect(state, SlotUIState.past);
    });

    test('Tonight — status=Cancelled → cancelled (overrides time)', () {
      final state = resolveSlotUIState(
        slot: buildFor(DateTime(2026, 5, 2), 'Cancelled'),
        now: now, user: access);
      expect(state, SlotUIState.cancelled);
    });

    test('NEXT Saturday viewed Sunday morning (status still Completed pre-cron) → upcomingFar', () {
      // Sunday 04:00 AM PKT — midnight cron has NOT fired yet (it runs at 00:01 server).
      final earlySunday = DateTime(2026, 5, 3, 4, 0);
      final state = resolveSlotUIState(
        slot: buildFor(DateTime(2026, 5, 9), 'Completed'),  // status not yet reset
        now: earlySunday, user: access);
      expect(state, SlotUIState.upcomingFar,
        reason: 'Future-date slot is upcoming regardless of stale status');
    });

    test('NEXT Saturday viewed Wednesday — status reset to Upcoming Class → upcomingFar', () {
      final wednesday = DateTime(2026, 5, 6, 14, 0);
      final state = resolveSlotUIState(
        slot: buildFor(DateTime(2026, 5, 9), 'Upcoming Class'),
        now: wednesday, user: access);
      expect(state, SlotUIState.upcomingFar);
    });

    test('NEXT Saturday at 6:50 PM (10 min before start) → upcomingSoon', () {
      final almostThere = DateTime(2026, 5, 9, 18, 50);
      final state = resolveSlotUIState(
        slot: buildFor(DateTime(2026, 5, 9), 'Upcoming Class'),
        now: almostThere, user: access);
      expect(state, SlotUIState.upcomingSoon);
    });

    test('NEXT Saturday at 7:05 PM, no link yet → liveNotReady (grey button)', () {
      final classTime = DateTime(2026, 5, 9, 19, 5);
      final state = resolveSlotUIState(
        slot: buildFor(DateTime(2026, 5, 9), 'Upcoming Class'),
        now: classTime, user: access);
      expect(state, SlotUIState.liveNotReady);
    });

    test('NEXT Saturday at 7:05 PM, trainer started + link present → liveReady (green)', () {
      final classTime = DateTime(2026, 5, 9, 19, 5);
      final input = SlotInput(
        status: 'In Progress',
        start: DateTime(2026, 5, 9, 19, 0),
        end:   DateTime(2026, 5, 9, 19, 50),
        trainerLink: 'https://zoom.us/abc',
      );
      final state = resolveSlotUIState(slot: input, now: classTime, user: access);
      expect(state, SlotUIState.liveReady);
    });

    test('Cancelled — viewing today honors the cancellation', () {
      // Admin cancelled today. User views today's slot card → cancelled.
      final today = DateTime(2026, 5, 2, 18, 0);
      final state = resolveSlotUIState(
        slot: buildFor(DateTime(2026, 5, 2), 'Cancelled'),
        now: today, user: access);
      expect(state, SlotUIState.cancelled);
    });

    test('Cancelled — viewing NEXT week from today does NOT show cancelled', () {
      // Today: Sat May 2, 11 PM PKT. Admin cancelled today's session.
      // Status="Cancelled" is still on the shared row (cron hasn't fired).
      // User scrolls to NEXT Saturday's view → slot.start is May 9.
      // Resolver should NOT honor cancelled because dates differ.
      final lateSaturday = DateTime(2026, 5, 2, 23, 0);
      final state = resolveSlotUIState(
        slot: buildFor(DateTime(2026, 5, 9), 'Cancelled'),
        now: lateSaturday, user: access);
      expect(state, SlotUIState.upcomingFar,
          reason: 'Cross-date Cancelled should not leak to future occurrences');
    });

    test('Cancelled — Sunday morning before midnight cron, viewing next Sat', () {
      // Status still says Cancelled (cron not fired yet on this server).
      final earlySunday = DateTime(2026, 5, 3, 4, 0);
      final state = resolveSlotUIState(
        slot: buildFor(DateTime(2026, 5, 9), 'Cancelled'),
        now: earlySunday, user: access);
      expect(state, SlotUIState.upcomingFar);
    });

    test('Cancelled — within-day cancellation viewed at the live window', () {
      // Cancellation must override even when the time-window check would
      // say "live" — protects against the live-button activating for a
      // class that was just cancelled.
      final justBeforeStart = DateTime(2026, 5, 2, 18, 50);
      final state = resolveSlotUIState(
        slot: buildFor(DateTime(2026, 5, 2), 'Cancelled'),
        now: justBeforeStart, user: access);
      expect(state, SlotUIState.cancelled);
    });
  });
}
