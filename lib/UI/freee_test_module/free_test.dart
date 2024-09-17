import 'package:fitness_zone_2/UI/auth_module/questionair_screen.dart';
import 'package:fitness_zone_2/values/my_colors.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:fitness_zone_2/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../values/my_imgs.dart';

class FreeTest extends StatelessWidget {
  FreeTest({super.key});
  final List<String> items = [
    "Snoozing your alarm every morning.",
    "Depending on multiple cups of coffee to survive the day",
    "The dreaded afternoon energy slump",
    "Feeling sluggish after eating"
  ];
  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(() {
        Get.back();
      }, text: "Are you hormonally\nimbalanced?", textAlign: TextAlign.center),
      body: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Text(
              "Say goodbye to hormonal struggles, and hello to answers and solutions.",
              style: textTheme.bodySmall!.copyWith(color: MyColors.textColor3),
              textAlign: TextAlign.center),
          SizedBox(
            height: 5,
          ),
          Text(
              "ake control of your health with Fit Her’s free hormone imbalance test, designed specifically for women.",
              style: textTheme.bodySmall!.copyWith(color: MyColors.textColor3),
              textAlign: TextAlign.center),
          const SizedBox(
            height: 20,
          ),
          CustomButton(
            text: "Start Free Test",
            onPressed: () {
              Get.to(()=>QuestionnaireScreen());
            },
            width: 150,
            height: 37,
            fontSize: 14,
            roundCorner: 25,
          ),
          const SizedBox(
            height: 50,
          ),
          Text("What do imbalanced hormones feels like?",
              style:
                  textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            height: 290,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: 5, // Number of stars (you can make this dynamic)
              itemBuilder: (context, index) {
                return Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Column(
                      children: [
                        SizedBox(height: 30.h,),
                        Expanded(
                          child: Container(
                            width: 300.w,
                            margin:
                                EdgeInsets.only(left: 25.w, right: index == 4 ? 20.w : 0),
                            padding:
                                EdgeInsets.only(top: 40.h, left: 25.w,right: 13.w),
                            decoration: BoxDecoration(
                                color: MyColors.workOut1,
                                borderRadius: BorderRadius.circular(5),
                                boxShadow: [
                                  BoxShadow(
                                      offset: const Offset(0, 1),
                                      spreadRadius: 0.5,
                                      blurRadius: 5,
                                      color: Colors.black.withOpacity(0.25))
                                ]),
                            child: Column(
                              // crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Low Energy",
                                  style: textTheme.bodyMedium!
                                      .copyWith(fontWeight: FontWeight.w600),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                ListView.builder(
                                  // padding:  EdgeInsets.only(left: 20,right: 14),
                                  itemCount: items.length,
                                  shrinkWrap: true ,
                                  itemBuilder: (context, index) {
                                    return Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('• ', style: TextStyle(fontSize: 20)),
                                        Expanded(
                                          child: Text(
                                            items[index],
                                            style: textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w400),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                // const Spacer(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Image.asset(MyImgs.battery,scale: 3.5,)
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
