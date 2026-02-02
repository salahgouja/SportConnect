import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/firebase_options.dart';
import 'package:sport_connect/core/config/app_config.dart';

/// Centralized Firebase service initialization
class FirebaseService {
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  static FirebaseStorage get storage => FirebaseStorage.instance;
  static FirebaseMessaging get messaging => FirebaseMessaging.instance;

  /// Initialize Firebase and all services
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      TalkerService.info('Firebase initialized successfully');
      TalkerService.info('Environment: ${AppConfig.environmentStatus}');

      // Connect to emulators if in emulator mode
      if (AppConfig.useEmulators) {
        await _connectToEmulators();
      }

      // Initialize Firestore settings
      firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      // Request notification permissions
      await _requestNotificationPermissions();
    } catch (e, stackTrace) {
      TalkerService.error('Firebase initialization failed', e, stackTrace);
      rethrow;
    }
  }

  /// Connect to Firebase emulators for local development
  static Future<void> _connectToEmulators() async {
    final host = AppConfig.emulatorHost;

    try {
      // Connect to Auth emulator
      await auth.useAuthEmulator(host, AppConfig.authEmulatorPort);
      TalkerService.info(
        'Connected to Auth emulator at $host:${AppConfig.authEmulatorPort}',
      );

      // Connect to Firestore emulator
      firestore.useFirestoreEmulator(host, AppConfig.firestoreEmulatorPort);
      TalkerService.info(
        'Connected to Firestore emulator at $host:${AppConfig.firestoreEmulatorPort}',
      );

      // Connect to Storage emulator
      await storage.useStorageEmulator(host, AppConfig.storageEmulatorPort);
      TalkerService.info(
        'Connected to Storage emulator at $host:${AppConfig.storageEmulatorPort}',
      );

      TalkerService.info('🔧 All Firebase emulators connected successfully!');
    } catch (e) {
      TalkerService.error('Failed to connect to emulators', e);
      TalkerService.warning('Falling back to production Firebase services');
    }
  }

  /// Request notification permissions
  static Future<void> _requestNotificationPermissions() async {
    try {
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      TalkerService.info(
        'Notification permission status: ${settings.authorizationStatus}',
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        String? token = await messaging.getToken();
        TalkerService.info('FCM Token: $token');
      }
    } catch (e) {
      TalkerService.warning('Failed to request notification permissions $e');
    }
  }

  /// Get current user
  static User? get currentUser => auth.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;
}
