import 'package:fitness_zone_2/UI/dashboard_module/paste_link/paste_link.dart';
import 'package:fitness_zone_2/data/controllers/auth_controller/auth_controller.dart';
import 'package:fitness_zone_2/values/my_colors.dart';
import 'package:fitness_zone_2/widgets/custom_button.dart';
import 'package:fitness_zone_2/widgets/custom_textfield.dart';
import 'package:fitness_zone_2/widgets/toasts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../UI/dashboard_module/all_user_screens/all_users_screen.dart';
import '../UI/dashboard_module/home_screen/home_screen.dart';
import '../UI/dashboard_module/session_screen/session_screen.dart';
import '../data/controllers/home_controller/home_controller.dart';
import '../data/models/add_package/add_package_model.dart';
import '../values/constants.dart';
import '../values/my_imgs.dart';

class CustomerSupportScreen extends StatelessWidget {
  CustomerSupportScreen({Key? key}) : super(key: key);
  HomeController homeController = Get.find();

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
              height: 20.h,
            ),
            GestureDetector(
              onTap: () {
                Get.to(() => AllUsersScreen(
                      isCustomerSupport: true,
                    ));
                homeController.getAllUsersFunc(isCustomerSupport: true);
              },
              child: containerWidget(
                  const Color(0xffCCF2FE), "All Users", MyImgs.userIcon),
            ),
            SizedBox(
              height: 20.h,
            ),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(
                    text: Constants.customerSupportLink +
                        homeController.sharedPreferences
                            .getString(Constants.userId)!));
                CustomToast.successToast(msg: "Link Copied!");
              },
              child: containerWidget(
                  const Color(0xffCCF2FE), "Your Link", MyImgs.userIcon),
            ),
          ],
        ),
      ),
    );
  }
}
