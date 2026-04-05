import 'package:fitness_zone_2/values/my_colors.dart';
import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton(
      {super.key,
      required this.onTap,
      required this.iconData,
      required this.text,
      this.backGroundColor = MyColors.buttonColor});
  final Function() onTap;
  final IconData iconData;
  final String text;
  final Color backGroundColor;

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: backGroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
      ),
      child: Row(
        children: [
          Icon(
            iconData,
            color: Colors.white,
            size: 10,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
