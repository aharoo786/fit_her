import 'package:fitness_zone_2/UI/health_tips_module/health_tips_details_screen.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:fitness_zone_2/widgets/circular_progress.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/controllers/home_controller/home_controller.dart';
import '../../values/my_colors.dart';
import '../../values/my_imgs.dart';
import '../../widgets/meal_details.dart';

class HealthTipsScreen extends StatelessWidget {
   HealthTipsScreen({super.key});
  final HomeController homeController=Get.find();
  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(() {
        Get.back();
      }, text: "Health Tips For You"),
      body: Obx(
        ()=>homeController.getHealthTipsLoad.value? ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.all(18.w),
          itemCount: homeController.getAllHealthTips!.healthTips.length, // Number of stars (you can make this dynamic)
          itemBuilder: (context, index) {
          var tip=  homeController.getAllHealthTips!.healthTips[index];
            return GestureDetector(
              onTap: () {
                Get.to(() => HealthTipsDetailsScreen(healthTip: tip,));
              },
              child: Container(
                height: 140.h,
                width: double.maxFinite,
                decoration: BoxDecoration(
                    color: MyColors.healthTipsColor,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.black, width: 1.w),
                    boxShadow: [
                      BoxShadow(
                          offset: const Offset(0, 4),
                          spreadRadius: 0.5,
                          blurRadius: 10,
                          color: Colors.black.withOpacity(0.25))
                    ]),
                child: LayoutBuilder(builder: (context, constraints) {
                  return Row(
                    children: [
                      Container(
                        height: 140,
                        width: constraints.maxWidth/3,
                        decoration: const BoxDecoration(
                            color: MyColors.primaryGradient1,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(25),
                                bottomLeft: Radius.circular(25)),
                            image: DecorationImage(
                                image: AssetImage(MyImgs.logo))),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 10.h, horizontal: 20.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tip.title,
                                style: textTheme.titleLarge!
                                    .copyWith(fontWeight: FontWeight.w600),
                              ),
                              SizedBox(
                                height: 3.h,
                              ),
                              Text(
                                tip.description,
                                style: textTheme.titleMedium!.copyWith(
                                    fontWeight: FontWeight.w600, height: 1.5,),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(
                                height: 25.h,
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  "Read More",
                                  style: textTheme.titleMedium!.copyWith(
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return SizedBox(
              height: 25.h,
            );
          },
        ):CircularProgress()
      ),
    );
  }
}
