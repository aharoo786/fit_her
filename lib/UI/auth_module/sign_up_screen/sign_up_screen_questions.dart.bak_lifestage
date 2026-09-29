import 'package:fitness_zone_2/data/controllers/auth_controller/auth_controller.dart';
import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/data/Repos/cycle_repo/cycle_data_repository.dart';
import 'package:fitness_zone_2/UI/auth_module/time_preference_screen.dart';
import 'package:fitness_zone_2/values/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../cycle_data_screen.dart';
import 'age_screen.dart';
import 'health_conditions_screen.dart';
import 'height_screen.dart';
import 'weight_screen.dart';

/// Orchestrates the onboarding question flow:
/// GoalScreen (step 1, handled before this) →
/// Age (2) → Weight (3) → Height (4) → Cycle (5) → HealthConditions (6) → TimePreference (7)
///
/// Each step is a standalone screen using the shared OnboardingScaffold design.
class SignUpScreenQuestions extends StatefulWidget {
  final String? selectedGoal;

  const SignUpScreenQuestions({Key? key, this.selectedGoal}) : super(key: key);

  @override
  State<SignUpScreenQuestions> createState() => _SignUpScreenQuestionsState();
}

class _SignUpScreenQuestionsState extends State<SignUpScreenQuestions> {
  static const int _totalSteps = 7;

  late final String _goal;
  late final int _initialAge;
  late final double _initialWeight;
  late final double _initialHeight;
  late final String _initialConditions;

  @override
  void initState() {
    super.initState();
    final auth = Get.find<AuthController>();

    _goal = widget.selectedGoal ?? auth.mainGoal.value;
    _initialAge = int.tryParse(auth.editAge.text) ?? 25;
    _initialWeight = double.tryParse(auth.editWeight.text) ?? 55;
    _initialHeight = double.tryParse(auth.editHeight.text) ?? 5.4;
    _initialConditions = auth.healthConditions.value;
  }

  @override
  Widget build(BuildContext context) {
    // Step 2: Age (Goal was step 1 via GoalScreen)
    return AgeScreen(
      currentStep: 2,
      totalSteps: _totalSteps,
      initialValue: _initialAge,
      onNext: (age) => _goToWeight(age),
    );
  }

  void _goToWeight(int age) {
    Get.to(() => WeightScreen(
          currentStep: 3,
          totalSteps: _totalSteps,
          initialValue: _initialWeight,
          onNext: (weight) => _goToHeight(age, weight),
        ));
  }

  void _goToHeight(int age, double weight) {
    Get.to(() => HeightScreen(
          currentStep: 4,
          totalSteps: _totalSteps,
          initialValue: _initialHeight,
          onNext: (height) => _goToCycle(age, weight, height),
        ));
  }

  void _goToCycle(int age, double weight, double height) {
    Get.to(() => CycleDataScreen(
          currentStep: 5,
          totalSteps: _totalSteps,
          onContinue: (cycleData) {
            _saveCycleData(cycleData);
            _goToHealthConditions(age, weight, height);
          },
          onSkip: () {
            _saveCycleData({'dataProvided': 0});
            _goToHealthConditions(age, weight, height);
          },
        ));
  }

  void _goToHealthConditions(int age, double weight, double height) {
    Get.to(() => HealthConditionsScreen(
          currentStep: 6,
          totalSteps: _totalSteps,
          initialConditions: _initialConditions,
          onNext: (conditions) => _goToTimePreference(conditions, age, weight, height),
        ));
  }

  void _goToTimePreference(String conditions, int age, double weight, double height) {
    Get.to(() => TimePreferenceScreen(
          currentStep: 7,
          totalSteps: _totalSteps,
          // TimePreference saves timeBlock to SharedPreferences first,
          // then calls this. updateUserDetails() will see hasTimeBlock = true
          // and navigate straight to BottomBarScreen.
          onCompleted: (_) => _finish(conditions, age, weight, height),
        ));
  }

  void _saveCycleData(Map<String, dynamic> cycleData) {
    final token = Get.find<AuthController>()
        .sharedPreferences
        .getString(Constants.accessToken) ?? '';
    Get.find<CycleDataRepository>()
        .saveCycleData(accessToken: token, body: cycleData);
  }

  void _finish(String conditions, int age, double weight, double height) {
    // Calculate BMI: weight(kg) / height(m)^2
    final heightInMeters = height * 0.3048;
    final bmi = weight / (heightInMeters * heightInMeters);
    final bmiStr = bmi.toStringAsFixed(2);

    final auth = Get.find<AuthController>();

    // Send to API — on success, updateUserDetails() navigates to BottomBarScreen.
    // timeBlock is already saved to SharedPreferences so the TimePreferenceScreen
    // check in updateUserDetails() is skipped.
    Get.find<HomeController>().addUserDetails(
      status: false,
      age: age.toString(),
      weight: weight.round().toString(),
      height: height.toString(),
      bmiResult: bmiStr,
      mainGoal: _goal,
      healthConditions: conditions,
    );

    // Update local controllers for profile display
    auth.editBmi.text = bmiStr;
    auth.editAge.text = age.toString();
    auth.editWeight.text = weight.round().toString();
    auth.editHeight.text = height.toString();
    auth.mainGoal.value = _goal;
    auth.healthConditions.value = conditions;
  }
}

/// Kept for backward compatibility — used by questionair_screen.dart
class Question {
  final String text;
  final List<String>? options;

  Question({required this.text, this.options});
}
