// Pure classification helpers for incoming FCM RemoteMessages.
//
// Before this file existed, NotificationServices._handleForegroundMessage
// (foreground) and main.dart's firebaseMessagingBackgroundHandler
// (background/terminated) each carried their own independent copy of
// this exact logic — a drift risk where the two paths could silently
// diverge if one was edited and the other forgotten. Both now delegate
// here, so there's one source of truth and one place to test it — see
// test/notifications/notification_message_classifier_test.dart.
//
// RemoteMessage is a plain data class from firebase_messaging (no
// platform channel involved in constructing one), so these functions
// are testable with plain fixtures — no Firebase app/mocking needed.
import 'package:firebase_messaging/firebase_messaging.dart';

/// True if [message] represents a system announcement.
///
/// `annoucement` (sic) is a legacy backend payload key typo, kept for
/// backward compatibility with older sends that may still use it.
bool isAnnouncementMessage(RemoteMessage message) =>
    message.data['annoucement'] != null ||
    message.data['announcement'] != null ||
    message.data['type'] == 'announcement';

/// True if [message] represents a class-schedule update (reminder,
/// cancellation, link-added, etc.) — based on either an explicit `type`
/// payload key, or (for older payloads that never set `type`) one of
/// several known notification titles.
bool isClassUpdateMessage(RemoteMessage message) {
  final type = message.data['type'];
  return type == 'classPrep' ||
      type == 'classStart' ||
      type == 'upcomingClass' ||
      type == 'classLinkAdded' ||
      type == 'trainerLinkAdded' ||
      message.notification?.title == 'Class Reminder' ||
      message.notification?.title == 'Upcoming Class' ||
      message.notification?.title == 'Class Link Added' ||
      message.notification?.title == 'Class link Added' ||
      message.notification?.title == 'Trainer link Added' ||
      message.notification?.title == 'Sweat Now, Selfies Later' ||
      message.notification?.title == 'Class Cancelled';
}

/// True if [message] carries the full class-slot payload (`upcomingSlot`
/// + `trainer`) needed to build an `UpcomingClassSlot`.
bool hasClassPayload(RemoteMessage message) =>
    message.data['upcomingSlot'] != null && message.data['trainer'] != null;

/// True if [message] represents a diet/meal plan update from a nutritionist.
bool isDietPlanMessage(RemoteMessage message) {
  final type = message.data['type'];
  final title = message.notification?.title?.toLowerCase() ?? '';
  return type == 'dietPlanUpdated' ||
      type == 'diet' ||
      type == 'dietPlan' ||
      title.contains('diet') ||
      title.contains('meal plan');
}

