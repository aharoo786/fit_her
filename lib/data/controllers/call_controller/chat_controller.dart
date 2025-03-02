import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/data/models/home_model/home_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../../values/constants.dart';
import '../../../widgets/toasts.dart';
import '../../GetServices/CheckConnectionService.dart';
import '../../models/login_response_model/login_response_model.dart';
import '../auth_controller/auth_controller.dart';

class CallController extends GetxController {
  var showNewMessageIcon = false.obs;
  IO.Socket? socket;
  var messages = <Map<String, dynamic>>[].obs;
  var participantList = [].obs;
  var participantListFree = [].obs;

  /// call screen variabls
  var muteAudio = true.obs;
  var trainerJoinedUID = 0.obs;
  var muteVideo = false.obs;
  var muteAudioAll = false.obs;
  CheckConnectionService connectionService = CheckConnectionService();
  LoginModel loginModel = Get.find<AuthController>().logInUser!;
  UserHomeData userHomeData = Get.find<HomeController>().userHomeData!;

  void connectToServer(bool isTrainer) {
    // socket = IO.io(
    //     "http://backend.thefither.com:9014",
    //     IO.OptionBuilder()
    //     //.setTransports(["websocket", "polling"])
    //         .disableAutoConnect() // disable auto-connection
    //         .build());
    socket = IO.io("https://backend.thefither.com:8001", <String, dynamic>{
      // socket = IO.io('http://stage.trimworldwide.com:9015', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'extraHeaders': {
        'protocols': ['TLSv1.2', 'TLSv1.3']
      },
      'forceNew': true, // Force a new connection
      'reconnection': true, // Enable reconnection
    });
    socket?.connect().onConnectError((c) {
      print('CallController.connectToServer $c');
    });
    socket?.connect().onConnect((c) {
      print('CallController.connectToServer');
    });

    socket?.on("receiveMessage", (data) {
      messages.add({
        "username": data["username"],
        "message": data["message"],
        "time": data["time"],
        "sendBy": data["sendBy"]
      });
      if (data["sendBy"] != loginModel.id) {
        showNewMessageIcon.value = true;
      }
      update(["groupChat"]);
    });

    socket?.on("userJoinChannel", (data) {
      ///For Trainer
      ///
      print('CallController.connectToServer  ${data}');

      if (data["isTrainer"]) {
        trainerJoinedUID.value = data["userUID"];
        print('CallController.connectToServer  ${trainerJoinedUID.value}');
      }

      ///for Free Trial Users
      else if (data["planName"] == "Free Trial") {
        participantListFree.add({
          "username": data["username"],
          "userId": data["userId"],
          "userUID": data["userUID"],
          "planName": data["planName"],
          "days": data["days"],
          "isMute": false
        });
      } else {
        /// Fro other users
        participantList.add({
          "username": data["username"],
          "userId": data["userId"],
          "userUID": data["userUID"],
          "planName": data["planName"],
          "days": data["days"],
          "isMute": false
        });
      }
      update(["groupChat"]);
    });
    socket?.on("leaveRoom", (data) {
      if (!isTrainer) {
        Get.back(result: true);
      }
      print('CallController.connectToServer i am logging out}');
    });

    // socket?.on("userJoined", (data) {
    //   messages.add({"username": "System", "message": data, "time": ""});
    //
    //
    // });
    //
    // socket?.on("userLeft", (data) {
    //   messages.add({"username": "System", "message": data, "time": ""});
    //
    // });
  }

  joinRoom(String room, int uid, int id, bool isTrainer) {
    var plan = userHomeData.userAllPlans
        .firstWhereOrNull((value) => value.planId == id);
    String planName = "";
    String days = "";

    if (plan != null) {
      planName = plan.title ?? "";
      days = "${DateTime.now().difference(plan.buyingDate!).inDays} days";
    }
    socket?.emit(
      "joinRoom",
      [
        "${loginModel.firstName} ${loginModel.lastName}",
        room,
        loginModel.id,
        uid,
        planName,
        days,
        isTrainer
      ],
    );
  }

  onTrainerLogout(String room) {
    socket?.emit("leaveRoom", [room]);
  }

  // Future<int?> updateUserRemoteId(int id, int planId) async {
  //   var plan = userHomeData?.userAllPlans
  //       .firstWhereOrNull((value) => value.planId == planId);
  //
  //   if (plan != null) {
  //     int days = DateTime.now().difference(plan.buyingDate!).inDays;
  //
  //     await FirebaseFirestore.instance
  //         .collection("users")
  //         .doc(Get.find<AuthController>().logInUser!.id.toString())
  //         .update({"remoteId": id, "days": "$days days"});
  //     return days;
  //   }
  //   return null;
  // }

  void onSendMessage(TextEditingController message) async {
    try {
      await connectionService.checkConnection().then((value) async {
        if (!value) {
          CustomToast.failToast(msg: "Check your internet connection");
        } else {
          if (message.text.isEmpty) {
            CustomToast.failToast(msg: "Please enter some text");
          } else {
            // await _firestore.collection(widget.chatRoomId).add({
            //   "sendBy": currentUserId,
            //   "message": _message.text,
            //   "name":
            //       "${Get.find<AuthController>().logInUser!.firstName} ${Get.find<AuthController>().logInUser!.lastName}",
            //   "time": Timestamp.now()
            // });
            if (socket != null && socket!.connected) {
              socket?.emit("sendMessage", [message.text, loginModel.id]);
            }
            message.clear();
          }
        }
      });
    } catch (e) {
      CustomToast.failToast(
          msg: "Something went wrong, please try again later");
    }
  }

  @override
  void onClose() {
    socket?.disconnect();
    super.onClose();
  }

  bool get isTrainer =>
      Get.find<AuthController>().loginAsA.value == Constants.trainer;

  @override
  void onInit() {
    connectToServer(isTrainer);
    super.onInit();
  }
}
