import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../data/services/cycle_engine.dart';
import '../data/services/insight_service.dart';
import '../theme/app_colors.dart';

class InsightCard extends StatefulWidget {
  final CycleInfo? cycleInfo;
  final Insight insight;
  final double? accuracyPercent;
  final VoidCallback? onViewSessions;
  final VoidCallback? onAddCycleData;

  const InsightCard({
    Key? key,
    required this.cycleInfo,
    required this.insight,
    this.accuracyPercent,
    this.onViewSessions,
    this.onAddCycleData,
  }) : super(key: key);

  @override
  State<InsightCard> createState() => _InsightCardState();
}

class _InsightCardState extends State<InsightCard> {
  bool _expanded = false;

  bool get _hasCycleData => widget.cycleInfo != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          left: BorderSide(color: AppColors.primary, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 2),
            blurRadius: 8,
            color: Colors.black.withOpacity(0.08),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Phase label + Confidence
            _buildPhaseRow(),
            SizedBox(height: 10.h),

            // 2. Nudge title
            Text(
              widget.insight.title,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 6.h),

            // 3. Nudge body (expandable)
            _buildNudgeBody(),
            SizedBox(height: 12.h),

            // 4. Pills row OR "Add cycle data" link
            if (_hasCycleData)
              _buildPillsRow()
            else
              _buildAddCycleDataLink(),
            SizedBox(height: 10.h),

            // 5. View recommended sessions
            if (_hasCycleData && widget.onViewSessions != null)
              GestureDetector(
                onTap: widget.onViewSessions,
                child: Text(
                  'View recommended sessions \u2192',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseRow() {
    final phaseLabel = _hasCycleData
        ? 'Day ${widget.cycleInfo!.cycleDay} of your cycle \u2022 ${_formatPhase(widget.cycleInfo!.phase)}'
        : 'Welcome back';

    return Row(
      children: [
        Expanded(
          child: Text(
            phaseLabel,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textHint,
            ),
          ),
        ),
        if (widget.accuracyPercent != null)
          Text(
            'Confidence: ${widget.accuracyPercent!.round()}%',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textHint,
            ),
          ),
      ],
    );
  }

  Widget _buildNudgeBody() {
    final bodyText = widget.insight.body;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedCrossFade(
          firstChild: Text(
            bodyText,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textTertiary,
              height: 1.5,
            ),
          ),
          secondChild: Text(
            bodyText,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textTertiary,
              height: 1.5,
            ),
          ),
          crossFadeState:
              _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        if (bodyText.length > 120)
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Text(
                _expanded ? 'Show less' : 'Read more',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPillsRow() {
    return Row(
      children: [
        if (widget.insight.energy != null)
          _buildPill(
            'Energy: ${widget.insight.energy!.label}',
            widget.insight.energy!.energy,
          ),
        SizedBox(width: 8.w),
        if (widget.insight.mood != null)
          _buildPill(
            'Mood: ${widget.insight.mood!.label}',
            widget.insight.mood!.mood,
          ),
        SizedBox(width: 8.w),
        if (widget.insight.craving != null)
          _buildCravingPill(widget.insight.craving!.craving),
      ],
    );
  }

  Widget _buildPill(String label, int level) {
    Color bg;
    Color textColor;

    if (level >= 4) {
      bg = const Color(0xFFE4F9D7);
      textColor = AppColors.textSecondary;
    } else if (level == 3) {
      bg = const Color(0xFFFEF3C7);
      textColor = const Color(0xFF92400E);
    } else {
      bg = const Color(0xFFF3F4F6);
      textColor = AppColors.textHint;
    }

    return Flexible(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildCravingPill(String craving) {
    final label = craving == 'none' ? 'No cravings' : 'Cravings: $craving';

    return Flexible(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textHint,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildAddCycleDataLink() {
    return GestureDetector(
      onTap: widget.onAddCycleData,
      child: Text(
        'Add cycle data for personalized insights \u2192',
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
      ),
    );
  }

  String _formatPhase(String phase) {
    return '${phase[0].toUpperCase()}${phase.substring(1)} Phase';
  }
}
