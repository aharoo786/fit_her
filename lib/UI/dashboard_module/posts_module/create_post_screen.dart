import 'dart:io';
import 'package:fitness_zone_2/values/my_colors.dart';
import 'package:fitness_zone_2/values/my_imgs.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/controllers/auth_controller/auth_controller.dart';
import '../../../data/controllers/home_controller/home_controller.dart';
import '../../../data/controllers/post_controller.dart';
import '../../../helper/permissions.dart';
import '../../../widgets/toasts.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final controller = Get.find<PostController>();
  TextEditingController content = TextEditingController();
  @override
  void initState() {
    controller.postImageFile = null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.grey100,
      appBar: HelpingWidgets().appBarWidget(() {
        Get.back();
      }, text: "Create Post"),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Text input card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextFormField(
                    controller: content,
                    maxLength: 1000,
                    minLines: 3,
                    style: TextStyle(
                      color: MyColors.textColor,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                    maxLines: 6,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: "What's on your mind? Share your thoughts...",
                      hintStyle: TextStyle(
                        color: MyColors.hintText,
                        fontSize: 15.sp,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 16.h,
                      ),
                    ),
                  ),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: content,
                    builder: (_, value, __) => Padding(
                      padding: EdgeInsets.only(right: 16.w, bottom: 8.h),
                      child: Text(
                        "${value.text.length}/1000",
                        style: TextStyle(
                          color: MyColors.grey,
                          fontSize: 11.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            // Image section
            GetBuilder<PostController>(builder: (ctrl) {
              if (ctrl.postImageFile != null) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        Image.file(ctrl.postImageFile!, height: 280.h, width: double.infinity, fit: BoxFit.cover),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: GestureDetector(
                            onTap: () {
                              ctrl.postImageFile = null;
                              ctrl.update();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return GestureDetector(
                  onTap: () => selectMediaBottomSheet(_getFromGallery, _getFromCamera, context),
                  child: Container(
                    height: 180.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: MyColors.buttonColor.withOpacity(0.4),
                        width: 2,
                        strokeAlign: BorderSide.strokeAlignInside,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: MyColors.planColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 40.sp,
                            color: MyColors.buttonColor,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          "Add a photo",
                          style: TextStyle(
                            color: MyColors.textColor,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "Tap to choose from camera or gallery",
                          style: TextStyle(
                            color: MyColors.hintText,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            }),
            SizedBox(height: 32.h),
            // Publish button
            Obx(() {
              final isLoading = !controller.createPostLoad.value;
              return SizedBox(
                width: double.infinity,
                height: 50.h,
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: MyColors.primaryGradient1,
                        ),
                      )
                    : ElevatedButton(
                        onPressed: () async {
                          if (!Get.find<HomeController>().hasActivePackage) {
                            CustomToast.failToast(msg: "You need an active package to create posts. Please subscribe to a plan first.");
                            return;
                          }
                          if (content.text.isEmpty && controller.postImageFile == null) {
                            CustomToast.failToast(msg: "You need to add content and image to create a post.");

                            return;
                          }

                          bool postCreated = await controller.createPost(text: content.text);
                          if (postCreated) {
                            HelpingWidgets.showCustomDialog(context, () {
                              Get.back();
                              Get.back();
                            }, "Wait for Approval!", "Your post will be displayed once approved by Admin.", MyImgs.doneTick, buttonText: "Got it!");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MyColors.buttonColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          textStyle: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text("Publish"),
                      ),
              );
            }),
          ],
        ),
      ),
    );
  }

  selectMediaBottomSheet(Function gallery, Function camera, BuildContext context) {
    Get.bottomSheet(
      Container(
        height: 200.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Add photo from",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: MyColors.textColor,
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMediaOption(
                  icon: Icons.photo_camera,
                  label: "Camera",
                  onTap: () {
                    Get.back();
                    camera(context);
                  },
                ),
                _buildMediaOption(
                  icon: Icons.photo_library_outlined,
                  label: "Gallery",
                  onTap: () {
                    Get.back();
                    gallery(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildMediaOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              color: MyColors.planColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: MyColors.buttonColor.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, size: 28.sp, color: MyColors.buttonColor),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: MyColors.textColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Get from Camera
  _getFromCamera(BuildContext context) async {
    PermissionOfPhotos().getFromCamera(context).then((value) async {
      if (value) {
        final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
        if (pickedFile != null) {
          var imagePath = pickedFile.path;
          final dir1 = Directory.systemTemp;
          final targetPath1 = "${dir1.absolute.path}/dp${Get.find<AuthController>().i}.jpg";
          var compressedFile1 = await FlutterImageCompress.compressAndGetFile(imagePath, targetPath1, quality: 60);
          controller.postImageFile = File(compressedFile1!.path);
          controller.update();
          Get.find<AuthController>().i++;
        }
      } else {
        print(value);
      }
    });
  }

  _getFromGallery(BuildContext context) async {
    PermissionOfPhotos().getFromGallery(context).then((value) async {
      if (value) {
        final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          var imagePath = pickedFile.path;
          final dir1 = Directory.systemTemp;
          final targetPath1 = "${dir1.absolute.path}/dp${Get.find<AuthController>().i}.jpg";
          var compressedFile1 = await FlutterImageCompress.compressAndGetFile(imagePath, targetPath1, quality: 60);
          controller.postImageFile = File(compressedFile1!.path);
          controller.update();
          Get.find<AuthController>().i++;
        }
      } else {
        print(value);
      }
    });
  }
}
