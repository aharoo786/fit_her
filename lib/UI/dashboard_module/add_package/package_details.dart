import 'dart:io';

import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:fitness_zone_2/widgets/custom_button.dart';
import 'package:fitness_zone_2/widgets/toasts.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../../../data/controllers/auth_controller/auth_controller.dart';
import '../../../data/models/get_user_plan/get_user_plan.dart';
import '../../../helper/permissions.dart';
import '../../../values/my_colors.dart';
import '../../../values/my_imgs.dart';
import '../../../widgets/circular_progress.dart';

class PackageDetails extends StatelessWidget {
  PackageDetails({super.key, required this.plan});
  final Plan plan;
  final HomeController homeController = Get.find();
  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(() {
        Get.back();
      }, text: "Package Details"),
      body: ListView(
        padding: EdgeInsets.all(20.h),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Package name:",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24.sp),
              ),
              Text(plan.title),
              SizedBox(
                height: 16.h,
              ),
              Text(
                "Overview",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24.sp),
              ),
              Text(plan.shortDescription),
              SizedBox(
                height: 16.h,
              ),
              Text(
                "Description",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24.sp),
              ),
              Text(plan.longDescription),
              SizedBox(
                height: 16.h,
              ),
              Text(
                "Duration",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24.sp),
              ),
              Text(plan.duration),
              SizedBox(
                height: 100.h,
              ),
              CustomButton(
                  text: "Buy Plan",
                  onPressed: () {
                    Get.find<HomeController>()
                        .getPaymentLink(plan.price.toString(), plan.id);
                  }),
              SizedBox(
                height: 20.h,
              ),
              Text(
                "Select ${plan.categoryId == 1 || plan.categoryId == 3 ? "Dietitian" : "Trainers"}",
                style: textTheme.headlineMedium!
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 10.h,
              ),
              Obx(() => homeController.getDietitianLoad.value
                  ? plan.categoryId == 3
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.symmetric(vertical: 20.h),
                              itemCount: homeController
                                  .getAllDietitianAndTrainers!
                                  .dietitions
                                  .length,
                              itemBuilder: (BuildContext context, int index) {
                                var diet = homeController
                                    .getAllDietitianAndTrainers!
                                    .dietitions[index];

                                return GestureDetector(
                                  onTap: () {
                                    homeController.selectedDietId.value =
                                        diet.id;
                                  },
                                  child: Obx(
                                    () => Container(
                                      width: 300.w,
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                              color: homeController
                                                          .selectedDietId
                                                          .value ==
                                                      diet.id
                                                  ? MyColors.buttonColor
                                                  : Colors.white),
                                          boxShadow: [
                                            BoxShadow(
                                                offset: const Offset(0, 2),
                                                blurRadius: 4,
                                                color: Colors.black
                                                    .withOpacity(0.1))
                                          ]),
                                      child: Row(children: [
                                        SizedBox(
                                          width: 70.w,
                                          child: Image.asset(MyImgs.logo),
                                        ),
                                        SizedBox(
                                          width: 10.w,
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${diet.firstName} ${diet.lastName}",
                                                style: textTheme.headlineSmall!
                                                    .copyWith(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                diet.email,
                                                style: textTheme.bodySmall!
                                                    .copyWith(),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        )
                                      ]),
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return SizedBox(
                                  height: 10.h,
                                );
                              },
                            ),
                            Text(
                              "Select Trainers",
                              style: textTheme.headlineMedium!
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.symmetric(vertical: 20.h),
                              itemCount: homeController
                                  .getAllDietitianAndTrainers!.trainers.length,
                              itemBuilder: (BuildContext context, int index) {
                                var diet = homeController
                                    .getAllDietitianAndTrainers!
                                    .trainers[index];

                                return GestureDetector(
                                  onTap: () {
                                    homeController.selectedTrainerId.value =
                                        diet.id;
                                  },
                                  child: Obx(
                                    () => Container(
                                      width: 300.w,
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                              color: homeController
                                                          .selectedTrainerId
                                                          .value ==
                                                      diet.id
                                                  ? MyColors.buttonColor
                                                  : Colors.white),
                                          boxShadow: [
                                            BoxShadow(
                                                offset: const Offset(0, 2),
                                                blurRadius: 4,
                                                color: Colors.black
                                                    .withOpacity(0.1))
                                          ]),
                                      child: Row(children: [
                                        SizedBox(
                                          width: 70.w,
                                          child: Image.asset(MyImgs.logo),
                                        ),
                                        SizedBox(
                                          width: 10.w,
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${diet.firstName} ${diet.lastName}",
                                                style: textTheme.headlineSmall!
                                                    .copyWith(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                diet.email,
                                                style: textTheme.bodySmall!
                                                    .copyWith(),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        )
                                      ]),
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return SizedBox(
                                  height: 10.h,
                                );
                              },
                            )
                          ],
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.symmetric(vertical: 20.h),
                          itemCount: plan.categoryId == 1
                              ? homeController
                                  .getAllDietitianAndTrainers!.dietitions.length
                              : homeController
                                  .getAllDietitianAndTrainers!.trainers.length,
                          itemBuilder: (BuildContext context, int index) {
                            var diet = plan.categoryId == 1
                                ? homeController.getAllDietitianAndTrainers!
                                    .dietitions[index]
                                : homeController.getAllDietitianAndTrainers!
                                    .trainers[index];

                            return GestureDetector(
                              onTap: () {
                                if (plan.categoryId == 1) {
                                  homeController.selectedDietId.value = diet.id;
                                } else {
                                  homeController.selectedTrainerId.value =
                                      diet.id;
                                }
                              },
                              child: Obx(
                                () => Container(
                                  width: 300.w,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                          color: (plan.categoryId == 1
                                                      ? homeController
                                                          .selectedDietId.value
                                                      : homeController
                                                          .selectedTrainerId) ==
                                                  diet.id
                                              ? MyColors.buttonColor
                                              : Colors.white),
                                      boxShadow: [
                                        BoxShadow(
                                            offset: const Offset(0, 2),
                                            blurRadius: 4,
                                            color:
                                                Colors.black.withOpacity(0.1))
                                      ]),
                                  child: Row(children: [
                                    SizedBox(
                                      width: 70.w,
                                      child: Image.asset(MyImgs.logo),
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${diet.firstName} ${diet.lastName}",
                                            style: textTheme.headlineSmall!
                                                .copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            diet.email,
                                            style:
                                                textTheme.bodySmall!.copyWith(),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    )
                                  ]),
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return SizedBox(
                              height: 10.h,
                            );
                          },
                        )
                  : const CircularProgress()),
              SizedBox(
                height: 20.h,
              ),
              GetBuilder<HomeController>(builder: (cont) {
                return GestureDetector(
                  onTap: () {
                    selectMediaBottomSheet(
                        _getFromGallery, _getFromCamera, context);
                  },
                  child: homeController.planPicture != null
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
                                  File(homeController.planPicture!.path),
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
                );
              }),
              SizedBox(
                height: 20.h,
              ),
              CustomButton(
                  text: "Upload Payment Picture",
                  onPressed: () {
                    if (homeController.planPicture == null) {
                      CustomToast.failToast(msg: "Please select image");
                    } else {
                      homeController.addPlanBuyImage(
                          plan.id.toString(), plan.categoryId);
                    }
                  })
            ],
          ),
        ],
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
              "${dir1.absolute.path}/dp${Get.find<AuthController>().i}.jpg";
          var compressedFile1 = await FlutterImageCompress.compressAndGetFile(
              imagePath, targetPath1,
              quality: 60);
          HomeController homeController = Get.find();

          homeController.planPicture = XFile(compressedFile1!.path);
          homeController.update();

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
          HomeController homeController = Get.find();
          homeController.planPicture = XFile(compressedFile1!.path);
          homeController.update();

          Get.find<AuthController>().i++;
          Get.find<AuthController>().update();
        }
      } else {
        print(value);
      }
    });
  }
}
