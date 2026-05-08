import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sport_connect/core/services/firebase_service.dart';

part 'settings_repository.g.dart';

@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(Ref ref) {
  throw UnimplementedError(
    'Override sharedPreferencesProvider in ProviderScope.',
  );
}

@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) {
  return SettingsRepository(
    ref.watch(sharedPreferencesProvider),
    ref.watch(firebaseServiceProvider),
  );
}

/// Repository for user settings persistence.
///
/// Manages app-wide settings like language, map style, notification settings,
/// privacy settings, analytics preferences, and saved login credentials.
class SettingsRepository {
  SettingsRepository(this._prefs, this._analyticsService);

  static const String _languageCodeKey = 'language_code';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _rideRemindersKey = 'ride_reminders';
  static const String _chatNotificationsKey = 'chat_notifications';
  static const String _marketingEmailsKey = 'marketing_emails';
  static const String _showLocationKey = 'show_location';
  static const String _publicProfileKey = 'public_profile';
  static const String _notificationDialogShownKey = 'notification_dialog_shown';
  static const String _analyticsEnabledKey = 'analytics_enabled';
  static const String _premiumPromptPrefix = 'premium_prompt_seen_';
  static const String _driverShowOnMapKey = 'driver_show_on_map';
  static const String _driverAllowInstantBookingKey =
      'driver_allow_instant_booking';

  final SharedPreferences _prefs;
  final FirebaseService _analyticsService;
  // ============================================================
  // Language Settings
  // ============================================================

  String? get languageCode => _prefs.getString(_languageCodeKey);

  Locale? get locale {
    final code = languageCode;
    return code != null ? Locale(code) : null;
  }

  Future<Locale> setLanguage(String languageCode) async {
    await _prefs.setString(_languageCodeKey, languageCode);
    return Locale(languageCode);
  }

  Future<void> clearLanguage() async {
    await _prefs.remove(_languageCodeKey);
  }

  // ============================================================
  // Notification Settings
  // ============================================================

  bool get notificationsEnabled {
    return _prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  Future<bool> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(_notificationsEnabledKey, enabled);
    return enabled;
  }

  bool get rideReminders {
    return _prefs.getBool(_rideRemindersKey) ?? true;
  }

  Future<bool> setRideReminders(bool enabled) async {
    await _prefs.setBool(_rideRemindersKey, enabled);
    return enabled;
  }

  bool get chatNotifications {
    return _prefs.getBool(_chatNotificationsKey) ?? true;
  }

  Future<bool> setChatNotifications(bool enabled) async {
    await _prefs.setBool(_chatNotificationsKey, enabled);
    return enabled;
  }

  bool get marketingEmails {
    return _prefs.getBool(_marketingEmailsKey) ?? false;
  }

  Future<bool> setMarketingEmails(bool enabled) async {
    await _prefs.setBool(_marketingEmailsKey, enabled);
    return enabled;
  }

  // ============================================================
  // Privacy & Safety Settings
  // ============================================================

  bool get showLocation {
    return _prefs.getBool(_showLocationKey) ?? true;
  }

  Future<bool> setShowLocation(bool enabled) async {
    await _prefs.setBool(_showLocationKey, enabled);
    return enabled;
  }

  bool get publicProfile {
    return _prefs.getBool(_publicProfileKey) ?? true;
  }

  Future<bool> setPublicProfile(bool enabled) async {
    await _prefs.setBool(_publicProfileKey, enabled);
    return enabled;
  }

  // ============================================================
  // Analytics & Crash Reporting
  // ============================================================

  bool get analyticsEnabled {
    return _prefs.getBool(_analyticsEnabledKey) ?? false;
  }

  Future<bool> setAnalyticsEnabled({required bool enabled}) async {
    await _prefs.setBool(_analyticsEnabledKey, enabled);
    await _analyticsService.setCollectionEnabled(enabled: enabled);
    return enabled;
  }

  // ============================================================
  // Notification Dialog
  // ============================================================

  bool get notificationDialogShown {
    return _prefs.getBool(_notificationDialogShownKey) ?? false;
  }

  Future<bool> setNotificationDialogShown({bool value = true}) async {
    await _prefs.setBool(_notificationDialogShownKey, value);
    return value;
  }

  // ============================================================
  // Premium Prompt
  // ============================================================

  bool premiumPromptSeenFor(String uid) {
    return _prefs.getBool('$_premiumPromptPrefix$uid') ?? false;
  }

  Future<void> setPremiumPromptSeen(String uid) async {
    await _prefs.setBool('$_premiumPromptPrefix$uid', true);
  }

  // ============================================================
  // Driver Settings
  // ============================================================

  bool get driverAllowInstantBooking {
    return _prefs.getBool(_driverAllowInstantBookingKey) ?? true;
  }

  Future<bool> setDriverAllowInstantBooking(bool value) async {
    await _prefs.setBool(_driverAllowInstantBookingKey, value);
    return value;
  }

  bool get driverShowOnMap {
    return _prefs.getBool(_driverShowOnMapKey) ?? true;
  }

  Future<bool> setDriverShowOnMap(bool value) async {
    await _prefs.setBool(_driverShowOnMapKey, value);
    return value;
  }
}
