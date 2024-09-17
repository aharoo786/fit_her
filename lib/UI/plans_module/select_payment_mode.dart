import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:fitness_zone_2/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../../data/controllers/auth_controller/auth_controller.dart';
import '../../data/controllers/home_controller/home_controller.dart';
import '../../helper/permissions.dart';
import '../../values/my_colors.dart';
import '../../values/my_imgs.dart';
import '../../widgets/toasts.dart';

class SelectPaymentMode extends StatelessWidget {
  SelectPaymentMode({super.key,required this.planId,required this.planCategory});
  HomeController homeController = Get.find();
  String planId;
  int planCategory;


  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(() {
        Get.back();
      }, text: "Select Payment Mode"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 50,
            ),
            // Center(
            //     child: CustomButton(
            //         text: "Debit/Credit Card",
            //         onPressed: () {
            //           homeController.makePayment(planId);
            //         })),
            // const SizedBox(
            //   height: 50,
            // ),
            // const Row(
            //   children: [
            //     Expanded(
            //       child: Divider(
            //         height: 1.5,
            //         color: Colors.black,
            //       ),
            //     ),
            //     SizedBox(
            //       width: 10,
            //     ),
            //     Text("Or"),
            //     SizedBox(
            //       width: 10,
            //     ),
            //     Expanded(
            //         child: Divider(
            //       height: 1.5,
            //       color: Colors.black,
            //     ))
            //   ],
            // ),
            const SizedBox(
              height: 50,
            ),
            Center(
              child: GetBuilder<HomeController>(builder: (cont) {
                return GestureDetector(
                  onTap: () {
                    selectMediaBottomSheet(
                        _getFromGallery, _getFromCamera, context);
                  },
                  child: homeController.planPicture != null
                      ? Container(
                          alignment: Alignment.center,
                          height: 100,
                          width: 100,
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
                          height: 100,
                          child: SvgPicture.asset(
                            MyImgs.upload,
                          ),
                        ),
                );
              }),
            ),
            SizedBox(
              width: 190,
              child: Text(
                "You can upload the payment slip of your subscribed plan here.",
                style: textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            Spacer(),
            CustomButton(
                text: "Upload",
                onPressed: () {
                  if (homeController.planPicture == null) {
                    CustomToast.failToast(msg: "Please select image");
                  } else {
                    homeController.addPlanBuyImage(
                        planId, planCategory);
                  }
                }),
            SizedBox(
              height: 20,
            ),
          ],
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
