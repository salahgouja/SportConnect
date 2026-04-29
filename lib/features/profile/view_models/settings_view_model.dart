import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/repositories/settings_repository.dart';

part 'settings_view_model.g.dart';

const Object _unset = Object();

class SettingsState {
  const SettingsState({
    this.languageCode,
    this.locale,
    this.notificationsEnabled = true,
    this.rideReminders = true,
    this.chatNotifications = true,
    this.showLocation = true,
    this.publicProfile = true,
    this.analyticsEnabled = true,
    this.mapStyle = 'standard',
    this.driverAllowInstantBooking = true,
    this.driverMaxDistance = 25.0,
    this.driverShowOnMap = true,
    this.driverNavigationApp = 'In-App',
    this.notificationDialogShown = false,
  });

  factory SettingsState.fromRepository(SettingsRepository repository) {
    return SettingsState(
      languageCode: repository.languageCode,
      locale: repository.locale,
      notificationsEnabled: repository.notificationsEnabled,
      rideReminders: repository.rideReminders,
      chatNotifications: repository.chatNotifications,
      showLocation: repository.showLocation,
      publicProfile: repository.publicProfile,
      analyticsEnabled: repository.analyticsEnabled,
      mapStyle: repository.mapStyle,
      driverAllowInstantBooking: repository.driverAllowInstantBooking,
      driverMaxDistance: repository.driverMaxDistance,
      driverShowOnMap: repository.driverShowOnMap,
      driverNavigationApp: repository.driverNavigationApp,
      notificationDialogShown: repository.notificationDialogShown,
    );
  }

  final String? languageCode;
  final Locale? locale;

  final bool notificationsEnabled;
  final bool rideReminders;
  final bool chatNotifications;

  final bool showLocation;
  final bool publicProfile;

  final bool analyticsEnabled;
  final String mapStyle;

  final bool driverAllowInstantBooking;
  final double driverMaxDistance;
  final bool driverShowOnMap;
  final String driverNavigationApp;

  final bool notificationDialogShown;

  SettingsState copyWith({
    Object? languageCode = _unset,
    Object? locale = _unset,
    bool? notificationsEnabled,
    bool? rideReminders,
    bool? chatNotifications,
    bool? showLocation,
    bool? publicProfile,
    bool? analyticsEnabled,
    String? mapStyle,
    bool? driverAllowInstantBooking,
    double? driverMaxDistance,
    bool? driverShowOnMap,
    String? driverNavigationApp,
    bool? notificationDialogShown,
  }) {
    return SettingsState(
      languageCode: identical(languageCode, _unset)
          ? this.languageCode
          : languageCode as String?,
      locale: identical(locale, _unset) ? this.locale : locale as Locale?,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      rideReminders: rideReminders ?? this.rideReminders,
      chatNotifications: chatNotifications ?? this.chatNotifications,
      showLocation: showLocation ?? this.showLocation,
      publicProfile: publicProfile ?? this.publicProfile,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      mapStyle: mapStyle ?? this.mapStyle,
      driverAllowInstantBooking:
          driverAllowInstantBooking ?? this.driverAllowInstantBooking,
      driverMaxDistance: driverMaxDistance ?? this.driverMaxDistance,
      driverShowOnMap: driverShowOnMap ?? this.driverShowOnMap,
      driverNavigationApp: driverNavigationApp ?? this.driverNavigationApp,
      notificationDialogShown:
          notificationDialogShown ?? this.notificationDialogShown,
    );
  }
}

@riverpod
class SettingsViewModel extends _$SettingsViewModel {
  SettingsRepository get _repository => ref.read(settingsRepositoryProvider);

  @override
  SettingsState build() {
    final repository = ref.watch(settingsRepositoryProvider);
    return SettingsState.fromRepository(repository);
  }

  Future<void> setLanguage(String languageCode) async {
    final locale = await _repository.setLanguage(languageCode);

    if (!ref.mounted) return;

    state = state.copyWith(
      languageCode: languageCode,
      locale: locale,
    );
  }

  Future<void> clearLanguage() async {
    await _repository.clearLanguage();

    if (!ref.mounted) return;

    state = state.copyWith(
      languageCode: null,
      locale: null,
    );
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final value = await _repository.setNotificationsEnabled(enabled);

    if (!ref.mounted) return;

    state = state.copyWith(notificationsEnabled: value);
  }

  Future<void> setRideReminders(bool enabled) async {
    final value = await _repository.setRideReminders(enabled);

    if (!ref.mounted) return;

    state = state.copyWith(rideReminders: value);
  }

  Future<void> setChatNotifications(bool enabled) async {
    final value = await _repository.setChatNotifications(enabled);

    if (!ref.mounted) return;

    state = state.copyWith(chatNotifications: value);
  }

  Future<void> setShowLocation(bool enabled) async {
    final value = await _repository.setShowLocation(enabled);

    if (!ref.mounted) return;

    state = state.copyWith(showLocation: value);
  }

  Future<void> setPublicProfile(bool enabled) async {
    final value = await _repository.setPublicProfile(enabled);

    if (!ref.mounted) return;

    state = state.copyWith(publicProfile: value);
  }

  Future<void> setAnalyticsEnabled({required bool enabled}) async {
    final value = await _repository.setAnalyticsEnabled(enabled: enabled);

    if (!ref.mounted) return;

    state = state.copyWith(analyticsEnabled: value);
  }

  Future<void> setMapStyle(String style) async {
    final value = await _repository.setMapStyle(style);

    if (!ref.mounted) return;

    state = state.copyWith(mapStyle: value);
  }

  Future<void> setDriverAllowInstantBooking(bool value) async {
    final updatedValue = await _repository.setDriverAllowInstantBooking(value);

    if (!ref.mounted) return;

    state = state.copyWith(driverAllowInstantBooking: updatedValue);
  }

  Future<void> setDriverMaxDistance(double value) async {
    final updatedValue = await _repository.setDriverMaxDistance(value);

    if (!ref.mounted) return;

    state = state.copyWith(driverMaxDistance: updatedValue);
  }

  Future<void> setDriverShowOnMap(bool value) async {
    final updatedValue = await _repository.setDriverShowOnMap(value);

    if (!ref.mounted) return;

    state = state.copyWith(driverShowOnMap: updatedValue);
  }

  Future<void> setDriverNavigationApp(String value) async {
    final updatedValue = await _repository.setDriverNavigationApp(value);

    if (!ref.mounted) return;

    state = state.copyWith(driverNavigationApp: updatedValue);
  }

  Future<void> setNotificationDialogShown({bool value = true}) async {
    final updatedValue = await _repository.setNotificationDialogShown(
      value: value,
    );

    if (!ref.mounted) return;

    state = state.copyWith(notificationDialogShown: updatedValue);
  }
}
