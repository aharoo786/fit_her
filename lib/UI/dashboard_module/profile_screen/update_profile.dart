import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../../../data/controllers/auth_controller/auth_controller.dart';
import '../../../helper/permissions.dart';
import '../../../helper/validators.dart';
import '../../../values/my_colors.dart';
import '../../../values/my_imgs.dart';
import '../../../widgets/app_bar_widget.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfield.dart';
import '../../../widgets/toasts.dart';

class UpdateProfile extends StatelessWidget {
  UpdateProfile({Key? key}) : super(key: key);
  final AuthController authController = Get.find();
  final HomeController homeController = Get.find();
  final TextEditingController speciality = TextEditingController();
  final TextEditingController totalPatients = TextEditingController();
  final TextEditingController experience = TextEditingController();
  final TextEditingController description = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: WillPopScope(
        onWillPop: () {
          onBack();
          return Future.value(true);
        },
        child: Scaffold(
          appBar: HelpingWidgets().appBarWidget(() {
            onBack();
            Get.back();
          }, text: "Update Speciality"),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 50.h,
                  ),
                  CustomTextField(
                    text: "Speciality",
                    length: 500,
                    controller: speciality,
                    validator: (value) =>
                        Validators.firstNameValidation(value!.toString()),
                    keyboardType: TextInputType.emailAddress,
                    inputFormatters:
                        FilteringTextInputFormatter.singleLineFormatter,
                  ),
                  SizedBox(
                    height: 16.h,
                  ),
                  CustomTextField(
                    text: "Total Patients",
                    controller: totalPatients,
                    length: 500,
                    validator: (value) =>
                        Validators.emailValidator(value!.toString()),
                    keyboardType: TextInputType.number,
                    inputFormatters: FilteringTextInputFormatter.digitsOnly,
                  ),
                  SizedBox(
                    height: 16.h,
                  ),
                  CustomTextField(
                    text: "Experience",
                    length: 500,
                    controller: experience,
                    validator: (value) =>
                        Validators.emailValidator(value!.toString()),
                    keyboardType: TextInputType.number,
                    inputFormatters: FilteringTextInputFormatter.digitsOnly,
                  ),
                  SizedBox(
                    height: 16.h,
                  ),
                  CustomTextField(
                    text: "Description",
                    length: 500,
                    controller: description,
                    validator: (value) =>
                        Validators.emailValidator(value!.toString()),
                    keyboardType: TextInputType.text,
                    inputFormatters:
                        FilteringTextInputFormatter.singleLineFormatter,
                  ),
                  SizedBox(
                    height: 16.h,
                  ),
                  GetBuilder<HomeController>(builder: (conte) {
                    return homeController.profilePicture != null
                        ? GestureDetector(
                            onTap: () {
                              selectMediaBottomSheet(
                                  _getFromGallery, _getFromCamera, context);
                            },
                            child: Container(
                              alignment: Alignment.center,
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(
                                  // / borderRadius: BorderRadius.circular(13),
              
                                  color: MyColors.bodyBackground,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.4),
                                      blurRadius: 2.0,
                                      spreadRadius: 0.0,
                                      offset: const Offset(0.0,
                                          2.0), // shadow direction: bottom right
                                    )
                                  ],
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: FileImage(
                                      File(homeController.profilePicture!.path),
                                    ),
                                  )),
                            ),
                          )
                        : GestureDetector(
                            onTap: () {
                              selectMediaBottomSheet(
                                  _getFromGallery, _getFromCamera, context);
                            },
                            child: Image.asset(
                              MyImgs.chooseImage,
                              scale: 4,
                            ));
                  })
                ],
              ),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomButton(
                    text: "Update Profile".tr,
                    onPressed: () async {
                      if (speciality.text.isEmpty ||
                          totalPatients.text.isEmpty ||
                          experience.text.isEmpty ||
                          description.text.isEmpty ||
                          homeController.profilePicture == null) {
                        CustomToast.failToast(
                            msg: "Please provide all information");
                        return;
                      }

                      await homeController.updateUserProfile(
                          speciality.text,
                          totalPatients.text,
                          experience.text,
                          description.text);
                      // onBack();
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  selectMediaBottomSheet(
      Function gallery, Function camera, BuildContext context) {
    Get.bottomSheet(Container(
      height: 150,
      color: MyColors.bodyBackground,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.photo_camera,
                  size: 30,
                ),
                onPressed: () {
                  Get.back();
                  camera(context);
                },
              ),
              Text("From Camera".tr)
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.photo,
                  size: 30,
                ),
                onPressed: () {
                  Get.back();
                  gallery(context);
                },
              ),
              Text("From Gallery".tr)
            ],
          ),
        ],
      ),
    ));
  }

  /// Get from Camera
  _getFromCamera(BuildContext context) async {
    PermissionOfPhotos().getFromCamera(context).then((value) async {
      if (value) {
        final pickedFile =
            await ImagePicker().pickImage(source: ImageSource.camera);
        if (pickedFile != null) {
          print("Picked File: ${pickedFile.path}");
          var imagePath = pickedFile.path;
          // Get.find<AuthController>().image = File(imagePath);
          // Get.find<AuthController>().update();

          var imageName = imagePath.split("/").last;
          print("Image Name: $imageName");
          final dir1 = Directory.systemTemp;
          final targetPath1 =
              dir1.absolute.path + "/dp${Get.find<AuthController>().i}.jpg";
          var compressedFile1 = await FlutterImageCompress.compressAndGetFile(
              imagePath, targetPath1,
              quality: 60);
          print("compressedFile File: ${compressedFile1!.path}");

          homeController.profilePicture = XFile(compressedFile1.path);
          homeController.update();

          Get.log("value of i=${Get.find<AuthController>().i}");
          Get.find<AuthController>().i++;
          Get.find<AuthController>().update();
        }
      } else {
        print(value);
      }
    });
  }

  _getFromGallery(BuildContext context) async {
    PermissionOfPhotos().getFromGallery(context).then((value) async {
      if (value) {
        final pickedFile =
            await ImagePicker().pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          print("Picked File: ${pickedFile.path}");
          var imagePath = pickedFile.path;
          // Get.find<AuthController>().image = File(imagePath);
          // Get.find<AuthController>().update();

          var imageName = imagePath.split("/").last;
          print("Image Name: $imageName");
          final dir1 = Directory.systemTemp;
          final targetPath1 =
              "${dir1.absolute.path}/dp${Get.find<AuthController>().i}.jpg";
          var compressedFile1 = await FlutterImageCompress.compressAndGetFile(
              imagePath, targetPath1,
              quality: 60);
          print("compressedFile File: ${compressedFile1!.path}");

          homeController.profilePicture = XFile(compressedFile1.path);
          homeController.update();

          Get.log("value of i=${Get.find<AuthController>().i}");
          Get.find<AuthController>().i++;
          Get.find<AuthController>().update();
        }
      } else {
        print(value);
      }
    });
  }

  onBack() {
    speciality.clear();
    experience.clear();
    description.clear();
    totalPatients.clear();
    homeController.profilePicture = null;
  }
}
