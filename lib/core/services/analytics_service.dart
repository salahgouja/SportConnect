import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:sport_connect/core/services/talker_service.dart';

/// Centralized analytics and crash-reporting service.
///
/// Wraps [FirebaseAnalytics] and [FirebaseCrashlytics] behind a single
/// facade so the rest of the app never touches the Firebase SDKs directly.
class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService instance = AnalyticsService._();

  late final FirebaseAnalytics _analytics;
  late final FirebaseCrashlytics _crashlytics;

  bool _initialized = false;

  // ── Initialization ────────────────────────────────────────────────

  /// Call once during app startup, **after** [FirebaseService.initialize].
  Future<void> initialize() async {
    if (_initialized) return;

    _analytics = FirebaseAnalytics.instance;
    _crashlytics = FirebaseCrashlytics.instance;

    // Disable crash collection in debug to keep the console clean.
    await _crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);

    _initialized = true;
    TalkerService.info('✅ Analytics & Crashlytics initialized');
  }

  // ── Analytics helpers ─────────────────────────────────────────────

  /// The observer to attach to [GoRouter] (or [MaterialApp.navigatorObservers]).
  FirebaseAnalyticsObserver get navigatorObserver =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  /// Log a named event with optional parameters.
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
    } catch (e) {
      TalkerService.error('Analytics logEvent failed', e);
    }
  }

  /// Identify the current user across both Analytics and Crashlytics.
  Future<void> setUserId(String? userId) async {
    await _analytics.setUserId(id: userId);
    await _crashlytics.setUserIdentifier(userId ?? '');
  }

  /// Attach a persistent property that is sent with every future event.
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  /// Screen-view logging (auto-tracked by observer, but useful for
  /// bottom-sheets, dialogs, and other non-route views).
  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  // ── Auth events ───────────────────────────────────────────────────

  Future<void> logLogin(String method) =>
      _analytics.logLogin(loginMethod: method);

  Future<void> logSignUp(String method) =>
      _analytics.logSignUp(signUpMethod: method);

  // ── Crashlytics helpers ───────────────────────────────────────────

  /// Record a non-fatal error (shows as a "non-fatal" in the Firebase console).
  void recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) {
    _crashlytics.recordError(
      exception,
      stack,
      reason: reason ?? 'non-fatal',
      fatal: fatal,
    );
  }

  /// Log a breadcrumb message visible in the crash report timeline.
  void log(String message) => _crashlytics.log(message);

  /// Attach a key/value visible in every future crash report.
  Future<void> setCustomKey(String key, Object value) =>
      _crashlytics.setCustomKey(key, value);
}
