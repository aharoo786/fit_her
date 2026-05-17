import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/controllers/meal_log_controller/meal_log_controller.dart';
import '../../../data/models/meal_log/meal_log.dart';
import '../../../widgets/v2/meal_status_chip.dart';
import 'meal_log_options_sheet.dart';

/// `POPUP_MEAL_EDIT_HISTORY` — opened from the calendar icon on the
/// meal log home tile. Last 7 days are tappable (open the options
/// sheet); older are read-only display rows.
class MealEditHistoryScreen extends StatefulWidget {
  const MealEditHistoryScreen({Key? key}) : super(key: key);

  @override
  State<MealEditHistoryScreen> createState() =>
      _MealEditHistoryScreenState();
}

class _MealEditHistoryScreenState extends State<MealEditHistoryScreen> {
  late final MealLogController _ctrl;
  bool _loading = true;
  Map<String, Map<MealType, MealLog>> _byDate = {};

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<MealLogController>();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final logs = await _ctrl.loadHistory();
    if (!mounted) return;
    final grouped = <String, Map<MealType, MealLog>>{};
    for (final m in logs) {
      grouped.putIfAbsent(m.date, () => {});
      grouped[m.date]![m.mealType] = m;
    }
    setState(() {
      _byDate = grouped;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dates = _byDate.keys.toList()..sort((a, b) => b.compareTo(a));
    return Scaffold(
      backgroundColor: const Color(0xFFE8F4E0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1A3A22)),
          onPressed: () => Get.back<dynamic>(),
        ),
        title: const Text(
          'Meal log history',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A3A22),
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6DC55A)),
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              color: const Color(0xFF6DC55A),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: dates.length,
                itemBuilder: (context, i) {
                  final date = dates[i];
                  final meals = _byDate[date]!;
                  // If any meal exists for this date, the editable flag
                  // already reflects the 7-day window server-side.
                  final anyEditable = meals.values.any((m) => m.editable);
                  return _DateGroup(
                    date: date,
                    editable: anyEditable,
                    meals: meals,
                    onTapMeal: (m) async {
                      if (!m.editable) return;
                      await MealLogOptionsSheet.show(meal: m);
                      // Re-pull after user returns — they may have
                      // edited an entry.
                      await _load();
                    },
                  );
                },
              ),
            ),
    );
  }
}

class _DateGroup extends StatelessWidget {
  final String date;
  final bool editable;
  final Map<MealType, MealLog> meals;
  final ValueChanged<MealLog> onTapMeal;

  const _DateGroup({
    required this.date,
    required this.editable,
    required this.meals,
    required this.onTapMeal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _prettyDate(date),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A3A22),
                  ),
                ),
              ),
              if (!editable)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEEEE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Read-only',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF7A8C78),
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ...MealType.values.map((t) {
            final m = meals[t];
            if (m == null) {
              // No row in DB for this meal slot on that date.
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: _MealHistoryRow(
                meal: m,
                onTap: () => onTapMeal(m),
              ),
            );
          }),
        ],
      ),
    );
  }

  static String _prettyDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return iso;
    }
  }
}

class _MealHistoryRow extends StatelessWidget {
  final MealLog meal;
  final VoidCallback onTap;
  const _MealHistoryRow({required this.meal, required this.onTap});

  static String _label(MealType t) {
    switch (t) {
      case MealType.breakfast: return 'Breakfast';
      case MealType.lunch: return 'Lunch';
      case MealType.dinner: return 'Dinner';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: meal.editable ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _label(meal.mealType),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: meal.editable
                        ? const Color(0xFF1A3A22)
                        : const Color(0xFF7A8C78),
                  ),
                ),
              ),
              MealStatusChip(status: meal.status),
              if (meal.editable)
                const Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: Color(0xFF7A8C78),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
