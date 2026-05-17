import 'package:flutter/material.dart';

/// V2 button family. Drop-in replacements for legacy CustomButton on V2
/// surfaces — colors and radius match `PaidHomeScreenV2` accent style.
/// Three variants: Primary (filled accent), Secondary (outline), Ghost
/// (text-only with hairline divider above for sheet "Skip" actions).

const Color _v2Accent = Color(0xFF6DC55A); // V2 brand green
const Color _v2AccentDark = Color(0xFF0D2014); // hero/dark CTA bg
const Color _v2TextOnAccent = Color(0xFFFFFFFF);
const Color _v2OutlineBorder = Color(0xFF1A3A22);
const Color _v2OutlineLabel = Color(0xFF1A3A22);
const Color _v2GhostLabel = Color(0xFF7A8C78);

class V2PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final bool fullWidth;
  final IconData? leadingIcon;

  const V2PrimaryButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.busy = false,
    this.fullWidth = true,
    this.leadingIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || busy;
    final btn = Opacity(
      opacity: disabled && !busy ? 0.5 : 1.0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: disabled ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: _v2Accent,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _v2Accent.withOpacity(0.28),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(_v2TextOnAccent),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (leadingIcon != null) ...[
                          Icon(leadingIcon, size: 18, color: _v2TextOnAccent),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          label,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _v2TextOnAccent,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
    return fullWidth ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}

class V2SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool fullWidth;

  const V2SecondaryButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.fullWidth = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final btn = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _v2OutlineBorder, width: 1.2),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _v2OutlineLabel,
            ),
          ),
        ),
      ),
    );
    return fullWidth ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}

/// "Skip for now", "Maybe later" style — no border, muted label.
class V2GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool fullWidth;

  const V2GhostButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.fullWidth = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final btn = TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: _v2GhostLabel,
        ),
      ),
    );
    return fullWidth ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}

/// Dark-on-dark CTA used inside the LIVE hero block (not common on
/// pop-ups, but exposed for completeness so future surfaces don't have
/// to reinvent it).
class V2DarkCtaButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const V2DarkCtaButton({
    Key? key,
    required this.label,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: _v2AccentDark,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _v2TextOnAccent,
            ),
          ),
        ),
      ),
    );
  }
}
