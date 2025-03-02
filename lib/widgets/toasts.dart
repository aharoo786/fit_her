import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import '../values/values.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';

class CustomToast {


 static showDownLoadToast(BuildContext context,
      {required String message, required String filePath}) {
    FToast fToast = FToast();
    fToast.init(context);
    fToast.showToast(
      toastDuration: Duration(seconds: 5),
      child: ToastWidget(message: message, filePath: filePath),
      gravity: ToastGravity.BOTTOM,
    );
  }

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
class ToastWidget extends StatelessWidget {
  final String message;
  final String filePath;

  const ToastWidget({super.key, required this.message, required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.0),
        color: Colors.black,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Download File",
              style: TextStyle(color: Colors.white, fontSize: 12.0)),
          SizedBox(
            width: 50.0,
          ),
          GestureDetector(
            onTap: () {
              try {
                print("path  $filePath");
                OpenFilex.open(filePath).then((result) {
                  // Handle the result if needed
                }).catchError((error, stackTrace) {
                  print("Error: $error");
                  print("Stack Trace: $stackTrace");
                });
              } catch (e) {
                print("error of opening---- $e");
              }
            },
            child: Text(
              "Open",
              style: TextStyle(
                color: Colors.white,
                decorationColor: Colors.white,
                decoration: TextDecoration.underline,
                fontSize: 10.0,
              ),
            ),
          ),
          SizedBox(
            width: 12.0,
          ),
          GestureDetector(
            onTap: () {
              Share.shareXFiles([XFile(filePath)], text: 'P45');
            },
            child: Text(
              "Share",
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white,
                fontSize: 10.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}