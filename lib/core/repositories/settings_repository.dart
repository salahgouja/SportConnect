import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_repository.g.dart';

@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(Ref ref) {
  throw UnimplementedError(
    'Override sharedPreferencesProvider in ProviderScope.',
  );
}

@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) {
  return SettingsRepository(ref.watch(sharedPreferencesProvider));
}

/// Repository for user settings persistence.
///
/// Manages app-wide settings that are actually wired into app behavior.
class SettingsRepository {
  SettingsRepository(this._prefs);

  static const String _languageCodeKey = 'language_code';
  static const String _notificationDialogShownKey = 'notification_dialog_shown';
  static const String _premiumPromptPrefix = 'premium_prompt_seen_';

  final SharedPreferences _prefs;
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

}
