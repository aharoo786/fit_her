import 'package:fitness_zone_2/values/my_imgs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../chat_controller.dart';
import '../group_chat_room.dart';
import 'chat_room.dart';

class UserWidget extends StatelessWidget {
  String roomId;
  int index;
  dynamic snapshot;
  UserWidget(
      {required this.roomId,
      required this.index,
      required this.snapshot,
   });

  @override
  Widget build(BuildContext context) {
    Get.put(AudioController());

    return ListTile(
      onTap: () async {
        Get.to(() => ChatRoom(
              chatRoomId: roomId,
              userMap:  snapshot.data!.docs[index].data()! as Map<String,dynamic>,
            ));
      },
      leading: Container(
        height: 40,
          width: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white10

          ),
          child: Image.asset(MyImgs.logo,height: 30,)),
      title: Text(
        snapshot.data!.docs[index]['name'],
        style: const TextStyle(
          color: Colors.black,
          fontSize: 17,
          fontWeight: FontWeight.w500,
        ),
      ),
      // subtitle: Text(snapshot.data!.docs[index]['isTyping']
      //     ? "typing..."
      //     : snapshot.data!.docs[index]['lastMessage']),
      // trailing: Text(
      //     snapshot.data!.docs[index]["unReadMessagesCounter"].toString() == "0"
      //         ? ""
      //         : snapshot.data!.docs[index]["unReadMessagesCounter"].toString()),
    );
  }
}
