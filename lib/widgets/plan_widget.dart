import 'package:fitness_zone_2/UI/plans_module/select_payment_mode.dart';
import 'package:fitness_zone_2/values/my_imgs.dart';
import 'package:fitness_zone_2/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../data/models/get_user_plan/get_user_plan.dart';
import '../values/my_colors.dart';

class PlanWidget extends StatelessWidget {
  const PlanWidget({super.key, required this.plan});
  final Plan plan;

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 5,
      child: Container(
        // width: 300,
        decoration: BoxDecoration(
          color: MyColors.primaryGradient1,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 6.h,
            ),
            Text('Recommended',
                style: textTheme.titleLarge!.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w600)),
            SizedBox(
              height: 6.h,
            ),
            Container(
              width: double.maxFinite,
              color: MyColors.planColor,
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Rs. ${plan.price}',
                      style: textTheme.titleLarge!.copyWith(
                          fontSize: 36.sp, fontWeight: FontWeight.w600)),
                  Text('per ${plan.duration}',
                      style: textTheme.titleLarge!
                          .copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  arrowContainer(textTheme, text: plan.shortDescription),
                  arrowContainer(textTheme, text: plan.longDescription),
                  arrowContainer(textTheme),
                  // arrowContainer(textTheme),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            CustomButton(
              height: 50.h,
              width: 120.w,
              roundCorner: 20,
              text: "Subscribe",
              fontSize: 14.sp,
              textColor: Colors.black,
              onPressed: () {
                Get.to(() => SelectPaymentMode(
                    planId: plan.id.toString(), planCategory: plan.categoryId));
              },
              color: Colors.white,
            ),
            SizedBox(height: 14.h),
          ],
        ),
      ),
    );
  }

  arrowContainer(TextTheme textTheme, {String? text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SvgPicture.asset(MyImgs.arrowCircleRight),
          SizedBox(
            width: 10.w,
          ),
          SizedBox(
            width: 150,
            child: Text(
              text ?? 'Live Workout Session',
              style: textTheme.bodySmall!.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,

              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
