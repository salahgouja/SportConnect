import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
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
import 'package:sport_connect/core/services/map_service.dart';
import 'package:sport_connect/core/services/routing_service.dart';
import 'package:sport_connect/core/services/talker_service.dart';
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

class RideDetailUiState {
  const RideDetailUiState({
    this.selectedSeats = 1,
    this.isBooking = false,
    this.isReminderEnabled = true,
    this.pickupLocation,
    this.routeInfo,
    this.isLoadingRoute = false,
  });

  final int selectedSeats;
  final bool isBooking;
  final bool isReminderEnabled;
  final LocationPoint? pickupLocation;
  final RouteInfo? routeInfo;
  final bool isLoadingRoute;

  RideDetailUiState copyWith({
    int? selectedSeats,
    bool? isBooking,
    bool? isReminderEnabled,
    LocationPoint? pickupLocation,
    bool clearPickupLocation = false,
    RouteInfo? routeInfo,
    bool clearRouteInfo = false,
    bool? isLoadingRoute,
  }) {
    return RideDetailUiState(
      selectedSeats: selectedSeats ?? this.selectedSeats,
      isBooking: isBooking ?? this.isBooking,
      isReminderEnabled: isReminderEnabled ?? this.isReminderEnabled,
      pickupLocation: clearPickupLocation
          ? null
          : (pickupLocation ?? this.pickupLocation),
      routeInfo: clearRouteInfo ? null : (routeInfo ?? this.routeInfo),
      isLoadingRoute: isLoadingRoute ?? this.isLoadingRoute,
    );
  }
}

@riverpod
class RideDetailUiViewModel extends _$RideDetailUiViewModel {
  @override
  RideDetailUiState build(String rideId) => const RideDetailUiState();

  Future<RouteInfo?> ensureRouteLoaded(RideModel ride) async {
    if (state.isLoadingRoute || state.routeInfo != null) {
      return state.routeInfo;
    }

    state = state.copyWith(isLoadingRoute: true);

    try {
      final fromCoords = LatLng(ride.origin.latitude, ride.origin.longitude);
      final toCoords = LatLng(
        ride.destination.latitude,
        ride.destination.longitude,
      );

      final waypoints = ride.route.waypoints
          .map((wp) => LatLng(wp.location.latitude, wp.location.longitude))
          .toList();

      final route = await RoutingService.getRoute(
        origin: fromCoords,
        destination: toCoords,
        waypoints: waypoints.isNotEmpty ? waypoints : null,
      );

      state = state.copyWith(routeInfo: route, isLoadingRoute: false);
      return route;
    } catch (_) {
      state = state.copyWith(isLoadingRoute: false);
      return null;
    }
  }

  void setSelectedSeats(int seats) {
    if (seats < 1) return;
    state = state.copyWith(selectedSeats: seats);
  }

  void setBooking(bool value) {
    state = state.copyWith(isBooking: value);
  }

  void setReminderEnabled(bool value) {
    state = state.copyWith(isReminderEnabled: value);
  }

  void setPickupLocation(LocationPoint location) {
    state = state.copyWith(pickupLocation: location);
  }

  void clearPickupLocation() {
    state = state.copyWith(clearPickupLocation: true);
  }
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

class CancellationReasonState {
  static const _unset = Object();

  const CancellationReasonState({
    this.selectedReason,
    this.commentText = '',
    this.isSubmitting = false,
    this.isSubmitted = false,
    this.validationMessage,
    this.errorMessage,
  });

  final String? selectedReason;
  final String commentText;
  final bool isSubmitting;
  final bool isSubmitted;
  final String? validationMessage;
  final String? errorMessage;

  CancellationReasonState copyWith({
    Object? selectedReason = _unset,
    String? commentText,
    bool? isSubmitting,
    bool? isSubmitted,
    String? validationMessage,
    String? errorMessage,
    bool clearValidation = false,
    bool clearError = false,
  }) {
    return CancellationReasonState(
      selectedReason: selectedReason == _unset
          ? this.selectedReason
          : selectedReason as String?,
      commentText: commentText ?? this.commentText,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      validationMessage: clearValidation
          ? null
          : (validationMessage ?? this.validationMessage),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

@riverpod
class CancellationReasonViewModel extends _$CancellationReasonViewModel {
  late final String _rideId;

  @override
  CancellationReasonState build(String rideId) {
    _rideId = rideId;
    return const CancellationReasonState();
  }

  void selectReason(String reason) {
    state = state.copyWith(
      selectedReason: reason,
      clearValidation: true,
      clearError: true,
    );
  }

  void updateComment(String comment) {
    state = state.copyWith(commentText: comment, clearError: true);
  }

  Future<void> submit() async {
    if (state.isSubmitting) {
      return;
    }

    final selectedReason = state.selectedReason;
    if (selectedReason == null || selectedReason.isEmpty) {
      state = state.copyWith(
        validationMessage: 'Please select a cancellation reason',
      );
      return;
    }

    state = state.copyWith(
      isSubmitting: true,
      isSubmitted: false,
      clearValidation: true,
      clearError: true,
    );

    try {
      final comment = state.commentText.trim();
      final reason = comment.isNotEmpty
          ? '$selectedReason | $comment'
          : selectedReason;

      await ref.read(rideActionsViewModelProvider).cancelRide(_rideId, reason);
      state = state.copyWith(isSubmitting: false, isSubmitted: true);
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Failed to cancel ride. Please try again.',
      );
    }
  }
}

class DisputeFormState {
  static const _unset = Object();

  const DisputeFormState({
    this.selectedDisputeType,
    this.description = '',
    this.attachedFiles = const [],
    this.isSubmitting = false,
    this.isSubmitted = false,
    this.typeError,
    this.descriptionError,
    this.errorMessage,
  });

  final String? selectedDisputeType;
  final String description;
  final List<File> attachedFiles;
  final bool isSubmitting;
  final bool isSubmitted;
  final String? typeError;
  final String? descriptionError;
  final String? errorMessage;

  DisputeFormState copyWith({
    Object? selectedDisputeType = _unset,
    String? description,
    List<File>? attachedFiles,
    bool? isSubmitting,
    bool? isSubmitted,
    String? typeError,
    String? descriptionError,
    String? errorMessage,
    bool clearTypeError = false,
    bool clearDescriptionError = false,
    bool clearError = false,
  }) {
    return DisputeFormState(
      selectedDisputeType: selectedDisputeType == _unset
          ? this.selectedDisputeType
          : selectedDisputeType as String?,
      description: description ?? this.description,
      attachedFiles: attachedFiles ?? this.attachedFiles,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      typeError: clearTypeError ? null : (typeError ?? this.typeError),
      descriptionError: clearDescriptionError
          ? null
          : (descriptionError ?? this.descriptionError),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

@riverpod
class DisputeFormViewModel extends _$DisputeFormViewModel {
  static const int maxAttachments = 5;
  static const int maxFileSizeBytes = 10 * 1024 * 1024;
  static const int minDescriptionLength = 20;

  late final String _rideId;

  @override
  DisputeFormState build(String rideId) {
    _rideId = rideId;
    return const DisputeFormState();
  }

  void selectType(String disputeType) {
    state = state.copyWith(
      selectedDisputeType: disputeType,
      clearTypeError: true,
      clearError: true,
    );
  }

  void updateDescription(String description) {
    state = state.copyWith(
      description: description,
      clearDescriptionError: true,
      clearError: true,
    );
  }

  Future<void> addAttachment(File file) async {
    if (state.attachedFiles.length >= maxAttachments) {
      state = state.copyWith(
        errorMessage: 'Maximum $maxAttachments files allowed',
      );
      return;
    }

    if (state.attachedFiles.any((existing) => existing.path == file.path)) {
      state = state.copyWith(errorMessage: 'That file is already attached.');
      return;
    }

    final size = await file.length();
    if (size > maxFileSizeBytes) {
      state = state.copyWith(errorMessage: 'File exceeds 10 MB limit');
      return;
    }

    state = state.copyWith(
      attachedFiles: [...state.attachedFiles, file],
      clearError: true,
    );
  }

  void removeAttachmentAt(int index) {
    if (index < 0 || index >= state.attachedFiles.length) {
      return;
    }

    final updatedFiles = [...state.attachedFiles]..removeAt(index);
    state = state.copyWith(attachedFiles: updatedFiles, clearError: true);
  }

  bool _validate() {
    final typeError = state.selectedDisputeType == null
        ? 'Please select a dispute type'
        : null;
    final description = state.description.trim();
    final descriptionError = description.isEmpty
        ? 'Please describe your issue'
        : (description.length < minDescriptionLength
              ? 'Please provide more detail (at least $minDescriptionLength characters)'
              : null);

    state = state.copyWith(
      typeError: typeError,
      descriptionError: descriptionError,
      clearError: true,
    );

    return typeError == null && descriptionError == null;
  }

  Future<void> submit({
    required String userId,
    required String userEmail,
    String? rideSummary,
  }) async {
    if (state.isSubmitting || !_validate()) {
      return;
    }

    state = state.copyWith(
      isSubmitting: true,
      isSubmitted: false,
      clearError: true,
    );

    try {
      await ref
          .read(disputeViewModelProvider)
          .submitDispute(
            rideId: _rideId,
            userId: userId,
            userEmail: userEmail,
            disputeType: state.selectedDisputeType!,
            description: state.description.trim(),
            rideSummary: rideSummary,
            attachments: state.attachedFiles,
          );
      state = state.copyWith(isSubmitting: false, isSubmitted: true);
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Failed to submit dispute. Please try again.',
      );
    }
  }
}

/// Streams the driver's live GPS location for a ride.
@riverpod
Stream<({double latitude, double longitude})?> driverLiveLocation(
  Ref ref,
  String rideId,
) {
  return ref.watch(rideRepositoryProvider).streamLiveLocation(rideId);
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

  Future<String?> submitRideModel(RideModel ride) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final rideId = await ref
          .read(rideServiceProvider.notifier)
          .createRide(ride);

      if (!ref.mounted) return rideId;
      state = state.copyWith(isLoading: false, error: null);
      return rideId;
    } catch (e) {
      if (!ref.mounted) return null;
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  void reset() {
    state = const RideFormState();
  }
}

/// Search state - includes both committed filters and draft UI state
enum RideSearchResultViewMode { list, map }

class RideSearchState {
  static const _unset = Object();

  final List<RideModel> rides;
  final List<RideModel> allSearchResults;
  final bool isLoading;
  final String? error;
  final RideSearchFilters filters;
  final bool hasMore;

  // Draft search/filter state (not yet committed to search)
  final LocationPoint? draftOrigin;
  final LocationPoint? draftDestination;
  final DateTime draftDate;
  final int draftSeats;
  final int selectedDateChip; // 0=Today, 1=Tomorrow, 2=Custom
  final bool hasSearched;

  // Draft filter state
  final double draftMaxPrice;
  final bool draftFemaleOnly;
  final bool draftInstantBook;
  final bool draftVerifiedOnly;
  final bool draftPetFriendly;
  final bool draftMusicAllowed;
  final double draftMinRating;
  final String draftSortBy;
  final String draftVehicleType;
  final bool isFilterPanelOpen;
  final RideSearchResultViewMode resultViewMode;
  final int visibleResultCount;
  final String? lastCompletedQueryKey;
  final String? pendingQueryKey;

  RideSearchState({
    this.rides = const [],
    this.allSearchResults = const [],
    this.isLoading = false,
    this.error,
    this.filters = const RideSearchFilters(),
    this.hasMore = true,
    this.draftOrigin,
    this.draftDestination,
    DateTime? draftDate,
    this.draftSeats = 1,
    this.selectedDateChip = 0,
    this.hasSearched = false,
    this.draftMaxPrice = 50,
    this.draftFemaleOnly = false,
    this.draftInstantBook = false,
    this.draftVerifiedOnly = false,
    this.draftPetFriendly = false,
    this.draftMusicAllowed = false,
    this.draftMinRating = 0,
    this.draftSortBy = 'recommended',
    this.draftVehicleType = 'any',
    this.isFilterPanelOpen = false,
    this.resultViewMode = RideSearchResultViewMode.list,
    this.visibleResultCount = 20,
    this.lastCompletedQueryKey,
    this.pendingQueryKey,
  }) : draftDate = draftDate ?? DateTime.now();

  RideSearchState copyWith({
    List<RideModel>? rides,
    List<RideModel>? allSearchResults,
    bool? isLoading,
    Object? error = _unset,
    RideSearchFilters? filters,
    bool? hasMore,
    Object? draftOrigin = _unset,
    Object? draftDestination = _unset,
    DateTime? draftDate,
    int? draftSeats,
    int? selectedDateChip,
    bool? hasSearched,
    double? draftMaxPrice,
    bool? draftFemaleOnly,
    bool? draftInstantBook,
    bool? draftVerifiedOnly,
    bool? draftPetFriendly,
    bool? draftMusicAllowed,
    double? draftMinRating,
    String? draftSortBy,
    String? draftVehicleType,
    bool? isFilterPanelOpen,
    RideSearchResultViewMode? resultViewMode,
    int? visibleResultCount,
    Object? lastCompletedQueryKey = _unset,
    Object? pendingQueryKey = _unset,
  }) {
    return RideSearchState(
      rides: rides ?? this.rides,
      allSearchResults: allSearchResults ?? this.allSearchResults,
      isLoading: isLoading ?? this.isLoading,
      error: error == _unset ? this.error : error as String?,
      filters: filters ?? this.filters,
      hasMore: hasMore ?? this.hasMore,
      draftOrigin: draftOrigin == _unset
          ? this.draftOrigin
          : draftOrigin as LocationPoint?,
      draftDestination: draftDestination == _unset
          ? this.draftDestination
          : draftDestination as LocationPoint?,
      draftDate: draftDate ?? this.draftDate,
      draftSeats: draftSeats ?? this.draftSeats,
      selectedDateChip: selectedDateChip ?? this.selectedDateChip,
      hasSearched: hasSearched ?? this.hasSearched,
      draftMaxPrice: draftMaxPrice ?? this.draftMaxPrice,
      draftFemaleOnly: draftFemaleOnly ?? this.draftFemaleOnly,
      draftInstantBook: draftInstantBook ?? this.draftInstantBook,
      draftVerifiedOnly: draftVerifiedOnly ?? this.draftVerifiedOnly,
      draftPetFriendly: draftPetFriendly ?? this.draftPetFriendly,
      draftMusicAllowed: draftMusicAllowed ?? this.draftMusicAllowed,
      draftMinRating: draftMinRating ?? this.draftMinRating,
      draftSortBy: draftSortBy ?? this.draftSortBy,
      draftVehicleType: draftVehicleType ?? this.draftVehicleType,
      isFilterPanelOpen: isFilterPanelOpen ?? this.isFilterPanelOpen,
      resultViewMode: resultViewMode ?? this.resultViewMode,
      visibleResultCount: visibleResultCount ?? this.visibleResultCount,
      lastCompletedQueryKey: lastCompletedQueryKey == _unset
          ? this.lastCompletedQueryKey
          : lastCompletedQueryKey as String?,
      pendingQueryKey: pendingQueryKey == _unset
          ? this.pendingQueryKey
          : pendingQueryKey as String?,
    );
  }

  bool get hasActiveFilters =>
      draftFemaleOnly ||
      draftInstantBook ||
      draftVerifiedOnly ||
      draftPetFriendly ||
      draftMusicAllowed ||
      draftMaxPrice < 50 ||
      draftMinRating > 0 ||
      draftVehicleType != 'any';

  int get activeFilterCount {
    int count = 0;
    if (draftMaxPrice < 50) count++;
    if (draftFemaleOnly) count++;
    if (draftInstantBook) count++;
    if (draftVerifiedOnly) count++;
    if (draftPetFriendly) count++;
    if (draftMusicAllowed) count++;
    if (draftMinRating > 0) count++;
    if (draftVehicleType != 'any') count++;
    return count;
  }
}

class RideSearchResultsData {
  const RideSearchResultsData({
    this.allResults = const [],
    this.visibleResults = const [],
    this.totalCount = 0,
    this.hasMore = false,
    this.isLoading = false,
    this.error,
    this.hasSearched = false,
    this.viewMode = RideSearchResultViewMode.list,
  });

  final List<RideModel> allResults;
  final List<RideModel> visibleResults;
  final int totalCount;
  final bool hasMore;
  final bool isLoading;
  final String? error;
  final bool hasSearched;
  final RideSearchResultViewMode viewMode;
}

final rideSearchResultsProvider = Provider<RideSearchResultsData>((ref) {
  final searchState = ref.watch(rideSearchViewModelProvider);

  RideSearchResultsData buildResults({
    required List<RideModel> source,
    required bool isLoading,
    required String? error,
    required bool hasSearched,
  }) {
    final filtered = _applyRideSearchPresentation(source, searchState);
    final visible = filtered.take(searchState.visibleResultCount).toList();
    return RideSearchResultsData(
      allResults: filtered,
      visibleResults: visible,
      totalCount: filtered.length,
      hasMore: visible.length < filtered.length,
      isLoading: isLoading,
      error: error,
      hasSearched: hasSearched,
      viewMode: searchState.resultViewMode,
    );
  }

  if (searchState.hasSearched) {
    return buildResults(
      source: searchState.allSearchResults,
      isLoading: searchState.isLoading,
      error: searchState.error,
      hasSearched: true,
    );
  }

  final activeRides = ref.watch(activeRidesProvider);
  return activeRides.when(
    loading: () => buildResults(
      source: const [],
      isLoading: true,
      error: null,
      hasSearched: false,
    ),
    error: (error, _) => buildResults(
      source: const [],
      isLoading: false,
      error: error.toString(),
      hasSearched: false,
    ),
    data: (rides) => buildResults(
      source: rides,
      isLoading: false,
      error: null,
      hasSearched: false,
    ),
  );
});

List<RideModel> _applyRideSearchPresentation(
  List<RideModel> rides,
  RideSearchState state,
) {
  final filtered = rides.where((ride) {
    if (!_isSameCalendarDay(ride.departureTime, state.draftDate)) {
      return false;
    }
    if (ride.remainingSeats < state.draftSeats) {
      return false;
    }
    if (ride.pricePerSeat > state.draftMaxPrice) {
      return false;
    }
    if (state.draftFemaleOnly && !ride.isWomenOnly) {
      return false;
    }
    if (state.draftPetFriendly && !ride.allowPets) {
      return false;
    }
    if (state.draftMusicAllowed && ride.allowSmoking) {
      return false;
    }
    if (state.draftMinRating > 0 && ride.averageRating < state.draftMinRating) {
      return false;
    }
    if (state.draftVehicleType == 'electric' && !ride.isEco) {
      return false;
    }
    if (state.draftVehicleType == 'comfort' && !ride.isPremium) {
      return false;
    }
    if (state.draftInstantBook && !ride.acceptsOnlinePayment) {
      return false;
    }
    return true;
  }).toList();

  switch (state.draftSortBy) {
    case 'price_low':
      filtered.sort((a, b) => a.pricePerSeat.compareTo(b.pricePerSeat));
      break;
    case 'price_high':
      filtered.sort((a, b) => b.pricePerSeat.compareTo(a.pricePerSeat));
      break;
    case 'rating':
      filtered.sort((a, b) => b.averageRating.compareTo(a.averageRating));
      break;
    case 'duration':
      filtered.sort(
        (a, b) => (a.durationMinutes ?? 1 << 20).compareTo(
          b.durationMinutes ?? 1 << 20,
        ),
      );
      break;
    case 'departure':
      filtered.sort((a, b) => a.departureTime.compareTo(b.departureTime));
      break;
    default:
      final now = DateTime.now();
      filtered.sort((a, b) {
        final scoreA =
            (a.remainingSeats * 10) +
            (100 - a.departureTime.difference(now).inMinutes);
        final scoreB =
            (b.remainingSeats * 10) +
            (100 - b.departureTime.difference(now).inMinutes);
        return scoreB.compareTo(scoreA);
      });
  }

  return filtered;
}

bool _isSameCalendarDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
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
  int _latestSearchRequestId = 0;

  @override
  RideSearchState build() => RideSearchState();

  // --- Draft state setters ---

  void setDraftOrigin(LocationPoint? origin) {
    state = state.copyWith(
      draftOrigin: origin,
      visibleResultCount: _pageSize,
      error: null,
    );
  }

  void setDraftDestination(LocationPoint? destination) {
    state = state.copyWith(
      draftDestination: destination,
      visibleResultCount: _pageSize,
      error: null,
    );
  }

  void swapLocations() {
    state = state.copyWith(
      draftOrigin: state.draftDestination,
      draftDestination: state.draftOrigin,
      visibleResultCount: _pageSize,
      error: null,
    );
  }

  void setDraftDate(DateTime date) {
    state = state.copyWith(draftDate: date, visibleResultCount: _pageSize);
  }

  void setDraftSeats(int seats) {
    if (seats < 1 || seats > 4) return;
    state = state.copyWith(draftSeats: seats, visibleResultCount: _pageSize);
  }

  void setSelectedDateChip(int chip) {
    state = state.copyWith(selectedDateChip: chip);
  }

  void setDraftMaxPrice(double price) {
    state = state.copyWith(
      draftMaxPrice: price.clamp(5, 100),
      visibleResultCount: _pageSize,
    );
  }

  void setDraftFemaleOnly(bool value) {
    state = state.copyWith(
      draftFemaleOnly: value,
      visibleResultCount: _pageSize,
    );
  }

  void setDraftInstantBook(bool value) {
    state = state.copyWith(
      draftInstantBook: value,
      visibleResultCount: _pageSize,
    );
  }

  void setDraftVerifiedOnly(bool value) {
    state = state.copyWith(
      draftVerifiedOnly: value,
      visibleResultCount: _pageSize,
    );
  }

  void setDraftPetFriendly(bool value) {
    state = state.copyWith(
      draftPetFriendly: value,
      visibleResultCount: _pageSize,
    );
  }

  void setDraftMusicAllowed(bool value) {
    state = state.copyWith(
      draftMusicAllowed: value,
      visibleResultCount: _pageSize,
    );
  }

  void setDraftMinRating(double rating) {
    state = state.copyWith(
      draftMinRating: rating.clamp(0, 5),
      visibleResultCount: _pageSize,
    );
  }

  void setDraftSortBy(String sortBy) {
    const supportedSorts = {
      'recommended',
      'price_low',
      'price_high',
      'rating',
      'departure',
      'duration',
    };
    state = state.copyWith(
      draftSortBy: supportedSorts.contains(sortBy) ? sortBy : 'recommended',
      visibleResultCount: _pageSize,
    );
  }

  void setDraftVehicleType(String vehicleType) {
    const supportedTypes = {'any', 'electric', 'comfort'};
    state = state.copyWith(
      draftVehicleType: supportedTypes.contains(vehicleType)
          ? vehicleType
          : 'any',
      visibleResultCount: _pageSize,
    );
  }

  void resetFilters() {
    state = state.copyWith(
      draftMaxPrice: 50,
      draftFemaleOnly: false,
      draftInstantBook: false,
      draftVerifiedOnly: false,
      draftPetFriendly: false,
      draftMusicAllowed: false,
      draftMinRating: 0,
      draftVehicleType: 'any',
      visibleResultCount: _pageSize,
    );
  }

  void setFilterPanelOpen(bool isOpen) {
    state = state.copyWith(isFilterPanelOpen: isOpen);
  }

  void setResultViewMode(RideSearchResultViewMode viewMode) {
    state = state.copyWith(resultViewMode: viewMode);
  }

  void resetPagination() {
    state = state.copyWith(visibleResultCount: _pageSize);
  }

  /// Initialize draft state with an initial destination (e.g., from event detail).
  void setInitialDestination(Map<String, dynamic> destination) {
    final address = destination['destinationAddress'] as String?;
    final lat = destination['destinationLat'] as double?;
    final lng = destination['destinationLng'] as double?;
    if (address != null && lat != null && lng != null) {
      state = state.copyWith(
        draftDestination: LocationPoint(
          address: address,
          latitude: lat,
          longitude: lng,
        ),
        visibleResultCount: _pageSize,
      );
    }
  }

  void updateFilters(RideSearchFilters filters) {
    state = state.copyWith(filters: filters, visibleResultCount: _pageSize);
  }

  /// Validates and executes a search with current draft state.
  /// Returns error message if validation fails, null on success.
  Future<String?> searchRides({bool forceRefresh = false}) async {
    // Validation: origin and destination required
    if (state.draftOrigin == null || state.draftDestination == null) {
      return 'Please enter both locations';
    }

    // Validation: prevent same origin and destination
    if (state.draftOrigin!.latitude == state.draftDestination!.latitude &&
        state.draftOrigin!.longitude == state.draftDestination!.longitude) {
      return 'Pickup and destination cannot be the same location';
    }

    // Validation: date must not be in the past
    final now = DateTime.now();
    if (state.draftDate.isBefore(DateTime(now.year, now.month, now.day))) {
      return 'Cannot search for past dates';
    }

    // Validation: seats must be valid
    if (state.draftSeats < 1 || state.draftSeats > 4) {
      return 'Seats must be between 1 and 4';
    }

    final queryKey = _buildDraftQueryKey(state);
    if (state.pendingQueryKey == queryKey) {
      return null;
    }
    if (!forceRefresh &&
        state.hasSearched &&
        state.lastCompletedQueryKey == queryKey) {
      return null;
    }

    final requestId = ++_latestSearchRequestId;

    state = state.copyWith(
      isLoading: true,
      error: null,
      pendingQueryKey: queryKey,
      visibleResultCount: _pageSize,
    );

    // Build committed filters from draft state
    final filters = RideSearchFilters(
      origin: state.draftOrigin,
      destination: state.draftDestination,
      departureDate: state.draftDate,
      minSeats: state.draftSeats,
      maxPrice: state.draftMaxPrice < 50 ? state.draftMaxPrice : null,
      womenOnly: state.draftFemaleOnly,
      allowPets: state.draftPetFriendly,
      minDriverRating: state.draftMinRating > 0 ? state.draftMinRating : null,
      sortBy: state.draftSortBy == 'recommended'
          ? 'departure_time'
          : state.draftSortBy,
    );

    // Capture repository before awaiting
    final repository = ref.read(rideRepositoryProvider);

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
      if (!ref.mounted || requestId != _latestSearchRequestId) return null;

      // Store full result set, surface first page
      final firstPage = rides.take(_pageSize).toList();

      state = state.copyWith(
        rides: firstPage,
        allSearchResults: rides,
        isLoading: false,
        error: null,
        filters: filters,
        hasSearched: true,
        hasMore: rides.length > _pageSize,
        visibleResultCount: _pageSize,
        lastCompletedQueryKey: queryKey,
        pendingQueryKey: null,
      );

      return null; // Success
    } catch (e, _) {
      if (!ref.mounted || requestId != _latestSearchRequestId) return null;
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        pendingQueryKey: null,
      );
      return e.toString();
    }
  }

  void clearResults() {
    state = state.copyWith(
      rides: const [],
      allSearchResults: const [],
      hasMore: true,
      visibleResultCount: _pageSize,
      lastCompletedQueryKey: null,
      pendingQueryKey: null,
      error: null,
    );
  }

  /// Reveals the next page of results from the cached [_allResults].
  void loadMore() {
    if (!state.hasMore || state.isLoading) return;

    final nextVisibleCount = state.visibleResultCount + _pageSize;
    final visibleRides = state.allSearchResults.take(nextVisibleCount).toList();
    final allShown = visibleRides.length >= state.allSearchResults.length;

    state = state.copyWith(
      rides: visibleRides,
      hasMore: !allShown,
      visibleResultCount: nextVisibleCount,
    );
  }
}

String _buildDraftQueryKey(RideSearchState state) {
  final origin = state.draftOrigin;
  final destination = state.draftDestination;
  final date = DateTime(
    state.draftDate.year,
    state.draftDate.month,
    state.draftDate.day,
  );

  return [
    origin?.latitude.toStringAsFixed(6) ?? '',
    origin?.longitude.toStringAsFixed(6) ?? '',
    destination?.latitude.toStringAsFixed(6) ?? '',
    destination?.longitude.toStringAsFixed(6) ?? '',
    date.toIso8601String(),
    state.draftSeats,
    state.draftMaxPrice.toStringAsFixed(2),
    state.draftFemaleOnly,
    state.draftInstantBook,
    state.draftVerifiedOnly,
    state.draftPetFriendly,
    state.draftMusicAllowed,
    state.draftMinRating.toStringAsFixed(1),
    state.draftSortBy,
    state.draftVehicleType,
  ].join('|');
}

// ---------------------------------------------------------------------------
// Ride Detail State — aggregates ride stream + bookings stream
// ---------------------------------------------------------------------------

/// Immutable UI state for any screen that shows a single ride with bookings.
class RideDetailState {
  const RideDetailState({
    this.ride = const AsyncValue.loading(),
    this.bookings = const [],
    this.isActing = false,
    this.actionError,
  });

  /// Real-time ride data from Firestore.
  final AsyncValue<RideModel?> ride;

  /// Live bookings for this ride (from the separate bookings sub-collection).
  final List<RideBooking> bookings;

  /// Whether a ride-detail action is currently in flight.
  final bool isActing;

  /// Error from the last action (book, accept, reject, cancel, etc.).
  final String? actionError;

  // Sentinel to distinguish "not passed" from "explicitly null".
  static const _unset = Object();

  RideDetailState copyWith({
    AsyncValue<RideModel?>? ride,
    List<RideBooking>? bookings,
    bool? isActing,
    Object? actionError = _unset,
  }) => RideDetailState(
    ride: ride ?? this.ride,
    bookings: bookings ?? this.bookings,
    isActing: isActing ?? this.isActing,
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
      state = state.copyWith(isActing: true, actionError: null);
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
            fromUserName: passenger.displayName,
            fromUserPhoto: passenger.photoUrl,
            rideId: ride.id,
            rideName: '$origin → $dest',
          );
        }
      } catch (_) {
        // Notification failure is non-fatal
      }

      state = state.copyWith(isActing: false, actionError: null);
      return true;
    } catch (e) {
      state = state.copyWith(isActing: false, actionError: e.toString());
      return false;
    }
  }

  Future<bool> acceptBooking(String bookingId) async {
    final ride = state.ride.value;
    if (ride == null) return false;
    try {
      state = state.copyWith(isActing: true, actionError: null);
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

      state = state.copyWith(isActing: false, actionError: null);
      return true;
    } catch (e) {
      state = state.copyWith(isActing: false, actionError: e.toString());
      return false;
    }
  }

  Future<bool> rejectBooking(String bookingId) async {
    final ride = state.ride.value;
    if (ride == null) return false;
    try {
      state = state.copyWith(isActing: true, actionError: null);
      await ref
          .read(rideRepositoryProvider)
          .updateBookingStatus(
            rideId: ride.id,
            bookingId: bookingId,
            newStatus: BookingStatus.rejected,
          );
      state = state.copyWith(isActing: false, actionError: null);
      return true;
    } catch (e) {
      state = state.copyWith(isActing: false, actionError: e.toString());
      return false;
    }
  }

  Future<bool> startRide() async {
    final ride = state.ride.value;
    if (ride == null) return false;
    try {
      state = state.copyWith(isActing: true, actionError: null);
      await ref.read(rideRepositoryProvider).startRide(ride.id);
      state = state.copyWith(isActing: false, actionError: null);
      return true;
    } catch (e) {
      state = state.copyWith(isActing: false, actionError: e.toString());
      return false;
    }
  }

  Future<bool> completeRide() async {
    final ride = state.ride.value;
    if (ride == null) return false;
    try {
      state = state.copyWith(isActing: true, actionError: null);
      await ref.read(rideServiceProvider.notifier).completeRide(ride.id);
      state = state.copyWith(isActing: false, actionError: null);
      return true;
    } catch (e) {
      state = state.copyWith(isActing: false, actionError: e.toString());
      return false;
    }
  }

  Future<bool> cancelRide({String reason = 'Cancelled by user'}) async {
    final ride = state.ride.value;
    if (ride == null) return false;
    try {
      state = state.copyWith(isActing: true, actionError: null);
      await ref.read(rideServiceProvider.notifier).cancelRide(ride.id, reason);
      state = state.copyWith(isActing: false, actionError: null);
      return true;
    } catch (e) {
      state = state.copyWith(isActing: false, actionError: e.toString());
      return false;
    }
  }
}

// ---------------------------------------------------------------------------
// Active Ride State — for driver / passenger active-ride screens
// ---------------------------------------------------------------------------

enum ActiveRidePhase { pickingUp, enRoute, arriving, completed }

enum ActiveRideLocationInitResult {
  ready,
  permissionRequired,
  permissionDenied,
  permissionDeniedForever,
  servicesDisabled,
  error,
}

/// Immutable state for active-ride screens that need live ride + bookings.
class ActiveRideState {
  static const _unset = Object();

  const ActiveRideState({
    this.ride = const AsyncValue.loading(),
    this.bookings = const [],
    this.phase = ActiveRidePhase.pickingUp,
    this.driverLiveLocation,
    this.currentLocation,
    this.isLoadingLocation = true,
    this.hasInitializedLocation = false,
    this.locationServicesEnabled = true,
    this.locationPermissionGranted = false,
    this.locationPermissionDeniedForever = false,
    this.locationError,
    this.userHeading = 0,
    this.currentSpeedKmh = 0,
    this.isNavigationExpanded = true,
    this.showPassengerDetails = false,
    this.isProcessing = false,
    this.pickedUpPassengerIds = const <String>{},
    this.nearbyPOIs = const <PointOfInterest>[],
    this.showPOIMarkers = false,
    this.osrmRoutePoints,
    this.loadedRouteKey,
    this.loadingRouteKey,
    this.isLoadingOsrmRoute = false,
    this.remainingDistanceKm,
    this.remainingEtaMinutes,
    this.isOffRoute = false,
    this.routeDeviationMeters = 0,
    this.passedWaypointIndices = const <int>{},
    this.hasSkippedReview = false,
    this.hasAutoNavigatedToCompletion = false,
    this.actionError,
  });

  final AsyncValue<RideModel?> ride;
  final List<RideBooking> bookings;
  final ActiveRidePhase phase;
  final ({double latitude, double longitude})? driverLiveLocation;
  final LatLng? currentLocation;
  final bool isLoadingLocation;
  final bool hasInitializedLocation;
  final bool locationServicesEnabled;
  final bool locationPermissionGranted;
  final bool locationPermissionDeniedForever;
  final String? locationError;
  final double userHeading;
  final double currentSpeedKmh;
  final bool isNavigationExpanded;
  final bool showPassengerDetails;
  final bool isProcessing;
  final Set<String> pickedUpPassengerIds;
  final List<PointOfInterest> nearbyPOIs;
  final bool showPOIMarkers;
  final List<LatLng>? osrmRoutePoints;
  final String? loadedRouteKey;
  final String? loadingRouteKey;
  final bool isLoadingOsrmRoute;
  final double? remainingDistanceKm;
  final int? remainingEtaMinutes;
  final bool isOffRoute;
  final double routeDeviationMeters;
  final Set<int> passedWaypointIndices;
  final bool hasSkippedReview;
  final bool hasAutoNavigatedToCompletion;
  final String? actionError;

  RideModel? get currentRide => ride.value;

  ActiveRideState copyWith({
    AsyncValue<RideModel?>? ride,
    List<RideBooking>? bookings,
    ActiveRidePhase? phase,
    Object? driverLiveLocation = _unset,
    Object? currentLocation = _unset,
    bool? isLoadingLocation,
    bool? hasInitializedLocation,
    bool? locationServicesEnabled,
    bool? locationPermissionGranted,
    bool? locationPermissionDeniedForever,
    Object? locationError = _unset,
    double? userHeading,
    double? currentSpeedKmh,
    bool? isNavigationExpanded,
    bool? showPassengerDetails,
    bool? isProcessing,
    Set<String>? pickedUpPassengerIds,
    List<PointOfInterest>? nearbyPOIs,
    bool? showPOIMarkers,
    Object? osrmRoutePoints = _unset,
    Object? loadedRouteKey = _unset,
    Object? loadingRouteKey = _unset,
    bool? isLoadingOsrmRoute,
    Object? remainingDistanceKm = _unset,
    Object? remainingEtaMinutes = _unset,
    bool? isOffRoute,
    double? routeDeviationMeters,
    Set<int>? passedWaypointIndices,
    bool? hasSkippedReview,
    bool? hasAutoNavigatedToCompletion,
    Object? actionError = _unset,
  }) => ActiveRideState(
    ride: ride ?? this.ride,
    bookings: bookings ?? this.bookings,
    phase: phase ?? this.phase,
    driverLiveLocation: driverLiveLocation == _unset
        ? this.driverLiveLocation
        : driverLiveLocation as ({double latitude, double longitude})?,
    currentLocation: currentLocation == _unset
        ? this.currentLocation
        : currentLocation as LatLng?,
    isLoadingLocation: isLoadingLocation ?? this.isLoadingLocation,
    hasInitializedLocation:
        hasInitializedLocation ?? this.hasInitializedLocation,
    locationServicesEnabled:
        locationServicesEnabled ?? this.locationServicesEnabled,
    locationPermissionGranted:
        locationPermissionGranted ?? this.locationPermissionGranted,
    locationPermissionDeniedForever:
        locationPermissionDeniedForever ?? this.locationPermissionDeniedForever,
    locationError: locationError == _unset
        ? this.locationError
        : locationError as String?,
    userHeading: userHeading ?? this.userHeading,
    currentSpeedKmh: currentSpeedKmh ?? this.currentSpeedKmh,
    isNavigationExpanded: isNavigationExpanded ?? this.isNavigationExpanded,
    showPassengerDetails: showPassengerDetails ?? this.showPassengerDetails,
    isProcessing: isProcessing ?? this.isProcessing,
    pickedUpPassengerIds: pickedUpPassengerIds ?? this.pickedUpPassengerIds,
    nearbyPOIs: nearbyPOIs ?? this.nearbyPOIs,
    showPOIMarkers: showPOIMarkers ?? this.showPOIMarkers,
    osrmRoutePoints: osrmRoutePoints == _unset
        ? this.osrmRoutePoints
        : osrmRoutePoints as List<LatLng>?,
    loadedRouteKey: loadedRouteKey == _unset
        ? this.loadedRouteKey
        : loadedRouteKey as String?,
    loadingRouteKey: loadingRouteKey == _unset
        ? this.loadingRouteKey
        : loadingRouteKey as String?,
    isLoadingOsrmRoute: isLoadingOsrmRoute ?? this.isLoadingOsrmRoute,
    remainingDistanceKm: remainingDistanceKm == _unset
        ? this.remainingDistanceKm
        : remainingDistanceKm as double?,
    remainingEtaMinutes: remainingEtaMinutes == _unset
        ? this.remainingEtaMinutes
        : remainingEtaMinutes as int?,
    isOffRoute: isOffRoute ?? this.isOffRoute,
    routeDeviationMeters: routeDeviationMeters ?? this.routeDeviationMeters,
    passedWaypointIndices: passedWaypointIndices ?? this.passedWaypointIndices,
    hasSkippedReview: hasSkippedReview ?? this.hasSkippedReview,
    hasAutoNavigatedToCompletion:
        hasAutoNavigatedToCompletion ?? this.hasAutoNavigatedToCompletion,
    actionError: actionError == _unset
        ? this.actionError
        : actionError as String?,
  );
}

/// ViewModel for active-ride screens — views watch only this provider.
@riverpod
class ActiveRideViewModel extends _$ActiveRideViewModel {
  StreamSubscription<Position>? _positionStreamSubscription;
  Future<ActiveRideLocationInitResult>? _locationInitializationOperation;

  @override
  ActiveRideState build(String rideId) {
    ref.onDispose(() => _positionStreamSubscription?.cancel());

    ref.listen(rideStreamProvider(rideId), (_, next) {
      _handleRideUpdate(next);
    });

    ref.listen(bookingsByRideProvider(rideId), (_, next) {
      _handleBookingsUpdate(next.value ?? const <RideBooking>[]);
    });

    ref.listen(driverLiveLocationProvider(rideId), (_, next) {
      _handleDriverLiveLocationUpdate(next.value);
    });

    final rideAsync = ref.read(rideStreamProvider(rideId));
    final bookings =
        ref.read(bookingsByRideProvider(rideId)).value ?? const <RideBooking>[];
    final driverLiveLocation = ref
        .read(driverLiveLocationProvider(rideId))
        .value;

    Future<void>.microtask(() {
      if (!ref.mounted) return;
      _handleRideUpdate(ref.read(rideStreamProvider(rideId)));
    });

    return ActiveRideState(
      ride: rideAsync,
      bookings: bookings,
      phase: _derivePhase(rideAsync.value, ActiveRidePhase.pickingUp),
      driverLiveLocation: driverLiveLocation,
    );
  }

  void skipReviewPrompt() {
    if (state.hasSkippedReview) return;
    state = state.copyWith(hasSkippedReview: true);
  }

  void markCompletionNavigationHandled() {
    if (state.hasAutoNavigatedToCompletion) return;
    state = state.copyWith(hasAutoNavigatedToCompletion: true);
  }

  Future<ActiveRideLocationInitResult> initializeLocationTracking({
    bool requestPermission = false,
  }) {
    final existingOperation = _locationInitializationOperation;
    if (existingOperation != null) {
      return existingOperation;
    }

    final initializationOperation = _runLocationInitialization(
      requestPermission: requestPermission,
    );
    _locationInitializationOperation = initializationOperation;
    return initializationOperation.whenComplete(() {
      if (identical(
        _locationInitializationOperation,
        initializationOperation,
      )) {
        _locationInitializationOperation = null;
      }
    });
  }

  Future<ActiveRideLocationInitResult> _runLocationInitialization({
    required bool requestPermission,
  }) async {
    state = state.copyWith(
      isLoadingLocation: true,
      hasInitializedLocation: true,
      locationError: null,
    );

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!ref.mounted) return ActiveRideLocationInitResult.error;

      if (!serviceEnabled) {
        state = state.copyWith(
          isLoadingLocation: false,
          locationServicesEnabled: false,
          locationPermissionGranted: false,
          locationPermissionDeniedForever: false,
          locationError: 'location-services-disabled',
        );
        return ActiveRideLocationInitResult.servicesDisabled;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied && requestPermission) {
        permission = await Geolocator.requestPermission();
      }

      if (!ref.mounted) return ActiveRideLocationInitResult.error;

      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(
          isLoadingLocation: false,
          locationServicesEnabled: true,
          locationPermissionGranted: false,
          locationPermissionDeniedForever: true,
          locationError: 'location-permission-denied-forever',
        );
        return ActiveRideLocationInitResult.permissionDeniedForever;
      }

      if (permission == LocationPermission.denied) {
        state = state.copyWith(
          isLoadingLocation: false,
          locationServicesEnabled: true,
          locationPermissionGranted: false,
          locationPermissionDeniedForever: false,
          locationError: requestPermission
              ? 'location-permission-denied'
              : null,
        );
        return requestPermission
            ? ActiveRideLocationInitResult.permissionDenied
            : ActiveRideLocationInitResult.permissionRequired;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      if (!ref.mounted) return ActiveRideLocationInitResult.error;

      state = state.copyWith(
        currentLocation: LatLng(position.latitude, position.longitude),
        userHeading: _sanitizeHeading(position.heading),
        currentSpeedKmh: _speedKmhFrom(position),
        isLoadingLocation: false,
        locationServicesEnabled: true,
        locationPermissionGranted: true,
        locationPermissionDeniedForever: false,
        locationError: null,
      );

      _startLocationStream();
      _updateDynamicEta(state.currentRide);
      return ActiveRideLocationInitResult.ready;
    } catch (e, stackTrace) {
      TalkerService.error(
        'Error initializing active ride location',
        e,
        stackTrace,
      );
      if (!ref.mounted) return ActiveRideLocationInitResult.error;

      state = state.copyWith(
        isLoadingLocation: false,
        locationError: 'location-init-failed',
      );
      return ActiveRideLocationInitResult.error;
    }
  }

  void _startLocationStream() {
    _positionStreamSubscription?.cancel();

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (position) {
            if (!ref.mounted) return;

            state = state.copyWith(
              currentLocation: LatLng(position.latitude, position.longitude),
              userHeading: _sanitizeHeading(position.heading),
              currentSpeedKmh: _speedKmhFrom(position),
              isLoadingLocation: false,
              locationServicesEnabled: true,
              locationPermissionGranted: true,
              locationPermissionDeniedForever: false,
              locationError: null,
            );

            unawaited(
              ref
                  .read(rideActionsViewModelProvider)
                  .updateLiveLocation(
                    rideId,
                    position.latitude,
                    position.longitude,
                  ),
            );

            _updateDynamicEta(state.currentRide);
          },
          onError: (Object error, StackTrace stackTrace) {
            TalkerService.error(
              'Active ride GPS stream failed',
              error,
              stackTrace,
            );
            if (!ref.mounted) return;
            state = state.copyWith(
              isLoadingLocation: false,
              locationError: 'location-stream-failed',
            );
          },
        );
  }

  void toggleNavigationExpanded() {
    state = state.copyWith(isNavigationExpanded: !state.isNavigationExpanded);
  }

  void showPassengerDetails() {
    if (state.showPassengerDetails) return;
    state = state.copyWith(showPassengerDetails: true);
  }

  void hidePassengerDetails() {
    if (!state.showPassengerDetails) return;
    state = state.copyWith(showPassengerDetails: false);
  }

  void selectPoi(PointOfInterest poi) {
    state = state.copyWith(
      nearbyPOIs: <PointOfInterest>[poi],
      showPOIMarkers: true,
    );
  }

  void clearPoiMarkers() {
    state = state.copyWith(
      nearbyPOIs: const <PointOfInterest>[],
      showPOIMarkers: false,
    );
  }

  void togglePickedUpPassenger(String passengerId) {
    final nextPickedUp = <String>{...state.pickedUpPassengerIds};
    if (!nextPickedUp.add(passengerId)) {
      nextPickedUp.remove(passengerId);
    }

    state = state.copyWith(pickedUpPassengerIds: nextPickedUp);
  }

  void transitionToArriving() {
    if (state.isProcessing || state.phase != ActiveRidePhase.enRoute) {
      return;
    }

    state = state.copyWith(phase: ActiveRidePhase.arriving);
  }

  Future<bool> startRide() async {
    final ride = state.currentRide;
    if (ride == null || state.isProcessing) return false;

    try {
      state = state.copyWith(isProcessing: true, actionError: null);
      await ref.read(rideRepositoryProvider).startRide(ride.id);
      if (!ref.mounted) return false;

      state = state.copyWith(
        isProcessing: false,
        actionError: null,
        phase: ActiveRidePhase.enRoute,
      );
      return true;
    } catch (e) {
      if (!ref.mounted) return false;
      state = state.copyWith(isProcessing: false, actionError: e.toString());
      return false;
    }
  }

  Future<bool> completeRide() async {
    final ride = state.currentRide;
    if (ride == null || state.isProcessing) return false;

    try {
      state = state.copyWith(isProcessing: true, actionError: null);
      await ref.read(rideServiceProvider.notifier).completeRide(ride.id);
      if (!ref.mounted) return false;

      state = state.copyWith(
        isProcessing: false,
        actionError: null,
        phase: ActiveRidePhase.completed,
      );
      return true;
    } catch (e) {
      if (!ref.mounted) return false;
      state = state.copyWith(isProcessing: false, actionError: e.toString());
      return false;
    }
  }

  Future<bool> cancelRide({String reason = 'Cancelled by user'}) async {
    final ride = state.currentRide;
    if (ride == null || state.isProcessing) return false;

    try {
      state = state.copyWith(isProcessing: true, actionError: null);
      await ref.read(rideServiceProvider.notifier).cancelRide(ride.id, reason);
      if (!ref.mounted) return false;

      state = state.copyWith(isProcessing: false, actionError: null);
      return true;
    } catch (e) {
      if (!ref.mounted) return false;
      state = state.copyWith(isProcessing: false, actionError: e.toString());
      return false;
    }
  }

  void _handleRideUpdate(AsyncValue<RideModel?> rideAsync) {
    final ride = rideAsync.value;
    final phase = _derivePhase(ride, state.phase);

    state = state.copyWith(ride: rideAsync, phase: phase);

    if (ride == null) {
      _clearDynamicEta();
      _clearPassengerRouteTracking();
      return;
    }

    if (ride.status != RideStatus.completed &&
        state.hasAutoNavigatedToCompletion) {
      state = state.copyWith(hasAutoNavigatedToCompletion: false);
    }

    unawaited(_ensureOsrmRouteLoaded(ride));
    _updateDynamicEta(ride);
    _updatePassengerRouteTracking(ride, state.driverLiveLocation);
  }

  void _handleBookingsUpdate(List<RideBooking> bookings) {
    final validPassengerIds = bookings
        .map((booking) => booking.passengerId)
        .toSet();
    final pickedUpPassengerIds = state.pickedUpPassengerIds
        .where(validPassengerIds.contains)
        .toSet();

    state = state.copyWith(
      bookings: bookings,
      pickedUpPassengerIds: pickedUpPassengerIds,
    );
  }

  void _handleDriverLiveLocationUpdate(
    ({double latitude, double longitude})? driverLiveLocation,
  ) {
    state = state.copyWith(driverLiveLocation: driverLiveLocation);
    _updatePassengerRouteTracking(state.currentRide, driverLiveLocation);
  }

  ActiveRidePhase _derivePhase(RideModel? ride, ActiveRidePhase currentPhase) {
    if (ride == null) return currentPhase;
    if (ride.status == RideStatus.completed) {
      return ActiveRidePhase.completed;
    }
    if (ride.status == RideStatus.inProgress &&
        currentPhase == ActiveRidePhase.pickingUp) {
      return ActiveRidePhase.enRoute;
    }
    return currentPhase;
  }

  Future<void> _ensureOsrmRouteLoaded(RideModel ride) async {
    final routeKey = _routeKeyFor(ride);
    final alreadyLoaded =
        state.loadedRouteKey == routeKey && state.osrmRoutePoints != null;
    final isLoadingSameRoute =
        state.isLoadingOsrmRoute && state.loadingRouteKey == routeKey;

    if (alreadyLoaded || isLoadingSameRoute) {
      return;
    }

    state = state.copyWith(
      isLoadingOsrmRoute: true,
      loadingRouteKey: routeKey,
      osrmRoutePoints: state.loadedRouteKey == routeKey
          ? state.osrmRoutePoints
          : null,
      loadedRouteKey: state.loadedRouteKey == routeKey
          ? state.loadedRouteKey
          : null,
      remainingDistanceKm: state.loadedRouteKey == routeKey
          ? state.remainingDistanceKm
          : null,
      remainingEtaMinutes: state.loadedRouteKey == routeKey
          ? state.remainingEtaMinutes
          : null,
    );

    try {
      final waypoints = ride.route.waypoints
          .map(
            (waypoint) =>
                LatLng(waypoint.location.latitude, waypoint.location.longitude),
          )
          .toList(growable: false);

      final routeInfo = await RoutingService.getRoute(
        origin: LatLng(ride.origin.latitude, ride.origin.longitude),
        destination: LatLng(
          ride.destination.latitude,
          ride.destination.longitude,
        ),
        waypoints: waypoints.isEmpty ? null : waypoints,
      );

      if (!ref.mounted || state.loadingRouteKey != routeKey) {
        return;
      }

      state = state.copyWith(
        osrmRoutePoints: routeInfo?.coordinates,
        loadedRouteKey: routeKey,
        loadingRouteKey: null,
        isLoadingOsrmRoute: false,
      );
      _updateDynamicEta(ride);
      _updatePassengerRouteTracking(ride, state.driverLiveLocation);
    } catch (e, stackTrace) {
      TalkerService.error(
        'Error loading active ride OSRM route',
        e,
        stackTrace,
      );
      if (!ref.mounted || state.loadingRouteKey != routeKey) {
        return;
      }

      state = state.copyWith(
        loadedRouteKey: routeKey,
        loadingRouteKey: null,
        isLoadingOsrmRoute: false,
      );
    }
  }

  void _updateDynamicEta(RideModel? ride) {
    final currentLocation = state.currentLocation;
    final routePoints = state.osrmRoutePoints;
    if (ride == null ||
        currentLocation == null ||
        routePoints == null ||
        routePoints.length < 2) {
      _clearDynamicEta();
      return;
    }

    var minimumDistance = double.infinity;
    var closestIndex = 0;
    for (var index = 0; index < routePoints.length; index++) {
      final distance = _haversineKm(currentLocation, routePoints[index]);
      if (!distance.isFinite) continue;
      if (distance < minimumDistance) {
        minimumDistance = distance;
        closestIndex = index;
      }
    }

    if (!minimumDistance.isFinite) {
      _clearDynamicEta();
      return;
    }

    var remainingDistance = _haversineKm(
      currentLocation,
      routePoints[closestIndex],
    );
    for (var index = closestIndex; index < routePoints.length - 1; index++) {
      remainingDistance += _haversineKm(
        routePoints[index],
        routePoints[index + 1],
      );
    }

    final totalDistance = ride.distanceKm ?? ride.route.distanceKm ?? 0;
    final totalDuration =
        ride.durationMinutes ?? ride.route.durationMinutes ?? 0;
    if (!remainingDistance.isFinite ||
        remainingDistance < 0 ||
        totalDistance <= 0 ||
        totalDuration <= 0) {
      _clearDynamicEta();
      return;
    }

    final ratio = (remainingDistance / totalDistance).clamp(0.0, 1.0);
    final etaMinutes = (ratio * totalDuration).round().clamp(0, 999);

    state = state.copyWith(
      remainingDistanceKm: remainingDistance,
      remainingEtaMinutes: etaMinutes,
    );
  }

  void _clearDynamicEta() {
    state = state.copyWith(
      remainingDistanceKm: null,
      remainingEtaMinutes: null,
    );
  }

  void _updatePassengerRouteTracking(
    RideModel? ride,
    ({double latitude, double longitude})? driverLiveLocation,
  ) {
    if (ride == null ||
        ride.status != RideStatus.inProgress ||
        driverLiveLocation == null ||
        state.osrmRoutePoints == null ||
        state.osrmRoutePoints!.length < 2) {
      _clearPassengerRouteTracking();
      return;
    }

    final driverPosition = LatLng(
      driverLiveLocation.latitude,
      driverLiveLocation.longitude,
    );
    double minimumDistanceMeters = double.infinity;
    for (final point in state.osrmRoutePoints!) {
      final distanceMeters = _haversineKm(driverPosition, point) * 1000;
      if (distanceMeters < minimumDistanceMeters) {
        minimumDistanceMeters = distanceMeters;
      }
    }

    final isOffRoute = minimumDistanceMeters > 500;
    final passedWaypointIndices = _getPassedWaypointIndices(
      driverPosition,
      state.osrmRoutePoints!,
      ride,
    );

    state = state.copyWith(
      isOffRoute: isOffRoute,
      routeDeviationMeters: minimumDistanceMeters.isFinite
          ? minimumDistanceMeters
          : 0,
      passedWaypointIndices: passedWaypointIndices,
    );
  }

  Set<int> _getPassedWaypointIndices(
    LatLng driverPosition,
    List<LatLng> routePoints,
    RideModel ride,
  ) {
    if (routePoints.length < 2) return const <int>{};

    var driverIndex = 0;
    var minimumDriverDistance = double.infinity;
    for (var index = 0; index < routePoints.length; index++) {
      final distance = _haversineKm(driverPosition, routePoints[index]);
      if (distance < minimumDriverDistance) {
        minimumDriverDistance = distance;
        driverIndex = index;
      }
    }

    final passedWaypointIndices = <int>{};
    for (
      var waypointIndex = 0;
      waypointIndex < ride.route.waypoints.length;
      waypointIndex++
    ) {
      final waypoint = ride.route.waypoints[waypointIndex];
      final waypointLatLng = LatLng(
        waypoint.location.latitude,
        waypoint.location.longitude,
      );

      var nearestWaypointIndex = 0;
      var minimumWaypointDistance = double.infinity;
      for (var routeIndex = 0; routeIndex < routePoints.length; routeIndex++) {
        final distance = _haversineKm(waypointLatLng, routePoints[routeIndex]);
        if (distance < minimumWaypointDistance) {
          minimumWaypointDistance = distance;
          nearestWaypointIndex = routeIndex;
        }
      }

      if (driverIndex >= nearestWaypointIndex) {
        passedWaypointIndices.add(waypoint.order);
      }
    }

    return passedWaypointIndices;
  }

  void _clearPassengerRouteTracking() {
    state = state.copyWith(
      isOffRoute: false,
      routeDeviationMeters: 0,
      passedWaypointIndices: const <int>{},
    );
  }

  String _routeKeyFor(RideModel ride) {
    final buffer = StringBuffer()
      ..write(ride.id)
      ..write('|')
      ..write(ride.origin.latitude.toStringAsFixed(6))
      ..write(',')
      ..write(ride.origin.longitude.toStringAsFixed(6))
      ..write('|')
      ..write(ride.destination.latitude.toStringAsFixed(6))
      ..write(',')
      ..write(ride.destination.longitude.toStringAsFixed(6));

    for (final waypoint in ride.route.waypoints) {
      buffer
        ..write('|')
        ..write(waypoint.location.latitude.toStringAsFixed(6))
        ..write(',')
        ..write(waypoint.location.longitude.toStringAsFixed(6));
    }

    return buffer.toString();
  }

  double _sanitizeHeading(double heading) {
    return heading.isFinite && heading >= 0 ? heading : 0;
  }

  double _speedKmhFrom(Position position) {
    final speed = position.speed;
    if (!speed.isFinite || speed < 0) return 0;
    return speed * 3.6;
  }

  double _haversineKm(LatLng origin, LatLng destination) {
    const earthRadiusKm = 6371.0;
    final deltaLat = _degToRad(destination.latitude - origin.latitude);
    final deltaLon = _degToRad(destination.longitude - origin.longitude);
    final sinLat = math.sin(deltaLat / 2);
    final sinLon = math.sin(deltaLon / 2);
    final haversine =
        sinLat * sinLat +
        math.cos(_degToRad(origin.latitude)) *
            math.cos(_degToRad(destination.latitude)) *
            sinLon *
            sinLon;
    return 2 * earthRadiusKm * math.asin(math.sqrt(haversine));
  }

  double _degToRad(double degrees) => degrees * math.pi / 180;
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

/// Ride reliability stats for a user (cancel & no-show counts).
///
/// Streams the user's ride history (completed + cancelled) and counts
/// how many were cancelled by the driver.
@riverpod
Stream<({int cancelCount, int noShowCount})> userRideReliability(
  Ref ref,
  String userId,
) {
  final repository = ref.read(rideRepositoryProvider);
  return repository.getRideHistory(userId).map((rides) {
    final cancelCount = rides
        .where((r) => r.status == RideStatus.cancelled)
        .length;
    return (cancelCount: cancelCount, noShowCount: 0);
  });
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
