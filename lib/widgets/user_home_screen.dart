import 'package:fitness_zone_2/UI/dashboard_module/home_screen/notification_screen.dart';
import 'package:fitness_zone_2/UI/dashboard_module/profile_screen/profile_screen_user.dart';
import 'package:fitness_zone_2/UI/diet_screen/diet_module.dart';
import 'package:fitness_zone_2/UI/freee_test_module/free_test.dart';
import 'package:fitness_zone_2/UI/freee_test_module/my_journey_screen.dart';
import 'package:fitness_zone_2/UI/health_tips_module/health_tips_screen.dart';
import 'package:fitness_zone_2/UI/plans_module/all_plans.dart';
import 'package:fitness_zone_2/UI/plans_module/invoice_screen.dart';
import 'package:fitness_zone_2/UI/plans_module/view_details.dart';
import 'package:fitness_zone_2/UI/workout_module/workout_screen.dart';
import 'package:fitness_zone_2/values/values.dart';
import 'package:fitness_zone_2/widgets/circular_progress.dart';
import 'package:fitness_zone_2/widgets/custom_button.dart';
import 'package:fitness_zone_2/widgets/gradient_border_container.dart';
import 'package:fitness_zone_2/widgets/plan_widget.dart';
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
  ScrollController userHomeScreenScrollController = ScrollController();
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
    return GetBuilder<HomeController>(builder: (cont) {
      return SingleChildScrollView(
          controller: userHomeScreenScrollController,
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
                        bottom:
                            authController.logInUser!.status ? 155.h : 25.h),
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
                                        : homeController.userHomeData!
                                            .userAllPlans[0].title,
                                style: textTheme.titleLarge!.copyWith(
                                    color: Colors.white.withOpacity(0.8),
                                    fontWeight: FontWeight.w500),
                              );
                            }),
                            Text(
                              "${authController.logInUser!.status ? "" : "Not "}Subscribed",
                              style: textTheme.headlineSmall!.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
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
                                  if (authController.logInUser!.status)
                                    GestureDetector(
                                      onTap: () {
                                        Get.to(() => InvoiceScreen());
                                      },
                                      child: Icon(
                                        Icons.inventory_2_outlined,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Get.to(() => NotificationScreen());
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
                                  homeController.getPlansUser();
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
                  if (authController.logInUser!.status &&
                      homeController.userHomeData?.userAllPlans.first.title !=
                          "Free Trial")
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
                              inputFormatters: FilteringTextInputFormatter
                                  .singleLineFormatter,
                              suffixIcon: GestureDetector(
                                onTap: () async {
                                  if (homeController.userHomeData!.userData
                                      .usedFreezeOption.value) {
                                    CustomToast.failToast(
                                        msg:
                                            "You have already used this option");
                                    return;
                                  }

                                  final DateTime? picked = await showDatePicker(
                                      context: context,
                                      builder: (BuildContext context,
                                          Widget? child) {
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
                                      lastDate: DateTime.now().add(Duration(
                                          days: homeController.userHomeData!
                                              .userAllPlans[0].remainingDays)));
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
                          Obx(
                            () => homeController.userHomeLoad.value
                                ? GestureDetector(
                                    onTap: () {
                                      if (homeController.userHomeData!.userData
                                          .usedFreezeOption.value) {
                                        CustomToast.failToast(
                                            msg:
                                                "You have already used this option");
                                        return;
                                      }
                                      if (homeController.userHomeData!.userData
                                          .freeze.value) {
                                        homeController.freezeMyAccount(false);
                                      } else {
                                        if (authController.dateExtendController
                                            .text.isEmpty) {
                                          CustomToast.failToast(
                                              msg: "Please enter freeze days");
                                        } else {
                                          homeController.freezeMyAccount(true);
                                        }
                                      }
                                    },
                                    child: GetBuilder<HomeController>(
                                      id: 'freezeButton', // Assigning an ID
                                      builder: (cont) {
                                        return Container(
                                          alignment: Alignment.center,
                                          width: 100.w,
                                          height: 56.h,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: MyColors.buttonColor,
                                          ),
                                          child: Text(
                                            cont.userHomeData!.userData.freeze
                                                    .value
                                                ? "Unfreeze"
                                                : "Freeze",
                                            style: textTheme.bodySmall,
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : SizedBox(),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.25,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                          horizontal: 30.w, vertical: 15.h),
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
                                  : index == 2
                                      ? Constants.PSYCHIATRIST
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
                                    child: SvgPicture.asset(
                                        textList[index]["image"]!)),
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
                              height: 280,
                              autoPlay: true,
                              viewportFraction: 0.7,
                              enlargeFactor: 0.3,
                              enlargeCenterPage: true,
                              enlargeStrategy: CenterPageEnlargeStrategy.scale,
                            ),
                            items:
                                homeController.allPlanModel!.plans.map((plan) {
                              return Builder(
                                builder: (BuildContext context) {
                                  if (plan.countries!.isNotEmpty) {
                                    if (plan.countries!.first.duration!
                                        .isNotEmpty) {
                                      plan.selectedDurationId.value = plan
                                          .countries!.first.duration!.first.id!;
                                    }
                                  }
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
                  // Obx(() => homeController.getTeamMembersLoad.value
                  //     ?

                  CarouselSlider(
                      options: CarouselOptions(
                          height: 250.h,
                          autoPlay: true,
                          viewportFraction: 0.7,
                          enlargeFactor: 0.3,
                          enlargeCenterPage: true,
                          enlargeStrategy: CenterPageEnlargeStrategy.scale),
                      items: homeController.team
                          .map((member) => Builder(
                                builder: (BuildContext context) {
                                  return ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.asset(member));
                                },
                              ))
                          .toList()),
                  //  : CircularProgress()),
                  SizedBox(
                    height: 20.h,
                  ),
                ],
              ),
              authController.logInUser!.status
                  ? Positioned(
                      top: 160,
                      left: 19,
                      right: 19,
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width - 38,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color: MyColors.primaryGradient1),
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
                                                      fontWeight:
                                                          FontWeight.w600)),
                                        ],
                                      ),
                                      // SizedBox(
                                      //   height: 30.h,
                                      // ),
                                      //
                                      // SizedBox(
                                      //   height: 30.h,
                                      // )
                                      SizedBox(
                                        height: 150.h,
                                      ),
                                    ],
                                  )
                                : const Center(
                                    child: CircularProgress(),
                                  )),
                          ),
                          Obx(() => homeController.userHomeLoad.value
                              ? homeController
                                      .userHomeData!.userAllPlans.isNotEmpty
                                  ? Positioned(
                                      top: 20,
                                      child: CircularPercentIndicator(
                                        radius: 120.0,
                                        lineWidth: 30.0,
                                        // fillColor: Colors.red,
                                        percent: homeController.getPlanValue(),

                                        progressColor: homeController
                                                    .userHomeData!
                                                    .userAllPlans[0]
                                                    .remainingDays >
                                                0
                                            ? MyColors.primaryGradient1
                                            : Colors.red,
                                        arcBackgroundColor: MyColors.planColor,
                                        // fillColor:MyColors.planColor,
                                        circularStrokeCap:
                                            CircularStrokeCap.round,
                                        startAngle: 180.0,

                                        arcType: ArcType.HALF,
                                      ),
                                    )
                                  : SizedBox()
                              : Center(
                                  child: CircularProgress(),
                                )),
                          Obx(() => homeController.userHomeLoad.value
                              ? homeController
                                      .userHomeData!.userAllPlans.isEmpty
                                  ? SizedBox()
                                  : homeController.userHomeData!.userAllPlans[0]
                                              .remainingDays >
                                          0
                                      ? Positioned(
                                          bottom: 20,
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: 30,
                                              ),
                                              Row(
                                                // mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
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
                                            ],
                                          ),
                                        )
                                      : Positioned(
                                          bottom: 20,
                                          left: 20,
                                          right: 20,
                                          child: CustomButton(
                                              text: "Renew Plan",
                                              onPressed: () {
                                                scrollToPosition(
                                                    userHomeScreenScrollController
                                                            .position
                                                            .maxScrollExtent /
                                                        1.2);
                                              }),
                                        )
                              : CircularProgress())
                        ],
                      ),
                    )
                  : const SizedBox.shrink()
            ],
          ));
    });
  }

  void scrollToPosition(double position) {
    userHomeScreenScrollController.animateTo(
      position, // Position to scroll to (e.g., screen height or any height)
      duration:
          const Duration(milliseconds: 500), // Duration for smooth scrolling
      curve: Curves.easeInOut, // Scrolling curve
    );
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
