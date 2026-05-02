import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/get_user_plan/get_workout_user_plan_details.dart'
    show Slot;

/// View-model pairing a parsed [Slot] with its raw local [DateTime]s and the
/// day offset from today (0 = today, 1 = tomorrow, …). Constructed in
/// `unpaid_home_screen.dart`; the dayOffset lets the tile decide whether to
/// append a weekday abbreviation and whether the row needs a "Tomorrow's
/// classes" header when today has no remaining entries.
class UpcomingSlot {
  final Slot slot;
  final DateTime startLocal;
  final DateTime endLocal;
  final int dayOffset;

  const UpcomingSlot(
    this.slot,
    this.startLocal,
    this.endLocal, {
    this.dayOffset = 0,
  });
}

class HeroComingUpRow extends StatelessWidget {
  final List<UpcomingSlot> upcoming;

  const HeroComingUpRow({
    Key? key,
    this.upcoming = const [],
  }) : super(key: key);

  // Rotating tile palette — preserves the old green / coral / amber cycle.
  static const List<_TilePalette> _palettes = [
    _TilePalette(Color(0xFFA8F0C0), 0.07, 0.12, 0.55),
    _TilePalette(Color(0xFFFF8A8A), 0.06, 0.10, 0.60),
    _TilePalette(Color(0xFFFAC775), 0.06, 0.10, 0.60),
  ];

  @override
  Widget build(BuildContext context) {
    if (upcoming.isEmpty) return const SizedBox.shrink();

    final w = MediaQuery.of(context).size.width;
    final double hPad = (w * 12 / 414).clamp(10.0, 16.0);
    // "Tomorrow's classes" header appears only when nothing remains today.
    final bool allFuture = upcoming.every((u) => u.dayOffset >= 1);
    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 14, hPad, 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (allFuture)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                "Tomorrow's classes",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.55),
                ),
              ),
            ),
          Row(
            children: [
              for (int i = 0; i < upcoming.length; i++) ...[
                Expanded(
                  child: _ClassTile(
                    name: upcoming[i].slot.type ?? 'Class',
                    time: _formatTileTime(upcoming[i]),
                    palette: _palettes[i % _palettes.length],
                  ),
                ),
                if (i < upcoming.length - 1) const SizedBox(width: 7),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// Today → "10:30 AM". Tomorrow / later → "10:30 AM · Mon".
  static String _formatTileTime(UpcomingSlot u) {
    if (u.dayOffset == 0) return u.slot.start;
    final abbrev = DateFormat('EEE').format(u.startLocal);
    return '${u.slot.start} · $abbrev';
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

class _ClassTile extends StatelessWidget {
  final String name;
  final String time;
  final _TilePalette palette;
  const _ClassTile({
    required this.name,
    required this.time,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
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
            name,
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
            time,
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
}
