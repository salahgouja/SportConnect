import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/features/rides/models/ride_model.dart';
import 'package:sport_connect/features/rides/repositories/ride_repository.dart';

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

/// Ride Form View Model
@riverpod
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
    required String driverName,
    String? driverPhotoUrl,
    double? driverRating,
  }) async {
    if (!state.isValid) {
      state = state.copyWith(error: 'Please fill all required fields');
      return null;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(rideRepositoryProvider);

      final ride = RideModel(
        id: '',
        driverId: driverId,
        driverName: driverName,
        driverPhotoUrl: driverPhotoUrl,
        driverRating: driverRating,
        origin: state.origin!,
        destination: state.destination!,
        departureTime: state.departureTime!,
        availableSeats: state.availableSeats,
        pricePerSeat: state.pricePerSeat,
        status: RideStatus.active,
      );

      final rideId = await repository.createRide(ride);
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
@riverpod
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
      final rides = await repository.searchRides(
        originLat: filters.origin!.latitude,
        originLng: filters.origin!.longitude,
        destLat: filters.destination!.latitude,
        destLng: filters.destination!.longitude,
        departureDate: filters.departureDate ?? DateTime.now(),
        minSeats: filters.minSeats,
        maxPrice: filters.maxPrice,
      );

      // If provider was disposed while awaiting, bail out safely
      if (!ref.mounted) return;

      state = state.copyWith(
        rides: rides,
        isLoading: false,
        hasMore: rides.length >= 20,
      );
    } catch (e, st) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  void clearResults() {
    state = state.copyWith(rides: [], hasMore: true);
  }
}

/// Single Ride Detail View Model
@riverpod
class RideDetailViewModel extends _$RideDetailViewModel {
  @override
  Future<RideModel?> build(String rideId) async {
    final repository = ref.read(rideRepositoryProvider);
    return repository.getRideById(rideId);
  }

  Future<bool> bookRide({
    required String passengerId,
    required String passengerName,
    String? passengerPhotoUrl,
    int seats = 1,
    String? note,
  }) async {
    final ride = state.value;
    if (ride == null) return false;

    try {
      final repository = ref.read(rideRepositoryProvider);

      final booking = RideBooking(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        passengerId: passengerId,
        passengerName: passengerName,
        passengerPhotoUrl: passengerPhotoUrl,
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
      final repository = ref.read(rideRepositoryProvider);
      await repository.completeRide(ride.id);
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
      final repository = ref.read(rideRepositoryProvider);
      await repository.cancelRide(ride.id);
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
