
import 'package:fitness_zone_2/values/values.dart';
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
  final FontWeight? fontWeight ;
  void Function() onPressed;

  CustomButton({
     this.height,
     this.width,
    required this.text,
    this.fontSize,
    this.borderColor,
    this.textColor,
    this.roundCorner,
    this.fontWeight,
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
      height: height ??60,
      width: width??390.w,
      decoration: BoxDecoration(
          border: color==null?null:Border.all(color: borderColor ?? MyColors.buttonColor),
          boxShadow: color!=null?null:[
            BoxShadow(
              spreadRadius: 0,
              blurRadius: 4,
              offset: const Offset(0,2),
              color: MyColors.black.withOpacity(0.2)
            )
          ],
          borderRadius: BorderRadius.circular(roundCorner ?? 8),
          color: color ?? MyColors.buttonColor,
        gradient: color==null?const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: MyColors.mainGradient
        ):null

      ),
      child: MaterialButton(
        shape: const RoundedRectangleBorder(
         // borderRadius: BorderRadius.circular(roundCorner ?? 30),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style:   textTheme.headlineMedium!.copyWith(fontSize: fontSize?? 20.sp,color:
          textColor?? MyColors.textColor2,
            fontWeight:fontWeight?? FontWeight.w600
          ),
        ),
      ),
    );
  }
}
