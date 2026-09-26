import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/controllers/diet_plan_user_controller/diet_plan_user_controller.dart';
import '../../data/models/diet_plan_v2/diet_plan_v2_models.dart';

const Color _kSage = Color(0xFF9AB09A);
const Color _kBodyMuted = Color(0xFF6F8B7A);
const Color _kAccent = Color(0xFF6DC55A);
const Color _kCardBorder = Color(0xFFD8EDD4);

// Chip geometry — shared between the state class (for scroll math) and
// _DayChip (for layout). Top-level so neither needs to peek into the
// other's private statics.
const double _kChipWidth = 50;
const double _kChipMargin = 4;
const Color _kInk = Color(0xFF163220);

/// Phase G.1 — horizontal day strip on the user's Diet tab. One chip
/// per day (1..plan.planDays), tap to switch the section to that day.
/// The chip also encodes "where in the plan that day sits" via colour:
/// past = white-on-mint, today = filled accent green, future = sage-
/// tinted, selected (any state) = 2px accent border + slight scale-up.
///
/// Auto-scrolls the selected chip into view on first build so deep
/// linking to "Day 12 of 14" doesn't dump the user at Day 1.
class V2DayStrip extends StatefulWidget {
  final DietPlanV2 plan;
  final int selectedDayNumber;
  final int? todayDayNumber;
  final ValueChanged<int> onDaySelected;

  /// Optional accessor — defaults to looking the controller up via Get.
  /// Lets the strip compute per-day calendar dates without owning a tz
  /// implementation here. Phase G.1 always uses the live controller.
  final DietPlanUserController? controller;

  const V2DayStrip({
    super.key,
    required this.plan,
    required this.selectedDayNumber,
    required this.todayDayNumber,
    required this.onDaySelected,
    this.controller,
  });

  @override
  State<V2DayStrip> createState() => _V2DayStripState();
}

class _V2DayStripState extends State<V2DayStrip> {
  late final ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelected(animate: false);
    });
  }

  @override
  void didUpdateWidget(covariant V2DayStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDayNumber != widget.selectedDayNumber) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelected(animate: true);
      });
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToSelected({required bool animate}) {
    if (!_scroll.hasClients) return;
    final viewport = _scroll.position.viewportDimension;
    final idx = widget.selectedDayNumber - 1;
    final chipCenter = (_kChipWidth + _kChipMargin * 2) * idx +
        (_kChipWidth + _kChipMargin * 2) / 2;
    final target =
        (chipCenter - viewport / 2).clamp(0.0, _scroll.position.maxScrollExtent);
    if (animate) {
      _scroll.animateTo(
        target,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    } else {
      _scroll.jumpTo(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Short plans (a 3-day trial, a week) fit on one line: spread the
    // days evenly across the width instead of a scrolling strip.
    if (widget.plan.planDays <= 7) {
      return Padding(
        padding: EdgeInsets.fromLTRB(12.w, 4.h, 12.w, 4.h),
        child: Row(
          children: List.generate(widget.plan.planDays, (i) {
            final dayNumber = i + 1;
            return Expanded(
              child: _DayChip(
                dayNumber: dayNumber,
                date: widget.controller?.dateForDay(dayNumber),
                todayDayNumber: widget.todayDayNumber,
                isSelected: dayNumber == widget.selectedDayNumber,
                onTap: () => widget.onDaySelected(dayNumber),
                flexible: true,
              ),
            );
          }),
        ),
      );
    }
    return SizedBox(
      // Chip natural height = 16 margin + 20.h padding + ~15 weekday text +
      // 2.h + 18.sp number + 6.h + 6 dot. Mixed scaled/unscaled metrics edge
      // past 80.h on most phones (RenderFlex overflow of ~4 px).
      height: 72.h,
      child: ListView.builder(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: widget.plan.planDays,
        itemBuilder: (context, i) {
          final dayNumber = i + 1;
          return _DayChip(
            dayNumber: dayNumber,
            date: widget.controller?.dateForDay(dayNumber),
            todayDayNumber: widget.todayDayNumber,
            isSelected: dayNumber == widget.selectedDayNumber,
            onTap: () => widget.onDaySelected(dayNumber),
          );
        },
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  final int dayNumber;
  final DateTime? date;
  final int? todayDayNumber;
  final bool isSelected;
  final VoidCallback onTap;
  final bool flexible;

  const _DayChip({
    required this.dayNumber,
    required this.date,
    required this.todayDayNumber,
    required this.isSelected,
    required this.onTap,
    this.flexible = false,
  });

  static const List<String> _weekdayShort = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
  ];

  bool get _isToday =>
      todayDayNumber != null && dayNumber == todayDayNumber;
  // Past is the implicit "neither today nor future" branch in build();
  // exposing a getter for it would be unused dead code (analyzer warns).
  bool get _isFuture =>
      todayDayNumber != null && dayNumber > (todayDayNumber as int);

  @override
  Widget build(BuildContext context) {
    // Colour scheme per state. Selected modifier always wins on the
    // border + slight scale; the bg + text colours come from the
    // base state (past/today/future).
    final Color bg;
    final Color numberColor;
    final Color labelColor;
    final Color dotColor;
    final List<BoxShadow>? shadow;

    // Selected day: solid dark ink, calmer than the old bright green
    // block. Today keeps a green dot and green weekday so it's easy to
    // spot when another day is selected.
    if (isSelected) {
      bg = _kInk;
      numberColor = Colors.white;
      labelColor = Colors.white.withOpacity(0.7);
      dotColor = _isToday ? _kAccent : Colors.transparent;
      shadow = [
        BoxShadow(
          color: _kInk.withOpacity(0.22),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ];
    } else if (_isToday) {
      bg = Colors.white;
      numberColor = _kInk;
      labelColor = _kAccent;
      dotColor = _kAccent;
      shadow = null;
    } else if (_isFuture) {
      bg = Colors.white;
      numberColor = _kBodyMuted.withOpacity(0.7);
      labelColor = _kSage.withOpacity(0.7);
      dotColor = _kSage.withOpacity(0.4);
      shadow = null;
    } else {
      // past or unknown (no todayDayNumber yet)
      bg = Colors.white;
      numberColor = _kBodyMuted;
      labelColor = _kSage;
      dotColor = _kSage;
      shadow = null;
    }

    final borderColor = isSelected
        ? _kInk
        : (_isToday ? _kAccent : _kCardBorder);
    final borderWidth = (!isSelected && _isToday) ? 1.5 : 1.0;
    const scale = 1.0;

    final weekday = (date == null)
        ? '·'
        : _weekdayShort[(date!.weekday - 1).clamp(0, 6)];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        child: Container(
          width: flexible ? null : _kChipWidth,
          margin: const EdgeInsets.symmetric(
            horizontal: _kChipMargin,
            vertical: 6,
          ),
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: borderWidth),
            boxShadow: shadow,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                weekday.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: labelColor,
                  letterSpacing: 0.7,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                '$dayNumber',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: numberColor,
                  height: 1.0,
                ),
              ),
              SizedBox(height: 6.h),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

