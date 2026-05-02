import 'package:flutter/material.dart';

/// Configuration for a single screening question.
class ScreeningQuestion {
  final String questionText;
  final String questionHighlight;
  final String subtitle;
  final List<String> options;
  final String researchNote;
  /// Options at or above this index count as risk indicators.
  final List<int> riskOptionIndices;

  const ScreeningQuestion({
    required this.questionText,
    required this.questionHighlight,
    required this.subtitle,
    required this.options,
    required this.researchNote,
    required this.riskOptionIndices,
  });
}

/// Configuration for a condition's intro screen.
class ScreeningIntro {
  final String emoji;
  final String label;
  final String titleBefore;
  final String titleHighlight;
  final String titleAfter;
  final String subtitle;
  final List<ScreeningCheckItem> checkItems;
  final String disclaimer;
  final Color accentColor;
  final Color accentBgLight;
  final Color accentBgDark;

  const ScreeningIntro({
    required this.emoji,
    required this.label,
    required this.titleBefore,
    required this.titleHighlight,
    this.titleAfter = '',
    required this.subtitle,
    required this.checkItems,
    required this.disclaimer,
    required this.accentColor,
    required this.accentBgLight,
    this.accentBgDark = const Color(0xFFFFF5F5),
  });
}

class ScreeningCheckItem {
  final String title;
  final String subtitle;

  const ScreeningCheckItem({required this.title, required this.subtitle});
}

/// Result screen configuration per risk level.
class ScreeningResultConfig {
  final String highTitle;
  final String highBody;
  final String moderateTitle;
  final String moderateBody;
  final String lowTitle;
  final String lowBody;
  final List<String> highNextSteps;
  final List<String> lowNextSteps;
  final String ctaButtonText;

  const ScreeningResultConfig({
    required this.highTitle,
    required this.highBody,
    required this.moderateTitle,
    required this.moderateBody,
    required this.lowTitle,
    required this.lowBody,
    required this.highNextSteps,
    required this.lowNextSteps,
    this.ctaButtonText = 'Book a consultation',
  });
}

/// Full screening configuration for a condition.
class ScreeningConfig {
  final String conditionType;
  final String conditionTag;
  final ScreeningIntro intro;
  final List<ScreeningQuestion> questions;
  final ScreeningResultConfig result;
  /// Risk thresholds: [moderateMin, highMin]
  final int moderateThreshold;
  final int highThreshold;

  const ScreeningConfig({
    required this.conditionType,
    required this.conditionTag,
    required this.intro,
    required this.questions,
    required this.result,
    this.moderateThreshold = 3,
    this.highThreshold = 5,
  });
}
