import 'package:fitness_zone_2/data/models/get_all_users/get_all_users_based_on_type.dart';
import 'package:fitness_zone_2/values/my_imgs.dart';
import 'package:fitness_zone_2/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../values/my_colors.dart';

class DoctorDetails extends StatelessWidget {
  const DoctorDetails({super.key, required this.userTypeData});
  final UserTypeData userTypeData;

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Column(
        children: [
          const SizedBox(
            height: kToolbarHeight / 2,
          ),
          SizedBox(
            width: double.maxFinite,
            child: Stack(
              children: [
                Container(
                  height: 360.h,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(MyImgs.doctor2),
                          fit: BoxFit.cover)),
                ),
                Column(
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
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25))),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 20.h,
                          ),
                          Text(
                            "${userTypeData.firstName} ${userTypeData.lastName}",
                            style: textTheme.headlineMedium!
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            userTypeData.speciality ?? "N/A",
                            style: textTheme.titleMedium!.copyWith(
                                color: MyColors.workOut2,
                                fontWeight: FontWeight.w500),
                          ),
                          SizedBox(
                            height: 8.h,
                          ),
                          Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              const Spacer(),
                              columnText(
                                  textTheme,
                                  userTypeData.totalPatients ?? "N/A",
                                  "Patients"),
                              SizedBox(
                                width: 50.w,
                              ),
                              columnText(textTheme,
                                  userTypeData.experience ?? "N/A", "yrs exp"),
                              SizedBox(
                                width: 40.w,
                              ),
                              columnText(textTheme, "N/A", "Rating"),
                              const Spacer()
                            ],
                          ),
                          SizedBox(
                            height: 25.h,
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 25.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Description",
                                      style: textTheme.bodyMedium!.copyWith(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      userTypeData.description ?? "N/A",
                                      style: textTheme.titleLarge!.copyWith(
                                          color: MyColors.workOutTextColor,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
      // bottomNavigationBar: Container(
      //   padding: EdgeInsets.only(
      //       left: MediaQuery.of(context).size.width * 0.7,
      //       right: 13.w,
      //       top: 10.h,
      //       bottom: 30.h),
      //   child: CustomButton(
      //     text: 'Book Now',
      //     onPressed: () {},
      //     width: 90.w,
      //     fontSize: 12.sp,
      //     height: 30.h,
      //   ),
      // ),
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
