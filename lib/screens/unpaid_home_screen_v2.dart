import 'package:flutter/material.dart';

/// Stub for the new unpaid home screen. Real implementation follows later —
/// for now this only proves the router branch works when
/// `logInUser.useNewUnpaidHome == true`.
class UnpaidHomeScreenV2 extends StatelessWidget {
  const UnpaidHomeScreenV2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF163220),
      body: const Center(
        child: Text(
          'New Unpaid Home Coming Soon',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
