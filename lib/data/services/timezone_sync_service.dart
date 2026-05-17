import 'package:flutter/widgets.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';

import '../../values/constants.dart';
import '../Repos/diet_plan_v2/diet_plan_user_repository.dart';
import '../controllers/auth_controller/auth_controller.dart';

/// Phase F.3 — keeps `User.timeZone` in sync with the device's actual
/// IANA zone.
///
/// Lifecycle:
///   • `_check()` runs on first start (called by `start()` after login)
///   • `WidgetsBindingObserver.didChangeAppLifecycleState` re-runs the
///     check on every app resume so a user who travels while the app is
///     backgrounded is detected the moment she opens the app
///
/// Pattern (per spec):
///   1. Read device zone via flutter_timezone.
///   2. Compare to `auth.userTimeZone`.
///   3. If different: optimistically update locally + fire PATCH.
///   4. On PATCH failure: keep the local change (next launch will retry)
///      and log it. Don't surface a snackbar — this is silent infra.
///
/// Registered in `get_di.dart` and started by the splash/login flow
/// once `auth.logInUser` is non-null. The service is a no-op until
/// auth is ready.
class TimezoneSyncService extends GetxService with WidgetsBindingObserver {
  final AuthController auth;
  final DietPlanUserRepository repo;

  TimezoneSyncService({required this.auth, required this.repo});

  bool _started = false;
  bool _inFlight = false;

  /// Idempotent — safe to call from multiple places (splash, post-login).
  void start() {
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    // Defer one frame so any in-progress login/rehydrate finishes first.
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  /// Tear down on logout — caller invokes this from AuthController.logout
  /// so the observer stops firing for the next user.
  void stop() {
    if (!_started) return;
    _started = false;
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _check();
    }
  }

  Future<void> _check() async {
    if (_inFlight) return;
    _inFlight = true;
    try {
      // Skip when there's no logged-in user (cold-start before login).
      if (auth.logInUser == null) return;

      String deviceTz;
      try {
        deviceTz = await FlutterTimezone.getLocalTimezone();
      } catch (e) {
        debugPrint('[TimezoneSyncService] device zone lookup failed: $e');
        return;
      }
      if (deviceTz.isEmpty) return;
      if (deviceTz == auth.userTimeZone) return; // already correct

      // Optimistic local update — DietPlanUserController.todaysDayNumber
      // reads `auth.userTimeZone` on every Obx tick, so the UI flips to
      // the new zone immediately even if the PATCH is in flight.
      final previous = auth.userTimeZone;
      auth.setUserTimeZoneLocal(deviceTz);

      final token =
          auth.sharedPreferences.getString(Constants.accessToken) ?? '';
      if (token.isEmpty) return;

      try {
        await repo.updateMyTimezone(
          accessToken: token,
          timezone: deviceTz,
        );
        debugPrint(
            '[TimezoneSyncService] synced device zone $previous → $deviceTz');
      } catch (e) {
        // Spec: keep the local change; retry on next launch.
        debugPrint(
            '[TimezoneSyncService] PATCH failed (kept locally, will retry): $e');
      }
    } finally {
      _inFlight = false;
    }
  }
}
