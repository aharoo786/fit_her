import 'dart:convert';

import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/data/controllers/post_controller.dart';
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
      print('SocketController.slotUpdate $message');
      if (message != null) {
        homeController.upComingClassNotifier.value = UpcomingClassSlot(
            upcomingSlot: Slot.fromJson(jsonDecode(message["upcomingSlot"])), trainer: ClientUser.fromJson(jsonDecode(message["trainer"])));
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
      print('SocketController.toggleLike $message');
      if (message != null) {
        final dynamic postIdValue = message["postId"];
        final int? postId = postIdValue is int ? postIdValue : int.tryParse(postIdValue.toString());
        if (postId == null) {
          return;
        }
        final post = Get.find<PostController>().postsList.firstWhereOrNull((p) => p.id == postId);
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

  getSlot() {
    socket?.emit("getSlot", {"id": Get.find<AuthController>().logInUser?.id});
  }

  @override
  void onInit() {
    socketInit();
    super.onInit();
  }
}
