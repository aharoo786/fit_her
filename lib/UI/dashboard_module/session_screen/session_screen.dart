// import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/controllers/auth_controller/auth_controller.dart';
import '../../../data/controllers/home_controller/home_controller.dart';
import '../../../values/constants.dart';
import '../../../values/dimens.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../values/my_colors.dart';
import '../../../values/my_imgs.dart';
import '../../../widgets/app_bar_widget.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfield.dart';
import 'package:get/get.dart';

import '../../../widgets/toasts.dart';
import '../call_screen/call_screen.dart';

class SessionScreen extends StatelessWidget {
  SessionScreen(
      {Key? key,
      required this.slotId,
      this.isDiet = false,
      required this.userId})
      : super(key: key);
  final int slotId;
  final bool isDiet;
  final int userId;
  final AuthController authController = Get.find();
  final HomeController homeController = Get.find();
  final TextEditingController channelName = TextEditingController();
  final TextEditingController googleMeet = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // print("link token  ${homeController.generatedToken}");
    var textTheme = Theme.of(context).textTheme;
    return GetBuilder<HomeController>(builder: (con) {
      return Scaffold(
        appBar: HelpingWidgets().appBarWidget(() {
          Get.back();
        },
            text: authController.loginAsA.value == Constants.user
                ? "Join Channel"
                : "Create Channel"),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: Dimens.size20.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(authController.loginAsA.value == Constants.user
                    ? MyImgs.joinChannel
                    : MyImgs.createChannel),
                SizedBox(
                  height: 20.h,
                ),
                const Text(
                  "Welcome Back, Enter Channel Name To Start Class.",
                  // style:
                  //     textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 20.h,
                ),
                // Text(
                //   "Channel Name",
                //   style:
                //       textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w500),
                // ),
                // SizedBox(
                //   height: Dimens.size5.h,
                // ),
                CustomTextField(
                  roundCorner: 16,
                  keyboardType: TextInputType.text,
                  text: "Channel name",
                  length: 30,
                  controller: channelName,
                  inputFormatters:
                      FilteringTextInputFormatter.singleLineFormatter,
                ),
                SizedBox(
                  height: 60.h,
                ),
                CustomButton(
                    text: "Update",
                    onPressed: () async {
                      if (channelName.text.isEmpty) {
                        CustomToast.failToast(
                            msg: "Please provide channel name to join");
                      } else {
                        Get.find<HomeController>().updateLinkFunc(
                            channelName, slotId, isDiet, userId);
                      }
                    }),
                SizedBox(
                  height: 20.h,
                ),
                CustomButton(
                    text: "Start Session",
                    onPressed: () async {
                      if (channelName.text.isEmpty) {
                        CustomToast.failToast(
                            msg: "Please provide channel name to join");
                      } else {
                        await _handleCameraAndMic(Permission.camera);
                        await _handleCameraAndMic(Permission.microphone);
                        var token = await homeController
                            .getAgoraToken(channelName.text);
                        //final cameras = await availableCameras();
                        // final firstCamera = cameras.first;
                        Get.to(() => CallScreen(
                          channelName: channelName.text,
                          token: token!,
                          userId: Get.find<AuthController>()
                              .logInUser!
                              .id
                              .toString(),
                          // camera: firstCamera,
                        ));
                      }
                    }),
                SizedBox(
                  height: 20.h,
                ),
                CustomTextField(
                    text: "Paste Link",
                    length: 10000,
                    keyboardType: TextInputType.text,
                    controller: googleMeet,
                    inputFormatters:
                        FilteringTextInputFormatter.singleLineFormatter),
                SizedBox(
                  height: 20.h,
                ),
                CustomButton(
                    text: "Update Session",
                    onPressed: () async {
                      if (googleMeet.text.isEmpty) {
                        CustomToast.failToast(
                            msg: "Please provide link to update");
                      } else {
                        Get.find<HomeController>().updateLinkFunc(
                            googleMeet, slotId, isDiet, userId);
                      }
                    }),
              ],
            ),
          ),
        ),
      );
    });
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    print(status);
  }
}

// Future<void> _pickVideo(BuildContext context) async {
//   try {
//     PermissionOfPhotos().getFromGallery(context).then((value) async {
//       if (value) {
//         XFile? pickedVideo =
//             await ImagePicker().pickVideo(source: ImageSource.gallery);
//         if (pickedVideo != null) {
//           Get.find<HomeController>()
//               .uploadBytesToFirebaseStorage(pickedVideo.path);
//         }
//       }
//     });
//   } catch (e) {
//     print('Error picking video: $e');
//   }
// }
