import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/Repos/plan_freeze_repo/plan_freeze_repository.dart';
import '../../data/Repos/user_plan_repo/user_plan_repository.dart';
import '../../data/controllers/auth_controller/auth_controller.dart';
import '../../data/models/user_plan/user_plan_item.dart';
import '../../values/constants.dart';

const Color _kCardBorder = Color(0xFFD8EDD4);
const Color _kHeroDark = Color(0xFF163220);
const Color _kAccent = Color(0xFF6DC55A);
const Color _kAmber = Color(0xFFFAC775);
const Color _kFrozenBlue = Color(0xFF4A8FB8);
const Color _kDanger = Color(0xFFE07B7B);
const Color _kTextPrimary = Color(0xFF163220);
const Color _kTextMuted = Color(0xFF6F8B7A);
const Color _kSage = Color(0xFF9AB09A);
const Color _kTrackBg = Color(0xFFEAF7E4);

/// V2 assigned-plan card. Shown on the profile screen — replaces the
/// older `_FreezePlanBlock`. Combines two endpoints:
///   • GET /users/get_user_plans (plan title, buyingDate, expireDate, price)
///   • GET /users/plan/freeze-status (active/paused state, freeze controls)
///
/// Renders nothing when there is no active plan, mirroring
/// `_FreezePlanBlock` so non-paid users continue to see no plan card.
class V2AssignedPlanCard extends StatefulWidget {
  const V2AssignedPlanCard({super.key});

  @override
  State<V2AssignedPlanCard> createState() => _V2AssignedPlanCardState();
}

class _V2AssignedPlanCardState extends State<V2AssignedPlanCard> {
  Map<String, dynamic>? _freezeStatus;
  UserPlanItem? _plan;
  bool _loading = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  String get _accessToken {
    final auth = Get.find<AuthController>();
    return auth.sharedPreferences.getString(Constants.accessToken) ?? '';
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final freezeRepo = Get.find<PlanFreezeRepository>();
      final planRepo = Get.find<UserPlanRepository>();

      final results = await Future.wait([
        freezeRepo.getStatus(accessToken: _accessToken),
        planRepo.getMyPlans(accessToken: _accessToken),
      ]);

      Map<String, dynamic>? freezeStatus;
      if (results[0].body != null && results[0].body['status'] == '1') {
        freezeStatus =
            Map<String, dynamic>.from(results[0].body['data'] ?? const {});
      }

      UserPlanItem? plan;
      if (results[1].body != null && results[1].body['status'] == '1') {
        final raw = results[1].body['data'];
        if (raw is List && raw.isNotEmpty) {
          // Prefer the plan that matches freeze-status' userPlanId.
          // Fallback to the first row when the IDs disagree (multiple
          // active rows is a backend quirk we don't try to resolve here).
          final targetId = freezeStatus?['userPlanId'];
          Map<String, dynamic>? match;
          for (final row in raw) {
            if (row is! Map) continue;
            final m = Map<String, dynamic>.from(row);
            if (targetId != null && m['id'] == targetId) {
              match = m;
              break;
            }
            match ??= m;
          }
          if (match != null) plan = UserPlanItem.fromJson(match);
        }
      }

      setState(() {
        _freezeStatus = freezeStatus;
        _plan = plan;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _doFreeze(int days) async {
    setState(() => _busy = true);
    try {
      final repo = Get.find<PlanFreezeRepository>();
      final res = await repo.freeze(accessToken: _accessToken, days: days);
      final ok = res.body != null && res.body['status'] == '1';
      Get.snackbar(
        ok ? 'Plan paused' : 'Could not freeze',
        res.body?['message']?.toString() ?? '',
        snackPosition: SnackPosition.BOTTOM,
      );
      if (ok) await _refresh();
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _doUnfreeze() async {
    setState(() => _busy = true);
    try {
      final repo = Get.find<PlanFreezeRepository>();
      final res = await repo.unfreeze(accessToken: _accessToken);
      final ok = res.body != null && res.body['status'] == '1';
      Get.snackbar(
        ok ? 'Plan resumed' : 'Could not unfreeze',
        res.body?['message']?.toString() ?? '',
        snackPosition: SnackPosition.BOTTOM,
      );
      if (ok) await _refresh();
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showFreezeDialog() {
    final budget =
        (_freezeStatus?['remainingFreezeBudget'] as num?)?.toInt() ?? 0;
    final controller = TextEditingController(text: budget > 0 ? '7' : '');
    Get.dialog(
      AlertDialog(
        title: const Text('Pause your plan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              budget > 0
                  ? 'You can pause for up to $budget more day(s) on this plan.'
                  : 'You have used your full freeze budget on this plan.',
              style: const TextStyle(fontSize: 13, color: _kTextMuted),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Days',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Workouts and consultations will be paused. Any upcoming appointments in this window will be auto-cancelled.',
              style: TextStyle(fontSize: 11, color: _kTextMuted),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final days = int.tryParse(controller.text.trim());
              if (days == null || days < 1 || (budget > 0 && days > budget)) {
                Get.snackbar(
                    'Invalid', 'Enter a number between 1 and $budget',
                    snackPosition: SnackPosition.BOTTOM);
                return;
              }
              Get.back();
              _doFreeze(days);
            },
            child: const Text('Pause plan'),
          ),
        ],
      ),
    );
  }

  void _showUnfreezeDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Resume your plan?'),
        content: const Text(
          'Workouts and consultations will be available again. Any unspent days will be refunded to your expiry.',
          style: TextStyle(fontSize: 13, color: _kTextMuted),
        ),
        actions: [
          TextButton(
              onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _doUnfreeze();
            },
            child: const Text('Resume'),
          ),
        ],
      ),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return _shell(
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      return _shell(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            _error!,
            style: const TextStyle(fontSize: 12, color: _kTextMuted),
          ),
        ),
      );
    }

    final hasActive = _freezeStatus?['hasActivePlan'] == true;
    if (!hasActive) return const SizedBox.shrink();

    final isFrozen = _freezeStatus?['isFrozen'] == true;
    final canFreeze = _freezeStatus?['canFreezeNow'] == true;
    final blockedReason = _freezeStatus?['blockedReason']?.toString();
    final budget = (_freezeStatus?['remainingFreezeBudget'] as num?)?.toInt();
    final resumeOn = _freezeStatus?['willResumeOn']?.toString();

    final title = _plan?.plan?.title?.trim();
    final price = _plan?.price;
    final buying = _plan?.buyingDate;
    final expire = _plan?.expireDate;
    final daysRemaining = _daysRemaining(expire);
    final daysTotal = _daysTotal(buying, expire);
    final progress = (daysTotal != null &&
            daysTotal > 0 &&
            daysRemaining != null)
        ? (1.0 - (daysRemaining / daysTotal)).clamp(0.0, 1.0)
        : null;

    final isExpiringSoon = daysRemaining != null && daysRemaining <= 7;
    final isExpired = daysRemaining != null && daysRemaining < 0;

    final Color barColor = isFrozen
        ? _kFrozenBlue
        : isExpired
            ? _kDanger
            : isExpiringSoon
                ? _kAmber
                : _kAccent;

    return _shell(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Lbl('MY PLAN'),
          const SizedBox(height: 12),
          _planHeader(title: title, price: price),
          if (progress != null) ...[
            const SizedBox(height: 14),
            _progressBar(progress, barColor),
            const SizedBox(height: 6),
            Text(
              _progressLabel(
                isFrozen: isFrozen,
                isExpired: isExpired,
                daysRemaining: daysRemaining,
                resumeOn: resumeOn,
              ),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: barColor,
              ),
            ),
          ],
          if (buying != null || expire != null) ...[
            const SizedBox(height: 10),
            _dateRow(buying: buying, expire: expire),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              _statusChip(isFrozen: isFrozen),
              const SizedBox(width: 10),
              Expanded(
                child: _freezeButton(
                  isFrozen: isFrozen,
                  canFreeze: canFreeze,
                  blockedReason: blockedReason,
                ),
              ),
            ],
          ),
          if (isFrozen && resumeOn != null) ...[
            const SizedBox(height: 8),
            Text(
              'Resumes ${_formatDate(resumeOn)} (or tap above to resume now)',
              style: const TextStyle(fontSize: 11, color: _kTextMuted),
            ),
          ] else if (!isFrozen && budget != null) ...[
            const SizedBox(height: 8),
            Text(
              'You can pause for up to $budget day(s) on this plan',
              style: const TextStyle(fontSize: 11, color: _kTextMuted),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Sub-widgets ───────────────────────────────────────────────────────

  Widget _planHeader({String? title, int? price}) {
    final showTitle = title != null && title.isNotEmpty;
    final showPrice = price != null && price > 0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _kAccent.withOpacity(0.14),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _kAccent.withOpacity(0.28), width: 1),
          ),
          child: const Text('✨', style: TextStyle(fontSize: 20)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                showTitle ? title : 'Active plan',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _kTextPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              if (showPrice) ...[
                const SizedBox(height: 2),
                Text(
                  'PKR $price',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _kTextMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _progressBar(double fraction, Color color) {
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: _kTrackBg,
        borderRadius: BorderRadius.circular(3),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: fraction,
            heightFactor: 1.0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dateRow({DateTime? buying, DateTime? expire}) {
    final buyStr = buying != null ? _formatDate(buying.toIso8601String()) : '—';
    final expStr = expire != null ? _formatDate(expire.toIso8601String()) : '—';
    return Row(
      children: [
        Expanded(child: _datePill(label: 'Bought', value: buyStr)),
        const SizedBox(width: 8),
        Expanded(child: _datePill(label: 'Expires', value: expStr)),
      ],
    );
  }

  Widget _datePill({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _kTrackBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: _kSage,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _kTextPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip({required bool isFrozen}) {
    final color = isFrozen ? _kFrozenBlue : _kAccent;
    final label = isFrozen ? 'Paused' : 'Active';
    final icon = isFrozen ? Icons.pause_rounded : Icons.check_rounded;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.32), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _freezeButton({
    required bool isFrozen,
    required bool canFreeze,
    String? blockedReason,
  }) {
    final enabled = !_busy && (isFrozen || canFreeze);
    final color = isFrozen
        ? _kFrozenBlue
        : (canFreeze ? _kAccent : _kCardBorder);
    final label = isFrozen
        ? 'Resume plan'
        : (canFreeze ? 'Pause plan' : (blockedReason ?? 'Pause plan'));
    final textColor =
        (isFrozen || canFreeze) ? Colors.white : _kTextMuted;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: !enabled
          ? null
          : (isFrozen ? _showUnfreezeDialog : _showFreezeDialog),
      child: Container(
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: _busy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
      ),
    );
  }

  Widget _shell(Widget child) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kCardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: _kHeroDark.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 10,
          ),
        ],
      ),
      child: child,
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────

  int? _daysRemaining(DateTime? expire) {
    if (expire == null) return null;
    final now = DateTime.now();
    return expire.difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  int? _daysTotal(DateTime? buying, DateTime? expire) {
    if (buying == null || expire == null) return null;
    final d = expire.difference(buying).inDays;
    return d > 0 ? d : null;
  }

  String _progressLabel({
    required bool isFrozen,
    required bool isExpired,
    int? daysRemaining,
    String? resumeOn,
  }) {
    if (isFrozen) return 'Paused';
    if (isExpired) return 'Plan expired';
    if (daysRemaining == null) return '';
    if (daysRemaining == 0) return 'Expires today';
    if (daysRemaining == 1) return '1 day remaining';
    return '$daysRemaining days remaining';
  }

  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso).toLocal();
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso.substring(0, iso.length >= 10 ? 10 : iso.length);
    }
  }
}

/// Small-caps section label — duplicates the private `_CardLabel` from
/// `profile_screen_user.dart` so this widget stays self-contained.
class _Lbl extends StatelessWidget {
  final String text;
  const _Lbl(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: _kSage,
        letterSpacing: 0.7,
      ),
    );
  }
}
