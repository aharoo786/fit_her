import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import '../values/values.dart';

class CustomToast {
  static failToast(
      {Color? bgcolor, Color? textColor, String? msg, len, gravity}) {
    return Fluttertoast.showToast(
      backgroundColor: bgcolor ?? MyColors.error,
      textColor: textColor ?? MyColors.textColor2,
      msg: msg!,
      timeInSecForIosWeb: 5,
      toastLength: len ?? Toast.LENGTH_LONG,
      gravity: gravity ?? ToastGravity.BOTTOM, // location// duration
    );
  }

  static successToast(
      {Color? bgcolor, Color? textColor, String? msg, len, gravity}) {
    return Fluttertoast.showToast(
      backgroundColor: bgcolor ?? Colors.green,
      textColor: textColor ?? MyColors.textColor2,
      msg: msg!,
      toastLength: len ?? Toast.LENGTH_LONG,
      gravity: gravity ?? ToastGravity.BOTTOM, // location// duration
    );
  }

  static noInternetToast(
      {Color? bgcolor, Color? textColor, len, gravity}) {
    return Fluttertoast.showToast(
      backgroundColor: bgcolor ?? Colors.green,
      textColor: textColor ?? MyColors.textColor2,
      msg: "No internet Connection",
      toastLength: len ?? Toast.LENGTH_LONG,
      gravity: gravity ?? ToastGravity.BOTTOM, // location// duration
    );
  }
}
