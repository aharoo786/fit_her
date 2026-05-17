import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/controllers/diet_plan_admin_controller/diet_plan_admin_controller.dart';
import '../../../data/models/diet_plan_v2/diet_plan_v2_models.dart';
import '../../../widgets/v2/v2_buttons.dart';
import '../../../widgets/v2/v2_edit_meal_sheet.dart';

const Color _kCream = Color(0xFFEAF7E4);
const Color _kHeroDark = Color(0xFF163220);
const Color _kSage = Color(0xFF9AB09A);
const Color _kBodyMuted = Color(0xFF6F8B7A);
const Color _kAccent = Color(0xFF6DC55A);
const Color _kCardBorder = Color(0xFFD8EDD4);
const Color _kDanger = Color(0xFFE07B7B);

/// Phase E.4 — review one diet plan, edit individual meals via the
/// bottom-sheet flow, and activate or cancel. Single screen handles the
/// entire dietitian-side review loop.
class PlanReviewEditScreen extends StatefulWidget {
  final int dietPlanId;
  const PlanReviewEditScreen({super.key, required this.dietPlanId});

  @override
  State<PlanReviewEditScreen> createState() => _PlanReviewEditScreenState();
}

class _PlanReviewEditScreenState extends State<PlanReviewEditScreen> {
  late final DietPlanAdminController _ctrl;

  /// Per-day expanded state, keyed by `day.id`. Day 1 starts expanded;
  /// the rest collapsed. Lives in the screen because the controller
  /// shouldn't care about UI presentation state.
  final Map<int, bool> _expanded = {};

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<DietPlanAdminController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ctrl.loadPlanById(widget.dietPlanId);
    });
  }

  void _ensureExpansionDefaults(DietPlanV2 plan) {
    if (_expanded.isNotEmpty) return;
    for (var i = 0; i < plan.days.length; i++) {
      final d = plan.days[i];
      if (d.id != null) _expanded[d.id!] = i == 0;
    }
  }

  // ─── Header ────────────────────────────────────────────────────────────

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
            child: Obx(() {
              final plan = _ctrl.currentPlan.value;
              final firstName = plan?.userFirstName?.trim();
              final title = (firstName == null || firstName.isEmpty)
                  ? 'Plan Review'
                  : "$firstName's Plan";
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'REVIEW',
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
                    title,
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
              );
            }),
          ),
          Obx(() {
            final plan = _ctrl.currentPlan.value;
            if (plan == null) return const SizedBox.shrink();
            return _StatusPill(status: plan.status);
          }),
        ],
      ),
    );
  }

  // ─── Body ──────────────────────────────────────────────────────────────

  Widget _body() {
    return Obx(() {
      if (_ctrl.isPlanLoading.value && _ctrl.currentPlan.value == null) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_kAccent),
          ),
        );
      }
      if (_ctrl.planError.value != null) {
        return _errorState();
      }
      final plan = _ctrl.currentPlan.value;
      if (plan == null) return const SizedBox.shrink();
      _ensureExpansionDefaults(plan);
      return _loadedBody(plan);
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
              _ctrl.planError.value ?? 'Could not load plan',
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
                onPressed: () => _ctrl.loadPlanById(widget.dietPlanId),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loadedBody(DietPlanV2 plan) {
    final isClosed = plan.status == DietPlanStatusV2.completed ||
        plan.status == DietPlanStatusV2.cancelled;
    final body = SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _summaryCard(plan),
          SizedBox(height: 16.h),
          ...plan.days.map((day) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _dayCard(plan, day, isClosed),
              )),
          if (isClosed) SizedBox(height: 8.h),
          if (isClosed) _closedBadge(plan),
        ],
      ),
    );
    // Closed plans (completed / cancelled) are read-only; dim the
    // content to make it visually obvious nothing here is editable.
    return Opacity(opacity: isClosed ? 0.65 : 1.0, child: body);
  }

  // ─── Section A — summary card ──────────────────────────────────────────

  Widget _summaryCard(DietPlanV2 plan) {
    final summary = (plan.summary ?? '').trim();
    final dayTotals = plan.days
        .map((d) => d.totalCalories)
        .where((c) => c > 0)
        .toList();
    final avgCalories = dayTotals.isEmpty
        ? 0
        : (dayTotals.reduce((a, b) => a + b) / dayTotals.length).round();
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI SUMMARY',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11.sp,
              fontWeight: FontWeight.w800,
              color: _kSage,
              letterSpacing: 0.84,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            summary.isEmpty ? 'AI-generated personalized plan' : summary,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: _kHeroDark,
              height: 1.5,
            ),
          ),
          SizedBox(height: 14.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 6.h,
            children: [
              _StatChip(text: '${plan.planDays} days'),
              _StatChip(text: '${plan.mealsPerDay} meals/day'),
              if (avgCalories > 0)
                _StatChip(text: '$avgCalories kcal/day avg'),
              _StatChip(text: 'Created ${_timeAgo(plan.createdAt)}'),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Section B+C — day card with meals ─────────────────────────────────

  Widget _dayCard(DietPlanV2 plan, DietPlanDayV2 day, bool isClosed) {
    final dayId = day.id ?? -day.dayNumber;
    final expanded = _expanded[dayId] ?? false;
    return _Card(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded[dayId] = !expanded),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Day ${day.dayNumber}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: _kHeroDark,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: _kAccent.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                          color: _kAccent.withOpacity(0.32), width: 1),
                    ),
                    child: Text(
                      '${_kcalString(day.totalCalories)} kcal',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                        color: _kHeroDark,
                      ),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: _kSage,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Column(
              children: [
                Divider(
                  height: 1,
                  thickness: 1,
                  color: _kCardBorder.withOpacity(0.5),
                ),
                ...day.meals.map((m) => _mealRow(m, isClosed)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _mealRow(DietPlanMealV2 meal, bool isClosed) {
    return Obx(() {
      final saving = _ctrl.savingMealId.value == meal.id;
      return InkWell(
        onTap: (saving || isClosed)
            ? null
            : () => _openEditSheet(meal),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            border: Border(
              bottom:
                  BorderSide(color: _kCardBorder.withOpacity(0.5), width: 1),
            ),
          ),
          child: saving ? _savingRow() : _mealRowContent(meal, isClosed),
        ),
      );
    });
  }

  Widget _savingRow() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Center(
        child: SizedBox(
          width: 18.w,
          height: 18.w,
          child: const CircularProgressIndicator(
            strokeWidth: 2.4,
            valueColor: AlwaysStoppedAnimation<Color>(_kAccent),
          ),
        ),
      ),
    );
  }

  Widget _mealRowContent(DietPlanMealV2 meal, bool isClosed) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Time pill.
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: _kSage,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                meal.time,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    meal.mealType.label.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w700,
                      color: _kSage,
                      letterSpacing: 0.6,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    meal.foodName,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: _kHeroDark,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${meal.calories} kcal',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: _kBodyMuted,
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              Icons.edit_outlined,
              size: 16.w,
              color: isClosed ? _kSage : _kAccent,
            ),
          ],
        ),
        if ((meal.notes ?? '').trim().isNotEmpty) ...[
          SizedBox(height: 6.h),
          Padding(
            padding: EdgeInsets.only(left: 56.w),
            child: Text(
              '↳ ${meal.notes!.trim()}',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11.sp,
                fontStyle: FontStyle.italic,
                color: _kSage,
                height: 1.4,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _openEditSheet(DietPlanMealV2 meal) async {
    final mealId = meal.id;
    if (mealId == null) return;
    await V2EditMealSheet.show(
      meal: meal,
      onSave: ({foodName, calories, time, notes, mealType}) {
        return _ctrl.updateMealOnCurrentPlan(
          mealId: mealId,
          foodName: foodName,
          calories: calories,
          time: time,
          notes: notes,
          mealType: mealType,
        );
      },
    );
  }

  // ─── Closed banner ─────────────────────────────────────────────────────

  Widget _closedBadge(DietPlanV2 plan) {
    final reason = plan.status == DietPlanStatusV2.cancelled
        ? 'cancelled'
        : 'completed';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kCardBorder, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline, color: _kSage, size: 18.w),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'This plan is $reason and cannot be edited.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: _kBodyMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Section E — sticky bottom bar ─────────────────────────────────────

  Widget? _bottomBar() {
    return Obx(() {
      final plan = _ctrl.currentPlan.value;
      if (plan == null) return const SizedBox.shrink();
      if (plan.status == DietPlanStatusV2.completed ||
          plan.status == DietPlanStatusV2.cancelled) {
        return const SizedBox.shrink();
      }
      return Container(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: _kCardBorder, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: plan.status == DietPlanStatusV2.draft
              ? _draftActions()
              : _activeActions(),
        ),
      );
    });
  }

  Widget _draftActions() {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Obx(() => V2SecondaryButton(
                label: 'Cancel Plan',
                onPressed: _ctrl.isCancelling.value || _ctrl.isActivating.value
                    ? null
                    : _confirmCancel,
              )),
        ),
        SizedBox(width: 12.w),
        Expanded(
          flex: 6,
          child: Obx(() => V2PrimaryButton(
                label: 'Activate Plan',
                busy: _ctrl.isActivating.value,
                onPressed:
                    _ctrl.isCancelling.value || _ctrl.isActivating.value
                        ? null
                        : _doActivate,
              )),
        ),
      ],
    );
  }

  Widget _activeActions() {
    return Obx(() => V2SecondaryButton(
          label: 'Cancel Plan',
          onPressed: _ctrl.isCancelling.value ? null : _confirmCancel,
        ));
  }

  Future<void> _doActivate() async {
    final ok = await _ctrl.activateCurrentPlan();
    if (!mounted) return;
    if (!ok) return;
    Get.snackbar(
      'Plan activated',
      'Your client will see it now.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: _kAccent.withOpacity(0.9),
      colorText: Colors.white,
      duration: const Duration(milliseconds: 2200),
    );
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    Get.back<dynamic>();
  }

  // ─── Cancel-reason dialog ──────────────────────────────────────────────

  Future<void> _confirmCancel() async {
    final reasonCtrl = TextEditingController();
    await Get.dialog<dynamic>(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Cancel this plan?',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 17.sp,
            fontWeight: FontWeight.w800,
            color: _kHeroDark,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "The user won't be able to use this plan. You can leave a "
              'reason for the audit trail (optional).',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12.sp,
                color: _kBodyMuted,
                height: 1.5,
              ),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: reasonCtrl,
              maxLength: 500,
              maxLines: 3,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13.sp,
                color: _kHeroDark,
              ),
              decoration: InputDecoration(
                hintText: 'Reason (optional)',
                hintStyle: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.sp,
                  color: _kBodyMuted,
                ),
                filled: true,
                fillColor: _kCream,
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w, vertical: 10.h),
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _kCardBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _kCardBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: _kDanger, width: 1.4),
                ),
              ),
            ),
          ],
        ),
        actions: [
          V2GhostButton(
            label: 'Keep Plan',
            onPressed: () => Get.back<dynamic>(),
            fullWidth: false,
          ),
          SizedBox(
            width: 160.w,
            child: ElevatedButton(
              onPressed: () => Get.back<dynamic>(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kDanger,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              child: Text(
                'Confirm Cancel',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    ).then((confirmed) async {
      if (confirmed != true) return;
      final reason = reasonCtrl.text.trim();
      final ok = await _ctrl.cancelCurrentPlan(
        reason: reason.isEmpty ? null : reason,
      );
      if (!mounted) return;
      if (!ok) return;
      Get.snackbar(
        'Plan cancelled',
        'The plan has been cancelled.',
        snackPosition: SnackPosition.BOTTOM,
      );
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      Get.back<dynamic>();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kCream,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            Expanded(child: _body()),
          ],
        ),
      ),
      bottomNavigationBar: _bottomBar(),
    );
  }
}

// ─── Local widgets ────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  const _Card({required this.child, this.padding});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.all(16.w),
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
      child: child,
    );
  }
}

class _StatChip extends StatelessWidget {
  final String text;
  const _StatChip({required this.text});
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

class _StatusPill extends StatelessWidget {
  final DietPlanStatusV2 status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, String label) = switch (status) {
      DietPlanStatusV2.draft => (_kSage, Colors.white, 'DRAFT'),
      DietPlanStatusV2.active => (_kAccent, Colors.white, 'ACTIVE'),
      DietPlanStatusV2.completed => (
          _kBodyMuted,
          Colors.white,
          'COMPLETED'
        ),
      DietPlanStatusV2.cancelled => (
          _kBodyMuted,
          Colors.white,
          'CANCELLED'
        ),
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 10.sp,
          fontWeight: FontWeight.w800,
          color: fg,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────

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

String _kcalString(int n) {
  // Lightweight thousands-separator: 1490 → "1,490". Avoids importing
  // intl just for this single use.
  final s = n.toString();
  if (s.length <= 3) return s;
  final chars = s.split('').reversed.toList();
  final out = <String>[];
  for (var i = 0; i < chars.length; i++) {
    if (i > 0 && i % 3 == 0) out.add(',');
    out.add(chars[i]);
  }
  return out.reversed.join();
}
