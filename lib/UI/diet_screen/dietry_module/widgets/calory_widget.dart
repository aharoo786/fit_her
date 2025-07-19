import 'package:fitness_zone_2/UI/diet_screen/track_calerories.dart';
import 'package:fitness_zone_2/values/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CaloryWidget extends StatelessWidget {
  const CaloryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () {
        Get.to(() => TrackCalories());
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
            color: const Color(0xffECF3E9),
            borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Calorie Counter",
                    style: textTheme.bodySmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "Track your food calories here",
                    style: textTheme.titleMedium?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: Colors.grey.shade300),
              child: const Icon(
                Icons.add,
                color: MyColors.buttonColor,
              ),
            )
          ],
        ),
      ),
    );
  }
}
