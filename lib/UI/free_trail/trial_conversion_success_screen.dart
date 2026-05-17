import 'package:fitness_zone_2/UI/plans_module/all_plans.dart';
import 'package:fitness_zone_2/helper/analytics_helper.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:fitness_zone_2/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TrialConversionSuccessScreen extends StatefulWidget {
  const TrialConversionSuccessScreen({super.key});

  @override
  State<TrialConversionSuccessScreen> createState() =>
      _TrialConversionSuccessScreenState();
}

class _TrialConversionSuccessScreenState
    extends State<TrialConversionSuccessScreen> {
  @override
  void initState() {
    super.initState();
    AnalyticsHelper.trackScreenView('trial_conversion_success_viewed');
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(() {
        Get.back();
      }, text: "Unlocked"),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              size: 96,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            Text(
              "You unlocked full access!",
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              "Your 3-day trial is complete and your account is now ready for subscription plans.",
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: "View Plans",
              onPressed: () async {
                await AnalyticsHelper.trackButtonClick(
                  'trial_view_plans_clicked',
                  screenName: 'trial_conversion_success',
                );
                Get.off(() => OurPlansScreen());
              },
            ),
          ],
        ),
      ),
    );
  }
}
