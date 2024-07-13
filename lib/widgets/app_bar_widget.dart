import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../values/constants.dart';
import '../values/dimens.dart';
import '../values/my_colors.dart';

class HelpingWidgets {
  PreferredSizeWidget appBarWidget(onTap, {String? text}) {
    return AppBar(
      backgroundColor: MyColors.buttonColor,
      // leadingWidth: 70.w,
      elevation: 0,
      title: text != null
          ? Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 20.sp,
                color: Colors.white,
              ),
            )
          : null,
      centerTitle: true,
      leading: onTap == null
          ? null
          : GestureDetector(
              onTap: onTap,
              child: Icon(
                Icons.arrow_back,
                color: MyColors.iconColor1,
              ),
            ),
    );
  }

  Widget appBarText(String text) {
    return Text(
      text,
      style: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.w500,
          //  fontStyle: FontStyle.normal,
          fontFamily: "Roboto"),
    );
  }
}
