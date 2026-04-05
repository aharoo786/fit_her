// import 'package:cultural_app/dashboard_module/bottom_bar_screen/bottom_bar_screen.dart';
// import 'package:cultural_app/dashboard_module/information/information.dart';
// import 'package:cultural_app/dashboard_module/saved_places/saved_places.dart';
// import 'package:cultural_app/data/controllers/auth_controller/auth_controller.dart';
// import 'package:cultural_app/data/controllers/home_controller/home_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
//
// import '../../values/dimens.dart';
// import '../../values/my_colors.dart';
// import '../../values/my_imgs.dart';
// import '../report_a_problem/report_a_problem.dart';
//
// class MyDrawer extends StatelessWidget {
//   MyDrawer({Key? key}) : super(key: key);
//
//   // ProfileController x = Get.put(ProfileController(sharedPreferences: Get.find(), profileRepo: Get.find(),));
//   @override
//   Widget build(BuildContext context) {
//     // Get.find<ProfileController>().getProfileData();
//     var theme = Theme.of(context);
//     var textTheme = theme.textTheme;
//
//     return SizedBox(
//       height: double.infinity,
//       width: Dimens.size320.w,
//       child: ClipRRect(
//         borderRadius: BorderRadius.only(
//             topRight: Radius.circular(30.w),
//             bottomRight: Radius.circular(30.w)),
//         child: Drawer(
//           elevation: 10,
//           backgroundColor: MyColors.primaryColor,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(
//                 height: 50.h,
//               ),
//               IconButton(
//                   onPressed: () {
//                     Get.back();
//                   },
//                   icon: const Icon(
//                     Icons.clear,
//                     size: 30,
//                   )),
//               SizedBox(
//                 height: 30.h,
//               ),
//               drawerCard(
//                   context: context,
//                   img: MyImgs.homeIconOutline,
//                   title: "Home".tr,
//                   onTap: () {
//                     Get.offAll(BottomBarScreen());
//                   }),
//               drawerCard(
//                   context: context,
//                   img: MyImgs.bookMark,
//                   title: "Saved places".tr,
//                   onTap: () async {
//                     Get.back();
//                    await Get.find<HomeController>().getFavorite();
//                     Get.to(SavedPlaces(
//                       search: "myFavourite",
//                     ));
//                   }),
//               drawerCard(
//                   context: context,
//                   img: MyImgs.information,
//                   title: "Information".tr,
//                   onTap: () {
//                     Get.back();
//                     Get.to(Information());
//                   }),
//               drawerCard(
//                   context: context,
//                   img: MyImgs.reportAProblem,
//                   title: "Report a problem".tr,
//                   onTap: () {
//                     Get.back();
//                     Get.to(() => ReportAProblem());
//                   }),
//               SizedBox(height: 400.h),
//               GestureDetector(
//                 onTap: () {
//                   _showLogoutDialog(context);
//                 },
//                 child: Align(
//                     alignment: Alignment.bottomCenter,
//                     child: Text(
//                       "Log out",
//                       style: textTheme.bodyLarge!.copyWith(color: Colors.black),
//                     )),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget drawerCard({context, img, title, onTap}) {
//     return Padding(
//       padding: EdgeInsets.only(
//           left: Dimens.size18.w, top: Dimens.size30.h, bottom: Dimens.size10),
//       child: GestureDetector(
//         onTap: () => onTap(),
//         child: Row(children: [
//           ImageIcon(
//             AssetImage(img),
//             color: MyColors.iconColor2,
//           ),
//           SizedBox(
//             width: Dimens.size15.w,
//           ),
//           Text(
//             title,
//             style: Theme.of(context).textTheme.headlineMedium!.copyWith(
//                   color: MyColors.textColor,
//                   fontWeight: FontWeight.w500,
//                   fontSize: 18.sp,
//                 ),
//           ),
//         ]),
//       ),
//     );
//   }
//
//   void _showLogoutDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Logout',
//               style: TextStyle(color: Colors.black, fontSize: 18.sp)),
//           content: Text('Are you sure you want to log out?',
//               style: TextStyle(color: Colors.black, fontSize: 16.sp)),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child:
//                   const Text('Cancel', style: TextStyle(color: Colors.black)),
//             ),
//             TextButton(
//               onPressed: () {
//                 Get.find<AuthController>().clearLocalStorage();
//               },
//               child: Text(
//                 'Logout',
//                 style: TextStyle(color: Colors.black),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
//
// // showDeleteDialog(BuildContext context) {
// //   // set up the buttons
// //   Widget cancelButton = GestureDetector(
// //     onTap: () {
// //
// //       Get.back();
// //     },
// //     child: Container(
// //       height: 30.h,
// //       width: 90.h,
// //       alignment: Alignment.center,
// //       decoration: BoxDecoration(
// //         borderRadius: BorderRadius.circular(36),
// //         border: Border.all(color: MyColors.buttonColor),
// //         color: Get.find<ProfileController>().deleteAccount
// //             ? Colors.transparent
// //             : MyColors.buttonColor,
// //       ),
// //       child: Text(
// //         "Cancel".tr,
// //         style: TextStyle(
// //             color: Get.find<ProfileController>().deleteAccount
// //                 ? MyColors.textColor
// //                 : MyColors.primary2,
// //             fontStyle: FontStyle.normal,
// //             fontSize: 12.sp),
// //       ),
// //       //    onPressed:
// //     ),
// //   );
// //   Widget continueButton = GestureDetector(
// //     onTap: () async {
// //       Get.find<ProfileController>().deleteAccount = true;
// //       Get.find<ProfileController>().update();
// //       await Get.find<ProfileController>().deleteUserAccount();
// //       Get.back();
// //     },
// //     child: Container(
// //       height: 30.h,
// //       width: 95.h,
// //       // padding: EdgeInsets.symmetric(5),
// //       alignment: Alignment.center,
// //       decoration: BoxDecoration(
// //           borderRadius: BorderRadius.circular(36),
// //           color: Get.find<ProfileController>().deleteAccount == false
// //               ? Colors.transparent
// //               : MyColors.buttonColor,
// //           border: Border.all(color: MyColors.buttonColor)),
// //
// //       child: Text("Continue".tr,
// //           style: TextStyle(
// //               color: Get.find<ProfileController>().deleteAccount == false
// //                   ? MyColors.textColor
// //                   : MyColors.primary2,
// //               fontStyle: FontStyle.normal,
// //               fontSize: 12.sp)),
// //     ),
// //   );
// //
// //   // set up the AlertDialog
// //   AlertDialog alert = AlertDialog(
// //     actionsPadding: EdgeInsets.only(right: 15.w, bottom: 15.h),
// //     shape: RoundedRectangleBorder(
// //         borderRadius: BorderRadius.all(Radius.circular(36.0))),
// //     title: Text(
// //       "Delete Account".tr,
// //       style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
// //     ),
// //     content: Text(
// //       "Do you want to delete your account?".tr,
// //       style: TextStyle(fontWeight: FontWeight.w400),
// //     ),
// //     actions: [
// //       cancelButton,
// //       continueButton,
// //     ],
// //   );
// //
// //   // show the dialog
// //   showDialog(
// //       context: context,
// //       builder: (BuildContext context) {
// //         return alert;
// //       });
// // }
