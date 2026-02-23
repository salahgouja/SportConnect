import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/repositories/settings_repository.dart';

part 'settings_provider.g.dart';

/// Provider for current app locale
///
/// Reads from SettingsRepository and provides reactive locale state.
/// Returns null if user hasn't set a preference (app will use system locale).
@riverpod
class LocaleProvider extends _$LocaleProvider {
  @override
  Future<Locale?> build() async {
    final repository = await ref.watch(settingsRepositoryProvider.future);
    return repository.locale;
  }

  /// Change app language
  ///
  /// Pass language code like 'en' or 'fr'
  Future<void> setLanguage(String languageCode) async {
    final repository = await ref.read(settingsRepositoryProvider.future);
    await repository.setLanguage(languageCode);

    // Update state to trigger rebuild
    state = AsyncValue.data(Locale(languageCode));
  }

  /// Clear language preference (use system default)
  Future<void> clearLanguage() async {
    final repository = await ref.read(settingsRepositoryProvider.future);
    await repository.clearLanguage();

    // Update state to trigger rebuild
    state = const AsyncValue.data(null);
  }
}

/// Provider for push notifications setting
@riverpod
class NotificationsEnabledProvider extends _$NotificationsEnabledProvider {
  @override
  Future<bool> build() async {
    final repository = await ref.watch(settingsRepositoryProvider.future);
    return repository.notificationsEnabled;
  }

  /// Set push notifications enabled/disabled
  Future<void> setEnabled(bool enabled) async {
    final repository = await ref.read(settingsRepositoryProvider.future);
    await repository.setNotificationsEnabled(enabled);
    state = AsyncValue.data(enabled);
  }
}

/// Provider for ride reminders setting
@riverpod
class RideRemindersProvider extends _$RideRemindersProvider {
  @override
  Future<bool> build() async {
    final repository = await ref.watch(settingsRepositoryProvider.future);
    return repository.rideReminders;
  }

  /// Set ride reminders enabled/disabled
  Future<void> setEnabled(bool enabled) async {
    final repository = await ref.read(settingsRepositoryProvider.future);
    await repository.setRideReminders(enabled);
    state = AsyncValue.data(enabled);
  }
}

/// Provider for chat notifications setting
@riverpod
class ChatNotificationsProvider extends _$ChatNotificationsProvider {
  @override
  Future<bool> build() async {
    final repository = await ref.watch(settingsRepositoryProvider.future);
    return repository.chatNotifications;
  }

  /// Set chat notifications enabled/disabled
  Future<void> setEnabled(bool enabled) async {
    final repository = await ref.read(settingsRepositoryProvider.future);
    await repository.setChatNotifications(enabled);
    state = AsyncValue.data(enabled);
  }
}

/// Provider for marketing emails setting
@riverpod
class MarketingEmailsProvider extends _$MarketingEmailsProvider {
  @override
  Future<bool> build() async {
    final repository = await ref.watch(settingsRepositoryProvider.future);
    return repository.marketingEmails;
  }

  /// Set marketing emails enabled/disabled
  Future<void> setEnabled(bool enabled) async {
    final repository = await ref.read(settingsRepositoryProvider.future);
    await repository.setMarketingEmails(enabled);
    state = AsyncValue.data(enabled);
  }
}

/// Provider for auto-accept rides setting
@riverpod
class AutoAcceptRidesProvider extends _$AutoAcceptRidesProvider {
  @override
  Future<bool> build() async {
    final repository = await ref.watch(settingsRepositoryProvider.future);
    return repository.autoAcceptRides;
  }

  /// Set auto-accept rides enabled/disabled
  Future<void> setEnabled(bool enabled) async {
    final repository = await ref.read(settingsRepositoryProvider.future);
    await repository.setAutoAcceptRides(enabled);
    state = AsyncValue.data(enabled);
  }
}

/// Provider for show location setting
@riverpod
class ShowLocationProvider extends _$ShowLocationProvider {
  @override
  Future<bool> build() async {
    final repository = await ref.watch(settingsRepositoryProvider.future);
    return repository.showLocation;
  }

  /// Set show location enabled/disabled
  Future<void> setEnabled(bool enabled) async {
    final repository = await ref.read(settingsRepositoryProvider.future);
    await repository.setShowLocation(enabled);
    state = AsyncValue.data(enabled);
  }
}

/// Provider for public profile setting
@riverpod
class PublicProfileProvider extends _$PublicProfileProvider {
  @override
  Future<bool> build() async {
    final repository = await ref.watch(settingsRepositoryProvider.future);
    return repository.publicProfile;
  }

  /// Set public profile enabled/disabled
  Future<void> setEnabled(bool enabled) async {
    final repository = await ref.read(settingsRepositoryProvider.future);
    await repository.setPublicProfile(enabled);
    state = AsyncValue.data(enabled);
  }
}

/// Provider for distance unit setting ('km' or 'miles')
@riverpod
class DistanceUnitProvider extends _$DistanceUnitProvider {
  @override
  Future<String> build() async {
    final repository = await ref.watch(settingsRepositoryProvider.future);
    return repository.distanceUnit;
  }

  /// Set distance unit preference
  Future<void> setUnit(String unit) async {
    final repository = await ref.read(settingsRepositoryProvider.future);
    await repository.setDistanceUnit(unit);
    state = AsyncValue.data(unit);
  }
}
