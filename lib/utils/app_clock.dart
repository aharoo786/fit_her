/// Server-anchored wall clock. Defends every slot resolver call against
/// device clocks that are wrong, drifted, or set to a different timezone
/// from the user's actual location.
///
/// Usage:
///   await AppClock.init();   // once, at app launch (fire-and-forget OK)
///   AppClock.now();          // anywhere — drop-in for DateTime.now()
///
/// Falls back to device time if the server hasn't been reached yet, so
/// the rest of the app keeps working offline. The offset is recomputed
/// on every successful call to [init], so dropping a fresh init into
/// AppLifecycleState.resumed (or after a long background) is cheap.
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:fitness_zone_2/values/constants.dart';

class AppClock {
  // (server.now - device.now) at the moment we measured. Adding this to
  // the current device time gives us the server's current view of "now".
  static Duration _offset = Duration.zero;
  static bool _initialized = false;
  static DateTime? _lastSyncDeviceTime;

  /// True once we've successfully fetched server time at least once.
  static bool get isInitialized => _initialized;

  /// Currently-applied offset (server - device). Useful for telemetry /
  /// debug overlays. Zero when uninitialized, so callers don't need to
  /// special-case the first-launch state.
  static Duration get offset => _offset;

  /// Last time a successful sync landed (device clock). Null until first
  /// successful [init].
  static DateTime? get lastSyncAt => _lastSyncDeviceTime;

  /// Fetch server time and recompute the offset. Safe to call repeatedly
  /// (e.g. on app foreground). Never throws — failures are silent and
  /// leave the previous offset in place.
  ///
  /// Round-trip compensation: we record send/recv ticks and assume the
  /// server's snapshot was taken halfway through the round-trip. This is
  /// the same heuristic NTP uses for non-symmetric latency.
  static Future<bool> init({Duration timeout = const Duration(seconds: 5)}) async {
    final url = Uri.parse('${Constants.baseUrl}admin/server-time');
    final sendStopwatch = Stopwatch()..start();
    try {
      final response = await http.get(url).timeout(timeout);
      sendStopwatch.stop();
      if (response.statusCode != 200) return false;
      final body = jsonDecode(response.body);
      if (body is! Map || body['status'] != '1') return false;
      final serverMs = body['data']?['ms'];
      if (serverMs is! int) return false;

      final halfRoundTripMs = sendStopwatch.elapsedMilliseconds ~/ 2;
      final estimatedServerNowMs = serverMs + halfRoundTripMs;
      final deviceNowMs = DateTime.now().millisecondsSinceEpoch;

      _offset = Duration(milliseconds: estimatedServerNowMs - deviceNowMs);
      _lastSyncDeviceTime = DateTime.now();
      _initialized = true;
      debugPrint(
        '[AppClock] synced — offset=${_offset.inSeconds}s '
        'rt=${sendStopwatch.elapsedMilliseconds}ms',
      );
      return true;
    } catch (e) {
      debugPrint('[AppClock] init failed: $e — falling back to device time');
      return false;
    }
  }

  /// Drop-in for [DateTime.now]. Returns server-anchored time when
  /// [init] has succeeded, otherwise device time. Call this everywhere a
  /// resolver, scheduler, or boundary check needs "now" — in particular
  /// in the workout schedule and the slot UI state resolver.
  static DateTime now() => DateTime.now().add(_offset);

  /// Reset the offset to zero. Test-only — production code should rely
  /// on [init].
  @visibleForTesting
  static void resetForTest() {
    _offset = Duration.zero;
    _initialized = false;
    _lastSyncDeviceTime = null;
  }

  /// Force a specific offset for tests that need deterministic time.
  @visibleForTesting
  static void setOffsetForTest(Duration offset) {
    _offset = offset;
    _initialized = true;
    _lastSyncDeviceTime = DateTime.now();
  }
}
