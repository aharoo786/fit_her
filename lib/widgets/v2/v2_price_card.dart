import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/get_user_plan/get_user_plan.dart';
import 'v2_buttons.dart';

const Color _kHeroDark = Color(0xFF163220);
const Color _kCardBorder = Color(0xFFD8EDD4);
const Color _kAccent = Color(0xFF6DC55A);
const Color _kTextPrimary = Color(0xFF163220);
const Color _kTextMuted = Color(0xFF6F8B7A);
const Color _kSage = Color(0xFF9AB09A);

/// V2 price/plan card. Replaces the legacy `PlanWidget` /
/// `OurPlansScreen` grid tile. Same `Plan` model, same currency +
/// duration logic — only the visual shell changes to match the V2
/// design system used by paid_home_screen_v2 and profile_screen_user.
class V2PriceCard extends StatelessWidget {
  final Plan plan;
  final VoidCallback onSubscribe;
  final List<String> features;

  const V2PriceCard({
    super.key,
    required this.plan,
    required this.onSubscribe,
    this.features = const [
      'Live workout sessions',
      'Customized diet plan',
      'Weekly follow-ups',
    ],
  });

  @override
  Widget build(BuildContext context) {
    final country = (plan.countries != null && plan.countries!.isNotEmpty)
        ? plan.countries!.first
        : null;
    final durations = country?.duration ?? const <DurationPlan>[];
    final currency = country?.currency ?? 'Rs.';

    if (plan.selectedDurationId.value == 0 && durations.isNotEmpty) {
      plan.selectedDurationId.value = durations.first.id ?? 0;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _kCardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: _kHeroDark.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 10,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heroHeader(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (plan.shortDescription.isNotEmpty &&
                    plan.shortDescription != 'N/A')
                  Text(
                    plan.shortDescription,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      height: 1.45,
                      color: _kTextMuted,
                    ),
                  ),
                if (durations.length > 1) ...[
                  const SizedBox(height: 12),
                  _durationChips(durations),
                ],
                const SizedBox(height: 12),
                _priceRow(currency, durations),
                const SizedBox(height: 14),
                ..._featureRows(),
                const SizedBox(height: 14),
                V2PrimaryButton(
                  label: 'Subscribe',
                  onPressed: onSubscribe,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      color: _kHeroDark,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _kAccent.withOpacity(0.18),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: _kAccent.withOpacity(0.32),
                width: 1,
              ),
            ),
            child: const Text('✨', style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'PLAN',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: _kAccent.withOpacity(0.85),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  plan.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _durationChips(List<DurationPlan> durations) {
    return Obx(() {
      final selectedId = plan.selectedDurationId.value;
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: durations.map((d) {
          final isSelected = d.id == selectedId;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => plan.selectedDurationId.value = d.id ?? 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? _kAccent : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? _kAccent : _kCardBorder,
                  width: 1,
                ),
              ),
              child: Text(
                d.days ?? '',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : _kTextPrimary,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _priceRow(String currency, List<DurationPlan> durations) {
    return Obx(() {
      final selectedId = plan.selectedDurationId.value;
      final selected = durations.isEmpty
          ? null
          : durations.firstWhere(
              (d) => d.id == selectedId,
              orElse: () => durations.first,
            );
      final amount = selected?.priceAmount ?? '—';
      final days = selected?.days ?? '';
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            currency,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _kTextMuted,
              height: 1.4,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            amount,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: _kTextPrimary,
              height: 1.0,
            ),
          ),
          const SizedBox(width: 6),
          if (days.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '/ $days',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _kSage,
                ),
              ),
            ),
        ],
      );
    });
  }

  List<Widget> _featureRows() {
    return features
        .map(
          (f) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _kAccent.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child:
                      const Icon(Icons.check, size: 12, color: _kAccent),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    f,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: _kTextPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }
}
