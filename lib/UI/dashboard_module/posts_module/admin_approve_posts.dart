import 'package:fitness_zone_2/values/my_colors.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:fitness_zone_2/widgets/circular_progress.dart';
import 'package:fitness_zone_2/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/controllers/post_controller.dart';
import '../../../data/models/post_model.dart';
import 'create_post_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AdminApprovePosts extends StatelessWidget {
  AdminApprovePosts({super.key});
  PostController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(() {
        Get.back();
      },
          text: "Approve Posts",
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
          onRefresh: () {
            controller.getAllPosts(approved: false);
            return Future.value();
          },
          color: MyColors.buttonColor,
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: controller.postsList.length,
            itemBuilder: (context, i) => _buildPostTile(controller.postsList[i]),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
          ),
        );
      }),
    );
  }

  Widget _buildPostTile(Post p) {
    final isTextOnly = p.imageUrl == null;

    if (isTextOnly && (p.text != null && p.text.isNotEmpty)) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(p.text),
        ),
      );
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
            ),
            const SizedBox(height: 8),
            //   if (p.title?.isNotEmpty ?? false) Text(p.title!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            if (p.text?.isNotEmpty ?? false) Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(p.text)),
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
            CustomButton(text: "Approve", onPressed: (){
              controller.approvePost(p.id);
            })
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
