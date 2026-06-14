import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../data/controllers/cycle_theme_controller/cycle_theme_controller.dart';
import '../widgets/new_home/community_footer.dart';
import '../widgets/new_home/phase_theme.dart';
import '../widgets/new_home/trial_cta_card.dart';
import '../widgets/progress_v2/goal_ring.dart';

/// Unpaid Progress preview — shown to users with `status == false` in
/// `bottom_bar_screen.dart` instead of the legacy ProgressScreenV1.
///
/// Job-to-be-done: make the user *want* the Day-14 report by showing it.
/// Every card carries a clear PREVIEW / SAMPLE label so this never reads
/// as fake data — it reads as "here's what's waiting for you".
///
/// Reuses V2 building blocks where possible:
///   • [GoalRing] — same primitive as the paid hero
///   • [TrialCtaCard] — the dark gradient CTA from the unpaid home so
///     the offer feels singular across surfaces
///   • [CommunityFooter] — same social-proof footer as home
class UnpaidProgressScreen extends StatelessWidget {
  const UnpaidProgressScreen({super.key});

  static const _kCanvas = Color(0xFFF5FBF2);
  static const _kHeroDark = Color(0xFF163220);
  static const _kAccent = Color(0xFF6DC55A);
  static const _kAccentSoft = Color(0xFFA8F0C0);
  static const _kCardBg = Colors.white;
  static const _kCardBorder = Color(0xFFD8EDD4);
  static const _kTextPrimary = Color(0xFF163220);
  static const _kTextMuted = Color(0xFF6F8B7A);
  static const _kSage = Color(0xFF9AB09A);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Phase-aware colors from the global controller — populated from
      // SharedPreferences on init, so no flicker on first render.
      final phaseTheme = Get.find<CycleThemeController>().theme.value;
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: _kCanvas,
          body: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Hero(phaseTheme: phaseTheme),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: const [
                      _SampleTrendCard(),
                      SizedBox(height: 12),
                      _UnlockJourneyCard(),
                      SizedBox(height: 12),
                      _AiInsightTeaseCard(),
                      SizedBox(height: 12),
                      TrialCtaCard(),
                      SizedBox(height: 4),
                      CommunityFooter(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

// ════════════════════════════════════════════════════════════════════════
// HERO — phase-aware band, PREVIEW pill, sample goal ring + 4 stat tiles.
// Background + accent driven by CycleThemeController via [PhaseTheme].
// Edge-to-edge with rounded bottom corners, status-bar safe.
// ════════════════════════════════════════════════════════════════════════
class _Hero extends StatelessWidget {
  final PhaseTheme phaseTheme;
  const _Hero({required this.phaseTheme});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final bg = phaseTheme.heroBackground;
    final accent = phaseTheme.accent;
    const radius = BorderRadius.only(
      bottomLeft: Radius.circular(36),
      bottomRight: Radius.circular(36),
    );
    return Container(
      decoration: BoxDecoration(color: bg, borderRadius: radius),
      child: ClipRRect(
        borderRadius: radius,
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
          child: Stack(
            children: [
              // Soft radial highlight — same recipe as the home hero.
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(1.1, -1.05),
                        radius: 1.3,
                        colors: [
                          accent.withOpacity(0.30),
                          accent.withOpacity(0.00),
                        ],
                        stops: const [0.0, 0.55],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(22, topInset + 14, 22, 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PreviewPill(accent: accent),
                    const SizedBox(height: 16),
                    const Text(
                      'Your 14-day report',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "This is what's waiting for you. Start tracking today.",
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: Color(0xCCFFFFFF),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _HeroSampleGoal(accent: accent),
                    const SizedBox(height: 18),
                    const _HeroStatGrid(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewPill extends StatelessWidget {
  final Color accent;
  const _PreviewPill({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.18),
        border: Border.all(color: accent.withOpacity(0.4), width: 1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔒', style: TextStyle(fontSize: 11)),
          const SizedBox(width: 5),
          Text(
            'PREVIEW',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: accent.withOpacity(0.85),
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSampleGoal extends StatelessWidget {
  final Color accent;
  const _HeroSampleGoal({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GoalRing(
          progress: 0.65,
          color: accent,
          centerText: '65%',
          size: 96,
          centerTextStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1,
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SAMPLE · DAY 14',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: Colors.white.withOpacity(0.45),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '−2.1 kg',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'of −3.2 kg goal',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  'On pace 💚',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: accent.withOpacity(0.9),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroStatGrid extends StatelessWidget {
  const _HeroStatGrid();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _HeroStatTile(value: '12', label: 'Workouts', emoji: '🏋️'),
        SizedBox(width: 8),
        _HeroStatTile(value: '8🔥', label: 'Streak', emoji: ''),
        SizedBox(width: 8),
        _HeroStatTile(value: '7.2h', label: 'Sleep', emoji: '🌙'),
        SizedBox(width: 8),
        _HeroStatTile(value: '2.1L', label: 'Hydration', emoji: '💧'),
      ],
    );
  }
}

class _HeroStatTile extends StatelessWidget {
  final String value;
  final String label;
  final String emoji;
  const _HeroStatTile({
    required this.value,
    required this.label,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          border:
              Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              emoji.isEmpty ? label : '$emoji $label',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// SAMPLE TREND — illustrative 4-week weight chart, phase-coloured.
// ════════════════════════════════════════════════════════════════════════
class _SampleTrendCard extends StatelessWidget {
  const _SampleTrendCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _CardTitleRow(
            title: 'WEEKLY TREND',
            trailingLabel: 'SAMPLE',
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 120,
            child: CustomPaint(
              painter: _SampleTrendPainter(),
              size: Size.infinite,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              _PhaseLegend(color: Color(0xFFFF8A8A), label: 'Menstrual'),
              SizedBox(width: 10),
              _PhaseLegend(color: Color(0xFFA8F0C0), label: 'Follicular'),
              SizedBox(width: 10),
              _PhaseLegend(color: Color(0xFFFAC775), label: 'Ovulation'),
              SizedBox(width: 10),
              _PhaseLegend(color: Color(0xFFC9B6FF), label: 'Luteal'),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "Track your weight, sync'd to your cycle phase.",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: UnpaidProgressScreen._kTextMuted,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _SampleTrendPainter extends CustomPainter {
  // 4 data points × 4 weeks = 16 sample readings. Coordinates expressed as
  // (x in 0..1, y in 0..1 where 0 = top / heaviest, 1 = bottom / lightest).
  // The path tells a story: small bumps in luteal & menstrual, dips in
  // follicular & ovulation. Down-trending overall.
  static const _points = <Offset>[
    Offset(0.00, 0.10),
    Offset(0.07, 0.18),
    Offset(0.14, 0.22),
    Offset(0.21, 0.20),
    Offset(0.28, 0.30),
    Offset(0.35, 0.40),
    Offset(0.42, 0.42),
    Offset(0.50, 0.38),
    Offset(0.57, 0.48),
    Offset(0.64, 0.55),
    Offset(0.71, 0.52),
    Offset(0.78, 0.60),
    Offset(0.85, 0.70),
    Offset(0.92, 0.75),
    Offset(1.00, 0.72),
  ];

  // Phase-coloured segments. Boundaries are quarter-of-week splits.
  static const _segments = <_Segment>[
    _Segment(start: 0.00, end: 0.25, color: Color(0xFFFF8A8A)),  // menstrual
    _Segment(start: 0.25, end: 0.55, color: Color(0xFFA8F0C0)),  // follicular
    _Segment(start: 0.55, end: 0.75, color: Color(0xFFFAC775)),  // ovulation
    _Segment(start: 0.75, end: 1.00, color: Color(0xFFC9B6FF)),  // luteal
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Faint dashed mid-line for visual anchor.
    final guidePaint = Paint()
      ..color = const Color(0xFFD8EDD4)
      ..strokeWidth = 1;
    const dashStep = 6.0;
    for (double x = 0; x < w; x += dashStep * 2) {
      canvas.drawLine(Offset(x, h * 0.5),
          Offset((x + dashStep).clamp(0, w), h * 0.5), guidePaint);
    }

    // Soft fill under the curve for depth.
    final fillPath = Path()..moveTo(0, h);
    for (final p in _points) {
      fillPath.lineTo(p.dx * w, p.dy * h);
    }
    fillPath
      ..lineTo(w, h)
      ..close();
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF6DC55A).withOpacity(0.18),
          const Color(0xFF6DC55A).withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(fillPath, fillPaint);

    // Phase-segmented line.
    for (final seg in _segments) {
      final segPaint = Paint()
        ..color = seg.color
        ..strokeWidth = 2.6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      final segPath = Path();
      bool started = false;
      for (int i = 0; i < _points.length; i++) {
        final t = _points[i].dx;
        final inside = t >= seg.start && t <= seg.end + 0.001;
        if (!inside) continue;
        final px = _points[i].dx * w;
        final py = _points[i].dy * h;
        if (!started) {
          segPath.moveTo(px, py);
          started = true;
        } else {
          segPath.lineTo(px, py);
        }
      }
      canvas.drawPath(segPath, segPaint);
    }

    // Final point dot.
    final last = _points.last;
    final dotCenter = Offset(last.dx * w - 1, last.dy * h);
    final dotPaint = Paint()..color = const Color(0xFF6DC55A);
    canvas.drawCircle(dotCenter, 4.5, dotPaint);
    canvas.drawCircle(
      dotCenter,
      6.5,
      Paint()
        ..color = const Color(0xFF6DC55A).withOpacity(0.25)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _SampleTrendPainter oldDelegate) => false;
}

class _Segment {
  final double start;
  final double end;
  final Color color;
  const _Segment({
    required this.start,
    required this.end,
    required this.color,
  });
}

class _PhaseLegend extends StatelessWidget {
  final Color color;
  final String label;
  const _PhaseLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 9,
            color: UnpaidProgressScreen._kSage,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// UNLOCK JOURNEY — vertical timeline. Day 1 is "live" (the user's
// starting line), the rest are upcoming milestones.
// ════════════════════════════════════════════════════════════════════════
class _UnlockJourneyCard extends StatelessWidget {
  const _UnlockJourneyCard();

  @override
  Widget build(BuildContext context) {
    final steps = <_TimelineStep>[
      const _TimelineStep(
        day: 'Day 1',
        title: 'Start tracking',
        subtitle: 'First check-in unlocks your dashboard.',
        live: true,
      ),
      const _TimelineStep(
        day: 'Day 3',
        title: 'Free trial ends',
        subtitle: 'Continue at PKR 3500/month — cancel anytime.',
      ),
      const _TimelineStep(
        day: 'Day 7',
        title: 'First weekly trends',
        subtitle: 'Weight, sleep & hydration patterns appear.',
      ),
      const _TimelineStep(
        day: 'Day 14',
        title: 'AI insights + full report',
        subtitle: 'Your phase-matched recommendations drop here.',
        star: true,
      ),
      const _TimelineStep(
        day: 'Day 21',
        title: 'Cycle-phase deep dive',
        subtitle: 'See how each phase shapes your results.',
      ),
    ];
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _CardTitleRow(title: 'YOUR UNLOCK JOURNEY'),
          const SizedBox(height: 14),
          for (int i = 0; i < steps.length; i++)
            _TimelineRow(
              step: steps[i],
              isLast: i == steps.length - 1,
            ),
        ],
      ),
    );
  }
}

class _TimelineStep {
  final String day;
  final String title;
  final String subtitle;
  final bool live;
  final bool star;
  const _TimelineStep({
    required this.day,
    required this.title,
    required this.subtitle,
    this.live = false,
    this.star = false,
  });
}

class _TimelineRow extends StatelessWidget {
  final _TimelineStep step;
  final bool isLast;
  const _TimelineRow({required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final dotColor =
        step.live ? UnpaidProgressScreen._kAccent : const Color(0xFFD8EDD4);
    final dotInner = step.live ? Colors.white : Colors.transparent;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    border: step.live
                        ? null
                        : Border.all(
                            color: UnpaidProgressScreen._kCardBorder,
                            width: 2,
                          ),
                  ),
                  child: step.live
                      ? Center(
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: dotInner,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: UnpaidProgressScreen._kCardBorder,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          step.day,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: UnpaidProgressScreen._kAccent,
                          ),
                        ),
                        if (step.star) ...[
                          const SizedBox(width: 6),
                          const Text('⭐', style: TextStyle(fontSize: 11)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      step.title,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: UnpaidProgressScreen._kTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      step.subtitle,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        height: 1.4,
                        color: UnpaidProgressScreen._kTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// AI INSIGHT TEASE — blurred sample insight, mirrors home's LockedInsightCard.
// ════════════════════════════════════════════════════════════════════════
class _AiInsightTeaseCard extends StatelessWidget {
  const _AiInsightTeaseCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _CardTitleRow(
            title: '🔒 AI INSIGHTS · DAY 14',
            trailingLabel: 'PREVIEW',
          ),
          SizedBox(height: 10),
          Opacity(
            opacity: 0.55,
            child: Text(
              'Recovery is 40% faster in your follicular phase — push today, '
              'rest smart this weekend for…',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                height: 1.5,
                color: Color(0xFF4A6B4A),
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Unlock 3 personalised insights every week →',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: UnpaidProgressScreen._kAccent,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// Shared bits
// ════════════════════════════════════════════════════════════════════════
class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UnpaidProgressScreen._kCardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: UnpaidProgressScreen._kCardBorder),
        boxShadow: [
          BoxShadow(
            color: UnpaidProgressScreen._kHeroDark.withOpacity(0.04),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CardTitleRow extends StatelessWidget {
  final String title;
  final String? trailingLabel;
  const _CardTitleRow({required this.title, this.trailingLabel});

  @override
  Widget build(BuildContext context) {
    final t = Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: UnpaidProgressScreen._kTextMuted,
        letterSpacing: 0.8,
      ),
    );
    if (trailingLabel == null) return t;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: t),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: UnpaidProgressScreen._kAccent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: UnpaidProgressScreen._kAccent.withOpacity(0.28),
            ),
          ),
          child: Text(
            trailingLabel!,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: UnpaidProgressScreen._kAccent,
              letterSpacing: 0.6,
            ),
          ),
        ),
      ],
    );
  }
}
