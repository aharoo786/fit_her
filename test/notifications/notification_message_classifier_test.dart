// Tests for the FCM message classification logic shared between
// NotificationServices (foreground) and main.dart's
// firebaseMessagingBackgroundHandler (background/terminated) — see
// lib/helper/notification_message_classifier.dart. RemoteMessage is a
// plain data class, so these fixtures need no real Firebase connection.
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fitness_zone_2/helper/notification_message_classifier.dart';

RemoteMessage _message({
  Map<String, dynamic> data = const {},
  String? title,
  String? body,
}) {
  return RemoteMessage(
    data: data,
    notification: (title != null || body != null)
        ? RemoteNotification(title: title, body: body)
        : null,
  );
}

void main() {
  group('isAnnouncementMessage', () {
    test('data.type == "announcement" is an announcement', () {
      expect(isAnnouncementMessage(_message(data: {'type': 'announcement'})), isTrue);
    });

    test('data.announcement present is an announcement', () {
      expect(isAnnouncementMessage(_message(data: {'announcement': 'true'})), isTrue);
    });

    test('legacy typo key "annoucement" is still honored', () {
      expect(isAnnouncementMessage(_message(data: {'annoucement': 'true'})), isTrue);
    });

    test('a plain class-update message is not an announcement', () {
      expect(
        isAnnouncementMessage(_message(data: {'type': 'classStart'})),
        isFalse,
      );
    });

    test('empty message is not an announcement', () {
      expect(isAnnouncementMessage(_message()), isFalse);
    });
  });

  group('isClassUpdateMessage', () {
    test('recognized data.type values are class updates', () {
      for (final type in [
        'classPrep',
        'classStart',
        'upcomingClass',
        'classLinkAdded',
        'trainerLinkAdded',
      ]) {
        expect(
          isClassUpdateMessage(_message(data: {'type': type})),
          isTrue,
          reason: 'type=$type should be a class update',
        );
      }
    });

    test('legacy payloads without a type field fall back to known titles', () {
      for (final title in [
        'Class Reminder',
        'Upcoming Class',
        'Class Link Added',
        'Class link Added',
        'Trainer link Added',
        'Sweat Now, Selfies Later',
        'Class Cancelled',
      ]) {
        expect(
          isClassUpdateMessage(_message(title: title)),
          isTrue,
          reason: 'title="$title" should be a class update',
        );
      }
    });

    test('unrelated type/title is not a class update', () {
      expect(
        isClassUpdateMessage(_message(data: {'type': 'planActivated'}, title: 'Congratulations!')),
        isFalse,
      );
    });
  });

  group('hasClassPayload', () {
    test('both upcomingSlot and trainer present -> true', () {
      expect(
        hasClassPayload(_message(data: {
          'upcomingSlot': '{"id":1}',
          'trainer': '{"id":2}',
        })),
        isTrue,
      );
    });

    test('missing either field -> false', () {
      expect(hasClassPayload(_message(data: {'upcomingSlot': '{"id":1}'})), isFalse);
      expect(hasClassPayload(_message(data: {'trainer': '{"id":2}'})), isFalse);
      expect(hasClassPayload(_message()), isFalse);
    });
  });

  group('classification functions agree on a realistic class-reminder payload', () {
    test('a typical "class starting soon" push classifies as class update with payload', () {
      final message = _message(
        data: {
          'type': 'classStart',
          'upcomingSlot': '{"id":42,"start":"6:00 PM"}',
          'trainer': '{"id":7,"name":"Coach Amina"}',
        },
        title: 'Class Link Added',
      );
      expect(isAnnouncementMessage(message), isFalse);
      expect(isClassUpdateMessage(message), isTrue);
      expect(hasClassPayload(message), isTrue);
    });
  });
}
