import 'package:fitness_zone_2/data/controllers/workout_controller/work_out_controller.dart';
import 'package:fitness_zone_2/helper/validators.dart';
import 'package:fitness_zone_2/helper/analytics_helper.dart';
import 'package:fitness_zone_2/values/my_colors.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:fitness_zone_2/widgets/custom_button.dart';
import 'package:fitness_zone_2/widgets/custom_textfield.dart';
import 'package:fitness_zone_2/widgets/toasts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../data/controllers/home_controller/home_controller.dart';
import '../../values/my_imgs.dart';
import '../plans_module/all_plans.dart';

class FreeTrialPersonalizationScreen extends StatefulWidget {
  const FreeTrialPersonalizationScreen({Key? key}) : super(key: key);

  @override
  State<FreeTrialPersonalizationScreen> createState() =>
      _FreeTrialPersonalizationScreenState();
}

class _FreeTrialPersonalizationScreenState
    extends State<FreeTrialPersonalizationScreen> {
  final PageController _pageController = PageController();
  final TextEditingController otherController = TextEditingController();

  int _currentPage = 0;
  List<String> answersList = [];
  bool showOther = false;

  final List<Map<String, dynamic>> pagesData = [
    {
      'question': "1. What's your main goal?",
      'subtitle': "(Choose one or more)",
      'options': [
        "Lose weight",
        "Tone my body",
        "Build strength",
        "Manage PCOS",
        "Stay fit overall",
        "Reduce bloating",
        "Improve mental health",
        "Other",
      ]
    },
    {
      'question': "2. Are you currently facing any specific issues?",
      'subtitle': "(Choose one or more)",
      'options': [
        "PCOS",
        "Arthritis",
        "Hypothyroidism",
        "Hormonal imbalance",
        "Low energy",
        "None",
        "Other",
      ]
    },
    {
      'question': "3. What are your preferences?",
      'subtitle': "Let us know what suits your lifestyle",
      'options': [
        "With Equipment",
        "Without Equipment",
        "Vegetarian",
        "Non-Vegetarian",
        "None",
        "Other",
      ]
    },
  ];

  late List<Map<String, dynamic>?> answers;

  @override
  void initState() {
    super.initState();
    // Preallocate space for each question
    answers = List.filled(pagesData.length, null);

    // Track free trial personalization screen view
    AnalyticsHelper.trackScreenView('free_trial_personalization_screen');
    AnalyticsHelper.trackFreeTrialEvent('started', step: 'personalization');
  }

  Future<bool> saveCurrentAnswer() async {
    if (answersList.isEmpty) {
      CustomToast.failToast(msg: "Please provide information");
      return false;
    }

    // Track question answered
    await AnalyticsHelper.trackQuestionnaireEvent(
      'question_answered',
      questionnaireType: 'personalization',
      questionNumber: (_currentPage + 1).toString(),
      answer: answersList.join(','),
    );

    answers[_currentPage] = {
      "answersList": [...answersList],
      "other": showOther,
      "otherText": otherController.text
    };
    return true;
  }

  void loadPreviousAnswer(int index) {
    final prevAnswer = answers[index];
    answersList = prevAnswer?["answersList"]?.cast<String>() ?? [];
    showOther = prevAnswer?["other"] ?? false;
    otherController.text = prevAnswer?["otherText"] ?? "";
  }

  void goToPreviousPage() {
    if (_currentPage > 0) {
      // saveCurrentAnswer();
      _currentPage--;
      loadPreviousAnswer(_currentPage);
      _pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() {});
    } else {
      Get.back();
    }
  }

  Future<void> goToNextPage() async {
    bool value = await saveCurrentAnswer();
    if (!value) {
      return;
    }
    if (_currentPage < pagesData.length - 1) {
      _currentPage++;
      loadPreviousAnswer(_currentPage);
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() {});
    } else {
      // Track questionnaire completed
      await AnalyticsHelper.trackQuestionnaireEvent(
        'completed',
        questionnaireType: 'personalization',
      );

      bool already = await Get.find<HomeController>().addFreeTrial();
      print('HelpingWidgets.getOurPlans $already');
      if (already) {
        // Track free trial already used
        await AnalyticsHelper.trackFreeTrialEvent('already_used');

        HelpingWidgets.showCustomDialog(context, () {
          Navigator.of(context).pop();
          Get.find<HomeController>().getPlansUser();
          Get.to(() => OurPlansScreen());
        },
            "Trial already availed!",
            "You've already used your free trial! To continue enjoying our services, please subscribe to one of our plans.",
            MyImgs.warning,
            buttonText: "See Plans");
      } else {
        // Track free trial personalization completed
        await AnalyticsHelper.trackFreeTrialEvent('questionnaire_completed',
            step: 'personalization');
        // Track free trial completed (key event)
        await AnalyticsHelper.trackFreeTrial('completed', step: 'personalization');
        Get.find<WorkOutController>().updateFreeTrialData(
            answers.whereType<Map<String, dynamic>>().toList());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(goToPreviousPage),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                physics: const NeverScrollableScrollPhysics(),
                controller: _pageController,
                itemCount: pagesData.length,
                itemBuilder: (context, index) {
                  final page = pagesData[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Let's Personalize Your Free Trial!",
                            style: textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            page['question'],
                            style: textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            page['subtitle'],
                            style: textTheme.bodySmall
                                ?.copyWith(color: Colors.grey),
                          ),
                          const SizedBox(height: 24),
                          Wrap(
                            spacing: 10,
                            runSpacing: 5,
                            children: List.generate(
                              page['options'].length,
                              (i) => ChoiceChip(
                                label: Text(page['options'][i]),
                                selected:
                                    answersList.contains(page['options'][i]),
                                onSelected: (selected) {
                                  final selectedOption = page['options'][i];
                                  if (selected) {
                                    if (selectedOption == "Other") {
                                      answersList = [selectedOption];
                                      showOther = true;
                                    } else {
                                      showOther = false;
                                      answersList
                                          .removeWhere((e) => e == "Other");
                                      answersList.add(selectedOption);
                                    }
                                  } else {
                                    answersList.remove(selectedOption);
                                  }
                                  setState(() {});
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  side: const BorderSide(
                                      color: MyColors.buttonColor),
                                ),
                                checkmarkColor: Colors.white,
                                backgroundColor: Colors.transparent,
                                labelStyle: TextStyle(
                                    color:
                                        answersList.contains(page['options'][i])
                                            ? Colors.white
                                            : MyColors.buttonColor),
                                selectedColor: MyColors.buttonColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (showOther)
                            CustomTextField(
                              height: 100,
                              text: "Specify if any Other",
                              length: 200,
                              maxlines: null,
                              controller: otherController,
                              keyboardType: TextInputType.text,
                              inputFormatters: FilteringTextInputFormatter
                                  .singleLineFormatter,
                            )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            CustomButton(
              text:
                  _currentPage == pagesData.length - 1 ? "Submit" : "Continue",
              onPressed: goToNextPage,
            ),
            const SizedBox(height: 16),
            buildIndicator(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        pagesData.length,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? Colors.green
                : Colors.green.withOpacity(0.4),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
