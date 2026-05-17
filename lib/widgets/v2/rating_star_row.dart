import 'package:flutter/material.dart';

/// 1-to-5 star row used by Day 7 review (satisfaction) and Progress
/// (sleepQuality, satisfaction). Stateless visual; the parent owns the
/// integer state and rebuilds on tap.
class RatingStarRow extends StatelessWidget {
  final int? value; // 1..5 or null for "not rated"
  final ValueChanged<int> onChanged;
  final double size;

  static const Color _filled = Color(0xFFFAC775); // amber accent
  static const Color _empty = Color(0xFFC8DEC4); // V2 connector grey-green

  const RatingStarRow({
    Key? key,
    required this.value,
    required this.onChanged,
    this.size = 36,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final n = i + 1;
        final filled = value != null && n <= value!;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: GestureDetector(
            onTap: () => onChanged(n),
            child: Icon(
              filled ? Icons.star_rounded : Icons.star_outline_rounded,
              size: size,
              color: filled ? _filled : _empty,
            ),
          ),
        );
      }),
    );
  }
}
