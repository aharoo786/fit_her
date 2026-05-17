import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/controllers/diet_plan_admin_controller/diet_plan_admin_controller.dart';
import '../../../data/models/diet_plan_v2/diet_plan_v2_models.dart';
import '../../../widgets/v2/v2_buttons.dart';
import '../../../widgets/v2/v2_plan_summary_card.dart';
import 'plan_review_edit_screen.dart';

const Color _kCream = Color(0xFFEAF7E4);
const Color _kHeroDark = Color(0xFF163220);
const Color _kSage = Color(0xFF9AB09A);
const Color _kBodyMuted = Color(0xFF6F8B7A);
const Color _kAccent = Color(0xFF6DC55A);
const Color _kCardBorder = Color(0xFFD8EDD4);
const Color _kDanger = Color(0xFFE07B7B);

/// Phase E.5 — per-user plan history. Filterable by status; tap any
/// card to open the Phase E.4 review/edit screen (which already
/// renders correctly for every status, including the read-only mode
/// for completed/cancelled plans).
class UserPlanHistoryScreen extends StatefulWidget {
  final int userId;
  final String userDisplayName;

  const UserPlanHistoryScreen({
    super.key,
    required this.userId,
    required this.userDisplayName,
  });

  @override
  State<UserPlanHistoryScreen> createState() =>
      _UserPlanHistoryScreenState();
}

class _UserPlanHistoryScreenState extends State<UserPlanHistoryScreen> {
  late final DietPlanAdminController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<DietPlanAdminController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ctrl.loadHistoryForUser(widget.userId);
    });
  }

  String get _firstName {
    final first = widget.userDisplayName.trim().split(' ').first;
    return first.isEmpty ? 'this client' : first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kCream,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            _filterRow(),
            Expanded(child: _body()),
          ],
        ),
      ),
    );
  }

  // ─── Top bar ────────────────────────────────────────────────────────────

  Widget _topBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(8.w, 4.h, 16.w, 8.h),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back<dynamic>(),
            icon: const Icon(Icons.arrow_back, color: _kHeroDark, size: 22),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'HISTORY',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: _kSage,
                    letterSpacing: 0.7,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '$_firstName\'s Plans',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: _kHeroDark,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Section A — filter chips ──────────────────────────────────────────

  Widget _filterRow() {
    return Obx(() {
      final selected = _ctrl.historyStatusFilter.value;
      return SizedBox(
        height: 44.h,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          children: [
            _FilterChip(
              label: 'All',
              selected: selected == null,
              onTap: () => _ctrl.loadHistoryForUser(widget.userId),
            ),
            SizedBox(width: 8.w),
            for (final s in DietPlanStatusV2.values) ...[
              _FilterChip(
                label: _statusLabel(s),
                selected: selected == s,
                onTap: () =>
                    _ctrl.loadHistoryForUser(widget.userId, status: s),
              ),
              SizedBox(width: 8.w),
            ],
          ],
        ),
      );
    });
  }

  static String _statusLabel(DietPlanStatusV2 s) {
    switch (s) {
      case DietPlanStatusV2.draft:
        return 'Drafts';
      case DietPlanStatusV2.active:
        return 'Active';
      case DietPlanStatusV2.completed:
        return 'Completed';
      case DietPlanStatusV2.cancelled:
        return 'Cancelled';
    }
  }

  // ─── Section B — list / states ─────────────────────────────────────────

  Widget _body() {
    return Obx(() {
      if (_ctrl.isHistoryLoading.value && _ctrl.userHistory.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_kAccent),
          ),
        );
      }
      if (_ctrl.historyError.value != null) {
        return _errorState();
      }
      if (_ctrl.userHistory.isEmpty) {
        return _emptyState();
      }
      return RefreshIndicator(
        color: _kAccent,
        onRefresh: () => _ctrl.loadHistoryForUser(
          widget.userId,
          status: _ctrl.historyStatusFilter.value,
        ),
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: _ctrl.userHistory.length,
          separatorBuilder: (_, __) => SizedBox(height: 12.h),
          itemBuilder: (context, i) {
            final plan = _ctrl.userHistory[i];
            return V2PlanSummaryCard(
              plan: plan,
              showUserInfo: false,
              onTap: () => Get.to<dynamic>(
                () => PlanReviewEditScreen(dietPlanId: plan.id),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _errorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56.w,
              height: 56.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _kDanger.withOpacity(0.14),
                shape: BoxShape.circle,
              ),
              child:
                  Icon(Icons.error_outline, color: _kDanger, size: 28.w),
            ),
            SizedBox(height: 14.h),
            Text(
              _ctrl.historyError.value ?? 'Could not load plans',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: _kHeroDark,
              ),
            ),
            SizedBox(height: 18.h),
            SizedBox(
              width: 180.w,
              child: V2SecondaryButton(
                label: 'Retry',
                onPressed: () => _ctrl.loadHistoryForUser(
                  widget.userId,
                  status: _ctrl.historyStatusFilter.value,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    final filter = _ctrl.historyStatusFilter.value;
    final emoji = filter == null ? '📭' : '🔍';
    final body = filter == null
        ? 'No plans yet for $_firstName. Generate her first plan from '
            'her client profile.'
        : 'No ${_statusLabel(filter).toLowerCase()} plans for $_firstName.';
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96.w,
              height: 96.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: _kCardBorder, width: 1),
              ),
              child: Text(emoji, style: TextStyle(fontSize: 40.sp)),
            ),
            SizedBox(height: 18.h),
            Text(
              filter == null ? 'NO PLANS YET' : 'NO MATCHES',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11.sp,
                fontWeight: FontWeight.w800,
                color: _kSage,
                letterSpacing: 0.84,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13.sp,
                height: 1.5,
                color: _kBodyMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: selected ? _kAccent : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? _kAccent : _kCardBorder,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : _kSage,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
