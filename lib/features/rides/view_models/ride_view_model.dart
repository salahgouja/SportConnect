import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/models/ride/ride_route.dart';
import 'package:sport_connect/features/rides/models/ride/ride_schedule.dart';
import 'package:sport_connect/features/rides/models/ride/ride_capacity.dart';
import 'package:sport_connect/features/rides/models/ride/ride_pricing.dart';
import 'package:sport_connect/features/rides/models/ride/ride_preferences.dart';
import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';
import 'package:sport_connect/features/rides/models/ride_search_filters.dart';
import 'package:sport_connect/features/rides/repositories/ride_repository.dart';
import 'package:sport_connect/features/rides/services/ride_service.dart';
import 'package:sport_connect/core/models/location/location_point.dart';
import 'package:sport_connect/core/models/value_objects/money.dart';

part 'ride_view_model.g.dart';

/// State for ride creation/editing
class RideFormState {
  final LocationPoint? origin;
  final LocationPoint? destination;
  final DateTime? departureTime;
  final int availableSeats;
  final double pricePerSeat;
  final bool isLoading;
  final String? error;

  const RideFormState({
    this.origin,
    this.destination,
    this.departureTime,
    this.availableSeats = 3,
    this.pricePerSeat = 0.0,
    this.isLoading = false,
    this.error,
  });

  RideFormState copyWith({
    LocationPoint? origin,
    LocationPoint? destination,
    DateTime? departureTime,
    int? availableSeats,
    double? pricePerSeat,
    bool? isLoading,
    String? error,
  }) {
    return RideFormState(
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      departureTime: departureTime ?? this.departureTime,
      availableSeats: availableSeats ?? this.availableSeats,
      pricePerSeat: pricePerSeat ?? this.pricePerSeat,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isValid =>
      origin != null && destination != null && departureTime != null;
}

final rideActionsViewModelProvider = Provider<RideActionsViewModel>((ref) {
  return RideActionsViewModel(ref);
});

/// Delegates ride operations through the [RideService] for validated
/// business logic. Falls back to the repository only for operations
/// that don't require additional validation (start, complete, stream).
class RideActionsViewModel {
  RideActionsViewModel(this._ref);

  final Ref _ref;

  Future<String> createRide(RideModel ride) {
    return _ref.read(rideServiceProvider.notifier).createRide(ride);
  }

  Future<void> cancelRide(String rideId, String reason) {
    return _ref.read(rideServiceProvider.notifier).cancelRide(rideId, reason);
  }

  Future<void> startRide(String rideId) {
    return _ref.read(rideRepositoryProvider).startRide(rideId);
  }

  Future<void> completeRide(String rideId) {
    // Route through RideService so XP reward + driver stats are recorded
    return _ref.read(rideServiceProvider.notifier).completeRide(rideId);
  }

  Future<void> updateBookingStatus({
    required String rideId,
    required String bookingId,
    required BookingStatus newStatus,
  }) {
    return _ref
        .read(rideRepositoryProvider)
        .updateBookingStatus(
          rideId: rideId,
          bookingId: bookingId,
          newStatus: newStatus,
        );
  }

  Future<void> bookRide({
    required String rideId,
    required RideBooking booking,
  }) {
    return _ref
        .read(rideRepositoryProvider)
        .bookRide(rideId: rideId, booking: booking);
  }

  Future<void> cancelBooking({
    required String rideId,
    required String bookingId,
  }) {
    return _ref
        .read(rideRepositoryProvider)
        .cancelBooking(rideId: rideId, bookingId: bookingId);
  }

  Stream<RideModel?> streamRideById(String rideId) {
    return _ref.read(rideRepositoryProvider).streamRideById(rideId);
  }
}

/// Ride Form View Model
@Riverpod(keepAlive: true)
class RideFormViewModel extends _$RideFormViewModel {
  @override
  RideFormState build() => const RideFormState();

  void setOrigin(LocationPoint origin) {
    state = state.copyWith(origin: origin);
  }

  void setDestination(LocationPoint destination) {
    state = state.copyWith(destination: destination);
  }

  void setDepartureTime(DateTime time) {
    state = state.copyWith(departureTime: time);
  }

  void setSeats(int seats) {
    state = state.copyWith(availableSeats: seats);
  }

  void setPrice(double price) {
    state = state.copyWith(pricePerSeat: price);
  }

  Future<String?> createRide({
    required String driverId,
    required LocationPoint origin,
    required LocationPoint destination,
    required DateTime departureTime,
    required int availableSeats,
    required double pricePerSeat,
    String currency = 'USD',
  }) async {
    if (!state.isValid) {
      state = state.copyWith(error: 'Please fill all required fields');
      return null;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final ride = RideModel(
        id: '',
        driverId: driverId,
        route: RideRoute(origin: origin, destination: destination),
        schedule: RideSchedule(departureTime: departureTime),
        capacity: RideCapacity(available: availableSeats),
        pricing: RidePricing(
          pricePerSeat: Money(amount: pricePerSeat, currency: currency),
        ),
        preferences: const RidePreferences(),
        status: RideStatus.active,
      );

      // Route through RideService so validation rules are applied consistently
      final rideId = await ref.read(rideServiceProvider.notifier).createRide(ride);
      state = state.copyWith(isLoading: false);
      return rideId;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  void reset() {
    state = const RideFormState();
  }
}

/// Search state
class RideSearchState {
  final List<RideModel> rides;
  final bool isLoading;
  final String? error;
  final RideSearchFilters filters;
  final bool hasMore;

  const RideSearchState({
    this.rides = const [],
    this.isLoading = false,
    this.error,
    this.filters = const RideSearchFilters(),
    this.hasMore = true,
  });

  RideSearchState copyWith({
    List<RideModel>? rides,
    bool? isLoading,
    String? error,
    RideSearchFilters? filters,
    bool? hasMore,
  }) {
    return RideSearchState(
      rides: rides ?? this.rides,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filters: filters ?? this.filters,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// Ride Search View Model
@Riverpod(keepAlive: true)
class RideSearchViewModel extends _$RideSearchViewModel {
  @override
  RideSearchState build() => const RideSearchState();

  void updateFilters(RideSearchFilters filters) {
    state = state.copyWith(filters: filters);
  }

  Future<void> searchRides() async {
    // Avoid calling into ref after async gaps by capturing dependencies early
    if (state.filters.origin == null || state.filters.destination == null) {
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    // Capture repository and filters before awaiting
    final repository = ref.read(rideRepositoryProvider);
    final filters = state.filters;

    try {
      var rides = await repository.searchRides(
        originLat: filters.origin!.latitude,
        originLng: filters.origin!.longitude,
        destLat: filters.destination!.latitude,
        destLng: filters.destination!.longitude,
        date: filters.departureDate ?? DateTime.now(),
        minSeats: filters.minSeats,
        maxPrice: filters.maxPrice,
      );

      // Post-filter by preferences not supported in Firestore query
      if (filters.womenOnly) {
        rides = rides.where((r) => r.preferences.isWomenOnly).toList();
      }
      if (filters.allowPets) {
        rides = rides.where((r) => r.preferences.allowPets).toList();
      }
      if (filters.minDriverRating != null) {
        rides = rides
            .where((r) => r.averageRating >= filters.minDriverRating!)
            .toList();
      }

      // If provider was disposed while awaiting, bail out safely
      if (!ref.mounted) return;

      state = state.copyWith(
        rides: rides,
        isLoading: false,
        hasMore: rides.length >= 20,
      );
    } catch (e, _) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  void clearResults() {
    state = state.copyWith(rides: [], hasMore: true);
  }
}

/// Single Ride Detail View Model (real-time updates)
@riverpod
class RideDetailViewModel extends _$RideDetailViewModel {
  @override
  Stream<RideModel?> build(String rideId) {
    final repository = ref.read(rideRepositoryProvider);
    return repository.streamRideById(rideId);
  }

  Future<bool> bookRide({
    required String passengerId,
    int seats = 1,
    String? note,
  }) async {
    final ride = state.value;
    if (ride == null) return false;

    try {
      final repository = ref.read(rideRepositoryProvider);

      final booking = RideBooking(
        id: const Uuid().v4(),
        rideId: ride.id,
        passengerId: passengerId,
        seatsBooked: seats,
        status: BookingStatus.pending,
        note: note,
        createdAt: DateTime.now(),
      );

      await repository.bookRide(rideId: ride.id, booking: booking);
      ref.invalidateSelf();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> acceptBooking(String bookingId) async {
    final ride = state.value;
    if (ride == null) return false;

    try {
      final repository = ref.read(rideRepositoryProvider);
      await repository.updateBookingStatus(
        rideId: ride.id,
        bookingId: bookingId,
        newStatus: BookingStatus.accepted,
      );
      ref.invalidateSelf();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> rejectBooking(String bookingId) async {
    final ride = state.value;
    if (ride == null) return false;

    try {
      final repository = ref.read(rideRepositoryProvider);
      await repository.updateBookingStatus(
        rideId: ride.id,
        bookingId: bookingId,
        newStatus: BookingStatus.rejected,
      );
      ref.invalidateSelf();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> startRide() async {
    final ride = state.value;
    if (ride == null) return false;

    try {
      final repository = ref.read(rideRepositoryProvider);
      await repository.startRide(ride.id);
      ref.invalidateSelf();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> completeRide() async {
    final ride = state.value;
    if (ride == null) return false;

    try {
      // Route through RideService so XP reward + driver stats are recorded
      await ref.read(rideServiceProvider.notifier).completeRide(ride.id);
      ref.invalidateSelf();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> cancelRide() async {
    final ride = state.value;
    if (ride == null) return false;

    try {
      // Route through RideService so validation + passenger notifications fire
      await ref
          .read(rideServiceProvider.notifier)
          .cancelRide(ride.id, 'Cancelled by user');
      ref.invalidateSelf();
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// User's Rides Provider (as driver)
@riverpod
Future<List<RideModel>> myRidesAsDriver(Ref ref, String userId) async {
  final repository = ref.read(rideRepositoryProvider);
  return repository.getRidesByDriver(userId);
}

/// User's Rides Stream Provider (as driver) - Real-time
@riverpod
Stream<List<RideModel>> myRidesAsDriverStream(Ref ref, String userId) {
  final repository = ref.read(rideRepositoryProvider);
  return repository.streamRidesByDriver(userId);
}

/// User's Rides as Passenger Stream Provider
@riverpod
Stream<List<RideModel>> myRidesAsPassengerStream(Ref ref, String userId) {
  final repository = ref.read(rideRepositoryProvider);
  return repository.streamRidesAsPassenger(userId);
}

/// Nearby Rides Stream Provider
@riverpod
Stream<List<RideModel>> nearbyRides(
  Ref ref, {
  required double latitude,
  required double longitude,
}) {
  final repository = ref.read(rideRepositoryProvider);
  return repository.streamNearbyRides(latitude: latitude, longitude: longitude);
}

/// All Active Rides Stream Provider (for search screen)
@riverpod
Stream<List<RideModel>> activeRides(Ref ref) {
  final repository = ref.read(rideRepositoryProvider);
  return repository.streamActiveRides();
}

/// Single Ride Stream Provider (for active ride screens)
@riverpod
Stream<RideModel?> rideStream(Ref ref, String rideId) {
  final repository = ref.read(rideRepositoryProvider);
  return repository.streamRideById(rideId);
}
