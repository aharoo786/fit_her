import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/widgets/admin_home_screen.dart';
import 'package:fitness_zone_2/widgets/customer_support_screen.dart';
import 'package:fitness_zone_2/widgets/dietitian_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';

import '../../../data/controllers/auth_controller/auth_controller.dart';
import '../../../screens/paid_home_screen_v2.dart';
import '../../../screens/unpaid_home_screen_v2.dart';
import '../../../values/constants.dart';
import '../../../values/my_colors.dart';
import '../../../widgets/trainer_home_screen.dart';
import '../../../widgets/user_home_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);
  final TextEditingController controller = TextEditingController();
  final AuthController authController = Get.find();

  final HomeController homeController = Get.find();

  @override
  Widget build(BuildContext context) {
    // No AppBar — the previous zero-height PreferredSize+AppBar served no
    // visible purpose but caused the mint status-bar band on PaidHomeV2.
    // AppBars in Flutter implement `systemOverlayStyle` via their own
    // AnnotatedRegion, and this one inherited the global
    // `AppBarTheme.systemOverlayStyle` (statusBarColor: AppColors.primary
    // = #8AD167) from `lib/theme/app_theme.dart:60-64`. That outer
    // AnnotatedRegion overrode PaidHomeV2's inner transparent one.
    // Children that need their own status-bar styling now own it cleanly.
    return Scaffold(
        backgroundColor: Color(0xffF5EEEE),
        body: Obx(() {
          // Touch isPaid.value so this Obx rebuilds when slip auto-approval
          // calls `markPaid()` — without this line, mutating logInUser.status
          // wouldn't trigger a re-render and the user would stay stuck on
          // the unpaid home until the next cold start.
          final _ = authController.isPaid.value;
          if (authController.loginAsA.value == Constants.user) {
            final user = authController.logInUser;
            if (user != null && user.status == true) {
              return const PaidHomeScreenV2();
            }
            if (user != null && user.status == false) {
              return const UnpaidHomeScreenV2();
            }
            return UserHomeScreen();
          } else if (authController.loginAsA.value == Constants.dietitian) {
            return DietitianProfileScreen();
          } else if (authController.loginAsA.value == Constants.admin) {
            return AdminHomeScreen();
          } else if (authController.loginAsA.value ==
              Constants.customerSupport) {
            return CustomerSupportScreen();
          } else {
            return TrainerHomeScreen();
          }
        }));
  }

  String getDisplayString(DateTime buyingDate) {
    DateTime now = DateTime.now();

    // Normalize dates to remove the time part
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(const Duration(days: 1));
    DateTime normalizedBuyingDate =
        DateTime(buyingDate.year, buyingDate.month, buyingDate.day);

    if (normalizedBuyingDate.compareTo(today) == 0) {
      return "Today";
    } else if (normalizedBuyingDate.compareTo(yesterday) == 0) {
      return "Yesterday";
    } else {
      return DateFormat("dd/MM/yyyy").format(buyingDate);
    }
  }
}

containerWidget(Color color, String text, String image,
    {bool isShowSwitch = false, RxBool? switchValue, String? id}) {
  return Container(
    padding: EdgeInsets.all(6.h),
    decoration: BoxDecoration(
      color: MyColors.appBackground,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.4),
          blurRadius: 10.0,
          spreadRadius: 0.0,
          offset: const Offset(0.0, 0.0), // shadow direction: bottom right
        )
      ],
    ),
    child: Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8), color: color),
              child: Image.asset(
                image,
                scale: 4,
                color: Colors.black,
              ),
            ),
            SizedBox(
              width: 20.w,
            ),
            Text(
              text,
              style: TextStyle(
                  color: MyColors.textColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400),
            ),
            if (isShowSwitch) ...{
              Spacer(),
              Obx(
                () => Switch(
                    value: switchValue!.value,
                    activeColor: MyColors.buttonColor,
                    activeTrackColor: MyColors.buttonColor.withOpacity(0.5),
                    inactiveThumbColor: Colors.red,
                    inactiveTrackColor: Colors.redAccent,
                    onChanged: (value) {
                      switchValue.value = value;
                      Get.find<HomeController>()
                          .postTrialPlanDetails(id!, value);
                    }),
              )
            }
          ],
        ),
      ],
    ),
  );
}
