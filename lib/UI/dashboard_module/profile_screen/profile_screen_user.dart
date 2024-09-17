import 'package:fitness_zone_2/data/controllers/auth_controller/auth_controller.dart';
import 'package:fitness_zone_2/values/my_colors.dart';
import 'package:fitness_zone_2/values/my_imgs.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:fitness_zone_2/widgets/custom_button.dart';
import 'package:fitness_zone_2/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../helper/get_di.dart';
import '../../../values/constants.dart';
import '../../auth_module/choose_any_one/choose_any_one.dart';

class ProfileScreenUser extends StatelessWidget {
  ProfileScreenUser({super.key});
  AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: MyColors.primaryGradient2,
      appBar: HelpingWidgets().appBarWidget(
        () {
          Get.back();
        },
        backGroundColor: MyColors.primaryGradient2,
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              const SizedBox(height: 50),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(25),
                        topLeft: Radius.circular(25)),
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 80),
                      CustomTextField(
                        text: "First Name",
                        controller: authController.editFirstName,
                        length: 1000,
                        Readonly: true,
                        keyboardType: TextInputType.text,
                        inputFormatters:
                            FilteringTextInputFormatter.singleLineFormatter,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        text: "Last Name",
                        length: 1000,
                        Readonly: true,
                        controller: authController.editLastName,
                        keyboardType: TextInputType.text,
                        inputFormatters:
                            FilteringTextInputFormatter.singleLineFormatter,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        text: "Email",
                        length: 1000,
                        Readonly: true,
                        controller: authController.editEmail,
                        keyboardType: TextInputType.text,
                        inputFormatters:
                            FilteringTextInputFormatter.singleLineFormatter,
                      ),
                      Spacer(),
                      CustomButton(
                        text: "Logout",
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(
                                    "Log Out",
                                    style: textTheme.headlineSmall,
                                  ),
                                  content: Text(
                                    "Are you sure you want to logout?",
                                    style: textTheme.bodyMedium,
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Get.back();
                                        },
                                        child: Text(
                                          "Cancel",
                                          style: textTheme.bodyMedium,
                                        )),
                                    TextButton(
                                        onPressed: () async {
                                          // Get.find<AuthController>().logout();
                                          Get.offAll(() => ChooseAnyOne());
                                          await init();
                                          authController.loginAsA.value =
                                              Constants.user;
                                        },
                                        child: Text(
                                          "Logout",
                                          style: textTheme.bodyMedium,
                                        )),
                                  ],
                                );
                              });
                        },
                        fontSize: 16,
                      ),
                      const SizedBox(height: 10),
                      CustomButton(
                        text: "Delete Account",
                        onPressed: () {
                          Get.defaultDialog(
                              title: "Alert",
                              content: const Text(
                                  "Do you really want to delete your Account"),
                              onConfirm: () async {
                                Get.back();

                                Get.find<AuthController>().deleteUser();
                              },
                              onCancel: () async {});
                        },
                        fontSize: 16,
                        borderColor: MyColors.primaryGradient2,
                        color: Colors.white,
                        textColor: MyColors.primaryGradient2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Positioned(
          //   top: 0,
          //   // left: MediaQuery.of(context).size.width/2.7,
          //   child: CircleAvatar(
          //     radius: 60,
          //     backgroundImage: AssetImage(
          //         MyImgs.userProfileIcon), // Replace with your image asset
          //     child: Align(
          //       alignment: Alignment.bottomRight,
          //       child: Container(
          //         padding: EdgeInsets.all(4),
          //         decoration: BoxDecoration(
          //           color: Colors.black,
          //           shape: BoxShape.circle,
          //         ),
          //         child: Icon(
          //           Icons.edit,
          //           color: Colors.white,
          //           size: 20,
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
