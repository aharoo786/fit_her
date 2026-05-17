import 'package:flutter/material.dart';

class FeelSelectorCard extends StatelessWidget {
  const FeelSelectorCard({Key? key}) : super(key: key);

  static const int _selectedIndex = 0;
  static const List<_Mood> _moods = [
    _Mood('😊', 'Great'),
    _Mood('😴', 'Tired'),
    _Mood('😣', 'Sore'),
    _Mood('⚡', 'Energy'),
    _Mood('😤', 'Stress'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD8EDD4), width: 1),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF163220).withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'HOW I FEEL TODAY',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Color(0xFF9AB09A),
              letterSpacing: 0.63,
            ),
          ),
          const SizedBox(height: 7),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF7E4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                for (int i = 0; i < _moods.length; i++) ...[
                  Expanded(
                    child: _MoodCell(
                      mood: _moods[i],
                      selected: i == _selectedIndex,
                    ),
                  ),
                  if (i < _moods.length - 1) const SizedBox(width: 2),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Mood {
  final String emoji;
  final String label;
  const _Mood(this.emoji, this.label);
}

class _MoodCell extends StatelessWidget {
  final _Mood mood;
  final bool selected;
  const _MoodCell({required this.mood, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
      decoration: selected
          ? BoxDecoration(
              color: const Color(0xFF163220),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF163220).withOpacity(0.2),
                  offset: const Offset(0, 2),
                  blurRadius: 10,
                ),
              ],
            )
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            mood.emoji,
            style: const TextStyle(fontSize: 18, height: 1),
          ),
          const SizedBox(height: 3),
          Text(
            mood.label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 8,
              fontWeight:
                  selected ? FontWeight.w700 : FontWeight.w500,
              color: selected
                  ? const Color(0xFF6DC55A)
                  : const Color(0xFF9AB09A),
            ),
          ),
        ],
      ),
    );
  }
}
