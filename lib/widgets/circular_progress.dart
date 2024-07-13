import 'package:flutter/material.dart';

import '../values/my_colors.dart';
class CircularProgress extends StatelessWidget {
  const CircularProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return  const Center(child: CircularProgressIndicator(color: MyColors.buttonColor,),);
  }
}
