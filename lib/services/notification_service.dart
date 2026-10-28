

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  await Firebase.initializeApp();

  debugPrint(
    'Background message received: ${message.messageId}',
  );
  debugPrint('Notification data: ${message.data}');
}

class NotificationService {
  static final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  static bool _initialized = false;

  static Future<void> initialize() async {
    // Prevent duplicate listeners if initialization is called again.
    if (_initialized) {
      debugPrint('NotificationService already initialized.');
      return;
    }

    // Register the background handler.
    FirebaseMessaging.onBackgroundMessage(
      firebaseMessagingBackgroundHandler,
    );

    // Request notification permission.
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint(
        'Notification permission: '
        '${settings.authorizationStatus}',
      );
    } catch (e, stackTrace) {
      debugPrint('Notification permission error: $e');
      debugPrintStack(stackTrace: stackTrace);
    }

    // Handle messages received while the app is open.
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        debugPrint(
          'Foreground notification title: '
          '${message.notification?.title}',
        );
        debugPrint(
          'Foreground notification body: '
          '${message.notification?.body}',
        );
        debugPrint('Notification data: ${message.data}');
      },
      onError: (Object error) {
        debugPrint('Foreground message listener error: $error');
      },
    );

    // Handle notification taps when the app is in the background.
    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        debugPrint('Notification tapped: ${message.data}');
      },
      onError: (Object error) {
        debugPrint('Notification tap listener error: $error');
      },
    );

    // Handle a notification that launched the app.
    try {
      final RemoteMessage? initialMessage =
          await _messaging.getInitialMessage();

      if (initialMessage != null) {
        debugPrint(
          'App launched by notification: '
          '${initialMessage.data}',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Initial notification error: $e');
      debugPrintStack(stackTrace: stackTrace);
    }

    // Request the FCM registration token.
    try {
      debugPrint('Requesting FCM registration token...');

      final String? token = await _messaging.getToken();

      if (token != null && token.isNotEmpty) {
        debugPrint('FCM token received successfully.');
        debugPrint('FCM TOKEN: ${token.length}');
      } else {
        debugPrint('FCM token is null or empty.');
      }
    } on FirebaseException catch (e, stackTrace) {
      debugPrint('Firebase FCM error code: ${e.code}');
      debugPrint('Firebase FCM error message: ${e.message}');
      debugPrintStack(stackTrace: stackTrace);
    } catch (e, stackTrace) {
      debugPrint('FCM token registration failed: $e');
      debugPrintStack(stackTrace: stackTrace);
    }

    // Listen for token changes.
    _messaging.onTokenRefresh.listen(
      (String newToken) {
        debugPrint('FCM token refreshed: $newToken');
      },
      onError: (Object error) {
        debugPrint('FCM token refresh error: $error');
      },
    );

    _initialized = true;
    debugPrint('NotificationService initialization completed.'); 
  }
}
