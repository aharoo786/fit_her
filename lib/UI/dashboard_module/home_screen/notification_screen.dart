import 'package:fitness_zone_2/values/my_colors.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(() {
        Get.back();
      }, text: "Notifications"),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Icon(
              Icons.notifications_none,
              color: MyColors.buttonColor,
              size: 150,
            ),
          ),
          SizedBox(
            height: 50,
          ),
          Text('Nothing here!',
              style: textTheme.headlineMedium!
                  .copyWith(fontSize: 32, fontWeight: FontWeight.w600)),
          SizedBox(
            height: 10,
          ),
          Text('If there’ll be something to\nnotify you, you’ll see it here.',
              style:
                  textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
