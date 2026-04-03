import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';

/// Service to handle push notifications using FCM.
/// Registers device tokens with the backend and handles foreground/background messages.
class NotificationService {
  final ApiClient apiClient;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  NotificationService(this.apiClient);

  /// Initializes the notification service.
  /// Requests permissions and sets up listeners for FCM messages.
  Future<void> initialize() async {
    // Return early if iOS - push notifications are disabled for iOS
    if (!kIsWeb && Platform.isIOS) {
      debugPrint('Notification system disabled for iOS');
      return;
    }

    // 1. Request Permission (especially for iOS)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted notification permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('User granted provisional notification permission');
    } else {
      debugPrint('User declined notification permission');
      // On some platforms, we can still get a token even if declined
      // but we shouldn't send anything if the user explicitly said no.
    }

    // 2. Initialize Local Notifications (for showing heads-up in foreground)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification click when app is in foreground
        debugPrint('Notification clicked: ${details.payload}');
      },
    );

    // 3. Create Notification Channel (Android 8.0+)
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'travelly_notifications_channel',
        'Travelly Notifications',
        description: 'Notifications for trip updates and expenses',
        importance: Importance.max,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    // 4. Register current token
    await _updateToken();

    // 5. Listen for Token Refresh
    _fcm.onTokenRefresh.listen((token) {
      _registerTokenWithBackend(token);
    });

    // 6. Handle Foreground Messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 7. Handle Background Messages Opened
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // 8. Check if App was opened via a notification from a terminated state
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleInitialMessage(initialMessage);
    }
  }

  /// Refreshes and registers the current FCM token with the backend.
  Future<void> _updateToken() async {
    try {
      String? token = await _fcm.getToken();
      if (token != null) {
        await _registerTokenWithBackend(token);
      }
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }
  }

  /// Registers a token with the backend API.
  Future<void> _registerTokenWithBackend(String token) async {
    if (!apiClient.isAuthenticated) {
      debugPrint('Skipping token registration: User not authenticated');
      return;
    }

    try {
      String deviceType = 'web';
      if (kIsWeb) {
        deviceType = 'web';
      } else if (Platform.isAndroid) {
        deviceType = 'android';
      } else if (Platform.isIOS) {
        deviceType = 'ios';
      }

      await apiClient.post(
        ApiEndpoints.registerToken,
        body: {'token': token, 'device': deviceType},
      );
      debugPrint('FCM Token registered successfully');
    } catch (e) {
      debugPrint('Failed to register FCM token: $e');
    }
  }

  /// Unregisters the current token from the backend.
  Future<void> unregisterToken() async {
    try {
      String? token = await _fcm.getToken();
      if (token != null) {
        await apiClient.delete(
          ApiEndpoints.unregisterToken,
          body: {'token': token},
        );
        debugPrint('FCM Token unregistered successfully');
      }
    } catch (e) {
      debugPrint('Failed to unregister FCM token: $e');
    }
  }

  /// Handle messages received while the app is in foreground.
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground Message: ${message.notification?.title}');
    
    // Show a local notification for foreground messages
    if (message.notification != null) {
      _showLocalNotification(message);
    }
  }

  /// Handle messages when the app is opened from the background.
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('Message Opened App: ${message.notification?.title}');
    // Logic to navigate to a specific screen based on message data
  }

  /// Handle the initial message if the app was opened from termination.
  void _handleInitialMessage(RemoteMessage message) {
    debugPrint('Initial Message: ${message.notification?.title}');
    // Logic to navigate to a specific screen based on message data
  }

  /// Shows a local notification using flutter_local_notifications plugin.
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'travelly_notifications_channel',
      'Travelly Notifications',
      channelDescription: 'Notifications for trip updates and expenses',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      id: message.hashCode,
      title: message.notification?.title,
      body: message.notification?.body,
      notificationDetails: platformDetails,
      payload: message.data['type'],
    );
  }
}
