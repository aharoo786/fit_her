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
const Color _kDanger = Color(0xFFE07B7B);
const Color _kCardBorder = Color(0xFFD8EDD4);

/// Phase E.2 — dietitian's drafts dashboard. Single-purpose: list every
/// `status:'draft'` plan she authored, with pull-to-refresh + retry on
/// error. Tapping a card or "Generate New Plan" both surface
/// placeholder snackbars — the real review/generate screens land in
/// Phase E.3 / E.4.
class DraftsDashboardScreen extends StatelessWidget {
  const DraftsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<DietPlanAdminController>();
    return Scaffold(
      backgroundColor: _kCream,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(ctrl),
            Expanded(child: _body(ctrl)),
          ],
        ),
      ),
    );
  }

  Widget _topBar(DietPlanAdminController ctrl) {
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
                  'DIETITIAN',
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
                  'Drafts to Review',
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
          // Count badge — only meaningful once data lands.
          Obx(() {
            if (ctrl.isLoading.value) return const SizedBox.shrink();
            final n = ctrl.drafts.length;
            if (n == 0) return const SizedBox.shrink();
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: _kSage.withOpacity(0.18),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: _kSage.withOpacity(0.32), width: 1),
              ),
              child: Text(
                '$n pending',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: _kHeroDark,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _body(DietPlanAdminController ctrl) {
    return Obx(() {
      if (ctrl.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_kAccent),
          ),
        );
      }
      if (ctrl.errorMessage.value != null) {
        return _errorState(ctrl);
      }
      if (ctrl.drafts.isEmpty) {
        return _emptyState();
      }
      return RefreshIndicator(
        color: _kAccent,
        onRefresh: () => ctrl.loadDrafts(refresh: true),
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: ctrl.drafts.length,
          separatorBuilder: (_, __) => SizedBox(height: 12.h),
          itemBuilder: (context, i) {
            final plan = ctrl.drafts[i];
            final name = plan.userDisplayName.isNotEmpty
                ? plan.userDisplayName
                : 'User #${plan.userId ?? '?'}';
            return V2PlanSummaryCard(
              plan: plan,
              showUserInfo: true,
              userDisplayName: name,
              userProfileImage: plan.userProfileImage,
              onTap: () => _onCardTap(plan),
            );
          },
        ),
      );
    });
  }

  Widget _errorState(DietPlanAdminController ctrl) {
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
              child: Icon(Icons.error_outline,
                  color: _kDanger, size: 28.w),
            ),
            SizedBox(height: 14.h),
            Text(
              ctrl.errorMessage.value ?? 'Something went wrong',
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
                onPressed: () {
                  ctrl.clearError();
                  ctrl.loadDrafts(refresh: true);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
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
              child: Text('🍽️', style: TextStyle(fontSize: 40.sp)),
            ),
            SizedBox(height: 18.h),
            Text(
              'ALL CAUGHT UP',
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
              "No drafts pending review. Generate a new plan for a "
              "client when you're ready.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13.sp,
                height: 1.5,
                color: _kBodyMuted,
              ),
            ),
            SizedBox(height: 22.h),
            SizedBox(
              width: 220.w,
              child: V2PrimaryButton(
                label: 'Generate New Plan',
                onPressed: _onGenerateTap,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onCardTap(DietPlanV2 plan) {
    Get.to<dynamic>(() => PlanReviewEditScreen(dietPlanId: plan.id));
  }

  void _onGenerateTap() {
    Get.snackbar(
      'Pick a client first',
      "Open a client from your client list, then tap 'Generate Plan' "
          'to start.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
    );
  }
}
