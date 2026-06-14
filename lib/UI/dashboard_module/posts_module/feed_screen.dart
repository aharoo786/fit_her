import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitness_zone_2/data/controllers/auth_controller/auth_controller.dart';
import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/data/controllers/post_controller.dart';
import 'package:fitness_zone_2/data/models/post_model.dart';
import 'package:fitness_zone_2/widgets/circular_progress.dart';
import 'package:fitness_zone_2/widgets/toasts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../UI/plans_module/all_plans.dart';
import '../../../values/constants.dart';
import 'create_post_screen.dart';

/// Paywall gate for community posting. Trainers and dietitians (the
/// platform's professionals) post freely regardless of `hasActivePackage`
/// because they're paid contributors, not subscribers. Everyone else
/// (regular users + admin/specialists) follows the existing
/// `hasActivePackage` rule. Backend role literals per CLAUDE.md:
/// 'Trainer' and 'Dietition' (typo preserved by the backend).
bool _canPostFreely() {
  final type = Get.find<AuthController>().logInUser?.userType;
  if (type == Constants.trainer || type == Constants.dietitian) return true;
  return Get.find<HomeController>().hasActivePackage;
}

// V2 design tokens — palette mirrors lib/docs/newdesign.md §2.
const _kCream = Color(0xFFEAF7E4);
const _kCardBorder = Color(0xFFD8EDD4);
const _kTextPrimary = Color(0xFF163220);
const _kTextSecondary = Color(0xFF6F8B7A);
const _kSage = Color(0xFF9AB09A);
const _kAccent = Color(0xFF6DC55A);
const _kLikedRose = Color(0xFFE07B7B);
const _kShadowTint = Color(0xFF163220);

class FeedScreen extends StatefulWidget {
  FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final PostController controller = Get.find();

  @override
  void initState() {
    super.initState();
    controller.getAllPosts();
    // Newest-first display via List.reversed in `_feed()` — no scroll-to-bottom
    // dance any more. The previous version's auto-scroll-to-bottom was a
    // chat metaphor that hid the most recent posts on a screen that's
    // semantically a feed. Newest at top is the standard expectation.
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _kCream,
        body: SafeArea(
          child: Column(
            children: [
              _topBar(),
              Expanded(
                child: Obx(() {
                  if (!controller.allPostsLoad.value) {
                    return const Center(child: CircularProgress());
                  }
                  if (controller.postsList.isEmpty) {
                    return _emptyState();
                  }
                  return RefreshIndicator(
                    onRefresh: () async => controller.getAllPosts(),
                    color: _kAccent,
                    child: _list(),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Top bar ───────────────────────────────────────────────────────────

  Widget _topBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
      child: Row(
        children: [
          // Tab-mounted screen — no back button. Title sits left for
          // visual weight balance with the action pill on the right.
          const Text(
            'COMMUNITY',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _kSage,
              letterSpacing: 0.84, // ~.07em at 12px
            ),
          ),
          const Spacer(),
          _composeButton(),
        ],
      ),
    );
  }

  /// Accent pill when the user has an active package; locked sage pill with
  /// a lock icon otherwise. Tap on the locked variant surfaces the same
  /// toast that gated the previous version.
  Widget _composeButton() {
    // `_canPostFreely` returns true for trainers/dietitians OR for users
    // with an active package. Same name (`hasPackage`) preserved below
    // so the existing render branches keep reading naturally.
    final hasPackage = _canPostFreely();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onComposeTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: hasPackage ? _kAccent : _kSage.withOpacity(0.18),
          borderRadius: BorderRadius.circular(20),
          border: hasPackage
              ? null
              : Border.all(color: _kSage.withOpacity(0.4), width: 1),
          boxShadow: hasPackage
              ? [
                  BoxShadow(
                    color: _kAccent.withOpacity(0.30),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasPackage ? Icons.add : Icons.lock_outline,
              color: hasPackage ? Colors.white : _kSage,
              size: 16.sp,
            ),
            SizedBox(width: 6.w),
            Text(
              hasPackage ? 'Post' : 'Locked',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: hasPackage ? Colors.white : _kSage,
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onComposeTap() {
    if (!_canPostFreely()) {
      // Locked → navigate to the plans/subscribe screen instead of the
      // dead-end toast. `OurPlansScreen` is the canonical paywall used by
      // recommended_slots, free-trial flows, and the in-AppBar upgrade CTA.
      Get.to(() => OurPlansScreen());
      return;
    }
    Get.to(() => const CreatePostScreen());
  }

  // ─── Upgrade banner + stats strip (above the list) ─────────────────────

  Widget _upgradeBanner() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // Same destination as the locked "+ Post" pill — `OurPlansScreen` is
      // the project-wide upgrade target.
      onTap: () => Get.to(() => OurPlansScreen()),
      child: Container(
        margin: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kCardBorder, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _kAccent.withOpacity(0.13),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.lock_outline, color: _kAccent, size: 16.sp),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                'Unlock posting & replies',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: _kTextPrimary,
                ),
              ),
            ),
            Text(
              'Upgrade',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: _kAccent,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(Icons.arrow_forward, color: _kAccent, size: 14.sp),
          ],
        ),
      ),
    );
  }

  Widget _statsStrip(int postsToday, int activeMembers) {
    if (postsToday == 0) return const SizedBox.shrink();
    final postsLabel = '$postsToday post${postsToday == 1 ? '' : 's'} today';
    final membersLabel = activeMembers > 0
        ? '$activeMembers member${activeMembers == 1 ? '' : 's'} active'
        : null;
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: _kAccent.withOpacity(0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt, color: _kAccent, size: 12.sp),
                SizedBox(width: 4.w),
                Text(
                  membersLabel == null
                      ? postsLabel
                      : '$postsLabel · $membersLabel',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: _kAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── List + empty state ────────────────────────────────────────────────

  Widget _list() {
    final hasPackage = _canPostFreely();
    // Newest-first display order. Backend returns oldest-first per the
    // previous scroll-to-bottom convention; reversing client-side keeps
    // the API contract identical and the most recent posts at the top.
    final posts = controller.postsList.reversed.toList();
    // Stats strip — derived from existing data, no new endpoint.
    //   - postsToday: how many posts created today (any user)
    //   - activeMembers: count of UNIQUE user.id values that posted today
    // Both drop to a hidden strip when postsToday == 0.
    final today = DateTime.now();
    bool isToday(DateTime c) =>
        c.year == today.year && c.month == today.month && c.day == today.day;
    final todaysPosts =
        controller.postsList.where((p) => isToday(p.createdAt)).toList();
    final postsToday = todaysPosts.length;
    final activeMembers = todaysPosts
        .map((p) => p.user?.id)
        .where((id) => id != null)
        .toSet()
        .length;

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
      itemCount: posts.length + 1, // +1 for the header strip
      separatorBuilder: (_, i) => SizedBox(height: i == 0 ? 0 : 12.h),
      itemBuilder: (context, i) {
        if (i == 0) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!hasPackage)
                Padding(
                  padding: EdgeInsets.zero,
                  child: _upgradeBanner(),
                ),
              if (postsToday > 0)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0),
                  child: _statsStrip(postsToday, activeMembers),
                ),
            ],
          );
        }
        final post = posts[i - 1];
        return _PostCard(
          post: post,
          onLike: () => controller.likePost(post.id),
          onReplyTap: () => _showRepliesSheet(post),
        );
      },
    );
  }

  Widget _emptyState() {
    return ListView(
      // Keep pull-to-refresh working when empty.
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 80.h),
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _kAccent.withOpacity(0.13),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.forum_outlined,
                    size: 28.sp,
                    color: _kAccent,
                  ),
                ),
                SizedBox(height: 18.h),
                Text(
                  'No posts yet',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: _kTextPrimary,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Be the first to share something with the community.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.sp,
                    color: _kTextSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Replies bottom sheet ──────────────────────────────────────────────

  void _showRepliesSheet(Post post) {
    final replyController = TextEditingController();

    void send() {
      final text = replyController.text.trim();
      if (text.isEmpty) return;
      if (!_canPostFreely()) {
        CustomToast.failToast(
          msg:
              "You need an active package to reply. Please subscribe to a plan first.",
        );
        return;
      }
      controller.sendReply(postId: post.id, message: text);
      replyController.clear();
    }

    Get.bottomSheet(
      Container(
        height: MediaQuery.of(Get.context!).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          boxShadow: [
            BoxShadow(
              color: _kShadowTint.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Drag handle
            Padding(
              padding: EdgeInsets.only(top: 10.h),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: _kSage.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 12.h),
              child: Row(
                children: [
                  const Text(
                    'REPLIES',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _kSage,
                      letterSpacing: 0.77,
                    ),
                  ),
                  const Spacer(),
                  Obx(() => Text(
                        '${post.replies.length}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _kTextSecondary,
                        ),
                      )),
                ],
              ),
            ),
            Container(height: 1, color: _kCardBorder),
            Expanded(
              child: Obx(() {
                final replies = post.replies;
                if (replies.isEmpty) return _repliesEmpty();
                return ListView.separated(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  itemCount: replies.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10.h),
                  itemBuilder: (_, i) => _replyTile(replies[i]),
                );
              }),
            ),
            _replyInput(replyController, send),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _repliesEmpty() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline,
                size: 40.sp, color: _kSage.withOpacity(0.6)),
            SizedBox(height: 10.h),
            Text(
              'No replies yet',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: _kTextPrimary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Be the first to reply.',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 12.sp, color: _kTextSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _replyTile(Reply r) {
    final initial =
        (r.user?.firstName ?? 'U').isEmpty ? 'U' : r.user!.firstName[0].toUpperCase();
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: _kCream,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _avatarCircle(initial: initial, size: 32),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        r.user?.firstName ?? 'Unknown',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          fontSize: 13.sp,
                          color: _kTextPrimary,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      _formatTime(r.createdAt),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11.sp,
                        color: _kSage,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),
                Text(
                  r.message,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.sp,
                    color: _kTextPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _replyInput(TextEditingController controller, VoidCallback onSend) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16.w, 8.h, 16.w, 12.h + MediaQuery.of(context).padding.bottom),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _kCream,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _kCardBorder, width: 1),
              ),
              child: TextField(
                controller: controller,
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                style: TextStyle(fontFamily: 'Poppins', fontSize: 13.sp, color: _kTextPrimary),
                decoration: InputDecoration(
                  hintText: 'Write a reply…',
                  hintStyle:
                      TextStyle(fontFamily: 'Poppins', color: _kSage, fontSize: 13.sp),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w, vertical: 10.h),
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onSend,
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: _kAccent,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _kAccent.withOpacity(0.30),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(Icons.arrow_upward_rounded,
                  color: Colors.white, size: 18.sp),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Time format ───────────────────────────────────────────────────────

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// ─── Avatar ───────────────────────────────────────────────────────────────

Widget _avatarCircle({required String initial, double size = 40}) {
  return Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      color: _kAccent,
    ),
    child: Text(
      initial,
      style: TextStyle(
        fontFamily: 'Poppins',
        color: Colors.white,
        fontSize: size * 0.4,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

// Normalises a post image URL so old http:// rows still render. Strips
// any scheme+host and re-prepends the current Constants.baseUrl. Works
// for both absolute (http/https) and already-relative paths.
String _normalisePostImageUrl(String raw) {
  String path = raw;
  if (raw.startsWith('http://') || raw.startsWith('https://')) {
    try {
      path = Uri.parse(raw).path;
    } catch (_) {
      // Malformed URL — fall back to using the raw string as a path.
      path = raw;
    }
  }
  final cleanPath = path.replaceFirst(RegExp(r'^/'), '');
  return '${Constants.baseUrl}/$cleanPath';
}

// ─── Post card (with read-more local state) ───────────────────────────────

class _PostCard extends StatefulWidget {
  final Post post;
  final VoidCallback onLike;
  final VoidCallback onReplyTap;

  const _PostCard({
    required this.post,
    required this.onLike,
    required this.onReplyTap,
  });

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  bool _expanded = false;

  // Heuristic — long enough that the body would overflow ~4 lines at the
  // V2 body type scale (13/500 line-height 1.5 across a card width of
  // roughly 320 logical px). Fine for now; can be replaced with a
  // TextPainter measurement if precision matters later.
  static const int _readMoreThreshold = 220;

  @override
  Widget build(BuildContext context) {
    final p = widget.post;
    final shouldTruncate = !_expanded && p.text.length > _readMoreThreshold;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kCardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: _kShadowTint.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(p),
                if (p.text.isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  Text(
                    shouldTruncate
                        ? '${p.text.substring(0, _readMoreThreshold)}…'
                        : p.text,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: _kTextPrimary,
                      height: 1.5,
                    ),
                  ),
                  if (p.text.length > _readMoreThreshold)
                    Padding(
                      padding: EdgeInsets.only(top: 6.h),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => setState(() => _expanded = !_expanded),
                        child: Text(
                          _expanded ? 'Show less' : 'Read more',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: _kAccent,
                          ),
                        ),
                      ),
                    ),
                ],
                if (p.imageUrl?.isNotEmpty ?? false) ...[
                  SizedBox(height: 12.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: CachedNetworkImage(
                      // Always normalise to <baseUrl>/<path>. Older posts
                      // stored a fully-qualified http:// URL (the backend
                      // used req.protocol, which is "http" behind a proxy
                      // without trust-proxy). iOS ATS / Android cleartext
                      // protection silently block those, so we strip the
                      // host and re-prepend our current baseUrl (https).
                      imageUrl: _normalisePostImageUrl(p.imageUrl!),
                      placeholder: (_, __) => Container(
                        height: 200.h,
                        color: _kCream,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: _kAccent,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        height: 200.h,
                        color: _kCream,
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 36.sp,
                          color: _kSage,
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
          Container(height: 1, color: _kCardBorder),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
            child: Row(
              children: [
                Obx(() => _ActionButton(
                      icon: p.isLiked.value
                          ? Icons.favorite
                          : Icons.favorite_border,
                      label: '${p.likesCount.value}',
                      iconColor:
                          p.isLiked.value ? _kLikedRose : _kSage,
                      onTap: widget.onLike,
                    )),
                SizedBox(width: 18.w),
                Obx(() => _ActionButton(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: '${p.replies.length}',
                      iconColor: _kSage,
                      onTap: widget.onReplyTap,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(Post p) {
    final initial = p.user?.firstName.isNotEmpty == true
        ? p.user!.firstName[0].toUpperCase()
        : 'U';
    final fullName = p.user != null
        ? '${p.user?.firstName ?? ''} ${p.user?.lastName ?? ''}'.trim()
        : 'Unknown';
    return Row(
      children: [
        _avatarCircle(initial: initial, size: 38),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      fullName.isEmpty ? 'Unknown' : fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        fontSize: 13.sp,
                        color: _kTextPrimary,
                      ),
                    ),
                  ),
                  // Role badge — fed from `ClientUser.userType` (defensive
                  // parse in lib/data/models/get_clients_diet.dart). Backend
                  // values per CLAUDE.md: 'Trainer' renders TRAINER,
                  // 'Dietition' (backend typo) renders as the correctly-
                  // spelled DIETITIAN. Anything else (incl. null) → no
                  // badge. Both pills use the same _kAccent green styling.
                  if (_roleLabelFor(p.user?.userType) != null)
                    _RoleBadge(label: _roleLabelFor(p.user?.userType)!),
                ],
              ),
              SizedBox(height: 2.h),
              Text(
                _formatTime(p.createdAt),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: _kSage,
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

/// Maps the backend's raw `userType` value to a display label for the
/// post-author role pill. Returns `null` for regular users (`'User'`),
/// admins, specialists, or any unknown / null value — those don't show a
/// badge.
///
/// Note the backend's literal `'Dietition'` spelling (typo preserved per
/// `CLAUDE.md`) — comparison must use that exact string. The display
/// label is corrected to "DIETITIAN" so the typo never reaches the UI.
String? _roleLabelFor(String? userType) {
  switch (userType) {
    case 'Trainer':
      return 'TRAINER';
    case 'Dietition':
      return 'DIETITIAN';
    default:
      return null;
  }
}

// ─── Role badge (TRAINER / DIETITIAN — same V2 chrome, label varies) ──────

class _RoleBadge extends StatelessWidget {
  final String label;
  const _RoleBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: _kAccent.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: _kAccent,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }
}

// ─── Action button (heart / reply) ────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18.sp, color: iconColor),
            SizedBox(width: 5.w),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: _kTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
