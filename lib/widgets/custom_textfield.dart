import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../values/dimens.dart';
import '../values/my_colors.dart';

class CustomTextField extends StatelessWidget {
  final double? height;
  final double? width;
  final double? roundCorner;
  final Color? bordercolor;
  final Color? background;
  final String text;
  final int length;
  final int? verticalPadding;
  final TextInputType keyboardType;
  final TextInputFormatter inputFormatters;
  bool? Readonly = false;
  final Widget? icon;
  final suffixIcon;
  final InputBorder? border;
  final String? errorText;
  final FocusNode? focusNode;
  final String? suffixtext;
  final Color? hintColor;
  final Color? textColor;
  final Color? cursorColor;
  final int? maxlines;
  final Color? color;
  final bool? isObscure;
  final Function(String)? onFieldSubmitted;

  TextEditingController? controller;
  FormFieldValidator<String>? validator;
  ValueChanged<String>? onChanged;

  CustomTextField({
    Key? key,
    this.height,
    this.width,
    this.roundCorner,
    this.suffixIcon,
    this.bordercolor,
    this.background,
    this.controller,
    this.border,
    this.maxlines,
    required this.text,
    this.validator,
    this.onChanged,
    this.errorText,
    this.Readonly,
    this.focusNode,
    this.hintColor,
    this.icon,
    this.color,
    this.suffixtext,
    required this.length,
    required this.keyboardType,
    required this.inputFormatters,
    this.isObscure,
    this.textColor,
    this.cursorColor,
    this.onFieldSubmitted,
    this.verticalPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var textTheme = theme.textTheme;
    var mediaQuery = MediaQuery.of(context).size;

    return Container(
      height: height ?? 56.h,
      width: width,
      decoration: BoxDecoration(
          boxShadow: [
            // BoxShadow(
            //   color: MyColors.textFieldColor.withOpacity(0.1),
            //   spreadRadius: 0,
            //   blurRadius: 0,
            //   offset: Offset(0, 0), // changes position of shadow
            // ),
          ],
          color: background ?? MyColors.textFieldColor,
          borderRadius: BorderRadius.circular(
            roundCorner ?? 8,
          ),
          border: Border.all(color: Colors.black)),
      child: TextFormField(
        // obscuringCharacter: '.',
        maxLength: length,
        cursorHeight: 30.h,
        maxLines: maxlines ?? 1,
        focusNode: focusNode,
        validator: (value) {
          if (value == "" || value!.isEmpty) {
            return 'Please enter some text';
          }
          return null;
        },
        style: TextStyle(
            color: textColor ?? MyColors.textColor,
            fontSize: 16.sp,
            fontWeight: FontWeight.w400),
        controller: controller,
        keyboardType: keyboardType,
        textAlign: TextAlign.start,
        onChanged: onChanged,

        autovalidateMode: AutovalidateMode.onUserInteraction,
        cursorColor: cursorColor ?? MyColors.black,
        inputFormatters: <TextInputFormatter>[inputFormatters],
        textInputAction: TextInputAction.next,
        readOnly: Readonly == true ? true : false,
        obscureText: isObscure ?? false,
        onFieldSubmitted: onFieldSubmitted,
        decoration: InputDecoration(
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          border: InputBorder.none,
          errorText: errorText,
          counterText: "",
          enabledBorder: border ?? InputBorder.none,
          // focusedBorder: UnderlineInputBorder(
          //   borderSide: BorderSide(color: color ?? MyColors.purple, width: 2),
          // ),
          errorBorder: OutlineInputBorder(
            borderRadius: roundCorner == null
                ? BorderRadius.circular(8)
                : BorderRadius.circular(roundCorner!),
            borderSide: const BorderSide(color: MyColors.red500, width: 0.5),
          ),
          hintText: text.tr,
          suffixIcon: suffixIcon,
          hintStyle: TextStyle(
              color: hintColor ?? MyColors.hintText,
              fontWeight: FontWeight.normal,
              fontSize: 14.sp),
          // contentPadding: EdgeInsets.only(left: 15, top: 9),
          prefixIcon: icon != null
              ? Padding(
                  padding: EdgeInsets.all(Dimens.size13.w),
                  child: icon,
                )
              : null,
          errorStyle: TextStyle(fontSize: 0),
          suffixText: suffixtext,
          focusColor: MyColors.green50,
        ),
      ),
    );
  }
}
