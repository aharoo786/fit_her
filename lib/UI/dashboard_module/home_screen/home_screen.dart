import 'package:fitness_zone_2/UI/chat/group_chat_room.dart';
import 'package:fitness_zone_2/UI/diet_screen/add_user_diet.dart';
import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/widgets/admin_home_screen.dart';
import 'package:fitness_zone_2/widgets/all_plans_screen.dart';
import 'package:fitness_zone_2/widgets/circular_progress.dart';
import 'package:fitness_zone_2/widgets/customer_support_screen.dart';
import 'package:fitness_zone_2/widgets/dietitian_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../data/controllers/auth_controller/auth_controller.dart';
import '../../../values/constants.dart';
import '../../../values/my_colors.dart';
import '../../../values/my_imgs.dart';
import '../../../widgets/trainer_home_screen.dart';
import '../../../widgets/custom_textfield.dart';
import '../../../widgets/toasts.dart';
import '../../../widgets/user_home_screen.dart';
import '../../chat/widgets/chat_room.dart';
import '../paste_link/paste_link.dart';
import '../session_screen/session_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);
  final TextEditingController controller = TextEditingController();
  final AuthController authController = Get.find();

  final HomeController homeController = Get.find();

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
        backgroundColor: Color(0xffF5EEEE),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
        body: Obx(() {
          if (authController.loginAsA.value == Constants.user) {
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
