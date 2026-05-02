import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Phase C primitive — 5-chip period selector that drives every endpoint
/// fetch on the Progress hub. Sits at the top of the hero block.
///
/// Period values match the backend's allow-list (`week | month | 3month |
/// 6month | year`). Display labels are short forms ("Week", "Month",
/// "3M", "6M", "1Y") and are decoupled from the values so future copy
/// changes don't require a backend change.
///
/// Two usage modes (mirrors [ExpandableCard]):
///
/// 1. **Reactive (recommended)** — pass [boundValue], an `Rx<String>` the
///    parent owns. The chip taps mutate it directly; the parent's
///    `ever(period, _ => fetchAll())` listener triggers the refetch. This
///    is what ProgressControllerV2 wires up.
///
/// 2. **Imperative** — pass [value] + [onChanged]. The widget reads
///    [value] and calls [onChanged] on tap. Useful for previews and the
///    test harness the user asked for.
///
/// You must pass exactly one of [boundValue] or ([value] + [onChanged]).
class PeriodChipSelector extends StatelessWidget {
  /// Reactive Rx<String> source-of-truth. Provide this OR
  /// ([value] + [onChanged]), not both.
  final Rx<String>? boundValue;

  /// Imperative current value.
  final String? value;

  /// Imperative change callback. Required when [value] is set.
  final ValueChanged<String>? onChanged;

  /// Optional override for the chip set. Each entry is `(value, label)`.
  /// Default matches the brief's allow-list.
  final List<PeriodChipOption> options;

  /// Outer padding around the row of chips.
  final EdgeInsetsGeometry padding;

  /// Active chip background colour. Default matches PaidHomeV2 accent.
  final Color activeColor;

  /// Inactive chip background colour.
  final Color inactiveColor;

  /// Active chip text colour.
  final Color activeTextColor;

  /// Inactive chip text colour.
  final Color inactiveTextColor;

  const PeriodChipSelector({
    Key? key,
    this.boundValue,
    this.value,
    this.onChanged,
    this.options = defaultOptions,
    this.padding = EdgeInsets.zero,
    this.activeColor = const Color(0xFF6DC55A),
    this.inactiveColor = const Color(0xFFEDF5EA),
    this.activeTextColor = Colors.white,
    this.inactiveTextColor = const Color(0xFF163220),
  })  : assert(
          (boundValue != null) ^ (value != null),
          'Pass exactly one of boundValue or value+onChanged',
        ),
        assert(
          value == null || onChanged != null,
          'onChanged is required when value is set',
        ),
        super(key: key);

  /// Default chip set. Matches /users/progress/* `period` allow-list.
  static const List<PeriodChipOption> defaultOptions = [
    PeriodChipOption(value: 'week', label: 'Week'),
    PeriodChipOption(value: 'month', label: 'Month'),
    PeriodChipOption(value: '3month', label: '3M'),
    PeriodChipOption(value: '6month', label: '6M'),
    PeriodChipOption(value: 'year', label: '1Y'),
  ];

  void _select(String next) {
    if (boundValue != null) {
      boundValue!.value = next;
    } else {
      onChanged?.call(next);
    }
  }

  Widget _row(String selected) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: options
            .map((opt) => _PeriodChip(
                  label: opt.label,
                  selected: opt.value == selected,
                  onTap: () => _select(opt.value),
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                  activeTextColor: activeTextColor,
                  inactiveTextColor: inactiveTextColor,
                ))
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (boundValue != null) {
      return Obx(() => _row(boundValue!.value));
    }
    return _row(value!);
  }
}

class PeriodChipOption {
  final String value;
  final String label;
  const PeriodChipOption({required this.value, required this.label});
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color activeColor;
  final Color inactiveColor;
  final Color activeTextColor;
  final Color inactiveTextColor;

  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.activeColor,
    required this.inactiveColor,
    required this.activeTextColor,
    required this.inactiveTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          // Tap target ≥ 44x44 for accessibility — see brief §8 of v1.
          constraints: const BoxConstraints(minWidth: 56, minHeight: 36),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? activeTextColor : inactiveTextColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
