import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../values/my_colors.dart';
import '../../../widgets/CustomText.dart';
import '../../../widgets/app_bar_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WorkOuts extends StatelessWidget {
  const WorkOuts({super.key});

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(() {
        Get.back();
      }, text: "Workouts"),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (BuildContext context, int index) {
          return Container(
              padding: EdgeInsets.only(
                  left: 30.w, top: 15.h, bottom: 15.h, right: 20.h),
              margin: const EdgeInsets.symmetric(vertical: 10),
              // height: 120,
              decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        offset: const Offset(0, 2),
                        blurRadius: 22,
                        color: Colors.black.withOpacity(.2))
                  ],
                  borderRadius: const BorderRadius.all(Radius.circular(8))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Yoga",
                        style: textTheme.bodyMedium!
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        "16 Exercise",
                        style: textTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.w400,
                            color: MyColors.black.withOpacity(0.6)),
                      ),
                      Text("40 minutes",
                          style: textTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.w400,
                              color: MyColors.black.withOpacity(0.6))),
                    ],
                  ),
                  Image.asset(
                    "assets/icons/yoga2.png",
                    scale: 1.5,
                  ),
                ],
              ));
        },
      ),
    );
  }
}
