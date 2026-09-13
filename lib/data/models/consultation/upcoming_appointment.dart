/// Returned by GET /appointment/me/current. Represents the signed-in
/// user's single most relevant ACTIVE (pending/confirmed/In Progress)
/// consultation booking, if any — used to render the "your booked
/// consultation" card on the Diet tab (Reschedule/Cancel actions).
///
/// `null` in place of an instance means "nothing booked right now",
/// which is a normal, expected state — not an error.
class UpcomingAppointment {
  final int id;
  final String date; // YYYY-MM-DD
  final String status; // pending | confirmed | In Progress
  final String? kind; // initial | followup
  final int userId;
  final int userPlanId;
  final int dietitianId;
  final String? dietitianName;
  final String? slotStart;
  final String? slotEnd;

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
  });

  /// Reschedule/Cancel only make sense before the session has started or
  /// finished. Once it's "In Progress" the dietitian owns the state from
  /// here, and completed/canceled rows never reach this model at all
  /// (the backend only returns pending/confirmed/In Progress rows).
  bool get canModify => status == 'pending' || status == 'confirmed';

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
    );
  }
}
