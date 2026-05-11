import 'package:workmanager/workmanager.dart';

/// Background tasks entry point (Android).
///
/// Keep this lightweight: it runs in a background isolate.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Placeholder: we will use this to resync reminders and schedule alerts.
    // Must return true/false to signal completion.
    return Future.value(true);
  });
}

