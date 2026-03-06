import 'package:fitness_zone_2/data/controllers/auth_controller/auth_controller.dart';
import 'package:fitness_zone_2/values/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitness_zone_2/UI/youtube_tutorial_player.dart';
import '../../helper/analytics_helper.dart';

class YouTubeTutorialService extends GetxService {
  static const String _freezeTutorialKey = 'show_freeze_tutorial';
  static const String _subscribeTutorialKey = 'show_subscribe_tutorial';
  static const String _dietTutorialKey = 'show_diet_tutorial';

  late SharedPreferences _prefs;

  // YouTube URLs for tutorials
  static const String freezeTutorialUrl = 'https://youtu.be/-5OaR6ujny0?si=ctN-ukv_gLVEBX4w';
  static const String subscribeTutorialUrl = 'https://youtu.be/PX74nzUl0uc?si=oemRnCTn12EQ-P_I';
  static const String dietTutorialUrl = 'https://youtu.be/yEn_ej-5zNo?si=WdXF46h79gZg9SVv';

  @override
  void onInit() async {
    super.onInit();
    _prefs = Get.find<AuthController>().sharedPreferences;
  }

  /// Check if tutorial should be shown
  bool shouldShowTutorial(String tutorialKey) {
    return _prefs.getBool(tutorialKey) ?? true;
  }

  /// Mark tutorial as "don't show again"
  Future<void> setDontShowAgain(String tutorialKey) async {
    await _prefs.setBool(tutorialKey, false);
  }

  /// Reset all tutorial preferences (for testing or admin purposes)
  Future<void> resetAllTutorials() async {
    await _prefs.setBool(_freezeTutorialKey, true);
    await _prefs.setBool(_subscribeTutorialKey, true);
    await _prefs.setBool(_dietTutorialKey, true);
  }

  /// Get current tutorial status for debugging
  Map<String, bool> getTutorialStatus() {
    return {
      'freeze': _prefs.getBool(_freezeTutorialKey) ?? true,
      'subscribe': _prefs.getBool(_subscribeTutorialKey) ?? true,
      'diet': _prefs.getBool(_dietTutorialKey) ?? true,
    };
  }

  /// Show freeze tutorial
  Future<bool> showFreezeTutorial(BuildContext context) async {
    if (!shouldShowTutorial(_freezeTutorialKey)) return false;

    // Track tutorial started
    await AnalyticsHelper.trackTutorialEvent('freeze_tutorial', 'started');

    bool shouldWatchTutorial = await _showTutorialDialog(
      context,
      'Freeze Account Tutorial',
      'Learn how to freeze your account when you need a break from your fitness journey.',
      freezeTutorialUrl,
      _freezeTutorialKey,
    );

    if (shouldWatchTutorial) {
      // Track tutorial completed
      await AnalyticsHelper.trackTutorialEvent('freeze_tutorial', 'completed');
      await _launchTutorial(freezeTutorialUrl, 'Freeze Account Tutorial');
    } else {
      // Track tutorial skipped
      await AnalyticsHelper.trackTutorialEvent('freeze_tutorial', 'skipped');
    }

    return shouldWatchTutorial;
  }

  /// Show subscribe tutorial
  Future<bool> showSubscribeTutorial(BuildContext context) async {
    if (!shouldShowTutorial(_subscribeTutorialKey)) return false;

    // Track tutorial started
    await AnalyticsHelper.trackTutorialEvent('subscribe_tutorial', 'started');

    bool shouldWatchTutorial = await _showTutorialDialog(
      context,
      'Subscribe to Plans Tutorial',
      'Learn how to subscribe to our fitness plans and unlock premium features.',
      subscribeTutorialUrl,
      _subscribeTutorialKey,
    );

    if (shouldWatchTutorial) {
      // Track tutorial completed
      await AnalyticsHelper.trackTutorialEvent('subscribe_tutorial', 'completed');
      await _launchTutorial(subscribeTutorialUrl, 'Subscribe to Plans Tutorial');
    } else {
      // Track tutorial skipped
      await AnalyticsHelper.trackTutorialEvent('subscribe_tutorial', 'skipped');
    }

    return shouldWatchTutorial;
  }

  /// Show diet tutorial
  Future<bool> showDietTutorial(BuildContext context) async {
    if (!shouldShowTutorial(_dietTutorialKey)) return false;

    // Track tutorial started
    await AnalyticsHelper.trackTutorialEvent('diet_tutorial', 'started');

    bool shouldWatchTutorial = await _showTutorialDialog(
      context,
      'Diet Plans Tutorial',
      'Learn how to use our diet planning features and track your nutrition.',
      dietTutorialUrl,
      _dietTutorialKey,
    );

    if (shouldWatchTutorial) {
      // Track tutorial completed
      await AnalyticsHelper.trackTutorialEvent('diet_tutorial', 'completed');
      await _launchTutorial(dietTutorialUrl, 'Diet Plans Tutorial');
    } else {
      // Track tutorial skipped
      await AnalyticsHelper.trackTutorialEvent('diet_tutorial', 'skipped');
    }

    return shouldWatchTutorial;
  }

  /// Show tutorial dialog with option to watch or skip
  Future<bool> _showTutorialDialog(
    BuildContext context,
    String title,
    String description,
    String videoUrl,
    String tutorialKey,
  ) async {
    bool shouldWatchTutorial = false;
    bool dontShowAgain = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(Icons.play_circle_filled, color: MyColors.buttonColor, size: 28),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Checkbox(
                        value: dontShowAgain,
                        onChanged: (value) {
                          setState(() {
                            dontShowAgain = value ?? false;
                          });
                        },
                        activeColor: MyColors.buttonColor,
                      ),
                      Expanded(
                        child: Text(
                          "Don't show this tutorial again",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // If "Don't show again" is checked, save the preference
                    if (dontShowAgain) {
                      setDontShowAgain(tutorialKey);
                    }
                    Navigator.of(context).pop(false);
                  },
                  child: Text(
                    'Skip',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // If "Don't show again" is checked, save the preference
                    if (dontShowAgain) {
                      setDontShowAgain(tutorialKey);
                    }
                    Navigator.of(context).pop(true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.buttonColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text('Watch Tutorial'),
                ),
              ],
            );
          },
        );
      },
    ).then((value) {
      shouldWatchTutorial = value ?? false;
    });

    return shouldWatchTutorial;
  }

  /// Launch tutorial in YouTube player
  Future<void> _launchTutorial(String videoUrl, String title) async {
    await Get.to(() => YouTubeTutorialPlayer(
          videoUrl: videoUrl,
          title: title,
        ));
  }

  /// Show a simple confirmation dialog for "don't show again"
  Future<bool> showDontShowAgainDialog(BuildContext context, String tutorialKey) async {
    bool dontShowAgain = false;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tutorial Complete'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Did you find this tutorial helpful?'),
              SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: dontShowAgain,
                    onChanged: (value) {
                      dontShowAgain = value ?? false;
                    },
                  ),
                  Expanded(
                    child: Text('Don\'t show this tutorial again'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (dontShowAgain) {
                  setDontShowAgain(tutorialKey);
                }
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );

    return dontShowAgain;
  }
}
