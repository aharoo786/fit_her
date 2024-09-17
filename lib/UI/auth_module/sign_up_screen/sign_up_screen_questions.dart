import 'package:fitness_zone_2/UI/auth_module/questionair_screen.dart';
import 'package:fitness_zone_2/UI/auth_module/sign_up_screen/BMI_result.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../values/dimens.dart';
import '../../../values/my_colors.dart';
import '../../../widgets/custom_button.dart';

class SignUpScreenQuestions extends StatefulWidget {
  @override
  _SignUpScreenQuestionsState createState() => _SignUpScreenQuestionsState();
}

class _SignUpScreenQuestionsState extends State<SignUpScreenQuestions> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int _currentIndex = 1;
  List<int> ageNumber = List.generate(100 - 18 + 1, (index) => 18 + index);
  List<int> weight = List.generate(150 - 28 + 1, (index) => 28 + index);
  List<String> height = [];
  @override
  void initState() {
    for (int feet = 3; feet <= 7; feet++) {
      for (int inches = 0; inches < 12; inches++) {
        height.add("${feet}.${inches}");
      }
    }
    answers = [
      _pages[0].options![0],
      ageNumber[1],
      weight[1],
      height[1],
      _pages[4].options![0]
    ];
    print("answers $answers");
    super.initState();
  }

  final List<Question> _pages = [
    Question(text: "What’s your goal?", options: [
      "Lose Weight",
      "Improve Fitness",
      "Build Muscles",
      "Reduce Stress",
      "For Consultancy",
    ]),
    Question(text: "Let’s get your age.", options: ["age"]),
    Question(text: "Let’s get your weight.", options: ["weight"]),
    Question(text: "Let’s get your height(Feet)", options: ["height"]),
    Question(
        text: "What’s time suits you?",
        options: ["Morning", "Afternoon", "Evening", "No preference"])
  ];
  List<dynamic> answers = [];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(
        () {
          if (_currentPage > 0) {
            _pageController.previousPage(
                duration: Duration(microseconds: 100), curve: Curves.easeIn);
          } else {
            Get.back();
          }
        },
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Step ${_currentPage + 1}/${_pages.length}",
                  style: textTheme.bodySmall!.copyWith(
                      color: MyColors.black, fontWeight: FontWeight.w400),
                ),
                SizedBox(
                  height: Dimens.size5.h,
                ),
                Text(
                  _pages[_currentPage].text,
                  style: textTheme.headlineSmall!.copyWith(
                      fontSize: 24.sp,
                      color: MyColors.textColor3,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            Expanded(
              child: PageView.builder(
                physics: const NeverScrollableScrollPhysics(),
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_pages[_currentPage].options!.length == 1) ...{
                          if (_pages[_currentPage].options!.contains("age"))
                            buildScrollPicker(ageNumber, textTheme),
                          if (_pages[_currentPage].options!.contains("weight"))
                            buildScrollPicker(weight, textTheme),
                          if (_pages[_currentPage].options!.contains("height"))
                            buildScrollPicker(height, textTheme)
                        } else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, indexO) {
                              var option = _pages[index].options![indexO];
                              return CustomButton(
                                text: option,
                                onPressed: () {
                                  answers[_currentPage] =
                                      _pages[index].options![indexO];
                                  setState(() {});
                                },
                                color: answers[_currentPage] ==
                                        _pages[index].options![indexO]
                                    ? MyColors.buttonColor
                                    : Colors.white,
                                textColor: MyColors.black,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w400,
                              );
                            },
                            separatorBuilder: (context, index) {
                              return SizedBox(
                                height: 24.h,
                              );
                            },
                            itemCount: _pages[index].options!.length,
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 20.w,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 10.h,
            ),
            CustomButton(
                text: _currentPage < _pages.length - 1 ? 'Next' : 'Done',
                onPressed: () async {
                  if (_currentPage < _pages.length - 1) {
                    _pageController.nextPage(
                        duration: const Duration(microseconds: 100),
                        curve: Curves.easeInOut);
                    print("answers $answers");
                  } else {
                    var heightInMeters = (double.parse(answers[3]) * 0.3048) *
                        (double.parse(answers[3]) * 0.3048);
                    var bmi = answers[2] / heightInMeters;

                    Get.offAll(() => BmiResult(
                          bmi: bmi.toStringAsFixed(2),
                        ));
                  }
                }),
            SizedBox(
              height: 30.h,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildScrollPicker(List<dynamic> values, TextTheme textTheme) {
    return SizedBox(
      height: 100,
      width: 300,
      child: Row(
        children: [
          if (_currentIndex != 0)
            Text(
              values[_currentIndex - 1].toString(),
              style: textTheme.bodySmall!.copyWith(
                color: MyColors.black.withOpacity(0.2),
                fontSize: 48.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          Expanded(
            child: PageView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: values.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                  answers[_currentPage] = values[index];
                });
              },
              itemBuilder: (context, index) {
                return Center(
                  child: Text(
                    values[_currentIndex].toString(),
                    style: textTheme.bodySmall!.copyWith(
                      color: MyColors.textColor3,
                      fontSize: 60.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ),
          if (_currentIndex <= values.length - 2)
            Text(
              values[_currentIndex + 1].toString(),
              style: textTheme.bodySmall!.copyWith(
                color: MyColors.black.withOpacity(0.2),
                fontSize: 48.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}
