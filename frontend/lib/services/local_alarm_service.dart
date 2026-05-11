import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalAlarmService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    // Pour tes tests au Nouveau-Brunswick.
    // Plus tard, on pourra rendre ça dynamique.
    tz.setLocalLocation(tz.getLocation('America/Moncton'));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(initSettings);

    final android = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();

    _initialized = true;
  }

  static Future<void> scheduleAlarm({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
  }) async {
    await init();

    final now = DateTime.now();

    if (dateTime.isBefore(now)) {
      debugPrint('ALARME IGNORÉE: date passée => $dateTime');
      return;
    }

    final scheduledDate = tz.TZDateTime.from(dateTime, tz.local);

    debugPrint('ALARME PLANIFIÉE: id=$id date=$scheduledDate');

    try {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'proconnectnb_alarm_channel',
            'Alarmes ProConnectNB',
            channelDescription: 'Alarmes pour rendez-vous et rappels',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            category: AndroidNotificationCategory.alarm,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } on PlatformException catch (e) {
      debugPrint('Exact alarm refusée: ${e.code}');

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'proconnectnb_alarm_channel',
            'Alarmes ProConnectNB',
            channelDescription: 'Alarmes pour rendez-vous et rappels',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            category: AndroidNotificationCategory.alarm,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  static Future<void> showTestNotification() async {
    await init();

    await _notifications.show(
      999999,
      'Test ProConnectNB',
      'La notification locale fonctionne.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'proconnectnb_alarm_channel',
          'Alarmes ProConnectNB',
          channelDescription: 'Alarmes pour rendez-vous et rappels',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  static Future<void> cancelAlarm(int id) async {
    await init();
    await _notifications.cancel(id);
  }
}
