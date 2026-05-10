/// Push multi-device requires Firebase Cloud Messaging (FCM).
/// This file is a safe stub so the app keeps compiling until Firebase is configured.
///
/// Once Firebase is added, replace this implementation with firebase_messaging:
/// - request permission
/// - FirebaseMessaging.instance.getToken()
/// - listen to onTokenRefresh
class PushTokenProvider {
  Future<String?> getDeviceToken() async {
    // TODO: integrate FirebaseMessaging to return a real FCM token.
    return null;
  }
}

