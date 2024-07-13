import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../data/controllers/home_controller/home_controller.dart';
import '../../../values/my_colors.dart';
import '../../../widgets/app_bar_widget.dart';
import '../../../widgets/circular_progress.dart';
import '../../../widgets/custom_button.dart';
import '../../auth_module/result_screen.dart';

class AllGuestUsers extends StatelessWidget {
  AllGuestUsers({Key? key}) : super(key: key);
  final HomeController homeController = Get.find();

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(() {
        Get.back();
      }, text: "All PCOS Results"),
      body: Column(
        children: [
          Expanded(
              child: Obx(
            () => homeController.guestUserLoad.value
                ? ListView.separated(
                   padding: EdgeInsets.symmetric(horizontal: 20.w,vertical: 20.h),
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (BuildContext context, int reportIndex) {
                      var guestUser =
                          homeController.getGuestData!.data[reportIndex];

                      return Container(
                        padding: EdgeInsets.all(20.h),
                        decoration: BoxDecoration(
                            color: MyColors.appBackground,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.black.withOpacity(0.6))),
                        child: Column(children: [
                          Text(
                            "PCOS Result",
                            style: textTheme.headlineSmall!
                                .copyWith(fontWeight: FontWeight.w700,),
                          ),
                          reportRow("Name", guestUser.name, context),
                          reportRow("Email", guestUser.email, context),
                          reportRow("Phone", guestUser.phone, context),
                          reportRow("Result", guestUser.result ?? "N/A", context),
                          reportRow("Date", DateFormat("dd-MM-yyyy").format(guestUser.createdAt), context),
                          SizedBox(height: 20.h,),
                          CustomButton(
                              text: "Chat with us",
                              onPressed: () {
                                openWhatsAppChat(guestUser.phone);
                              }),
                        ]),
                      );
                    },
                    itemCount: homeController.getGuestData!.data.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(
                        height: 20.h,
                      );
                    },
                  )
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text1,
              style: textTheme.bodyMedium!.copyWith(
                  color: MyColors.textColor.withOpacity(0.6),
                  fontWeight: FontWeight.w400),
            ),
            Text(
              text2,
              style: textTheme.bodySmall!.copyWith(
                  color: MyColors.textColor, fontWeight: FontWeight.w500),
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
