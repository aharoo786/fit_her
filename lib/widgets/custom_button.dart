
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../values/my_colors.dart';

class CustomButton extends StatelessWidget {
  final double? height;
  final double? width;
  final double? roundCorner;
  final String text;
  final double? fontSize;
  final Color? color;
  final Color? textColor;
  final Color? borderColor;
  void Function() onPressed;

  CustomButton({
     this.height,
     this.width,
    required this.text,
    this.fontSize,
    this.borderColor,
    this.textColor,
    this.roundCorner,
    this.color,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var textTheme = theme.textTheme;
    var mediaQuery = MediaQuery.of(context).size;
    return Container(
      height: height ??56.h,
      width: width??374.w,
      decoration: BoxDecoration(
          border: Border.all(color: borderColor ?? MyColors.buttonColor),
          borderRadius: BorderRadius.circular(roundCorner ?? 12),
          color: color ?? MyColors.buttonColor),
      child: MaterialButton(
        shape: const RoundedRectangleBorder(
         // borderRadius: BorderRadius.circular(roundCorner ?? 30),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style:   textTheme.headline2!.copyWith(fontSize: fontSize?? 16.sp,color:
          textColor?? MyColors.textColor2,
            fontWeight: FontWeight.w500
          ),
        ),
      ),
    );
  }
}
