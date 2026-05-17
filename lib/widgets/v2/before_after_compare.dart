import 'dart:io';
import 'package:flutter/material.dart';

/// Drag-slider comparison of two device-local photo files. Used inside
/// the Progress submission flow's review screen so the user can see
/// their own Day 0 vs Day 30 side-by-side. Photos NEVER leave the
/// device — Section 10. The widget only reads File paths and renders
/// `Image.file`.
///
///   BeforeAfterCompare(beforePath: '...', afterPath: '...')
class BeforeAfterCompare extends StatefulWidget {
  final String beforePath;
  final String afterPath;
  final double aspectRatio;

  const BeforeAfterCompare({
    Key? key,
    required this.beforePath,
    required this.afterPath,
    this.aspectRatio = 3 / 4,
  }) : super(key: key);

  @override
  State<BeforeAfterCompare> createState() => _BeforeAfterCompareState();
}

class _BeforeAfterCompareState extends State<BeforeAfterCompare> {
  double _split = 0.5; // 0..1 — fraction of width showing "before"

  static const Color _handle = Color(0xFFFFFFFF);
  static const Color _handleStroke = Color(0xFF1A3A22);
  static const Color _label = Color(0xFFFFFFFF);
  static const Color _labelBg = Color(0x991A3A22);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            return Stack(
              children: [
                // After (full width, behind).
                Positioned.fill(
                  child: Image.file(
                    File(widget.afterPath),
                    fit: BoxFit.cover,
                  ),
                ),
                // Before (clipped to left portion).
                Positioned.fill(
                  child: ClipRect(
                    clipper: _LeftClipper(_split),
                    child: Image.file(
                      File(widget.beforePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Labels.
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: _label_pill('Before'),
                ),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: _label_pill('After'),
                ),
                // Drag handle.
                Positioned(
                  left: w * _split - 18,
                  top: 0,
                  bottom: 0,
                  width: 36,
                  child: GestureDetector(
                    onHorizontalDragUpdate: (d) {
                      setState(() {
                        _split = (_split + d.delta.dx / w).clamp(0.05, 0.95);
                      });
                    },
                    child: Center(
                      child: Container(
                        width: 4,
                        decoration: const BoxDecoration(color: _handle),
                        child: Center(
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _handle,
                              border: Border.all(color: _handleStroke, width: 1.5),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x33000000),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.compare_arrows_rounded,
                              size: 18,
                              color: _handleStroke,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget _label_pill(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: _labelBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: _label,
            letterSpacing: 0.4,
          ),
        ),
      );
}

class _LeftClipper extends CustomClipper<Rect> {
  final double split;
  _LeftClipper(this.split);
  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, size.width * split, size.height);
  @override
  bool shouldReclip(_LeftClipper oldClipper) => oldClipper.split != split;
}
