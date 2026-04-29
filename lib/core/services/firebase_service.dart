import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/config/app_config.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/firebase_options.dart';

part 'firebase_service.g.dart';

/// Firebase bootstrap and SDK access service.
///
/// Owns:
/// - Firebase initialization
/// - App Check activation
/// - emulator wiring
/// - Firestore offline cache configuration
/// - Realtime Database persistence configuration
/// - Analytics helpers
/// - Crashlytics helpers
///
/// Repositories should normally depend on the narrow Firebase providers at the
/// bottom of this file, for example [firestoreInstanceProvider] or
/// [authInstanceProvider], instead of depending on [FirebaseService] directly.
class FirebaseService {
  FirebaseService._();

  static FirebaseService? _instance;

  static FirebaseService get instance {
    _instance ??= FirebaseService._();
    return _instance!;
  }

  bool _initialized = false;

  bool get isInitialized => _initialized;

  FirebaseAuth get auth => FirebaseAuth.instance;
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
  FirebaseStorage get storage => FirebaseStorage.instance;
  FirebaseFunctions get functions => FirebaseFunctions.instance;
  FirebaseDatabase get database => FirebaseDatabase.instance;
  FirebaseMessaging get messaging => FirebaseMessaging.instance;
  FirebaseAnalytics get analytics => FirebaseAnalytics.instance;
  FirebaseCrashlytics get crashlytics => FirebaseCrashlytics.instance;

  bool get useEmulators => AppConfig.useEmulators;

  /// Navigator observer for Firebase Analytics screen tracking.
  FirebaseAnalyticsObserver get analyticsNavigatorObserver {
    return FirebaseAnalyticsObserver(analytics: analytics);
  }

  Future<FirebaseService> initialize() async {
    if (_initialized) return this;

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // RTDB offline persistence is intentionally disabled.
      // Live location data (the only RTDB use-case) is inherently online-only;
      // caching stale GPS coordinates has no value. More critically, enabling
      // persistence sets a flag on the native FirebaseDatabase singleton.
      // When the native_geofence foreground service starts a background Dart
      // isolate and registers firebase_database via DartPluginRegistrant, the
      // plugin calls FirebaseDatabase.getInstance() and sees persistence=true,
      // then tries to open the same SQLite file the main process already holds
      // exclusively → SQLITE_BUSY → FATAL DatabaseException crash.
      // Firestore persistence (100 MB, below) covers all durable offline state.

      await FirebaseAppCheck.instance.activate(
        providerAndroid: kDebugMode
            ? const AndroidDebugProvider()
            : const AndroidPlayIntegrityProvider(),
        providerApple: kDebugMode
            ? const AppleDebugProvider()
            : const AppleDeviceCheckProvider(),
      );

      firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: 100 * 1024 * 1024,
      );

      if (useEmulators) {
        await connectToEmulators();
      }

      await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);

      _initialized = true;

      TalkerService.info('Firebase initialized successfully');
      TalkerService.info('Environment: ${AppConfig.environmentStatus}');
      TalkerService.info('✅ Analytics & Crashlytics initialized');

      return this;
    } catch (e, st) {
      TalkerService.error('Firebase initialization failed', e, st);
      rethrow;
    }
  }

  Future<void> connectToEmulators() async {
    final host = AppConfig.emulatorHost;

    try {
      await auth.useAuthEmulator(host, AppConfig.authEmulatorPort);

      TalkerService.info(
        'Connected to Auth emulator at $host:${AppConfig.authEmulatorPort}',
      );

      firestore.useFirestoreEmulator(
        host,
        AppConfig.firestoreEmulatorPort,
      );

      TalkerService.info(
        'Connected to Firestore emulator at '
        '$host:${AppConfig.firestoreEmulatorPort}',
      );

      await storage.useStorageEmulator(
        host,
        AppConfig.storageEmulatorPort,
      );

      TalkerService.info(
        'Connected to Storage emulator at '
        '$host:${AppConfig.storageEmulatorPort}',
      );

      database.useDatabaseEmulator(
        host,
        AppConfig.databaseEmulatorPort,
      );

      TalkerService.info(
        'Connected to Realtime Database emulator at '
        '$host:${AppConfig.databaseEmulatorPort}',
      );

      functions.useFunctionsEmulator(
        host,
        AppConfig.functionsEmulatorPort,
      );

      TalkerService.info(
        'Connected to Functions emulator at '
        '$host:${AppConfig.functionsEmulatorPort}',
      );

      TalkerService.info('🔧 Firebase emulators connected successfully');
    } catch (e, st) {
      TalkerService.error('Failed to connect to Firebase emulators', e, st);
      TalkerService.warning(
        'Emulator connection failed on host $host. Ensure Firebase emulators '
        'are running and ports match firebase.json. For physical devices use '
        '--dart-define=FIREBASE_EMULATOR_HOST=<LAN_IP>. For Android emulator '
        'use --dart-define=FIREBASE_USE_ANDROID_EMULATOR_HOST=true.',
      );
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Analytics and Crashlytics collection
  // ───────────────────────────────────────────────────────────────────────────

  Future<void> setCollectionEnabled({required bool enabled}) async {
    await analytics.setAnalyticsCollectionEnabled(enabled);
    await crashlytics.setCrashlyticsCollectionEnabled(enabled);

    TalkerService.info(
      'Analytics collection ${enabled ? 'enabled' : 'disabled'}',
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Analytics helpers
  // ───────────────────────────────────────────────────────────────────────────

  Future<void> logEvent(
    String name, {
    Map<String, Object>? parameters,
  }) async {
    try {
      await analytics.logEvent(
        name: name,
        parameters: parameters,
      );
    } on Exception catch (e, st) {
      TalkerService.error('Analytics logEvent failed', e, st);
    }
  }

  Future<void> setUserId(String? userId) async {
    await analytics.setUserId(id: userId);
    await crashlytics.setUserIdentifier(userId ?? '');
  }

  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    await analytics.setUserProperty(
      name: name,
      value: value,
    );
  }

  Future<void> logScreenView(String screenName) async {
    await analytics.logScreenView(screenName: screenName);
  }

  Future<void> logLogin(String method) {
    return analytics.logLogin(loginMethod: method);
  }

  Future<void> logSignUp(String method) {
    return analytics.logSignUp(signUpMethod: method);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Crashlytics helpers
  // ───────────────────────────────────────────────────────────────────────────

  void recordError(
    Object exception,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) {
    unawaited(
      crashlytics.recordError(
        exception,
        stack,
        reason: reason ?? 'non-fatal',
        fatal: fatal,
      ),
    );
  }

  Future<void> recordFlutterFatalError(FlutterErrorDetails details) {
    return crashlytics.recordFlutterFatalError(details);
  }

  void logCrashlyticsMessage(String message) {
    crashlytics.log(message);
  }

  Future<void> setCustomKey(String key, Object value) {
    return crashlytics.setCustomKey(key, value);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Riverpod Firebase providers
// ─────────────────────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
FirebaseService firebaseService(Ref ref) {
  return FirebaseService.instance;
}
