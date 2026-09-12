/// Shared "days remaining" math for plan-expiry UI. Pulled out once a
/// second place (the home-screen expiry banner) needed the exact same
/// calculation as the Profile screen's plan card
/// (widgets/v2/v2_assigned_plan_card.dart) — negative means already
/// expired, by however many days.
int? daysRemainingUntil(DateTime? expire) {
  if (expire == null) return null;
  final now = DateTime.now();
  return expire.difference(DateTime(now.year, now.month, now.day)).inDays;
}
