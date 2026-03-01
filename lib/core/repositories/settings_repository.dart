import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Repository for user settings persistence
///
/// Manages app-wide settings like language, theme, and preferences.
class SettingsRepository {
  static const String _languageCodeKey = 'language_code';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _rideRemindersKey = 'ride_reminders';
  static const String _chatNotificationsKey = 'chat_notifications';
  static const String _marketingEmailsKey = 'marketing_emails';
  static const String _autoAcceptRidesKey = 'auto_accept_rides';
  static const String _showLocationKey = 'show_location';
  static const String _publicProfileKey = 'public_profile';
  static const String _distanceUnitKey = 'distance_unit';
  static const String _savedEmailKey = 'saved_email';
  static const String _rememberMeKey = 'remember_me';

  final SharedPreferences _prefs;

  SettingsRepository(this._prefs);

  // ============================================================
  // Language Settings
  // ============================================================

  /// Get the saved language code (e.g., 'en', 'fr')
  ///
  /// Returns null if no language has been saved (use system default)
  String? get languageCode {
    return _prefs.getString(_languageCodeKey);
  }

  /// Get locale from saved language code
  ///
  /// Returns null if no language has been saved (use system default)
  Locale? get locale {
    final code = languageCode;
    return code != null ? Locale(code) : null;
  }

  /// Save language preference
  ///
  /// Pass language code like 'en' or 'fr'
  Future<void> setLanguage(String languageCode) async {
    await _prefs.setString(_languageCodeKey, languageCode);
  }

  /// Clear language preference (use system default)
  Future<void> clearLanguage() async {
    await _prefs.remove(_languageCodeKey);
  }

  // ============================================================
  // Notification Settings
  // ============================================================

  /// Whether push notifications are enabled (defaults to true)
  bool get notificationsEnabled {
    return _prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  /// Save push notifications preference
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(_notificationsEnabledKey, enabled);
  }

  /// Whether ride reminders are enabled (defaults to true)
  bool get rideReminders {
    return _prefs.getBool(_rideRemindersKey) ?? true;
  }

  /// Save ride reminders preference
  Future<void> setRideReminders(bool enabled) async {
    await _prefs.setBool(_rideRemindersKey, enabled);
  }

  /// Whether chat notifications are enabled (defaults to true)
  bool get chatNotifications {
    return _prefs.getBool(_chatNotificationsKey) ?? true;
  }

  /// Save chat notifications preference
  Future<void> setChatNotifications(bool enabled) async {
    await _prefs.setBool(_chatNotificationsKey, enabled);
  }

  /// Whether marketing emails are enabled (defaults to false)
  bool get marketingEmails {
    return _prefs.getBool(_marketingEmailsKey) ?? false;
  }

  /// Save marketing emails preference
  Future<void> setMarketingEmails(bool enabled) async {
    await _prefs.setBool(_marketingEmailsKey, enabled);
  }

  // ============================================================
  // Privacy & Safety Settings
  // ============================================================

  /// Whether auto-accept rides is enabled (defaults to false)
  bool get autoAcceptRides {
    return _prefs.getBool(_autoAcceptRidesKey) ?? false;
  }

  /// Save auto-accept rides preference
  Future<void> setAutoAcceptRides(bool enabled) async {
    await _prefs.setBool(_autoAcceptRidesKey, enabled);
  }

  /// Whether to show real-time location during rides (defaults to true)
  bool get showLocation {
    return _prefs.getBool(_showLocationKey) ?? true;
  }

  /// Save show location preference
  Future<void> setShowLocation(bool enabled) async {
    await _prefs.setBool(_showLocationKey, enabled);
  }

  /// Whether profile is public (defaults to true)
  bool get publicProfile {
    return _prefs.getBool(_publicProfileKey) ?? true;
  }

  /// Save public profile preference
  Future<void> setPublicProfile(bool enabled) async {
    await _prefs.setBool(_publicProfileKey, enabled);
  }

  // ============================================================
  // Appearance Settings
  // ============================================================

  /// Get distance unit preference ('km' or 'miles', defaults to 'km')
  String get distanceUnit {
    return _prefs.getString(_distanceUnitKey) ?? 'km';
  }

  /// Save distance unit preference
  Future<void> setDistanceUnit(String unit) async {
    await _prefs.setString(_distanceUnitKey, unit);
  }

  // ============================================================
  // Login Credentials
  // ============================================================

  /// Last email saved by the "remember me" feature.
  String? get savedEmail => _prefs.getString(_savedEmailKey);

  /// Whether the user opted to have their email pre-filled on next login.
  bool get rememberMe => _prefs.getBool(_rememberMeKey) ?? false;

  /// Persists the [email] and sets the remember-me flag to true.
  Future<void> saveCredentials({required String email}) async {
    await _prefs.setString(_savedEmailKey, email);
    await _prefs.setBool(_rememberMeKey, true);
  }

  /// Clears saved credentials and resets the remember-me flag.
  Future<void> clearCredentials() async {
    await _prefs.remove(_savedEmailKey);
    await _prefs.setBool(_rememberMeKey, false);
  }
}
