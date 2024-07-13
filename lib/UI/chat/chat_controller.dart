import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/GetServices/CheckConnectionService.dart';

class AudioController extends GetxController {
  final _isRecordPlaying = false.obs,
      isRecording = false.obs,
      isSending = false.obs,
      isUploading = false.obs;

  List<int> selectedContactListIndex = [];
  String lastMessage = "";
  final _currentId = 999999.obs;
  var otherUserId = "";
  final start = DateTime.now().obs;
  final end = DateTime.now().obs;
  CheckConnectionService connectionService = CheckConnectionService();
  String _total = "";
  String get total => _total;
  var completedPercentage = 0.0.obs;
  var currentDuration = 0.obs;
  var containerHeight = 45.0.obs;
  var slidePosition = 0.0.obs;
  var totalDuration = 0.obs;
  var isUserOnline = false.obs;
  var isUserOnChatScreen = false;
  List<dynamic> lastMessageList = [];
  var videoIsPlaying = false.obs;
  var selectedId = "";
  int limit = 10;

  bool isLoadingContacts = true;
  bool currentUserMessage = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // late FirebaseStorage firebaseStorage;

  bool get isRecordPlaying => _isRecordPlaying.value;
  bool get isRecordingValue => isRecording.value;
  int get currentId => _currentId.value;
  var isTyping = false.obs;
  var totalDurationString = Duration().toString().obs;
  ScrollController controller = ScrollController();
  String chatRoomID = "";

  String lastMessageReceived = "End to end encypted";

  @override
  void onClose() {
    super.onClose();
  }


  calcDuration() {
    var a = end.value.difference(start.value).inSeconds;
    format(Duration d) => d.toString().split('.').first.padLeft(8, "0");
    _total = format(Duration(seconds: a));
  }



  Future<void> updateLastMessage(String text, String userUid) async {
    await _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection("myusers")
        .doc(userUid)
        .update({"time": FieldValue.serverTimestamp(), "lastMessage": text});
    await _firestore
        .collection("users")
        .doc(userUid)
        .collection("myusers")
        .doc(_auth.currentUser!.uid)
        .update({"time": FieldValue.serverTimestamp(), "lastMessage": text});
  }


  updateUnreadMessages(String roomId, dynamic userMap, dynamic myMap) async {
    // Get.dialog(Center(
    //   child: CircularProgressIndicator(),
    // ));
    try {
      final CollectionReference collection = _firestore
          .collection("chatroom")
          .doc(roomId)
          .collection("chatusers")
          .doc(userMap["uid"])
          .collection("chats");
      await collection
          .where("isRead", isEqualTo: false)
          .get()
          .then((snapshot) async {
        for (DocumentSnapshot doc in snapshot.docs) {
          await doc.reference.update({"isRead": true});
        }
      });
      await _firestore
          .collection("users")
          .doc(_auth.currentUser!.uid)
          .collection("myusers")
          .doc(userMap["uid"])
          .update({"unReadMessagesCounter": ""});
      // Get.back();

    } catch (e) {
      // Get.back();
      Get.snackbar("Alert", "Something went wrong");
    }
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (_) => ChatRoom(
    //       chatRoomId: roomId,
    //       userMap: snapshot.data!.docs[index],
    //       myMap: myMap,
    //     ),
    //   ),
    // );

    print("updation");
  }

  var lastDoc = null;

  // scrollListener() {
  //   print("in scrroll");
  //   if (controller.offset >= controller.position.maxScrollExtent &&
  //       !controller.position.outOfRange) {
  //     print("at the end of list");
  //     limit += 10;
  //     print("limit  $limit");
  //     paginatingDataUsingStream(chatRoomID);
  //     //paginatingData(chatRoomID);
  //
  //     //   fetchNextMovies(chatRoomID);
  //   } else {
  //     print("not scroll");
  //   }
  // }



  Stream<QuerySnapshot<Object?>> getAllMessagesByPagination(
      int limit, String chatRoomId) {
    CollectionReference collectionRef = _firestore
        .collection('chatroom')
        .doc(chatRoomId)
        .collection("chatusers")
        .doc(_auth.currentUser!.uid)
        .collection('chats');
    Query query = collectionRef.orderBy("time", descending: true).limit(limit);

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
      update();
    }

    return query.snapshots();
  }


  String getFileName(String url) {
    RegExp regExp = RegExp(r'.+(\/|%2F)(.+)\?.+');
    //This Regex won't work if you remove ?alt...token
    var matches = regExp.allMatches(url);

    var match = matches.elementAt(0);
    print(Uri.decodeFull(match.group(2)!));
    return Uri.decodeFull(match.group(2)!);
  }

  // Future<File?> downloadFile(String url, String fileName) async {
  //   try {
  //     Get.log("downloadingg");
  //
  //     if (await Permission.storage.isGranted) {
  //       //
  //       // final response = await Dio().get(
  //       //   url,
  //       //   options: Options(
  //       //       responseType: ResponseType.bytes,
  //       //       followRedirects: false,
  //       //       receiveTimeout: Duration(seconds: 5)),
  //       // );
  //       // final appStorage =  Directory("/storage/emulated/0/Download");
  //       // Get.log(" app storage   ${appStorage.path}");
  //       // var file = File("${appStorage.path}/$fileName");
  //       // final raf = file.openSync(mode: FileMode.write);
  //       //  raf.writeFromSync(response.data);
  //       //
  //       // await raf.close();
  //       // print("response : $response");
  //
  //       var file = await CustomCacheManager.instance.getSingleFile(url);
  //       //  var progress=file2.single.then((value) {
  //       //    value
  //       //  })
  //       // var progress=file2.forEach((element) {
  //       //   element.
  //       // });
  //       // file2.forEach((element) { });
  //       Get.log("file   $file");
  //       return file;
  //     } else {
  //       Permission.storage.request();
  //     }
  //   } catch (e) {
  //     return null;
  //   }
  // }

  // changeStatusOfIsOnChatScreen(bool resume) {
  //   if (resume) {
  //     Get.log("in app cycle ........resume");
  //     _firestore
  //         .collection("users")
  //         .doc(otherUserId)
  //         .collection("myusers")
  //         .doc(_auth.currentUser!.uid)
  //         .update({"isOnChatScreen": true});
  //     isUserOnChatScreen = true;
  //   } else {
  //     Get.log("in app cycle ........");
  //     _firestore
  //         .collection("users")
  //         .doc(otherUserId)
  //         .collection("myusers")
  //         .doc(_auth.currentUser!.uid)
  //         .update({"isOnChatScreen": false});
  //     isUserOnChatScreen = false;
  //     updateIsTyping(false);
  //   }
  // }


  // String? deviceToken;
  // Future<String?> getDeviceToken() async {
  //   await FirebaseMessaging.instance.getToken().then((token) {
  //     if (token != null) {
  //       deviceToken = token;
  //       GetStorage().write(Constants.deviceToken, token);
  //       // GetLocalStorage().setToken(token);
  //       // guestUser();
  //       //  SingleToneValue.instance.deviceToken = token;
  //       print("Dv token $token");
  //     }
  //   }).catchError((onError) {
  //     print("the error is $onError");
  //   });
  //   return deviceToken;
  // }
}





