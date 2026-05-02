import 'package:flutter/material.dart';

class LockedInsightCard extends StatelessWidget {
  const LockedInsightCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD8EDD4), width: 1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "🔒 FITHER AI · TODAY'S INSIGHT",
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Color(0xFF9AB09A),
              letterSpacing: 0.63,
            ),
          ),
          SizedBox(height: 6),
          Opacity(
            opacity: 0.55,
            child: Text(
              'Recovery is 40% faster in your follicular phase — push today, rest smart this weekend for...',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF4A6B4A),
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Unlock insight →',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6DC55A),
            ),
          ),
        ],
      ),
    );
  }
}
