import 'package:flutter/material.dart';

class CommunityFooter extends StatelessWidget {
  const CommunityFooter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 4, bottom: 22),
      child: Text.rich(
        TextSpan(
          style: TextStyle(fontSize: 11, color: Color(0xFF9AB09A)),
          children: [
            TextSpan(
              text: '2,400 women',
              style: TextStyle(
                color: Color(0xFF163220),
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(text: ' are training on FitHer this week'),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
