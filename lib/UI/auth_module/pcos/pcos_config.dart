import 'package:flutter/material.dart';
import 'screening_data.dart';

/// PCOS screening configuration — SD01 to SD07 design.
final pcosConfig = ScreeningConfig(
  conditionType: 'PCOS',
  conditionTag: 'PCOS Screening · Rotterdam Criteria',
  intro: ScreeningIntro(
    emoji: '🔬',
    label: 'PCOS Screening',
    titleBefore: 'Check your ',
    titleHighlight: 'PCOS',
    titleAfter: '\nsymptoms',
    subtitle:
        "Answer 5 simple questions. We'll tell you if your symptoms are consistent with Polycystic Ovary Syndrome.",
    accentColor: const Color(0xFFE05050),
    accentBgLight: const Color(0xFFFFE8E8),
    accentBgDark: const Color(0xFFFFF5F5),
    checkItems: const [
      ScreeningCheckItem(
        title: 'Period regularity',
        subtitle: 'Irregular, infrequent or absent periods',
      ),
      ScreeningCheckItem(
        title: 'Hair growth patterns',
        subtitle: 'Unusual hair on face, chest or stomach',
      ),
      ScreeningCheckItem(
        title: 'Weight management',
        subtitle: 'Difficulty losing weight despite effort',
      ),
      ScreeningCheckItem(
        title: 'Skin and acne',
        subtitle: 'Persistent acne or oily skin',
      ),
      ScreeningCheckItem(
        title: 'Hormone levels',
        subtitle: 'Known elevated androgens or ovarian cysts',
      ),
    ],
    disclaimer:
        'This screening tool is for informational purposes only and is not a medical diagnosis. Fit Her uses validated symptom questionnaires to help you understand your health. If results suggest PCOS, please consult a qualified gynecologist.',
  ),
  questions: const [
    ScreeningQuestion(
      questionText: 'How regular are\nyour ',
      questionHighlight: 'periods?',
      subtitle:
          'This helps us understand your ovulation patterns — a key indicator of hormonal balance',
      options: [
        'Regular — every 21 to 35 days',
        'Irregular — varies a lot each month',
        'Infrequent — fewer than 8 per year',
        'Absent — no period for 3+ months',
      ],
      researchNote:
          'Irregular or infrequent periods (oligomenorrhoea) are one of the three core Rotterdam Criteria for PCOS assessment, used by gynaecologists worldwide.',
      riskOptionIndices: [1, 2, 3],
    ),
    ScreeningQuestion(
      questionText: 'Do you have unusual\n',
      questionHighlight: 'hair growth',
      subtitle:
          'This refers to dark or coarse hair appearing on the face, chin, chest, stomach or upper thighs',
      options: [
        'No — no unusual hair growth',
        'Mild — a little on face or body',
        'Moderate — noticeable in multiple areas',
        'Significant — affects daily confidence',
      ],
      researchNote:
          'Hirsutism — excess hair growth in a male pattern — is a clinical sign of elevated androgens, one of the three core Rotterdam Criteria used to screen for PCOS.',
      riskOptionIndices: [1, 2, 3],
    ),
    ScreeningQuestion(
      questionText: 'Do you struggle with\n',
      questionHighlight: 'weight loss?',
      subtitle: 'Despite eating well and exercising regularly',
      options: [
        'Yes — very difficult to lose weight',
        'Somewhat — slower than expected',
        'No — weight responds normally',
        "I haven't tried to lose weight",
      ],
      researchNote:
          'Insulin resistance — common in PCOS — causes the body to store fat more easily and makes weight loss significantly harder despite diet and exercise.',
      riskOptionIndices: [0, 1],
    ),
    ScreeningQuestion(
      questionText: 'How would you describe\nyour ',
      questionHighlight: 'skin and acne?',
      subtitle: 'Especially around jawline, chin and cheeks',
      options: [
        'Clear — rarely get spots',
        'Mild — occasional breakouts',
        'Moderate — frequent, hard to control',
        'Severe — persistent, deep or cystic',
      ],
      researchNote:
          'Elevated androgens in PCOS trigger excess sebum production, leading to persistent adult acne — particularly along the lower face and jawline.',
      riskOptionIndices: [2, 3],
    ),
    ScreeningQuestion(
      questionText: 'Have you had any\n',
      questionHighlight: 'hormone tests',
      subtitle:
          'Blood tests or ultrasound related to your cycle or hormones',
      options: [
        'Yes — told I have elevated androgens',
        'Yes — cysts seen on ovary ultrasound',
        'Yes — tests done but all normal',
        'No — never had hormone tests',
      ],
      researchNote:
          'Polycystic ovarian morphology on ultrasound is the third Rotterdam Criterion. However PCOS can be present even without visible cysts if other criteria are met.',
      riskOptionIndices: [0, 1],
    ),
  ],
  result: const ScreeningResultConfig(
    highTitle: 'Your symptoms are consistent with PCOS',
    highBody:
        'You reported patterns that align with Rotterdam Criteria indicators. This does not confirm a diagnosis but warrants further investigation by a doctor.',
    moderateTitle: 'Some symptoms align with PCOS',
    moderateBody:
        'You reported some patterns that could indicate PCOS. Consider monitoring your symptoms and discussing with a healthcare provider.',
    lowTitle: 'Your symptoms are less consistent with PCOS',
    lowBody:
        "Your answers show fewer of the typical PCOS indicators. This doesn't rule it out entirely — PCOS presents differently in every woman — but your symptoms are less aligned with the Rotterdam Criteria patterns.",
    highNextSteps: [
      'Add PCOS program to your profile',
      'Build you a PCOS-friendly diet plan',
      'Track your symptoms over time',
      'Recommend low-androgen workouts',
    ],
    lowNextSteps: [
      'Continue tracking your cycle in Fit Her',
      'Retake screening if symptoms change',
      'Still concerned? Book a consultation',
    ],
    ctaButtonText: 'Book a gynaecologist consultation',
  ),
  moderateThreshold: 3,
  highThreshold: 5,
);
