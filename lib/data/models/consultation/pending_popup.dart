/// Single entry in HomeDashboardModel.pendingPopups. Drives the
/// PendingPopupOrchestrator (Phase 2D). The variable string maps 1:1 to
/// a Flutter sheet; metadata carries cycle/planId/etc. needed at render.
class PendingPopup {
  final String variable; // e.g. "POPUP_DAY7_REVIEW"
  final DateTime? eligibleAt;
  final int dismissCount;
  final Map<String, dynamic>? metadata;

  const PendingPopup({
    required this.variable,
    this.eligibleAt,
    this.dismissCount = 0,
    this.metadata,
  });

  factory PendingPopup.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? m(dynamic x) =>
        x is Map ? Map<String, dynamic>.from(x) : null;
    DateTime? d(dynamic x) =>
        x is String && x.isNotEmpty ? DateTime.tryParse(x) : null;

    return PendingPopup(
      variable: (json['variable'] as String?) ?? '',
      eligibleAt: d(json['eligibleAt']),
      dismissCount: (json['dismissCount'] as int?) ?? 0,
      metadata: m(json['metadata']),
    );
  }
}
