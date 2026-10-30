
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  await Firebase.initializeApp();

  debugPrint(
    'Background notification received: ${message.messageId}',
  );
  debugPrint('Notification data: ${message.data}');
}

class NotificationService {
  static final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static bool _initialized = false;

  static StreamSubscription<User?>? _authSubscription;
  static StreamSubscription<String>? _tokenRefreshSubscription;

  static Future<void> initialize() async {
    if (_initialized) {
      debugPrint('NotificationService already initialized.');
      return;
    }

    // Register background message handler.
    FirebaseMessaging.onBackgroundMessage(
      firebaseMessagingBackgroundHandler,
    );

    // Ask the user for notification permission.
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
    } catch (e) {
      debugPrint('Notification permission error: $e');
    }

    // Handle messages received while the app is open.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(
        'Foreground notification: '
        '${message.notification?.title}',
      );
      debugPrint(
        'Notification body: '
        '${message.notification?.body}',
      );
      debugPrint('Notification data: ${message.data}');
    });

    // Handle notification taps while the app is in the background.
    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        debugPrint('Notification tapped: ${message.data}');
      },
    );

    // Handle a notification that launched the app.
    try {
      final initialMessage =
          await _messaging.getInitialMessage();

      if (initialMessage != null) {
        debugPrint(
          'App launched from notification: '
          '${initialMessage.data}',
        );
      }
    } catch (e) {
      debugPrint('Initial notification error: $e');
    }

    // Save the token whenever a user logs in or changes accounts.
    _authSubscription = _auth.authStateChanges().listen(
      (User? user) async {
        if (user == null) {
          debugPrint('No logged-in user to register for notifications.');
          return;
        }

        await _registerDeviceToken(user.uid);
      },
      onError: (Object error) {
        debugPrint('Authentication listener error: $error');
      },
    );

    // Save refreshed tokens to the currently logged-in account.
    _tokenRefreshSubscription =
        _messaging.onTokenRefresh.listen(
      (String token) async {
        final user = _auth.currentUser;

        if (user != null) {
          await _saveToken(user.uid, token);
        }
      },
      onError: (Object error) {
        debugPrint('FCM token refresh error: $error');
      },
    );

    _initialized = true;

    debugPrint('NotificationService initialized.');
  }

  // Get the device token and save it to Firestore.
  static Future<void> _registerDeviceToken(
    String userId,
  ) async {
    try {
      debugPrint('Registering notification token...');

      final String? token = await _messaging.getToken();

      if (token == null || token.isEmpty) {
        debugPrint('FCM token is unavailable.');
        return;
      }

      await _saveToken(userId, token);
    } on FirebaseException catch (e) {
      debugPrint('Firebase token error: ${e.code} - ${e.message}');
    } catch (e) {
      debugPrint('Token registration failed: $e');
    }
  }

  // Save the device token in users/{userId}.
  static Future<void> _saveToken(
    String userId,
    String token,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).set(
        {
          'fcmToken': token,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      debugPrint('FCM token saved to the user account.');
    } catch (e) {
      debugPrint('Unable to save FCM token to Firestore: $e');
    }
  }
}