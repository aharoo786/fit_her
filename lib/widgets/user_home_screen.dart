import 'package:fitness_zone_2/UI/auth_module/edit_user/edit_user.dart';
import 'package:fitness_zone_2/UI/chat/group_chat_room.dart';
import 'package:fitness_zone_2/UI/dashboard_module/my_plan_details/my_plan_screen.dart';
import 'package:fitness_zone_2/UI/dashboard_module/profile_screen/PaymentDetails.dart';
import 'package:fitness_zone_2/widgets/circular_progress.dart';
import 'package:fitness_zone_2/widgets/custom_button.dart';
import 'package:fitness_zone_2/widgets/toasts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../UI/chat/widgets/chat_room.dart';
import '../UI/dashboard_module/home_screen/home_screen.dart';
import '../UI/dashboard_module/measurement_screen/measurement_screen.dart';
import '../UI/dashboard_module/my_daily_meal/my_daily_meal.dart';
import '../UI/dashboard_module/my_recordings/my_recordings_screen.dart';
import '../UI/dashboard_module/profile_screen/Imporatant_Screen.dart';
import '../data/controllers/auth_controller/auth_controller.dart';
import '../data/controllers/home_controller/home_controller.dart';
import '../values/constants.dart';
import '../values/my_colors.dart';
import '../values/my_imgs.dart';
import 'package:get/get.dart';
import 'custom_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserHomeScreen extends StatelessWidget {
  UserHomeScreen({Key? key}) : super(key: key);

  final AuthController authController = Get.find();
  final HomeController homeController = Get.find();
  final List<Color> colors = [
    Colors.grey,
    Colors.blueGrey,
    Colors.teal,
    Colors.cyanAccent
  ];
  final List<String> images = [
    MyImgs.yoga,
    MyImgs.zumba,
    MyImgs.cardio,
    MyImgs.mediation,
  ];
  final List<String> textList = [
    "Yoga",
    "Zumba",
    "Cardio",
    "Mediation",
  ];
  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return SingleChildScrollView(
      child: Obx(
        () => homeController.userHomeLoad.value
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 45.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.4),
                                blurRadius: 22.0,
                                spreadRadius: 0.0,
                                offset: const Offset(
                                    0.0, 0.0), // shadow direction: bottom right
                              )
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    MyImgs.body,
                                    scale: 4,
                                  ),
                                  SizedBox(
                                    width: 5.w,
                                  ),
                                  Text(
                                    "Finished",
                                    style: textTheme.bodyMedium!
                                        .copyWith(fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              Text(
                                  "${homeController.userHomeData!.remainingDays} days",
                                  style: textTheme.bodyMedium!.copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 24.sp)),
                              Text(
                                "Remaining\nDays",
                                style: textTheme.bodyMedium!.copyWith(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14.sp,
                                    color: MyColors.black.withOpacity(0.6)),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10.w,),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.only(
                                left: 12.w, top: 8.h, bottom: 8.h, ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.4),
                                  blurRadius: 22.0,
                                  spreadRadius: 0.0,
                                  offset: const Offset(
                                      0.0, 0.0), // shadow direction: bottom right
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Image.asset(
                                      MyImgs.calender2,
                                      scale: 4,
                                    ),
                                    SizedBox(
                                      width: 5.w,
                                    ),
                                    Text(
                                      "Days Spend",
                                      style: textTheme.bodySmall!
                                          .copyWith(fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                ),
                                RichText(
                                    text: TextSpan(
                                        text:
                                            "${homeController.userHomeData!.spendDays}",
                                        style: textTheme.bodyLarge!.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                        children: [
                                      TextSpan(
                                          text: " days",
                                          style: textTheme.bodySmall!.copyWith(
                                              fontWeight: FontWeight.w400,
                                              color:
                                                  Colors.black.withOpacity(0.4)))
                                    ]))
                              ],
                            ),
                          ),
                        )
                      ],
                    ),

                    SizedBox(
                      height: 20.h,
                    ),
                    Text(
                      "Your Plan",
                      style: textTheme.headlineMedium!
                          .copyWith(fontWeight: FontWeight.w600),
                    ),

                    SizedBox(
                      height: 150.h,
                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        itemCount: 1,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              if (homeController.userHomeData!.freeze == 1) {
                                CustomToast.failToast(
                                    msg:
                                        "You plan has been frozen make request to the admin to unfreeze you ");
                              } else {
                                Get.to(() => MyPlanScreen());
                              }
                            },
                            child: Container(
                              width: 300.w,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                        offset: Offset(0, 2),
                                        blurRadius: 4,
                                        color: Colors.black.withOpacity(0.1))
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
                                        homeController.userHomeData!.title,
                                        style:
                                            textTheme.headlineSmall!.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,

                                      ),
                                      Text(
                                        homeController
                                            .userHomeData!.shortDescription,
                                        style: textTheme.bodySmall!.copyWith(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        "PKR ${homeController.userHomeData!.price}",
                                        style: textTheme.bodyLarge!.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ]),
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return SizedBox(
                            width: 10.w,
                          );
                        },
                      ),

                      // child: Obx(
                      //     ()=>
                      //     authController.homeDataLoad.value?
                      //     ListView.builder(
                      //       itemCount: authController.homeModel.plans.length,
                      //       scrollDirection: Axis.horizontal,
                      //       itemBuilder: (BuildContext context, int index) {
                      //         return GestureDetector(
                      //           onTap: () {
                      //             // Get.to(() => Payment(
                      //             //       plan: authController.homeModel.plans[index],
                      //             //     ));
                      //           },
                      //           child: Container(
                      //             width: 300.w,
                      //             padding: const EdgeInsets.all(10),
                      //             decoration: BoxDecoration(
                      //                 color: Colors.white,
                      //                 borderRadius: BorderRadius.circular(16),
                      //                 boxShadow: [
                      //                   BoxShadow(
                      //                       offset: Offset(0, 2),
                      //                       blurRadius: 22,
                      //                       color: Colors.black.withOpacity(0.1))
                      //                 ]),
                      //             child: Row(children: [
                      //               SizedBox(
                      //                 width: 70.w,
                      //                 child: Image.network(
                      //                     "${Constants.baseUrl}/${authController.homeModel.plans[index].image}"),
                      //               ),
                      //               SizedBox(
                      //                 width: 10.w,
                      //               ),
                      //               Expanded(
                      //                 child: Column(
                      //                   crossAxisAlignment: CrossAxisAlignment.start,
                      //                   children: [
                      //                     Text(
                      //                       authController.homeModel.plans[index].title,
                      //                       style: textTheme.headlineSmall!.copyWith(
                      //                         fontWeight: FontWeight.w500,
                      //                       ),
                      //                     ),
                      //                     Text(
                      //                       authController
                      //                           .homeModel.plans[index].longDescription,
                      //                       style: textTheme.bodySmall!.copyWith(),
                      //                       maxLines: 3,
                      //                       overflow: TextOverflow.ellipsis,
                      //                     ),
                      //                     Text(
                      //                       "PKR ${authController.homeModel.plans[index].price}",
                      //                       style: textTheme.bodyLarge!.copyWith(
                      //                         fontWeight: FontWeight.w500,
                      //                       ),
                      //                     ),
                      //                   ],
                      //                 ),
                      //               )
                      //             ]),
                      //           ),
                      //         );
                      //       }):Center(child: CircularProgressIndicator(),),
                      // ),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    homeController.userHomeData!.freeze == 0
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Freeze Plan",
                                style: textTheme.headlineMedium!
                                    .copyWith(fontWeight: FontWeight.w700),
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomTextField(
                                      keyboardType: TextInputType.text,
                                      text: "Duration Freeze".tr,
                                      length: 30,
                                      controller:
                                          authController.dateExtendController,
                                      Readonly: true,
                                      inputFormatters:
                                          FilteringTextInputFormatter
                                              .singleLineFormatter,
                                      suffixIcon: GestureDetector(
                                        onTap: () async {
                                          final DateTime? picked =
                                              await showDatePicker(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context,
                                                          Widget? child) {
                                                    return Theme(
                                                      data: ThemeData.light()
                                                          .copyWith(
                                                        primaryColor: MyColors
                                                            .buttonColor, // OK button background color
                                                        hintColor: MyColors
                                                            .buttonColor, // OK button text color
                                                        dialogBackgroundColor:
                                                            Colors
                                                                .white, // Dialog background color
                                                      ),
                                                      child: child!,
                                                    );
                                                  },
                                                  initialDate: DateTime.now(),
                                                  firstDate: DateTime.now(),
                                                  lastDate: DateTime(2099));
                                          if (picked != null) {
                                            authController
                                                    .dateExtendController.text =
                                                "${picked.difference(DateTime.now()).inDays} days";
                                          }
                                        },
                                        child: Image.asset(
                                          MyImgs.calender2,
                                          scale: 3,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10.w,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      if (authController
                                          .dateExtendController.text.isEmpty) {
                                        CustomToast.failToast(
                                            msg: "Please enter freeze days");
                                      } else {
                                        Get.find<HomeController>()
                                            .freezeMyAccount();
                                      }
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      width: 100.w,
                                      height: 56.h,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: MyColors.buttonColor),
                                      child: Text(
                                        "Update",
                                        style: textTheme.bodySmall,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20.h,
                              ),
                            ],
                          )
                        : SizedBox.shrink(),

                    CustomButton(
                        text: "Chat Support",
                        onPressed: () async {
                          String roomId = (Get.find<AuthController>()
                                      .logInUser!
                                      .id
                                      .toString()
                                      .hashCode +
                                  Get.find<AuthController>()
                                      .logInUser!
                                      .adminId
                                      .toString()
                                      .hashCode)
                              .toString();
                          var userMap = await FirebaseFirestore.instance
                              .collection("users")
                              .doc(authController.logInUser!.adminId.toString())
                              .get();
                          print("usermap ${userMap.data()}");
                          Get.to(() => ChatRoom(
                                chatRoomId: roomId,
                                userMap: userMap.data()!,
                              ));
                        }),
                    SizedBox(
                      height: 20.h,
                    ),

                    Text(
                      "Reviews",
                      style: textTheme.headlineMedium!
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    CarouselSlider(
                      options: CarouselOptions(height: 200.h, autoPlay: true),
                      items: homeController.userHomeData!.testimonial.map((i) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Container(
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.symmetric(
                                  horizontal: 5.0, vertical: 10.h),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                        offset: const Offset(0, 2),
                                        blurRadius: 4,
                                        color: Colors.black.withOpacity(0.1))
                                  ],
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                      image: NetworkImage(
                                          "${Constants.baseUrl}/${i.image}"))),
                            );
                          },
                        );
                      }).toList(),
                    ),
                    // Text(
                    //   "Workout Plans",
                    //   style: textTheme.headlineMedium!
                    //       .copyWith(fontWeight: FontWeight.w600),
                    // ),
                    // SizedBox(
                    //   height: 24.h,
                    // ),
                    // SizedBox(
                    //     height: 110.h,
                    //     child: ListView.builder(
                    //       scrollDirection: Axis.horizontal,
                    //       itemBuilder: (BuildContext context, int index) =>
                    //           GestureDetector(
                    //         onTap: () {
                    //           //  Get.to(()=>WorkOuts());
                    //         },
                    //         child: Container(
                    //           margin: EdgeInsets.only(left: 10.w, right: 10.w),
                    //           decoration: BoxDecoration(
                    //               // color: Colors.yellow,
                    //               borderRadius: BorderRadius.circular(8)),
                    //           child: Column(
                    //             mainAxisAlignment:
                    //                 MainAxisAlignment.spaceBetween,
                    //             children: [
                    //               Container(
                    //                 height: 70.h,
                    //                 width: 70.w,
                    //                 decoration: BoxDecoration(
                    //                     color: colors[index],
                    //                     borderRadius: BorderRadius.circular(8)),
                    //                 child: Image.asset(
                    //                   images[index],
                    //                   scale: 3.5,
                    //                 ),
                    //               ),
                    //               Text(
                    //                 textList[index],
                    //                 style: textTheme.titleLarge!.copyWith(),
                    //               ),
                    //               SizedBox(
                    //                 height: 10.h,
                    //               ),
                    //             ],
                    //           ),
                    //         ),
                    //       ),
                    //       itemCount: textList.length,
                    //     )),
                    SizedBox(
                      height: 30.h,
                    ),
                    Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Important Tips",
                              style: textTheme.headlineMedium!
                                  .copyWith(fontWeight: FontWeight.w700),
                            ),
                            SizedBox(
                              height: 20.h,
                            ),
                            Container(
                              //height: 140.h,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 26.h),
                              decoration: BoxDecoration(
                                  color: const Color(0xfffcd8e0),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        "Tips for Achieving \nYour Fitness Goals",
                                        style: textTheme.headlineSmall!
                                            .copyWith(
                                                fontWeight: FontWeight.w500,
                                                color: const Color(0xff4A4A4A)),
                                      ),
                                      SizedBox(
                                        height: 20.h,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Get.to(() => ImportantScreen());
                                        },
                                        child: Row(
                                          children: [
                                            Text(
                                              "Explore",
                                              style: textTheme.bodyMedium!
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: const Color(
                                                          0xff175A87)),
                                            ),
                                            SizedBox(
                                              width: 15.w,
                                            ),
                                            Icon(Icons.arrow_forward,
                                                color: const Color(0xff175A87)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        Image.asset(
                          MyImgs.womanImage,
                          scale: 2.93,
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                    // SizedBox(
                    //   height: 20.h,
                    // ),
                    // Text(
                    //   "Our Plans",
                    //   style: textTheme.headlineMedium!
                    //       .copyWith(fontWeight: FontWeight.w600),
                    // ),
                    //
                    // SizedBox(
                    //   height: 150.h,
                    //   child: ListView.separated(
                    //     padding: EdgeInsets.symmetric(vertical: 20.h),
                    //     itemCount: 3,
                    //     scrollDirection: Axis.horizontal,
                    //     itemBuilder: (BuildContext context, int index) {
                    //       return GestureDetector(
                    //         onTap: () {
                    //           Get.to(() => Payment());
                    //         },
                    //         child: Container(
                    //           width: 300.w,
                    //           padding: const EdgeInsets.all(10),
                    //           decoration: BoxDecoration(
                    //               color: Colors.white,
                    //               borderRadius: BorderRadius.circular(16),
                    //               boxShadow: [
                    //                 BoxShadow(
                    //                     offset: Offset(0, 2),
                    //                     blurRadius: 4,
                    //                     color: Colors.black.withOpacity(0.1))
                    //               ]),
                    //           child: Row(children: [
                    //             SizedBox(
                    //               width: 70.w,
                    //               child: Image.asset(MyImgs.logo),
                    //             ),
                    //             SizedBox(
                    //               width: 10.w,
                    //             ),
                    //             Expanded(
                    //               child: Column(
                    //                 crossAxisAlignment: CrossAxisAlignment.start,
                    //                 children: [
                    //                   Text(
                    //                     "Package ${index + 1}",
                    //                     style: textTheme.headlineSmall!.copyWith(
                    //                       fontWeight: FontWeight.w500,
                    //                     ),
                    //                   ),
                    //                   Text(
                    //                     "this is the description",
                    //                     style: textTheme.bodySmall!.copyWith(),
                    //                     maxLines: 3,
                    //                     overflow: TextOverflow.ellipsis,
                    //                   ),
                    //                   Text(
                    //                     "PKR ${100 * (index + 1)}",
                    //                     style: textTheme.bodyLarge!.copyWith(
                    //                       fontWeight: FontWeight.w500,
                    //                     ),
                    //                   ),
                    //                 ],
                    //               ),
                    //             )
                    //           ]),
                    //         ),
                    //       );
                    //     },
                    //     separatorBuilder: (BuildContext context, int index) {
                    //       return SizedBox(
                    //         width: 10.w,
                    //       );
                    //     },
                    //   ),
                    //
                    //   // child: Obx(
                    //   //     ()=>
                    //   //     authController.homeDataLoad.value?
                    //   //     ListView.builder(
                    //   //       itemCount: authController.homeModel.plans.length,
                    //   //       scrollDirection: Axis.horizontal,
                    //   //       itemBuilder: (BuildContext context, int index) {
                    //   //         return GestureDetector(
                    //   //           onTap: () {
                    //   //             // Get.to(() => Payment(
                    //   //             //       plan: authController.homeModel.plans[index],
                    //   //             //     ));
                    //   //           },
                    //   //           child: Container(
                    //   //             width: 300.w,
                    //   //             padding: const EdgeInsets.all(10),
                    //   //             decoration: BoxDecoration(
                    //   //                 color: Colors.white,
                    //   //                 borderRadius: BorderRadius.circular(16),
                    //   //                 boxShadow: [
                    //   //                   BoxShadow(
                    //   //                       offset: Offset(0, 2),
                    //   //                       blurRadius: 22,
                    //   //                       color: Colors.black.withOpacity(0.1))
                    //   //                 ]),
                    //   //             child: Row(children: [
                    //   //               SizedBox(
                    //   //                 width: 70.w,
                    //   //                 child: Image.network(
                    //   //                     "${Constants.baseUrl}/${authController.homeModel.plans[index].image}"),
                    //   //               ),
                    //   //               SizedBox(
                    //   //                 width: 10.w,
                    //   //               ),
                    //   //               Expanded(
                    //   //                 child: Column(
                    //   //                   crossAxisAlignment: CrossAxisAlignment.start,
                    //   //                   children: [
                    //   //                     Text(
                    //   //                       authController.homeModel.plans[index].title,
                    //   //                       style: textTheme.headlineSmall!.copyWith(
                    //   //                         fontWeight: FontWeight.w500,
                    //   //                       ),
                    //   //                     ),
                    //   //                     Text(
                    //   //                       authController
                    //   //                           .homeModel.plans[index].longDescription,
                    //   //                       style: textTheme.bodySmall!.copyWith(),
                    //   //                       maxLines: 3,
                    //   //                       overflow: TextOverflow.ellipsis,
                    //   //                     ),
                    //   //                     Text(
                    //   //                       "PKR ${authController.homeModel.plans[index].price}",
                    //   //                       style: textTheme.bodyLarge!.copyWith(
                    //   //                         fontWeight: FontWeight.w500,
                    //   //                       ),
                    //   //                     ),
                    //   //                   ],
                    //   //                 ),
                    //   //               )
                    //   //             ]),
                    //   //           ),
                    //   //         );
                    //   //       }):Center(child: CircularProgressIndicator(),),
                    //   // ),
                    // ),

                    SizedBox(
                      height: 30.h,
                    ),
                    Text(
                      "Let’s Start",
                      style: textTheme.headlineMedium!
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(
                      height: 24.h,
                    ),
                    GestureDetector(
                        onTap: () {
                          Get.to(() => MeasureMentScreen());
                        },
                        child: containerWidget(const Color(0xffFCE4D1),
                            "My Weekly Report", MyImgs.myWeeklyReport)),
                    SizedBox(
                      height: 20.h,
                    ),
                    GestureDetector(
                        onTap: () {
                          Get.to(() => MyDailyMeal(
                                isAnnouceMent: true,
                              ));
                        },
                        child: containerWidget(const Color(0xffCCF2FE),
                            "Give Feedback", MyImgs.aboutUs)),
                    // SizedBox(
                    //   height: 20.h,
                    // ),
                    // GestureDetector(
                    //     onTap: () {
                    //       Get.to(() => MyDailyMeal(
                    //             isAnnouceMent: true,
                    //           ));
                    //     },
                    //     child: containerWidget(const Color(0xffCCF2FE),
                    //         "Announcements", MyImgs.annoucements)),
                    SizedBox(
                      height: 20.h,
                    ),
                    // GestureDetector(
                    //     onTap: () {
                    //       Get.to(() => EditUser());
                    //     },
                    //     child: containerWidget(const Color(0xffCCF2FE),
                    //         "Account Settings", MyImgs.sendIcon)),
                    // SizedBox(
                    //   height: 20.h,
                    // ),
                    // GestureDetector(
                    //     onTap: () {
                    //       //Get.to(() => SessionScreen());
                    //     },
                    //     child: containerWidget(const Color(0xffFFF1FE),
                    //         "Join Live Session", MyImgs.joinLive)),
                    SizedBox(
                      height: 16.h,
                    ),
                  ],
                ),
              )
            : const CircularProgress(),
      ),
    );
  }
}
