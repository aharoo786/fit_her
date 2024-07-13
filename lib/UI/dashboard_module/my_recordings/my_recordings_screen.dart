import 'package:flutter/material.dart';

import '../../../values/my_colors.dart';
import '../../../values/my_imgs.dart';
import '../../../widgets/app_bar_widget.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyRecordingsScreen extends StatelessWidget {
  const MyRecordingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
        appBar: HelpingWidgets().appBarWidget(() {
          Get.back();
        }, text: "All Recordings"),
        body: Column(
          children: [
            Expanded(
                child: ListView.separated(
              padding:  EdgeInsets.all(20.h),
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w,vertical:15.h ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 22,

                        offset: const Offset(0,2),
                        color: Colors.black.withOpacity(0.2)
                      )
                    ],
                    borderRadius: BorderRadius.circular(8)
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Video #${index+1}",
                          style: textTheme.bodyLarge!
                              .copyWith(color: MyColors.textColor),
                        ),
                        Text(
                          "Duration: 10 minutes",
                          style: textTheme.titleMedium!
                              .copyWith(color: MyColors.textColor),
                        ),
                      ],
                    ),
                    Image.asset(MyImgs.yoga2,scale:2 ,)

                  ]),
                );
              },
              itemCount: 10,
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(
                  height: 12.h,
                );
              },
            ))
          ],
        ));
  }
}
