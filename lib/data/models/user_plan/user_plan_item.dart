/// Models the `data[]` payload from `GET /users/get_user_plans`.
///
/// Backend (partner_backend/controllers/FrontSite/userController.js
/// `get_user_plans`) returns `UserPlan.findAll({ status: true, UserId },
/// include: [Plan])`. Each row carries the freeze/duration/price/date
/// columns from `models/UserPlan.js` plus an embedded `Plan` row.
///
/// Sequelize emits the included model under its model name (`Plan`,
/// capitalized). We accept both casings just in case the backend ever
/// flips the alias — never throw on a missing/renamed key.
class UserPlanItem {
  final int id;
  final DateTime? buyingDate;
  final DateTime? expireDate;
  final String? planStatus;
  final int? price;
  final String? dietitionLink;
  final int? durationIdPlan;
  final DateTime? frozenAt;
  final int? freezeDays;
  final int? totalFrozenDays;
  final int? originalDurationDays;
  final UserPlanInner? plan;

  const UserPlanItem({
    required this.id,
    this.buyingDate,
    this.expireDate,
    this.planStatus,
    this.price,
    this.dietitionLink,
    this.durationIdPlan,
    this.frozenAt,
    this.freezeDays,
    this.totalFrozenDays,
    this.originalDurationDays,
    this.plan,
  });

  factory UserPlanItem.fromJson(Map<String, dynamic> json) {
    final inner = json['Plan'] ?? json['plan'];
    return UserPlanItem(
      id: _toInt(json['id']) ?? 0,
      buyingDate: _toDate(json['buyingDate']),
      expireDate: _toDate(json['expireDate']),
      planStatus: json['planStatus']?.toString(),
      price: _toInt(json['price']),
      dietitionLink: json['dietitionLink']?.toString(),
      durationIdPlan: _toInt(json['durationIdPlan']),
      frozenAt: _toDate(json['frozenAt']),
      freezeDays: _toInt(json['freezeDays']),
      totalFrozenDays: _toInt(json['totalFrozenDays']),
      originalDurationDays: _toInt(json['originalDurationDays']),
      plan: inner is Map<String, dynamic>
          ? UserPlanInner.fromJson(inner)
          : null,
    );
  }
}

class UserPlanInner {
  final int? id;
  final String? title;
  final String? shortDescription;
  final String? longDescription;

  const UserPlanInner({
    this.id,
    this.title,
    this.shortDescription,
    this.longDescription,
  });

  factory UserPlanInner.fromJson(Map<String, dynamic> json) =>
      UserPlanInner(
        id: _toInt(json['id']),
        title: json['title']?.toString(),
        shortDescription: json['shortDescription']?.toString(),
        longDescription: json['longDescription']?.toString(),
      );
}

int? _toInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

DateTime? _toDate(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  return DateTime.tryParse(v.toString());
}
