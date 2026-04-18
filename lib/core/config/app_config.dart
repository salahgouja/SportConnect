import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

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
  /// Change this to switch between emulator and production
  static const EnvironmentMode environmentMode = /*kDebugMode
      ? EnvironmentMode.emulator
      :*/
      EnvironmentMode.production;

  /// Check if we're using emulators
  static bool get useEmulators => environmentMode == EnvironmentMode.emulator;

  /// Emulator host configuration
  /// - Android emulator uses 10.0.2.2 to access host machine's localhost
  /// - iOS simulator and web use localhost/127.0.0.1
  /// - Physical devices need the actual IP address of your machine
  static String get emulatorHost {
    if (kIsWeb) {
      return 'localhost';
    }
    if (Platform.isAndroid) {
      return 'localhost';
    }
    return 'localhost';
  }

  /// Emulator ports (must match firebase.json)
  static const int authEmulatorPort = 9099;
  static const int firestoreEmulatorPort = 8080;
  static const int storageEmulatorPort = 9199;
  static const int functionsEmulatorPort = 5001;
  static const int databaseEmulatorPort = 9000;

  /// App-level settings
  static const String appName = 'SportConnect';
  static const String appVersion = '1.0.4';
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
