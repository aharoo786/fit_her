import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/controllers/paid_home_controller/paid_home_controller.dart';
import '../../data/models/home_dashboard/home_dashboard_model.dart';
import '../new_home/phase_theme.dart';

/// Slider-only bottom sheet for logging this week's weight.
/// Range: 40.0..150.0 kg in 0.5 kg steps (220 divisions).
/// Pre-fills from `initialKg` (usually `dashboard.goal.currentWeightKg`).
/// Pattern mirrors SleepLogModal from B2.6.1.
class LogWeightModal extends StatefulWidget {
  final HomeDashboardModel dashboard;
  final double? initialKg;

  const LogWeightModal({
    Key? key,
    required this.dashboard,
    this.initialKg,
  }) : super(key: key);

  static Future<void> show({
    required BuildContext context,
    required HomeDashboardModel dashboard,
    double? initialKg,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => LogWeightModal(
        dashboard: dashboard,
        initialKg: initialKg,
      ),
    );
  }

  @override
  State<LogWeightModal> createState() => _LogWeightModalState();
}

class _LogWeightModalState extends State<LogWeightModal> {
  static const double _minKg = 40.0;
  static const double _maxKg = 150.0;
  static const int _divisions = 220; // 0.5 kg steps across 110 kg range
  static const double _defaultKg = 60.0;

  late double _selectedKg;

  @override
  void initState() {
    super.initState();
    final raw = widget.initialKg;
    if (raw != null && (raw < _minKg || raw > _maxKg)) {
      debugPrint('[LogWeightModal] Clamping out-of-range initialKg: $raw');
    }
    _selectedKg = raw?.clamp(_minKg, _maxKg) ?? _defaultKg;
  }

  Future<void> _onSave() async {
    final controller = Get.find<PaidHomeController>();
    final success = await controller.logWeight(_selectedKg);
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save. Try again.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = PhaseTheme.forPhaseString(widget.dashboard.cycle?.phase);
    final bottomSafe = MediaQuery.of(context).padding.bottom;
    final controller = Get.find<PaidHomeController>();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, bottomSafe + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFD8EDD4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text(
            "What's your weight today?",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF163220),
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              '${_selectedKg.toStringAsFixed(1)} kg',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w700,
                color: theme.accent,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: theme.accent,
              inactiveTrackColor: const Color(0xFFD8EDD4),
              thumbColor: theme.accent,
              overlayColor: theme.accent.withOpacity(0.20),
              trackHeight: 4,
            ),
            child: Slider(
              value: _selectedKg,
              min: _minKg,
              max: _maxKg,
              divisions: _divisions,
              onChanged: (v) => setState(() => _selectedKg = v),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '40kg',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9AB09A),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '150kg',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9AB09A),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: _CancelButton(
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SaveButton(
                  accent: theme.accent,
                  onTap: _onSave,
                  isSaving: controller.isSavingWeight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CancelButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CancelButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD8EDD4), width: 1),
        ),
        child: const Text(
          'Cancel',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF9AB09A),
          ),
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final Color accent;
  final VoidCallback onTap;
  final RxBool isSaving;

  const _SaveButton({
    required this.accent,
    required this.onTap,
    required this.isSaving,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final saving = isSaving.value;
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: saving ? null : onTap,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Save',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
        ),
      );
    });
  }
}
