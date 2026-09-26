import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/controllers/paid_home_controller/paid_home_controller.dart';
import '../../data/models/home_dashboard/home_dashboard_model.dart';

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
  // Each mood gets its own soft accent instead of one uniform dark pill
  // for all five — lets the row read as expressive/varied at a glance,
  // and gives selecting "Great" vs "Stress" a genuinely different feel.
  // Deliberately muted/pastel (not traffic-light red/green) so a hard
  // day never reads as "wrong" — a wellness app shouldn't punish Stress
  // or Sore with an alarming color.
  static const List<_Mood> _moods = [
    _Mood(emoji: '😊', label: 'Great', color: Color(0xFF6DC55A)),
    _Mood(emoji: '😴', label: 'Tired', color: Color(0xFF8FA6C9)),
    _Mood(emoji: '😣', label: 'Sore', color: Color(0xFFE39B6B)),
    _Mood(emoji: '⚡', label: 'Energy', color: Color(0xFFE8B23D)),
    _Mood(emoji: '😤', label: 'Stress', color: Color(0xFFD97B87)),
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
          // "How I feel today" — bumped up from the old 9px .lbl9 spec.
          // This is the one daily, personal input on the whole screen; it
          // was visually the quietest thing on the card, which undersold
          // it every single time someone opened the app.
          Row(
            children: [
              // Neutral green heart before anything's picked today; once
              // a mood is selected (optimistic tap or the saved dashboard
              // value), the header itself reflects that mood instead of
              // staying a generic icon — a small confirmation that reads
              // at a glance, not just the "Logged ✓" text over on the right.
              Text(
                _effectiveIndex() != null
                    ? _moods[_effectiveIndex()!].emoji
                    : '💚',
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 5),
              const Text(
                'How I feel today',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF163220),
                ),
              ),
              const Spacer(),
              // Quiet reward for having already logged today — closes the
              // loop instead of the tap just silently updating something.
              if (_dashboardIndex() != null && _optimisticIndex == null)
                Text(
                  'Logged ✓',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: _moods[_dashboardIndex()!].color,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 9),
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
  final Color color;
  const _Mood({required this.emoji, required this.label, required this.color});
}

class _Cell extends StatelessWidget {
  final _Mood mood;
  final bool selected;
  final VoidCallback onTap;

  const _Cell({
    required this.mood,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      // Tap feedback: the whole cell pops slightly on selection instead of
      // flatly swapping — a small nudge that the app noticed the tap.
      child: TweenAnimationBuilder<double>(
        key: ValueKey('${mood.label}-$selected'),
        tween: Tween(begin: selected ? 0.9 : 1.0, end: 1.0),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutBack,
        builder: (context, scale, child) =>
            Transform.scale(scale: scale, child: child),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
          decoration: selected
              ? BoxDecoration(
                  color: const Color(0xFF163220),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    // Glow tinted by the mood's own color — "Great" and
                    // "Stress" both use the familiar dark pill (keeps it
                    // consistent with selected states elsewhere in the
                    // app) but now visibly glow a different color, so the
                    // row responds to *which* feeling was picked.
                    BoxShadow(
                      color: mood.color.withOpacity(0.45),
                      offset: const Offset(0, 2),
                      blurRadius: 12,
                    ),
                  ],
                )
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Emoji sits on its own soft color badge at all times — even
              // unselected, each mood carries its own identity instead of
              // all five looking like interchangeable pale chips.
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? Colors.white.withOpacity(0.16)
                      : mood.color.withOpacity(0.14),
                ),
                child: Text(
                  mood.emoji,
                  style: const TextStyle(fontSize: 16, height: 1.0),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                mood.label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 8.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? mood.color : const Color(0xFF9AB09A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
