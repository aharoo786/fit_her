import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Shared pill-button pair used by the home screen's status banners
/// (PlanFrozenBanner, PlanExpiryBanner) so they read as one consistent
/// design system instead of drifting apart over time. Mirrors
/// profile_screen_user.dart's _subscriptionSecondaryButton /
/// _subscriptionPrimaryButton (that pair is tuned for the dark
/// subscription card -- translucent white fill; these are the light-card
/// counterparts), adapted with a caller-supplied tint so each banner can
/// still read as "the paused-state button" / "the expiring-state button"
/// via color while keeping the exact same shape/radius/type scale.
class SecondaryPillButton extends StatelessWidget {
  final String label;
  final String icon;
  final Color color;
  final bool loading;
  final VoidCallback? onTap;

  const SecondaryPillButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    this.loading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: loading ? null : onTap,
      child: Container(
        height: 38.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: loading
            ? SizedBox(
                width: 14.sp,
                height: 14.sp,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(icon, style: TextStyle(fontSize: 11.sp, color: color)),
                  SizedBox(width: 6.w),
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Light-card counterpart of profile_screen_user.dart's
/// _subscriptionPrimaryButton -- same solid-fill shape/radius, tint
/// supplied by the caller (green "go do a positive thing" for Manage,
/// amber/red "this needs attention" for Renew).
class PrimaryPillButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const PrimaryPillButton({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 38.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12.sp,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
