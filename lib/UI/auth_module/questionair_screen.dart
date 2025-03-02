import 'package:fitness_zone_2/UI/auth_module/result_screen.dart';
import 'package:fitness_zone_2/data/controllers/auth_controller/auth_controller.dart';
import 'package:fitness_zone_2/values/my_colors.dart';
import 'package:fitness_zone_2/values/my_imgs.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:fitness_zone_2/widgets/toasts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  _QuestionnaireScreenState createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  PageController pageController = PageController();

  int _currentPageIndex = 0;
  final List<Question> _questions = [
    Question(
      text: "What is your age?",
      options: ['Under 18', '18-25', '26-35', '36-45', 'Over 45'],
    ),
    Question(
      text: "How often do you get your periods?",
      options: [
        'My periods are regular (Every 21-34 days)',
        'I get my periods every 20 days or less',
        'I get my periods every 35 days or longer',
        'I go months without a period',
        'I am on birth control so I don\'t know',
      ],
    ),
    Question(
      text: "For how many days do you bleed when you are on your periods?",
      options: [
        '1-2\nDays',
        '3-10\nDays',
        '10+\nDays',
      ],
    ),
    Question(
      text: "How heavy is your bleeding during your period?",
      options: [
        'Light Bleeding',
        'Normal Bleeding',
        'Heavy Bleeding/Clots of blood'
      ],
    ),
    Question(
      text: "How often do you change your pad?",
      options: [
        'I change my pad every 1-2 hours',
        'I change my pad every 2-3 hours',
        'I change my pad every 3-5 hours',
        "I change my pad every 8 hours"
      ],
    ),
    Question(
      text: "Do you notice any of the following on any part of your body?",
      options: [
        'none',
        'I notice dark and thick hair growth on various parts of my body',
        'I notice acne on various parts of my body (Face, back)',
        'I notice oil on my skin',
      ],
    ),
    Question(
      text: "Do you experience mood swings, anxiety, or depression?",
      options: ['Yes, frequently', 'Yes, occasionally', 'No, rarely or never'],
    ),
    Question(
      text: "Have you noticed thinning hair or bald patches?",
      options: [
        'Yes, significant hair loss',
        'Yes, moderate hair loss',
        'No, hair appears healthy'
      ],
    ),
    Question(
      text:
          "Have you noticed darkening of your skin, especially in skin folds like the neck, groin, or underarms?",
      options: [
        'Yes, significant darkening',
        'Yes, moderate darkening',
        'No, skin appears normal'
      ],
    ),
    Question(
      text: "Have you experienced difficulty getting pregnant?",
      options: [
        'Yes, have tried without success',
        'Yes, currently undergoing fertility treatments',
        'No, have not tried to conceive or no issues conceiving'
      ],
    ),
    // Add more questions as needed
  ];
  late final List<String>? _answers; // Initialize with empty strings
  @override
  void initState() {
    _answers = List.filled(_questions.length, "");
    super.initState();
  }

  String answer = "";
  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(() {
        Get.back();
      }, text: "PCOS Assessment Test"),
      body: PageView.builder(
        controller: pageController,
        itemCount: _questions.length,
        itemBuilder: (context, index) {
          return _buildQuestionPage(index, textTheme);
        },
        onPageChanged: (index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (_currentPageIndex > 0) {
                    pageController.previousPage(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.bounceIn);
                  }
                },
              ),
              Text('${_currentPageIndex + 1}/${_questions.length}'),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () {
                  if (_currentPageIndex < _questions.length - 1) {
                    pageController.nextPage(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.bounceIn);
                  } else {
                    String result = "result";
                    var emptyAnswer = _answers!.any((element) => element == "");

                    if (emptyAnswer) {
                      CustomToast.failToast(
                          msg: "Please fill up all the questions");
                    } else {
                      var low = _answers!
                          .where((element) => element == "0")
                          .toList()
                          .length;
                      var moderate = _answers!
                          .where((element) => element == "1")
                          .toList()
                          .length;
                      var high = _answers!
                          .where((element) => element == "2")
                          .toList()
                          .length;
                      if (low > moderate && low > high) {
                        result = "Low Risk of PCOS";
                      } else if (moderate > low && moderate > low) {
                        result = "Moderate Risk of PCOS";
                      } else {
                        result = "High Risk of PCOS";
                      }
                      Get.find<AuthController>().guestLogin(result);
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionPage(int index, TextTheme textTheme) {
    final question = _questions[index];
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text(
              question.text,
              style:
                  textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Image.asset(MyImgs.pcos),
          const SizedBox(height: 40.0),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(
                  question.options!.length,
                  (optionIndex) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 7, horizontal: 10),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: const BoxDecoration(
                        color: MyColors.planColor,
                      ),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(4)),
                            child: Checkbox(
                              visualDensity: const VisualDensity(
                                  horizontal: -4, vertical: -4),
                              value: question.selectedIndex == optionIndex,
                              hoverColor: Colors.white,
                              onChanged: (value) {
                                setState(() {
                                  _answers![index] =
                                      question.options![optionIndex];

                                  if (value == true) {
                                    question.selectedIndex = optionIndex;
                                  } else {
                                    question.selectedIndex = null;
                                  }
                                });
                              },
                              side: BorderSide.none,
                              checkColor: MyColors.primaryGradient1,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Text(
                              question.options![optionIndex],
                              style: textTheme.titleLarge!.copyWith(
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: null,
                            ),
                          )
                        ],
                      ),
                    );

                    // return RadioListTile(
                    //   shape: RoundedRectangleBorder(
                    //     borderRadius: BorderRadius.circular(
                    //         8.0), // Adjust the radius as needed
                    //     side: BorderSide(
                    //         color: Colors.black,
                    //         width: 1.5), // Define border color and width
                    //   ),
                    //   visualDensity: const VisualDensity(vertical: -4),
                    //   title: Text(
                    //     question.options![optionIndex],
                    //     style:
                    //         TextStyle(fontWeight: FontWeight.w500, fontSize: 16.sp),
                    //   ),
                    //   value: optionIndex.toString(),
                    //   fillColor: WidgetStateProperty.resolveWith<Color>(
                    //     (Set<WidgetState> states) {
                    //       if (states.contains(WidgetState.selected)) {
                    //         return Colors.black; // Color when selected
                    //       }
                    //       return Colors.black; // Color when not selected
                    //     },
                    //   ),
                    //   groupValue: _answers![index],
                    //   onChanged: (value) {
                    //     setState(() {
                    //       _answers![index] = value.toString();
                    //     });
                    //   },
                    // );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Question {
  final String text;
  final List<String>? options;
  int? selectedIndex;

  Question({
    required this.text,
    this.options,
    this.selectedIndex,
  });
}
