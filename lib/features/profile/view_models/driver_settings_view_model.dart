import 'package:flutter_riverpod/flutter_riverpod.dart';

class DriverSettingsState {
  const DriverSettingsState({
    this.autoAcceptRequests = false,
    this.acceptCashPayments = true,
    this.acceptCardPayments = true,
    this.showOnMap = true,
    this.allowInstantBooking = true,
    this.soundEffects = true,
    this.vibration = true,
    this.nightMode = false,
    this.maxDistance = 25.0,
    this.selectedLanguage = 'English',
    this.navigationApp = 'In-App',
  });

  final bool autoAcceptRequests;
  final bool acceptCashPayments;
  final bool acceptCardPayments;
  final bool showOnMap;
  final bool allowInstantBooking;
  final bool soundEffects;
  final bool vibration;
  final bool nightMode;
  final double maxDistance;
  final String selectedLanguage;
  final String navigationApp;

  DriverSettingsState copyWith({
    bool? autoAcceptRequests,
    bool? acceptCashPayments,
    bool? acceptCardPayments,
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
      autoAcceptRequests: autoAcceptRequests ?? this.autoAcceptRequests,
      acceptCashPayments: acceptCashPayments ?? this.acceptCashPayments,
      acceptCardPayments: acceptCardPayments ?? this.acceptCardPayments,
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

class DriverSettingsViewModel extends Notifier<DriverSettingsState> {
  @override
  DriverSettingsState build() => const DriverSettingsState();

  void setAutoAcceptRequests(bool value) {
    state = state.copyWith(autoAcceptRequests: value);
  }

  void setAllowInstantBooking(bool value) {
    state = state.copyWith(allowInstantBooking: value);
  }

  void setAcceptCashPayments(bool value) {
    if (!value && !state.acceptCardPayments) {
      return;
    }
    state = state.copyWith(acceptCashPayments: value);
  }

  void setAcceptCardPayments(bool value) {
    if (!value && !state.acceptCashPayments) {
      return;
    }
    state = state.copyWith(acceptCardPayments: value);
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

final driverSettingsViewModelProvider =
    NotifierProvider<DriverSettingsViewModel, DriverSettingsState>(
      DriverSettingsViewModel.new,
    );
