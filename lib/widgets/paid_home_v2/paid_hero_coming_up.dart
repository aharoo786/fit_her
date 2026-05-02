import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/home_dashboard/home_dashboard_model.dart';

/// H-01 Coming Up row. Renders up to 3 phase-tinted tiles in a fixed
/// mint/coral/amber cycle (matches the HTML, NOT phase-driven).
/// When `comingUp` is empty, shows a single muted "No upcoming classes"
/// text in place of the tile row.
class PaidHeroComingUp extends StatelessWidget {
  final List<ComingUpClass> comingUp;

  const PaidHeroComingUp({Key? key, required this.comingUp}) : super(key: key);

  // Fixed palette — H-01 defaults in `new screens/Home_All43_Variants.html`
  // line 133-137. Rotation is mint → coral → amber regardless of phase.
  static const List<_TilePalette> _palettes = [
    _TilePalette(Color(0xFFA8F0C0), 0.07, 0.12, 0.55), // mint
    _TilePalette(Color(0xFFFF8A8A), 0.06, 0.10, 0.60), // coral
    _TilePalette(Color(0xFFFAC775), 0.06, 0.10, 0.60), // amber
  ];

  @override
  Widget build(BuildContext context) {
    if (comingUp.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 18),
        child: Text(
          'No upcoming classes',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.45),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 18),
      child: Row(
        children: [
          for (int i = 0; i < comingUp.length; i++) ...[
            Expanded(
              child: _Tile(
                item: comingUp[i],
                palette: _palettes[i % _palettes.length],
              ),
            ),
            if (i < comingUp.length - 1) const SizedBox(width: 7),
          ],
        ],
      ),
    );
  }
}

class _TilePalette {
  final Color base;
  final double bgOpacity;
  final double borderOpacity;
  final double timeOpacity;
  const _TilePalette(
    this.base,
    this.bgOpacity,
    this.borderOpacity,
    this.timeOpacity,
  );
}

class _Tile extends StatelessWidget {
  final ComingUpClass item;
  final _TilePalette palette;

  const _Tile({required this.item, required this.palette});

  @override
  Widget build(BuildContext context) {
    // Build a single local DateTime from (today UTC + dayOffset, HH:MM UTC),
    // then derive BOTH the time string and the weekday label from it. The
    // previous version converted time and day independently — time via
    // ScheduleTimeHelper (local TZ) and day via `now + dayOffset` (UTC-day
    // offset). When the UTC→local shift crossed midnight (e.g. UTC 19:00
    // dayOffset=0 → 00:00 next day in PKT), the two could disagree and
    // tiles would render with a weekday label that didn't match the actual
    // local class day.
    final displayStr = _resolveDisplay(item);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      decoration: BoxDecoration(
        color: palette.base.withOpacity(palette.bgOpacity),
        border: Border.all(
          color: palette.base.withOpacity(palette.borderOpacity),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.classType ?? 'Class',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              height: 1.2,
              color: Colors.white.withOpacity(0.65),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            displayStr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: palette.base.withOpacity(palette.timeOpacity),
            ),
          ),
        ],
      ),
    );
  }

  /// Pass-through display: shows whatever the admin entered for slot.start
  /// (e.g. "12:00 PM"). Same string the workout schedule renders — by
  /// design, the two surfaces always agree. When the slot is not on today's
  /// weekday, we suffix the abbreviated weekday name (e.g. "12:00 PM · Thu").
  /// No timezone math, no UTC parsing.
  static String _resolveDisplay(ComingUpClass item) {
    final raw = (item.start ?? item.startTimeUtc ?? '').trim();
    if (raw.isEmpty) return '—';
    final weekday = item.weekday;
    if (weekday == null || weekday.isEmpty) return raw;
    final todayName = DateFormat('EEEE').format(DateTime.now());
    if (weekday == todayName) return raw;
    final short = weekday.length >= 3 ? weekday.substring(0, 3) : weekday;
    return '$raw · $short';
  }
}
