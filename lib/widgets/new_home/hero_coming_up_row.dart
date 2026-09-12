import 'dart:async';

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

class HeroComingUpRow extends StatefulWidget {
  final List<UpcomingSlot> upcoming;

  /// Optional callback fired when the user taps anywhere on the slot row.
  /// Typically navigates to the workout schedule screen.
  final VoidCallback? onTap;

  const HeroComingUpRow({
    Key? key,
    this.upcoming = const [],
    this.onTap,
  }) : super(key: key);

  @override
  State<HeroComingUpRow> createState() => _HeroComingUpRowState();
}

class _HeroComingUpRowState extends State<HeroComingUpRow> {
  Timer? _clockTicker;

  // Rotating tile palette — preserves the old green / coral / amber cycle.
  static const List<_TilePalette> _palettes = [
    _TilePalette(Color(0xFFA8F0C0), 0.07, 0.12, 0.55),
    _TilePalette(Color(0xFFFF8A8A), 0.06, 0.10, 0.60),
    _TilePalette(Color(0xFFFAC775), 0.06, 0.10, 0.60),
  ];

  @override
  void initState() {
    super.initState();
    // Tick every 30 s — keeps the "Starts in Xm" countdown accurate
    // without a network call.
    _clockTicker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _clockTicker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.upcoming.isEmpty) return const SizedBox.shrink();

    final now = DateTime.now();
    final w = MediaQuery.of(context).size.width;
    final double hPad = (w * 12 / 414).clamp(10.0, 16.0);
    // "Tomorrow's classes" header appears only when nothing remains today.
    final bool allFuture = widget.upcoming.every((u) => u.dayOffset >= 1);
    final content = Padding(
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
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.55),
                ),
              ),
            ),
          Row(
            children: [
              for (int i = 0; i < widget.upcoming.length; i++) ...[
                Expanded(
                  child: _ClassTile(
                    slot: widget.upcoming[i],
                    palette: _palettes[i % _palettes.length],
                    now: now,
                  ),
                ),
                if (i < widget.upcoming.length - 1) const SizedBox(width: 7),
              ],
            ],
          ),
        ],
      ),
    );
    if (widget.onTap == null) return content;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: content,
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

class _ClassTile extends StatelessWidget {
  final UpcomingSlot slot;
  final _TilePalette palette;
  final DateTime now;

  const _ClassTile({
    required this.slot,
    required this.palette,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    final mins = _minutesUntilStart();
    final bool showCountdown = mins != null && mins >= 0 && mins <= 15;

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
            slot.slot.type ?? 'Class',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              height: 1.2,
              color: Colors.white.withOpacity(0.65),
            ),
          ),
          const SizedBox(height: 4),
          if (showCountdown) ...[
            // Amber countdown badge — matches PaidHeroComingUp styling.
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFAC775).withOpacity(0.22),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: const Color(0xFFFAC775).withOpacity(0.45),
                  width: 1,
                ),
              ),
              child: Text(
                mins == 0 ? 'Starts now' : 'Starts in ${mins}m',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFAC775),
                ),
              ),
            ),
          ] else ...[
            Text(
              _formatTileTime(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: palette.base.withOpacity(palette.timeOpacity),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Minutes until [startLocal]. Only meaningful when [dayOffset == 0].
  /// Returns null for tomorrow's slots or if start is in the past.
  int? _minutesUntilStart() {
    if (slot.dayOffset != 0) return null;
    final diff = slot.startLocal.difference(now).inMinutes;
    if (diff < 0) return null;
    return diff;
  }

  /// Today → "10:30 AM". Tomorrow / later → "10:30 AM · Mon".
  String _formatTileTime() {
    if (slot.dayOffset == 0) return slot.slot.start;
    final abbrev = DateFormat('EEE').format(slot.startLocal);
    return '${slot.slot.start} · $abbrev';
  }
}
