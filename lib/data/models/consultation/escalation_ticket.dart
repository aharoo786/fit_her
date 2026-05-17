/// Mirrors backend EscalationTickets row. Used by the admin/dietitian
/// queue UI in Phase 3-4 work. User-side just sees a confirmation when
/// they open one (MEDICAL or PLAN_DELAYED via the FAB / popup CTAs).
class EscalationTicket {
  final int? id;
  final int? userId;
  final int? dietitianId;
  final String? trigger;
  final String? severity;
  final String? status;
  final Map<String, dynamic>? payload;
  final bool notifiedDietitian;
  final bool notifiedAdmin;
  final DateTime? openedAt;
  final DateTime? resolvedAt;
  final int? resolvedBy;
  final String? resolutionNote;

  const EscalationTicket({
    this.id,
    this.userId,
    this.dietitianId,
    this.trigger,
    this.severity,
    this.status,
    this.payload,
    this.notifiedDietitian = false,
    this.notifiedAdmin = false,
    this.openedAt,
    this.resolvedAt,
    this.resolvedBy,
    this.resolutionNote,
  });

  factory EscalationTicket.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? m(dynamic x) =>
        x is Map ? Map<String, dynamic>.from(x) : null;
    DateTime? d(dynamic x) =>
        x is String && x.isNotEmpty ? DateTime.tryParse(x) : null;

    return EscalationTicket(
      id: json['id'] as int?,
      userId: json['userId'] as int?,
      dietitianId: json['dietitianId'] as int?,
      trigger: json['trigger'] as String?,
      severity: json['severity'] as String?,
      status: json['status'] as String?,
      payload: m(json['payload']),
      notifiedDietitian: (json['notifiedDietitian'] as bool?) ?? false,
      notifiedAdmin: (json['notifiedAdmin'] as bool?) ?? false,
      openedAt: d(json['openedAt']),
      resolvedAt: d(json['resolvedAt']),
      resolvedBy: json['resolvedBy'] as int?,
      resolutionNote: json['resolutionNote'] as String?,
    );
  }
}
