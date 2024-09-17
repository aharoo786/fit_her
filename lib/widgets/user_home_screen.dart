import 'package:fitness_zone_2/UI/dashboard_module/home_screen/notification_screen.dart';
import 'package:fitness_zone_2/UI/dashboard_module/profile_screen/profile_screen_user.dart';
import 'package:fitness_zone_2/UI/diet_screen/diet_module.dart';
import 'package:fitness_zone_2/UI/freee_test_module/free_test.dart';
import 'package:fitness_zone_2/UI/freee_test_module/my_journey_screen.dart';
import 'package:fitness_zone_2/UI/health_tips_module/health_tips_screen.dart';
import 'package:fitness_zone_2/UI/plans_module/all_plans.dart';
import 'package:fitness_zone_2/UI/plans_module/view_details.dart';
import 'package:fitness_zone_2/UI/workout_module/workout_screen.dart';
import 'package:fitness_zone_2/values/values.dart';
import 'package:fitness_zone_2/widgets/circular_progress.dart';
import 'package:fitness_zone_2/widgets/gradient_border_container.dart';
import 'package:fitness_zone_2/widgets/plan_widget.dart';
import 'package:fitness_zone_2/widgets/review_cardd.dart';
import 'package:fitness_zone_2/widgets/toasts.dart';
import 'package:flutter/widgets.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../data/controllers/auth_controller/auth_controller.dart';
import '../data/controllers/home_controller/home_controller.dart';
import '../values/my_colors.dart';
import '../values/my_imgs.dart';
import 'package:get/get.dart';
import 'border_titlle_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'custom_textfield.dart';

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
  final List<Map<String, String>> textList = [
    {"text": "Workouts", "image": MyImgs.workoutHome},
    {"text": "Diet Plans", "image": MyImgs.dietPlanHome},
    {"text": "Mental Help", "image": MyImgs.mentalHelpHome},
    {"text": "Gynae", "image": MyImgs.GynaeHome},
    {"text": "Free Test", "image": MyImgs.freeTestHome},
    {"text": "Health Tips", "image": MyImgs.healthTips},
    {"text": "Cooperates", "image": MyImgs.team},
    {"text": "Our Journey", "image": MyImgs.ourJourney},
  ];
  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return SingleChildScrollView(
        child: Stack(
      children: [
        Column(
          children: [
            Container(
              // height: 100,
              padding: EdgeInsets.only(
                  top: 30.h,
                  left: 20.w,
                  right: 20.w,
                  bottom: authController.logInUser!.status ? 155.h : 25.h),
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: MyColors.mainGradient),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Get.to(() => ProfileScreenUser());
                            },
                            child: Container(
                                height: 60.h,
                                width: 60.h,
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: MyColors.primaryGradient1,
                                ),
                                child: Image.asset(
                                  MyImgs.logo,
                                  height: 40,
                                )),
                          ),
                          SizedBox(
                            width: 8.w,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Hey!",
                                style: textTheme.titleLarge!.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500),
                              ),
                              Text(
                                "${authController.logInUser!.firstName} ${authController.logInUser!.lastName}",
                                style: textTheme.titleLarge!.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      GetBuilder<HomeController>(builder: (co) {
                        return Text(
                          homeController.userHomeData == null
                              ? "No Plan"
                              : homeController
                                      .userHomeData!.userAllPlans.isEmpty
                                  ? "No Plan"
                                  : homeController
                                      .userHomeData!.userAllPlans[0].title,
                          style: textTheme.titleLarge!.copyWith(
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w500),
                        );
                      }),
                      Text(
                        "${authController.logInUser!.status ? "" : "Not "}Subscribed",
                        style: textTheme.headlineSmall!.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.to(() => ViewDetails());
                        },
                        child: Row(
                          children: [
                            Text(
                              "View Details   ",
                              style: textTheme.titleLarge!.copyWith(
                                  color: Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.w500),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white.withOpacity(0.8),
                              size: 10,
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          // mainAxisSize: MainAxisSize.min,
                          children: [
                            // Icon(
                            //   Icons.shopping_cart,
                            //   color: Colors.white,
                            //   size: 30,
                            // ),
                            // SizedBox(
                            //   width: 10,
                            // ),
                            GestureDetector(
                              onTap: () {
                                Get.to(()=>NotificationScreen());
                              },
                              child: Icon(
                                Icons.notifications_none,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),

                            //Image.asset(MyImgs.graph, height: 109.h, width: 143.w)
                          ],
                        ),
                        SizedBox(height: 30),
                        MaterialButton(
                          color: MyColors.primaryGradient3,
                          textColor: Colors.white,
                          onPressed: () {
                            homeController.getPlans();
                            Get.to(() => OurPlansScreen());
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Our Plans",
                                style: textTheme.titleLarge!.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                              ),

                              SizedBox(width: 5.w), // Add some spacing
                              Icon(
                                Icons.arrow_downward,
                                size: 15.w,
                                weight: 20,
                                grade: 20,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: authController.logInUser!.status ? 185 : 0,
            ),
            if (authController.logInUser!.status)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        keyboardType: TextInputType.text,
                        text: "Duration Freeze".tr,
                        length: 30,
                        controller: authController.dateExtendController,
                        Readonly: true,
                        bordercolor: MyColors.primaryGradient1,
                        inputFormatters:
                            FilteringTextInputFormatter.singleLineFormatter,
                        suffixIcon: GestureDetector(
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                                context: context,
                                builder: (BuildContext context, Widget? child) {
                                  return Theme(
                                    data: ThemeData.light().copyWith(
                                      primaryColor: MyColors
                                          .buttonColor, // OK button background color
                                      hintColor: MyColors
                                          .buttonColor, // OK button text color
                                      dialogBackgroundColor: Colors
                                          .white, // Dialog background color
                                    ),
                                    child: child!,
                                  );
                                },
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2099));
                            if (picked != null) {
                              authController.dateExtendController.text =
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
                        if (authController.dateExtendController.text.isEmpty) {
                          CustomToast.failToast(
                              msg: "Please enter freeze days");
                        } else {
                          Get.find<HomeController>().freezeMyAccount();
                        }
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: 100.w,
                        height: 56.h,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: MyColors.buttonColor),
                        child: Text(
                          "Update",
                          style: textTheme.bodySmall,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.25,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 15.h),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, // Number of children per row
                    crossAxisSpacing: 20.w, // Spacing between columns
                    mainAxisSpacing: 14.h,
                    childAspectRatio: 0.85 // Spacing between rows
                    ),
                itemCount: 8, // Total number of items
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      if (index == 0) {
                        Get.to(() => WorkoutScreen(
                              isProduct: index == 6,
                            ));
                        homeController
                            .getUsersBasedOnUserType(Constants.trainer);
                      } else if (index == 1 || index == 2 || index == 3) {
                        Get.to(() => DietScreen());
                        homeController.getUsersBasedOnUserType(index == 3
                            ? Constants.GYNECOLOGIST
                            : Constants.dietitian);
                      } else if (index == 4) {
                        Get.to(() => FreeTest());
                      } else if (index == 5) {
                        Get.to(() => HealthTipsScreen());
                        homeController.getHealthTips();
                      } else if (index == 7) {
                        Get.to(() => OurJourneyScreen());
                      } else if (index == 6) {
                        CustomToast.successToast(
                            msg: "Coming soon! Stay tuned");
                      }
                    },
                    child: Column(
                      children: [
                        Expanded(
                            child: GradientBorderContainer(
                          child: Center(
                              child:
                                  SvgPicture.asset(textList[index]["image"]!)),
                        )),
                        SizedBox(
                          height: 4.h,
                        ),
                        Text(
                          textList[index]["text"]!,
                          style: textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.w500,
                              color: MyColors.primaryGradient3),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20.h),
            const BorderTitleWidget(
              text: "Top Sellers Plans",
            ),
            SizedBox(height: 20.h),
            SizedBox(
              height: 270.h,
              child: Obx(() => homeController.getPlanLoaded.value
                  ? CarouselSlider(
                      options: CarouselOptions(
                        height: 250.h,
                        autoPlay: true,
                        viewportFraction: 0.7,
                        enlargeFactor: 0.3,
                        enlargeCenterPage: true,
                        enlargeStrategy: CenterPageEnlargeStrategy.scale,
                      ),
                      items: homeController.allPlanModel!.plans.map((plan) {
                        return Builder(
                          builder: (BuildContext context) {
                            return PlanWidget(
                              plan: plan,
                            );
                          },
                        );
                      }).toList(),
                    )
                  : const CircularProgress()),
            ),
            // SizedBox(height: 40.h),
            // const BorderTitleWidget(
            //   text: "Our Clients Love Us",
            // ),
            // SizedBox(height: 20.h),
            // SizedBox(
            //   height: 145.h,
            //   child: ListView.builder(
            //     padding: EdgeInsets.symmetric(vertical: 8.h),
            //     shrinkWrap: true,
            //     scrollDirection: Axis.horizontal,
            //     itemCount: 5, // Number of stars (you can make this dynamic)
            //     itemBuilder: (context, index) {
            //       return ReviewCard(
            //         isLast: index == 4,
            //       );
            //     },
            //   ),
            // ),
            SizedBox(height: 40.h),
            const BorderTitleWidget(
              text: "Our Team",
            ),
            SizedBox(height: 20.h),
            Obx(() => homeController.getTeamMembersLoad.value
                ? CarouselSlider(
                    options: CarouselOptions(
                        height: 250.h,
                        autoPlay: true,
                        viewportFraction: 0.7,
                        enlargeFactor: 0.3,
                        enlargeCenterPage: true,
                        enlargeStrategy: CenterPageEnlargeStrategy.scale),
                    items: homeController.getTeamMembers?.data
                        .map((member) => Builder(
                              builder: (BuildContext context) {
                                return member.image == null
                                    ? Image.asset(MyImgs.ourTeam)
                                    : Image.network(
                                        "${Constants.baseUrl}/${member.image!}");
                              },
                            ))
                        .toList())
                : CircularProgress()),
            SizedBox(
              height: 20.h,
            ),
            // Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 20.w),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       SizedBox(
            //         height: 20.h,
            //       ),
            //       Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           Container(
            //             padding: EdgeInsets.symmetric(
            //                 horizontal: 45.w, vertical: 10.h),
            //             decoration: BoxDecoration(
            //               borderRadius: BorderRadius.circular(8),
            //               color: Colors.white,
            //               boxShadow: [
            //                 BoxShadow(
            //                   color: Colors.grey.withOpacity(0.4),
            //                   blurRadius: 22.0,
            //                   spreadRadius: 0.0,
            //                   offset: const Offset(0.0,
            //                       0.0), // shadow direction: bottom right
            //                 )
            //               ],
            //             ),
            //             child: Column(
            //               children: [
            //                 Row(
            //                   children: [
            //                     Image.asset(
            //                       MyImgs.body,
            //                       scale: 4,
            //                     ),
            //                     SizedBox(
            //                       width: 5.w,
            //                     ),
            //                     Text(
            //                       "Finished",
            //                       style: textTheme.bodyMedium!.copyWith(
            //                           fontWeight: FontWeight.w500),
            //                     ),
            //                   ],
            //                 ),
            //                 Text(
            //                     "${homeController.userHomeData!.remainingDays} days",
            //                     style: textTheme.bodyMedium!.copyWith(
            //                         fontWeight: FontWeight.w500,
            //                         fontSize: 24.sp)),
            //                 Text(
            //                   "Remaining\nDays",
            //                   style: textTheme.bodyMedium!.copyWith(
            //                       fontWeight: FontWeight.w400,
            //                       fontSize: 14.sp,
            //                       color: MyColors.black.withOpacity(0.6)),
            //                   textAlign: TextAlign.center,
            //                 ),
            //               ],
            //             ),
            //           ),
            //           SizedBox(
            //             width: 10.w,
            //           ),
            //           Expanded(
            //             child: Container(
            //               padding: EdgeInsets.only(
            //                 left: 12.w,
            //                 top: 8.h,
            //                 bottom: 8.h,
            //               ),
            //               decoration: BoxDecoration(
            //                 borderRadius: BorderRadius.circular(8),
            //                 color: Colors.white,
            //                 boxShadow: [
            //                   BoxShadow(
            //                     color: Colors.grey.withOpacity(0.4),
            //                     blurRadius: 22.0,
            //                     spreadRadius: 0.0,
            //                     offset: const Offset(0.0,
            //                         0.0), // shadow direction: bottom right
            //                   )
            //                 ],
            //               ),
            //               child: Column(
            //                 crossAxisAlignment: CrossAxisAlignment.start,
            //                 children: [
            //                   Row(
            //                     children: [
            //                       Image.asset(
            //                         MyImgs.calender2,
            //                         scale: 4,
            //                       ),
            //                       SizedBox(
            //                         width: 5.w,
            //                       ),
            //                       Text(
            //                         "Days Spend",
            //                         style: textTheme.bodySmall!.copyWith(
            //                             fontWeight: FontWeight.w400),
            //                       ),
            //                     ],
            //                   ),
            //                   RichText(
            //                       text: TextSpan(
            //                           text:
            //                               "${homeController.userHomeData!.spendDays}",
            //                           style:
            //                               textTheme.bodyLarge!.copyWith(
            //                             fontWeight: FontWeight.w500,
            //                           ),
            //                           children: [
            //                         TextSpan(
            //                             text: " days",
            //                             style: textTheme.bodySmall!
            //                                 .copyWith(
            //                                     fontWeight:
            //                                         FontWeight.w400,
            //                                     color: Colors.black
            //                                         .withOpacity(0.4)))
            //                       ]))
            //                 ],
            //               ),
            //             ),
            //           )
            //         ],
            //       ),
            //
            //       SizedBox(
            //         height: 20.h,
            //       ),
            //       Text(
            //         "Your Plan",
            //         style: textTheme.headlineMedium!
            //             .copyWith(fontWeight: FontWeight.w600),
            //       ),
            //
            //       SizedBox(
            //         height: 150.h,
            //         child: ListView.separated(
            //           padding: EdgeInsets.symmetric(vertical: 20.h),
            //           itemCount: 1,
            //           scrollDirection: Axis.horizontal,
            //           itemBuilder: (BuildContext context, int index) {
            //             return GestureDetector(
            //               onTap: () {
            //                 if (homeController.userHomeData!.freeze ==
            //                     1) {
            //                   CustomToast.failToast(
            //                       msg:
            //                           "You plan has been frozen make request to the admin to unfreeze you ");
            //                 } else {
            //                   Get.to(() => MyPlanScreen());
            //                 }
            //               },
            //               child: Container(
            //                 width: 300.w,
            //                 padding: const EdgeInsets.all(10),
            //                 decoration: BoxDecoration(
            //                     color: Colors.white,
            //                     borderRadius: BorderRadius.circular(16),
            //                     boxShadow: [
            //                       BoxShadow(
            //                           offset: Offset(0, 2),
            //                           blurRadius: 4,
            //                           color:
            //                               Colors.black.withOpacity(0.1))
            //                     ]),
            //                 child: Row(children: [
            //                   SizedBox(
            //                     width: 70.w,
            //                     child: Image.asset(MyImgs.logo),
            //                   ),
            //                   SizedBox(
            //                     width: 10.w,
            //                   ),
            //                   Expanded(
            //                     child: Column(
            //                       crossAxisAlignment:
            //                           CrossAxisAlignment.start,
            //                       children: [
            //                         Text(
            //                           homeController.userHomeData!.title,
            //                           style: textTheme.headlineSmall!
            //                               .copyWith(
            //                             fontWeight: FontWeight.w500,
            //                           ),
            //                           maxLines: 1,
            //                           overflow: TextOverflow.ellipsis,
            //                         ),
            //                         Text(
            //                           homeController
            //                               .userHomeData!.shortDescription,
            //                           style:
            //                               textTheme.bodySmall!.copyWith(),
            //                           maxLines: 1,
            //                           overflow: TextOverflow.ellipsis,
            //                         ),
            //                         Text(
            //                           "PKR ${homeController.userHomeData!.price}",
            //                           style:
            //                               textTheme.bodyLarge!.copyWith(
            //                             fontWeight: FontWeight.w500,
            //                           ),
            //                         ),
            //                       ],
            //                     ),
            //                   )
            //                 ]),
            //               ),
            //             );
            //           },
            //           separatorBuilder:
            //               (BuildContext context, int index) {
            //             return SizedBox(
            //               width: 10.w,
            //             );
            //           },
            //         ),
            //       ),
            //       SizedBox(
            //         height: 20.h,
            //       ),
            //       homeController.userHomeData!.freeze == 0
            //           ? Column(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               children: [
            //                 Text(
            //                   "Freeze Plan",
            //                   style: textTheme.headlineMedium!
            //                       .copyWith(fontWeight: FontWeight.w700),
            //                 ),
            //                 SizedBox(
            //                   height: 10.h,
            //                 ),
            //                 Row(
            //                   children: [
            //                     Expanded(
            //                       child: CustomTextField(
            //                         keyboardType: TextInputType.text,
            //                         text: "Duration Freeze".tr,
            //                         length: 30,
            //                         controller: authController
            //                             .dateExtendController,
            //                         Readonly: true,
            //                         inputFormatters:
            //                             FilteringTextInputFormatter
            //                                 .singleLineFormatter,
            //                         suffixIcon: GestureDetector(
            //                           onTap: () async {
            //                             final DateTime? picked =
            //                                 await showDatePicker(
            //                                     context: context,
            //                                     builder:
            //                                         (BuildContext context,
            //                                             Widget? child) {
            //                                       return Theme(
            //                                         data:
            //                                             ThemeData.light()
            //                                                 .copyWith(
            //                                           primaryColor: MyColors
            //                                               .buttonColor, // OK button background color
            //                                           hintColor: MyColors
            //                                               .buttonColor, // OK button text color
            //                                           dialogBackgroundColor:
            //                                               Colors
            //                                                   .white, // Dialog background color
            //                                         ),
            //                                         child: child!,
            //                                       );
            //                                     },
            //                                     initialDate:
            //                                         DateTime.now(),
            //                                     firstDate: DateTime.now(),
            //                                     lastDate: DateTime(2099));
            //                             if (picked != null) {
            //                               authController
            //                                       .dateExtendController
            //                                       .text =
            //                                   "${picked.difference(DateTime.now()).inDays} days";
            //                             }
            //                           },
            //                           child: Image.asset(
            //                             MyImgs.calender2,
            //                             scale: 3,
            //                           ),
            //                         ),
            //                       ),
            //                     ),
            //                     SizedBox(
            //                       width: 10.w,
            //                     ),
            //                     GestureDetector(
            //                       onTap: () {
            //                         if (authController
            //                             .dateExtendController
            //                             .text
            //                             .isEmpty) {
            //                           CustomToast.failToast(
            //                               msg:
            //                                   "Please enter freeze days");
            //                         } else {
            //                           Get.find<HomeController>()
            //                               .freezeMyAccount();
            //                         }
            //                       },
            //                       child: Container(
            //                         alignment: Alignment.center,
            //                         width: 100.w,
            //                         height: 56.h,
            //                         decoration: BoxDecoration(
            //                             borderRadius:
            //                                 BorderRadius.circular(10),
            //                             color: MyColors.buttonColor),
            //                         child: Text(
            //                           "Update",
            //                           style: textTheme.bodySmall,
            //                         ),
            //                       ),
            //                     ),
            //                   ],
            //                 ),
            //                 SizedBox(
            //                   height: 20.h,
            //                 ),
            //               ],
            //             )
            //           : SizedBox.shrink(),
            //
            //       CustomButton(
            //           text: "Chat Support",
            //           onPressed: () async {
            //             String roomId = (Get.find<AuthController>()
            //                         .logInUser!
            //                         .id
            //                         .toString()
            //                         .hashCode +
            //                     Get.find<AuthController>()
            //                         .logInUser!
            //                         .adminId
            //                         .toString()
            //                         .hashCode)
            //                 .toString();
            //             var userMap = await FirebaseFirestore.instance
            //                 .collection("users")
            //                 .doc(authController.logInUser!.adminId
            //                     .toString())
            //                 .get();
            //             print("usermap ${userMap.data()}");
            //             Get.to(() => ChatRoom(
            //                   chatRoomId: roomId,
            //                   userMap: userMap.data()!,
            //                 ));
            //           }),
            //       SizedBox(
            //         height: 20.h,
            //       ),
            //
            //       Text(
            //         "Reviews",
            //         style: textTheme.headlineMedium!
            //             .copyWith(fontWeight: FontWeight.w600),
            //       ),
            //       SizedBox(
            //         height: 10.h,
            //       ),
            //       CarouselSlider(
            //         options:
            //             CarouselOptions(height: 200.h, autoPlay: true),
            //         items:
            //             homeController.userHomeData!.testimonial.map((i) {
            //           return Builder(
            //             builder: (BuildContext context) {
            //               return Container(
            //                 width: MediaQuery.of(context).size.width,
            //                 margin: EdgeInsets.symmetric(
            //                     horizontal: 5.0, vertical: 10.h),
            //                 decoration: BoxDecoration(
            //                     color: Colors.white,
            //                     boxShadow: [
            //                       BoxShadow(
            //                           offset: const Offset(0, 2),
            //                           blurRadius: 4,
            //                           color:
            //                               Colors.black.withOpacity(0.1))
            //                     ],
            //                     borderRadius: BorderRadius.circular(8),
            //                     image: DecorationImage(
            //                         image: NetworkImage(
            //                             "${Constants.baseUrl}/${i.image}"))),
            //               );
            //             },
            //           );
            //         }).toList(),
            //       ),
            //
            //       SizedBox(
            //         height: 30.h,
            //       ),
            //       Stack(
            //         alignment: Alignment.centerRight,
            //         children: [
            //           Column(
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: [
            //               Text(
            //                 "Important Tips",
            //                 style: textTheme.headlineMedium!
            //                     .copyWith(fontWeight: FontWeight.w700),
            //               ),
            //               SizedBox(
            //                 height: 20.h,
            //               ),
            //               Container(
            //                 //height: 140.h,
            //                 padding: EdgeInsets.symmetric(
            //                     horizontal: 16.w, vertical: 26.h),
            //                 decoration: BoxDecoration(
            //                     color: const Color(0xfffcd8e0),
            //                     borderRadius: BorderRadius.circular(8)),
            //                 child: Row(
            //                   children: [
            //                     Column(
            //                       children: [
            //                         Text(
            //                           "Tips for Achieving \nYour Fitness Goals",
            //                           style: textTheme.headlineSmall!
            //                               .copyWith(
            //                                   fontWeight: FontWeight.w500,
            //                                   color: const Color(
            //                                       0xff4A4A4A)),
            //                         ),
            //                         SizedBox(
            //                           height: 20.h,
            //                         ),
            //                         GestureDetector(
            //                           onTap: () {
            //                             Get.to(() => ImportantScreen());
            //                           },
            //                           child: Row(
            //                             children: [
            //                               Text(
            //                                 "Explore",
            //                                 style: textTheme.bodyMedium!
            //                                     .copyWith(
            //                                         fontWeight:
            //                                             FontWeight.w500,
            //                                         color: const Color(
            //                                             0xff175A87)),
            //                               ),
            //                               SizedBox(
            //                                 width: 15.w,
            //                               ),
            //                               Icon(Icons.arrow_forward,
            //                                   color: const Color(
            //                                       0xff175A87)),
            //                             ],
            //                           ),
            //                         ),
            //                       ],
            //                     ),
            //                   ],
            //                 ),
            //               )
            //             ],
            //           ),
            //           Image.asset(
            //             MyImgs.womanImage,
            //             scale: 2.93,
            //             fit: BoxFit.cover,
            //           ),
            //         ],
            //       ),
            //       // SizedBox(
            //       //   height: 20.h,
            //       // ),
            //       // Text(
            //       //   "Our Plans",
            //       //   style: textTheme.headlineMedium!
            //       //       .copyWith(fontWeight: FontWeight.w600),
            //       // ),
            //       //
            //       // SizedBox(
            //       //   height: 150.h,
            //       //   child: ListView.separated(
            //       //     padding: EdgeInsets.symmetric(vertical: 20.h),
            //       //     itemCount: 3,
            //       //     scrollDirection: Axis.horizontal,
            //       //     itemBuilder: (BuildContext context, int index) {
            //       //       return GestureDetector(
            //       //         onTap: () {
            //       //           Get.to(() => Payment());
            //       //         },
            //       //         child: Container(
            //       //           width: 300.w,
            //       //           padding: const EdgeInsets.all(10),
            //       //           decoration: BoxDecoration(
            //       //               color: Colors.white,
            //       //               borderRadius: BorderRadius.circular(16),
            //       //               boxShadow: [
            //       //                 BoxShadow(
            //       //                     offset: Offset(0, 2),
            //       //                     blurRadius: 4,
            //       //                     color: Colors.black.withOpacity(0.1))
            //       //               ]),
            //       //           child: Row(children: [
            //       //             SizedBox(
            //       //               width: 70.w,
            //       //               child: Image.asset(MyImgs.logo),
            //       //             ),
            //       //             SizedBox(
            //       //               width: 10.w,
            //       //             ),
            //       //             Expanded(
            //       //               child: Column(
            //       //                 crossAxisAlignment: CrossAxisAlignment.start,
            //       //                 children: [
            //       //                   Text(
            //       //                     "Package ${index + 1}",
            //       //                     style: textTheme.headlineSmall!.copyWith(
            //       //                       fontWeight: FontWeight.w500,
            //       //                     ),
            //       //                   ),
            //       //                   Text(
            //       //                     "this is the description",
            //       //                     style: textTheme.bodySmall!.copyWith(),
            //       //                     maxLines: 3,
            //       //                     overflow: TextOverflow.ellipsis,
            //       //                   ),
            //       //                   Text(
            //       //                     "PKR ${100 * (index + 1)}",
            //       //                     style: textTheme.bodyLarge!.copyWith(
            //       //                       fontWeight: FontWeight.w500,
            //       //                     ),
            //       //                   ),
            //       //                 ],
            //       //               ),
            //       //             )
            //       //           ]),
            //       //         ),
            //       //       );
            //       //     },
            //       //     separatorBuilder: (BuildContext context, int index) {
            //       //       return SizedBox(
            //       //         width: 10.w,
            //       //       );
            //       //     },
            //       //   ),
            //       //
            //       //   // child: Obx(
            //       //   //     ()=>
            //       //   //     authController.homeDataLoad.value?
            //       //   //     ListView.builder(
            //       //   //       itemCount: authController.homeModel.plans.length,
            //       //   //       scrollDirection: Axis.horizontal,
            //       //   //       itemBuilder: (BuildContext context, int index) {
            //       //   //         return GestureDetector(
            //       //   //           onTap: () {
            //       //   //             // Get.to(() => Payment(
            //       //   //             //       plan: authController.homeModel.plans[index],
            //       //   //             //     ));
            //       //   //           },
            //       //   //           child: Container(
            //       //   //             width: 300.w,
            //       //   //             padding: const EdgeInsets.all(10),
            //       //   //             decoration: BoxDecoration(
            //       //   //                 color: Colors.white,
            //       //   //                 borderRadius: BorderRadius.circular(16),
            //       //   //                 boxShadow: [
            //       //   //                   BoxShadow(
            //       //   //                       offset: Offset(0, 2),
            //       //   //                       blurRadius: 22,
            //       //   //                       color: Colors.black.withOpacity(0.1))
            //       //   //                 ]),
            //       //   //             child: Row(children: [
            //       //   //               SizedBox(
            //       //   //                 width: 70.w,
            //       //   //                 child: Image.network(
            //       //   //                     "${Constants.baseUrl}/${authController.homeModel.plans[index].image}"),
            //       //   //               ),
            //       //   //               SizedBox(
            //       //   //                 width: 10.w,
            //       //   //               ),
            //       //   //               Expanded(
            //       //   //                 child: Column(
            //       //   //                   crossAxisAlignment: CrossAxisAlignment.start,
            //       //   //                   children: [
            //       //   //                     Text(
            //       //   //                       authController.homeModel.plans[index].title,
            //       //   //                       style: textTheme.headlineSmall!.copyWith(
            //       //   //                         fontWeight: FontWeight.w500,
            //       //   //                       ),
            //       //   //                     ),
            //       //   //                     Text(
            //       //   //                       authController
            //       //   //                           .homeModel.plans[index].longDescription,
            //       //   //                       style: textTheme.bodySmall!.copyWith(),
            //       //   //                       maxLines: 3,
            //       //   //                       overflow: TextOverflow.ellipsis,
            //       //   //                     ),
            //       //   //                     Text(
            //       //   //                       "PKR ${authController.homeModel.plans[index].price}",
            //       //   //                       style: textTheme.bodyLarge!.copyWith(
            //       //   //                         fontWeight: FontWeight.w500,
            //       //   //                       ),
            //       //   //                     ),
            //       //   //                   ],
            //       //   //                 ),
            //       //   //               )
            //       //   //             ]),
            //       //   //           ),
            //       //   //         );
            //       //   //       }):Center(child: CircularProgressIndicator(),),
            //       //   // ),
            //       // ),
            //
            //       SizedBox(
            //         height: 30.h,
            //       ),
            //       Text(
            //         "Let’s Start",
            //         style: textTheme.headlineMedium!
            //             .copyWith(fontWeight: FontWeight.w700),
            //       ),
            //       SizedBox(
            //         height: 24.h,
            //       ),
            //       GestureDetector(
            //           onTap: () {
            //             Get.to(() => MeasureMentScreen());
            //           },
            //           child: containerWidget(const Color(0xffFCE4D1),
            //               "My Weekly Report", MyImgs.myWeeklyReport)),
            //       SizedBox(
            //         height: 20.h,
            //       ),
            //       GestureDetector(
            //           onTap: () {
            //             Get.to(() => MyDailyMeal(
            //                   isAnnouceMent: true,
            //                 ));
            //           },
            //           child: containerWidget(const Color(0xffCCF2FE),
            //               "Give Feedback", MyImgs.aboutUs)),
            //       // SizedBox(
            //       //   height: 20.h,
            //       // ),
            //       // GestureDetector(
            //       //     onTap: () {
            //       //       Get.to(() => MyDailyMeal(
            //       //             isAnnouceMent: true,
            //       //           ));
            //       //     },
            //       //     child: containerWidget(const Color(0xffCCF2FE),
            //       //         "Announcements", MyImgs.annoucements)),
            //       SizedBox(
            //         height: 20.h,
            //       ),
            //       // GestureDetector(
            //       //     onTap: () {
            //       //       Get.to(() => EditUser());
            //       //     },
            //       //     child: containerWidget(const Color(0xffCCF2FE),
            //       //         "Account Settings", MyImgs.sendIcon)),
            //       // SizedBox(
            //       //   height: 20.h,
            //       // ),
            //       // GestureDetector(
            //       //     onTap: () {
            //       //       //Get.to(() => SessionScreen());
            //       //     },
            //       //     child: containerWidget(const Color(0xffFFF1FE),
            //       //         "Join Live Session", MyImgs.joinLive)),
            //       SizedBox(
            //         height: 16.h,
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
        authController.logInUser!.status
            ? Positioned(
                top: 160,
                left: 19,
                right: 19,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width - 38,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: MyColors.primaryGradient1),
                          borderRadius: BorderRadius.circular(25)),
                      child: Obx(() => homeController.userHomeLoad.value
                          ? Column(
                              children: [
                                SizedBox(
                                  height: 110.h,
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Days Spent",
                                      style: textTheme.bodyMedium!,
                                    ),
                                    Text(
                                        homeController.userHomeData!
                                                .userAllPlans.isEmpty
                                            ? "N/a"
                                            : "${homeController.userHomeData!.userAllPlans[0].spendDays}/${homeController.userHomeData!.userAllPlans[0].remainingDays + homeController.userHomeData!.userAllPlans[0].spendDays}",
                                        style: textTheme.headlineMedium!
                                            .copyWith(
                                                fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                SizedBox(
                                  height: 30.h,
                                ),
                                Row(
                                  // mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    daySpentWidget(
                                        textTheme,
                                        "${homeController.userHomeData!.userAllPlans[0].spendDays}",
                                        "Done"),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    daySpentWidget(
                                        textTheme,
                                        "${homeController.userHomeData!.userAllPlans[0].remainingDays}",
                                        "Remaining"),
                                  ],
                                ),
                                SizedBox(
                                  height: 30.h,
                                )
                              ],
                            )
                          : const Center(
                              child: CircularProgress(),
                            )),
                    ),
                    Obx(() => homeController.userHomeLoad.value
                        ? homeController.userHomeData!.userAllPlans.isNotEmpty
                            ? CircularPercentIndicator(
                                radius: 120.0,
                                lineWidth: 30.0,
                                // fillColor: Colors.red,
                                percent: homeController.userHomeData!
                                        .userAllPlans[0].spendDays /
                                    (homeController.userHomeData!
                                            .userAllPlans[0].remainingDays +
                                        homeController.userHomeData!
                                            .userAllPlans[0].spendDays),

                                progressColor: MyColors.primaryGradient1,
                                arcBackgroundColor: MyColors.planColor,
                                // fillColor:MyColors.planColor,
                                circularStrokeCap: CircularStrokeCap.round,
                                startAngle: 180.0,

                                arcType: ArcType.HALF,
                              )
                            : SizedBox()
                        : Center(
                            child: CircularProgress(),
                          )),
                  ],
                ),
              )
            : const SizedBox.shrink()
      ],
    ));
  }

  daySpentWidget(TextTheme textTheme, String text, String text1) {
    return Container(
      height: 100.h,
      width: 120.w,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15), color: MyColors.planColor),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: textTheme.headlineLarge!
                .copyWith(fontWeight: FontWeight.w600, fontSize: 36),
          ),
          Text(
            text1,
            style: textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
