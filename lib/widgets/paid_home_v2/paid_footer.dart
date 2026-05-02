import 'package:flutter/material.dart';

import '../../data/models/home_dashboard/home_dashboard_model.dart';

/// Centered social-proof footer.
///
/// Two render modes, mirroring the `footer(text)` helper from the H-44
/// reference HTML:
///
/// 1. Default (count-based): "**N women** joined a class today" — bold
///    dark count + muted suffix. Hides when count is null/zero so we
///    never show "0 women joined a class today".
/// 2. Override: caller passes [overrideText]; the entire string renders
///    in the muted style with no count math and no bold span. Used for
///    status messages or future market-specific copy.
class PaidFooter extends StatelessWidget {
  final HomeDashboardModel dashboard;
  final String? overrideText;

  const PaidFooter({
    Key? key,
    required this.dashboard,
    this.overrideText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (overrideText != null) {
      return _shell(
        Text(
          overrideText!,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: Color(0xFF9AB09A),
          ),
        ),
      );
    }

    final count = dashboard.social?.womenJoinedToday;
    if (count == null || count <= 0) return const SizedBox.shrink();

    return _shell(
      Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$count women',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF163220),
              ),
            ),
            const TextSpan(
              text: ' joined a class today',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: Color(0xFF9AB09A),
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _shell(Widget child) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 22),
      child: Center(child: child),
    );
  }
}
