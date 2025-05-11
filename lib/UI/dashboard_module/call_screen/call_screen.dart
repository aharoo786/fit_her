import 'dart:async';
import 'package:fitness_zone_2/UI/chat/group_chat_room.dart';
import 'package:fitness_zone_2/data/controllers/call_controller/chat_controller.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../data/controllers/auth_controller/auth_controller.dart';
import '../../../data/controllers/home_controller/home_controller.dart';
import '../../../data/models/get_user_plan/get_workout_user_plan_details.dart';
import '../../../values/constants.dart';
import '../../../values/my_colors.dart';
import '../../../widgets/toasts.dart';

class CallScreen extends StatefulWidget {
  final String channelName;
  final String token;
  final String userId;
  final int? slotId;
  final bool isDiet;
  final Plan? plan;
  final int? trainerUID;
  final String title;

  CallScreen({
    Key? key,
    required this.channelName,
    required this.token,
    required this.userId,
    this.isDiet = false,
    this.plan,
    required this.title,
    this.slotId,
    this.trainerUID,
  }) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final AuthController authController = Get.find();
  final CallController callController = Get.find();
  final HomeController homeController = Get.find();
  RtcEngine? _engine;
  int? _remoteUid;
  bool _localUserJoined = false;
  bool isTrainer = false;

  String get roomId => widget.channelName.hashCode.toString();

  @override
  void initState() {
    super.initState();
    callController.participantList.value = [];
    callController.participantListFree.value = [];
    initAgora();
    isTrainer = authController.loginAsA.value == Constants.trainer;

    WakelockPlus.enable();
  }

  Future<void> muteAllExceptOne(int uid) async {
    // await _engine?.muteAllRemoteAudioStreams(true);
    // for (var user in callController.participantListFree.value) {
    //   print('_CallScreenState.muteAllExceptOne{$user}');
    //   await _engine?.muteRemoteAudioStream(uid: user["userUID"], mute: true);
    // }
    // for (var user in callController.participantList.value) {
    //   await _engine?.muteRemoteAudioStream(uid: user["userUID"], mute: true);
    // }
    callController.muteAllUsers(roomId, true);
    callController.muteAudioAll.value = true; // Mute all first
    await _engine?.muteRemoteAudioStream(
        uid: widget.trainerUID ?? 0, mute: false); // Unmute only one user
  }

  Future<void> initAgora() async {
    callController.muteVideo.value = false;
    callController.muteAudio.value = true;
    callController.muteAudioAll.value = false;
    await [Permission.microphone, Permission.camera].request();

    _engine = createAgoraRtcEngine();
    await _engine!.initialize(
      const RtcEngineContext(
        appId: Constants.appID,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ),
    );
    print('_CallScreenState.initAgora ${widget.trainerUID}');

    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) async {
          if (isTrainer) {
            await homeController.updateTrainerJoin(connection.localUid ?? 0,
                widget.slotId ?? 0, widget.channelName.hashCode.toString());
          }
          if (widget.plan != null || isTrainer) {
            callController.joinRoom(widget.channelName.hashCode.toString(),
                connection.localUid ?? 0, widget.plan?.id ?? -1, isTrainer);

            // await homeController.updateUserRemoteId(
            //     connection.localUid ?? 0, widget.plan!.id);
          }

          setState(() => _localUserJoined = true);
          callController.update();
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          // Map<String, dynamic> user =
          //     await homeController.getUserNameUsingId(remoteUid);
          // homeController.participantList.add(
          //   {
          //     "id": remoteUid,
          //     "name": user["name"],
          //     "days": user["days"],
          //     "isMute": false
          //   },
          // );
          // print('_CallScreenState.initAgora ${widget.trainerUID}');
          //
          print('_CallScreenState.initAgora ${remoteUid}');
          print('_CallScreenState.initAgora ${widget.trainerUID}');
          if (authController.loginAsA.value == Constants.user) {
            if (remoteUid == widget.trainerUID) {
              _engine!.setRemoteVideoStreamType(
                  uid: remoteUid, streamType: VideoStreamType.videoStreamHigh);
              setState(() => _remoteUid = remoteUid);
            } else {
              _engine!.muteRemoteVideoStream(uid: remoteUid, mute: true);
            }
            // _engine?.setRemoteVideoStreamType(
            //     uid: callController.trainerJoinedUID.value,
            //     streamType: VideoStreamType.videoStreamHigh);
            // setState(() => _remoteUid = callController.trainerJoinedUID.value);
            // Ignore other users
          }

          callController.update();
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          if (isTrainer) {
            setState(() {
              callController.participantList
                  .removeWhere((e) => e["userUID"] == remoteUid);
              callController.participantListFree
                  .removeWhere((e) => e["userUID"] == remoteUid);
              // if (authController.loginAsA.value == Constants.user) {
              //   _remoteUid = null;
              // }
            });
          }
        },
      ),
    );

    const role = ClientRoleType.clientRoleBroadcaster;
    await _engine!.setClientRole(role: role);

    await _engine!.enableVideo();
    await _engine!.enableAudio();
    // await _engine!.muteLocalVideoStream(true);
    await _engine!.muteLocalAudioStream(true);
    await _engine!.startPreview();

    await _engine!.joinChannel(
      token: widget.token,
      channelId: widget.channelName,
      uid: Get.find<AuthController>().logInUser!.id,
      options: const ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );
    callController.engine = _engine;

    //   freeUser();
  }

  Future<void> _dispose() async {
    await _engine?.leaveChannel();
    await _engine?.release();
    callController.muteVideo.value = true;
    callController.muteAudio.value = true;
    WakelockPlus.disable();
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CallController>(builder: (controller) {
      return WillPopScope(
        onWillPop: () async {
          backButtonClick();
          return false;
        },
        child: Scaffold(
          appBar: HelpingWidgets().appBarWidget(text: widget.title, () {
            backButtonClick();
          }),
          body: widget.isDiet || authController.loginAsA.value == Constants.user
              ? _buildSingleUserView()
              : _buildGridView(),
          bottomNavigationBar: _buildBottomBar(),
        ),
      );
    });
  }

  Widget _buildSingleUserView() {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              _remoteUid != null
                  ? _remoteVideoUser(
                      _remoteUid!, "Trainer", callController, false)
                  : const Center(child: Text("No user joined yet")),
              Positioned(
                bottom: 30,
                right: 20,
                child: SizedBox(
                  height: 200,
                  width: 100,
                  child: _localUserJoined
                      ? _buildLocalUserWidget()
                      : const SizedBox(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  _buildListView(List participantList) {
    return Expanded(
      child: ListView.separated(
          itemBuilder: (context, index) {
            final participant = participantList[index];
            return Container(
              width: 200,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: GestureDetector(
                onTap: () => _showParticipantDialog(participant),
                child: _remoteVideoUser(
                    participant["userUID"],
                    participant["username"],
                    callController,
                    participant["isMute"],
                    days: participant["days"]),
              ),
            );
          },
          separatorBuilder: (context, index) => SizedBox(
                height: 10,
              ),
          itemCount: participantList.length),
    );
  }

  Widget _buildGridView() {
    return Stack(
      children: [
        Obx(
          () => Row(
            children: [
              _buildListView(callController.participantListFree.value),
              SizedBox(
                width: 10,
              ),
              _buildListView(callController.participantList.value)
            ],
          ),
        ),
        // GridView.builder(
        //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        //     crossAxisCount: 2,
        //     crossAxisSpacing: 8.0,
        //     mainAxisSpacing: 8.0,
        //     childAspectRatio: 0.7,
        //   ),
        //   itemCount: callController.participantList.length,
        //   itemBuilder: (context, index) {
        //     final participant = callController.participantList[index];
        //     return GestureDetector(
        //       onTap: () => _showParticipantDialog(participant),
        //       child: _remoteVideoUser(
        //           participant["userUID"],
        //           participant["username"],
        //           homeController,
        //           participant["isMute"],
        //           days: participant["days"]),
        //     );
        //   },
        // ),
        Positioned(
          bottom: 30,
          right: 20,
          child: SizedBox(
            height: 200,
            width: 150,
            child: _buildLocalUserWidget(),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        color: Color(0xff6F8064),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBottomBarButton(
            icon: callController.muteAudio.value
                ? Icons.mic_off_rounded
                : Icons.mic,
            onTap: () async {
              //  if (!freeUser()) {
              if (callController.isMuteAll.value && !isTrainer) {
                CustomToast.failToast(
                    msg: "Please request trainer to un mute you");
              } else {
                callController.muteAudio.value =
                    !callController.muteAudio.value;
                _engine!.muteLocalAudioStream(callController.muteAudio.value);
                callController.update();
              }
              //  }
            },
          ),
          _buildBottomBarButton(
            icon: callController.muteVideo.value
                ? Icons.videocam_off
                : Icons.videocam,
            onTap: () {
              print(
                  '_CallScreenState._buildBottomBar ${callController.isMuteAll.value}');
              //  if (!freeUser()) {
              // if (callController.isMuteAll.value && !isTrainer) {
              //   CustomToast.failToast(
              //       msg: "Please request trainer to un mute you");
              // } else {
              callController.muteVideo.value = !callController.muteVideo.value;
              _engine!.muteLocalVideoStream(callController.muteVideo.value);
              callController.update();
              // }

              //   }
            },
          ),
          Obx(
            () => Stack(
              alignment: Alignment.topRight,
              children: [
                _buildBottomBarButton(
                  icon: Icons.message,
                  onTap: () {
                    Get.to(() => GroupChatRoom(
                          chatRoomId: widget.channelName.hashCode.toString(),
                        ));
                  },
                ),
                callController.showNewMessageIcon.value
                    ? Container(
                        height: 15,
                        width: 15,
                        decoration: const BoxDecoration(
                            color: Colors.red, shape: BoxShape.circle),
                      )
                    : SizedBox.shrink(),
              ],
            ),
          ),
          _buildBottomBarButton(
            icon: Icons.call_end,
            onTap: () async {
              backButtonClick();
            },
          ),
          if (authController.loginAsA.value == Constants.trainer)
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 25,
              child: GetBuilder<CallController>(
                builder: (homeController) => PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'mute_all') {
                      muteAllExceptOne(0);
                      callController.muteAudioAll.value = true;
                    } else {
                      callController.muteAllUsers(roomId, false);

                      // await _engine?.muteAllRemoteAudioStreams(false);
                      callController.muteAudioAll.value = false;
                    }
                    callController.update(); // Update UI
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem(
                      value: callController.muteAudioAll.value
                          ? 'un_mute_all'
                          : 'mute_all',
                      child: Text(
                        callController.muteAudioAll.value
                            ? "Unmute All"
                            : "Mute All",
                      ),
                    ),
                  ],
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  backButtonClick() async {
    await Get.defaultDialog<bool>(
      title: "End Session",
      content: const Text("Are you sure you want to end session?"),
      onCancel: () => Get.back(result: false),
      onConfirm: () async {
        if (isTrainer) {
          await homeController.updateTrainerJoin(
              0,
              widget.slotId ?? 0,
              isTrainerJoined: false,
              widget.channelName.hashCode.toString());
          callController
              .onTrainerLogout(widget.channelName.hashCode.toString());
          Get.back();
          Get.back();
        } else {
          callController.onDisconnectFunction();

          Get.back();
          await _dispose();
          var s = homeController.sharedPreferences;
          if (s.getString(Constants.reviewDate) == null) {
            Get.back(result: true);
          } else {
            int dif = DateTime.now()
                .difference(DateTime.parse(s.getString(Constants.reviewDate)!))
                .inDays;

            // DateTime.parse(s.getString(Constants.reviewDate)!)
            // .difference(DateTime.now().add(Duration(days: 1)))
            // .inDays;
            print(" ${dif}");

            if (dif >= 2) {
              Get.back(result: true);
            } else {
              Get.back();
            }
          }
        }
      },
    );
  }

  Widget _buildBottomBarButton(
      {required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: CircleAvatar(
        backgroundColor: Colors.white,
        radius: 25,
        child: Icon(icon, color: MyColors.buttonColor),
      ),
    );
  }

  checkUserMicOnOff(int uid, bool mute) async {
    callController.muteSpecificUser(roomId, mute, uid);
    // await _engine?.muteRemoteAudioStream(uid: uid, mute: mute);
    var index =
        callController.participantList.indexWhere((v) => v["userUID"] == uid);

    if (index != -1) {
      callController.participantList[index]["isMute"] = mute;
    } else {
      var indexFree = callController.participantListFree
          .indexWhere((v) => v["userUID"] == uid);
      if (indexFree != -1) {
        callController.participantListFree[indexFree]["isMute"] = mute;
      }
    }
    callController.update();
  }

  Widget _remoteVideoUser(
      int uid, String name, CallController controller, bool isMute,
      {String? days}) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                    // border: Border.all(color: Colors.grey),
                    // borderRadius: BorderRadius.circular(10.0),
                    ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: AgoraVideoView(
                    controller: VideoViewController(
                      rtcEngine: _engine!,
                      canvas: VideoCanvas(uid: uid),
                    ),
                  ),
                ),
              ),
            ),
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (days != null)
              Text(
                "$days",
                style: const TextStyle(color: Colors.grey),
              ),
          ],
        ),
        if (isTrainer)
          Positioned(
            bottom: 50,
            right: 10,
            child: _buildBottomBarButton(
              icon: isMute ? Icons.mic_off_rounded : Icons.mic,
              onTap: () async {
                checkUserMicOnOff(uid, !isMute);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildLocalUserWidget() {
    if (_engine == null) {
      return const CircularProgressIndicator(
        color: MyColors.primaryColor,
      );
    }

    return Container(
      margin: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: _engine!,
          canvas: const VideoCanvas(uid: 0),
        ),
      ),
    );
  }

  Future<void> _showParticipantDialog(Map<String, dynamic> participant) async {
    await Get.defaultDialog(
      title: participant["name"],
      content: Text("Days: ${participant["days"]}"),
      confirm: ElevatedButton(
        onPressed: () => Get.back(),
        child: const Text(
          "OK",
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  freeUser({bool showToast = true}) {
    if (widget.plan != null) {
      if (widget.plan!.title == "Free Trial") {
        callController.muteAudio.value = true;
        callController.muteVideo.value = true;
        _engine!.muteLocalAudioStream(true);
        _engine!.muteLocalVideoStream(true);
        if (showToast) CustomToast.failToast(msg: "You are in Free Mode");
        return true;
      }
    }
    return false;
  }
}
