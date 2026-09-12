import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../UI/plans_module/all_plans.dart';
import '../../data/Repos/user_plan_repo/user_plan_repository.dart';
import '../../data/controllers/auth_controller/auth_controller.dart';
import '../../data/models/user_plan/user_plan_item.dart';
import '../../utils/plan_expiry.dart';
import '../../values/constants.dart';
import 'pill_button.dart';

const Color _kAmber = Color(0xFFC98A2C);
const Color _kDanger = Color(0xFFC24A4A);
const Color _kCardBorder = Color(0xFFD8EDD4);
const Color _kHeroDark = Color(0xFF163220);

/// Small, self-hiding heads-up on the paid home screen for a plan that's
/// about to lapse or already has. The full countdown card already exists
/// on the Profile screen (v2_assigned_plan_card.dart) -- this is
/// deliberately lighter (no freeze controls, just "renew before/after you
/// lose access"), surfaced where a user actually sees it on opening the
/// app rather than only if they go looking on Profile. Sibling of
/// V2Day7TriggerBanner in paid_home_screen_v2.dart -- same
/// self-hide-when-not-applicable pattern.
///
/// Visual language matches PlanFrozenBanner (white card, Poppins, solid
/// pill button, no drop-shadow/colored-strip) -- both were checked
/// against `new screens/Profile_Final_3Screens.html` and the production
/// _subscriptionPrimaryButton in profile_screen_user.dart as the source
/// of truth, and now share the actual button widgets via pill_button.dart
/// so the two banners can't drift apart in future edits. The severity
/// color (amber while there's still time, red once it's actually
/// expired) is carried by the icon and the button fill instead of a
/// colored side-strip.
class PlanExpiryBanner extends StatefulWidget {
  const PlanExpiryBanner({super.key});

  @override
  State<PlanExpiryBanner> createState() => _PlanExpiryBannerState();
}

class _PlanExpiryBannerState extends State<PlanExpiryBanner> {
  UserPlanItem? _plan;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final auth = Get.find<AuthController>();
      final token =
          auth.sharedPreferences.getString(Constants.accessToken) ?? '';
      final repo = Get.find<UserPlanRepository>();
      final res = await repo.getMyPlans(accessToken: token);

      UserPlanItem? plan;
      if (res.body != null && res.body['status'] == '1') {
        final raw = res.body['data'];
        if (raw is List && raw.isNotEmpty && raw.first is Map) {
          plan = UserPlanItem.fromJson(Map<String, dynamic>.from(raw.first));
        }
      }
      if (mounted) {
        setState(() {
          _plan = plan;
          _loaded = true;
        });
      }
    } catch (_) {
      // Best-effort and silent -- a plan-status hiccup shouldn't block the
      // rest of the home screen from rendering.
      if (mounted) setState(() => _loaded = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _plan == null) return const SizedBox.shrink();

    final daysRemaining = daysRemainingUntil(_plan!.expireDate);
    if (daysRemaining == null || daysRemaining > 7) {
      return const SizedBox.shrink();
    }

    final isExpired = daysRemaining < 0;
    final accent = isExpired ? _kDanger : _kAmber;
    final message = isExpired
        ? 'Your plan has expired -- renew to get back to your sessions'
        : daysRemaining == 0
            ? 'Your plan expires today -- renew to keep your spot'
            : daysRemaining == 1
                ? 'Your plan expires tomorrow -- renew to keep your spot'
                : 'Your plan expires in $daysRemaining days -- renew to keep your spot';

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kCardBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('\u23f0', style: TextStyle(fontSize: 14.sp, color: accent)),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: _kHeroDark,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            PrimaryPillButton(
              label: isExpired ? 'Renew Now' : 'Renew',
              color: accent,
              onTap: () => Get.to(() => OurPlansScreen()),
            ),
          ],
        ),
      ),
    );
  }
}
