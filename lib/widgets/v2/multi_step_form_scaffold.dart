import 'package:flutter/material.dart';
import 'v2_buttons.dart';

/// Scaffold for the pre-consultation form (Phase 2C, popup #2). Header
/// shows progress dots; footer shows Back / Next (or Submit on last
/// step). Auto-save lives in the parent — this widget only emits the
/// `onNext` / `onBack` callbacks.
///
/// Keep state outside: each step is a separate widget passed in via
/// `body`. Parent decides what `body` to render based on `currentStep`.
class MultiStepFormScaffold extends StatelessWidget {
  final String title;
  final int currentStep; // 0-indexed
  final int totalSteps;
  final Widget body;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final VoidCallback? onSubmit;
  final bool nextEnabled;
  final bool busy;
  final String? skipLabel; // e.g. "Skip for now" on optional steps
  final VoidCallback? onSkip;

  static const Color _activeDot = Color(0xFF6DC55A);
  static const Color _inactiveDot = Color(0xFFC8DEC4);
  static const Color _title = Color(0xFF1A3A22);
  static const Color _subtitle = Color(0xFF7A8C78);

  const MultiStepFormScaffold({
    Key? key,
    required this.title,
    required this.currentStep,
    required this.totalSteps,
    required this.body,
    this.onBack,
    this.onNext,
    this.onSubmit,
    this.nextEnabled = true,
    this.busy = false,
    this.skipLabel,
    this.onSkip,
  }) : super(key: key);

  bool get _isLastStep => currentStep >= totalSteps - 1;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title + step counter.
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _title,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            Text(
              'Step ${currentStep + 1} of $totalSteps',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _subtitle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Progress dots.
        Row(
          children: List.generate(totalSteps, (i) {
            final active = i <= currentStep;
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i == totalSteps - 1 ? 0 : 6),
                height: 6,
                decoration: BoxDecoration(
                  color: active ? _activeDot : _inactiveDot,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 24),

        // Body content for the current step.
        body,

        const SizedBox(height: 24),

        // Footer row.
        Row(
          children: [
            if (onBack != null && currentStep > 0) ...[
              Expanded(
                child: V2SecondaryButton(
                  label: 'Back',
                  onPressed: busy ? null : onBack,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: 2,
              child: V2PrimaryButton(
                label: _isLastStep ? 'Submit' : 'Next',
                busy: busy,
                onPressed: !nextEnabled
                    ? null
                    : (_isLastStep ? onSubmit : onNext),
              ),
            ),
          ],
        ),

        if (skipLabel != null && onSkip != null) ...[
          const SizedBox(height: 8),
          V2GhostButton(label: skipLabel!, onPressed: busy ? null : onSkip),
        ],
      ],
    );
  }
}
