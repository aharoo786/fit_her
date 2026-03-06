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
  // var showNewMessageIcon = false.obs;
  // IO.Socket? socket;
  // var messages = <Map<String, dynamic>>[].obs;
  // var participantList = [].obs;
  // var participantListFree = [].obs;
  // var isMuteAll = false.obs;
  // RtcEngine? engine;
  //
  // /// call screen variabls
  // var muteAudio = true.obs;
  // var trainerJoinedUID = 0.obs;
  // var muteVideo = false.obs;
  // var muteAudioAll = false.obs;
  // CheckConnectionService connectionService = CheckConnectionService();
  // LoginModel loginModel = Get.find<AuthController>().logInUser!;
  // bool get isTrainer =>
  //     Get.find<AuthController>().loginAsA.value == Constants.trainer;
  //
  // UserHomeData? userHomeData;
  //
  // void connectToServer(bool isTrainer) {
  //   socket = IO.io('https://backend.thefither.com', <String, dynamic>{
  //     'transports': ['websocket'],
  //     'autoConnect': true,
  //     'reconnection': true, // Enable reconnection
  //     'reconnectionAttempts': 5, // Number of reconnection attempts
  //     'reconnectionDelay': 2000, // Delay before attempting to reconnect
  //   });
  //   socket?.connect().onConnectError((c) {
  //     print('CallController.connectToServer $c');
  //   });
  //
  //   socket?.on("receiveMessage", (data) {
  //     print('CallController.connectToServer message');
  //     messages.add({
  //       "username": data["username"],
  //       "message": data["message"],
  //       "time": data["time"],
  //       "sendBy": data["sendBy"]
  //     });
  //     if (data["sendBy"] != loginModel.id) {
  //       showNewMessageIcon.value = true;
  //     }
  //     update();
  //   });
  //   socket?.on("userJoinChannel", (data) {
  //     ///For Trainer
  //     ///
  //     print('CallController.connectToServerhhjkjhkjhkjjklkjj  ${data}');
  //
  //     if (data["isTrainer"]) {
  //       trainerJoinedUID.value = data["userUID"];
  //       print(
  //           'CallController.connectToServerjkkjhjkjkjkjkk  ${trainerJoinedUID.value}');
  //     }
  //
  //     ///for Free Trial Users
  //     else if (data["planName"] == "Free Trial") {
  //       participantListFree.add({
  //         "username": data["username"],
  //         "userId": data["userId"],
  //         "userUID": data["userUID"],
  //         "planName": data["planName"],
  //         "days": data["days"],
  //         "isMute": false
  //       });
  //     } else {
  //       /// Fro other users
  //       participantList.add({
  //         "username": data["username"],
  //         "userId": data["userId"],
  //         "userUID": data["userUID"],
  //         "planName": data["planName"],
  //         "days": data["days"],
  //         "isMute": false
  //       });
  //     }
  //   });
  //   socket?.on("leaveRoom", (data) {
  //     if (!isTrainer) {
  //       Get.back(result: true);
  //       onDisconnectFunction();
  //     }
  //     print('CallController.connectToServer i am logging out}');
  //   });
  //   socket?.on("muteAllUsers", (data) {
  //     isMuteAll.value = data;
  //     if (!isTrainer) {
  //       engine?.muteLocalAudioStream(data);
  //     }
  //   });
  //   socket?.on("muteSpecificUser", (data) {
  //     if (data["id"] == loginModel.id) {
  //       isMuteAll.value = data["mute"];
  //       engine?.muteLocalAudioStream(data["mute"]);
  //     }
  //   });
  //   socket?.onDisconnect((_) {
  //     socket?.emit('disconnected', [loginModel.id]);
  //   });
  //   update();
  //   // socket?.on("userJoined", (data) {
  //   //   messages.add({"username": "System", "message": data, "time": ""});
  //   //
  //   //
  //   // });
  //   //
  //   // socket?.on("userLeft", (data) {
  //   //   messages.add({"username": "System", "message": data, "time": ""});
  //   //
  //   // });
  // }
  //
  // muteAllUsers(String room, bool mute) {
  //   socket?.emit("muteAllUsers", [room, mute]);
  // }
  //
  // muteSpecificUser(String room, bool mute, int id) {
  //   socket?.emit("muteSpecificUser", [room, mute, id]);
  // }
  //
  // onDisconnectFunction() {
  //   socket?.emit('disconnected', [loginModel.id]);
  // }
  //
  // joinRoom(String room, int uid, int id, bool isTrainer) {
  //   var plan = userHomeData?.userAllPlans
  //       .firstWhereOrNull((value) => value.planId == id);
  //   String planName = "";
  //   String days = "";
  //
  //   if (plan != null) {
  //     planName = plan.title ?? "";
  //     days = "${DateTime.now().difference(plan.buyingDate!).inDays} days";
  //   }
  //   socket?.emit(
  //     "joinRoom",
  //     [
  //       "${loginModel.firstName} ${loginModel.lastName}",
  //       room,
  //       loginModel.id,
  //       uid,
  //       planName,
  //       days,
  //       isTrainer
  //     ],
  //   );
  // }
  //
  // onTrainerLogout(String room) {
  //   socket?.emit("leaveRoom", [room]);
  // }
  //
  // // Future<int?> updateUserRemoteId(int id, int planId) async {
  // //   var plan = userHomeData?.userAllPlans
  // //       .firstWhereOrNull((value) => value.planId == planId);
  // //
  // //   if (plan != null) {
  // //     int days = DateTime.now().difference(plan.buyingDate!).inDays;
  // //
  // //     await FirebaseFirestore.instance
  // //         .collection("users")
  // //         .doc(Get.find<AuthController>().logInUser!.id.toString())
  // //         .update({"remoteId": id, "days": "$days days"});
  // //     return days;
  // //   }
  // //   return null;
  // // }
  //
  // void onSendMessage(TextEditingController message) async {
  //   try {
  //     await connectionService.checkConnection().then((value) async {
  //       if (!value) {
  //         CustomToast.failToast(msg: "Check your internet connection");
  //       } else {
  //         if (message.text.isEmpty) {
  //           CustomToast.failToast(msg: "Please enter some text");
  //         } else {
  //           // await _firestore.collection(widget.chatRoomId).add({
  //           //   "sendBy": currentUserId,
  //           //   "message": _message.text,
  //           //   "name":
  //           //       "${Get.find<AuthController>().logInUser!.firstName} ${Get.find<AuthController>().logInUser!.lastName}",
  //           //   "time": Timestamp.now()
  //           // });
  //           if (socket != null && socket!.connected) {
  //             socket?.emit("sendMessage", [message.text, loginModel.id]);
  //           }
  //           message.clear();
  //         }
  //       }
  //     });
  //   } catch (e) {
  //     CustomToast.failToast(
  //         msg: "Something went wrong, please try again later");
  //   }
  // }
  //
  // @override
  // void onClose() {
  //   socket?.disconnect();
  //   super.onClose();
  // }
  //
  // @override
  // void onInit() {
  //   connectToServer(isTrainer);
  //   if (!isTrainer) {
  //     userHomeData = Get.find<HomeController>().userHomeData!;
  //   }
  //   super.onInit();
  // }
}
