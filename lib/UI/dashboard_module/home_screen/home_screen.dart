import 'package:fitness_zone_2/UI/chat/group_chat_room.dart';
import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/widgets/admin_home_screen.dart';
import 'package:fitness_zone_2/widgets/all_plans_screen.dart';
import 'package:fitness_zone_2/widgets/circular_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../data/controllers/auth_controller/auth_controller.dart';
import '../../../values/constants.dart';
import '../../../values/my_colors.dart';
import '../../../values/my_imgs.dart';
import '../../../widgets/trainer_home_screen.dart';
import '../../../widgets/custom_textfield.dart';
import '../../../widgets/toasts.dart';
import '../../../widgets/user_home_screen.dart';
import '../../chat/widgets/chat_room.dart';
import '../paste_link/paste_link.dart';
import '../session_screen/session_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);
  final TextEditingController controller = TextEditingController();
  final AuthController authController = Get.find();

  final HomeController homeController = Get.find();

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
        backgroundColor: MyColors.primaryColor,
        body: Obx(() {
          if (authController.loginAsA.value == Constants.user) {
            if (authController.logInUser!.status) {
              return UserHomeScreen();
            } else {
              return AllPlansScreen();
            }
          } else if (authController.loginAsA.value == Constants.dietitian) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  SizedBox(
                    height: 50.h,
                  ),
                  Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(
                            top: 42.h, bottom: 42.h, right: 15.w, left: 130.w),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: const Color(0xffFAD8CD)),
                        child: Text(
                          "Make Your Body\nHealthy & Fit With Us",
                          style: textTheme.headlineMedium!.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Image.asset(
                        MyImgs.girl,
                        scale: 3,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 40.h,
                  ),
                  Expanded(child: Obx(() {
                    if (homeController.dietHomeLoad.value) {
                      if (homeController.getDietitianUsers!.plans.isEmpty) {
                        return const Text("No users assign to you yet");
                      }

                      return ListView.separated(
                          itemBuilder: (context, int index) {
                            var user = homeController
                                .getDietitianUsers!.plans[index].user;
                            var plan =
                                homeController.getDietitianUsers!.plans[index];
                            var showString =
                            getDisplayString(plan.buyingDate);


                            return user != null
                                ? Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                showString,
                                                style: textTheme.bodySmall!
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 20.sp),
                                              ),
                                              Text(
                                                "${user.firstName} ${user.lastName}",
                                                style: textTheme.bodyLarge,
                                              ),
                                              Text(
                                                user.email,
                                                style: textTheme.bodySmall,
                                              ),
                                              SizedBox(
                                                height: 5.h,
                                              ),
                                              Text(
                                                plan.plan.title,
                                                style: textTheme.bodySmall,
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              GestureDetector(
                                                  onTap: () async {
                                                    String roomId =
                                                        (authController
                                                                    .logInUser!
                                                                    .id
                                                                    .toString()
                                                                    .hashCode +
                                                                plan.user!.id
                                                                    .toString()
                                                                    .hashCode)
                                                            .toString();
                                                    var userMap;
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection("users")
                                                        .doc(plan.user!.id
                                                            .toString())
                                                        .get()
                                                        .then((value) {
                                                      userMap = value.data();
                                                    });
                                                    userMap ??= {
                                                      "id": plan.user!.id
                                                          .toString(),
                                                      "name":
                                                          "${plan.user!.firstName} ${plan.user!.lastName}",
                                                      "deviceToken": ""
                                                    };

                                                    Get.to(() => ChatRoom(
                                                          chatRoomId: roomId,
                                                          userMap: userMap,
                                                        ));
                                                  },
                                                  child: const Icon(
                                                    Icons.message,
                                                  )),
                                              SizedBox(
                                                width: 20.w,
                                              ),
                                              GestureDetector(
                                                onTap: () =>
                                                    Get.to(() => SessionScreen(
                                                          slotId: homeController
                                                              .getDietitianUsers!
                                                              .plans[index]
                                                              .id,
                                                          isDiet: true,
                                                          userId: homeController
                                                              .getDietitianUsers!
                                                              .plans[index]
                                                              .user!
                                                              .id,
                                                        )),

                                                // Get.to(() => PasteLink(
                                                //       slotId: homeController
                                                //           .getDietitianUsers!
                                                //           .plans[index]
                                                //           .id,
                                                //       isDiet: true,
                                                //     )),
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  width: 100.w,
                                                  height: 30.h,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      color:
                                                          MyColors.buttonColor),
                                                  child: Text(
                                                    "Paste Link",
                                                    style: textTheme.bodySmall,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 5.h,
                                      ),
                                      Divider(
                                        height: 1.h,
                                        color: Colors.black.withOpacity(0.6),
                                      )
                                    ],
                                  )
                                : SizedBox();
                          },
                          separatorBuilder: (context, int index) => SizedBox(
                                height: 10.h,
                              ),
                          itemCount:
                              homeController.getDietitianUsers!.plans.length);
                    } else {
                      return const Center(
                        child: CircularProgress(),
                      );
                    }
                  })
                      //     Obx(
                      //   () => authController.dietitianDataLoad.value
                      //       ? ListView.separated(
                      //           itemBuilder: (context, int index) => Column(
                      //                 children: [
                      //                   ListTile(
                      //                     trailing: GestureDetector(
                      //                         onTap: () {
                      //                           String chatRoomId = (authController
                      //                                       .getDietitianUsers
                      //                                       .plans[index]
                      //                                       .user
                      //                                       .hashCode +
                      //                                   authController
                      //                                       .logInUser!.id.hashCode)
                      //                               .toString();
                      //                           Get.to(ChatRoom(
                      //                               chatRoomId: chatRoomId));
                      //                         },
                      //                         child: const Icon(
                      //                           Icons.message,
                      //                         )),
                      //                     subtitle: Text(authController
                      //                         .getDietitianUsers
                      //                         .plans[index]
                      //                         .plan
                      //                         .title),
                      //                     title: Text(
                      //                       "${authController.getDietitianUsers.plans[index].user.firstName} ${authController.getDietitianUsers.plans[index].user.lastName}",
                      //                       style: textTheme.bodyLarge,
                      //                     ),
                      //                   ),
                      //                   Divider(
                      //                     height: 1.h,
                      //                     color: Colors.black.withOpacity(0.6),
                      //                   )
                      //                 ],
                      //               ),
                      //           separatorBuilder: (context, int index) => SizedBox(
                      //                 height: 10.h,
                      //               ),
                      //           itemCount:
                      //               authController.getDietitianUsers.plans.length)
                      //       : const Center(
                      //           child: CircularProgressIndicator(),
                      //         ),
                      // )
                      )

                  // GestureDetector(
                  //     onTap: () {
                  //       Get.to(() => SessionScreen());
                  //     },
                  //     child: containerWidget(const Color(0xffCCF2FE),
                  //         "My Sessions", MyImgs.myRecordings)),
                  ,
                  SizedBox(
                    height: 16.h,
                  ),
                ],
              ),
            );
          } else if (authController.loginAsA.value == Constants.admin) {
            return AdminHomeScreen();
          } else {
            return TrainerHomeScreen();
          }
        }));
  }
  String getDisplayString(DateTime buyingDate) {
    DateTime now = DateTime.now();

    // Normalize dates to remove the time part
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(const Duration(days: 1));
    DateTime normalizedBuyingDate = DateTime(buyingDate.year, buyingDate.month, buyingDate.day);

    if (normalizedBuyingDate.compareTo(today) == 0) {
      return "Today";
    } else if (normalizedBuyingDate.compareTo(yesterday) == 0) {
      return "Yesterday";
    } else {
      return DateFormat("dd/MM/yyyy").format(buyingDate);
    }
  }
}

containerWidget(Color color, String text, String image) {
  return Container(
    padding: EdgeInsets.all(6.h),
    decoration: BoxDecoration(
      color: MyColors.appBackground,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.4),
          blurRadius: 10.0,
          spreadRadius: 0.0,
          offset: const Offset(0.0, 0.0), // shadow direction: bottom right
        )
      ],
    ),
    child: Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8), color: color),
              child: Image.asset(
                image,
                scale: 4,
                color: Colors.black,
              ),
            ),
            SizedBox(
              width: 20.w,
            ),
            Text(
              text,
              style: TextStyle(
                  color: MyColors.textColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400),
            )
          ],
        ),
      ],
    ),
  );
}
