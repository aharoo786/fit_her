import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../values/my_colors.dart';



class BorderTitleWidget extends StatelessWidget {
  const BorderTitleWidget({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    var textTheme=Theme.of(context).textTheme;
    return Column(children: [
      Container(
        height: 3.h,
        width: 143.w,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: MyColors.primaryGradient3),
      ),
      SizedBox(height: 10.h),
      Text(
        text,
        style: textTheme.bodyMedium!.copyWith(
            fontWeight: FontWeight.w600,
            color: MyColors.primaryGradient3),
      ),
    ],);
  }
}
