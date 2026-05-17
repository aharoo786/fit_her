import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Numeric input used by progress submission (weight, waist, hip, etc).
/// Single-decimal precision, optional unit suffix, fixed 64h pill style.
/// `previousValue` is rendered below as ghost text so the user can see
/// trend ("Last: 62.4 kg") — Section 9 frictionless touch.
class MeasurementInput extends StatelessWidget {
  final String label;
  final String unit; // "kg" or "cm"
  final TextEditingController controller;
  final double? previousValue;
  final FocusNode? focusNode;

  static const Color _bg = Color(0xFFF5FDF2);
  static const Color _border = Color(0xFFC8DEC4);
  static const Color _label = Color(0xFF7A8C78);
  static const Color _value = Color(0xFF1A3A22);
  static const Color _previous = Color(0xFF9AB09A);

  const MeasurementInput({
    Key? key,
    required this.label,
    required this.unit,
    required this.controller,
    this.previousValue,
    this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _label,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}')),
                  ],
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    hintText: '—',
                    hintStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      color: _previous,
                    ),
                  ),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _value,
                  ),
                ),
              ),
              Text(
                unit,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _label,
                ),
              ),
            ],
          ),
        ),
        if (previousValue != null) ...[
          const SizedBox(height: 4),
          Text(
            'Last: ${previousValue!.toStringAsFixed(1)} $unit',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              color: _previous,
            ),
          ),
        ],
      ],
    );
  }
}
