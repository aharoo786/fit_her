import 'package:fitness_zone_2/values/my_imgs.dart';
import 'package:flutter/material.dart';

import '../../../../values/my_colors.dart';
import '../../../../widgets/custom_button.dart';

class RescheduleCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final String message;
  final String imageUrl;
  final Function() firstOnTap;
  final Function() secondOnTap;

  const RescheduleCard({
    super.key,
    required this.name,
    required this.subtitle,
    required this.message,
    required this.imageUrl,
    required this.firstOnTap,
    required this.secondOnTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                  backgroundImage: AssetImage(MyImgs.logo), radius: 20),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(subtitle,
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(message),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomButton(
                text: "Cancel",
                onPressed: firstOnTap,
                height: 25,
                width: 70,
                roundCorner: 20,
                fontSize: 8,
                color: Colors.transparent,
                textColor: MyColors.buttonColor,
              ),
              const SizedBox(width: 6),
              CustomButton(
                text: "Approve",
                onPressed: secondOnTap,
                height: 25,
                width: 70,
                roundCorner: 20,
                fontSize: 8,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
