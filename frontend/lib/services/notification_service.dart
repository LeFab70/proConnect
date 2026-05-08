import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz_data.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: android);

    await _notifications.initialize(settings);

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  static NotificationDetails get _defaultNotificationDetails {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'rappels_channel',
        'Rappels',
        channelDescription: 'Notifications des rappels et médicaments',
        importance: Importance.max,
        priority: Priority.high,
        category: AndroidNotificationCategory.alarm,
        fullScreenIntent: true,
        visibility: NotificationVisibility.public,
      ),
    );
  }

  static Future<void> showMedicationReminder({
    required int id,
    required String title,
    required String body,
  }) async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      debugPrint('Notification ignorée : plateforme non supportée.');
      return;
    }

    await _notifications.show(id, title, body, _defaultNotificationDetails);
  }

  static Future<void> cancelMedicationNotifications(String medicationId) async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      debugPrint(
        'Annulation notifications médicament ignorée : plateforme non supportée.',
      );
      return;
    }
    final baseId = medicationId.hashCode;

    await _notifications.cancel(baseId + 10);
    await _notifications.cancel(baseId + 20);
    await _notifications.cancel(baseId + 30);
    await _notifications.cancel(baseId + 40);
    await _notifications.cancel(baseId + 50);
    await _notifications.cancel(baseId + 60);
    await _notifications.cancel(baseId + 999);
  }

  static Future<void> scheduleWeeklyRappel({
    required int id,
    required String title,
    required String body,
    required int weekday,
    required int hour,
    required int minute,
  }) async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      debugPrint(
        'Notification ignorée : zonedSchedule non supporté sur cette plateforme.',
      );
      return;
    }
    final now = tz.TZDateTime.now(tz.local);

    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    while (scheduledDate.weekday != weekday || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    try {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        _defaultNotificationDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    } on PlatformException catch (e) {
      if (e.code == 'exact_alarms_not_permitted') {
        await _notifications.zonedSchedule(
          id,
          title,
          body,
          scheduledDate,
          _defaultNotificationDetails,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
        return;
      }
      rethrow;
    }
  }

  static Future<void> scheduleDailyRappel({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
  }) async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      debugPrint(
        'Notification ignorée : zonedSchedule non supporté sur cette plateforme.',
      );
      return;
    }

    var scheduledDate = tz.TZDateTime.from(dateTime, tz.local);

    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    try {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        _defaultNotificationDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } on PlatformException catch (e) {
      if (e.code == 'exact_alarms_not_permitted') {
        await _notifications.zonedSchedule(
          id,
          title,
          body,
          scheduledDate,
          _defaultNotificationDetails,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        );
        return;
      }
      rethrow;
    }
  }

  static Future<void> cancelNotification(int id) async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      debugPrint(
        'Annulation notification ignorée : non supportée sur cette plateforme.',
      );
      return;
    }

    await _notifications.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
