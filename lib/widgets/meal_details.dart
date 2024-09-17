import 'package:fitness_zone_2/UI/plans_module/select_payment_mode.dart';
import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/values/my_imgs.dart';
import 'package:fitness_zone_2/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../values/my_colors.dart';

class DietDetails extends StatelessWidget {
  DietDetails({
    super.key,
    this.isPlan = false,
    this.title = "Keto Diet Plan",
    this.longDescription = "Transform your health with us",
    this.description =
        "The Keto Diet, short for the ketogenic diet, is a high-fat, low-carbohydrate eating plan designed to shift your body's primary energy source from carbohydrates to fats.",
    this.price="2000",
    this.duration="3 months",
    this.planId="0",this.planCategory=0
  });
  String description;
  String title;
  String longDescription;
  String price;
  String duration;
  String planId;
  int planCategory;

  final bool isPlan;
  final List workoutText = [
    "Early Detection",
    "Preventive Care",
    "Personalized Health Advice"
  ];

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: ListView(
        children: [
          // const SizedBox(
          //   height: kToolbarHeight / ,
          // ),
          SizedBox(
            width: double.maxFinite,
            child: Stack(
              children: [
                Container(
                  height: 360.h,
                  decoration:  BoxDecoration(
                    color:isPlan?MyColors.primaryGradient2:Colors.white ,
                      image: DecorationImage(
                          image: AssetImage(isPlan?MyImgs.logo:MyImgs.doctor2),
                          fit: BoxFit.cover)),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: kToolbarHeight / 2,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 13.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Get.back();
                            },
                            child: const CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.arrow_back,
                                color: MyColors.iconColor2,
                              ),
                            ),
                          ),
                          // GestureDetector(
                          //   onTap: () {},
                          //   child: const CircleAvatar(
                          //     radius: 15,
                          //     backgroundColor: Colors.white,
                          //     child: Icon(
                          //       Icons.favorite_border,
                          //       color: MyColors.iconColor2,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 270.h,
                    ),
                    // const Spacer(),

                    Container(
                      width: double.maxFinite,
                      padding: EdgeInsets.symmetric(horizontal: 25.w),
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 20.h,
                          ),
                          Text(
                            title,
                            style: textTheme.headlineMedium!
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            "Transform your health with us",
                            style: textTheme.titleMedium!.copyWith(
                                color: MyColors.workOutTextColor,
                                fontWeight: FontWeight.w500),
                          ),
                          SizedBox(
                            height: 8.h,
                          ),
                          Text(
                            description,
                            style: textTheme.titleLarge!.copyWith(
                                color: MyColors.workOutTextColor,
                                height: 1.5,
                                fontWeight: FontWeight.w400),
                          ),
                          SizedBox(
                            height: 25.h,
                          ),
                          Text(
                           isPlan?"Description":"Purpose",
                            style: textTheme.bodySmall!
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            longDescription,
                            style: textTheme.titleLarge!.copyWith(
                                color: MyColors.workOutTextColor,
                                height: 1.5,
                                fontWeight: FontWeight.w400),
                          ),

                          isPlan?Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 25.h,

                              ),
                              Text(
                                "Duration",
                                style: textTheme.bodySmall!
                                    .copyWith(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                duration,
                                style: textTheme.titleLarge!.copyWith(
                                    color: MyColors.workOutTextColor,
                                    height: 1.5,
                                    fontWeight: FontWeight.w400),
                              ),
                              SizedBox(
                                height: 8.h,
                              ),
                            ],
                          ):SizedBox.shrink(),

                          Text(
                            "Benefits",
                            style: textTheme.bodySmall!
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          Wrap(
                            children: workoutText.map((i) {
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        color: MyColors.workOut1),
                                    margin: EdgeInsets.only(
                                        right: 12.w, bottom: 12.h),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 15.w, vertical: 5.h),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          i,
                                          style: textTheme.bodySmall!.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: MyColors.primaryGradient3),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
      bottomNavigationBar: Container(
        padding:
            EdgeInsets.only(left: 25.w, right: 25.w, top: 10.h, bottom: 30.h),
        child: Row(
          children: [
            Expanded(
                child: RichText(
                    text: TextSpan(
                        text: "Rs. ",
                        style: textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        children: [
                  TextSpan(
                      text: price,
                      style: textTheme.bodySmall!.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 32.sp,
                      )),
                  TextSpan(
                      text: " /month",
                      style: textTheme.bodySmall!.copyWith(
                        fontWeight: FontWeight.w600,
                      )),
                ]))),
            CustomButton(
              text: 'Book Now',
              onPressed: () {
                // Get.find<HomeController>().makePayment();
                Get.to(()=>SelectPaymentMode(planId: planId, planCategory: planCategory,));
              },
              width: 100.w,
              fontSize: 12.sp,
              height: 30.h,
            ),
          ],
        ),
      ),
    );
  }

  Widget columnText(TextTheme textTheme, String text1, String text2) {
    return Column(
      children: [
        Text(
          text1,
          style: textTheme.headlineMedium!
              .copyWith(color: MyColors.workOut2, fontWeight: FontWeight.w600),
        ),
        Text(
          text2,
          style: textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
