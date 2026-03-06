import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:fitness_zone_2/UI/auth_module/sign_up_screen/sign_up_screen_questions.dart';
import 'package:fitness_zone_2/data/controllers/auth_controller/auth_controller.dart';
import 'package:fitness_zone_2/values/my_colors.dart';
import 'package:fitness_zone_2/values/my_imgs.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:fitness_zone_2/widgets/custom_button.dart';
import 'package:fitness_zone_2/widgets/custom_textfield.dart';

class ProfileScreenUser extends StatelessWidget {
  ProfileScreenUser({super.key});

  final AuthController authController = Get.find();

  Widget _buildReadOnlyTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 4),
        CustomTextField(
          text: label,
          controller: controller,
          length: 1000,
          Readonly: true,
          keyboardType: keyboardType,
          inputFormatters: FilteringTextInputFormatter.singleLineFormatter,
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, TextTheme textTheme) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Log Out", style: textTheme.headlineSmall),
        content: Text("Are you sure you want to logout?",
            style: textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel", style: textTheme.bodyMedium),
          ),
          TextButton(
            onPressed: () => authController.logout(),
            child: Text("Logout", style: textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    Get.defaultDialog(
      title: "Alert",
      content: const Text("Do you really want to delete your account?"),
      onConfirm: () {
        Get.back();
        authController.deleteUser();
      },
      onCancel: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: MyColors.primaryGradient2,
      appBar: HelpingWidgets().appBarWidget(
        () => Get.back(),
        backGroundColor: MyColors.primaryGradient2,
      ),
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              children: [
                const SizedBox(height: 50),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(25)),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          _buildReadOnlyTextField(
                            label: "First Name",
                            controller: authController.editFirstName,
                          ),
                          const SizedBox(height: 20),
                          _buildReadOnlyTextField(
                            label: "Last Name",
                            controller: authController.editLastName,
                          ),
                          const SizedBox(height: 20),
                          _buildReadOnlyTextField(
                            label: "Email",
                            controller: authController.editEmail,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 20),
                          _buildReadOnlyTextField(
                            label: "Age",
                            controller: authController.editAge,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 20),
                          _buildReadOnlyTextField(
                            label: "Height",
                            controller: authController.editHeight,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 20),
                          _buildReadOnlyTextField(
                            label: "Weight",
                            controller: authController.editWeight,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 20),
                          _buildReadOnlyTextField(
                            label: "BMI Result",
                            controller: authController.editBmi,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 40),
                          CustomButton(
                            text: "Update Details",
                            onPressed: () =>
                                Get.to(() => SignUpScreenQuestions()),
                            fontSize: 16,
                          ),
                          const SizedBox(height: 10),
                          CustomButton(
                            text: "Logout",
                            onPressed: () =>
                                _showLogoutDialog(context, textTheme),
                            fontSize: 16,
                          ),
                          const SizedBox(height: 10),
                          CustomButton(
                            text: "Delete Account",
                            onPressed: _showDeleteDialog,
                            fontSize: 16,
                            borderColor: MyColors.primaryGradient2,
                            color: Colors.white,
                            textColor: MyColors.primaryGradient2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage(MyImgs.userProfileIcon),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.edit, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
