import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/widgets/circular_progress.dart';
import 'package:fitness_zone_2/widgets/custom_button.dart';
import 'package:fitness_zone_2/widgets/full_image_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../values/constants.dart';
import '../../../values/my_colors.dart';
import '../../../widgets/app_bar_widget.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AllNewUserImages extends StatelessWidget {
  AllNewUserImages({Key? key}) : super(key: key);
  final HomeController homeController = Get.find();

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(() {
        Get.back();
      }, text: "All New Users"),
      body: Column(
        children: [
          Expanded(
              child: Obx(
            () => homeController.getPlanImagesLoad.value
                ? GetBuilder<HomeController>(
                    id: "newList",
                    builder: (cont) {
                      return ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemBuilder: (BuildContext context, int index) {
                          var plan =
                              homeController.getAllPlansImages!.data[index];
                          var user = homeController
                              .getAllPlansImages!.data[index].user;

                          return Container(
                            padding: EdgeInsets.all(20.h),
                            decoration: BoxDecoration(
                                color: MyColors.appBackground,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: Colors.black.withOpacity(0.6))),
                            child: Column(children: [
                              if (plan.image != null)
                                GestureDetector(
                                  onTap: () {
                                    Get.to(() =>
                                        FullImageWidget(image: plan.image!));
                                  },
                                  child: Container(
                                    height: 200.h,
                                    margin: EdgeInsets.only(bottom: 20.h),
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: NetworkImage(
                                                "${Constants.baseUrl}/${plan.image!}"),
                                            fit: BoxFit.cover)),
                                  ),
                                ),

                              reportRow(
                                  "Name",
                                  "${user?.firstName} ${user?.lastName}",
                                  context),
                              reportRow("Email", user?.email ?? "", context),
                              reportRow(
                                  "Phone No.", user?.phone ?? "", context),
                              // reportRow("Phone no", user.phone, context),
                              reportRow(
                                  "Plan Name",
                                  plan.plan == null ? "N/A" : plan.plan!.title,
                                  context),
                              reportRow(
                                  "Sales Representative",
                                  user?.supporter != null
                                      ? "${user?.supporter!.firstName} ${user?.supporter?.lastName} "
                                      : "",
                                  context),
                              reportRow(
                                  "Plan Duration",
                                  plan.plan == null
                                      ? "N/A"
                                      : plan.priceDuration.duration??"",
                                  context),
                              SizedBox(
                                height: 20.h,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomButton(
                                        text: "Approve",
                                        onPressed: () {
                                          homeController
                                              .approveUser(plan.id.toString(),false);
                                        }),
                                  ),
                                  SizedBox(width: 10,),
                                  Expanded(
                                    child: CustomButton(
                                        text: "Reject",
                                        color:Colors.red,
                                        onPressed: () {
                                          homeController
                                              .approveUser(plan.id.toString(),true);
                                        }),
                                  ),
                                ],
                              )
                              // reportRow("Current Day Weight",
                              //     report.currentWeight, context),
                              // reportRow("Waist", report.weist, context),
                              // reportRow("Shoulder", report.shoulder, context),
                              // reportRow("Arms", report.arms, context),
                              // reportRow("Chest", report.chest, context),
                              // reportRow("Abdomen", report.abdoman, context),
                              // reportRow("Hips", report.hips, context),
                              // reportRow("Thighs", report.thighs, context),
                            ]),
                          );
                        },
                        itemCount:
                            homeController.getAllPlansImages!.data.length,
                        separatorBuilder: (BuildContext context, int index) {
                          return SizedBox(
                            height: 20.h,
                          );
                        },
                      );
                    })
                : CircularProgress(),
          ))
        ],
      ),
    );
  }

  Widget reportRow(String text1, String text2, context) {
    var textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Row(
          // crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                text1,
                style: textTheme.bodyMedium!.copyWith(
                    color: MyColors.textColor.withOpacity(0.6),
                    fontWeight: FontWeight.w400),
              ),
            ),
            Expanded(
              child: Text(
                text2,
                style: textTheme.bodySmall!.copyWith(
                    color: MyColors.textColor, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 5.h,
        )
      ],
    );
  }
}
