/// Single source of truth for what the workout schedule UI should
/// render for a given slot. The schedule card and the bottom-sheet
/// popup must both call [resolveSlotUIState] so they cannot disagree.
///
/// Pure: no DateTime.now(), no controllers, no I/O. Caller injects
/// [now] from app clock and pre-parsed slot times. The resolver does
/// not do timezone math — anchor [SlotInput.start]/[SlotInput.end] to
/// the correct calendar date before calling.
library;

enum SlotUIState {
  /// Admin marked the slot as cancelled. Show "Cancelled" pill, no
  /// actions. Beats every other state.
  cancelled,

  /// More than 15 minutes from start. Neutral upcoming card, no
  /// Join button.
  upcomingFar,

  /// Within 15 minutes of start, before start. Show countdown pill;
  /// button is disabled with "Starts in Xm" label and a toast on tap.
  upcomingSoon,

  /// In the start..end window, but the slot is not yet joinable —
  /// either backend status isn't "In Progress" or trainerLink is
  /// missing/empty. Grey "Join now"; toast "Trainer is setting up".
  liveNotReady,

  /// In window, status is "In Progress", link present, but the user
  /// is gated: plan is frozen or expired. Grey "Join now"; toast
  /// names the actual block reason.
  liveBlocked,

  /// All clear: in window, status In Progress, link present, user
  /// unblocked. Green "Join now"; tapping launches Zoom.
  liveReady,

  /// After end, and the slot reached "In Progress" or "Completed".
  /// Show neutral past card, no actions.
  past,

  /// After end, and the slot never went live (status stayed
  /// "Upcoming Class" / "Class Link Added"). Distinct from [past] so
  /// the UI can flag missed sessions for follow-up.
  endedNotAttended,
}

/// Backend status string constants the resolver cares about. Anything
/// else is treated as "not live" — safer than throwing on an unknown
/// value the admin panel could one day introduce.
class SlotStatus {
  static const String inProgress = 'In Progress';
  static const String completed = 'Completed';
  static const String cancelled = 'Cancelled';
}

/// Slot fields the resolver needs. The full Slot model intentionally
/// is not imported so this file stays free of UI/data dependencies and
/// the resolver remains trivially testable.
class SlotInput {
  final String? status;
  final DateTime start;
  final DateTime end;
  final String? trainerLink;

  const SlotInput({
    required this.status,
    required this.start,
    required this.end,
    required this.trainerLink,
  });
}

/// Plan-level access state. [remainingDays] <= 0 means the plan is
/// expired — the same gate the popup currently checks.
class UserAccessInput {
  final bool isFrozen;
  final int remainingDays;

  const UserAccessInput({
    required this.isFrozen,
    required this.remainingDays,
  });
}

const Duration _kSoonWindow = Duration(minutes: 15);

bool _wasOrIsLive(String? trimmedStatus) =>
    trimmedStatus == SlotStatus.inProgress ||
    trimmedStatus == SlotStatus.completed;

bool _hasLink(String? link) => link != null && link.trim().isNotEmpty;

SlotUIState resolveSlotUIState({
  required SlotInput slot,
  required DateTime now,
  required UserAccessInput user,
}) {
  // Trim once: cheap defense against backend whitespace creeping into a
  // status value (e.g. "Cancelled ") which would otherwise silently fall
  // through and grant the wrong state.
  final status = slot.status?.trim();

  // Cancelled overrides every time/state check below.
  if (status == SlotStatus.cancelled) return SlotUIState.cancelled;

  // After the window. The end is treated as the cutoff: at exactly `now
  // == slot.end` the class is over.
  if (!now.isBefore(slot.end)) {
    return _wasOrIsLive(status)
        ? SlotUIState.past
        : SlotUIState.endedNotAttended;
  }

  // Before the window — far vs soon split at start - 15 min.
  final soonStart = slot.start.subtract(_kSoonWindow);
  if (now.isBefore(soonStart)) return SlotUIState.upcomingFar;
  if (now.isBefore(slot.start)) return SlotUIState.upcomingSoon;

  // Inside the window: start <= now < end.
  if (status != SlotStatus.inProgress || !_hasLink(slot.trainerLink)) {
    return SlotUIState.liveNotReady;
  }
  if (user.isFrozen || user.remainingDays <= 0) {
    return SlotUIState.liveBlocked;
  }
  return SlotUIState.liveReady;
}

// ─── presentation layer ─────────────────────────────────────────────────
//
// Both UI surfaces (schedule card "Join now" and bottom-sheet popup
// "Join Session") build their button from this struct. Keeping the UIs
// as dumb renderers prevents the original divergence bug from coming
// back: change a label or a color in one place, both surfaces update.

enum SlotButtonAppearance {
  /// Don't render a button at all (past, cancelled, far upcoming, etc.).
  hidden,

  /// Render a non-tappable button. Tap surface should still show the
  /// `toastMessage` so the user understands why it's grey.
  disabled,

  /// Render a tappable button that triggers `action`.
  enabled,
}

/// Color tokens — kept abstract so the resolver stays Flutter-free.
/// The widget layer maps these to actual Color values.
enum SlotButtonColor {
  /// No button drawn — paired with [SlotButtonAppearance.hidden].
  none,

  /// Brand accent (green for the existing palette). Used for
  /// [SlotUIState.liveReady] only.
  accent,

  /// Disabled / not-yet-actionable look.
  grey,
}

enum SlotButtonAction {
  /// Tap is a no-op. Used with `hidden`, also valid for safety on any
  /// state where the UI should refuse to do anything.
  none,

  /// Launch the slot's trainerLink (Zoom / browser fallback). Only
  /// produced for [SlotUIState.liveReady].
  joinClass,

  /// Tap shows `toastMessage`. Used by all `disabled` states.
  showToast,
}

/// When [SlotUIState.liveBlocked], the caller passes which gate failed
/// so the toast can name the actual reason.
enum SlotBlockReason { frozen, expired }

class SlotPresentation {
  final SlotButtonAppearance appearance;
  final String? buttonLabel;
  final SlotButtonColor buttonColor;
  final String? toastMessage;
  final SlotButtonAction action;

  const SlotPresentation({
    required this.appearance,
    this.buttonLabel,
    required this.buttonColor,
    this.toastMessage,
    required this.action,
  });

  static const SlotPresentation _hidden = SlotPresentation(
    appearance: SlotButtonAppearance.hidden,
    buttonColor: SlotButtonColor.none,
    action: SlotButtonAction.none,
  );
}

/// Pure mapping from [SlotUIState] (+ optional context) to what the
/// button should look like and do.
///
/// [minutesUntilStart] is consulted only for [SlotUIState.upcomingSoon];
/// when null the label falls back to a generic "Starts soon".
///
/// [blockReason] is consulted only for [SlotUIState.liveBlocked]. Caller
/// must pass it; if omitted, a generic plan-unavailable message is used.
SlotPresentation presentationForState(
  SlotUIState state, {
  int? minutesUntilStart,
  SlotBlockReason? blockReason,
}) {
  switch (state) {
    case SlotUIState.cancelled:
    case SlotUIState.past:
    case SlotUIState.endedNotAttended:
    case SlotUIState.upcomingFar:
      return SlotPresentation._hidden;

    case SlotUIState.upcomingSoon:
      final label = minutesUntilStart != null
          ? 'Starts in ${minutesUntilStart}m'
          : 'Starts soon';
      return SlotPresentation(
        appearance: SlotButtonAppearance.disabled,
        buttonLabel: label,
        buttonColor: SlotButtonColor.grey,
        toastMessage: "Class hasn't started yet",
        action: SlotButtonAction.showToast,
      );

    case SlotUIState.liveNotReady:
      return const SlotPresentation(
        appearance: SlotButtonAppearance.disabled,
        buttonLabel: 'Join now',
        buttonColor: SlotButtonColor.grey,
        toastMessage: 'Trainer is setting up, hold tight',
        action: SlotButtonAction.showToast,
      );

    case SlotUIState.liveBlocked:
      final reason = blockReason ?? SlotBlockReason.expired;
      return SlotPresentation(
        appearance: SlotButtonAppearance.disabled,
        buttonLabel: 'Join now',
        buttonColor: SlotButtonColor.grey,
        toastMessage: reason == SlotBlockReason.frozen
            ? 'Your account is frozen, please unfreeze first.'
            : 'Please renew your plan.',
        action: SlotButtonAction.showToast,
      );

    case SlotUIState.liveReady:
      return const SlotPresentation(
        appearance: SlotButtonAppearance.enabled,
        buttonLabel: 'Join now',
        buttonColor: SlotButtonColor.accent,
        action: SlotButtonAction.joinClass,
      );
  }
}
