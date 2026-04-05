import 'package:flutter/material.dart';

import '../values/my_colors.dart';

class GradientBorderContainer extends StatelessWidget {
  final Widget child;
  final double borderWidth;

  const GradientBorderContainer({
    required this.child,
    this.borderWidth = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            MyColors.primaryGradient1,
            MyColors.primaryGradient2,
            MyColors.primaryGradient3,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: EdgeInsets.all(borderWidth),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15 - borderWidth),
        ),
        child: child,
      ),
    );
  }
}
