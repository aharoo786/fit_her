import 'package:fitness_zone_2/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/app_bar_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.result});
  final String result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(() {
        Get.back();
      }, text: "Result"),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        //crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 50.h,
          ),
          Center(
            child: Text(
              "Your PCOS Result",
              style: TextStyle(
                fontSize: 40.sp,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            height: 10.h,
          ),
          Center(
            child: Text(
              "Result: $result",
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            height: 20.h,
          ),
          Text(
            "Any Query or Need Consultancy",
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 20.h,
          ),
          CustomButton(
              text: "Chat with us",
              onPressed: () {
                openWhatsAppChat("923264986911");
              }),
          SizedBox(
            height: 20.h,
          ),
          Text(
            "Interpretation of Results",
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 20.h,
          ),
          RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 14.sp, color: Colors.black),
              children: [
                if (result == "High Risk of PCOS")
                  const TextSpan(
                    text: 'High Risk of PCOS: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                if (result == "High Risk of PCOS")
                  const TextSpan(
                    text:
                        "If you answered 'Yes' or 'Frequently' to several questions related to menstrual irregularity, excess hair growth, acne, weight gain, fertility issues, family history of PCOS, and lifestyle factors such as sedentary behavior and poor diet, you may be at a higher risk of PCOS. It is advisable to consult a healthcare professional for further evaluation and management.\n\n",
                  ),
                if (result == "Moderate Risk of PCOS")
                  const TextSpan(
                    text: 'Moderate Risk of PCOS: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                if (result == "Moderate Risk of PCOS")
                  const TextSpan(
                    text:
                        "If you answered 'Yes' or 'Frequently' to some questions related to PCOS symptoms and risk factors, but not all, you may be at a moderate risk of PCOS. It is recommended to discuss your concerns with a healthcare provider for personalized assessment and guidance.\n\n",
                  ),
                if (result == "Low Risk of PCOS")
                  const TextSpan(
                    text: 'Low Risk of PCOS: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                if (result == "Low Risk of PCOS")
                  const TextSpan(
                    text:
                        "If you answered 'No' or 'Occasionally' to most questions related to PCOS symptoms and risk factors, you may be at a lower risk of PCOS. However, if you still have concerns or experience any unusual symptoms, it is advisable to seek medical advice for reassurance.",
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

void openWhatsAppChat(String phoneNumber) async {

  String url =
      'https://api.whatsapp.com/send/?phone=$phoneNumber&text&type=phone_number&app_absent=0';

  try {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  } catch (e) {
    throw 'Could not launch $e';
  }
}
