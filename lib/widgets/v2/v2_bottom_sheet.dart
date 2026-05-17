import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// V2BottomSheet — shared shell for every paid-user pop-up (Phase 2C).
/// Mirrors the V2 visual language used in `paid_home_v2/`: mint page
/// bg `#E8F4E0`, 25-radius top corners, dark `#0D2014` text colour, soft
/// drag handle, optional close button.
///
/// Use the static `show<T>()` helper instead of constructing directly:
///
///   final result = await V2BottomSheet.show<bool>(
///     title: 'Day 7 review',
///     child: const Day7ReviewBody(),
///     dismissible: false, // mandatory popups can pass false
///   );
///
/// `dismissible=false` blocks tap-outside / swipe-down dismissal — used
/// for the mandatory Day 15/30 progress submission (build plan risk #5,
/// soft-block default — popup persists until submitted).
class V2BottomSheet extends StatelessWidget {
  final String? title;
  final Widget child;
  final bool dismissible;

  static const Color _bg = Color(0xFFFFFFFF);
  static const Color _drag = Color(0xFFC8DEC4);
  static const Color _textDark = Color(0xFF1A3A22);
  static const Color _textMuted = Color(0xFF7A8C78);
  static const BorderRadius _topRadius = BorderRadius.only(
    topLeft: Radius.circular(25),
    topRight: Radius.circular(25),
  );

  const V2BottomSheet({
    Key? key,
    this.title,
    required this.child,
    this.dismissible = true,
  }) : super(key: key);

  /// Helper that wraps `Get.bottomSheet` with the V2 shell. Returns
  /// whatever the body popped via `Get.back(result: ...)`.
  static Future<T?> show<T>({
    String? title,
    required Widget child,
    bool dismissible = true,
  }) {
    return Get.bottomSheet<T>(
      V2BottomSheet(
        title: title,
        dismissible: dismissible,
        child: child,
      ),
      isScrollControlled: true,
      isDismissible: dismissible,
      enableDrag: dismissible,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: viewInsets),
        child: Container(
          decoration: const BoxDecoration(
            color: _bg,
            borderRadius: _topRadius,
            boxShadow: [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 24,
                offset: Offset(0, -4),
              ),
            ],
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.92,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle (only visible when dismissible — mandatory
              // popups have no pull-down affordance).
              if (dismissible)
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 6),
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _drag,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                )
              else
                const SizedBox(height: 16),

              // Title row + close button.
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 8, 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: title != null
                          ? Text(
                              title!,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: _textDark,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            )
                          : const SizedBox.shrink(),
                    ),
                    if (dismissible)
                      IconButton(
                        icon: const Icon(Icons.close, size: 22, color: _textMuted),
                        onPressed: () => Get.back<dynamic>(),
                      )
                    else
                      const SizedBox(width: 8, height: 44),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
