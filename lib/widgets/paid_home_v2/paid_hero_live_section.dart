import 'package:flutter/material.dart';

import '../../data/models/home_dashboard/home_dashboard_model.dart';
import '../app_bar_widget.dart';
import '../new_home/phase_theme.dart';

/// H-01 LIVE section. Renders [SizedBox.shrink] when `live == null` or when
/// the backend status is not exactly `"In Progress"`. LIVE label, elapsed
/// counter, and Join button all gate on the same `live.status` field — no
/// client-side clock math.
/// Title splits on the FIRST space: first word in bold #fff, rest muted.
/// A single-word title (e.g., "Yoga") renders all-bold with no muted suffix.
class PaidHeroLiveSection extends StatelessWidget {
  final LiveClass? live;
  final PhaseTheme theme;

  const PaidHeroLiveSection({
    Key? key,
    required this.live,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = live;
    if (l == null) return const SizedBox.shrink();
    // Backend already returns live==null unless status is "In Progress",
    // but gate again client-side so a stale cached payload can't show LIVE.
    if (l.status != 'In Progress') return const SizedBox.shrink();

    // Title split on first space.
    final title = (l.classType ?? '').trim();
    final spaceIdx = title.indexOf(' ');
    final hasSuffix = spaceIdx > 0 && spaceIdx < title.length - 1;
    final firstWord = hasSuffix ? title.substring(0, spaceIdx) : title;
    final restWords = hasSuffix ? title.substring(spaceIdx + 1) : '';

    // Status line: "{participantCount} women · {elapsedMinutes} min elapsed".
    // Skip null parts and drop surrounding separators cleanly.
    final statusParts = <String>[];
    if (l.participantCount != null) {
      statusParts.add('${l.participantCount} women');
    }
    if (l.elapsedMinutes != null) {
      statusParts.add('${l.elapsedMinutes} min elapsed');
    }
    final statusText = statusParts.join(' · ');

    // Subtitle: "{trainerName} · {durationMinutes} min · {caloriesEstimate} kcal".
    final subParts = <String>[];
    final trainer = (l.trainerName ?? '').trim();
    if (trainer.isNotEmpty) subParts.add(trainer);
    if (l.durationMinutes != null) subParts.add('${l.durationMinutes} min');
    if (l.caloriesEstimate != null) subParts.add('${l.caloriesEstimate} kcal');
    final subtitle = subParts.join(' · ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // LIVE pill
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: const BoxDecoration(
                  color: Color(0xFFE24B4A),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    SizedBox(
                      width: 5,
                      height: 5,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'LIVE',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              if (statusText.isNotEmpty) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    statusText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.22),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 11),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: hasSuffix ? '$firstWord ' : firstWord,
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.3,
                              height: 1.0,
                            ),
                          ),
                          if (hasSuffix)
                            TextSpan(
                              text: restWords,
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w300,
                                color: Colors.white.withOpacity(0.5),
                                letterSpacing: -0.3,
                                height: 1.0,
                              ),
                            ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.26),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 14),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  final link = l.trainerLink;
                  final id = l.slotId;
                  if (link == null || link.isEmpty || id == null) return;
                  HelpingWidgets.startMeeting(link, id.toString());
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 22, vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.accent,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: theme.accent.withOpacity(0.33),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: const Text(
                    'Join',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
