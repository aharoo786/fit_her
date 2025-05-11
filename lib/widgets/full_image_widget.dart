import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../values/constants.dart';

class FullImageWidget extends StatelessWidget {
  const FullImageWidget({super.key, required this.image});
  final String image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: HelpingWidgets().appBarWidget(() {
        Get.back();
      }),
      body: Center(
        child: Image.network("${Constants.baseUrl}/${image}"),
      ),
    );
  }
}
