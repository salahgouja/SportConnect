import 'dart:io';

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
import 'package:sport_connect/core/providers/repository_providers.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
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

  /// Stamps the booking with the Stripe payment intent ID once payment
  /// succeeds. Prevents the "Complete Payment" button from reappearing
  /// and guards against double-charges on back-navigation.
  Future<void> markBookingPaid({
    required String bookingId,
    required String paymentIntentId,
  }) {
    return _ref
        .read(bookingRepositoryProvider)
        .updateBookingPaymentIntent(
          bookingId: bookingId,
          paymentIntentId: paymentIntentId,
        );
  }

  Stream<RideModel?> streamRideById(String rideId) {
    return _ref.read(rideRepositoryProvider).streamRideById(rideId);
  }

  /// Fetches a one-shot list of all bookings for a ride (driver-side).
  ///
  /// Used by screens that need to look up a specific booking ID before
  /// performing a follow-up action (e.g. rating, cancellation).
  Future<List<RideBooking>> getBookingsByRideId(
    String rideId,
    String driverId,
  ) {
    return _ref
        .read(bookingRepositoryProvider)
        .getBookingsByRideId(rideId, driverId);
  }

  /// Returns the current passenger's booking for a ride, or null.
  Future<RideBooking?> getPassengerBookingForRide(
    String rideId,
    String passengerId,
  ) {
    return _ref
        .read(bookingRepositoryProvider)
        .getPassengerBookingForRide(rideId, passengerId);
  }

  /// One-shot fetch of a single ride by ID.
  ///
  /// Used for deep-link / route-based prefill scenarios where we only
  /// need the current snapshot, not a live stream.
  Future<RideModel?> getRideById(String rideId) {
    return _ref.read(rideRepositoryProvider).getRideById(rideId);
  }

  /// Pushes the driver's GPS coordinates to Firestore.
  ///
  /// Failures are silently swallowed — a missed location ping must not
  /// interrupt the navigation flow.
  Future<void> updateLiveLocation(
    String rideId,
    double latitude,
    double longitude,
  ) {
    return _ref
        .read(rideRepositoryProvider)
        .updateLiveLocation(rideId, latitude, longitude);
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
      final rideId = await ref
          .read(rideServiceProvider.notifier)
          .createRide(ride);
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
///
/// Uses client-side batching: the Firestore geo query returns all matches
/// (up to 100) since cursor pagination isn't possible with latitude
/// inequality filters. Results are stored in [_allResults] and surfaced
/// in pages of [_pageSize] via [loadMore].
@riverpod
class RideSearchViewModel extends _$RideSearchViewModel {
  static const _pageSize = 20;

  /// Full result set from the last Firestore query (post client-side filter).
  List<RideModel> _allResults = [];

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

      // Store full result set, surface first page
      _allResults = rides;
      final firstPage = rides.take(_pageSize).toList();

      state = state.copyWith(
        rides: firstPage,
        isLoading: false,
        hasMore: rides.length > _pageSize,
      );
    } catch (e, _) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  void clearResults() {
    _allResults = [];
    state = state.copyWith(rides: [], hasMore: true);
  }

  /// Reveals the next page of results from the cached [_allResults].
  void loadMore() {
    if (!state.hasMore || state.isLoading) return;

    final currentCount = state.rides.length;
    final nextPage = _allResults.skip(currentCount).take(_pageSize).toList();
    final allShown = currentCount + nextPage.length >= _allResults.length;

    state = state.copyWith(
      rides: [...state.rides, ...nextPage],
      hasMore: !allShown,
    );
  }
}

// ---------------------------------------------------------------------------
// Ride Detail State — aggregates ride stream + bookings stream
// ---------------------------------------------------------------------------

/// Immutable UI state for any screen that shows a single ride with bookings.
class RideDetailState {
  const RideDetailState({
    this.ride = const AsyncValue.loading(),
    this.bookings = const [],
    this.actionError,
  });

  /// Real-time ride data from Firestore.
  final AsyncValue<RideModel?> ride;

  /// Live bookings for this ride (from the separate bookings sub-collection).
  final List<RideBooking> bookings;

  /// Error from the last action (book, accept, reject, cancel, etc.).
  final String? actionError;

  // Sentinel to distinguish "not passed" from "explicitly null".
  static const _unset = Object();

  RideDetailState copyWith({
    AsyncValue<RideModel?>? ride,
    List<RideBooking>? bookings,
    Object? actionError = _unset,
  }) => RideDetailState(
    ride: ride ?? this.ride,
    bookings: bookings ?? this.bookings,
    actionError: actionError == _unset
        ? this.actionError
        : actionError as String?,
  );
}

/// Single Ride Detail View Model — views watch only this, never separate
/// stream/booking providers directly.
@riverpod
class RideDetailViewModel extends _$RideDetailViewModel {
  @override
  RideDetailState build(String rideId) {
    final rideAsync = ref.watch(rideStreamProvider(rideId));
    final bookings =
        ref.watch(bookingsByRideProvider(rideId)).value ?? const [];
    return RideDetailState(ride: rideAsync, bookings: bookings);
  }

  Future<bool> bookRide({
    required String passengerId,
    int seats = 1,
    String? note,

    /// Optional passenger pickup location — stored on the booking and later
    /// added to the ride's route as a waypoint when the driver accepts.
    LocationPoint? pickupLocation,
  }) async {
    final ride = state.ride.value;
    if (ride == null) return false;

    try {
      final booking = RideBooking(
        id: const Uuid().v4(),
        rideId: ride.id,
        passengerId: passengerId,
        driverId: ride.driverId,
        seatsBooked: seats,
        status: BookingStatus.pending,
        note: note,
        pickupLocation: pickupLocation,
        createdAt: DateTime.now(),
      );
      await ref
          .read(rideRepositoryProvider)
          .bookRide(rideId: ride.id, booking: booking);
      state = state.copyWith(actionError: null);

      // Notify the driver that a new booking request has arrived.
      // Fire-and-forget: a notification failure must never break the booking.
      try {
        final passenger = ref.read(currentUserProvider).value;
        if (passenger != null) {
          final notificationRepo = ref.read(notificationRepositoryProvider);
          final origin = ride.origin.city ?? ride.origin.address;
          final dest = ride.destination.city ?? ride.destination.address;
          await notificationRepo.sendRideBookingRequest(
            toUserId: ride.driverId,
            fromUserId: passengerId,
            fromUserName: passenger.displayName ?? 'Passenger',
            fromUserPhoto: passenger.photoUrl,
            rideId: ride.id,
            rideName: '$origin → $dest',
          );
        }
      } catch (_) {
        // Notification failure is non-fatal
      }

      return true;
    } catch (e) {
      state = state.copyWith(actionError: e.toString());
      return false;
    }
  }

  Future<bool> acceptBooking(String bookingId) async {
    final ride = state.ride.value;
    if (ride == null) return false;
    try {
      // 1. Mark booking as accepted.
      await ref
          .read(rideRepositoryProvider)
          .updateBookingStatus(
            rideId: ride.id,
            bookingId: bookingId,
            newStatus: BookingStatus.accepted,
          );

      // 2. If the passenger specified a pickup location, add it as a
      //    RouteWaypoint so the driver can see the stop on the route card.
      final idx = state.bookings.indexWhere((b) => b.id == bookingId);
      if (idx >= 0) {
        final booking = state.bookings[idx];
        if (booking.pickupLocation != null) {
          final existing = ride.route.waypoints;
          final nextOrder = existing.isEmpty
              ? 0
              : existing.map((w) => w.order).reduce((a, b) => a > b ? a : b) +
                    1;
          final updated = [
            ...existing,
            RouteWaypoint(location: booking.pickupLocation!, order: nextOrder),
          ];
          await ref.read(rideRepositoryProvider).updateRideFields(ride.id, {
            'route.waypoints': updated.map((w) => w.toJson()).toList(),
          });
        }
      }

      state = state.copyWith(actionError: null);
      return true;
    } catch (e) {
      state = state.copyWith(actionError: e.toString());
      return false;
    }
  }

  Future<bool> rejectBooking(String bookingId) async {
    final ride = state.ride.value;
    if (ride == null) return false;
    try {
      await ref
          .read(rideRepositoryProvider)
          .updateBookingStatus(
            rideId: ride.id,
            bookingId: bookingId,
            newStatus: BookingStatus.rejected,
          );
      state = state.copyWith(actionError: null);
      return true;
    } catch (e) {
      state = state.copyWith(actionError: e.toString());
      return false;
    }
  }

  Future<bool> startRide() async {
    final ride = state.ride.value;
    if (ride == null) return false;
    try {
      await ref.read(rideRepositoryProvider).startRide(ride.id);
      state = state.copyWith(actionError: null);
      return true;
    } catch (e) {
      state = state.copyWith(actionError: e.toString());
      return false;
    }
  }

  Future<bool> completeRide() async {
    final ride = state.ride.value;
    if (ride == null) return false;
    try {
      await ref.read(rideServiceProvider.notifier).completeRide(ride.id);
      state = state.copyWith(actionError: null);
      return true;
    } catch (e) {
      state = state.copyWith(actionError: e.toString());
      return false;
    }
  }

  Future<bool> cancelRide({String reason = 'Cancelled by user'}) async {
    final ride = state.ride.value;
    if (ride == null) return false;
    try {
      await ref.read(rideServiceProvider.notifier).cancelRide(ride.id, reason);
      state = state.copyWith(actionError: null);
      return true;
    } catch (e) {
      state = state.copyWith(actionError: e.toString());
      return false;
    }
  }
}

// ---------------------------------------------------------------------------
// Active Ride State — for driver / passenger active-ride screens
// ---------------------------------------------------------------------------

/// Immutable state for active-ride screens that need live ride + bookings.
class ActiveRideState {
  const ActiveRideState({
    this.ride = const AsyncValue.loading(),
    this.bookings = const [],
  });

  final AsyncValue<RideModel?> ride;
  final List<RideBooking> bookings;

  ActiveRideState copyWith({
    AsyncValue<RideModel?>? ride,
    List<RideBooking>? bookings,
  }) => ActiveRideState(
    ride: ride ?? this.ride,
    bookings: bookings ?? this.bookings,
  );
}

/// ViewModel for active-ride screens — views watch only this provider.
@riverpod
class ActiveRideViewModel extends _$ActiveRideViewModel {
  @override
  ActiveRideState build(String rideId) {
    final rideAsync = ref.watch(rideStreamProvider(rideId));
    final bookings =
        ref.watch(bookingsByRideProvider(rideId)).value ?? const [];
    return ActiveRideState(ride: rideAsync, bookings: bookings);
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

/// Real-time stream of all bookings for a given ride.
///
/// Use this alongside [rideDetailViewModelProvider] in any screen that needs
/// booking data (requests tab, passenger list, earnings, etc.) — the
/// [RideModel.bookings] field is never populated from Firestore.
@riverpod
Stream<List<RideBooking>> bookingsByRide(Ref ref, String rideId) {
  final uid = ref.watch(currentUserProvider).value?.uid;
  if (uid == null) return const Stream.empty();
  return ref
      .read(bookingRepositoryProvider)
      .streamBookingsByRideId(rideId, uid);
}

/// Real-time stream of a single booking by ID.
///
/// Wraps [BookingRepository.streamBookingById] so views never import the
/// repository layer directly.
@riverpod
Stream<RideBooking?> bookingStream(Ref ref, String bookingId) {
  return ref.read(bookingRepositoryProvider).streamBookingById(bookingId);
}

/// Real-time stream of all bookings for a given passenger.
///
/// Used on the pending-booking screen where the passenger polls for
/// status changes before being auto-navigated.
@riverpod
Stream<List<RideBooking>> bookingsByPassenger(Ref ref, String passengerId) {
  return ref
      .read(bookingRepositoryProvider)
      .streamBookingsByPassengerId(passengerId);
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

// ─── Dispute ──────────────────────────────────────────────────────────────────

final disputeViewModelProvider = Provider<DisputeViewModel>((ref) {
  return DisputeViewModel(ref);
});

/// Delegates dispute submission through [DisputeRepository].
class DisputeViewModel {
  DisputeViewModel(this._ref);

  final Ref _ref;

  /// Submits a dispute and optionally uploads file attachments.
  ///
  /// Returns the new dispute document ID.
  Future<String> submitDispute({
    required String rideId,
    required String userId,
    required String? userEmail,
    required String disputeType,
    required String description,
    String? rideSummary,
    List<File> attachments = const [],
  }) async {
    final repo = _ref.read(disputeRepositoryProvider);
    final disputeId = await repo.submitDispute(
      rideId: rideId,
      userId: userId,
      userEmail: userEmail,
      disputeType: disputeType,
      description: description,
      rideSummary: rideSummary,
    );

    if (attachments.isNotEmpty) {
      await repo.uploadAttachments(disputeId: disputeId, files: attachments);
    }

    return disputeId;
  }
}
