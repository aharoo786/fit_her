import 'dart:ui';

import 'package:fitness_zone_2/UI/chat/widgets/chat_room.dart';
import 'package:fitness_zone_2/UI/dashboard_module/bottom_bar_screen/diet_plans_of_user.dart';
import 'package:fitness_zone_2/UI/dashboard_module/bottom_bar_screen/progress_screen.dart';
import 'package:fitness_zone_2/UI/dashboard_module/bottom_bar_screen/work_out_bottom_screen.dart';
import 'package:fitness_zone_2/UI/dashboard_module/bottom_bar_screen/workout_plans_of_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../data/controllers/auth_controller/auth_controller.dart';
import '../../../values/constants.dart';
import '../../../values/my_colors.dart';
import '../../../values/my_imgs.dart';
import '../../chat/chat_home_screen.dart';
import '../home_screen/home_screen.dart';
import '../profile_screen/profile_screen.dart';

class BottomBarScreen extends StatefulWidget {
  int? index;
  BottomBarScreen({Key? key, this.index = 0, this.roomId, this.userMap})
      : super(key: key);
  String? roomId;
  Map<String, dynamic>? userMap;

  @override
  State<BottomBarScreen> createState() => _BottomBarScreenState();
}

class _BottomBarScreenState extends State<BottomBarScreen> {
  late List<Widget> _widgetOption = [];
  @override
  void initState() {
    super.initState();
    _widgetOption = Get.find<AuthController>().loginAsA.value == Constants.admin
        ? [
            HomeScreen(),
            ChatHomeScreen(),
            ProfileScreen(),
          ]
        : Get.find<AuthController>().loginAsA.value == Constants.user
            ? [
                HomeScreen(),
                WorkPlansOfUser(),
                DietPlansOfUser(),
                ProgressScreen(),
                ChatRoom(
                    chatRoomId: widget.roomId ?? "",
                    userMap: widget.userMap ?? {}),
              ]
            : [
                HomeScreen(),
                ProfileScreen(),
              ];
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
        resizeToAvoidBottomInset: false,
        body: _widgetOption.elementAt(widget.index!),
        bottomNavigationBar: Get.find<AuthController>().loginAsA.value ==
                Constants.user
            ? PreferredSize(
                preferredSize: Size.fromHeight(70.h),
                child: BottomNavigationBar(
                  elevation: 0,
                  backgroundColor: Colors.white,
                  currentIndex: widget.index!,

                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: Colors.white,
                  unselectedItemColor: MyColors.primaryGradient1,
                  unselectedIconTheme:
                      const IconThemeData(color: MyColors.primaryGradient1),
                  unselectedLabelStyle: TextStyle(
                      color: MyColors.primaryGradient1,
                      fontWeight: FontWeight.w500,
                      fontSize: 10.sp),

                  selectedIconTheme:
                      const IconThemeData(color: MyColors.primaryColor),
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
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: MyColors.buttonColor),
                        child: SvgPicture.asset(
                          MyImgs.homeSVG,
                          height: 30,
                          colorFilter: const ColorFilter.mode(
                              Colors.white, BlendMode.srcIn),
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
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: MyColors.buttonColor),
                        child: SvgPicture.asset(
                          MyImgs.workout,
                          height: 30,
                          colorFilter: const ColorFilter.mode(
                              Colors.white, BlendMode.srcIn),
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
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: MyColors.buttonColor),
                        child: SvgPicture.asset(
                          MyImgs.diet,
                          height: 30,
                          colorFilter: const ColorFilter.mode(
                              Colors.white, BlendMode.srcIn),
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
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: MyColors.buttonColor),
                        child: SvgPicture.asset(
                          MyImgs.progress,
                          height: 30,
                          colorFilter: const ColorFilter.mode(
                              Colors.white, BlendMode.srcIn),
                        ),
                      ),
                      label: "Progress",
                    ),
                    BottomNavigationBarItem(
                      icon: SvgPicture.asset(
                        MyImgs.helpSVG,
                        height: 30,
                      ),
                      activeIcon: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: MyColors.buttonColor),
                        child: SvgPicture.asset(
                          MyImgs.helpSVG,
                          height: 30,
                          colorFilter: const ColorFilter.mode(
                              Colors.white, BlendMode.srcIn),
                        ),
                      ),
                      label: "Help",
                    ),
                  ],
                  onTap: (value) async {
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
                      selectedIconTheme:
                          const IconThemeData(color: MyColors.primaryColor),
                      // unselectedLabelStyle: const TextStyle(
                      //   fontFamily: 'Roboto',
                      // ),
                      // selectedLabelStyle: const TextStyle(
                      //   fontFamily: 'Roboto',
                      // ),
                      items: Get.find<AuthController>().loginAsA.value ==
                              Constants.admin
                          ? [
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
                                      style: textTheme.bodyMedium!.copyWith(
                                          fontWeight: FontWeight.w500,
                                          color: widget.index == 0
                                              ? Colors.white
                                              : Colors.black),
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
                                      style: textTheme.bodyMedium!.copyWith(
                                          fontWeight: FontWeight.w500,
                                          color: widget.index == 1
                                              ? Colors.white
                                              : Colors.black),
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
                                      style: textTheme.bodyMedium!.copyWith(
                                          fontWeight: FontWeight.w500,
                                          color: widget.index == 2
                                              ? Colors.white
                                              : Colors.black),
                                    )
                                  ],
                                ),
                                label: "",
                              ),
                            ]
                          : [
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
                                      style: textTheme.bodyMedium!.copyWith(
                                          fontWeight: FontWeight.w500,
                                          color: widget.index == 0
                                              ? Colors.white
                                              : Colors.black),
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
                                      style: textTheme.bodyMedium!.copyWith(
                                          fontWeight: FontWeight.w500,
                                          color: widget.index == 1
                                              ? Colors.white
                                              : Colors.black),
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
              )
        //body: _widgetOption.elementAt(_currentIndex),
        // drawer: MyDrawer(),
        //
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        // floatingActionButton: FloatingActionButton(
        //   // isExtended: true,
        //   mini: false,
        //   elevation: 0,
        //   foregroundColor: MyColors.green,
        //   backgroundColor: MyColors.primaryColor,
        //   child: Material(
        //     // height: getHeight(200),
        //     type: MaterialType.transparency,
        //     child: Ink(
        //       decoration: BoxDecoration(
        //         border: Border.all(color: MyColors.bodyBackground, width: 5.0.w),
        //         shape: BoxShape.circle,
        //         color: MyColors.primary2,
        //       ),
        //       child: Center(
        //         child: Image.asset(
        //           MyImgs.logo3,
        //           width: 80.w,
        //           height: 80.w,
        //           fit: BoxFit.contain,
        //         ),
        //       ),
        //     ),
        //   ),
        //   onPressed: () async {},
        //   // label: null,
        // ),
        );
  }
}
