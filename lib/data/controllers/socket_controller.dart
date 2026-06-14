import 'dart:convert';

import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/data/controllers/post_controller.dart';
import 'package:fitness_zone_2/helper/notification_services.dart';
import 'package:fitness_zone_2/values/constants.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../models/get_clients_diet.dart';
import '../models/get_user_plan/get_workout_user_plan_details.dart';
import '../models/post_model.dart';
import '../models/upcoming_class_slot.dart';
import 'auth_controller/auth_controller.dart';

class SocketController extends GetxController {
  IO.Socket? socket;

  HomeController homeController = Get.find();

  void joinCommunity() {
    print('SocketController.joinCommunity');
    socket?.emit("joinCommunity");
  }

  void leaveCommunity() {
    print('SocketController.leaveCommunity');
    socket?.emit("leaveCommunity");
  }

  void joinPost(int postId) {
    print('SocketController.joinPost $postId');
    socket?.emit("joinPost", postId);
  }

  void leavePost(int postId) {
    print('SocketController.leavePost $postId');
    socket?.emit("leavePost", postId);
  }

  socketInit() {
    socket = IO.io('https://backend.thefither.com', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'reconnection': true,
      'reconnectionAttempts': 5,
      'reconnectionDelay': 2000,
    });

    socket?.connect();
    socket?.onConnect((c) {
      print('SocketController.onConnect ${socket?.id}');
      socket?.emit("getSlot", {"id": Get.find<AuthController>().logInUser?.id});
    });
    socket?.onConnectError((error) {
      print('SocketController.onConnectError $error');
    });
    socket?.onError((error) {
      print('SocketController.onError $error');
    });
    socket?.onDisconnect((reason) {
      print('SocketController.onDisconnect $reason');
    });
    socket?.on("slotUpdate", (message) {
      if (message == null) return;

      final upcomingClassSlot = UpcomingClassSlot(
        upcomingSlot: Slot.fromJson(jsonDecode(message["upcomingSlot"])),
        trainer: ClientUser.fromJson(jsonDecode(message["trainer"])),
      );

      // Always update UI so she can see the class on screen
      homeController.upComingClassNotifier.value = upcomingClassSlot;

      // Only fire a local notification if the slot falls in her preferred time block
      final slot = upcomingClassSlot.upcomingSlot;
      if (slot != null && _isInPreferredTimeBlock(slot.start)) {
        final notifServices = Get.find<NotificationServices>();
        // Reuse the existing addNotification-style local push via RemoteMessage-like data.
        // Since we're coming from socket (not FCM), we show a local notification directly.
        notifServices.showLocalNotification(
          title: _titleForStatus(upcomingClassSlot.upcomingSlot?.status),
          body: _bodyForStatus(upcomingClassSlot.upcomingSlot?.status),
        );
      }
    });

    socket?.on("newPost", (message) {
      print('SocketController.newPost $message');
      if (message != null) {
        var post = Post.fromJson(message);
        if (post.approved) {
          final postController = Get.find<PostController>();
          final existing = postController.postsList.firstWhereOrNull((p) => p.id == post.id);
          if (existing == null) {
            postController.postsList.add(post);
            postController.postsList.refresh();
          }
        }
      }
    });

    socket?.on("replyWithUser", (message) {
      print('SocketController.replyWithUser $message');
      if (message != null) {
        final post = Get.find<PostController>().postsList.firstWhereOrNull((p) => p.id == message["postId"]);
        if (post != null) {
          final reply = Reply.fromJson(message);
          final alreadyExists = post.replies.any((r) => r.id == reply.id);
          if (!alreadyExists) {
            post.replies.add(reply);
            Get.find<PostController>().postsList.refresh();
          }
        }
      }
    });
    socket?.on("replyCreated", (message) {
      print('SocketController.replyCreated $message');
      if (message != null) {
        final dynamic postIdValue = message["postId"];
        final int? postId = postIdValue is int ? postIdValue : int.tryParse(postIdValue.toString());
        final replyJson = message["reply"];
        if (postId == null || replyJson == null) {
          return;
        }
        final post = Get.find<PostController>().postsList.firstWhereOrNull((p) => p.id == postId);
        if (post != null) {
          final reply = Reply.fromJson(replyJson);
          final alreadyExists = post.replies.any((r) => r.id == reply.id);
          if (!alreadyExists) {
            post.replies.add(reply);
            Get.find<PostController>().postsList.refresh();
          }
        }
      }
    });

    socket?.on("toggleLike", (message) {
      if (message != null) {
    
        final post = Get.find<PostController>().postsList.firstWhereOrNull((p) => p.id == int.parse(message["postId"]));
        print('SocketController.socketInit ${post}');
        if (post != null) {
          if (message["like"]) {
            post.likesCount.value++;
          } else {
            if (post.likesCount.value > 0) {
              post.likesCount.value--;
            }
          }
          Get.find<PostController>().postsList.refresh();
        }
      }
    });
  }

  /// Returns true if [slotStart] falls inside the user's preferred time block.
  /// Handles both 24h ("08:00") and 12h ("8:00 AM" / "08:00 PM") formats.
  /// "all" or unset → always true (notify for everything).
  bool _isInPreferredTimeBlock(String? slotStart) {
    final prefs = Get.find<AuthController>().sharedPreferences;
    final timeBlock = prefs.getString(Constants.timeBlock) ?? 'all';

    if (timeBlock == 'all') return true;
    if (slotStart == null || slotStart.isEmpty) return true;

    try {
      int hour;
      final upper = slotStart.toUpperCase().trim();

      if (upper.contains('AM') || upper.contains('PM')) {
        // 12h format: "8:00 AM" or "08:00 PM"
        final isPm = upper.contains('PM');
        final timePart = upper.replaceAll('AM', '').replaceAll('PM', '').trim();
        final parts = timePart.split(':');
        hour = int.parse(parts[0]);
        if (isPm && hour != 12) hour += 12;
        if (!isPm && hour == 12) hour = 0;
      } else {
        // 24h format: "08:00"
        final parts = slotStart.split(':');
        hour = int.parse(parts[0]);
      }

      switch (timeBlock) {
        case 'morning':   return hour >= 6  && hour < 11;
        case 'afternoon': return hour >= 11 && hour < 16;
        case 'evening':   return hour >= 16 && hour < 20;
        case 'night':     return hour >= 20 && hour < 23;
        default:          return true;
      }
    } catch (_) {
      return true; // Parse error → don't silently drop notification
    }
  }

  String _titleForStatus(String? status) {
    switch (status) {
      case 'Cancelled':    return 'Class Cancelled';
      case 'In Progress':  return 'Sweat Now, Selfies Later 💪';
      default:             return 'Class Link Added';
    }
  }

  String _bodyForStatus(String? status) {
    switch (status) {
      case 'Cancelled':   return 'Sorry, your upcoming class has been cancelled.';
      case 'In Progress': return 'Join the session now.';
      default:            return 'Join the session now.';
    }
  }

  getSlot() {
    socket?.emit("getSlot", {"id": Get.find<AuthController>().logInUser?.id});
  }

  @override
  void onInit() {
    socketInit();
    super.onInit();
  }
}
