import 'package:fitness_zone_2/UI/free_trail/free_trail_question.dart';
import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../UI/plans_module/all_plans.dart';
import '../data/models/get_all_users/get_all_users_based_on_type.dart';
import '../values/my_colors.dart';
import '../values/my_imgs.dart';
import 'custom_button.dart';

class HelpingWidgets {
  PreferredSizeWidget appBarWidget(onTap,
      {String? text,
      TextAlign? textAlign,
      Color backGroundColor = Colors.white,
      Widget? actionWidget,
      PreferredSizeWidget? bottom}) {
    return AppBar(
      backgroundColor: backGroundColor,
      // leadingWidth: 70.w,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: backGroundColor),
      title: text != null
          ? Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 20.sp,
                color: Colors.black,
              ),
              textAlign: textAlign ?? TextAlign.start,
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
      actions: [actionWidget ?? const SizedBox()],
      bottom: bottom,
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

  Widget notSubscribed() {
    return const Center(
        child: Text("Please subscribe our plan to get started"));
  }

  Widget bottomBarButtonWidget({String text = "Submit", VoidCallback? onTap}) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: CustomButton(
        text: text,
        onPressed: onTap ?? () => Get.back(),
      ),
    );
  }

  Widget iconPlusMinus({IconData icon = Icons.add, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40.h,
        width: 40.h,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: MyColors.buttonColor, width: 2)),
        child: Icon(
          icon,
          color: MyColors.buttonColor,
        ),
      ),
    );
  }

  Widget getOurPlans(TextTheme textTheme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
              color: MyColors.planColor,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: MyColors.primaryGradient1)),
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
          onPressed: () {
            Get.find<HomeController>().addFreeTrial();
            //  Get.to(()=>FreeTrialPersonalizationScreen());
          },
          color: Colors.white,
          textColor: MyColors.primaryGradient1,
        ),
        SizedBox(
          height: 18.h,
        ),
        CustomButton(
            text: "Subscribe Now",
            onPressed: () {
              Get.find<HomeController>().getPlansUser();
              Get.to(() => OurPlansScreen());
            }),
        SizedBox(
          height: 20.h,
        )
      ],
    );
  }

  Widget list(List<UserTypeData> list, RxInt variable, TextTheme textTheme) {
    return ListView.separated(
      // shrinkWrap: true,
      itemCount: list.length,
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(vertical: 10),
      itemBuilder: (BuildContext context, int index) {
        var diet = list[index];

        return GestureDetector(
          onTap: () {
            variable.value = diet.id;
          },
          child: Obx(
            () => Container(
              width: 300.w,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: variable.value == diet.id
                          ? MyColors.buttonColor
                          : Colors.white),
                  boxShadow: [
                    BoxShadow(
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                        color: Colors.black.withOpacity(0.1))
                  ]),
              child: Row(children: [
                Container(
                  width: 70.w,
                  height: 80,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: MyColors.primaryGradient1,
                      image: const DecorationImage(
                          image: AssetImage(MyImgs.logo))),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${diet.firstName} ${diet.lastName}",
                          style: textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          diet.email,
                          style: textTheme.bodySmall!.copyWith(),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                )
              ]),
            ),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return SizedBox(
          width: 10.h,
        );
      },
    );
  }

  showCustomDialog(BuildContext context, Function() onTap, String firstText,
      String secondText, String image) {
    var textTheme = Theme.of(context).textTheme;
    showDialog(
        context: context,
        builder: (context) => Dialog(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(image),
                    const SizedBox(
                      height: 14,
                    ),
                    Text(
                      firstText,
                      style: textTheme.bodyMedium!.copyWith(
                          color: MyColors.black, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      secondText,
                      style: textTheme.titleLarge!.copyWith(
                          fontSize: 13,
                          color: MyColors.black.withOpacity(0.5),
                          fontWeight: FontWeight.w400),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    CustomButton(
                      text: "Start",
                      onPressed: onTap,
                      height: 40,
                      width: 200,
                      fontSize: 14,
                      roundCorner: 25,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ));
  }
}
