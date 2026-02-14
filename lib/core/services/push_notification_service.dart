import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/services/talker_service.dart';

part 'push_notification_service.g.dart';

/// Top-level background message handler — must NOT be a class method.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  TalkerService.info(
    'Background message received: ${message.messageId}',
  );
  // Local notification is shown automatically by FCM for data+notification
  // messages when the app is in background/terminated.
}

/// Android notification channel IDs
class NotificationChannels {
  NotificationChannels._();

  static const String messagesId = 'sport_connect_messages';
  static const String messagesName = 'Messages';
  static const String messagesDesc = 'New chat message notifications';

  static const String ridesId = 'sport_connect_rides';
  static const String ridesName = 'Rides';
  static const String ridesDesc = 'Ride booking and status notifications';

  static const String generalId = 'sport_connect_general';
  static const String generalName = 'General';
  static const String generalDesc = 'General app notifications';
}

/// Service that bridges Firebase Cloud Messaging with local notifications.
///
/// Handles foreground display, navigation on tap, and FCM token management.
class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService _instance =
      PushNotificationService._();
  static PushNotificationService get instance => _instance;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize the service — call once from main.
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    // 1. Create Android notification channels
    await _createNotificationChannels();

    // 2. Initialize flutter_local_notifications
    await _initLocalNotifications();

    // 3. Set foreground notification presentation (iOS)
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 4. Listen for foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 5. Listen for notification taps (app was in background)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // 6. Check for initial message (app opened from terminated state)
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      // Defer navigation until the router is ready
      _pendingInitialMessage = initialMessage;
    }

    TalkerService.info('PushNotificationService initialized');
  }

  /// Pending message that arrived when the app was terminated.
  RemoteMessage? _pendingInitialMessage;

  /// Call this once the router is mounted to handle the initial message.
  void handlePendingInitialMessage(BuildContext context) {
    if (_pendingInitialMessage != null) {
      _navigateFromPayload(context, _pendingInitialMessage!.data);
      _pendingInitialMessage = null;
    }
  }

  // ---------------------------------------------------------------------------
  // FCM Token Management
  // ---------------------------------------------------------------------------

  /// Save the current FCM token to the user's Firestore document.
  Future<void> saveFcmToken(String userId) async {
    try {
      final token = await _messaging.getToken();
      if (token == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'fcmToken': token});

      TalkerService.info('FCM token saved for user $userId');

      // Listen for token refreshes
      _messaging.onTokenRefresh.listen((newToken) async {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({'fcmToken': newToken});
        TalkerService.info('FCM token refreshed for user $userId');
      });
    } catch (e) {
      TalkerService.error('Failed to save FCM token', e);
    }
  }

  // ---------------------------------------------------------------------------
  // Channel & Local Notification Setup
  // ---------------------------------------------------------------------------

  Future<void> _createNotificationChannels() async {
    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return;

    const channels = [
      AndroidNotificationChannel(
        NotificationChannels.messagesId,
        NotificationChannels.messagesName,
        description: NotificationChannels.messagesDesc,
        importance: Importance.high,
      ),
      AndroidNotificationChannel(
        NotificationChannels.ridesId,
        NotificationChannels.ridesName,
        description: NotificationChannels.ridesDesc,
        importance: Importance.high,
      ),
      AndroidNotificationChannel(
        NotificationChannels.generalId,
        NotificationChannels.generalName,
        description: NotificationChannels.generalDesc,
        importance: Importance.defaultImportance,
      ),
    ];

    for (final channel in channels) {
      await androidPlugin.createNotificationChannel(channel);
    }
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      ),
      onDidReceiveNotificationResponse: (response) {
        // Handle tap on local notification
        if (response.payload != null) {
          try {
            final data = jsonDecode(response.payload!) as Map<String, dynamic>;
            _navigateFromData(data);
          } catch (_) {}
        }
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Message Handlers
  // ---------------------------------------------------------------------------

  /// Display a local notification when a message arrives in the foreground.
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    TalkerService.info(
      'Foreground message: ${message.notification?.title}',
    );

    final notification = message.notification;
    if (notification == null) return;

    final channelId = _channelForType(message.data['type'] as String?);

    await _localNotifications.show(
      id: message.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          _channelName(channelId),
          icon: '@mipmap/ic_launcher',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  /// Handle notification tap when the app was in the background.
  void _handleNotificationTap(RemoteMessage message) {
    TalkerService.info('Notification tapped: ${message.data}');
    _navigateFromData(message.data);
  }

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  /// Global navigator key — set from MaterialApp.router. Used when no
  /// BuildContext is available (e.g. notification tap from background).
  static GlobalKey<NavigatorState>? navigatorKey;

  void _navigateFromData(Map<String, dynamic> data) {
    final context = navigatorKey?.currentContext;
    if (context == null) return;
    _navigateFromPayload(context, data);
  }

  void _navigateFromPayload(BuildContext context, Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final referenceId = data['referenceId'] as String?;

    if (type == null || referenceId == null) return;

    switch (type) {
      case 'message':
        context.push('/chat/$referenceId');
      case 'ride_request':
      case 'ride_update':
        context.push('/ride/$referenceId');
      default:
        context.push('/notifications');
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _channelForType(String? type) {
    switch (type) {
      case 'message':
        return NotificationChannels.messagesId;
      case 'ride_request':
      case 'ride_update':
        return NotificationChannels.ridesId;
      default:
        return NotificationChannels.generalId;
    }
  }

  String _channelName(String channelId) {
    switch (channelId) {
      case NotificationChannels.messagesId:
        return NotificationChannels.messagesName;
      case NotificationChannels.ridesId:
        return NotificationChannels.ridesName;
      default:
        return NotificationChannels.generalName;
    }
  }
}

/// Riverpod provider for push notification service.
@Riverpod(keepAlive: true)
PushNotificationService pushNotificationService(Ref ref) {
  return PushNotificationService.instance;
}
