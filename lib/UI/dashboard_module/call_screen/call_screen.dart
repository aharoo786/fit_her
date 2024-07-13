import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_zone_2/UI/chat/group_chat_room.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../data/controllers/auth_controller/auth_controller.dart';
import '../../../data/controllers/home_controller/home_controller.dart';
import '../../../values/constants.dart';
import '../../../values/my_colors.dart';

class CallScreen extends StatefulWidget {
  CallScreen({
    Key? key,
    required this.channelName,
    required this.token,
    required this.userId,
    // required this.camera
  }) : super(key: key);
  final String channelName;
  final String token;
  final String userId;
  // final CameraDescription camera;

  @override
  State<CallScreen> createState() => _MyAppState();
}

class _MyAppState extends State<CallScreen> {
  //ScreenRecorderController controller = ScreenRecorderController();
  //EdScreenRecorder screenRecorder = EdScreenRecorder();
  final AuthController authController = Get.find();
  int? _remoteUid;
  bool _localUserJoined = false;
  bool recordingStart = false;

  List participantName = [];
  late RtcEngine _engine;
  //late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  Map<String, dynamic>? _response;

  @override
  void initState() {
    super.initState();
    // Get.find<HomeController>().recordSession(widget.channelName);();
    // startRecord()
    // ;
    Get.find<HomeController>().participantList = [];
    // Get.find<HomeController>().listenForDataChanges();
    initAgora();
    WakelockPlus.enable();
    // _controller = CameraController(
    //   widget.camera,
    //   ResolutionPreset.medium,
    // );
  }

  Future<void> initAgora() async {
    // retrieve permissions
    await [Permission.microphone, Permission.camera].request();

    //create the engine
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: Constants.appID,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("local user ${connection.localUid} joined");

          Get.find<HomeController>().updateUserRemoteId(connection.localUid!);

          _localUserJoined = true;
          Get.find<HomeController>().update();
        },
        onUserJoined:
            (RtcConnection connection, int remoteUid, int elapsed) async {
          debugPrint("remote user $remoteUid joined");

          // setState(() {

          // String name =
          //     ;
          // print("name123456  $name");
          // participantName.add(name);
          _remoteUid = remoteUid;
          //  await Get.find<HomeController>().getUsersCollection();
          String name =
              await Get.find<HomeController>().getUserNameUsingId(remoteUid);
          // Get.log("getting name.....$name");
          Get.find<HomeController>()
              .participantList
              .add({"id": _remoteUid, "name": name});

          Get.find<HomeController>().update();

          // });

          Get.log("list12345  ${Get.find<HomeController>().participantList}");
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          debugPrint("remote user $remoteUid left channel");
          setState(() {
            Get.find<HomeController>()
                .participantList
                .removeWhere((element) => element["id"] == remoteUid);
            _remoteUid = null;
          });
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint(
              '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
        },
      ),
    );

    await _engine.setClientRole(
        role:

            // authController.loginAsA.value == Constants.host
            //     ?
            ClientRoleType.clientRoleAudience
        // : ClientRoleType.clientRoleAudience

        );
    await _engine.enableVideo();
    await _engine.startPreview();
    await _engine.joinChannel(
      token: widget.token,
      channelId: widget.channelName,
      uid: 0,
      options: const ChannelMediaOptions(
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
          clientRoleType: ClientRoleType.clientRoleBroadcaster),
    );
  }

  @override
  void dispose() {
    super.dispose();

    _dispose();
  }

  Future<void> deleteCollection() async {
    CollectionReference collectionReference = FirebaseFirestore.instance
        .collection(widget.channelName.hashCode.toString());

    QuerySnapshot querySnapshot = await collectionReference.get();

    for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
      await documentSnapshot.reference.delete();
    }
  }

  Future<void> _dispose() async {
    //await stopRecord();
    //await stopRecord();

    if (Get.find<AuthController>().loginAsA.value == Constants.dietitian ||
        Get.find<AuthController>().loginAsA.value == Constants.trainer) {
      await deleteCollection();
      // await stopRecording();
    }
    await _engine.leaveChannel();
    await _engine.release();
    WakelockPlus.enable();
    //_controller.dispose();
  }

  // Create UI with local view and remote view
  @override
  Widget build(BuildContext context) {
    print("toke   ${widget.token}");
    return GetBuilder<HomeController>(builder: (contr) {
      return WillPopScope(
        onWillPop: () {
          Get.defaultDialog(
              title: "End Session",
              content: const Text("Are you sure you want to end session?"),
              onCancel: () async {},
              onConfirm: () async {
                await _dispose();
                Get.back();
                Get.back();
              });
          return Future.value(true);
        },
        child: Scaffold(
          body: GetBuilder<HomeController>(builder: (homeController) {
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Set the number of items in a row
                  crossAxisSpacing:
                      8.0, // Optional spacing between items horizontally
                  mainAxisSpacing: 8.0,
                  childAspectRatio:
                      0.7 // Optional spacing between items vertically
                  ),
              itemCount: Get.find<HomeController>().participantList.length +
                  1, // Replace with your actual item count
              itemBuilder: (BuildContext context, int index) {
                // Replace this with the widget for each item
                if (index == 0) {
                  return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => Container(
                            height: double.infinity,
                            width: double.infinity,
                            color: Colors.black,
                            child: Stack(
                              children: [
                                _buildLocalUserWidget(),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Container(
                                    height: 40.h,
                                    width: 40.h,
                                    margin:
                                        EdgeInsets.only(top: 10.h, left: 10.w),
                                    decoration: const BoxDecoration(
                                        color: MyColors.primaryColor,
                                        shape: BoxShape.circle),
                                    child: const Icon(
                                      Icons.clear,
                                      color: Colors.black,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                      child: _buildLocalUserWidget());
                } else {
                  return GestureDetector(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) => Container(
                                height: double.infinity,
                                width: double.infinity,
                                color: Colors.black,
                                child: Stack(
                                  children: [
                                    _remoteVideoUser(
                                        Get.find<HomeController>()
                                            .participantList[index - 1]["id"],
                                        Get.find<HomeController>()
                                                .participantList[index - 1]
                                            ["name"]),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Container(
                                        height: 40.h,
                                        width: 40.h,
                                        margin: EdgeInsets.only(
                                            top: 10.h, left: 10.w),
                                        decoration: const BoxDecoration(
                                            color: MyColors.primaryColor,
                                            shape: BoxShape.circle),
                                        child: const Icon(
                                          Icons.clear,
                                          color: Colors.black,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ));
                    },
                    child: _remoteVideoUser(
                        Get.find<HomeController>().participantList[index - 1]
                            ["id"],
                        Get.find<HomeController>().participantList[index - 1]
                            ["name"]),
                  );
                }
              },
            );
          }),
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FloatingActionButton(
                mini: true,
                onPressed: () {
                  contr.muteAudio.value = !contr.muteAudio.value;
                  _engine.muteLocalAudioStream(contr.muteAudio.value);
                  contr.update();
                },
                backgroundColor: Colors.white,
                child: Obx(() => Icon(
                      contr.muteAudio.value ? Icons.mic_off_rounded : Icons.mic,
                      color: Colors.black,
                    )),
              ),
              FloatingActionButton(
                mini: true,
                onPressed: () async {
                  contr.muteVideo.value = !contr.muteVideo.value;
                  await _engine.muteLocalAudioStream(contr.muteVideo.value);
                  contr.update();
                },
                backgroundColor: Colors.white,
                child: Obx(() => Icon(
                      contr.muteVideo.value
                          ? Icons.videocam_off
                          : Icons.videocam,
                      color: Colors.black,
                    )),
              ),
              FloatingActionButton(
                mini: true,
                onPressed: () async {
                  Get.to(() => GroupChatRoom(
                        chatRoomId: widget.channelName.hashCode.toString(),
                      ));
                },
                backgroundColor: Colors.white,
                child: const Icon(
                  Icons.message,
                  color: Colors.black,
                ),
              ),
              // Get.find<AuthController>().loginAsA.value == Constants.host
              //     ? FloatingActionButton(
              //         mini: true,
              //         onPressed: () async {
              //           try {
              //             await startRecording();
              //           } catch (e) {
              //             print('Error: $e');
              //           }
              //         },
              //         backgroundColor: Colors.white,
              //         child: const Icon(
              //           Icons.emergency_recording_rounded,
              //           color: Colors.black,
              //         ),
              //       )
              //     : SizedBox(),
              FloatingActionButton(
                mini: true,
                onPressed: () async {
                  Get.defaultDialog(
                      title: "End Session",
                      content:
                          const Text("Are you sure you want to end session?"),
                      onCancel: () async {},
                      onConfirm: () async {
                        await _dispose();
                        Get.back();
                        Get.back();
                      });
                },
                backgroundColor: Colors.red,
                child: const Icon(
                  Icons.call_end,
                  color: Colors.white,
                ),
              ),
              // FloatingActionButton(
              //   mini: true,
              //   onPressed: () async {
              //     _toggleCamera();
              //   },
              //   backgroundColor: Colors.white,
              //   child: const Icon(
              //     Icons.cameraswitch_sharp,
              //     color: Colors.black,
              //   ),
              // ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildLocalUserWidget() {
    // Your logic for building the local user's video widget
    if (_localUserJoined) {
      return Get.find<HomeController>().muteVideo.value
          ? Container(
              color: Colors.black,
              child: const Icon(
                Icons.videocam_off,
                color: Colors.white,
              ),
            )
          : Stack(
              alignment: Alignment.bottomCenter,
              children: [
                AgoraVideoView(
                  controller: VideoViewController(
                    rtcEngine: _engine,
                    canvas: const VideoCanvas(uid: 0),
                  ),
                ),
                Container(
                  height: 30.h,
                  color: Colors.white,
                  width: double.infinity,
                  child: Text(
                      "${authController.logInUser!.firstName} ${authController.logInUser!.lastName}"),
                )
              ],
            );
    } else {
      return const CircularProgressIndicator();
    }
  }

  // Future<void> _toggleCamera() async {
  //   final cameras = await availableCameras();
  //   print("cameras  $cameras");
  //   final newCamera = cameras
  //       .firstWhere((element) => element.name != _controller.description.name);
  //
  //   _controller.setDescription(newCamera);
  //
  //   setState(() {});
  // }

  Widget _remoteVideoUser(int id, String name) {
    print("remotid $_remoteUid");
    if (_remoteUid != null) {
      return Stack(
        alignment: Alignment.bottomCenter,
        children: [
          AgoraVideoView(
            controller: VideoViewController.remote(
              rtcEngine: _engine,
              canvas: VideoCanvas(uid: id),
              connection: RtcConnection(channelId: widget.channelName),
            ),
          ),
          Container(
            height: 30.h,
            color: Colors.white,
            width: double.infinity,
            child: Text(name),
          )
        ],
      );
    } else {
      return const Text(
        'Please wait for remote user to join',
        textAlign: TextAlign.center,
      );
    }
  }

// startRecording() async {
//   try {
//     // if (!_controller.value.isInitialized) {
//     //   await _controller.initialize();
//     // }
//     await _controller.initialize();
//
//     await _controller.startVideoRecording();
//     CustomToast.successToast(msg: "Recording start");
//     Get.find<HomeController>().update();
//   } catch (e) {
//     print('Error: $e');
//   }
// }
//
// stopRecording() async {
//   if (_controller.value.isRecordingVideo) {
//     await _controller.stopVideoRecording().then((value) {
//       Get.find<HomeController>().videoFile = XFile(value.path);
//       Get.find<HomeController>().update();
//     });
//   }
// }
}
