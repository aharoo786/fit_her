import 'package:flutter/material.dart';
import '../../data/models/meal_log/meal_log.dart';

/// Status pill rendered on the meal log home tile (Phase 2D) and inside
/// the meal-edit-history screen. Color codes match the task spec
/// (Section 6.2):
///   followed    → green
///   alternative → amber
///   skipped     → muted grey
///   pending     → outline grey (no fill)
class MealStatusChip extends StatelessWidget {
  final MealStatus status;
  final double height;
  final bool dense;

  const MealStatusChip({
    Key? key,
    required this.status,
    this.height = 24,
    this.dense = false,
  }) : super(key: key);

  static const Map<MealStatus, _ChipStyle> _styles = {
    MealStatus.followed: _ChipStyle(
      bg: Color(0xFFE4F9D7),
      fg: Color(0xFF2D6B26),
      label: 'Followed',
      icon: Icons.check_rounded,
    ),
    MealStatus.alternative: _ChipStyle(
      bg: Color(0xFFFDEFD0),
      fg: Color(0xFF8A6515),
      label: 'Alternative',
      icon: Icons.swap_horiz_rounded,
    ),
    MealStatus.skipped: _ChipStyle(
      bg: Color(0xFFEEEEEE),
      fg: Color(0xFF6F6F6F),
      label: 'Skipped',
      icon: Icons.skip_next_rounded,
    ),
    MealStatus.pending: _ChipStyle(
      bg: Color(0x00000000), // transparent — only border
      fg: Color(0xFF7A8C78),
      label: 'Pending',
      icon: Icons.access_time_rounded,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final s = _styles[status]!;
    final outline = status == MealStatus.pending;
    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: dense ? 8 : 10),
      decoration: BoxDecoration(
        color: s.bg,
        borderRadius: BorderRadius.circular(12),
        border: outline ? Border.all(color: s.fg.withOpacity(0.55)) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(s.icon, size: 12, color: s.fg),
          const SizedBox(width: 4),
          Text(
            s.label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: dense ? 10 : 11,
              fontWeight: FontWeight.w600,
              color: s.fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipStyle {
  final Color bg;
  final Color fg;
  final String label;
  final IconData icon;
  const _ChipStyle({
    required this.bg,
    required this.fg,
    required this.label,
    required this.icon,
  });
}
