import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_view_model.g.dart';

/// State for the home screen
class HomeState {
  final int selectedTabIndex;
  final bool isMapExpanded;
  final LatLng? currentLocation;
  final bool isLoadingLocation;
  final String? locationError;

  const HomeState({
    this.selectedTabIndex = 0,
    this.isMapExpanded = true,
    this.currentLocation,
    this.isLoadingLocation = false,
    this.locationError,
  });

  HomeState copyWith({
    int? selectedTabIndex,
    bool? isMapExpanded,
    LatLng? currentLocation,
    bool? isLoadingLocation,
    String? locationError,
  }) {
    return HomeState(
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      isMapExpanded: isMapExpanded ?? this.isMapExpanded,
      currentLocation: currentLocation ?? this.currentLocation,
      isLoadingLocation: isLoadingLocation ?? this.isLoadingLocation,
      locationError: locationError,
    );
  }
}

/// ViewModel for the home screen
/// Manages navigation state, map expansion, and location
@riverpod
class HomeViewModel extends _$HomeViewModel {
  @override
  HomeState build() {
    return const HomeState();
  }

  /// Set the current tab index
  void setTabIndex(int index) {
    state = state.copyWith(selectedTabIndex: index);
  }

  /// Toggle map expansion
  void toggleMapExpansion() {
    state = state.copyWith(isMapExpanded: !state.isMapExpanded);
  }

  /// Set current location
  void setCurrentLocation(LatLng location) {
    state = state.copyWith(
      currentLocation: location,
      isLoadingLocation: false,
      locationError: null,
    );
  }

  /// Set location loading state
  void setLocationLoading(bool isLoading) {
    state = state.copyWith(isLoadingLocation: isLoading);
  }

  /// Set location error
  void setLocationError(String error) {
    state = state.copyWith(locationError: error, isLoadingLocation: false);
  }
}

// Note: Use nearbyRidesStreamProvider and hotspotsStreamProvider from home_repository.dart
// instead of the old Map-based providers that were here before.
