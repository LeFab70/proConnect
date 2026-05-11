import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';

import 'secrets.dart';

/// Background tasks entry point (Android).
///
/// Keep this lightweight: it runs in a background isolate.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // Load auth token saved by AuthProvider.
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final isAuth = prefs.getBool("isAuth") ?? false;
      if (!isAuth || token == null || token.isEmpty) return true;

      // Fetch reminders from backend.
      const baseUrl =
          "https://proconnectnb-d2bxe6embxg2e7h7.eastus2-01.azurewebsites.net";
      final resp = await http.get(
        Uri.parse("$baseUrl/api/rappels"),
        headers: {
          "Content-Type": "application/json",
          "x-api-key": Secrets.apiKey,
          "Authorization": "Bearer $token",
        },
      );
      if (resp.statusCode != 200) return true;

      final decoded = jsonDecode(resp.body);
      if (decoded is! List) return true;

      // Init local notifications + timezone.
      tz_data.initializeTimeZones();
      tz.setLocalLocation(tz.local);

      final notifications = FlutterLocalNotificationsPlugin();
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidInit);
      await notifications.initialize(initSettings);

      // Schedule upcoming notifications (best-effort).
      final now = DateTime.now();
      for (final item in decoded) {
        if (item is! Map) continue;

        final actif = item["actif"] == true;
        if (!actif) continue;

        final id = item["id"];
        final type = (item["type"] ?? "").toString();
        final dateHeureNotif = item["dateHeureNotification"]?.toString();
        if (id == null || dateHeureNotif == null) continue;

        final notifTime = DateTime.tryParse(dateHeureNotif);
        if (notifTime == null) continue;
        if (notifTime.isBefore(now)) continue;

        // Stable notification id (must fit int32).
        final notifId = (id.toString().hashCode & 0x7fffffff);

        final isMed = type.toLowerCase().contains("medicament");
        final title = isMed ? "Rappel médicament" : "Rappel";
        final body = isMed
            ? "Il est temps de prendre votre médicament."
            : "Vous avez un rappel prévu.";

        await notifications.zonedSchedule(
          notifId,
          title,
          body,
          tz.TZDateTime.from(notifTime, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'rappels_channel',
              'Rappels',
              channelDescription: 'Notifications des rappels et médicaments',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    } catch (_) {
      // Never fail the task for runtime exceptions.
    }
    return true;
  });
}

