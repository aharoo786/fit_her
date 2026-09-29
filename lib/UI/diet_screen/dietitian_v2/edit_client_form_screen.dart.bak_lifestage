import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/controllers/dietitian_dashboard_controller/dietitian_dashboard_controller.dart';
import '../../../widgets/toasts.dart';

/// Dietitian edits the client's pre-consultation form, usually live
/// during the consultation. Saving OVERWRITES the client's answers
/// (product decision): whatever is saved here is what the AI uses when
/// it generates the diet plan.
///
/// Opens with the raw profile map (or null when the client never filled
/// the form, in which case the dietitian fills it from scratch and the
/// backend creates the row on first save).
class EditClientFormScreen extends StatefulWidget {
  final int userId;
  final String? clientName;
  final Map<String, dynamic>? initial;

  const EditClientFormScreen({
    super.key,
    required this.userId,
    this.clientName,
    this.initial,
  });

  @override
  State<EditClientFormScreen> createState() => _EditClientFormScreenState();
}

class _Opt {
  final String value;
  final String label;
  const _Opt(this.value, this.label);
}

const _kBg = Color(0xFFE8F4E0);
const _kInk = Color(0xFF1A3A22);
const _kSoft = Color(0xFF7A8C78);
const _kAccent = Color(0xFF6DC55A);
const _kBorder = Color(0xFFC8DEC4);

class _EditClientFormScreenState extends State<EditClientFormScreen> {
  // Same option values the client-side form writes, so both sides stay
  // readable by the AI and by each other.
  static const _goals = <_Opt>[
    _Opt('weight_loss', 'Lose weight'),
    _Opt('weight_gain', 'Gain weight'),
    _Opt('maintain', 'Maintain'),
    _Opt('pcos_management', 'Manage PCOS'),
    _Opt('postpartum', 'Postpartum recovery'),
    _Opt('pregnancy_prep', 'Pregnancy prep'),
    _Opt('general_wellness', 'General wellness'),
  ];
  static const _cycle = <_Opt>[
    _Opt('regular_cycle', 'Regular cycle'),
    _Opt('irregular_cycle', 'Irregular cycle'),
    _Opt('pcos', 'PCOS'),
    _Opt('pregnant', 'Pregnant'),
    _Opt('postpartum', 'Postpartum'),
    _Opt('menopause', 'Menopause'),
    _Opt('prefer_not_to_say', 'Prefer not to say'),
  ];
  static const _diet = <_Opt>[
    _Opt('vegetarian', 'Vegetarian'),
    _Opt('halal', 'Halal'),
    _Opt('lactose_free', 'Lactose-free'),
    _Opt('gluten_free', 'Gluten-free'),
    _Opt('eggs_ok', 'Eggs OK'),
    _Opt('seafood_ok', 'Seafood OK'),
    _Opt('no_restrictions', 'No restrictions'),
  ];

  late final DietitianDashboardController _ctrl;
  String? _goal;
  String? _cycleStatus;
  final Set<String> _prefs = {};
  int _meals = 5;
  bool _saving = false;

  final _allergies = TextEditingController();
  final _medical = TextEditingController();
  final _meds = TextEditingController();
  final _fasting = TextEditingController();
  final _surgeries = TextEditingController();
  final _family = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<DietitianDashboardController>();
    final m = widget.initial ?? const {};
    _goal = m['goals'] as String?;
    _cycleStatus = m['pregnancyMenstrualStatus'] as String?;
    final prefs = m['dietaryPreferences'];
    if (prefs is List) _prefs.addAll(prefs.map((e) => e.toString()));
    final meals = int.tryParse('${m['mealsPerDay'] ?? ''}');
    if (meals != null && meals >= 3 && meals <= 6) _meals = meals;
    _allergies.text = (m['allergies'] ?? '').toString();
    _medical.text = (m['medicalConditions'] ?? '').toString();
    _meds.text = (m['currentMedications'] ?? '').toString();
    _fasting.text = (m['fastingHabits'] ?? '').toString();
    _surgeries.text = (m['surgeries'] ?? '').toString();
    _family.text = (m['familyHistory'] ?? '').toString();
  }

  @override
  void dispose() {
    for (final c in [_allergies, _medical, _meds, _fasting, _surgeries, _family]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final ok = await _ctrl.patchClientProfile(
      userId: widget.userId,
      body: {
        'goals': _goal,
        'pregnancyMenstrualStatus': _cycleStatus,
        'dietaryPreferences': _prefs.toList(),
        'mealsPerDay': _meals,
        'allergies': _allergies.text.trim(),
        'medicalConditions': _medical.text.trim(),
        'currentMedications': _meds.text.trim(),
        'fastingHabits': _fasting.text.trim(),
        'surgeries': _surgeries.text.trim(),
        'familyHistory': _family.text.trim(),
      },
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      CustomToast.successToast(msg: 'Form updated');
      Get.back<bool>(result: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: _kInk),
        title: Text(
          widget.clientName == null ? 'Edit form' : "${widget.clientName}'s form",
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _kInk,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          const Text(
            'Your changes replace what the client entered. The AI plan is built from this form.',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: _kSoft),
          ),
          const SizedBox(height: 16),
          _label('Goal'),
          _chips(_goals, (v) => _goal == v, (v) => setState(() => _goal = v)),
          _label('Cycle / reproductive status'),
          _chips(_cycle, (v) => _cycleStatus == v,
              (v) => setState(() => _cycleStatus = v)),
          _label('Dietary preferences'),
          _chips(_diet, (v) => _prefs.contains(v), (v) {
            setState(() {
              if (!_prefs.remove(v)) _prefs.add(v);
            });
          }),
          _label('Meals per day'),
          _chips(
            const [_Opt('3', '3'), _Opt('4', '4'), _Opt('5', '5'), _Opt('6', '6')],
            (v) => '$_meals' == v,
            (v) => setState(() => _meals = int.parse(v)),
          ),
          _label('Allergies'),
          _field(_allergies, 'e.g. peanuts, shellfish'),
          _label('Medical conditions'),
          _field(_medical, 'e.g. PCOS, hypothyroid, diabetes'),
          _label('Current medications'),
          _field(_meds, 'e.g. Metformin 500mg'),
          _label('Fasting habits'),
          _field(_fasting, 'e.g. fasts Mondays and Thursdays'),
          _label('Past surgeries'),
          _field(_surgeries, 'Optional'),
          _label('Family history'),
          _field(_family, 'Optional'),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Save form',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 8),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _kInk,
          ),
        ),
      );

  Widget _chips(
    List<_Opt> opts,
    bool Function(String) isOn,
    void Function(String) onTap,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: opts.map((o) {
        final on = isOn(o.value);
        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => onTap(o.value),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: on ? _kInk : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: on ? _kInk : _kBorder),
            ),
            child: Text(
              o.label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: on ? Colors.white : _kInk,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _field(TextEditingController c, String hint) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: _kBorder),
    );
    return TextField(
      controller: c,
      minLines: 1,
      maxLines: 4,
      style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: _kInk),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
            fontFamily: 'Poppins', fontSize: 13, color: Color(0xFF9AB09A)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: _kAccent, width: 1.5),
        ),
      ),
    );
  }
}
