import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'my_colors.dart';

class Styles {
  static final appTheme = _baseTheme.copyWith(

    iconTheme: const IconThemeData(
      color: MyColors.black,
      size:20,
    ),
    textTheme: _baseTextTheme,
    cardTheme: _baseTheme.cardTheme.copyWith(
      margin: EdgeInsets.zero,
    ),
    textSelectionTheme: _baseTheme.textSelectionTheme.copyWith(
      cursorColor: _colorScheme.secondary,
      selectionHandleColor: _colorScheme.secondary,
    ),
    appBarTheme: AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: MyColors.buttonColor,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light
        ),
        backgroundColor: _colorScheme.background,
        titleTextStyle:  TextStyle(
          fontSize: 24.sp,
         // fontWeight: FontWeight.w500,
         fontStyle: FontStyle.normal,
          color: MyColors.textColor,
          fontFamily :"Roboto",

        )),
    scrollbarTheme: ScrollbarThemeData(
        showTrackOnHover: true,
        interactive: true,
        trackColor: MaterialStateProperty.all(MyColors.green100),
        trackBorderColor: MaterialStateProperty.all(MyColors.yellow),
        thickness: MaterialStateProperty.all(5),
        thumbColor: MaterialStateProperty.all(MyColors.darkBlue),
        radius: const Radius.circular(10),
        minThumbLength: 10),
  );

  static final secondaryTextTheme = _baseTextTheme.apply(
    displayColor: MyColors.bodyBackground,
    bodyColor: MyColors.white200,
  );

  static final onSecondaryTextTheme = _baseTextTheme.apply(
    displayColor: MyColors.black,
    bodyColor: MyColors.black,
  );

  static const _colorScheme = ColorScheme.light(
    primary: MyColors.bodyBackground,
    secondary: MyColors.black,
    onPrimary: MyColors.bodyBackground,
    onSecondary: MyColors.primary2,
    onBackground: MyColors.appBackground,
  );

  static final _baseTheme = ThemeData.from(
    colorScheme: _colorScheme,
    textTheme: Typography.material2018().black.apply(
      fontFamily: "Roboto",
      displayColor: _colorScheme.secondary,
      bodyColor: _colorScheme.secondary,
    ),
  );

  static final _baseTextTheme = _baseTheme.textTheme.copyWith(
    headlineLarge: _baseTheme.textTheme.headlineLarge!.copyWith(
      color: MyColors.black,
      fontSize: 32.sp,
      height: 1.5,
      fontFamily: "Roboto",
      fontWeight: FontWeight.w700,
    ),
    headlineMedium: _baseTheme.textTheme.headlineMedium!.copyWith(
      color: MyColors.textColor,
      fontSize: 24.sp,
      height: 1.5,
      fontFamily: "Roboto",
      fontStyle: FontStyle.normal,
    ),
    headlineSmall: _baseTheme.textTheme.headlineSmall!.copyWith(
        fontSize: 20.sp,
        color: MyColors.black,
        height: 1.5,
        fontFamily: "Roboto",
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal),
    bodyLarge: _baseTheme.textTheme.bodyLarge!.copyWith(
      fontSize: 18.sp,
      color: MyColors.textColor,
      height: 1.5,
      fontWeight: FontWeight.w500,
      fontFamily: "Roboto",
    ),
    bodyMedium: _baseTheme.textTheme.bodyMedium!.copyWith(
        fontSize: 16.sp,
        color: MyColors.textColor,
        height: 1.5,
        fontFamily: "Roboto",
        fontStyle: FontStyle.normal),
    bodySmall: _baseTheme.textTheme.bodySmall!.copyWith(
        fontSize: 14.sp,
        color: MyColors.textColor,
        height: 1.5,
        fontFamily: "Roboto",
        fontStyle: FontStyle.normal),
    titleLarge: _baseTheme.textTheme.titleLarge!.copyWith(
        fontSize: 12.sp,
        color: MyColors.black,
        height: 1.5,
        fontFamily: "Roboto",
        fontWeight: FontWeight.w700),
    titleMedium: _baseTheme.textTheme.labelLarge!.copyWith(
        fontSize: 10.sp,
        color: MyColors.black,
        //  decoration: TextDecoration.underline,
        height: 1.5,
        fontFamily: "Roboto",
        fontWeight: FontWeight.normal),
    titleSmall: _baseTheme.textTheme.labelMedium!.copyWith(
      fontSize: 8.sp,
      color: MyColors.grey,
      height: 1.5,
      fontFamily: "Roboto",
    ),
    // overline: _baseTheme.textTheme.overline!.copyWith(
    //   fontSize: 8,
    //   fontFamily :"Roboto",
    //   color: MyColors.grey,
    //   height: 1.5,
    // ),
  );

  static final _accentTextTheme = _baseTextTheme.apply(
    displayColor: _colorScheme.secondary,
    bodyColor: _colorScheme.secondary,
  );

  Styles._();
}
