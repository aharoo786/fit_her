import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../UI/plans_module/all_plans.dart';
import '../values/constants.dart';
import '../values/dimens.dart';
import '../values/my_colors.dart';
import '../values/my_imgs.dart';
import 'custom_button.dart';

class HelpingWidgets {
  PreferredSizeWidget appBarWidget(onTap, {String? text,TextAlign? textAlign,Color backGroundColor=Colors.white}) {
    return AppBar(
      backgroundColor: backGroundColor,
      // leadingWidth: 70.w,
      elevation: 0,
      systemOverlayStyle:  SystemUiOverlayStyle(statusBarColor: backGroundColor),
      title: text != null
          ? Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 20.sp,
                color: Colors.black,

              ),
             textAlign: textAlign?? TextAlign.start,
            )
          : null,
      centerTitle: true,
      leading: onTap == null
          ? null
          : GestureDetector(
              onTap: onTap,
              child: Icon(
                Icons.arrow_back,
                color: MyColors.iconColor2,
              ),
            ),
    );
  }

  Widget appBarText(String text) {
    return Text(
      text,
      style: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.w500,
          //  fontStyle: FontStyle.normal,
          fontFamily: "Roboto"),
    );
  }

  Widget notSubscribed(){
  return  const Center(child: Text("Please subscribe our plan to get started"));
  }

  Widget  getOurPlans(TextTheme textTheme){
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
              color: MyColors.planColor,
              borderRadius: BorderRadius.circular(5),
              border:
              Border.all(color: MyColors.primaryGradient1)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(MyImgs.freeTrial),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Free Trial Period",
                    style: textTheme.bodyMedium!
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(
                height: 7,
              ),
              Text(
                "1 day free, than charge\nRs. 2500 for a month",
                style: textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.black.withOpacity(0.3)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const Spacer(),
        CustomButton(
          text: "Start Free Trial",
          onPressed: () {},
          color: Colors.white,
          textColor: MyColors.primaryGradient1,
        ),
        SizedBox(
          height: 18.h,
        ),
        CustomButton(
            text: "Subscribe Now",
            onPressed: () {
              Get.find<HomeController>().getPlans();
              Get.to(() => OurPlansScreen());
            }),
        SizedBox(
          height: 20.h,
        )
      ],
    );
  }
}
