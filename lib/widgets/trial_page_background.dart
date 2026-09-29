import 'package:flutter/material.dart';

/// White page with the same two soft green circles as the signup screens
/// (OnboardingScaffold), so signup and the whole free trial journey look
/// like one flow. Wrap a Scaffold that has a transparent background.
class TrialPageBackground extends StatelessWidget {
  final Widget child;
  const TrialPageBackground({Key? key, required this.child}) : super(key: key);

  static const Color _circle = Color(0xFFEAF7E4);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -70,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _circle.withOpacity(0.5),
              ),
            ),
          ),
          Positioned(
            bottom: 140,
            left: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _circle.withOpacity(0.3),
              ),
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}
