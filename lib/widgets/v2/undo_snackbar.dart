import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 5-second undo snackbar shown after every meal-log save (Section 6.5).
/// Uses GetX SnackPosition.BOTTOM so the surface is consistent with the
/// app's existing toast pattern (`CustomToast`). Tapping "UNDO" inside
/// the window triggers the caller's revert callback; otherwise the
/// snackbar dismisses silently after 5s.
///
///   showUndoSnackbar(
///     message: 'Breakfast logged as Followed',
///     onUndo: () => mealLogController.undoLast(),
///   );
void showUndoSnackbar({
  required String message,
  required VoidCallback onUndo,
  Duration duration = const Duration(seconds: 5),
}) {
  // Hide any in-flight snackbar so a rapid sequence of taps doesn't
  // queue 5 of them.
  if (Get.isSnackbarOpen) {
    Get.closeAllSnackbars();
  }

  Get.snackbar(
    '',
    '',
    titleText: const SizedBox.shrink(),
    messageText: Row(
      children: [
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TextButton(
          onPressed: () {
            Get.closeAllSnackbars();
            onUndo();
          },
          style: TextButton.styleFrom(
            minimumSize: const Size(0, 32),
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          child: const Text(
            'UNDO',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFFFAC775), // amber accent — pops on dark bg
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    ),
    backgroundColor: const Color(0xFF1A3A22),
    snackPosition: SnackPosition.BOTTOM,
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
    borderRadius: 14,
    duration: duration,
    isDismissible: true,
    forwardAnimationCurve: Curves.easeOutQuint,
    reverseAnimationCurve: Curves.easeInQuint,
  );
}
