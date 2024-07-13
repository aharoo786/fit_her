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

class MyDailyMeal extends StatelessWidget {
  MyDailyMeal(
      {Key? key, this.isAnnouceMent = false, this.isTestimonials = false})
      : super(key: key);
  final bool isAnnouceMent;
  final bool isTestimonials;
  final AuthController authController = Get.find();
  final HomeController homeController = Get.find();
  final TextEditingController breakFast = TextEditingController();
  final TextEditingController lunch = TextEditingController();
  final TextEditingController dinner = TextEditingController();

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
          },
              text: isAnnouceMent
                  ? "FeedBack"
                  : isTestimonials
                      ? "Add Testimonials"
                      : "Daily Report"),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: isTestimonials
                ? GetBuilder<HomeController>(builder: (cont) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 20.h,
                        ),
                        GestureDetector(
                          onTap: () {
                            selectMediaBottomSheet(
                                _getFromGallery, _getFromCamera, context);
                          },
                          child: homeController.testiPicture != null
                              ? Container(
                                  alignment: Alignment.center,
                                  height: 100.h,
                                  width: 100.h,
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
                                          File(homeController
                                              .testiPicture!.path),
                                        ),
                                      )),
                                )
                              : SizedBox(
                                  height: 100.h,
                                  child: Image.asset(
                                    MyImgs.chooseImage,
                                    scale: 2,
                                  ),
                                ),
                        )
                      ],
                    );
                  })
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 50.h,
                      ),
                      CustomTextField(
                        text: isAnnouceMent ? "FeedBack" : "BreakFast",
                        length: 500,
                        controller: breakFast,
                        validator: (value) =>
                            Validators.firstNameValidation(value!.toString()),
                        keyboardType: TextInputType.emailAddress,
                        inputFormatters:
                            FilteringTextInputFormatter.singleLineFormatter,
                      ),
                      SizedBox(
                        height: 16.h,
                      ),
                      isAnnouceMent
                          ? SizedBox()
                          : CustomTextField(
                              text: "Lunch",
                              controller: lunch,
                              length: 500,
                              validator: (value) =>
                                  Validators.emailValidator(value!.toString()),
                              keyboardType: TextInputType.emailAddress,
                              inputFormatters: FilteringTextInputFormatter
                                  .singleLineFormatter,
                            ),
                      isAnnouceMent
                          ? SizedBox()
                          : SizedBox(
                              height: 16.h,
                            ),
                      isAnnouceMent
                          ? SizedBox()
                          : CustomTextField(
                              text: "Dinner",
                              length: 500,
                              controller: dinner,
                              validator: (value) =>
                                  Validators.emailValidator(value!.toString()),
                              keyboardType: TextInputType.emailAddress,
                              inputFormatters: FilteringTextInputFormatter
                                  .singleLineFormatter,
                            ),
                      SizedBox(
                        height: 16.h,
                      ),
                      Expanded(
                        child: GetBuilder<AuthController>(builder: (context) {
                          return GridView.builder(
                            physics: BouncingScrollPhysics(),
                            padding: EdgeInsets.all(8),
                            // direction: Axis.horizontal,
                            // alignment: WrapAlignment.spaceBetween,
                            // spacing: 7.0,
                            // runSpacing: 11.0,
                            // children: List<Widget>.generate(
                            //     _authController.farmImages.length, (int index) {
                            itemBuilder: (BuildContext context, int index) {
                              return index > 0
                                  ? GestureDetector(
                                      onTap: () {
                                        XFile file =
                                            authController.mealImages[index];
                                        authController.mealImages[index] =
                                            authController.mealImages[0];
                                        authController.mealImages[0] = file;
                                        authController.update();
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            // / borderRadius: BorderRadius.circular(13),
                                            color: MyColors.bodyBackground,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.4),
                                                blurRadius: 2.0,
                                                spreadRadius: 0.0,
                                                offset: const Offset(0.0,
                                                    2.0), // shadow direction: bottom right
                                              )
                                            ],
                                            image: authController
                                                    .mealImages.isEmpty
                                                ? null
                                                : DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: FileImage(
                                                      File(authController
                                                          .mealImages[index - 1]
                                                          .path),
                                                    ),
                                                  )),
                                      ),
                                    )
                                  : GestureDetector(
                                      onTap: () {
                                        selectMediaBottomSheet(_getFromGallery,
                                            _getFromCamera, context);
                                      },
                                      child: Image.asset(
                                        MyImgs.chooseImage,
                                        scale: 2,
                                      ));
                            },
                            gridDelegate:
                                SliverGridDelegateWithMaxCrossAxisExtent(
                              // crossAxisCount: 4,
                              crossAxisSpacing: 12.0.w,
                              childAspectRatio: 1,
                              mainAxisSpacing: 12.0.h,
                              maxCrossAxisExtent: 100,
                            ),
                            itemCount: authController.mealImages.isEmpty
                                ? 1
                                : authController.mealImages.length + 1,

                            // })
                          );
                        }),
                      ),
                    ],
                  ),
          ),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomButton(
                    text: "Share".tr,
                    onPressed: () async {
                      if (isAnnouceMent) {
                        if (breakFast.text.isEmpty) {
                          CustomToast.failToast(
                              msg: "Please provide all information");
                        } else {
                          Share.shareXFiles(authController.mealImages,
                              text: "Announcement: ${breakFast.text}");
                        }
                      } else if (isTestimonials) {
                        if (homeController.testiPicture == null) {
                          CustomToast.failToast(msg: "Please provide image");
                        } else {
                          homeController.addTestimonials();

                        }
                      } else {
                        if (breakFast.text.isEmpty ||
                            lunch.text.isEmpty ||
                            dinner.text.isEmpty) {
                          CustomToast.failToast(
                              msg: "Please provide all information");
                        } else if (authController.mealImages.isEmpty) {
                          CustomToast.failToast(
                              msg: "Please provide at least one image");
                        } else {
                          Share.shareXFiles(authController.mealImages,
                              text:
                                  "BreakFast: ${breakFast.text}\nLunch: ${lunch.text}\nDinner: ${dinner.text}");
                        }
                      }
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
          if (isTestimonials) {
            homeController.testiPicture = XFile(compressedFile1.path);
            homeController.update();
          } else {
            Get.find<AuthController>()
                .mealImages
                .add(XFile(compressedFile1.path));
          }

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
          if (isTestimonials) {
            homeController.testiPicture = XFile(compressedFile1.path);
            homeController.update();
          } else {
            Get.find<AuthController>()
                .mealImages
                .add(XFile(compressedFile1.path));
          }

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
    breakFast.clear();
    lunch.clear();
    dinner.clear();
    authController.mealImages.clear();
    homeController.testiPicture = null;
  }
}
