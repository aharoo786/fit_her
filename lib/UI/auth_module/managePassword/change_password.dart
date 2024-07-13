// import 'package:farm_sharing/common_utils/validators/validators.dart';
//
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
//
// class ChangePassword extends StatelessWidget {
//   ChangePassword({Key? key}) : super(key: key);
//   TextEditingController oldPass = TextEditingController();
//   TextEditingController newPass = TextEditingController();
//   TextEditingController cNewPass = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     var theme = Theme.of(context);
//     var textTheme = theme.textTheme;
//     var mediaQuery = MediaQuery.of(context).size;
//     return GestureDetector(
//       onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: MyColors.primaryColor,
//           elevation: 0,
//           leading: IconButton(
//             icon: Image.asset(
//               MyImgs.back1,
//               height: (Dimens.size22.h),
//               width: (Dimens.size25.w),
//               color: MyColors.black,
//               fit: BoxFit.cover,
//             ),
//             onPressed: () => Get.back(),
//           ),
//           centerTitle: true,
//           title: Text(
//             'Change Password'.tr,
//             textAlign: TextAlign.center,
//             style: textTheme.headline3
//           ),
//         ),
//         backgroundColor: MyColors.primaryColor,
//         body:
//           Column(
//             children: [
//
//               Expanded(
//                 child: Container(
//
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(36),
//                         topRight: Radius.circular(36)),
//                     color: MyColors.bodyBackground,
//                   ),
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(horizontal: Dimens.size20.w),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(
//                           height: Dimens.size30.h,
//                         ),
//                         Text(
//                           "Old Password".tr,
//                           style: textTheme.headline4,
//                         ),
//                         SizedBox(
//                           height: Dimens.size10.h,
//                         ),
//                         CustomTextField(
//                             icon: Image.asset(MyImgs.pass),
//                             text: "Old Password".tr,
//                             length: 18,
//                             validator: (value) =>
//                                 Validators.firstNameValidation(value!),
//                             controller: oldPass,
//                             keyboardType: TextInputType.text,
//                             inputFormatters:
//                                 FilteringTextInputFormatter.singleLineFormatter),
//                         SizedBox(
//                           height: Dimens.size30.h,
//                         ),
//                         Text(
//                           "New Password".tr,
//                           style: textTheme.headline4,
//                         ),
//                         SizedBox(
//                           height: Dimens.size10.h,
//                         ),
//                         CustomTextField(
//                             icon: Image.asset(MyImgs.pass),
//                             text: "New Password".tr,
//                             length: 18,
//                             validator: (value) =>
//                                 Validators.firstNameValidation(value!),
//                             controller: newPass,
//                             keyboardType: TextInputType.text,
//                             inputFormatters:
//                                 FilteringTextInputFormatter.singleLineFormatter),
//                         SizedBox(
//                           height: Dimens.size30.h,
//                         ),
//                         Text(
//                           "confirmPwd".tr,
//                           style: textTheme.headline4,
//                         ),
//                         SizedBox(
//                           height: Dimens.size10.h,
//                         ),
//                         CustomTextField(
//                             icon: Image.asset(MyImgs.pass),
//                             text: "confirmPwd".tr,
//                             length: 18,
//                             controller: cNewPass,
//                             validator: (value) =>
//                                 Validators.firstNameValidation(value!),
//                             keyboardType: TextInputType.text,
//                             inputFormatters:
//                                 FilteringTextInputFormatter.singleLineFormatter),
//                         SizedBox(
//                           height: Dimens.size50.h,
//                         ),
//                         Center(
//                           child: CustomButton(
//                               height: 48.h,
//                               width: 280.w,
//                               roundCorner: 30,
//                               textColor: MyColors.primary2,
//                               borderColor: MyColors.black,
//                               text: "Save".tr,
//                               onPressed: () {
//                                 if (oldPass.text.isEmpty ||
//                                     newPass.text.isEmpty ||
//                                     cNewPass.text.isEmpty) {
//                                   CustomToast.failToast(
//                                       msg: "Please fill all fields".tr);
//                                 } else {
//                                   if (newPass.text != cNewPass.text) {
//                                     CustomToast.failToast(
//                                         msg: "Password does not match".tr);
//                                   } else {
//                                     if (oldPass.text == newPass.text) {
//                                       CustomToast.failToast(
//                                           msg:
//                                               "New password must be different from the old password".tr);
//                                     } else {
//                                       Get.find<ProfileController>()
//                                           .updatePassword(
//                                               oldPassword: oldPass.text,
//                                               newPassword: newPass.text);
//                                       // oldPass.text="";
//                                       // newPass.text="";
//                                       // cNewPass.text="";
//
//                                     }
//                                   }
//                                 }
//                               }),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//
//       ),
//     );
//   }
// }
