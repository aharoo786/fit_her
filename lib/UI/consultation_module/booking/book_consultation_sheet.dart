import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/controllers/consultation_controller/consultation_controller.dart';
import '../../../data/models/consultation/dietitian_availability.dart';
import '../../../widgets/toasts.dart';
import '../../../widgets/v2/v2_bottom_sheet.dart';
import '../../../widgets/v2/v2_buttons.dart';
import 'dietitian_calendar_picker.dart';

/// Reused by:
///   • POPUP_BOOK_INITIAL_CONSULTATION   (kind = "initial")
///   • POPUP_BOOK_FOLLOWUP_CONSULTATION  (kind = "followup")
///
/// Caller threads in the dietitian + user IDs (the user's assigned
/// dietitian comes from the plan; user comes from auth). Sheet is the
/// only place that knows about the calendar picker.
class BookConsultationSheet extends StatefulWidget {
  /// Variable used for popup-state ack (dismiss / complete).
  final String popupVariable;

  /// Booking inputs threaded by the caller.
  final int dietitianId;
  final String? dietitianName;
  final int userId;
  final int userPlanId;
  final String kind; // "initial" | "followup"

  const BookConsultationSheet({
    Key? key,
    required this.popupVariable,
    required this.dietitianId,
    required this.userId,
    required this.userPlanId,
    required this.kind,
    this.dietitianName,
  }) : super(key: key);

  static Future<void> show({
    required String popupVariable,
    required int dietitianId,
    String? dietitianName,
    required int userId,
    required int userPlanId,
    required String kind,
  }) {
    return V2BottomSheet.show(
      title: kind == 'initial'
          ? 'Book your first consultation'
          : 'Book your follow-up',
      child: BookConsultationSheet(
        popupVariable: popupVariable,
        dietitianId: dietitianId,
        dietitianName: dietitianName,
        userId: userId,
        userPlanId: userPlanId,
        kind: kind,
      ),
    );
  }

  @override
  State<BookConsultationSheet> createState() => _BookConsultationSheetState();
}

class _BookConsultationSheetState extends State<BookConsultationSheet> {
  late final ConsultationController _ctrl;
  bool _loading = true;
  bool _booking = false;
  DietitianAvailability? _availability;
  DietitianAvailabilitySlot? _selected;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<ConsultationController>();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await _ctrl.loadAvailability(dietitianId: widget.dietitianId);
    if (!mounted) return;
    setState(() {
      _availability = data;
      _loading = false;
      // Auto-select the first available slot so the CTA isn't disabled
      // on first paint — user can change with one tap.
      if (data != null) {
        _selected = data.slots.firstWhereOrNull((s) => s.available);
      }
    });
  }

  Future<void> _book() async {
    final s = _selected;
    if (s == null) return;
    setState(() => _booking = true);
    final ok = await _ctrl.bookConsultation(
      date: s.date,
      userId: widget.userId,
      dietitianId: widget.dietitianId,
      timeSlotId: s.slotDietId ?? 0,
      userPlanId: widget.userPlanId,
      kind: widget.kind,
    );
    if (!mounted) return;
    setState(() => _booking = false);
    if (ok) {
      // Retire the popup — backend already wrote the appointment, but
      // we want the popup row marked completed so eligibility stops
      // surfacing it.
      await _ctrl.completePopup(widget.popupVariable, metadata: {
        'date': s.date,
        'slotDietId': s.slotDietId,
      });
      Get.back<dynamic>();
      CustomToast.successToast(msg: 'Booked. See you on ${s.date} at ${s.start}.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 240,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6DC55A)),
          ),
        ),
      );
    }
    if (_availability == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text(
              "Couldn't load availability. Tap retry.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: Color(0xFF7A8C78),
              ),
            ),
          ),
          V2SecondaryButton(label: 'Retry', onPressed: _load),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.dietitianName != null && widget.dietitianName!.isNotEmpty) ...[
          Text(
            'with ${widget.dietitianName}',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF7A8C78),
            ),
          ),
          const SizedBox(height: 12),
        ],
        DietitianCalendarPicker(
          slots: _availability!.slots,
          selected: _selected,
          onSelect: (s) => setState(() => _selected = s),
        ),
        const SizedBox(height: 20),
        V2PrimaryButton(
          label: _selected == null
              ? 'Pick a slot'
              : 'Book ${_selected!.start ?? ''} on ${_selected!.date}',
          busy: _booking,
          onPressed: _selected == null || !_selected!.available ? null : _book,
        ),
        const SizedBox(height: 8),
        V2GhostButton(
          label: 'Maybe later',
          onPressed: _booking
              ? null
              : () {
                  _ctrl.dismissPopup(widget.popupVariable);
                  Get.back<dynamic>();
                },
        ),
      ],
    );
  }
}
