import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../values/my_imgs.dart';
import '../../../widgets/CustomText.dart';
import '../../../widgets/app_bar_widget.dart';

class Success_Stories extends StatelessWidget {
  Success_Stories({super.key});
  var imagePath = [
    MyImgs.review1,
    MyImgs.review2,
    MyImgs.review3,
    MyImgs.review4,
    MyImgs.review5,
    MyImgs.review6,
  ];

  var text = [
    "Miss Kavita joined us from India, and she reduced 8 to 10 kgs in 2 months with fat loss and Inch loss also, and the transformation is visible.",
    "I am Maham, I joined Fitness Zone when I was 56 and my posture was also bad I looked chubby. In starting I was shocked that staying at home is it possible to reduce weight  but from the first week I started losing weight in 5 days I reduced 1kg. And in a month 6kgs down that was my ideal weight.😇",
    "Hello ma'am, myself Sonali Joshi. I had joined fitness zone on june 26th. My weight was 60 kg. I had reduced 6 kg and now m 54 kg. M sooo happy. Not only my weight is reduced, but I lost Inches which is awesome. M suffering from premanopose and doctors told me to reduce weight upto 53 kg and m almost near to my target. My periods become regular, no pains and no vomiting during periods. Thank you so much fitness zone. Credit goes to Farzana ma'am, dietician ma'am and whole fitness zone team. Thanks a lot. Love you Allaah aapko bahut khusiya de aur aapki bahut taraqii ho",
    "Miss Tahira reduced 7kgs in a month no doubt she is a good student. Regular in sessions and Stick to the diet plan and trust our Experts and results are visible.😇",
    "Miss Hannah reduced 10kgs in 2.5 Months. More power to her 👍. And fat loss with inches loss also visible 🤞",
    "I m so happy ma'am mashallah I have lose 10 kg almost and also 3 inches of every part... I am so happy in two months fitness zone helped me so much in my weight loss journey. I love you all miss Zainab miss Rumina and miss sobia all are very honest and loving and caring... The best platform fitnesszone... I will prefer it for whole my life and to my family and friends to join fitness zone.♥️😘😍"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(() {
        Get.back();
      }, text: "Success Stories"),
      body: ListView.separated(
        itemCount: text.length,
        padding: EdgeInsets.all(20.h),
        itemBuilder: (BuildContext context, int index) {
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Image.asset(
              imagePath[index],
              height: 80.h,
              width: 80.h,
            ),
            SizedBox(
              width: 10.w,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image.asset(imagePath[index]),
                  Text(
                    text[index],
                    style:  TextStyle(
                      fontSize: 16.sp,
                      color: const Color.fromARGB(255, 60, 60, 60),
                    ),
                  ),
                  // CustomText(
                  //   Title: "Terry Summerson",
                  //   TitleFontSize: 16,
                  //   TitleColor: Colors.black,
                  // )
                ],
              ),
            )
          ]);
        },
        separatorBuilder: (BuildContext context, int index) => SizedBox(
          height: 30.h,
        ),
      ),
    );
  }
}
