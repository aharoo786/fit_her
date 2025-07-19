import 'package:fitness_zone_2/data/controllers/rating_controller/rating_controller.dart';
import 'package:fitness_zone_2/widgets/custom_button.dart';
import 'package:fitness_zone_2/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../values/constants.dart';

class FeedbackBottomSheet extends StatelessWidget {
  String planId;
  String trainerOrDiet;

  FeedbackBottomSheet(this.planId, this.trainerOrDiet, {super.key});

  TextEditingController comment = TextEditingController();
  RatingController ratingController = Get.find();

  double rating = 3.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      child: ListView(
        //  mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Your feedback helps us improve.",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          SizedBox(height: 8),
          Text("Help us improve your experience by rating the session."),
          SizedBox(height: 16),
          RatingBar(
            filledIcon: Icons.star,
            alignment: Alignment.center,
            emptyIcon: Icons.star_border,
            onRatingChanged: (value) {
              rating = value;
            },
            initialRating: 3,
            size: 40,
            maxRating: 5,
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  const Column(
                    children: [
                      Icon(Icons.sentiment_satisfied,
                          color: Colors.green, size: 40),
                      SizedBox(height: 4),
                      Text("Fun & Engaging",
                          style: TextStyle(color: Colors.green)),
                    ],
                  ),
                  SizedBox(height: 16),
                  _buildFeedbackTag("Fun & Engaging", Colors.green),
                  _buildFeedbackTag("Clear Guidance", Colors.green),
                  _buildFeedbackTag("Good Pace", Colors.green),
                  _buildFeedbackTag("Challenging", Colors.green),
                  _buildFeedbackTag("Supportive", Colors.green),
                ],
              ),
              Column(
                children: [
                  const Column(
                    children: [
                      Icon(Icons.sentiment_dissatisfied,
                          color: Colors.red, size: 40),
                      SizedBox(height: 4),
                      Text("Dull & Boring",
                          style: TextStyle(color: Colors.red)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildFeedbackTag("Dull & Boring", Colors.red),
                  _buildFeedbackTag("Confusing", Colors.red),
                  _buildFeedbackTag("Too Fast", Colors.red),
                  _buildFeedbackTag("Too Easy", Colors.red),
                  _buildFeedbackTag("UnSupportive", Colors.red),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomTextField(
              text: "Add Comment",
              length: 1000,
              height: 100,
              maxlines: 4,
              controller: comment,
              keyboardType: TextInputType.text,
              inputFormatters: FilteringTextInputFormatter.singleLineFormatter),
          const SizedBox(height: 16),
          CustomButton(
              text: "Send Feedback",
              onPressed: () {
                Get.find<RatingController>().sharedPreferences.remove(Constants.giveReview);


                Get.find<RatingController>().addClassReview(
                    planId, comment.text, rating, trainerOrDiet);
              }),
        ],
      ),
    );
  }

  Widget _buildFeedbackTag(String text, Color color) {
    return GestureDetector(
      onTap: () {
        ratingController.classReview.value = text;
      },
      child: Obx(
        () => Chip(
          label: Text(
            text,
            style: TextStyle(
                color: ratingController.classReview.value == text
                    ? color
                    : Colors.grey),
          ),
          backgroundColor: Colors.transparent,
          shape: StadiumBorder(
            side: BorderSide(
                color: ratingController.classReview.value == text
                    ? color
                    : Colors.grey),
          ),
          labelStyle: TextStyle(
              color: ratingController.classReview.value == text
                  ? color
                  : Colors.grey),
        ),
      ),
    );
  }
}
