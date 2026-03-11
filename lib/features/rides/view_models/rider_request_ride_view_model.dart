import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:sport_connect/core/models/location/location_point.dart';
import 'package:sport_connect/features/events/models/event_model.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/models/ride_search_filters.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';

class RiderRequestRideState {
  RiderRequestRideState({
    this.fromLocation,
    this.toLocation,
    this.fromAddress = '',
    this.toAddress = '',
    DateTime? date,
    TimeOfDay? time,
    this.passengers = 1,
    this.event,
    this.showResults = false,
    this.sort = 'recommended',
    this.errorMessage,
  }) : date = date ?? DateTime.now(),
       time = time ?? TimeOfDay.now();

  final LatLng? fromLocation;
  final LatLng? toLocation;
  final String fromAddress;
  final String toAddress;
  final DateTime date;
  final TimeOfDay time;
  final int passengers;
  final EventModel? event;
  final bool showResults;
  final String sort;
  final String? errorMessage;

  RiderRequestRideState copyWith({
    LatLng? fromLocation,
    bool clearFromLocation = false,
    LatLng? toLocation,
    bool clearToLocation = false,
    String? fromAddress,
    String? toAddress,
    DateTime? date,
    TimeOfDay? time,
    int? passengers,
    EventModel? event,
    bool clearEvent = false,
    bool? showResults,
    String? sort,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RiderRequestRideState(
      fromLocation: clearFromLocation ? null : (fromLocation ?? this.fromLocation),
      toLocation: clearToLocation ? null : (toLocation ?? this.toLocation),
      fromAddress: fromAddress ?? this.fromAddress,
      toAddress: toAddress ?? this.toAddress,
      date: date ?? this.date,
      time: time ?? this.time,
      passengers: passengers ?? this.passengers,
      event: clearEvent ? null : (event ?? this.event),
      showResults: showResults ?? this.showResults,
      sort: sort ?? this.sort,
      errorMessage: clearError ? null : errorMessage,
    );
  }

  bool get hasSameOriginAndDestination {
    final from = fromLocation;
    final to = toLocation;
    if (from == null || to == null) return false;
    return from.latitude == to.latitude && from.longitude == to.longitude;
  }

  bool get canSearch =>
      fromLocation != null && toLocation != null && !hasSameOriginAndDestination;

  DateTime get departureDateTime => DateTime(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
  );
}

class RiderRequestRideViewModel extends Notifier<RiderRequestRideState> {
  @override
  RiderRequestRideState build() => RiderRequestRideState();

  void setFromLocation(LatLng? location, String address) {
    state = state.copyWith(
      fromLocation: location,
      fromAddress: address,
      clearFromLocation: location == null,
      clearError: true,
    );
  }

  void setToLocation(LatLng? location, String address) {
    state = state.copyWith(
      toLocation: location,
      toAddress: address,
      clearToLocation: location == null,
      clearError: true,
    );
  }

  void swapLocations() {
    state = state.copyWith(
      fromLocation: state.toLocation,
      fromAddress: state.toAddress,
      toLocation: state.fromLocation,
      toAddress: state.fromAddress,
      clearError: true,
    );
  }

  void setDate(DateTime date) {
    state = state.copyWith(date: date, clearError: true);
  }

  void setTime(TimeOfDay time) {
    state = state.copyWith(time: time, clearError: true);
  }

  void incrementPassengers() {
    state = state.copyWith(
      passengers: (state.passengers + 1).clamp(1, 6),
      clearError: true,
    );
  }

  void decrementPassengers() {
    state = state.copyWith(
      passengers: (state.passengers - 1).clamp(1, 6),
      clearError: true,
    );
  }

  void setEvent(EventModel? event) {
    state = state.copyWith(event: event, clearEvent: event == null, clearError: true);
  }

  void setSort(String sort) {
    state = state.copyWith(sort: sort);
  }

  void hideResults() {
    state = state.copyWith(showResults: false, clearError: true);
  }

  String? _validateSearch() {
    if (state.fromLocation == null || state.toLocation == null) {
      return 'Please select both pickup and drop-off locations.';
    }
    if (state.hasSameOriginAndDestination) {
      return 'Pickup and drop-off locations cannot be the same.';
    }
    final departure = state.departureDateTime;
    if (departure.isBefore(DateTime.now())) {
      return 'Departure date and time must be in the future.';
    }
    if (state.passengers < 1 || state.passengers > 6) {
      return 'Passengers must be between 1 and 6.';
    }
    return null;
  }

  Future<void> searchRides() async {
    final validationError = _validateSearch();
    if (validationError != null) {
      state = state.copyWith(errorMessage: validationError);
      return;
    }

    final filters = RideSearchFilters(
      origin: LocationPoint(
        address: state.fromAddress,
        latitude: state.fromLocation!.latitude,
        longitude: state.fromLocation!.longitude,
      ),
      destination: LocationPoint(
        address: state.toAddress,
        latitude: state.toLocation!.latitude,
        longitude: state.toLocation!.longitude,
      ),
      departureDate: state.departureDateTime,
      minSeats: state.passengers,
    );

    ref.read(rideSearchViewModelProvider.notifier).updateFilters(filters);
    await ref.read(rideSearchViewModelProvider.notifier).searchRides();
    if (!ref.mounted) return;
    state = state.copyWith(showResults: true, clearError: true);
  }
}

final riderRequestRideViewModelProvider =
    NotifierProvider<RiderRequestRideViewModel, RiderRequestRideState>(
      RiderRequestRideViewModel.new,
    );

final riderRequestSortedRidesProvider = Provider<List<RideModel>>((ref) {
  final rides = List<RideModel>.of(ref.watch(rideSearchViewModelProvider).rides);
  final sort = ref.watch(riderRequestRideViewModelProvider).sort;
  switch (sort) {
    case 'earliest':
      rides.sort((a, b) => a.departureTime.compareTo(b.departureTime));
      break;
    case 'price':
      rides.sort((a, b) => a.pricePerSeat.compareTo(b.pricePerSeat));
      break;
    case 'rating':
      rides.sort((a, b) => b.averageRating.compareTo(a.averageRating));
      break;
    default:
      break;
  }
  return rides;
});