import 'package:flutter/material.dart';

class LockedStatsGrid extends StatelessWidget {
  const LockedStatsGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Opacity(
        opacity: 0.45,
        child: Row(
          children: const [
            Expanded(child: _LockedTile(label: '💧 Water')),
            SizedBox(width: 8),
            Expanded(child: _LockedTile(label: '🌙 Sleep')),
          ],
        ),
      ),
    );
  }
}

class _LockedTile extends StatelessWidget {
  final String label;
  const _LockedTile({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD8EDD4), width: 1),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF163220).withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF9AB09A),
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            '🔒',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
