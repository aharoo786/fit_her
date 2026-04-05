import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../widgets/CustomText.dart';
import '../../../widgets/app_bar_widget.dart';

class ImportantScreen extends StatelessWidget {
  ImportantScreen({Key? key}) : super(key: key);
  bool isChecked = false;
  var textList = [
    'Water intake should be 3 liters per day',
    'Add 30 minutes of walk or any physical activity to boost your cardiac rate',
    'Add more fiber to your diet.',
    'Take 2 tbsp. Of ispaghol in 1 glass of water if you feel constipated.',
    'Salad is portion free.',
    'Take 2 tbsp. Of ispaghol in 1 glass of water if you feel constipated.',
    'Avoid potatoes & arvi banana and mango.',
    'Take fruits as whole rather than taking juices.',
    'Healthy weight loss is 3 to 5 k.g in a month.',
    'Try to complete at least 8000 to 10000 steps daily.',
    'Make detox water by adding 1 slice green apple, mint leaves, ½ tsp.Cinnamon, small piece of ginger soaked for 8 hours in 6 glasses of water.'
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(() {
        Get.back();
      }, text: "Important Tips"),
      body: ListView.builder(
        itemCount: textList.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
            ),
            child: Container(
                padding: const EdgeInsets.only(bottom: 10, top: 10),
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(blurRadius: 10.0, color: Colors.black12)
                    ],
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    color: const Color.fromARGB(255, 255, 255, 255),
                    border: Border.all(
                        width: 0.1, color: Colors.black.withOpacity(0.2))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Checkbox(
                        value: true,
                        onChanged: (bool? ok) {
                          isChecked = ok!;
                        }),
                    Expanded(
                      child: CustomText(
                        Title: textList[index],
                        TitleFontSize: 14,
                      ),
                    ),
                  ],
                )),
          );
        },
      ),
    );
  }
}
