import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/controllers/paid_home_controller/paid_home_controller.dart';
import '../../data/models/home_dashboard/home_dashboard_model.dart';
import '../new_home/phase_theme.dart';

/// "How I feel today" mood row.
/// 5 mood cells, one selected at a time. Optimistic UI: tap reflects
/// instantly; while the backend save is in flight the whole row dims to
/// 60% and taps are blocked. On failure the selection reverts to the
/// previous dashboard value and a SnackBar explains.
///
/// Mood int convention (mirrors DailyCheckin.moodLevel server-side):
///   1 = Great · 2 = Tired · 3 = Sore · 4 = Energy · 5 = Stress
class PaidFeelSelector extends StatefulWidget {
  final HomeDashboardModel dashboard;

  const PaidFeelSelector({Key? key, required this.dashboard})
      : super(key: key);

  @override
  State<PaidFeelSelector> createState() => _PaidFeelSelectorState();
}

class _PaidFeelSelectorState extends State<PaidFeelSelector> {
  static const List<_Mood> _moods = [
    _Mood(emoji: '😊', label: 'Great'),
    _Mood(emoji: '😴', label: 'Tired'),
    _Mood(emoji: '😣', label: 'Sore'),
    _Mood(emoji: '⚡', label: 'Energy'),
    _Mood(emoji: '😤', label: 'Stress'),
  ];

  final PaidHomeController _controller = Get.find<PaidHomeController>();

  /// Null when no tap is in flight. When non-null, overrides the index
  /// derived from `dashboard.todayCheckin.moodLevel`. Cleared on success
  /// AND on failure — after either, the dashboard is the source of truth.
  int? _optimisticIndex;

  /// Maps backend moodLevel (1..5, nullable) to UI cell index (0..4, nullable).
  /// Invalid values return null so no cell is pre-selected.
  int? _dashboardIndex() {
    final m = widget.dashboard.todayCheckin?.moodLevel;
    if (m == null || m < 1 || m > 5) return null;
    return m - 1;
  }

  int? _effectiveIndex() => _optimisticIndex ?? _dashboardIndex();

  Future<void> _onTap(int cellIndex) async {
    // Ignore taps while a save is in flight (simple approach per spec).
    if (_controller.isSavingMood.value) return;

    final previous = _effectiveIndex();
    // No-op if tapping the already-selected cell.
    if (previous == cellIndex) return;

    // Optimistic: paint the new selection immediately.
    setState(() => _optimisticIndex = cellIndex);

    final success = await _controller.logMood(cellIndex + 1);
    if (!mounted) return;

    // Clear the optimistic override either way — the dashboard (refreshed on
    // success, unchanged on failure) becomes the source of truth again.
    setState(() => _optimisticIndex = null);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Couldn't save. Please try again."),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme =
        PhaseTheme.forPhaseString(widget.dashboard.cycle?.phase);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD8EDD4), width: 1),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // "HOW I FEEL TODAY" label (.lbl9 spec).
          const Text(
            'HOW I FEEL TODAY',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Color(0xFF9AB09A),
              // letter-spacing: 0.07em of 9 px = ~0.63 logical pixels.
              letterSpacing: 9 * 0.07,
            ),
          ),
          const SizedBox(height: 7),
          // Track: cream bg, flex row, 3 px inner padding, 2 px gap.
          Obx(() {
            final saving = _controller.isSavingMood.value;
            return Opacity(
              opacity: saving ? 0.6 : 1.0,
              child: IgnorePointer(
                ignoring: saving,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF7E4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      for (int i = 0; i < _moods.length; i++) ...[
                        Expanded(
                          child: _Cell(
                            mood: _moods[i],
                            selected: _effectiveIndex() == i,
                            accent: theme.accent,
                            onTap: () => _onTap(i),
                          ),
                        ),
                        if (i < _moods.length - 1) const SizedBox(width: 2),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _Mood {
  final String emoji;
  final String label;
  const _Mood({required this.emoji, required this.label});
}

class _Cell extends StatelessWidget {
  final _Mood mood;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  const _Cell({
    required this.mood,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
        decoration: selected
            ? BoxDecoration(
                color: const Color(0xFF163220),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF163220).withOpacity(0.20),
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
              style: const TextStyle(fontSize: 18, height: 1.0),
            ),
            const SizedBox(height: 3),
            Text(
              mood.label,
              style: TextStyle(
                fontSize: 8,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                // Selected: phase accent (follicular=green, ovulatory=teal,
                // luteal=amber, menstrual=coral).
                // Unselected: grey-green label color from HTML.
                color: selected ? accent : const Color(0xFF9AB09A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
