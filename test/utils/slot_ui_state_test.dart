import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_zone_2/utils/slot_ui_state.dart';

void main() {
  // Reference times — the slot runs 8:00-8:50 AM on a fixed date so
  // every test is deterministic regardless of wall clock.
  final start = DateTime(2026, 5, 2, 8, 0);
  final end = DateTime(2026, 5, 2, 8, 50);

  const defaultUser = UserAccessInput(isFrozen: false, remainingDays: 30);

  SlotInput slotWith({
    String? status = 'Upcoming Class',
    String? link,
    DateTime? customStart,
    DateTime? customEnd,
  }) =>
      SlotInput(
        status: status,
        start: customStart ?? start,
        end: customEnd ?? end,
        trainerLink: link,
      );

  group('cancelled — overrides every other state', () {
    test('cancelled long before start', () {
      expect(
        resolveSlotUIState(
          slot: slotWith(status: SlotStatus.cancelled),
          now: start.subtract(const Duration(hours: 4)),
          user: defaultUser,
        ),
        SlotUIState.cancelled,
      );
    });

    test('cancelled inside the window even with link present', () {
      expect(
        resolveSlotUIState(
          slot: slotWith(status: SlotStatus.cancelled, link: 'https://zoom'),
          now: start.add(const Duration(minutes: 5)),
          user: defaultUser,
        ),
        SlotUIState.cancelled,
      );
    });

    test('cancelled after end is still cancelled (not endedNotAttended)', () {
      expect(
        resolveSlotUIState(
          slot: slotWith(status: SlotStatus.cancelled),
          now: end.add(const Duration(hours: 2)),
          user: defaultUser,
        ),
        SlotUIState.cancelled,
      );
    });
  });

  group('upcoming — before start', () {
    test('16+ minutes before start -> upcomingFar', () {
      expect(
        resolveSlotUIState(
          slot: slotWith(),
          now: start.subtract(const Duration(minutes: 16)),
          user: defaultUser,
        ),
        SlotUIState.upcomingFar,
      );
    });

    test('exactly 15 minutes before start -> upcomingSoon (boundary)', () {
      expect(
        resolveSlotUIState(
          slot: slotWith(),
          now: start.subtract(const Duration(minutes: 15)),
          user: defaultUser,
        ),
        SlotUIState.upcomingSoon,
      );
    });

    test('1 minute before start -> upcomingSoon', () {
      expect(
        resolveSlotUIState(
          slot: slotWith(),
          now: start.subtract(const Duration(minutes: 1)),
          user: defaultUser,
        ),
        SlotUIState.upcomingSoon,
      );
    });
  });

  group('in window — gating logic', () {
    test('exactly at start with status not In Progress -> liveNotReady', () {
      expect(
        resolveSlotUIState(
          slot: slotWith(status: 'Class Link Added', link: 'https://zoom'),
          now: start,
          user: defaultUser,
        ),
        SlotUIState.liveNotReady,
      );
    });

    test('In Progress + null link -> liveNotReady', () {
      expect(
        resolveSlotUIState(
          slot: slotWith(status: SlotStatus.inProgress, link: null),
          now: start.add(const Duration(minutes: 5)),
          user: defaultUser,
        ),
        SlotUIState.liveNotReady,
      );
    });

    test('In Progress + empty link -> liveNotReady', () {
      expect(
        resolveSlotUIState(
          slot: slotWith(status: SlotStatus.inProgress, link: ''),
          now: start.add(const Duration(minutes: 5)),
          user: defaultUser,
        ),
        SlotUIState.liveNotReady,
      );
    });

    test('In Progress + whitespace-only link -> liveNotReady', () {
      expect(
        resolveSlotUIState(
          slot: slotWith(status: SlotStatus.inProgress, link: '   '),
          now: start.add(const Duration(minutes: 5)),
          user: defaultUser,
        ),
        SlotUIState.liveNotReady,
      );
    });

    test('In Progress + link + frozen user -> liveBlocked', () {
      expect(
        resolveSlotUIState(
          slot: slotWith(status: SlotStatus.inProgress, link: 'https://zoom'),
          now: start.add(const Duration(minutes: 5)),
          user: const UserAccessInput(isFrozen: true, remainingDays: 30),
        ),
        SlotUIState.liveBlocked,
      );
    });

    test('In Progress + link + 0 remainingDays -> liveBlocked', () {
      expect(
        resolveSlotUIState(
          slot: slotWith(status: SlotStatus.inProgress, link: 'https://zoom'),
          now: start.add(const Duration(minutes: 5)),
          user: const UserAccessInput(isFrozen: false, remainingDays: 0),
        ),
        SlotUIState.liveBlocked,
      );
    });

    test('In Progress + link + negative remainingDays -> liveBlocked', () {
      expect(
        resolveSlotUIState(
          slot: slotWith(status: SlotStatus.inProgress, link: 'https://zoom'),
          now: start.add(const Duration(minutes: 5)),
          user: const UserAccessInput(isFrozen: false, remainingDays: -3),
        ),
        SlotUIState.liveBlocked,
      );
    });

    test('all clear -> liveReady', () {
      expect(
        resolveSlotUIState(
          slot: slotWith(status: SlotStatus.inProgress, link: 'https://zoom'),
          now: start.add(const Duration(minutes: 5)),
          user: defaultUser,
        ),
        SlotUIState.liveReady,
      );
    });

    test('exactly at end (boundary) is past, not live', () {
      expect(
        resolveSlotUIState(
          slot: slotWith(status: SlotStatus.inProgress, link: 'https://zoom'),
          now: end,
          user: defaultUser,
        ),
        SlotUIState.past,
      );
    });

    test('one millisecond before end is still in window', () {
      expect(
        resolveSlotUIState(
          slot: slotWith(status: SlotStatus.inProgress, link: 'https://zoom'),
          now: end.subtract(const Duration(milliseconds: 1)),
          user: defaultUser,
        ),
        SlotUIState.liveReady,
      );
    });

    test('block reason wins over not-ready when both apply', () {
      // Per spec ordering, when status is "In Progress" + link present we
      // check user gates next — so user.isFrozen returns liveBlocked, not
      // liveNotReady. The earlier-stage liveNotReady is for the case
      // where the slot itself isn't ready yet.
      expect(
        resolveSlotUIState(
          slot: slotWith(status: SlotStatus.inProgress, link: 'https://zoom'),
          now: start.add(const Duration(minutes: 1)),
          user: const UserAccessInput(isFrozen: true, remainingDays: 0),
        ),
        SlotUIState.liveBlocked,
      );
    });
  });

  group('after end', () {
    test('was In Progress -> past', () {
      expect(
        resolveSlotUIState(
          slot: slotWith(status: SlotStatus.inProgress),
          now: end.add(const Duration(seconds: 1)),
          user: defaultUser,
        ),
        SlotUIState.past,
      );
    });

    test('Completed -> past', () {
      expect(
        resolveSlotUIState(
          slot: slotWith(status: SlotStatus.completed),
          now: end.add(const Duration(hours: 1)),
          user: defaultUser,
        ),
        SlotUIState.past,
      );
    });

    test('still Upcoming Class (never went live) -> endedNotAttended', () {
      expect(
        resolveSlotUIState(
          slot: slotWith(status: 'Upcoming Class'),
          now: end.add(const Duration(minutes: 1)),
          user: defaultUser,
        ),
        SlotUIState.endedNotAttended,
      );
    });

    test('Class Link Added but never started -> endedNotAttended', () {
      expect(
        resolveSlotUIState(
          slot: slotWith(status: 'Class Link Added', link: 'https://zoom'),
          now: end.add(const Duration(hours: 5)),
          user: defaultUser,
        ),
        SlotUIState.endedNotAttended,
      );
    });

    test('null status after end -> endedNotAttended', () {
      expect(
        resolveSlotUIState(
          slot: slotWith(status: null),
          now: end.add(const Duration(minutes: 30)),
          user: defaultUser,
        ),
        SlotUIState.endedNotAttended,
      );
    });
  });

  group('unknown / null status (defensive)', () {
    test('null status before start -> upcomingFar (cancelled check skipped)', () {
      expect(
        resolveSlotUIState(
          slot: slotWith(status: null),
          now: start.subtract(const Duration(hours: 1)),
          user: defaultUser,
        ),
        SlotUIState.upcomingFar,
      );
    });

    test('null status in window -> liveNotReady', () {
      expect(
        resolveSlotUIState(
          slot: slotWith(status: null, link: 'https://zoom'),
          now: start.add(const Duration(minutes: 5)),
          user: defaultUser,
        ),
        SlotUIState.liveNotReady,
      );
    });

    test('unknown future status in window -> liveNotReady', () {
      expect(
        resolveSlotUIState(
          slot: slotWith(status: 'Some New Status', link: 'https://zoom'),
          now: start.add(const Duration(minutes: 5)),
          user: defaultUser,
        ),
        SlotUIState.liveNotReady,
      );
    });
  });

  group('whitespace tolerance — trims status', () {
    test('"Cancelled " (trailing space) -> cancelled', () {
      expect(
        resolveSlotUIState(
          slot: slotWith(status: 'Cancelled '),
          now: start.add(const Duration(minutes: 5)),
          user: defaultUser,
        ),
        SlotUIState.cancelled,
      );
    });

    test('" In Progress " (surrounding spaces) in window -> liveReady', () {
      expect(
        resolveSlotUIState(
          slot: slotWith(status: ' In Progress ', link: 'https://zoom'),
          now: start.add(const Duration(minutes: 5)),
          user: defaultUser,
        ),
        SlotUIState.liveReady,
      );
    });

    test('"Completed " (trailing space) after end -> past', () {
      expect(
        resolveSlotUIState(
          slot: slotWith(status: 'Completed '),
          now: end.add(const Duration(hours: 1)),
          user: defaultUser,
        ),
        SlotUIState.past,
      );
    });
  });

  group('presentationForState — button mapping', () {
    test('past -> hidden, no action', () {
      final p = presentationForState(SlotUIState.past);
      expect(p.appearance, SlotButtonAppearance.hidden);
      expect(p.buttonLabel, isNull);
      expect(p.buttonColor, SlotButtonColor.none);
      expect(p.toastMessage, isNull);
      expect(p.action, SlotButtonAction.none);
    });

    test('endedNotAttended -> hidden', () {
      expect(
        presentationForState(SlotUIState.endedNotAttended).appearance,
        SlotButtonAppearance.hidden,
      );
    });

    test('cancelled -> hidden, no action', () {
      final p = presentationForState(SlotUIState.cancelled);
      expect(p.appearance, SlotButtonAppearance.hidden);
      expect(p.action, SlotButtonAction.none);
    });

    test('upcomingFar -> hidden', () {
      expect(
        presentationForState(SlotUIState.upcomingFar).appearance,
        SlotButtonAppearance.hidden,
      );
    });

    test('upcomingSoon with minutesUntilStart=5 -> "Starts in 5m"', () {
      final p = presentationForState(
        SlotUIState.upcomingSoon,
        minutesUntilStart: 5,
      );
      expect(p.appearance, SlotButtonAppearance.disabled);
      expect(p.buttonLabel, 'Starts in 5m');
      expect(p.buttonColor, SlotButtonColor.grey);
      expect(p.toastMessage, "Class hasn't started yet");
      expect(p.action, SlotButtonAction.showToast);
    });

    test('upcomingSoon without minutes -> "Starts soon"', () {
      final p = presentationForState(SlotUIState.upcomingSoon);
      expect(p.buttonLabel, 'Starts soon');
      expect(p.appearance, SlotButtonAppearance.disabled);
    });

    test('liveNotReady -> grey "Join now" with setup toast', () {
      final p = presentationForState(SlotUIState.liveNotReady);
      expect(p.appearance, SlotButtonAppearance.disabled);
      expect(p.buttonLabel, 'Join now');
      expect(p.buttonColor, SlotButtonColor.grey);
      expect(p.toastMessage, 'Trainer is setting up, hold tight');
      expect(p.action, SlotButtonAction.showToast);
    });

    test('liveBlocked + frozen -> frozen-account toast', () {
      final p = presentationForState(
        SlotUIState.liveBlocked,
        blockReason: SlotBlockReason.frozen,
      );
      expect(p.appearance, SlotButtonAppearance.disabled);
      expect(p.buttonLabel, 'Join now');
      expect(p.buttonColor, SlotButtonColor.grey);
      expect(
        p.toastMessage,
        'Your account is frozen, please unfreeze first.',
      );
      expect(p.action, SlotButtonAction.showToast);
    });

    test('liveBlocked + expired -> renew-plan toast', () {
      final p = presentationForState(
        SlotUIState.liveBlocked,
        blockReason: SlotBlockReason.expired,
      );
      expect(p.toastMessage, 'Please renew your plan.');
    });

    test('liveBlocked with no reason given -> defaults to expired toast', () {
      final p = presentationForState(SlotUIState.liveBlocked);
      expect(p.toastMessage, 'Please renew your plan.');
    });

    test('liveReady -> enabled, accent, joinClass action', () {
      final p = presentationForState(SlotUIState.liveReady);
      expect(p.appearance, SlotButtonAppearance.enabled);
      expect(p.buttonLabel, 'Join now');
      expect(p.buttonColor, SlotButtonColor.accent);
      expect(p.toastMessage, isNull);
      expect(p.action, SlotButtonAction.joinClass);
    });

    test('only liveReady ever produces joinClass action', () {
      // Defends against a future edit accidentally letting a not-ready
      // state launch Zoom.
      for (final state in SlotUIState.values) {
        final p = presentationForState(state);
        if (state != SlotUIState.liveReady) {
          expect(
            p.action,
            isNot(SlotButtonAction.joinClass),
            reason: '$state should not be joinable',
          );
        }
      }
    });
  });
}
