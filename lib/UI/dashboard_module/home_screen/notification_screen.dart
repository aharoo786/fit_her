import 'package:fitness_zone_2/data/controllers/auth_controller/auth_controller.dart';
import 'package:fitness_zone_2/values/my_colors.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../values/my_imgs.dart';

class NotificationScreen extends StatelessWidget {
  NotificationScreen({super.key});
  final AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(() {
        Get.back();
      }, text: "Notifications"),
      body: ValueListenableBuilder<List<dynamic>?>(
        valueListenable: authController.sharedPrefNotifier,
        builder: (context, value, child) {
          return ListView.separated(
              itemBuilder: (context, index) => Dismissible(
                    key: UniqueKey(),
                    onDismissed: (dismiss) {
                      authController.removeItem(index);
                    },
                    background: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.centerRight,
                      color: Colors.red,
                      child: Icon(Icons.delete,color: Colors.white,),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white10),
                              child: Image.asset(
                                MyImgs.logo,
                                height: 30,
                              )),
                          title: Text(
                            value![index].title,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            value[index].body,
                            style: textTheme.titleLarge!
                                .copyWith(color: Colors.grey),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Divider(
                            height: 1,
                            color: Colors.grey.withOpacity(0.3),
                          ),
                        )
                      ],
                    ),
                  ),
              separatorBuilder: (context, index) => SizedBox(
                    height: 0,
                  ),
              itemCount: value == null ? 0 : value.length);

          // return Text(
          //   value != null ? 'Stored Value: $value' : 'No Value Stored',
          //   style: TextStyle(fontSize: 20),
          // );
        },
      ),

      // Column(
      //   crossAxisAlignment: CrossAxisAlignment.center,
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   children: [
      //     Center(
      //       child: Icon(
      //         Icons.notifications_none,
      //         color: MyColors.buttonColor,
      //         size: 150,
      //       ),
      //     ),
      //     SizedBox(
      //       height: 50,
      //     ),
      //     Text('Nothing here!',
      //         style: textTheme.headlineMedium!
      //             .copyWith(fontSize: 32, fontWeight: FontWeight.w600)),
      //     SizedBox(
      //       height: 10,
      //     ),
      //     Text('If there’ll be something to\nnotify you, you’ll see it here.',
      //         style:
      //             textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w500),
      //       textAlign: TextAlign.center,
      //     ),
      //   ],
      // ),
    );
  }
}
