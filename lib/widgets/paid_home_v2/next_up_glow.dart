import 'package:flutter/material.dart';

/// Wraps a daily check-in card (Mood / Water / Sleep) with a soft pulsing
/// glow when it's the next thing the user hasn't logged today — a quiet
/// "do this one next" nudge instead of a hard-forced wizard flow. The
/// glow fully disappears the moment that item is logged (the parent
/// screen recomputes which item is "next" every time the dashboard
/// refreshes, which already happens automatically after every successful
/// log), so it advances Mood → Water → Sleep on its own with no extra
/// event plumbing needed here.
///
/// Deliberately just a highlight, not an expand/collapse — Water and
/// Sleep aren't collapsible cards to begin with, they're always fully
/// visible, so there's nothing to "open". The nudge is purely visual.
///
/// Renders [child] completely unchanged when [active] is false, so a
/// card that isn't being pointed to costs nothing and looks identical
/// to before this existed.
class NextUpGlow extends StatefulWidget {
  final bool active;
  final Color color;
  final Widget child;

  const NextUpGlow({
    Key? key,
    required this.active,
    required this.color,
    required this.child,
  }) : super(key: key);

  @override
  State<NextUpGlow> createState() => _NextUpGlowState();
}

class _NextUpGlowState extends State<NextUpGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );

  @override
  void initState() {
    super.initState();
    if (widget.active) _ctrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant NextUpGlow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Start/stop the loop as the "next up" target moves between cards —
    // an inactive card must not keep animating (or keep a ticker alive)
    // once the glow has moved on to a different one.
    if (widget.active && !_ctrl.isAnimating) {
      _ctrl.repeat(reverse: true);
    } else if (!widget.active && _ctrl.isAnimating) {
      _ctrl.stop();
      _ctrl.value = 0;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return widget.child;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final t = _ctrl.value; // 0..1, breathes in and out
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.16 + 0.22 * t),
                blurRadius: 12 + 8 * t,
                spreadRadius: 0.5 + 1.5 * t,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
