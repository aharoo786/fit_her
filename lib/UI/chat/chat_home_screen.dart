import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_zone_2/UI/chat/widgets/user_widget.dart';
import 'package:fitness_zone_2/data/controllers/auth_controller/auth_controller.dart';
import 'package:fitness_zone_2/values/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'chat_controller.dart';

class ChatHomeScreen extends StatefulWidget {
  @override
  _ChatHomeScreen createState() => _ChatHomeScreen();
}

class _ChatHomeScreen extends State<ChatHomeScreen>
    with WidgetsBindingObserver {
  Map<String, dynamic>? userMap;
  bool isLoading = false;
  final TextEditingController _search = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  AudioController audioController = Get.put(AudioController());
  AuthController authController = Get.find();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.buttonColor,
        title: const Text("Messages"),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 20.h,
          ),
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection("users")
                .doc(authController.logInUser!.id.toString())
                .collection("myusers")
                // .orderBy("time", descending: true)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                print("snap shot ${snapshot.data!.docChanges}");
                return ListView.builder(
                  itemBuilder: (context, index) {
                    String roomId =
                        (authController.logInUser!.id.toString().hashCode +
                                snapshot.data!.docs[index]['id']
                                    .toString()
                                    .hashCode)
                            .toString();
                    print(snapshot);

                    // Get.find<AudioController>().  getUnreadMessagesCounter();
                    return  Column(
                      children: [
                        UserWidget(
                                roomId: roomId,
                                index: index,
                                snapshot: snapshot,
                              ),
                        Divider(height: 1,color: Colors.black,)
                      ],
                    );

                  },
                  itemCount:
                      snapshot.data == null ? 0 : snapshot.data!.docs.length,
                );
              } else {
                return const Center(child: Text("Nothing to show yet"));
              }
            },
          )),
        ],
      ),
    );
  }
}
