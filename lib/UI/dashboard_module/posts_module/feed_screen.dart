import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/data/controllers/post_controller.dart';
import 'package:fitness_zone_2/data/models/post_model.dart';
import 'package:fitness_zone_2/values/my_colors.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:fitness_zone_2/widgets/circular_progress.dart';
import 'package:fitness_zone_2/widgets/toasts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../values/constants.dart';
import 'create_post_screen.dart';

class FeedScreen extends StatefulWidget {
  FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final PostController controller = Get.find();

  TextEditingController message = TextEditingController();
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    controller.getAllPosts();
    scrollToBottom();
    ever(controller.postsList, (_) => scrollToBottom());

    super.initState();
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.grey100,
      appBar: HelpingWidgets().appBarWidget(
        null,
        text: "Social Form",
        actionWidget: GestureDetector(
          onTap: () {
            if (!Get.find<HomeController>().hasActivePackage) {
              CustomToast.failToast(
                msg:
                    "You need an active package to create posts. Please subscribe to a plan first.",
              );
              return;
            }
            Get.to(() => const CreatePostScreen());
          },
          child: Container(
            margin: EdgeInsets.only(right: 16.w),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: MyColors.buttonColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: MyColors.buttonColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: Colors.white, size: 18.sp),
                SizedBox(width: 6.w),
                Text(
                  "Create Post",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (!controller.allPostsLoad.value) {
          return const Center(child: CircularProgress());
        }

        if (controller.postsList.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async => controller.getAllPosts(),
          color: MyColors.buttonColor,
          child: ListView.separated(
            controller: scrollController,
            padding: EdgeInsets.all(20.w),
            itemCount: controller.postsList.length,
            itemBuilder: (context, i) =>
                _buildPostTile(controller.postsList[i]),
            separatorBuilder: (_, __) => SizedBox(height: 16.h),
          ),
        );
      }),
      bottomNavigationBar: _buildMessageBar(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: MyColors.planColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.forum_outlined,
                size: 64.sp,
                color: MyColors.buttonColor,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              "No posts yet",
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: MyColors.textColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Be the first to share something with the community!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: MyColors.grey,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16.w, 12.h, 16.w, 12.h + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints: BoxConstraints(maxHeight: 100.h),
                decoration: BoxDecoration(
                  color: MyColors.grey100,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: MyColors.dividerColor),
                ),
                child: TextField(
                  controller: message,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: "Send a message...",
                    hintStyle: TextStyle(
                      color: MyColors.hintText,
                      fontSize: 15.sp,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 12.h,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: MyColors.textColor,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: MyColors.buttonColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: MyColors.buttonColor.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 22.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    if (message.text.trim().isEmpty) {
      CustomToast.failToast(msg: "Please enter some text");
      return;
    }
    if (!Get.find<HomeController>().hasActivePackage) {
      CustomToast.failToast(
        msg:
            "You need an active package to send messages. Please subscribe to a plan first.",
      );
      return;
    }
    controller.createPost(text: message.text, isPost: false);
    message.clear();
  }

  Widget _buildPostTile(Post p) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserHeader(p),
                if (p.text.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  Text(
                    p.text,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: MyColors.textColor,
                      height: 1.5,
                    ),
                  ),
                ],
                if (p.imageUrl?.isNotEmpty ?? false) ...[
                  SizedBox(height: 12.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: p.imageUrl!.startsWith('http')
                          ? p.imageUrl!
                          : '${Constants.baseUrl}/${p.imageUrl!.replaceFirst(RegExp(r'^/'), '')}',
                      placeholder: (_, __) => Container(
                        height: 200.h,
                        color: MyColors.grey200,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: MyColors.buttonColor,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        height: 200.h,
                        color: MyColors.grey200,
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 48.sp,
                          color: MyColors.grey,
                        ),
                      ),
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Divider(height: 1, color: MyColors.dividerColor),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: _buildPostActions(p),
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader(Post p) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20.r,
          backgroundColor: MyColors.buttonColor,
          child: Text(
            p.user != null
                ? (p.user?.firstName ?? 'U').substring(0, 1).toUpperCase()
                : 'U',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                p.user != null
                    ? '${p.user?.firstName ?? ''} ${p.user?.lastName ?? ''}'
                        .trim()
                    : 'Unknown',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15.sp,
                  color: MyColors.textColor,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                _formatTime(p.createdAt),
                style: TextStyle(
                  color: MyColors.grey,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPostActions(Post p) {
    return Row(
      children: [
        Obx(
          () => _ActionButton(
            icon: p.isLiked.value ? Icons.favorite : Icons.favorite_border,
            label: '${p.likesCount.value}',
            color: p.isLiked.value ? Colors.red : MyColors.grey,
            onTap: () => controller.likePost(p.id),
          ),
        ),
        SizedBox(width: 24.w),
        _ActionButton(
          icon: Icons.chat_bubble_outline_rounded,
          label: '${p.replies.length}',
          color: MyColors.grey,
          onTap: () => _showRepliesSheet(p),
        ),
      ],
    );
  }

  void _showRepliesSheet(Post post) {
    final TextEditingController replyController = TextEditingController();
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(Get.context!).size.height * 0.65,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Row(
                children: [
                  Container(
                    width: 4.w,
                    height: 24.h,
                    decoration: BoxDecoration(
                      color: MyColors.buttonColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    "Replies",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: MyColors.textColor,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1),
            Expanded(
              child: Obx(() {
                final replies = post.replies;
                if (replies.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 48.sp,
                          color: MyColors.grey,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          "No replies yet",
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: MyColors.grey,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "Be the first to reply!",
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: MyColors.hintText,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  itemCount: replies.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final r = replies[index];
                    return Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: MyColors.grey100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 16.r,
                            backgroundColor: MyColors.buttonColor,
                            child: Text(
                              r.user?.firstName.substring(0, 1).toUpperCase() ??
                                  'U',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      r.user?.firstName ?? "Unknown",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14.sp,
                                        color: MyColors.textColor,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      _formatTime(r.createdAt),
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: MyColors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  r.message,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: MyColors.textColor,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: MyColors.grey100,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: MyColors.dividerColor),
                      ),
                      child: TextField(
                        controller: replyController,
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) {
                          if (replyController.text.trim().isEmpty) return;
                          if (!Get.find<HomeController>().hasActivePackage) {
                            CustomToast.failToast(
                              msg:
                                  "You need an active package to reply. Please subscribe to a plan first.",
                            );
                            return;
                          }
                          controller.sendReply(
                            postId: post.id,
                            message: replyController.text.trim(),
                          );
                          replyController.clear();
                        },
                        decoration: InputDecoration(
                          hintText: "Write a reply...",
                          hintStyle: TextStyle(
                            color: MyColors.hintText,
                            fontSize: 14.sp,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 12.h,
                          ),
                        ),
                        style: TextStyle(
                            fontSize: 14.sp, color: MyColors.textColor),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  GestureDetector(
                    onTap: () {
                      if (replyController.text.trim().isEmpty) return;
                      if (!Get.find<HomeController>().hasActivePackage) {
                        CustomToast.failToast(
                          msg:
                              "You need an active package to reply. Please subscribe to a plan first.",
                        );
                        return;
                      }
                      controller.sendReply(
                        postId: post.id,
                        message: replyController.text.trim(),
                      );
                      replyController.clear();
                    },
                    child: Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        color: MyColors.buttonColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20.sp, color: color),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: MyColors.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
