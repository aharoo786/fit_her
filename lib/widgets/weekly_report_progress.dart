import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';

class WeeklyReportProgress extends StatelessWidget {
  final int checkinsThisWeek;

  const WeeklyReportProgress({
    Key? key,
    required this.checkinsThisWeek,
  }) : super(key: key);

  bool get _isReady => checkinsThisWeek >= 4;

  @override
  Widget build(BuildContext context) {
    final progress = (checkinsThisWeek / 4).clamp(0.0, 1.0);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Report',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textHint,
                ),
              ),
              Text(
                _isReady
                    ? 'Your weekly report is ready Sunday!'
                    : '$checkinsThisWeek/4 check-ins',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: _isReady ? AppColors.primary : AppColors.textHint,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: SizedBox(
              height: 6,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: progress),
                duration: const Duration(milliseconds: 600),
                curve: Curves.ease,
                builder: (context, value, child) {
                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.divider,
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: value,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
