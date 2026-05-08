import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:talker_riverpod_logger/talker_riverpod_logger.dart';

/// Centralized Talker service for logging across the app.
///
/// Provides:
/// - Global Talker instance for app-wide logging
/// - TalkerDioLogger for HTTP request/response logging
/// - TalkerRiverpodObserver for Riverpod state management logging
/// - TalkerScreen for viewing logs in-app
class TalkerService {
  TalkerService._();

  static const isVerboseLoggingEnabled = bool.fromEnvironment(
    'SPORT_CONNECT_VERBOSE_LOGS',
  );

  static Talker? _instance;

  /// Global Talker instance.
  static Talker get instance {
    _instance ??= TalkerFlutter.init(
      settings: TalkerSettings(),
      logger: TalkerLogger(
        output: debugPrint,
        settings: TalkerLoggerSettings(
          enableColors: !kIsWeb,
          maxLineWidth: 120,
        ),
      ),
    );
    return _instance!;
  }

  /// Creates a TalkerDioLogger interceptor for Dio instances.
  ///
  /// Add this from the HTTP layer, not via a Dio extension.
  static TalkerDioLogger get dioLogger => TalkerDioLogger(
    talker: instance,
    settings: TalkerDioLoggerSettings(
      printRequestData: false,
      printResponseData: false,
      printErrorData: false,
      printErrorHeaders: false,
      requestPen: kIsWeb ? null : (AnsiPen()..cyan()),
      responsePen: kIsWeb ? null : (AnsiPen()..green()),
      errorPen: kIsWeb ? null : (AnsiPen()..red()),
    ),
  );

  /// Creates a TalkerRiverpodObserver for ProviderScope.
  static TalkerRiverpodObserver get riverpodObserver => TalkerRiverpodObserver(
    talker: instance,
    settings: const TalkerRiverpodLoggerSettings(
      printProviderAdded: false,
      printProviderUpdated: false,
    ),
  );

  static void log(String message) {
    if (isVerboseLoggingEnabled) instance.log(message);
  }

  static void debug(String message) {
    if (isVerboseLoggingEnabled) instance.debug(message);
  }

  static void info(String message) {
    if (isVerboseLoggingEnabled) instance.info(message);
  }

  static void warning(String message) => instance.warning(message);

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    instance.error(message, error, stackTrace);
  }

  static void verbose(String message) {
    if (isVerboseLoggingEnabled) instance.verbose(message);
  }

  /// Handle and log exceptions with stack traces.
  static void handleException(
    Object exception, {
    StackTrace? stackTrace,
    String? message,
  }) {
    instance.handle(exception, stackTrace, message);
  }

  /// Navigate to the TalkerScreen to view all logs. Debug builds only.
  static void showLogScreen(BuildContext context) {
    if (!kDebugMode || kIsWeb) return;

    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => TalkerScreen(talker: instance),
        ),
      ),
    );
  }

  /// Get a TalkerRouteObserver for navigation logging.
  static TalkerRouteObserver? get routeObserver =>
      kIsWeb || !isVerboseLoggingEnabled ? null : TalkerRouteObserver(instance);

  /// Wrap a widget with TalkerWrapper for error monitoring.
  static Widget wrapWithMonitor({required Widget child}) {
    if (kIsWeb) return child;
    return TalkerWrapper(talker: instance, child: child);
  }
}
