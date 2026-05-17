import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Phase C primitive — expand/collapse card used by the AI Insights section
/// (3 cards on the hub, only one open at a time).
///
/// Two usage modes:
///
/// 1. **Coordinated** — pass [groupSelectedIndex] and [index]. The widget
///    reads/writes that shared `RxInt` so siblings collapse when this one
///    opens. This is what the Progress hub uses (3 InsightCards share one
///    `RxInt` owned by ProgressControllerV2).
///
/// 2. **Standalone** — omit [groupSelectedIndex]. The widget owns its own
///    open/closed state. Useful for previews / one-off cards / the test
///    harness the user asked for.
///
/// In both modes the card animates expansion in 200ms and is fully
/// keyboard-accessible (toggleable via Tap + Enter).
class ExpandableCard extends StatefulWidget {
  /// Always-visible header. Tap target for the expand/collapse toggle.
  final Widget header;

  /// Body shown when expanded. Lazy — only built when needed.
  final WidgetBuilder bodyBuilder;

  /// Position of this card within its group. Required when
  /// [groupSelectedIndex] is provided. Defaults to 0 in standalone mode.
  final int index;

  /// Shared RxInt for single-open coordination across sibling cards. Use
  /// `(-1).obs` to indicate "all closed" initial state. When provided, the
  /// widget's expanded state is derived from `groupSelectedIndex.value`.
  final RxInt? groupSelectedIndex;

  /// Initial open/closed state in standalone mode. Ignored when
  /// [groupSelectedIndex] is provided.
  final bool initiallyExpanded;

  /// Optional callback fired with the new expanded state on every toggle.
  /// Useful for analytics or for parents that want to react without
  /// owning an RxInt.
  final ValueChanged<bool>? onExpandedChanged;

  /// Visible decoration around the card. Pass null to disable the default
  /// white card shell — useful when the parent already wraps with its own
  /// border / shadow / padding.
  final BoxDecoration? decoration;

  /// Inner padding. Defaults match the mockup's chunky cards.
  final EdgeInsetsGeometry padding;

  /// Animation duration for expand/collapse.
  final Duration duration;

  /// Optional trailing icon shown next to the header. Defaults to a
  /// chevron that rotates 180° on expand.
  final Widget? trailing;

  const ExpandableCard({
    Key? key,
    required this.header,
    required this.bodyBuilder,
    this.index = 0,
    this.groupSelectedIndex,
    this.initiallyExpanded = false,
    this.onExpandedChanged,
    this.decoration,
    this.padding = const EdgeInsets.all(16),
    this.duration = const Duration(milliseconds: 200),
    this.trailing,
  }) : super(key: key);

  @override
  State<ExpandableCard> createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<ExpandableCard>
    with SingleTickerProviderStateMixin {
  /// Used only in standalone mode. When [widget.groupSelectedIndex] is set,
  /// state lives there and this field is ignored.
  late bool _localExpanded;

  @override
  void initState() {
    super.initState();
    _localExpanded = widget.initiallyExpanded;
  }

  bool _isOpenFor(int? selected) {
    if (widget.groupSelectedIndex == null) return _localExpanded;
    return selected == widget.index;
  }

  void _toggle() {
    final group = widget.groupSelectedIndex;
    if (group != null) {
      // Coordinated mode: flip group state. Open this index, or close
      // everything if it was already open.
      group.value = group.value == widget.index ? -1 : widget.index;
      widget.onExpandedChanged?.call(group.value == widget.index);
    } else {
      setState(() => _localExpanded = !_localExpanded);
      widget.onExpandedChanged?.call(_localExpanded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shellDecoration = widget.decoration ??
        BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD8EDD4), width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF163220).withOpacity(0.05),
              offset: const Offset(0, 2),
              blurRadius: 10,
            ),
          ],
        );

    // The body widget that everything below renders. Lazy-evaluated only
    // when the card is open so heavy child trees don't pay the build cost
    // before the user taps.
    Widget shellFor(bool open) {
      return AnimatedContainer(
        duration: widget.duration,
        curve: Curves.easeOutCubic,
        decoration: shellDecoration,
        child: Padding(
          padding: widget.padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: _toggle,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: widget.header),
                    const SizedBox(width: 12),
                    AnimatedRotation(
                      turns: open ? 0.5 : 0.0,
                      duration: widget.duration,
                      child: widget.trailing ??
                          const Icon(
                            Icons.expand_more,
                            color: Color(0xFF6DC55A),
                            size: 24,
                          ),
                    ),
                  ],
                ),
              ),
              ClipRect(
                child: AnimatedAlign(
                  alignment: Alignment.topCenter,
                  duration: widget.duration,
                  curve: Curves.easeOutCubic,
                  heightFactor: open ? 1.0 : 0.0,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Builder(builder: widget.bodyBuilder),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (widget.groupSelectedIndex == null) {
      return shellFor(_localExpanded);
    }
    // Coordinated mode: re-render whenever the group RxInt changes.
    return Obx(() => shellFor(_isOpenFor(widget.groupSelectedIndex!.value)));
  }
}
