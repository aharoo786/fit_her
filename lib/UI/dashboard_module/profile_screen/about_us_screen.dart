import 'package:flutter/material.dart';
import '../../../values/my_imgs.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../widgets/app_bar_widget.dart';

class AboutUsScreen extends StatelessWidget {
  AboutUsScreen({Key? key}) : super(key: key);

  final List<Color> colors = [
    Colors.grey,
    Colors.blueGrey,
    Colors.teal,
    Colors.white10,
    Colors.yellow,
    Colors.tealAccent
  ];
  final List<String> images = [
    MyImgs.yoga,
    MyImgs.zumba,
    MyImgs.cardio,
    MyImgs.mediation,
    MyImgs.zumba,
    MyImgs.yoga,
  ];
  final List<String> textList = [
    "Yoga",
    "Zumba",
    "Cardio",
    "Mediation",
    "Strength",
    "Training"

  ];

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(() {
        Get.back();
      }, text: "About Us"),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Column(
            //       children: [
            //         Image.asset(
            //           MyImgs.img1,
            //           scale: 3.3,
            //         ),
            //         SizedBox(
            //           height: 12.h,
            //         ),
            //         Image.asset(
            //           MyImgs.img2,
            //           scale: 3.3,
            //         )
            //       ],
            //     ),
            //     Column(
            //       children: [
            //         ClipRRect(
            //             borderRadius: const BorderRadius.only(
            //               bottomLeft: Radius.circular(8),
            //               bottomRight: Radius.circular(8),
            //             ),
            //             child: Image.asset(
            //               MyImgs.img3,
            //               width: 130,
            //               height: 20,
            //               fit: BoxFit.fitWidth,
            //             )),
            //         const SizedBox(
            //           height: 12,
            //         ),
            //         Image.asset(
            //           MyImgs.img4,
            //           scale: 3.3,
            //         ),
            //         SizedBox(
            //           height: 12.h,
            //         ),
            //         Image.asset(
            //           MyImgs.img5,
            //           scale: 3.3,
            //         )
            //       ],
            //     ),
            //     Column(
            //       children: [
            //         ClipRRect(
            //             borderRadius: const BorderRadius.only(
            //               bottomLeft: Radius.circular(8),
            //               bottomRight: Radius.circular(8),
            //             ),
            //             child: Image.asset(
            //               MyImgs.img6,
            //               width: 130,
            //               height: 60,
            //               fit: BoxFit.fitWidth,
            //             )),
            //         SizedBox(
            //           height: 12.h,
            //         ),
            //         Image.asset(
            //           MyImgs.img7,
            //           scale: 3.3,
            //         ),
            //       ],
            //     ),
            //     Column(
            //       children: [
            //         Image.asset(
            //           MyImgs.img8,
            //           scale: 3.3,
            //         ),
            //         SizedBox(
            //           height: 12.h,
            //         ),
            //         Image.asset(
            //           MyImgs.img9,
            //           scale: 3.3,
            //         )
            //       ],
            //     ),
            //   ],
            // ),
            SizedBox(
              height: 16.h,
            ),
            Padding(
              padding: EdgeInsets.only(left: 20.w),
              child: Text(
                "About FitHer",
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
              ),
            ),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.only(left: 20.w),
              child: Text(
                "It's a package of your health, fitness, and beauty. You will reduce 4 to 7 kgs in a month with us. Here, you have live support of experts for dietary consultancy or advice, and you will get a customised plan, and it will be tracked through daily reminders. Also, you will have a gym at home on your cell phone, Your trainer will be available on-screen to guide you and help you maintain your postures. Live support of all our team(experts) will be available for you.",
                style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[500]),
              ),
            ),
            SizedBox(
              height: 16.h,
            ),
            // Padding(
            //   padding: EdgeInsets.only(left: 20.w),
            //   child: Text(
            //     "Workout Plans",
            //     style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
            //   ),
            // ),
            // SizedBox(height: 16.w),
            // SizedBox(
            //     height: 110.h,
            //     child: ListView.builder(
            //       scrollDirection: Axis.horizontal,
            //       itemBuilder: (BuildContext context, int index) => Container(
            //         margin: EdgeInsets.only(left: 10.w, right: 10.w),
            //         decoration: BoxDecoration(
            //             // color: Colors.yellow,
            //             borderRadius: BorderRadius.circular(8)),
            //         child: Column(
            //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //           children: [
            //             Container(
            //               height: 70.h,
            //               width: 70.w,
            //               decoration: BoxDecoration(
            //                   color: colors[index],
            //                   borderRadius: BorderRadius.circular(8)),
            //               child: Image.asset(
            //                 images[index],
            //                 scale: 3.5,
            //               ),
            //             ),
            //             Text(
            //               textList[index],
            //               style: textTheme.titleLarge!.copyWith(),
            //             ),
            //             SizedBox(
            //               height: 10.h,
            //             ),
            //           ],
            //         ),
            //       ),
            //       itemCount: textList.length,
            //     )),
          ],
        ),
      ),
    );
  }
}
