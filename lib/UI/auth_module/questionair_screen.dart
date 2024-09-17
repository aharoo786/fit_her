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
      text: "How regular are your menstrual cycles?",
      options: [
        'Regular (28-35 days)',
        'Somewhat irregular (36-45 days)',
        'Highly irregular (46 days or longer)'
      ],
    ),
    Question(
      text: "How heavy is your bleeding during your period?",
      options: [
        'Light',
        'Normal; change pad/tampon every 3-4 hours',
        'Very heavy during period',
        'Notice clots of blood during period',
        'Both very heavy bleeding and clots of blood',
      ],
    ),
    Question(
      text:
          "Do you experience acne that doesn't seem to respond well to treatment?",
      options: ['Yes, significantly', 'Yes, moderately', 'No, not noticeable'],
    ),
    Question(
      text:
          "Have you experienced unexplained weight gain, especially around your midsection",
      options: [
        'Yes, significant weight gain',
        'Yes, moderate weight gain',
        'No, weight has remained stable'
      ],
    ),
    Question(
      text: "Do you often feel fatigued or have low energy levels?",
      options: [
        'Yes, frequently exhausted',
        'Yes, occasionally fatigued',
        'No, generally have good energy levels'
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
                      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: const BoxDecoration(
                        color: MyColors.planColor,
                      ),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                 color:Colors.white,
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(4)),
                            child: Checkbox(
                              visualDensity:
                                  const VisualDensity(horizontal: -4, vertical: -4),
                              value: question.selectedIndex==optionIndex,
                             hoverColor: Colors.white,

                              onChanged: (value) {
                                setState(() {

                                  _answers![index] = question.options![optionIndex];

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
                              style: textTheme.titleLarge!
                                  .copyWith(fontWeight: FontWeight.w400,),
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

  Question( {
    required this.text,
    this.options,
    this.selectedIndex,
  });
}
