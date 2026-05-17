class NudgeTemplate {
  final int dayStart;
  final int dayEnd;
  final String title;
  final String body;

  const NudgeTemplate({
    required this.dayStart,
    required this.dayEnd,
    required this.title,
    required this.body,
  });
}

class GenericNudge {
  final String id;
  final String title;
  final String body;

  const GenericNudge({
    required this.id,
    required this.title,
    required this.body,
  });
}

class StaticInsights {
  StaticInsights._();

  // --- Phase-based nudge templates ---
  static const Map<String, List<NudgeTemplate>> nudges = {
    'menstrual': [
      NudgeTemplate(
        dayStart: 1,
        dayEnd: 1,
        title: 'Day 1 - Take it easy',
        body: 'Your period just started. Low energy is completely normal. A gentle stretch or rest day is perfect. Listen to your body.',
      ),
      NudgeTemplate(
        dayStart: 2,
        dayEnd: 2,
        title: 'Day 2 - Rest is productive',
        body: 'Still early in your cycle. Energy stays low. Gentle Yoga or Stretch & Restore are ideal if you move at all.',
      ),
      NudgeTemplate(
        dayStart: 3,
        dayEnd: 3,
        title: 'Day 3 - Slow and steady',
        body: 'Energy starting to lift slightly. A light session could feel good, but no pressure. Your body is still recovering.',
      ),
      NudgeTemplate(
        dayStart: 4,
        dayEnd: 4,
        title: 'Day 4 - The shift begins',
        body: 'You may notice energy creeping back. A low-intensity session like Pilates could feel surprisingly good today.',
      ),
      NudgeTemplate(
        dayStart: 5,
        dayEnd: 5,
        title: 'Day 5 - Almost through',
        body: 'Your period is wrapping up. Energy is climbing. Tomorrow you will feel the difference. Today, keep it gentle.',
      ),
    ],
    'follicular': [
      NudgeTemplate(
        dayStart: 6,
        dayEnd: 6,
        title: 'Day 6 - Energy is back',
        body: 'Estrogen is rising and you should feel it. Great day to get back into a rhythm. Strength or Cardio will feel right.',
      ),
      NudgeTemplate(
        dayStart: 7,
        dayEnd: 8,
        title: 'Rising energy',
        body: 'Your body is building momentum. Best window for challenging workouts. Push yourself a little - you can handle it.',
      ),
      NudgeTemplate(
        dayStart: 9,
        dayEnd: 10,
        title: 'Momentum week',
        body: 'Energy climbing steadily. You are in your power phase. High-intensity sessions will feel amazing this week.',
      ),
      NudgeTemplate(
        dayStart: 11,
        dayEnd: 12,
        title: 'Peak building',
        body: 'Almost at your energy peak. Motivation should be high. Great time to try a new class or increase intensity.',
      ),
      NudgeTemplate(
        dayStart: 13,
        dayEnd: 13,
        title: 'Tomorrow is peak',
        body: 'Energy nearly at its highest. Fuel up, hydrate, get ready - tomorrow and the next few days are your power window.',
      ),
    ],
    'ovulatory': [
      NudgeTemplate(
        dayStart: 14,
        dayEnd: 14,
        title: 'Day 14 - Peak energy',
        body: 'This is your peak. Energy, motivation, confidence all at highest. Go all out - Power HIIT, Cardio Blast, whatever excites you.',
      ),
      NudgeTemplate(
        dayStart: 15,
        dayEnd: 15,
        title: 'Still at the top',
        body: 'Energy remains high. Social energy also peaking - a live group session will feel incredible. Feed off the community energy.',
      ),
      NudgeTemplate(
        dayStart: 16,
        dayEnd: 16,
        title: 'Last day of peak',
        body: 'Power window closing. Make the most of today. Tomorrow the shift begins - but today, you are unstoppable.',
      ),
    ],
    'luteal': [
      NudgeTemplate(
        dayStart: 17,
        dayEnd: 18,
        title: 'Gentle shift',
        body: 'Energy starts to ease. You may still feel strong, but do not push too hard. Power Yoga or Pilates are perfect.',
      ),
      NudgeTemplate(
        dayStart: 19,
        dayEnd: 21,
        title: 'Mid-luteal',
        body: 'Progesterone rising. You might feel more tired. That is normal. A moderate session will feel great without draining you.',
      ),
      NudgeTemplate(
        dayStart: 22,
        dayEnd: 23,
        title: 'Cravings may appear',
        body: 'Craving sugar or carbs? That is your hormones - not weakness. A gentle workout can actually help reduce cravings.',
      ),
      NudgeTemplate(
        dayStart: 24,
        dayEnd: 25,
        title: 'Winding down',
        body: 'Energy low. Mood might dip. Hardest part of the cycle. Be kind to yourself. Gentle Yoga or Stretch is enough.',
      ),
      NudgeTemplate(
        dayStart: 26,
        dayEnd: 28,
        title: 'Almost there',
        body: 'Period approaching. Energy and mood at lowest. Rest is a valid choice. If you move, keep it gentle. Better days coming.',
      ),
    ],
  };

  // --- Generic nudges for users with no cycle data ---
  static const List<GenericNudge> genericNudges = [
    GenericNudge(
      id: 'A',
      title: 'Good morning!',
      body: 'Ready to move today? Check out today\'s sessions and find one that fits your energy. Add cycle data for personalized insights.',
    ),
    GenericNudge(
      id: 'B',
      title: 'Your body, your pace',
      body: 'Some days are high energy, some are not. Listen to your body and pick the right session. Cycle tracking makes this more accurate.',
    ),
    GenericNudge(
      id: 'C',
      title: 'Stay consistent',
      body: 'The best workout is the one you show up for. Browse today\'s schedule and find your moment.',
    ),
    GenericNudge(
      id: 'D',
      title: 'You + 30 women',
      body: 'Today\'s sessions are filling up. Join the community and get moving. Your body will thank you.',
    ),
  ];

  /// Returns a generic nudge based on day of year (rotates A-D).
  static GenericNudge getGenericNudge() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    return genericNudges[dayOfYear % 4];
  }
}
