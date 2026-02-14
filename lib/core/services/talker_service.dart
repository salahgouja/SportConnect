import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:talker_riverpod_logger/talker_riverpod_logger.dart';
import 'package:dio/dio.dart';

/// Centralized Talker service for logging across the app
///
/// Provides:
/// - Global Talker instance for app-wide logging
/// - TalkerDioLogger for HTTP request/response logging
/// - TalkerRiverpodObserver for Riverpod state management logging
/// - TalkerScreen for viewing logs in-app
class TalkerService {
  TalkerService._();

  static Talker? _instance;

  /// Global Talker instance
  static Talker get instance {
    _instance ??= TalkerFlutter.init(
      settings: TalkerSettings(
        enabled: true,
        useConsoleLogs: kDebugMode,
        maxHistoryItems: 1000,
      ),
      logger: TalkerLogger(
        output: debugPrint,
        settings: TalkerLoggerSettings(enableColors: true, maxLineWidth: 120),
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
      printRequestHeaders: kDebugMode,
      printResponseHeaders: kDebugMode,
      printRequestData: kDebugMode,
      printResponseData: kDebugMode,
      printResponseMessage: true,
      // Custom colors for better visibility
      requestPen: AnsiPen()..cyan(),
      responsePen: AnsiPen()..green(),
      errorPen: AnsiPen()..red(),
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
      enabled: true,
      printProviderAdded: true,
      printProviderUpdated: true,
      printProviderDisposed: true,
      printProviderFailed: true,
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

  /// Navigate to the TalkerScreen to view all logs
  ///
  /// Usage:
  /// ```dart
  /// TalkerService.showLogScreen(context);
  /// ```
  static void showLogScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => TalkerScreen(talker: instance)),
    );
  }

  /// Get a TalkerRouteObserver for navigation logging
  ///
  /// Usage:
  /// ```dart
  /// MaterialApp(
  ///   localizationsDelegates: AppLocalizations.localizationsDelegates,
  ///   supportedLocales: AppLocalizations.supportedLocales,
  ///   navigatorObservers: [TalkerService.routeObserver],
  /// )
  /// ```
  static TalkerRouteObserver get routeObserver => TalkerRouteObserver(instance);

  /// Wrap a widget with TalkerWrapper for error boundary
  ///
  /// Usage:
  /// ```dart
  /// TalkerService.wrapWithMonitor(
  ///   child: MyWidget(),
  /// )
  /// ```
  static Widget wrapWithMonitor({required Widget child}) {
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
