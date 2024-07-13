import 'package:fitness_zone_2/data/controllers/auth_controller/auth_controller.dart';
import 'package:fitness_zone_2/values/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../data/models/home_model/home_model.dart';
import '../../../values/my_imgs.dart';
import '../../../widgets/CustomText.dart';
import '../../../widgets/app_bar_widget.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfield.dart';
import '../../../widgets/toasts.dart';

class Payment extends StatelessWidget {
  Payment({super.key,});


  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(
        () {
          Get.back();
        },
        text: "Payment Detail",
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:  EdgeInsets.symmetric(horizontal: 20.w,vertical: 20.h),
            child: Text(
              "Join Live Session",
              style: textTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child:
          ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: 7,
           // scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                 // Get.to(() => Payment());
                },
                child: Container(
                  width: 300.w,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            offset: Offset(0, 2),
                            blurRadius: 4,
                            color: Colors.black.withOpacity(0.1))
                      ]),
                  child: Row(children: [
                    SizedBox(
                      width: 10.w,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Date/Time ${index + 1}",
                            style: textTheme.headlineSmall!.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "this is the description",
                            style: textTheme.bodySmall!.copyWith(),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: MyColors.buttonColor
                      ),
                      child: Text("Join now",style: textTheme.bodySmall,),
                    )
                  ]),
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return SizedBox(
                height: 10.h,
              );
            },
          ),
          )

        ],
      ),
    );
  }
}

