// import 'package:fitness_zone_2/data/controllers/auth_controller/auth_controller.dart';
// import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
// import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
// import 'package:fitness_zone_2/widgets/custom_button.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// import '../../../values/my_colors.dart';
// import '../../../widgets/toasts.dart';
// import '../../chat/group_chat_room.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// import '../../chat/widgets/chat_room.dart';
// import '../call_screen/call_screen.dart';
//
// class MyPlanScreen extends StatelessWidget {
//   MyPlanScreen({super.key});
//   final HomeController homeController = Get.find();
//   final AuthController authController = Get.find();
//   @override
//   Widget build(BuildContext context) {
//     var textTheme = Theme.of(context).textTheme;
//
//     return Scaffold(
//       appBar: HelpingWidgets().appBarWidget(() {
//         Get.back();
//       }, text: "Plan Details"),
//       body: ListView(
//         padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
//         // crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             "My Plan: ${homeController.userHomeData!.title}",
//             style:
//                 textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w600),
//           ),
//           Text(
//             homeController.userHomeData!.shortDescription,
//             style: textTheme.bodySmall!.copyWith(),
//           ),
//           SizedBox(
//             height: 10.h,
//           ),
//           Text(
//             homeController.userHomeData!.longDescription,
//             style: textTheme.bodySmall!.copyWith(),
//           ),
//           SizedBox(
//             height: 20.h,
//           ),
//           homeController.userHomeData!.dietitionDetails == null
//               ? const SizedBox.shrink()
//               : Column(
//                   children: [
//                     CustomButton(
//                         text: "Chat with Dietitian",
//                         onPressed: () async {
//                           String roomId = (authController.logInUser!.id
//                                       .toString()
//                                       .hashCode +
//                                   homeController
//                                       .userHomeData!.dietitionDetails!.id
//                                       .toString()
//                                       .hashCode)
//                               .toString();
//                           Map<String, dynamic>? userMap;
//                           await FirebaseFirestore.instance
//                               .collection("users")
//                               .doc(homeController
//                                   .userHomeData!.dietitionDetails!.id
//                                   .toString())
//                               .get()
//                               .then((value) {
//                             userMap = value.data();
//                           });
//
//                           userMap ??= {
//                             "id": homeController
//                                 .userHomeData!.dietitionDetails!.id
//                                 .toString(),
//                             "name":
//                                 "${homeController.userHomeData!.dietitionDetails!.firstName} ${homeController.userHomeData!.dietitionDetails!.lastName}",
//                             "deviceToken": ""
//                           };
//                           Get.to(() => ChatRoom(
//                                 chatRoomId: roomId,
//                                 userMap: userMap!,
//                               ));
//                         }),
//                     SizedBox(
//                       height: 20.h,
//                     ),
//                   ],
//                 ),
//           homeController.userHomeData!.CategoryId == 3 ||
//               homeController.userHomeData!.CategoryId == 2
//               ? Text(
//                   "Time Table",
//                   style: textTheme.headlineMedium!
//                       .copyWith(fontWeight: FontWeight.w600),
//                 ):SizedBox.shrink(),
//           homeController.userHomeData!.CategoryId == 3 ||
//                   homeController.userHomeData!.CategoryId == 2
//               ? ListView.separated(
//                   physics: const NeverScrollableScrollPhysics(),
//                   shrinkWrap: true,
//                   itemBuilder: (context, int index) {
//                     var dayTime = homeController.userHomeData!.time[index];
//                     return ExpansionTile(
//                       onExpansionChanged: (bool value) {
//                         if (value) {}
//                       },
//                       trailing: const Icon(Icons.keyboard_arrow_down_rounded),
//                       tilePadding: EdgeInsets.zero,
//                       title: Text(
//                         dayTime.day,
//                         style: textTheme.bodyLarge,
//                       ),
//                       children: [
//                         ListView.separated(
//                             shrinkWrap: true,
//                             physics: const NeverScrollableScrollPhysics(),
//                             itemBuilder: (context, int timeIndex) {
//                               var slot = dayTime.slots[timeIndex];
//                               return Row(children: [
//                                 Container(
//                                   height: 56.h,
//                                   width: 120.w,
//                                   padding:
//                                       EdgeInsets.symmetric(horizontal: 12.w),
//                                   alignment: Alignment.centerLeft,
//                                   decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(8),
//                                       border: Border.all(color: Colors.black)),
//                                   child: Text(
//                                     slot.start,
//                                     style: TextStyle(
//                                         color: MyColors.textColor,
//                                         fontSize: 16.sp,
//                                         fontWeight: FontWeight.w400),
//                                   ),
//                                 ),
//                                 SizedBox(
//                                   width: 10.w,
//                                 ),
//                                 Container(
//                                   height: 56.h,
//                                   width: 120.w,
//                                   padding:
//                                       EdgeInsets.symmetric(horizontal: 12.w),
//                                   alignment: Alignment.centerLeft,
//                                   decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(8),
//                                       border: Border.all(color: Colors.black)),
//                                   child: Text(
//                                     slot.end,
//                                     style: TextStyle(
//                                         color: MyColors.textColor,
//                                         fontSize: 16.sp,
//                                         fontWeight: FontWeight.w400),
//                                   ),
//                                 ),
//                                 SizedBox(
//                                   width: 10.w,
//                                 ),
//                                 GestureDetector(
//                                   onTap: () async {
//                                     if (slot.trainerLink == null) {
//                                       CustomToast.failToast(
//                                           msg: "Trainer did not add link yet");
//                                     } else {
//                                       if (isValidUrl(slot.trainerLink)) {
//                                         await launchUrl(
//                                             Uri.parse(slot.trainerLink));
//
//                                         // if (!await launchUrl(
//                                         //     Uri.parse(slot.trainerLink!))) {
//                                         //   CustomToast.failToast(
//                                         //       msg: "Could not launch link");
//                                         // }
//                                       } else {
//                                         await _handleCameraAndMic(
//                                             Permission.camera);
//                                         await _handleCameraAndMic(
//                                             Permission.microphone);
//                                         var token = await homeController
//                                             .getAgoraToken(slot.trainerLink);
//
//                                         Get.to(() => CallScreen(
//                                               channelName: slot.trainerLink,
//                                               token: token!,
//                                               userId: Get.find<AuthController>()
//                                                   .logInUser!
//                                                   .id
//                                                   .toString(),
//                                               // camera: firstCamera,
//                                             ));
//                                       }
//                                     }
//                                   },
//                                   child: Container(
//                                     alignment: Alignment.center,
//                                     width: 100.w,
//                                     height: 30.h,
//                                     decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(10),
//                                         color: MyColors.buttonColor),
//                                     child: Text(
//                                       "Join",
//                                       style: textTheme.bodySmall,
//                                     ),
//                                   ),
//                                 ),
//                               ]);
//                             },
//                             separatorBuilder: (context, int index) {
//                               return SizedBox(
//                                 height: 10.h,
//                               );
//                             },
//                             itemCount: dayTime.slots.length)
//                       ],
//                     );
//                   },
//                   separatorBuilder: (context, int index) {
//                     return SizedBox(
//                       height: 10.h,
//                     );
//                   },
//                   itemCount: homeController.userHomeData!.time.length)
//               : SizedBox.shrink(),
//         ],
//       ),
//       bottomNavigationBar:
//       homeController.userHomeData!.dietitionDetails==null?null:
//       Padding(
//         padding: const EdgeInsets.all(20),
//         child: CustomButton(
//           text: 'Join for you consultancy',
//           onPressed: () async {
//             var link = homeController.userHomeData!.dietitionLink;
//             if (link == null) {
//               CustomToast.failToast(msg: "Dietitian did not paste link yet");
//             } else {
//               if (isValidUrl(link)) {
//                 await launchUrl(Uri.parse(link));
//
//                 // if (!await launchUrl(
//                 //     Uri.parse(slot.trainerLink!))) {
//                 //   CustomToast.failToast(
//                 //       msg: "Could not launch link");
//                 // }
//               } else {
//                 await _handleCameraAndMic(Permission.camera);
//                 await _handleCameraAndMic(Permission.microphone);
//                 var token = await homeController.getAgoraToken(link);
//                 //final cameras = await availableCameras();
//                 // final firstCamera = cameras.first;
//                 Get.to(() => CallScreen(
//                       channelName: link,
//                       token: token!,
//                       userId:
//                           Get.find<AuthController>().logInUser!.id.toString(),
//                       // camera: firstCamera,
//                     ));
//                 // if (!await launchUrl(Uri.parse(
//                 //     homeController.userHomeData!.dietitionLink))) {
//                 //   CustomToast.failToast(msg: "Could not launch link");
//                 // }
//               }
//             }
//           },
//         ),
//       ),
//     );
//   }
//
//   bool isValidUrl(String url) {
//     const urlPattern =
//         r'^(https?:\/\/)?([a-zA-Z0-9\-]+\.)+[a-zA-Z]{2,}(:[0-9]{1,5})?(\/.*)?$';
//     final result = RegExp(urlPattern).hasMatch(url);
//     return result;
//   }
//
//   Future<void> _handleCameraAndMic(Permission permission) async {
//     final status = await permission.request();
//     print(status);
//   }
// }
