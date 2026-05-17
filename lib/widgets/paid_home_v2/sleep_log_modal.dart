import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/controllers/paid_home_controller/paid_home_controller.dart';
import '../../data/models/home_dashboard/home_dashboard_model.dart';
import '../new_home/phase_theme.dart';

/// Slider-only bottom sheet for logging last night's sleep.
/// Range: 4.0h..10.0h in 0.5h steps (12 divisions, 13 tick positions).
/// Pre-fills from `initialHours` when editing; falls back to 7.0.
class SleepLogModal extends StatefulWidget {
  final double? initialHours;
  final HomeDashboardModel dashboard;

  const SleepLogModal({
    Key? key,
    required this.dashboard,
    this.initialHours,
  }) : super(key: key);

  static Future<void> show({
    required BuildContext context,
    required HomeDashboardModel dashboard,
    double? initialHours,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => SleepLogModal(
        initialHours: initialHours,
        dashboard: dashboard,
      ),
    );
  }

  @override
  State<SleepLogModal> createState() => _SleepLogModalState();
}

class _SleepLogModalState extends State<SleepLogModal> {
  static const double _minHours = 4.0;
  static const double _maxHours = 10.0;
  static const int _divisions = 12;
  static const double _defaultHours = 7.0;

  late double _selectedHours;

  @override
  void initState() {
    super.initState();
    final raw = widget.initialHours;
    if (raw != null && (raw < _minHours || raw > _maxHours)) {
      debugPrint(
          '[SleepLogModal] Clamping out-of-range initialHours: $raw');
    }
    _selectedHours = raw?.clamp(_minHours, _maxHours) ?? _defaultHours;
  }

  Future<void> _onSave() async {
    final controller = Get.find<PaidHomeController>();
    final success = await controller.logSleep(_selectedHours);
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
    final theme =
        PhaseTheme.forPhaseString(widget.dashboard.cycle?.phase);
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
          // Drag handle.
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
            'How many hours did you sleep?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF163220),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Last night',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF9AB09A),
            ),
          ),
          const SizedBox(height: 32),
          // Big number display.
          Center(
            child: Text(
              '${_selectedHours.toStringAsFixed(1)} h',
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
              value: _selectedHours,
              min: _minHours,
              max: _maxHours,
              divisions: _divisions,
              onChanged: (v) => setState(() => _selectedHours = v),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '4h',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9AB09A),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '10h',
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
                  isSaving: controller.isSavingSleep,
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
        // Controller also guards re-entry; this is defensive so rapid taps
        // don't queue up.
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
