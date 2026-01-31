import 'package:fitness_zone_2/values/my_colors.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:fitness_zone_2/widgets/circular_progress.dart';
import 'package:fitness_zone_2/widgets/toasts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../data/controllers/post_controller.dart';
import '../../../data/models/post_model.dart';
import 'create_post_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
      appBar: HelpingWidgets().appBarWidget(null,
          text: "Social Form",
          actionWidget: IconButton(
            icon: const Icon(Icons.create),
            onPressed: () => Get.to(() => const CreatePostScreen()),
          )),
      body: Obx(() {
        if (!controller.allPostsLoad.value) {
          return const Center(child: CircularProgress());
        }

        if (controller.postsList.value.isEmpty) {
          return const Center(child: Text('No posts yet. Tap + to create.'));
        }

        return RefreshIndicator(
          onRefresh: () async => controller.getAllPosts(),
          color: MyColors.buttonColor,
          child: ListView.separated(
            controller: scrollController,
            padding: const EdgeInsets.all(12),
            itemCount: controller.postsList.value.length,
            itemBuilder: (context, i) => _buildPostTile(controller.postsList[i]),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
          ),
        );
      }),
      bottomNavigationBar: Container(
        height: 48.h,
        margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.grey.withOpacity(0.5),
                ),
                child: TextFormField(
                  expands: true,
                  controller: message,
                  //  cursorHeight: 30,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  onChanged: (value) {},
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10),
                    hintText: "Send Message ...",
                    hintStyle: const TextStyle(
                      decoration: TextDecoration.none,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 10.w,
            ),

            Container(
              // padding: EdgeInsets.all(8),
              alignment: Alignment.center,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: MyColors.buttonColor),
              child: IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Colors.white,
                    size: 25.w,
                  ),
                  onPressed: () {
                    if (message.text.trim().isEmpty) {
                      CustomToast.failToast(msg: "Please enter some text");
                      return;
                    }

                    controller.createPost(text: message.text, isPost: false);
                    message.clear();
                  }),
            )

            //   );
            // }),
          ],
        ),
      ),
    );
  }

  Widget _buildPostTile(Post p) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserHeader(p),
            if (p.text.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(p.text)),
            if (p.imageUrl?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: p.imageUrl!,
                    placeholder: (_, __) => Container(height: 180, color: Colors.grey.shade200),
                    errorWidget: (_, __, ___) => Container(
                      height: 180,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image),
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            _buildPostActions(p),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(Post p) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: MyColors.buttonColor,
          child: Text(p.user != null ? (p.user?.firstName ?? 'U').substring(0, 1).toUpperCase() : 'U'),
        ),
        const SizedBox(width: 8),
        if (p.user != null)
          Expanded(
            child: Text(p.user?.firstName ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        Text(_formatTime(p.createdAt), style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildPostActions(Post p) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Like button
        Obx(() {
          return TextButton.icon(
            onPressed: () => controller.likePost(p.id),
            icon: Icon(
              p.isLiked.value ? Icons.favorite : Icons.favorite_border,
              color: p.isLiked.value ? Colors.red : Colors.grey,
            ),
            label: Text(
              '${p.likesCount}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black),
            ),
          );
        }),
        const SizedBox(width: 16),
        // Reply button
        TextButton.icon(
          onPressed: () => _showRepliesSheet(p),
          icon: const Icon(Icons.reply, color: Colors.grey),
          label: Text(
            '${p.replies.length}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black),
          ),
        ),
      ],
    );
  }

  void _showRepliesSheet(Post post) {
    final TextEditingController replyController = TextEditingController();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(12),
        height: 400,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                final replies = post.replies;
                if (replies.isEmpty) {
                  return const Center(child: Text("No replies yet."));
                }
                return ListView.builder(
                  itemCount: replies.length,
                  itemBuilder: (context, index) {
                    final r = replies[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: MyColors.buttonColor,
                        child: Text(r.user?.firstName.substring(0, 1).toUpperCase() ?? 'U'),
                      ),
                      title: Text(r.user?.firstName ?? "Unknown"),
                      subtitle: Text(r.message),
                      trailing: Text(_formatTime(r.createdAt), style: const TextStyle(fontSize: 10)),
                    );
                  },
                );
              }),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: replyController,
                    decoration: const InputDecoration(hintText: "Write a reply..."),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: MyColors.buttonColor),
                  onPressed: () {
                    if (replyController.text.trim().isNotEmpty) {
                      controller.sendReply(postId: post.id, message: replyController.text.trim());
                      replyController.clear();
                    }
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${dt.month}/${dt.day}/${dt.year}';
  }
}
