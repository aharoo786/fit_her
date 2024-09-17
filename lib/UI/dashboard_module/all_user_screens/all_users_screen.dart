import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:flutter/material.dart';

import '../../../values/constants.dart';
import '../../../values/my_colors.dart';
import '../../../values/my_imgs.dart';
import '../../../widgets/app_bar_widget.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../widgets/circular_progress.dart';
import '../../../widgets/custom_button.dart';
import '../../auth_module/edit_user/edit_user.dart';
import '../add_new_user/add_new_user.dart';

class AllUsersScreen extends StatelessWidget {
  AllUsersScreen({Key? key}) : super(key: key);
  final HomeController homeController = Get.find();
  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return WillPopScope(
      onWillPop: () {
        homeController.clearyControllers();
        return Future.value(true);
      },
      child: Scaffold(
        appBar: HelpingWidgets().appBarWidget(() {
          homeController.clearyControllers();
          Get.back();
        }, text: "All Users"),
        body: Column(
          children: [
            Obx(() => homeController.getAllUsersLoad.value
                ? Expanded(
                    child: ListView.separated(
                    itemCount: homeController.getAllUsers!.users.length,
                    padding: EdgeInsets.all(20.h),
                    itemBuilder: (BuildContext context, int index) {
                      var user = homeController.getAllUsers!.users[index];
                      return Row(children: [
                        Container(
                          height: 32.h,
                          width: 32.h,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: Colors.black),
                          child: Image.asset(
                            MyImgs.userIcon,
                            scale: 4,
                          ),
                        ),
                        SizedBox(
                          width: 15.w,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${user.user.firstName} ${user.user.lastName}",
                                style: textTheme.bodyMedium!.copyWith(
                                    color: MyColors.textColor,
                                    fontWeight: FontWeight.w500),
                              ),
                              Text(
                                user.user.email,
                                style: textTheme.bodySmall!.copyWith(
                                    color: MyColors.textColor,
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                homeController.firstNameController.text =
                                    user.user.firstName;
                                homeController.lastNameController.text =
                                    user.user.lastName;
                                homeController.emailController.text =
                                    user.user.email;
                                homeController.phoneController.text =
                                    user.user.phone;
                                homeController.passwordController.text = "";
                                if (user.plans != null) {
                                  homeController.dateExtendController.text =
                                      "${user.plans!.expireDate.difference(DateTime.now()).inDays} days";
                                }

                                Get.to(() => EditUser(
                                      user: user,
                                    ));
                              },
                              child: Container(
                                height: 32.h,
                                width: 32.h,
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xffEBEBEB)),
                                child: const Icon(Icons.edit),
                              ),
                            ),
                            SizedBox(
                              width: 12.w,
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.defaultDialog(
                                    title: "Alert",
                                    content: const Text(
                                        "Do you really want to delete that user"),
                                    onConfirm: () async {
                                      Get.back();

                                      // Get.find<AuthController>()
                                      //     .deleteUser(doc[Constants.userId]);
                                    },
                                    onCancel: () async {});
                              },
                              child: Container(
                                height: 32.h,
                                width: 32.h,
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xffFFDAD3)),
                                child: Icon(Icons.delete),
                              ),
                            ),
                          ],
                        ),
                      ]);
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(
                        height: 20.h,
                      );
                    },
                  ))
                : const CircularProgress())
          ],
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomButton(
                  text: "Add User",
                  onPressed: () async {
                    Get.to(() => AddNewUser());
                    Get.find<HomeController>().getPlans();
                    // Get.find<HomeController>().getAllDietitian();
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
