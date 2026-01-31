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

  socketInit() {
    socket = IO.io('https://test.thefither.com', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'reconnection': true,
      'reconnectionAttempts': 5,
      'reconnectionDelay': 2000,
    });

    socket?.connect();
    socket?.onConnect((c) {
      socket?.emit("getSlot", {"id": Get.find<AuthController>().logInUser?.id});
    });
    socket?.on("slotUpdate", (message) {
      if (message != null) {
        homeController.upComingClassNotifier.value = UpcomingClassSlot(
            upcomingSlot: Slot.fromJson(jsonDecode(message["upcomingSlot"])), trainer: ClientUser.fromJson(jsonDecode(message["trainer"])));
      }
    });
    socket?.on("newPost", (message) {
      print('SocketController.socketInit ${message}');
      if (message != null) {
        var post = Post.fromJson(message);
        if (post.approved) {
          Get.find<PostController>().postsList.add(post);
        }
      }
    });
    socket?.on("replyWithUser", (message) {
      if (message != null) {
        final post = Get.find<PostController>().postsList.firstWhereOrNull((p) => p.id == message["postId"]);
        if (post != null) {
          post.replies.add(Reply.fromJson(message));
          Get.find<PostController>().postsList.refresh();
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

  getSlot() {
    socket?.emit("getSlot", {"id": Get.find<AuthController>().logInUser?.id});
  }

  @override
  void onInit() {
    socketInit();
    super.onInit();
  }
}
