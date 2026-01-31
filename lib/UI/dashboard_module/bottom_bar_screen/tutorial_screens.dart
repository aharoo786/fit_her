import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:get/get.dart';

class TutorialScreen extends StatelessWidget {
  final List<Map<String, String>> tutorials = [
    {"id": "-5OaR6ujny0", "title": "How to Freeze/Unfreeze your plan?"},
    {"id": "PX74nzUl0uc", "title": "Enroll to the plan of your choice"},
    {"id": "yEn_ej-5zNo", "title": "How to book a Dietary Appointment?"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(() {
        Get.back();
      }, text: "Tutorials "),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tutorials.length,
        itemBuilder: (context, index) {
          final videoId = tutorials[index]["id"]!;
          final title = tutorials[index]["title"]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              AspectRatio(
                  aspectRatio: 16 / 9,
                  child: YoutubePlayer(
                    controller: YoutubePlayerController(
                      initialVideoId: videoId,
                      flags: const YoutubePlayerFlags(autoPlay: false),
                    ),
                  )),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}
