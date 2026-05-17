import 'package:flutter/material.dart';

/// 0–100 percent slider used by Day 7 review (adherence). Renders a
/// large numeric value above the bar; the bar itself is a styled
/// Material Slider with the V2 accent green track.
class V2SliderInput extends StatelessWidget {
  final int value; // 0..100
  final ValueChanged<int> onChanged;
  final String suffix; // e.g. "%"
  final int min;
  final int max;

  static const Color _accent = Color(0xFF6DC55A);
  static const Color _track = Color(0xFFC8DEC4);
  static const Color _label = Color(0xFF1A3A22);

  const V2SliderInput({
    Key? key,
    required this.value,
    required this.onChanged,
    this.suffix = '%',
    this.min = 0,
    this.max = 100,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '$value$suffix',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: _label,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: _accent,
            inactiveTrackColor: _track,
            thumbColor: _accent,
            overlayColor: _accent.withOpacity(0.18),
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
          ),
          child: Slider(
            value: value.toDouble().clamp(min.toDouble(), max.toDouble()),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
      ],
    );
  }
}
