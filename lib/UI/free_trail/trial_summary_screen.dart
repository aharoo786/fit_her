import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' show NumberFormat;

import '../../data/controllers/home_controller/home_controller.dart';
import '../plans_module/all_plans.dart';
import '../plans_module/select_payment_mode.dart';

/// "My trial" summary: what she did in her trial, a short note from the
/// Fit Her Team, and (from her last trial day) the offer in HER
/// country's prices with a live countdown. All numbers and prices come
/// from GET /trial/summary; the offer is saved on the server so the
/// countdown is the same everywhere.
class TrialSummaryScreen extends StatefulWidget {
  const TrialSummaryScreen({super.key});

  @override
  State<TrialSummaryScreen> createState() => _TrialSummaryScreenState();
}

const _kBg = Color(0xFFE8F4E0);
const _kInk = Color(0xFF163220);
const _kInkSoft = Color(0xFF6F8B7A);
const _kAccent = Color(0xFF6DC55A);
const _kAccentBg = Color(0xFFEAF7E4);
const _kBorder = Color(0xFFD8EDD4);
const _kHero2 = Color(0xFF24502F);
const _kAmber = Color(0xFFC98A2C);

class _TrialSummaryScreenState extends State<TrialSummaryScreen> {
  final HomeController _home = Get.find<HomeController>();
  Map<String, dynamic>? _data;
  bool _loading = true;
  Timer? _tick;
  // Selected duration per plan.
  final Map<int, int> _durationByPlan = {};

  @override
  void initState() {
    super.initState();
    _load();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _offer != null) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final d = await _home.loadTrialSummary();
    if (!mounted) return;
    setState(() {
      _data = d;
      _loading = false;
    });
  }

  Map<String, dynamic>? get _offer =>
      _data?['offer'] is Map ? Map<String, dynamic>.from(_data!['offer'] as Map) : null;

  int _int(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;

  String _money(dynamic v) {
    final cur = '${_offer?['currency'] ?? ''}'.trim();
    final n = NumberFormat('#,##0').format(v is num ? v : num.tryParse('$v') ?? 0);
    return cur.isEmpty ? n : '$cur $n';
  }

  String _durationLabel(int? days) {
    if (days == null || days <= 0) return 'Plan';
    if (days % 30 == 0) {
      final m = days ~/ 30;
      return '$m month${m == 1 ? '' : 's'}';
    }
    return '$days days';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_kAccent),
              ),
            )
          : _data == null
              ? _errorView()
              : RefreshIndicator(
                  color: _kAccent,
                  onRefresh: _load,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _hero(),
                      _stats(),
                      _noteCard(),
                      _offerSection(),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
    );
  }

  Widget _errorView() => SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("We couldn't load your summary.",
                  style: TextStyle(fontFamily: 'Poppins', color: _kInkSoft)),
              TextButton(
                onPressed: _load,
                child: const Text('Try again',
                    style: TextStyle(
                        fontFamily: 'Poppins', fontWeight: FontWeight.w700, color: _kAccent)),
              ),
              TextButton(
                onPressed: () => Get.to(() => OurPlansScreen()),
                child: const Text('See plans',
                    style: TextStyle(fontFamily: 'Poppins', color: _kInkSoft)),
              ),
            ],
          ),
        ),
      );

  // ── Hero ───────────────────────────────────────────────────────────
  Widget _hero() {
    final name = '${_data?['firstName'] ?? ''}'.trim();
    final days = _int(_data?['trialDays']);
    final ended = _data?['ended'] == true;
    return Container(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 12, 20, 26),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_kInk, _kHero2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            ended ? 'YOUR TRIAL IS COMPLETE' : 'LAST DAY OF YOUR TRIAL',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: _kAccent,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name.isEmpty ? 'Your $days days with Fit Her' : '$name, your $days days\nwith Fit Her',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 26,
              height: 1.2,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your plan and progress are saved. Here is what you did.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: Colors.white.withOpacity(0.78),
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats ──────────────────────────────────────────────────────────
  Widget _stats() {
    final goal = _int(_data?['classGoal']);
    final attended = _int(_data?['classesAttended']);
    final meals = _int(_data?['mealsLogged']);
    Widget tile(String emoji, String value, String label) => Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _kBorder),
            ),
            child: Column(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _kInk,
                  ),
                ),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 11.5, color: _kInkSoft),
                ),
              ],
            ),
          ),
        );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Row(
        children: [
          tile(attended >= goal ? '🏆' : '💪', '$attended/$goal', 'classes joined'),
          const SizedBox(width: 10),
          tile('🥗', '$meals', 'meals logged'),
        ],
      ),
    );
  }

  Widget _noteCard() {
    final note = '${_data?['note'] ?? ''}'.trim();
    if (note.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kAccentBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kAccent.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💚  A note from the Fit Her Team',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: _kInk,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            note,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13.5,
              height: 1.5,
              color: _kInk,
            ),
          ),
        ],
      ),
    );
  }

  // ── Offer ──────────────────────────────────────────────────────────
  Widget _offerSection() {
    final offer = _offer;
    if (offer == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        child: _primaryButton('See plans', () => Get.to(() => OurPlansScreen())),
      );
    }
    if (offer['redeemed'] == true) {
      return _infoBox('💚 Offer applied. Your payment is being verified, we will let you know soon.');
    }
    final expiresAt = DateTime.tryParse('${offer['expiresAt']}')?.toLocal();
    final left = expiresAt == null ? Duration.zero : expiresAt.difference(DateTime.now());
    if (offer['expired'] == true || left.isNegative) {
      return Column(
        children: [
          _infoBox('This offer has ended. You can still continue at the normal price, anytime.'),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _primaryButton('See plans', () => Get.to(() => OurPlansScreen())),
          ),
        ],
      );
    }

    final items = (offer['items'] is List ? offer['items'] as List : const [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    // Group by plan, recommended first (server already sorted).
    final plans = <int, List<Map<String, dynamic>>>{};
    for (final i in items) {
      plans.putIfAbsent(_int(i['planId']), () => []).add(i);
    }
    final pct = _int(offer['percent']);
    final h = left.inHours;
    final m = left.inMinutes % 60;
    final s = left.inSeconds % 60;
    String two(int v) => v.toString().padLeft(2, '0');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          decoration: BoxDecoration(
            color: _kInk,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Text('🎁  $pct% off, just for you',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  )),
              const Spacer(),
              Text(
                '${two(h)}:${two(m)}:${two(s)}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _kAccent,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 6, 20, 0),
          child: Text(
            'Offer ends when the timer runs out.',
            textAlign: TextAlign.right,
            style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: _kInkSoft),
          ),
        ),
        ...plans.entries.map((e) => _planCard(e.key, e.value, pct)),
      ],
    );
  }

  Widget _planCard(int planId, List<Map<String, dynamic>> options, int pct) {
    final recommended = options.first['recommended'] == true;
    final selectedDuration = _durationByPlan[planId] ?? _int(options.first['durationId']);
    final sel = options.firstWhere(
      (o) => _int(o['durationId']) == selectedDuration,
      orElse: () => options.first,
    );
    final list = _int(sel['listPrice']);
    final price = _int(sel['offerPrice']);
    final desc = '${options.first['planDescription'] ?? ''}'.trim();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: recommended ? _kAccent : _kBorder, width: recommended ? 2 : 1),
        boxShadow: recommended
            ? [BoxShadow(color: _kAccent.withOpacity(0.2), blurRadius: 16, offset: const Offset(0, 6))]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (recommended)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: const BoxDecoration(
                color: _kAccent,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              child: const Text(
                '⭐  Recommended for you',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${sel['planTitle'] ?? 'Plan'}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: _kInk,
                  ),
                ),
                if (desc.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(desc,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: _kInkSoft)),
                  ),
                const SizedBox(height: 12),
                if (options.length > 1)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: options.map((o) {
                      final on = _int(o['durationId']) == _int(sel['durationId']);
                      return GestureDetector(
                        onTap: () => setState(() => _durationByPlan[planId] = _int(o['durationId'])),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: on ? _kInk : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: on ? _kInk : _kBorder),
                          ),
                          child: Text(
                            _durationLabel(o['days'] is int ? o['days'] as int : null),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: on ? Colors.white : _kInk,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _money(price),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: _kInk,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        _money(list),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: _kInkSoft,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  'You save ${_money(list - price)}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: _kAmber,
                  ),
                ),
                const SizedBox(height: 14),
                _primaryButton(
                  'Continue with $pct% off',
                  () => Get.to(() => SelectPaymentMode(
                        planId: '$planId',
                        durationId: _int(sel['durationId']),
                        price: '$price',
                      )),
                  filled: recommended,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBox(String text) => Container(
        margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _kBorder),
        ),
        child: Text(
          text,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13.5, height: 1.5, color: _kInk),
        ),
      );

  Widget _primaryButton(String label, VoidCallback onTap, {bool filled = true}) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: filled
          ? ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kAccent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(label,
                  style: const TextStyle(
                      fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w700)),
            )
          : OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: _kInk,
                side: const BorderSide(color: _kInk),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(label,
                  style: const TextStyle(
                      fontFamily: 'Poppins', fontSize: 14.5, fontWeight: FontWeight.w700)),
            ),
    );
  }
}
