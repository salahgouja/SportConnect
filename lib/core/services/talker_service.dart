import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:talker_riverpod_logger/talker_riverpod_logger.dart';

/// Centralized Talker service for logging across the app
///
/// Provides:
/// - Global Talker instance for app-wide logging
/// - TalkerDioLogger for HTTP request/response logging
/// - TalkerRiverpodObserver for Riverpod state management logging
/// - TalkerScreen for viewing logs in-app (non-web only)
class TalkerService {
  TalkerService._();

  static Talker? _instance;

  /// Global Talker instance
  static Talker get instance {
    _instance ??= TalkerFlutter.init(
      settings: TalkerSettings(),
      logger: TalkerLogger(
        output: debugPrint,
        settings: TalkerLoggerSettings(
          enableColors: !kIsWeb, // ANSI colors crash on web
          maxLineWidth: 120,
        ),
      ),
    );
    return _instance!;
  }

  /// Creates a TalkerDioLogger interceptor for Dio instances
  ///
  /// Usage:
  /// ```dart
  /// final dio = Dio();
  /// dio.interceptors.add(TalkerService.dioLogger);
  /// ```
  static TalkerDioLogger get dioLogger => TalkerDioLogger(
    talker: instance,
    settings: TalkerDioLoggerSettings(
      printRequestData: false,
      printResponseData: false,
      printErrorData: false,
      printErrorHeaders: false,
      // AnsiPen is not supported on web
      requestPen: kIsWeb ? null : (AnsiPen()..cyan()),
      responsePen: kIsWeb ? null : (AnsiPen()..green()),
      errorPen: kIsWeb ? null : (AnsiPen()..red()),
    ),
  );

  /// Creates a TalkerRiverpodObserver for ProviderScope
  ///
  /// Usage:
  /// ```dart
  /// ProviderScope(
  ///   observers: [TalkerService.riverpodObserver],
  ///   child: MyApp(),
  /// )
  /// ```
  static TalkerRiverpodObserver get riverpodObserver => TalkerRiverpodObserver(
    talker: instance,
    settings: const TalkerRiverpodLoggerSettings(
      printProviderAdded: false,
      printProviderUpdated: false,
    ),
  );

  // Convenience logging methods
  static void log(String message) => instance.log(message);
  static void debug(String message) => instance.debug(message);
  static void info(String message) => instance.info(message);
  static void warning(String message) => instance.warning(message);
  static void error(String message, [Object? error, StackTrace? stackTrace]) =>
      instance.error(message, error, stackTrace);
  static void verbose(String message) => instance.verbose(message);

  /// Handle and log exceptions with stack traces
  static void handleException(
    Object exception, {
    StackTrace? stackTrace,
    String? message,
  }) {
    instance.handle(exception, stackTrace, message);
  }

  /// Navigate to the TalkerScreen to view all logs (non-web only)
  ///
  /// Usage:
  /// ```dart
  /// TalkerService.showLogScreen(context);
  /// ```
  static void showLogScreen(BuildContext context) {
    if (kIsWeb) {
      debugPrint('[TalkerService] TalkerScreen is not supported on web.');
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => TalkerScreen(talker: instance)),
    );
  }

  /// Get a TalkerRouteObserver for navigation logging (non-web only)
  ///
  /// Returns null on web — filter it out with .whereType or .nonNulls:
  /// ```dart
  /// navigatorObservers: [
  ///   if (TalkerService.routeObserver != null) TalkerService.routeObserver!,
  /// ]
  /// ```
  static TalkerRouteObserver? get routeObserver =>
      kIsWeb ? null : TalkerRouteObserver(instance);

  /// Wrap a widget with TalkerWrapper for error boundary (non-web only)
  ///
  /// Falls back to returning the child unwrapped on web.
  ///
  /// Usage:
  /// ```dart
  /// TalkerService.wrapWithMonitor(child: MyWidget())
  /// ```
  static Widget wrapWithMonitor({required Widget child}) {
    if (kIsWeb) return child;
    return TalkerWrapper(talker: instance, child: child);
  }
}

/// Extension to add TalkerDioLogger to Dio instances easily
extension DioTalkerExtension on Dio {
  /// Adds TalkerDioLogger interceptor to this Dio instance
  void addTalkerInterceptor() {
    interceptors.add(TalkerService.dioLogger);
  }
}
