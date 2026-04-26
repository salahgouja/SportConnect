import 'package:flutter/foundation.dart';

/// Environment mode for Firebase services
enum EnvironmentMode {
  /// Use Firebase emulators for local development
  emulator,

  /// Use production Firebase services
  production,
}

/// App Configuration - Firebase only
class AppConfig {
  AppConfig._();

  /// Current environment mode
  static const EnvironmentMode environmentMode = kDebugMode
      ? EnvironmentMode.emulator
      : EnvironmentMode.production;

  /// Check if we're using emulators
  static bool get useEmulators => environmentMode == EnvironmentMode.emulator;

  /// Optional override for Firebase emulator host.
  ///
  /// Example for physical Android/iOS device over Wi-Fi:
  /// --dart-define=FIREBASE_EMULATOR_HOST=192.168.1.23
  static const String emulatorHostOverride = String.fromEnvironment(
    'FIREBASE_EMULATOR_HOST',
    defaultValue: 'localhost',
  );

  /// Enable Android emulator loopback host (10.0.2.2) when needed.
  ///
  /// Example for Android emulator:
  /// --dart-define=FIREBASE_USE_ANDROID_EMULATOR_HOST=true
  static const bool useAndroidEmulatorHost = bool.fromEnvironment(
    'FIREBASE_USE_ANDROID_EMULATOR_HOST',
    defaultValue: false,
  );

  /// Emulator host resolution.
  ///
  /// Priority:
  /// 1) Explicit FIREBASE_EMULATOR_HOST override.
  /// 2) Android emulator loopback (10.0.2.2) when enabled.
  /// 3) Loopback (127.0.0.1) for local reverse/forward workflows.
  static String get emulatorHost {
    return '10.221.107.105';
    final overrideHost = emulatorHostOverride.trim();
    if (overrideHost.isNotEmpty) {
      return overrideHost;
    }

    if (kIsWeb) {
      return '10.116.167.105';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return '10.116.167.105';
    }

    return '10.116.167.105';
  }

  /// Emulator ports (must match firebase.json)
  static const int authEmulatorPort = int.fromEnvironment(
    'FIREBASE_AUTH_EMULATOR_PORT',
    defaultValue: 9099,
  );
  static const int firestoreEmulatorPort = int.fromEnvironment(
    'FIREBASE_FIRESTORE_EMULATOR_PORT',
    defaultValue: 8080,
  );
  static const int storageEmulatorPort = int.fromEnvironment(
    'FIREBASE_STORAGE_EMULATOR_PORT',
    defaultValue: 9199,
  );
  static const int functionsEmulatorPort = int.fromEnvironment(
    'FIREBASE_FUNCTIONS_EMULATOR_PORT',
    defaultValue: 5001,
  );
  static const int databaseEmulatorPort = int.fromEnvironment(
    'FIREBASE_DATABASE_EMULATOR_PORT',
    defaultValue: 9000,
  );

  /// App-level settings
  static const String appName = 'SportConnect';
  static const String appVersion = '1.0.9';
  static const String supportTicketEmail = String.fromEnvironment(
    'SPORTCONNECT_SUPPORT_EMAIL',
    defaultValue: 'support@sportconnect.app',
  );

  /// API settings
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration locationTimeout = Duration(seconds: 10);

  /// Map settings
  static const double defaultMapZoom = 13;
  static const double minMapZoom = 3;
  static const double maxMapZoom = 18;

  /// Pagination
  static const int pageSize = 20;
  static const int maxSearchRadius = 50; // km

  /// Feature flags
  static bool get isPremiumEnabled => true;
  static bool get isChatEnabled => true;
  static bool get isGamificationEnabled => true;

  /// In-app purchase product identifiers for premium subscription plans.
  /// Override via --dart-define in CI/CD per environment if needed.
  static const String premiumMonthlyProductId = String.fromEnvironment(
    'SPORTCONNECT_IAP_PREMIUM_MONTHLY_ID',
    defaultValue: 'sportconnect_premium_monthly',
  );
  static const String premiumYearlyProductId = String.fromEnvironment(
    'SPORTCONNECT_IAP_PREMIUM_YEARLY_ID',
    defaultValue: 'sportconnect_premium_yearly',
  );

  /// Get environment status string for logging
  static String get environmentStatus {
    if (useEmulators) {
      return 'EMULATOR MODE - Host: $emulatorHost';
    }
    return 'PRODUCTION MODE';
  }
}
