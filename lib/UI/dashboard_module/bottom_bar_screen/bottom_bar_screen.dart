import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../data/controllers/auth_controller/auth_controller.dart';
import '../../../values/constants.dart';
import '../../../values/my_colors.dart';
import '../../../values/my_imgs.dart';
import '../../chat/chat_home_screen.dart';
import '../drawer_screen/dwarer_screen.dart';
import '../home_screen/home_screen.dart';
import '../profile_screen/profile_screen.dart';

class BottomBarScreen extends StatefulWidget {
  int? index;
  BottomBarScreen({Key? key, this.index = 0}) : super(key: key);

  @override
  State<BottomBarScreen> createState() => _BottomBarScreenState();
}

class _BottomBarScreenState extends State<BottomBarScreen> {
  @override
  void initState() {
    super.initState();
  }

  // int _currentIndex = wi;
  final List<Widget> _widgetOption =
      Get.find<AuthController>().loginAsA.value == Constants.admin
          ? [
              HomeScreen(),
              ChatHomeScreen(),
              ProfileScreen(),
            ]
          : [
              HomeScreen(),
              ProfileScreen(),
            ];

  var scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return Scaffold(
        // drawer: MyDrawer(),
        backgroundColor: MyColors.primaryColor,
        key: scaffoldKey,
        resizeToAvoidBottomInset: false,

        // drawer: MyDrawer(),
        appBar: widget.index == 0
            ? AppBar(
                automaticallyImplyLeading: false,

                // systemOverlayStyle:
                //     const SystemUiOverlayStyle(statusBarColor: MyColors.primaryColor),
                // leading: IconButton(
                //   onPressed: () {
                //     scaffoldKey.currentState?.openDrawer();
                //   },
                //   icon: Image.asset(
                //     MyImgs.drawerIcon,
                //     color: MyColors.black,
                //     scale: 4,
                //   ),
                // ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      //"Hi, ${Get.find<AuthController>().logInUser!.firstName} ${Get.find<AuthController>().logInUser!.lastName}" ,
                      "Hi, ${Get.find<AuthController>().logInUser!.firstName} ${Get.find<AuthController>().logInUser!.lastName}",
                      style: textTheme.headlineMedium!.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 18.sp,
                          color: Colors.white),
                    ),
                    widget.index == 0
                        ? Text(
                            "Welcome to FitHer",
                            style: textTheme.headlineMedium!.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 14.sp,
                                color: Colors.white),
                          )
                        : SizedBox(),
                  ],
                ),

                backgroundColor: MyColors.buttonColor,
                elevation: 0,
              )
            : null,
        body: _widgetOption.elementAt(widget.index!),
        bottomNavigationBar: Container(
          padding: EdgeInsets.only(bottom: 20.h, left: 20, right: 20.w),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(20)),
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
                items:     Get.find<AuthController>().loginAsA.value==Constants.admin?   [
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
                ]:[
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
