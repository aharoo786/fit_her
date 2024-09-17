import 'package:fitness_zone_2/data/models/get_all_health_tips/get_health_tips.dart';
import 'package:fitness_zone_2/values/my_colors.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../values/my_imgs.dart';

class HealthTipsDetailsScreen extends StatelessWidget {
  const HealthTipsDetailsScreen({super.key, required this.healthTip});
  final HealthTip healthTip;

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(() {
        Get.back();
      },
          text: healthTip.title,
          textAlign: TextAlign.center),
      body: Column(
        children: [
          Center(
            child: Text(
              "Your guide to Inner Peace and Relaxation ",
              style: textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: MyColors.black.withOpacity(0.25)),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 200,
                width: double.maxFinite,
                decoration: const BoxDecoration(
                    color: MyColors.primaryGradient1,
                    // borderRadius: BorderRadius.only(
                    //     topLeft: Radius.circular(25),
                    //     bottomLeft: Radius.circular(25)),
                    image: DecorationImage(
                        image: AssetImage(MyImgs.logo))),
              ),
              SizedBox(
                height: 15.h,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Purpose",
                      style:
                          textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 5,),
                    Text(
                      healthTip.description,
                      style: textTheme.titleLarge!.copyWith(
                          color: MyColors.black.withOpacity(0.25),
                          // height: 1.5,
                          // overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.w400),
                    )
                  ],
                ),
              ),

            ],
          )
        ],
      ),
    );
  }
}
