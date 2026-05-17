import 'package:flutter/material.dart';
import 'screening_data.dart';

/// Thyroid screening — SD-08 to SD-14 · Billewicz Scale
final thyroidConfig = ScreeningConfig(
  conditionType: 'Thyroid',
  conditionTag: 'Thyroid · Billewicz Scale',
  intro: ScreeningIntro(
    emoji: '🦋',
    label: 'Thyroid Screening',
    titleBefore: 'Check your\n',
    titleHighlight: 'thyroid',
    titleAfter: ' symptoms',
    subtitle: '5 questions — based on the Billewicz Scale, the clinical standard for thyroid symptom assessment',
    accentColor: const Color(0xFF6DC55A),
    accentBgLight: const Color(0xFFEAF7E4),
    accentBgDark: const Color(0xFFEAF7E4),
    checkItems: const [
      ScreeningCheckItem(title: 'Energy & fatigue levels', subtitle: 'Persistent tiredness or feeling sluggish'),
      ScreeningCheckItem(title: 'Cold sensitivity & weight changes', subtitle: 'Unexplained weight gain or feeling cold'),
      ScreeningCheckItem(title: 'Hair, skin & digestion', subtitle: 'Hair thinning, dry skin, constipation'),
    ],
    disclaimer: 'Not a diagnosis — if results suggest a thyroid issue, confirm with a TSH blood test from your doctor.',
  ),
  questions: const [
    ScreeningQuestion(
      questionText: 'How sensitive are you to\n',
      questionHighlight: 'cold?',
      subtitle: 'Compared to people around you in the same environment',
      options: [
        'I feel cold much more than others',
        'Slightly more cold-sensitive than most',
        'Same cold sensitivity as everyone else',
        'I actually feel warmer than most people',
      ],
      researchNote: 'Cold intolerance is a key Billewicz Scale indicator for hypothyroidism. An underactive thyroid reduces metabolic heat production, making the body less able to regulate warmth.',
      riskOptionIndices: [0, 1],
    ),
    ScreeningQuestion(
      questionText: 'How would you describe your\n',
      questionHighlight: 'energy levels?',
      subtitle: 'On most days, regardless of how much you sleep',
      options: [
        'Always tired — even after a full night\'s sleep',
        'Often tired by mid-morning or afternoon',
        'Normal energy levels most of the time',
        'High energy — rarely feel tired',
      ],
      researchNote: 'Persistent fatigue despite adequate sleep is one of the most common symptoms of hypothyroidism. Low thyroid hormone slows down nearly every function in the body, reducing energy production at the cellular level.',
      riskOptionIndices: [0, 1],
    ),
    ScreeningQuestion(
      questionText: 'Has your weight changed\n',
      questionHighlight: 'unexpectedly?',
      subtitle: 'Without a significant change in your diet or activity',
      options: [
        'Yes — gained weight despite eating normally',
        'Slight weight gain I can\'t explain',
        'My weight has been stable',
        'I have actually lost weight recently',
      ],
      researchNote: 'Unexplained weight gain is a hallmark of hypothyroidism. A slowed metabolism caused by insufficient thyroid hormone leads to weight accumulation even with a normal or reduced caloric intake.',
      riskOptionIndices: [0, 1],
    ),
    ScreeningQuestion(
      questionText: 'Have you noticed changes in your\n',
      questionHighlight: 'hair or nails?',
      subtitle: 'Over the past few months',
      options: [
        'Yes — significant hair loss or thinning',
        'Mild increase in hair shedding',
        'Hair and nails seem normal',
        'My hair has actually become thicker',
      ],
      researchNote: 'Hair loss, thinning hair and brittle nails are classic signs of hypothyroidism. Thyroid hormones are essential for healthy hair follicle cycling — reduced levels cause follicles to rest longer, leading to shedding.',
      riskOptionIndices: [0, 1],
    ),
    ScreeningQuestion(
      questionText: 'How would you describe your\n',
      questionHighlight: 'skin and digestion?',
      subtitle: 'Your general skin texture and gut function',
      options: [
        'Dry skin and frequent constipation',
        'Either dry skin or occasional constipation',
        'Skin and digestion feel normal',
        'Skin is oily or digestion is fast',
      ],
      researchNote: 'Dry skin and constipation are both Billewicz Scale indicators for hypothyroidism. Slowed metabolism reduces sweat gland activity and gut motility, causing both symptoms simultaneously.',
      riskOptionIndices: [0, 1],
    ),
  ],
  result: const ScreeningResultConfig(
    highTitle: 'Your symptoms are consistent with thyroid disorder',
    highBody: 'Your answers match several key clinical indicators. This does not confirm a diagnosis but warrants further investigation by a doctor.',
    moderateTitle: 'Some thyroid indicators present',
    moderateBody: 'You reported some patterns that could indicate thyroid issues. Monitoring these symptoms and getting a blood test would be worthwhile.',
    lowTitle: 'Fewer thyroid disorder indicators found',
    lowBody: "Your answers show fewer typical indicators. This doesn't rule it out entirely — please speak to a doctor if you have concerns.",
    highNextSteps: [
      'Add thyroid-friendly program to your profile',
      'Build you a thyroid-supporting diet plan',
      'Track your energy and symptoms over time',
      'Recommend low-intensity workouts appropriate for thyroid conditions',
    ],
    lowNextSteps: [
      'Continue tracking your energy and cycle',
      'Retake the screening if symptoms develop',
      'Speak to a doctor if you have ongoing concerns',
    ],
    ctaButtonText: 'Book a consultation →',
  ),
  moderateThreshold: 3,
  highThreshold: 6,
);
