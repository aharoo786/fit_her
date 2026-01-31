import 'dart:io';
import 'package:fitness_zone_2/values/my_colors.dart';
import 'package:fitness_zone_2/values/my_imgs.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:fitness_zone_2/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/controllers/auth_controller/auth_controller.dart';
import '../../../data/controllers/post_controller.dart';
import '../../../helper/permissions.dart';

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
      appBar: HelpingWidgets().appBarWidget(() {
        Get.back();
      }, text: "Create Post"),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              constraints: const BoxConstraints(
                minHeight: 52,
                maxHeight: 120,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: TextFormField(
                controller: content,
                maxLength: 1000,
                minLines: 1,
                style: const TextStyle(color: MyColors.textColor, fontSize: 16, fontWeight: FontWeight.w400),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline, // 👈 enter key adds a new line
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  counterText: "",
                  hintText: "What do you want to talk about?",
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(child: GetBuilder<PostController>(builder: (controller) {
              if (controller.postImageFile != null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.file(controller.postImageFile!, height: 300, fit: BoxFit.cover),
                    const SizedBox(height: 8),
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(MyImgs.getImage),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "Snap a picture now!",
                      style: TextStyle(color: Color(0xffBABABA), fontSize: 12),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    CustomButton(
                        width: 150,
                        height: 30,
                        fontSize: 12,
                        borderColor: MyColors.buttonColor,
                        color: Colors.white,
                        textColor: MyColors.buttonColor,
                        roundCorner: 20,
                        text: "Select from Device",
                        onPressed: () {
                          selectMediaBottomSheet(_getFromGallery, _getFromCamera, context);
                        })
                  ],
                );
              }
            })),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Obx(
                  () => !controller.createPostLoad.value
                      ? const CircularProgressIndicator(
                          color: MyColors.primaryGradient1,
                        )
                      : CustomButton(
                          height: 34,
                          width: 85,
                          fontSize: 12,
                          roundCorner: 20,
                          text: "Publish",
                          onPressed: () async {
                            bool postCreated = await controller.createPost(text: content.text);

                            print('_CreatePostScreenState.build ${postCreated}');
                            if (postCreated) {
                              HelpingWidgets.showCustomDialog(context, () {
                                Get.back();
                                Get.back();
                              }, "Wait for Approval!", "Your post will be displayed once approved by Admin.", MyImgs.doneTick, buttonText: "Got it!");
                            }
                          }),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  selectMediaBottomSheet(Function gallery, Function camera, BuildContext context) {
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
