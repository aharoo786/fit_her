/// Returned by GET /appointment/me/current. Represents the signed-in
/// user's single most relevant consultation booking, if any — used to
/// render the "your booked consultation" card on the Diet tab
/// (Reschedule/Cancel while pending, the "Join Meeting" state machine
/// once confirmed, and a short post-completion window so the "your plan
/// will be delivered in 2 working days" message has something to show).
///
/// `null` in place of an instance means "nothing to show right now",
/// which is a normal, expected state — not an error.
class UpcomingAppointment {
  final int id;
  final String date; // YYYY-MM-DD
  final String status; // pending | confirmed | In Progress | completed
  final String? kind; // initial | followup
  final int userId;
  final int userPlanId;
  final int dietitianId;
  final String? dietitianName;
  final String? slotStart;
  final String? slotEnd;

  // The dietitian's Meet link for this slot, once she's saved one. Null
  // until then — drives the grey ("no link yet") vs. yellow ("link's in,
  // waiting for her to start") stage of the Join Meeting button.
  final String? dietitionLink;

  // True when this appointment's scheduled time has passed by more than
  // the grace window but not yet the staleness cutoff, and no no-show
  // has been reported — mirrors popupEligibility.js's
  // NO_SHOW_GRACE_MINUTES/NO_SHOW_STALE_HOURS rule (via
  // consultationBookingController.js's isAwaitingConsultant). Drives an
  // inline "consultant hasn't joined" notice on this card instead of the
  // old blocking popup.
  final bool awaitingConsultant;

  // True only when `status == 'canceled'` AND this specific
  // cancellation was caused by the dietitian never showing up (not an
  // ordinary client/dietitian-initiated cancel). Drives a dedicated
  // "your dietitian missed this session — rebook free" card state.
  final bool noShow;

  // True only when `status == 'canceled'` AND this specific
  // cancellation was caused by the dietitian never confirming the
  // booking at all (as opposed to noShow, where she DID confirm but
  // never joined). Drives a dedicated "please reschedule" card state.
  final bool expired;

  const UpcomingAppointment({
    required this.id,
    required this.date,
    required this.status,
    this.kind,
    required this.userId,
    required this.userPlanId,
    required this.dietitianId,
    this.dietitianName,
    this.slotStart,
    this.slotEnd,
    this.dietitionLink,
    this.awaitingConsultant = false,
    this.noShow = false,
    this.expired = false,
  });

  /// Reschedule only makes sense before the dietitian has committed to
  /// the slot. Once she's confirmed it, rescheduling is off the table —
  /// the card switches to the Join Meeting flow instead — and Cancel is
  /// handled separately from this flag.
  bool get canModify => status == 'pending';

  factory UpcomingAppointment.fromJson(Map<String, dynamic> json) {
    return UpcomingAppointment(
      id: (json['id'] as num).toInt(),
      date: (json['date'] as String?) ?? '',
      status: (json['status'] as String?) ?? 'pending',
      kind: json['kind'] as String?,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      userPlanId: (json['userPlanId'] as num?)?.toInt() ?? 0,
      dietitianId: (json['dietitianId'] as num?)?.toInt() ?? 0,
      dietitianName: json['dietitianName'] as String?,
      slotStart: json['slotStart'] as String?,
      slotEnd: json['slotEnd'] as String?,
      dietitionLink: (json['dietitionLink'] as String?)?.trim().isNotEmpty ==
              true
          ? json['dietitionLink'] as String
          : null,
      awaitingConsultant: (json['awaitingConsultant'] as bool?) ?? false,
      noShow: (json['noShow'] as bool?) ?? false,
      expired: (json['expired'] as bool?) ?? false,
    );
  }
}
