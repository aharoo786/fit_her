import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/models/diet_plan_v2/diet_plan_v2_models.dart';

const Color _kCardBorder = Color(0xFFD8EDD4);
const Color _kHeroDark = Color(0xFF163220);
const Color _kSage = Color(0xFF9AB09A);
const Color _kBodyMuted = Color(0xFF6F8B7A);
const Color _kCream = Color(0xFFEAF7E4);
const Color _kAccent = Color(0xFF6DC55A);
const Color _kDanger = Color(0xFFE07B7B);

/// Status-aware plan summary card. One widget for every dietitian-side
/// list surface (drafts dashboard, user history, anything else later) —
/// the previous V2DraftPlanCard hardcoded the DRAFT badge and is now
/// retired.
///
/// `showUserInfo` toggles the avatar+name row: enabled on the drafts
/// dashboard (mixed users, dietitian needs to see whose plan); disabled
/// on the per-user history (everything is the same person already).
class V2PlanSummaryCard extends StatelessWidget {
  final DietPlanV2 plan;
  final VoidCallback? onTap;
  final bool showUserInfo;
  final String? userDisplayName;
  final String? userProfileImage;

  const V2PlanSummaryCard({
    super.key,
    required this.plan,
    this.onTap,
    this.showUserInfo = false,
    this.userDisplayName,
    this.userProfileImage,
  });

  bool get _isClosed =>
      plan.status == DietPlanStatusV2.completed ||
      plan.status == DietPlanStatusV2.cancelled;

  @override
  Widget build(BuildContext context) {
    final card = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _kCardBorder, width: 1),
            boxShadow: [
              BoxShadow(
                color: _kHeroDark.withOpacity(0.05),
                offset: const Offset(0, 2),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topRow(),
              if (showUserInfo) ...[
                SizedBox(height: 10.h),
                _userRow(),
              ],
              SizedBox(height: 10.h),
              _summary(),
              SizedBox(height: 12.h),
              _statsRow(),
            ],
          ),
        ),
      ),
    );

    // Closed plans (completed/cancelled) get a soft dim — same visual
    // language as the review screen's read-only mode so the dietitian
    // recognises closed-state at a glance across surfaces.
    return Opacity(opacity: _isClosed ? 0.8 : 1.0, child: card);
  }

  // ─── Sub-widgets ───────────────────────────────────────────────────────

  Widget _topRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _StatusPill(status: plan.status),
        const Spacer(),
        Text(
          _timeAgo(plan.createdAt),
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: _kSage,
          ),
        ),
      ],
    );
  }

  Widget _userRow() {
    final name =
        (userDisplayName == null || userDisplayName!.trim().isEmpty)
            ? 'User #${plan.userId ?? '?'}'
            : userDisplayName!;
    return Row(
      children: [
        _Avatar(name: name, imageUrl: userProfileImage),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: _kHeroDark,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _summary() {
    final raw = (plan.summary ?? '').trim();
    final text = raw.isEmpty ? 'AI-generated personalized plan' : raw;
    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 13.sp,
        height: 1.45,
        color: _kBodyMuted,
      ),
    );
  }

  Widget _statsRow() {
    final dayTotals = plan.days
        .map((d) => d.totalCalories)
        .where((c) => c > 0)
        .toList();
    final avg = dayTotals.isEmpty
        ? null
        : (dayTotals.reduce((a, b) => a + b) / dayTotals.length).round();
    return Wrap(
      spacing: 8.w,
      runSpacing: 6.h,
      children: [
        _Chip(text: '📅 ${plan.planDays} days'),
        _Chip(text: '🍽️ ${plan.mealsPerDay} meals/day'),
        if (avg != null) _Chip(text: '🔥 $avg kcal/day'),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  final DietPlanStatusV2 status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final (Color bg, String label, bool showLiveDot) = switch (status) {
      DietPlanStatusV2.draft => (_kSage, 'DRAFT', false),
      DietPlanStatusV2.active => (_kAccent, 'ACTIVE', true),
      DietPlanStatusV2.completed => (_kBodyMuted, 'COMPLETED', false),
      DietPlanStatusV2.cancelled => (_kDanger, 'CANCELLED', false),
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLiveDot) ...[
            Container(
              width: 6.w,
              height: 6.w,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 5.w),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final String? imageUrl;
  const _Avatar({required this.name, this.imageUrl});

  String get _initial {
    final t = name.trim();
    if (t.isEmpty) return '?';
    return t.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final size = 32.w;
    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _kCream,
        shape: BoxShape.circle,
        border: Border.all(color: _kAccent.withOpacity(0.32), width: 1),
      ),
      child: Text(
        _initial,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13.sp,
          fontWeight: FontWeight.w800,
          color: _kHeroDark,
        ),
      ),
    );
    if (imageUrl == null || imageUrl!.isEmpty) return fallback;
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (_, __) => fallback,
        errorWidget: (_, __, ___) => fallback,
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  const _Chip({required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: _kCream,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _kCardBorder, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: _kHeroDark,
        ),
      ),
    );
  }
}

String _timeAgo(DateTime? when) {
  if (when == null) return 'just now';
  final diff = DateTime.now().difference(when);
  if (diff.isNegative || diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays == 1) return 'yesterday';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
  if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
  return '${(diff.inDays / 365).floor()}y ago';
}
