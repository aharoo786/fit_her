import 'package:flutter/material.dart';
import 'screening_data.dart';

/// Endometriosis screening — SD-35 to SD-41 · Symptom Diary Adapted
final endometriosisConfig = ScreeningConfig(
  conditionType: 'Endometriosis',
  conditionTag: 'Endometriosis · Symptom Screening',
  intro: ScreeningIntro(
    emoji: '🩸',
    label: 'Endometriosis Screening',
    titleBefore: 'Check your\n',
    titleHighlight: 'endometriosis',
    titleAfter: ' symptoms',
    subtitle: "5 questions — endometriosis takes an average of 7 years to diagnose. Let's catch it earlier.",
    accentColor: const Color(0xFF6DC55A),
    accentBgLight: const Color(0xFFEAF7E4),
    accentBgDark: const Color(0xFFEAF7E4),
    checkItems: const [
      ScreeningCheckItem(title: 'Period pain severity & pelvic pain', subtitle: 'Pain that interferes with daily activities'),
      ScreeningCheckItem(title: 'Pain during sex or when using the toilet', subtitle: 'Pain beyond normal menstrual cramps'),
      ScreeningCheckItem(title: 'Fertility concerns', subtitle: 'Difficulty conceiving or history of miscarriage'),
    ],
    disclaimer: 'Endometriosis can only be confirmed through laparoscopy. This screener identifies symptom patterns that warrant medical investigation. Please consult a gynaecologist if results suggest endometriosis.',
  ),
  questions: const [
    ScreeningQuestion(
      questionText: 'Do you experience ',
      questionHighlight: 'severe pain during your period',
      subtitle: 'that limits your daily activities?',
      options: [
        'No — manageable discomfort',
        'Mild — takes painkillers but functional',
        'Moderate — misses work or school occasionally',
        'Severe — completely unable to function',
      ],
      researchNote: 'Dysmenorrhoea (painful periods) that is disproportionate to normal menstrual cramps is the hallmark symptom of endometriosis. Pain severe enough to disrupt daily life strongly correlates with the condition.',
      riskOptionIndices: [2, 3],
    ),
    ScreeningQuestion(
      questionText: 'Do you experience ',
      questionHighlight: 'pelvic pain',
      subtitle: 'outside of your period?',
      options: [
        'No — pain only during period',
        'Occasional pain between periods',
        'Regular chronic pelvic pain',
        'Constant pain that never fully goes away',
      ],
      researchNote: 'Chronic pelvic pain independent of the menstrual cycle suggests endometrial tissue implants are active throughout the month, not just during menstruation — a key diagnostic indicator.',
      riskOptionIndices: [2, 3],
    ),
    ScreeningQuestion(
      questionText: 'Do you experience ',
      questionHighlight: 'pain during or after sex?',
      subtitle: '',
      options: [
        'No pain during sex',
        'Mild discomfort occasionally',
        'Moderate pain — affects intimacy',
        'Severe pain — avoids sex because of pain',
      ],
      researchNote: 'Dyspareunia (pain during sex) is present in up to 50% of women with endometriosis. It occurs because endometrial tissue in the pelvic area creates scar tissue and inflammation that stretches during intercourse.',
      riskOptionIndices: [2, 3],
    ),
    ScreeningQuestion(
      questionText: 'Do you have ',
      questionHighlight: 'pain when using the toilet',
      subtitle: 'during your period?',
      options: [
        'No pain when using toilet',
        'Mild discomfort occasionally',
        'Moderate pain — frequent during period',
        'Severe pain every time during period',
      ],
      researchNote: 'Painful bowel or bladder movements during menstruation can indicate endometriosis affecting the bowel or bladder. This symptom is frequently dismissed but is a significant diagnostic clue.',
      riskOptionIndices: [2, 3],
    ),
    ScreeningQuestion(
      questionText: 'Have you had ',
      questionHighlight: 'difficulty conceiving',
      subtitle: 'or been told fertility may be affected?',
      options: [
        'Not trying to conceive currently',
        'Trying but no concerns flagged yet',
        'Experiencing fertility challenges',
        'Diagnosed with fertility issues or endometriosis',
      ],
      researchNote: 'Endometriosis is found in 30-50% of women with infertility. It affects conception through inflammation, adhesions, and hormonal disruption. Early identification can help preserve fertility options.',
      riskOptionIndices: [2, 3],
    ),
  ],
  result: const ScreeningResultConfig(
    highTitle: 'Your symptoms are consistent with endometriosis',
    highBody: 'Your answers indicate several symptoms commonly associated with endometriosis. Because average diagnosis takes 7-10 years, we strongly encourage you to speak to a gynaecologist now.',
    moderateTitle: 'Some endometriosis indicators present',
    moderateBody: 'You reported some patterns that could be related to endometriosis. Tracking these symptoms over time and discussing with a specialist is recommended.',
    lowTitle: 'Fewer endometriosis indicators found',
    lowBody: "Your answers show fewer typical endometriosis symptom patterns. If your period pain ever becomes severe or disruptive, always speak to a doctor — don't accept it as normal.",
    highNextSteps: [
      'Add endometriosis-aware program to your profile',
      'Anti-inflammatory nutrition plan',
      'Low-impact exercise during flare periods',
      'Track pain patterns and cycle symptoms',
    ],
    lowNextSteps: [
      "Never accept severe period pain as 'normal'",
      'Track your pain patterns in Fit Her',
      'Retake if symptoms worsen or change',
    ],
    ctaButtonText: 'Book a gynaecologist consultation →',
  ),
  moderateThreshold: 3,
  highThreshold: 5,
);
