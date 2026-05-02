import 'package:flutter/material.dart';

/// Phase C primitive — horizontal "intensity bar with delta" used by:
///   • Symptoms card (4 rows: bloating / energy / mood / cramps)
///   • Nutrition card macro tiles (calories / protein / carbs / water)
///
/// Pure Flutter — no chart lib, no controller. Brief §5.3 explicitly opts
/// for `Container + LinearGradient + delta arrow` here because Syncfusion
/// is overkill for a 1D bar.
///
/// Direction semantics for [delta] colour are decided by the backend
/// (`SymptomDelta` returns 'improvement' | 'regression' | 'unchanged').
/// This widget just renders what it's told — pass [deltaIsImprovement] so
/// the green/red colour is correct regardless of whether the symptom is
/// "lower is better" (bloating, cramps) or "higher is better" (mood, energy).
class TrendBar extends StatelessWidget {
  /// Display label, e.g. "Bloating", "Protein".
  final String label;

  /// 0..1 fill fraction. Clamped on render. `null` renders a muted empty bar
  /// + "—" trailing text for the no-data state.
  final double? pct;

  /// Optional bar fill colour. Defaults to the design-system green
  /// (#6DC55A — same accent the existing PaidHomeV2 cards use).
  final Color? color;

  /// Trailing text shown right of the bar, e.g. "35%", "78g/100g", "1.6L".
  /// Empty string suppresses the trailing block entirely.
  final String trailingText;

  /// Signed delta percentage. Pass `null` to suppress the delta pill.
  /// Magnitude is rendered with one digit ("60%" not "60.0%"); sign is
  /// derived from [deltaIsImprovement] + [deltaPct] together (see below).
  final double? deltaPct;

  /// Whether the [deltaPct] represents an improvement (green) or
  /// regression (red). The backend computes this — frontend just renders.
  /// `null` + a non-null [deltaPct] → neutral grey pill.
  final bool? deltaIsImprovement;

  /// Optional nudge copy shown under the bar in muted text — e.g.
  /// "drink more" or "more protein". Empty / null hides the line.
  final String? nudge;

  /// Optional override for the bar height. Default 8 logical px matches
  /// the mockup; pass 12 for the chunkier nutrition macros if needed.
  final double barHeight;

  const TrendBar({
    Key? key,
    required this.label,
    required this.pct,
    this.trailingText = '',
    this.deltaPct,
    this.deltaIsImprovement,
    this.color,
    this.nudge,
    this.barHeight = 8,
  }) : super(key: key);

  static const Color _defaultBarColor = Color(0xFF6DC55A);
  static const Color _trackColor = Color(0xFFE8F2E5);
  static const Color _improveColor = Color(0xFF3FA34D);
  static const Color _regressColor = Color(0xFFE07B7B);
  static const Color _neutralColor = Color(0xFF9AB09A);
  static const Color _labelColor = Color(0xFF163220);
  static const Color _mutedColor = Color(0xFF6F8B7A);

  @override
  Widget build(BuildContext context) {
    final fill = (pct ?? 0).clamp(0.0, 1.0);
    final hasData = pct != null;
    final barColor = color ?? _defaultBarColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _labelColor,
                ),
              ),
            ),
            if (deltaPct != null) ...[
              _DeltaPill(
                deltaPct: deltaPct!,
                isImprovement: deltaIsImprovement,
              ),
              const SizedBox(width: 8),
            ],
            if (trailingText.isNotEmpty)
              Text(
                hasData ? trailingText : '—',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _labelColor,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(barHeight / 2),
          child: Stack(
            children: [
              Container(
                height: barHeight,
                width: double.infinity,
                color: _trackColor,
              ),
              FractionallySizedBox(
                widthFactor: fill,
                child: Container(
                  height: barHeight,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        barColor.withOpacity(0.85),
                        barColor,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (nudge != null && nudge!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              nudge!,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: _mutedColor,
              ),
            ),
          ),
      ],
    );
  }
}

class _DeltaPill extends StatelessWidget {
  final double deltaPct;
  final bool? isImprovement;

  const _DeltaPill({required this.deltaPct, this.isImprovement});

  @override
  Widget build(BuildContext context) {
    final magnitude = deltaPct.abs().round();
    // Arrow direction tracks the raw sign of the delta. The COLOUR tracks
    // semantic meaning (improvement/regression). A symptom that's "lower
    // is better" can have a downward arrow + green colour at the same
    // time — that's intentional and the backend tells us which is which.
    final arrow = deltaPct == 0 ? '·' : (deltaPct > 0 ? '↑' : '↓');
    final Color color;
    final Color bg;
    if (isImprovement == true) {
      color = TrendBar._improveColor;
      bg = const Color(0xFFE4F4DC);
    } else if (isImprovement == false) {
      color = TrendBar._regressColor;
      bg = const Color(0xFFFCE3E3);
    } else {
      color = TrendBar._neutralColor;
      bg = const Color(0xFFEDEFEC);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$arrow $magnitude%',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
          height: 1.0,
        ),
      ),
    );
  }
}
