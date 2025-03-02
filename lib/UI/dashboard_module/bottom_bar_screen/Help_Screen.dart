import 'package:fitness_zone_2/data/controllers/auth_controller/auth_controller.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:fitness_zone_2/widgets/toasts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/controllers/home_controller/home_controller.dart';
import '../../chat/widgets/chat_room.dart';

class HelpScreen extends StatelessWidget {
  HelpScreen({super.key});
  final HomeController homeController = Get.find();
  final AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(null, text: "Help Section"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(
                Icons.admin_panel_settings,
                color: Colors.blue,
                size: 30,
              ),
              title: Text('Chat with Admin'),
              onTap: () async {
                if (authController.logInUser != null) {
                  var userDetail = authController.logInUser!.adminId.toString();

                  var userMap = await homeController
                      .getspecificUserFromFireStore(userDetail);
                  var roomId = await homeController.makeRoomId(userDetail);

                  Get.to(() => ChatRoom(
                        chatRoomId: roomId,
                        userMap: userMap,
                      ));
                  authController.sharedPreferences.setBool("showDot", false);
                  Get.find<AuthController>().showDot.value = false;
                } else {
                  CustomToast.failToast(msg: "Please try again later");
                }
              },
            ),
            Divider(color: Colors.grey.shade300),
            ListTile(
              leading: Icon(
                Icons.support_agent,
                color: Colors.green,
                size: 30,
              ),
              title: Text('Chat with Customer Support'),
              onTap: () async {
                if (homeController.userHomeData?.customSupporter != null) {
                  var userDetail = homeController
                      .userHomeData!.customSupporter!.id
                      .toString();

                  var userMap = await homeController
                      .getspecificUserFromFireStore(userDetail);
                  var roomId = await homeController.makeRoomId(userDetail);

                  Get.to(() => ChatRoom(
                        chatRoomId: roomId,
                        userMap: userMap,
                      ));
                  authController.sharedPreferences.setBool("showDot", false);
                  Get.find<AuthController>().showDot.value = false;
                } else {
                  CustomToast.failToast(msg: "Please try again later");
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
