import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/controllers/dietitian_dashboard_controller/dietitian_dashboard_controller.dart';
import '../../../data/models/consultation/day7_review.dart';
import 'client_consultation_screen.dart';

/// Phase 3 — flagged Day 7 reviews queue. Surfaces every review the
/// server-side hook flagged (Decision 6 thresholds: adherence < 40%,
/// pain reported, severe side effects, satisfaction < 2). Each entry
/// links to the full client view.
class FlaggedReviewsScreen extends StatefulWidget {
  const FlaggedReviewsScreen({Key? key}) : super(key: key);

  @override
  State<FlaggedReviewsScreen> createState() => _FlaggedReviewsScreenState();
}

class _FlaggedReviewsScreenState extends State<FlaggedReviewsScreen> {
  late final DietitianDashboardController _ctrl;
  bool _loading = true;
  List<Day7Review> _reviews = const [];

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<DietitianDashboardController>();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await _ctrl.loadReviews(flagged: true, limit: 100);
    if (!mounted) return;
    setState(() {
      _reviews = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F4E0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A3A22)),
        title: const Text(
          'Flagged reviews',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A3A22),
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(Color(0xFF6DC55A)),
              ),
            )
          : _reviews.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No flagged reviews 🎉',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF7A8C78),
                      ),
                    ),
                  ),
                )
              : RefreshIndicator(
                  color: const Color(0xFF6DC55A),
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _reviews.length,
                    itemBuilder: (_, i) {
                      final r = _reviews[i];
                      // Backend join surfaces the user via the Sequelize
                      // include alias `User` — read from the raw payload
                      // since we don't have a typed field on Day7Review.
                      // The list-tile relies on the userId only; the
                      // client-detail screen resolves the full name via
                      // its own profile fetch.
                      final userId = r.userId ?? 0;
                      return GestureDetector(
                        onTap: userId == 0
                            ? null
                            : () => Get.to<dynamic>(() =>
                                ClientConsultationScreen(userId: userId)),
                        child: _FlaggedTile(review: r),
                      );
                    },
                  ),
                ),
    );
  }
}

class _FlaggedTile extends StatelessWidget {
  final Day7Review review;
  const _FlaggedTile({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE24B4A), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'User #${review.userId ?? '?'} · Cycle ${review.cycle ?? '?'}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A3A22),
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF7A8C78),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: (review.flagReasons ?? const [])
                .map((r) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1EE),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: const Color(0xFFFFCDB8), width: 1),
                      ),
                      child: Text(
                        r.toString(),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFE24B4A),
                          letterSpacing: 0.4,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 6),
          if (review.createdAt != null)
            Text(
              _shortTs(review.createdAt!),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                color: Color(0xFF9AB09A),
              ),
            ),
        ],
      ),
    );
  }

  static String _shortTs(DateTime dt) {
    final local = dt.toLocal();
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${local.day} ${months[local.month - 1]} ${local.year}';
  }
}
