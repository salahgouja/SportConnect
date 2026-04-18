import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'driver_settings_view_model.g.dart';

class DriverSettingsState {
  const DriverSettingsState({
    this.showOnMap = true,
    this.allowInstantBooking = true,
    this.soundEffects = true,
    this.vibration = true,
    this.nightMode = false,
    this.maxDistance = 25.0,
    this.selectedLanguage = 'English',
    this.navigationApp = 'In-App',
  });

  final bool showOnMap;
  final bool allowInstantBooking;
  final bool soundEffects;
  final bool vibration;
  final bool nightMode;
  final double maxDistance;
  final String selectedLanguage;
  final String navigationApp;

  DriverSettingsState copyWith({
    bool? showOnMap,
    bool? allowInstantBooking,
    bool? soundEffects,
    bool? vibration,
    bool? nightMode,
    double? maxDistance,
    String? selectedLanguage,
    String? navigationApp,
  }) {
    return DriverSettingsState(
      showOnMap: showOnMap ?? this.showOnMap,
      allowInstantBooking: allowInstantBooking ?? this.allowInstantBooking,
      soundEffects: soundEffects ?? this.soundEffects,
      vibration: vibration ?? this.vibration,
      nightMode: nightMode ?? this.nightMode,
      maxDistance: maxDistance ?? this.maxDistance,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      navigationApp: navigationApp ?? this.navigationApp,
    );
  }
}

@riverpod
class DriverSettingsViewModel extends _$DriverSettingsViewModel {
  @override
  DriverSettingsState build() => const DriverSettingsState();

  void setAllowInstantBooking(bool value) {
    state = state.copyWith(allowInstantBooking: value);
  }

  void setShowOnMap(bool value) {
    state = state.copyWith(showOnMap: value);
  }

  void setSoundEffects(bool value) {
    state = state.copyWith(soundEffects: value);
  }

  void setVibration(bool value) {
    state = state.copyWith(vibration: value);
  }

  void setNightMode(bool value) {
    state = state.copyWith(nightMode: value);
  }

  void setMaxDistance(double value) {
    state = state.copyWith(maxDistance: value.clamp(5.0, 50.0));
  }

  void setSelectedLanguage(String value) {
    state = state.copyWith(selectedLanguage: value);
  }

  void setNavigationApp(String value) {
    state = state.copyWith(navigationApp: value);
  }
}
