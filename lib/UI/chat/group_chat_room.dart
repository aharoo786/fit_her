import 'package:fitness_zone_2/data/controllers/call_controller/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../data/controllers/auth_controller/auth_controller.dart';
import '../../data/controllers/home_controller/home_controller.dart';
import '../../values/my_colors.dart';
import '../../widgets/app_bar_widget.dart';

class GroupChatRoom extends StatefulWidget {
  final String chatRoomId;
  final bool isUpdated = false;
  const GroupChatRoom({super.key, required this.chatRoomId});

  @override
  State<GroupChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<GroupChatRoom>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  int currentUserId = Get.find<AuthController>().logInUser!.id;

  CallController callController = Get.find();

  final TextEditingController _message = TextEditingController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((v) {
      callController.showNewMessageIcon.value = false;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GetBuilder<CallController>(
        id: "groupChat",
        builder: (call) {
          return GestureDetector(
              onTap: () {},
              child: Scaffold(
                appBar: HelpingWidgets().appBarWidget(() {
                  Get.back();
                }, text: "Chat Room"),
                body: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        //reverse: true,
                        itemCount: call.messages.reversed.length,
                        itemBuilder: (context, index) {
                          var msg = call.messages[index];
                          return messages(
                            size,
                            msg,
                            context,
                            index,
                          );
                        },
                      ),

                      // ListView.builder(
                      //   itemCount: snapshot.data!.docs.length,
                      //   shrinkWrap: false,
                      //   reverse: true,
                      //   itemBuilder: (context, index) {
                      //     Map<String, dynamic> map =
                      //         snapshot.data!.docs[index].data()
                      //             as Map<String, dynamic>;
                      //     return messages(
                      //       size,
                      //       map,
                      //       context,
                      //       index,
                      //     );
                      //   },
                      // ),
                    ),
                    // Expanded(
                    //   child: SizedBox(
                    //     width: size.width,
                    //     child: StreamBuilder<QuerySnapshot>(
                    //       stream:
                    //           _firestore.collection(widget.chatRoomId).snapshots(),
                    //       builder: (BuildContext context, snapshot) {
                    //         if (snapshot.data != null) {
                    //           var data = snapshot.data!.docs;
                    //           return Column(
                    //             children: [
                    //
                    //             ],
                    //           );
                    //         } else {
                    //           return Center(child: CircularProgressIndicator());
                    //         }
                    //       },
                    //     ),
                    //   ),
                    // ),
                    Container(
                      height: 48.h,
                      margin: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 10.h),
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
                                contentPadding: EdgeInsets.all(5),
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
                                onPressed: () => call.onSendMessage(_message)),
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
      alignment: map['sendBy'] == currentUserId
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.only(left: 8, right: 8, top: 7, bottom: 5),
        margin: EdgeInsets.only(
            left: map['sendBy'] == currentUserId ? 100 : 10,
            right: map['sendBy'] == currentUserId ? 10 : 100,
            bottom: 5,
            top: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topRight: const Radius.circular(8),
              topLeft: const Radius.circular(8),
              bottomLeft: map['sendBy'] == currentUserId
                  ? const Radius.circular(8)
                  : const Radius.circular(0),
              bottomRight: map['sendBy'] == currentUserId
                  ? const Radius.circular(0)
                  : const Radius.circular(8)),
          color: Colors.blue,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              map['username'].toString(),
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
