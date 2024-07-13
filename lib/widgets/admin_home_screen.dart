import 'package:fitness_zone_2/UI/dashboard_module/add_package/add_package.dart';
import 'package:fitness_zone_2/UI/dashboard_module/get_all_new_user_images/get_new_user_images.dart';
import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../UI/dashboard_module/add_new_user/add_new_user.dart';
import '../UI/dashboard_module/all_user_screens/all_users_screen.dart';
import '../UI/dashboard_module/all_weekly_reports/all_weekly_report.dart';
import '../UI/dashboard_module/get_guest_users/get_guest_users.dart';
import '../UI/dashboard_module/home_screen/home_screen.dart';
import '../UI/dashboard_module/my_daily_meal/my_daily_meal.dart';
import '../UI/dashboard_module/my_recordings/my_recordings_screen.dart';

import '../UI/dashboard_module/reminders_screen/reminders_screen.dart';
import '../values/my_colors.dart';
import '../values/my_imgs.dart';
import 'package:get/get.dart';

import 'all_plans_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  AdminHomeScreen({Key? key}) : super(key: key);
  final HomeController homeController = Get.find();
  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            SizedBox(
              height: 50.h,
            ),
            Stack(
              alignment: Alignment.bottomLeft,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(
                      top: 42.h, bottom: 42.h, right: 15.w, left: 130.w),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xffFAD8CD)),
                  child: Text(
                    "Make Your Body\nHealthy & Fit With Us",
                    style: textTheme.headlineMedium!.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Image.asset(
                  MyImgs.girl,
                  scale: 3,
                ),
              ],
            ),
            SizedBox(
              height: 40.h,
            ),
            GestureDetector(
              onTap: () {
                Get.to(() => AllUsersScreen());
                homeController.getAllUsersFunc();
              },
              child: containerWidget(
                  const Color(0xffCCF2FE), "All Users", MyImgs.userIcon),
            ),
            SizedBox(
              height: 20.h,
            ),
            GestureDetector(
              onTap: () {
                Get.to(() => AllGuestUsers());
                homeController.getGuestUsers();
              },
              child: containerWidget(const Color(0xffCCF2FE),
                  "PCOS Assessment Users", MyImgs.userIcon),
            ),
            SizedBox(
              height: 20.h,
            ),
            GestureDetector(
              onTap: () {
                Get.to(() => AllNewUserImages());
                homeController.getAllImagesPlan();
              },
              child: containerWidget(
                  const Color(0xffCCF2FE), "New Users", MyImgs.userIcon),
            ),
            SizedBox(
              height: 20.h,
            ),
            GestureDetector(
              onTap: () {
                Get.to(() => AllWeeklyReport());
                homeController.getWeeklyReportsFunc();
              },
              child: containerWidget(const Color(0xffFCE4D1),
                  "All Weekly Reports", MyImgs.myWeeklyReport),
            ),
            SizedBox(
              height: 20.h,
            ),
            GestureDetector(
              onTap: () {
                Get.to(() => AllPlansScreen(
                      isHaveAppBar: true,
                    ));
                homeController.getPlans();
              },
              child: containerWidget(
                  const Color(0xffFdE4F1), "All Packages", MyImgs.package),
            ),
            SizedBox(
              height: 20.h,
            ),
            GestureDetector(
              onTap: () {
                Get.to(() => AddPackage());
                homeController.getCategories();
              },
              child: containerWidget(
                  const Color(0xffFdE4F1), "Add Package", MyImgs.package),
            ),
            SizedBox(
              height: 16.h,
            ),
            GestureDetector(
              onTap: () {
                Get.to(() => AddNewUser(
                      isMember: true,
                    ));
                homeController.getPlans();
              },
              child: containerWidget(
                  const Color(0xffE9ECEF), "Add Team Member", MyImgs.addMember),
            ),
            // SizedBox(
            //   height: 20.h,
            // ),
            // GestureDetector(
            //   onTap: () {
            //     // Get.to(() => MyDailyMeal(
            //     //       isAnnouceMent: true,
            //     //     ));
            //     Get.to(() => RemindersScreen(
            //           isAnnouncement: true,
            //         ));
            //   },
            //   child: containerWidget(const Color(0xffE6EEFF), "Announcements",
            //       MyImgs.annoucements),
            // ),
            SizedBox(
              height: 20.h,
            ),
            GestureDetector(
              onTap: () {
                Get.to(() => RemindersScreen());
              },
              child: containerWidget(const Color(0xffE6EEFF),
                  "Meal Plan Tracker", MyImgs.annoucements),
            ),
            SizedBox(
              height: 20.h,
            ),
            GestureDetector(
              onTap: () {
                Get.to(() => MyDailyMeal(
                      isTestimonials: true,
                    ));
              },
              child: containerWidget(const Color(0xffE6EEFF),
                  "Add Testimonials", MyImgs.annoucements),
            ),
            SizedBox(
              height: 20.h,
            ),
          ],
        ),
      ),
    );
  }
}
