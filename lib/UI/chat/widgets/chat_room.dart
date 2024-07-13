import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_zone_2/data/api_provider/chat_api_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../../data/GetServices/CheckConnectionService.dart';
import '../../../../data/controllers/auth_controller/auth_controller.dart';
import '../../../../values/constants.dart';
import '../../../../values/my_colors.dart';
import '../../../../widgets/app_bar_widget.dart';
import '../../../../widgets/toasts.dart';

class ChatRoom extends StatefulWidget {
  final String chatRoomId;
  final Map<String, dynamic> userMap;
  bool isUpdated = false;
  ChatRoom({required this.chatRoomId, required this.userMap});

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  CheckConnectionService connectionService = CheckConnectionService();

  bool temp = false;

  bool audio = false;

  List<QueryDocumentSnapshot> listMessage = [];

  late String recordFilePath;

  final TextEditingController _message = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> checkAndAddUser() async {
    try {
      AuthController authController = Get.find();
      var login = authController.logInUser;

      QuerySnapshot userSubCollection = await _firestore
          .collection("users")
          .doc(widget.userMap["id"])
          .collection("myusers")
          .get();

      bool isAvailable = false;
      for (var element in userSubCollection.docs) {
        print(
            "element: ${element.data()}, uid: ${authController.logInUser!.id}");
        if (element["id"] == authController.logInUser!.id) {
          isAvailable = true;
          break;
        }
      }

      if (isAvailable) {
        Get.log("User is available");
      } else {
        await _firestore
            .collection("users")
            .doc(widget.userMap["id"])
            .collection("myusers")
            .doc(login!.id.toString())
            .set({
          "id": login.id.toString(),
          "name": "${login.firstName} ${login.lastName}",
          "time": Timestamp.now(),
          "deviceToken":
              authController.sharedPreferences.getString(Constants.deviceToken)
        });

        Get.log("User is not available, added to the collection");
      }
    } catch (e) {
      Get.log("Error: $e");
    }
  }

  void onSendMessage() async {
    try {
      await connectionService.checkConnection().then((value) async {
        if (!value) {
          CustomToast.failToast(msg: "Check your internet connection");
        } else {
          if (_message.text.isEmpty) {
            CustomToast.failToast(msg: "Please enter some text");
          } else {
            await _firestore
                .collection(Constants.chatRoom)
                .doc(widget.chatRoomId)
                .collection(Constants.allMessages)
                .add({
              "sendBy": Get.find<AuthController>().logInUser!.id,
              "name":
                  "${Get.find<AuthController>().logInUser!.firstName} ${Get.find<AuthController>().logInUser!.lastName}",
              "message": _message.text,
              "time": Timestamp.now()
            });
            checkAndAddUser();
            Get.find<AuthController>().sendMessageNotifications(
                {"title": "A new message arrived", "body": _message.text,"deviceToken":widget.userMap["deviceToken"]});
            _message.clear();
          }
        }
      });
    } catch (e) {
      CustomToast.failToast(
          msg: "Something went wrong, please try again later");
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GetBuilder<AuthController>(builder: (homeController) {
      return GestureDetector(
          onTap: () {
            //    Get.find<AudioController>().selectedId="";
          },
          child: Scaffold(
            appBar: HelpingWidgets().appBarWidget(() {
              Get.back();
            }, text: "Chat Room"),
            body:
                // SingleChildScrollView(
                //     child:
                Column(
              children: [
                Expanded(
                  child: SizedBox(
                    //height: size.height / 1.25,
                    width: size.width,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection(Constants.chatRoom)
                          .doc(widget.chatRoomId)
                          .collection(Constants.allMessages)
                          .orderBy('time', descending: true)
                          .snapshots(),
                      builder: (BuildContext context, snapshot) {
                        print("snapshot $snapshot");
                        if (snapshot.data != null) {
                          var data = snapshot.data!.docs;
                          print("data  ${snapshot.data}");
                          return Column(
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  itemCount: snapshot.data!.docs.length,
                                  shrinkWrap: false,
                                  reverse: true,
                                  itemBuilder: (context, index) {
                                    Map<String, dynamic> map =
                                        snapshot.data!.docs[index].data()
                                            as Map<String, dynamic>;
                                    return messages(
                                      size,
                                      map,
                                      context,
                                      index,
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        } else {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      },
                    ),
                  ),
                ),
                Container(
                  height: 48.h,
                  margin:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextFormField(
                          expands: true,
                          controller: _message,
                          //  cursorHeight: 30,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          onChanged: (value) {},
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(5),
                            hintText: "Send Message ...",
                            hintStyle: const TextStyle(
                              decoration: TextDecoration.none,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10.w,
                      ),

                      Container(
                        // padding: EdgeInsets.all(8),
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: MyColors.buttonColor),
                        child: IconButton(
                            icon: Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 25.w,
                            ),
                            onPressed: onSendMessage),
                      )

                      //   );
                      // }),
                    ],
                  ),
                ),
              ],
            ),
            //    ),
          ));
    });
  }

  Widget messages(
      Size size, Map<String, dynamic> map, BuildContext context, int index) {
    return Container(
      width: size.width,
      alignment: map['sendBy'] == Get.find<AuthController>().logInUser!.id
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.only(left: 8, right: 8, top: 7, bottom: 5),
        margin: EdgeInsets.only(
            left: map['sendBy'] == Get.find<AuthController>().logInUser!.id
                ? 100
                : 10,
            right: map['sendBy'] == Get.find<AuthController>().logInUser!.id
                ? 10
                : 100,
            bottom: 5,
            top: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topRight: const Radius.circular(8),
              topLeft: const Radius.circular(8),
              bottomLeft:
                  map['sendBy'] == Get.find<AuthController>().logInUser!.id
                      ? const Radius.circular(8)
                      : const Radius.circular(0),
              bottomRight:
                  map['sendBy'] == Get.find<AuthController>().logInUser!.id
                      ? const Radius.circular(0)
                      : const Radius.circular(8)),
          color: MyColors.buttonColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              map['name'] ?? "",
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            SizedBox(
              height: 5.h,
            ),
            Text(
              map['message'],
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
