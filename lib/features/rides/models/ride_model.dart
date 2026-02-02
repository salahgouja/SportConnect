import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sport_connect/features/auth/models/user_model.dart';

part 'ride_model.freezed.dart';
part 'ride_model.g.dart';

/// Ride status enum
enum RideStatus { draft, active, full, inProgress, completed, cancelled }

/// Booking status enum
enum BookingStatus { pending, accepted, rejected, cancelled, completed }

/// Location point model
@freezed
abstract class LocationPoint with _$LocationPoint {
  const factory LocationPoint({
    required String address,
    required double latitude,
    required double longitude,
    String? placeId,
    String? city,
  }) = _LocationPoint;

  factory LocationPoint.fromJson(Map<String, dynamic> json) =>
      _$LocationPointFromJson(json);
}

/// Route waypoint
@freezed
abstract class RouteWaypoint with _$RouteWaypoint {
  const factory RouteWaypoint({
    required LocationPoint location,
    @Default(0) int order,
    @TimestampConverter() DateTime? estimatedArrival,
  }) = _RouteWaypoint;

  factory RouteWaypoint.fromJson(Map<String, dynamic> json) =>
      _$RouteWaypointFromJson(json);
}

/// Booking model for ride reservations
@freezed
abstract class RideBooking with _$RideBooking {
  const factory RideBooking({
    required String id,
    required String passengerId,
    @Default('Unknown Passenger') String passengerName,
    String? passengerPhotoUrl,
    @Default(1) int seatsBooked,
    @Default(BookingStatus.pending) BookingStatus status,
    LocationPoint? pickupLocation,
    LocationPoint? dropoffLocation,
    String? note,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? respondedAt,
  }) = _RideBooking;

  factory RideBooking.fromJson(Map<String, dynamic> json) =>
      _$RideBookingFromJson(json);
}

/// Review model
@freezed
abstract class RideReview with _$RideReview {
  const factory RideReview({
    required String id,
    required String reviewerId,
    required String reviewerName,
    String? reviewerPhotoUrl,
    required String revieweeId,
    required double rating,
    String? comment,
    @Default([]) List<String> tags,
    @TimestampConverter() DateTime? createdAt,
  }) = _RideReview;

  factory RideReview.fromJson(Map<String, dynamic> json) =>
      _$RideReviewFromJson(json);
}

/// Main Ride model
@freezed
abstract class RideModel with _$RideModel {
  const RideModel._();

  const factory RideModel({
    required String id,
    required String driverId,
    required String driverName,
    String? driverPhotoUrl,
    double? driverRating,

    // Route information
    required LocationPoint origin,
    required LocationPoint destination,
    @Default([]) List<RouteWaypoint> waypoints,

    // Route details
    double? distanceKm,
    int? durationMinutes,
    String? polylineEncoded,

    // Timing
    @RequiredTimestampConverter() required DateTime departureTime,
    @TimestampConverter() DateTime? arrivalTime,
    @Default(15) int flexibilityMinutes,

    // Capacity
    @Default(3) int availableSeats,
    @Default(0) int bookedSeats,

    // Pricing
    @Default(0.0) double pricePerSeat,
    String? currency,
    @Default(false) bool isPriceNegotiable,
    @Default(false) bool acceptsOnlinePayment, // Driver has Stripe connected
    // Status
    @Default(RideStatus.draft) RideStatus status,

    // Preferences
    @Default(false) bool allowPets,
    @Default(false) bool allowSmoking,
    @Default(true) bool allowLuggage,
    @Default(false) bool isWomenOnly,
    @Default(true) bool allowChat,
    int? maxDetourMinutes,

    // Vehicle
    String? vehicleId,
    String? vehicleInfo,

    // Bookings
    @Default([]) List<RideBooking> bookings,

    // Reviews
    @Default([]) List<RideReview> reviews,

    // Recurrence (for regular commutes)
    @Default(false) bool isRecurring,
    @Default([]) List<int> recurringDays,
    @TimestampConverter() DateTime? recurringEndDate,

    // XP Rewards
    @Default(50) int xpReward,

    // Metadata
    String? notes,
    @Default([]) List<String> tags,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
  }) = _RideModel;

  factory RideModel.fromJson(Map<String, dynamic> json) =>
      _$RideModelFromJson(json);

  /// Remaining seats
  int get remainingSeats => availableSeats - bookedSeats;

  /// Is ride full
  bool get isFull => remainingSeats <= 0;

  /// Is ride bookable
  bool get isBookable =>
      status == RideStatus.active &&
      !isFull &&
      departureTime.isAfter(DateTime.now());

  /// Pending bookings count
  int get pendingBookingsCount =>
      bookings.where((b) => b.status == BookingStatus.pending).length;

  /// Accepted bookings
  List<RideBooking> get acceptedBookings =>
      bookings.where((b) => b.status == BookingStatus.accepted).toList();

  /// Average rating from reviews
  double get averageRating {
    if (reviews.isEmpty) return 0.0;
    return reviews.map((r) => r.rating).reduce((a, b) => a + b) /
        reviews.length;
  }

  /// Formatted price
  String get formattedPrice =>
      '${pricePerSeat.toStringAsFixed(2)} ${currency ?? 'USD'}';

  /// CO2 saved per passenger (kg) - approx 0.12 kg per km
  double get co2SavedPerPassenger => (distanceKm ?? 0) * 0.12;
}

/// Ride search filters
@freezed
abstract class RideSearchFilters with _$RideSearchFilters {
  const factory RideSearchFilters({
    LocationPoint? origin,
    LocationPoint? destination,
    @TimestampConverter() DateTime? departureDate,
    @TimestampConverter() DateTime? departureTimeFrom,
    @TimestampConverter() DateTime? departureTimeTo,
    @Default(1) int minSeats,
    double? maxPrice,
    double? maxRadiusKm,
    @Default(false) bool allowPets,
    @Default(false) bool allowSmoking,
    @Default(false) bool womenOnly,
    double? minDriverRating,
    @Default('departure_time') String sortBy,
    @Default(true) bool sortAscending,
  }) = _RideSearchFilters;

  factory RideSearchFilters.fromJson(Map<String, dynamic> json) =>
      _$RideSearchFiltersFromJson(json);
}
