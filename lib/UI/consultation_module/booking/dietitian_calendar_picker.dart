import 'package:flutter/material.dart';

import '../../../data/models/consultation/dietitian_availability.dart';

/// Two-row picker: horizontal date strip on top, slot pills below.
/// Reused by both initial + followup booking sheets via
/// [BookConsultationSheet]. Pure presentation — parent owns selection
/// state and the network fetch.
class DietitianCalendarPicker extends StatelessWidget {
  final List<DietitianAvailabilitySlot> slots; // already sorted by date
  final DietitianAvailabilitySlot? selected;
  final ValueChanged<DietitianAvailabilitySlot> onSelect;

  static const Color _textDark = Color(0xFF1A3A22);
  static const Color _textMuted = Color(0xFF7A8C78);

  const DietitianCalendarPicker({
    Key? key,
    required this.slots,
    required this.selected,
    required this.onSelect,
  }) : super(key: key);

  /// Returns the dates that have at least one available slot. Used to
  /// build the horizontal date strip — empty days hide entirely.
  List<String> _availableDates() {
    final byDate = <String, bool>{};
    for (final s in slots) {
      if (!byDate.containsKey(s.date)) byDate[s.date] = false;
      if (s.available) byDate[s.date] = true;
    }
    final dates = byDate.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    dates.sort();
    return dates;
  }

  /// Slots for the currently selected date. Mixed available/unavailable
  /// so the user sees the full picture and can compare.
  List<DietitianAvailabilitySlot> _slotsForDate(String date) {
    return slots.where((s) => s.date == date).toList()
      ..sort((a, b) => (a.start ?? '').compareTo(b.start ?? ''));
  }

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(
            'No availability in the next 2 weeks',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: _textMuted,
            ),
          ),
        ),
      );
    }

    final dates = _availableDates();
    if (dates.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(
            'All slots are booked. Try again later.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: _textMuted,
            ),
          ),
        ),
      );
    }

    final activeDate = selected?.date ?? dates.first;
    final daySlots = _slotsForDate(activeDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Pick a day',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _textDark,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 64,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final d = dates[i];
              final dt = DateTime.tryParse(d) ?? DateTime.now();
              final isActive = d == activeDate;
              return _DatePill(
                weekday: _shortWeekday(dt),
                day: dt.day.toString(),
                active: isActive,
                onTap: () {
                  // Selecting a date clears the slot selection so the
                  // user must pick a fresh slot for the new day.
                  final firstAvail = _slotsForDate(d)
                      .firstWhere(
                          (s) => s.available,
                          orElse: () => _slotsForDate(d).first);
                  onSelect(firstAvail);
                },
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Available slots',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _textDark,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: daySlots.map((s) {
            final isSelected = selected?.slotDietId == s.slotDietId &&
                selected?.date == s.date;
            return _SlotPill(
              label: s.start ?? '—',
              available: s.available,
              selected: isSelected,
              onTap: s.available ? () => onSelect(s) : null,
            );
          }).toList(),
        ),
      ],
    );
  }

  static const _weekdayShort = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];
  static String _shortWeekday(DateTime dt) =>
      _weekdayShort[(dt.weekday - 1).clamp(0, 6)];
}

class _DatePill extends StatelessWidget {
  final String weekday;
  final String day;
  final bool active;
  final VoidCallback onTap;

  const _DatePill({
    required this.weekday,
    required this.day,
    required this.active,
    required this.onTap,
  });

  static const Color _bgDark = Color(0xFF0D2014);
  static const Color _bg = Color(0xFFF5FDF2);
  static const Color _accent = Color(0xFF6DC55A);
  static const Color _label = Color(0xFF1A3A22);
  static const Color _muted = Color(0xFF7A8C78);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        decoration: BoxDecoration(
          color: active ? _bgDark : _bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? _bgDark : const Color(0xFFC8DEC4),
          ),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              weekday,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: active ? _accent : _muted,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              day,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: active ? Colors.white : _label,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlotPill extends StatelessWidget {
  final String label;
  final bool available;
  final bool selected;
  final VoidCallback? onTap;

  const _SlotPill({
    required this.label,
    required this.available,
    required this.selected,
    required this.onTap,
  });

  static const Color _accent = Color(0xFF6DC55A);
  static const Color _accentBg = Color(0xFFE4F9D7);
  static const Color _label = Color(0xFF1A3A22);
  static const Color _muted = Color(0xFF9AB09A);
  static const Color _disabled = Color(0xFFEDEDED);

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? _accentBg
        : available
            ? Colors.white
            : _disabled;
    final fg = selected
        ? const Color(0xFF1A3A22)
        : available
            ? _label
            : _muted;
    final border = selected
        ? _accent
        : available
            ? const Color(0xFFC8DEC4)
            : Colors.transparent;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: border, width: selected ? 1.5 : 1),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: fg,
              decoration: !available
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }
}
