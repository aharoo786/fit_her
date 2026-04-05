import 'package:fitness_zone_2/values/my_colors.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class TutorialScreen extends StatelessWidget {
  final List<Map<String, String>> tutorials = [
    {"id": "-5OaR6ujny0", "title": "How to Freeze/Unfreeze your plan?"},
    {"id": "PX74nzUl0uc", "title": "Enroll to the plan of your choice"},
    {"id": "yEn_ej-5zNo", "title": "How to book a Dietary Appointment?"},
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: MyColors.grey100,
      appBar: HelpingWidgets().appBarWidget(() {
        Get.back();
      }, text: "Tutorials"),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        children: [
          // Header section
          Container(
            padding: EdgeInsets.all(20.w),
            margin: EdgeInsets.only(bottom: 24.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [MyColors.planColor, MyColors.workOut1],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: MyColors.buttonColor.withOpacity(0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.play_circle_outline,
                    size: 36.sp,
                    color: MyColors.buttonColor,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Learn & Grow",
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: MyColors.textColor,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "Watch step-by-step guides to get the most out of Fit Her",
                        style: textTheme.bodyMedium?.copyWith(
                          color: MyColors.grey,
                          fontSize: 13.sp,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Tutorial cards
          ...List.generate(tutorials.length, (index) {
            final videoId = tutorials[index]["id"]!;
            final title = tutorials[index]["title"]!;
            return _TutorialCard(
              index: index + 1,
              title: title,
              videoId: videoId,
            );
          }),
        ],
      ),
    );
  }
}

class _TutorialCard extends StatelessWidget {
  final int index;
  final String title;
  final String videoId;

  const _TutorialCard({
    required this.index,
    required this.title,
    required this.videoId,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card header with step number
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: MyColors.buttonColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: MyColors.buttonColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "$index",
                      style: textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: MyColors.textColor,
                        fontSize: 15.sp,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Video player
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.w),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: YoutubePlayer(
                      controller: YoutubePlayerController(
                        initialVideoId: videoId,
                        flags: const YoutubePlayerFlags(
                          autoPlay: false,
                          mute: false,
                          hideControls: false,
                          controlsVisibleAtStart: true,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
