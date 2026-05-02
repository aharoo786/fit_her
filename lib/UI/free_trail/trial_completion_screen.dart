import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:fitness_zone_2/UI/free_trail/trial_conversion_success_screen.dart';
import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/values/my_colors.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:fitness_zone_2/widgets/custom_button.dart';
import 'package:fitness_zone_2/widgets/custom_textfield.dart';
import 'package:fitness_zone_2/widgets/toasts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class TrialCompletionScreen extends StatefulWidget {
  const TrialCompletionScreen({super.key});

  @override
  State<TrialCompletionScreen> createState() => _TrialCompletionScreenState();
}

class _TrialCompletionScreenState extends State<TrialCompletionScreen> {
  final HomeController homeController = Get.find();
  final TextEditingController commentController = TextEditingController();

  double rating = 4;
  String classReview = "Fun & Engaging";
  bool feedbackSubmitted = false;

  final List<String> positiveTags = const [
    "Fun & Engaging",
    "Clear Guidance",
    "Good Pace",
    "Challenging",
    "Supportive",
  ];

  final List<String> negativeTags = const [
    "Dull & Boring",
    "Confusing",
    "Too Fast",
    "Too Easy",
    "UnSupportive",
  ];

  Future<void> submitFeedback() async {
    if (feedbackSubmitted) {
      return;
    }

    final success = await homeController.submitTrialFeedback(
      rating: rating,
      comment: commentController.text,
      classReview: classReview,
    );

    if (success) {
      setState(() {
        feedbackSubmitted = true;
      });
    }
  }

  Future<void> continueToPlans() async {
    if (!feedbackSubmitted) {
      CustomToast.failToast(msg: "Please submit feedback before continuing");
      return;
    }

    final converted = await homeController.markTrialConverted();
    if (!converted) {
      return;
    }

    homeController.getPlansUser();
    Get.to(() => const TrialConversionSuccessScreen());
  }

  Widget buildTag(String tag, Color color) {
    final selected = classReview == tag;
    return GestureDetector(
      onTap: () {
        setState(() {
          classReview = tag;
        });
      },
      child: Chip(
        label: Text(
          tag,
          style: TextStyle(color: selected ? color : Colors.grey),
        ),
        shape: StadiumBorder(
          side: BorderSide(color: selected ? color : Colors.grey),
        ),
        backgroundColor: Colors.transparent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(() {
        Get.back();
      }, text: "Trial Complete"),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            "You completed all 3 trial days!",
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            "Share quick feedback and unlock your full plan.",
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          RatingBar(
            filledIcon: Icons.star,
            emptyIcon: Icons.star_border,
            onRatingChanged: (value) {
              rating = value;
            },
            initialRating: 4,
            size: 36,
            maxRating: 5,
            alignment: Alignment.center,
          ),
          const SizedBox(height: 20),
          Text("What described your classes best?", style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: positiveTags.map((tag) => buildTag(tag, Colors.green)).toList(),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: negativeTags.map((tag) => buildTag(tag, Colors.red)).toList(),
          ),
          const SizedBox(height: 12),
          CustomTextField(
            text: "Any comments?",
            controller: commentController,
            length: 400,
            height: 110,
            maxlines: 4,
            keyboardType: TextInputType.multiline,
            inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: feedbackSubmitted ? "Feedback Submitted" : "Submit Feedback",
            color: feedbackSubmitted ? Colors.white : null,
            borderColor: MyColors.buttonColor,
            textColor: feedbackSubmitted ? MyColors.buttonColor : Colors.white,
            onPressed: submitFeedback,
          ),
          const SizedBox(height: 10),
          CustomButton(
            text: "Unlock Full Plan",
            onPressed: continueToPlans,
          ),
        ],
      ),
    );
  }
}
