import 'dart:convert';
import 'dart:ui';
import 'package:fitness_zone_2/UI/dashboard_module/bottom_bar_screen/diet_plans_of_user.dart';
import 'package:fitness_zone_2/UI/dashboard_module/bottom_bar_screen/progress_screen.dart';
import 'package:fitness_zone_2/UI/dashboard_module/bottom_bar_screen/workout_plans_of_user.dart';
import 'package:fitness_zone_2/UI/dashboard_module/posts_module/feed_screen.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/controllers/auth_controller/auth_controller.dart';
import '../../../data/controllers/home_controller/home_controller.dart';
import '../../../values/constants.dart';
import '../../../values/my_colors.dart';
import '../../../values/my_imgs.dart';
import '../../../widgets/review_bottom_sheet.dart';
import '../../chat/chat_home_screen.dart';
import '../home_screen/home_screen.dart';
import '../profile_screen/profile_screen.dart';

class BottomBarScreen extends StatefulWidget {
  int? index;
  BottomBarScreen({Key? key, this.index = 0, this.roomId, this.userMap}) : super(key: key);
  String? roomId;
  Map<String, dynamic>? userMap;

  @override
  State<BottomBarScreen> createState() => _BottomBarScreenState();
}

class _BottomBarScreenState extends State<BottomBarScreen> {
  late List<Widget> _widgetOption = [];
  AuthController authController = Get.find();
  @override
  void initState() {
    super.initState();
    if (authController.loginAsA.value == Constants.user) {
      Get.find<HomeController>().getPlansUser();
    }

    authController.showDot.value = authController.sharedPreferences.getBool("showDot") ?? false;
    _widgetOption = authController.loginAsA.value == Constants.admin
        ? [
            HomeScreen(),
            ChatHomeScreen(),
            ProfileScreen(),
          ]
        : authController.loginAsA.value == Constants.user
            ? [
                HomeScreen(),
                WorkPlansOfUser(),
                DietPlansOfUser(),
                ProgressScreen(),
                FeedScreen()
                // ChatRoom(
                //     chatRoomId: widget.roomId ?? "",
                //     userMap: widget.userMap ?? {}),
              ]
            : [
                HomeScreen(),
                ChatHomeScreen(),
                ProfileScreen(),
              ];

    if (authController.sharedPreferences.getBool("isFirstTime") == null) {
      WidgetsBinding.instance.addPostFrameCallback((value) {
        HelpingWidgets.showCustomDialog(context, () {
          authController.sharedPreferences.setBool("isFirstTime", false);
          Get.back();
        }, "Welcome to FitHer!", "We’re thrilled to have you on this journey. Let’s kickstart it to a healthier, happier you.", MyImgs.welcomeEmoji);
      });
    }
    if (authController.sharedPreferences.getString(Constants.announcementNotification) != null) {
      var announcement = jsonDecode(authController.sharedPreferences.getString(Constants.announcementNotification)!);
      DateTime announcementDate = DateTime.parse(announcement["date"]);
      Duration diff = DateTime.now().difference(announcementDate);

      // show if announcement is less than 1 day old
      if (diff.inDays == 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          HelpingWidgets.showCustomDialog(context, () {
            Get.back();
            authController.sharedPreferences.remove(Constants.announcementNotification);
          }, announcement["title"], announcement["body"], MyImgs.logo, buttonText: "Ok, Got It");
        });
      }
    }
    if (authController.sharedPreferences.getBool(Constants.giveReview) != null ||
        authController.sharedPreferences.getBool(Constants.giveReview) == true) {
      WidgetsBinding.instance.addPostFrameCallback((value) {
        authController.sharedPreferences.remove(Constants.giveReview);
        Get.bottomSheet(isScrollControlled: true, FeedbackBottomSheet("0", "0"));
      });
    }
  }

  // int _currentIndex = wi;

  var scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return Scaffold(
        // drawer: MyDrawer(),
        backgroundColor: MyColors.primaryColor,
        key: scaffoldKey,
        resizeToAvoidBottomInset: true,
        body: _widgetOption.elementAt(widget.index!),
        floatingActionButton: authController.logInUser!.status && Get.find<AuthController>().loginAsA.value == Constants.user && widget.index !=4
            ? FloatingActionButton(
                onPressed: () async {
                  final Uri whatsappUrl = Uri.parse(
                      'https://api.whatsapp.com/send/?phone=${Get.find<HomeController>().userHomeData?.customSupporter?.phone}&text&type=phone_number&app_absent=0');
                  try {
                    if (await canLaunchUrl(whatsappUrl)) {
                      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
                    } else {
                      await launchUrl(whatsappUrl);
                    }
                  } catch (e) {
                    print('Could not launch WhatsApp: $e');
                  }
                },
                backgroundColor: const Color(0xFF25D366), // WhatsApp green color
                child: SvgPicture.asset(
                  MyImgs.whatsappIcon,
                  width: 28,
                  height: 28,
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              )
            : null,
        floatingActionButtonLocation: authController.logInUser!.status && Get.find<AuthController>().loginAsA.value == Constants.user
            ? FloatingActionButtonLocation.endFloat
            : null,
        bottomNavigationBar: Get.find<AuthController>().loginAsA.value == Constants.user
            ? PreferredSize(
                preferredSize: Size.fromHeight(70.h),
                child: BottomNavigationBar(
                  elevation: 0,
                  backgroundColor: Colors.white,
                  currentIndex: widget.index!,

                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: Colors.white,
                  unselectedItemColor: MyColors.primaryGradient1,
                  unselectedIconTheme: const IconThemeData(color: MyColors.primaryGradient1),
                  unselectedLabelStyle: TextStyle(color: MyColors.primaryGradient1, fontWeight: FontWeight.w500, fontSize: 10.sp),

                  selectedIconTheme: const IconThemeData(color: MyColors.primaryColor),
                  selectedFontSize: 10.sp,
                  // selectedLabelStyle: TextStyle(fontSize: 0),
                  // selectedFontSize: 0,
                  // unselectedFontSize: 10,
                  // unselectedLabelStyle: const TextStyle(
                  //   fontFamily: 'Roboto',
                  // ),
                  // selectedLabelStyle: const TextStyle(
                  //   fontFamily: 'Roboto',
                  // ),
                  items: [
                    BottomNavigationBarItem(
                      icon: SvgPicture.asset(
                        MyImgs.homeSVG,
                        height: 30,
                      ),
                      activeIcon: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: MyColors.buttonColor),
                        child: SvgPicture.asset(
                          MyImgs.homeSVG,
                          height: 30,
                          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                        ),
                      ),
                      label: "Home",
                    ),
                    BottomNavigationBarItem(
                      icon: SvgPicture.asset(
                        MyImgs.workout,
                        height: 30,
                      ),
                      activeIcon: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: MyColors.buttonColor),
                        child: SvgPicture.asset(
                          MyImgs.workout,
                          height: 30,
                          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                        ),
                      ),
                      label: "Workout",
                    ),
                    BottomNavigationBarItem(
                      icon: SvgPicture.asset(
                        MyImgs.diet,
                        height: 30,
                      ),
                      activeIcon: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: MyColors.buttonColor),
                        child: SvgPicture.asset(
                          MyImgs.diet,
                          height: 30,
                          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                        ),
                      ),
                      label: "Diet",
                    ),
                    BottomNavigationBarItem(
                      icon: SvgPicture.asset(
                        MyImgs.progress,
                        height: 30,
                      ),
                      activeIcon: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: MyColors.buttonColor),
                        child: SvgPicture.asset(
                          MyImgs.progress,
                          height: 30,
                          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                        ),
                      ),
                      label: "Progress",
                    ),
                    BottomNavigationBarItem(
                      icon: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          SvgPicture.asset(
                            MyImgs.helpSVG,
                            height: 30,
                          ),
                          dotWidget()
                        ],
                      ),
                      activeIcon: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: MyColors.buttonColor),
                            child: SvgPicture.asset(
                              MyImgs.helpSVG,
                              height: 30,
                              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                            ),
                          ),
                          dotWidget()
                        ],
                      ),
                      label: "Community",
                    ),
                  ],
                  onTap: (value) async {
                    if (value == 3) {
                      authController.sharedPreferences.setBool("showDot", false);
                      authController.showDot.value = false;
                    }
                    setState(() {
                      widget.index = value;
                    });
                  },
                ),
              )
            : Container(
                padding: EdgeInsets.only(bottom: 20.h, left: 20, right: 20.w),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  child: PreferredSize(
                    preferredSize: Size.fromHeight(56.h),
                    child: BottomNavigationBar(
                      elevation: 0,
                      backgroundColor: MyColors.buttonColor,
                      currentIndex: widget.index!,
                      type: BottomNavigationBarType.fixed,
                      selectedItemColor: Colors.white,
                      unselectedItemColor: MyColors.black,
                      selectedFontSize: 0,
                      unselectedFontSize: 0,
                      selectedIconTheme: const IconThemeData(color: MyColors.primaryColor),
                      // unselectedLabelStyle: const TextStyle(
                      //   fontFamily: 'Roboto',
                      // ),
                      // selectedLabelStyle: const TextStyle(
                      //   fontFamily: 'Roboto',
                      // ),
                      items: [
                        BottomNavigationBarItem(
                          icon: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.home),
                              SizedBox(
                                width: 5.w,
                              ),
                              Text(
                                "Home",
                                style: textTheme.bodyMedium!
                                    .copyWith(fontWeight: FontWeight.w500, color: widget.index == 0 ? Colors.white : Colors.black),
                              )
                            ],
                          ),
                          label: "",
                        ),
                        BottomNavigationBarItem(
                          icon: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.message),
                              SizedBox(
                                width: 5.w,
                              ),
                              Text(
                                "Chat",
                                style: textTheme.bodyMedium!
                                    .copyWith(fontWeight: FontWeight.w500, color: widget.index == 1 ? Colors.white : Colors.black),
                              )
                            ],
                          ),
                          label: "",
                        ),
                        BottomNavigationBarItem(
                          icon: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.person),
                              SizedBox(
                                width: 5.w,
                              ),
                              Text(
                                "Profile",
                                style: textTheme.bodyMedium!
                                    .copyWith(fontWeight: FontWeight.w500, color: widget.index == 2 ? Colors.white : Colors.black),
                              )
                            ],
                          ),
                          label: "",
                        ),
                      ],

                      onTap: (value) async {
                        setState(() {
                          widget.index = value;
                        });
                      },
                    ),
                  ),
                ),
              ));
  }

  dotWidget() {
    return Obx(() => authController.showDot.value
        ? Container(
            height: 5,
            width: 5,
            decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
          )
        : SizedBox.shrink());
  }
}
