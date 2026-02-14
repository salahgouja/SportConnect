import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sport_connect/core/converters/timestamp_converter.dart';
import 'package:sport_connect/core/models/location/location_point.dart';
import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';
import 'ride_route.dart';
import 'ride_pricing.dart';
import 'ride_capacity.dart';
import 'ride_schedule.dart';
import 'ride_preferences.dart';

part 'ride_model.freezed.dart';
part 'ride_model.g.dart';

/// Ride status enum
enum RideStatus { draft, active, full, inProgress, completed, cancelled }

/// Refactored Ride model using composition
/// Follows Single Responsibility Principle
///
/// Convenience getters bridge old flat field names to composed sub-models,
/// so the view layer doesn't need hundreds of changes.
@freezed
abstract class RideModel with _$RideModel {
  const RideModel._();

  const factory RideModel({
    required String id,
    required String driverId,

    // Composed sub-models
    required RideRoute route,
    required RideSchedule schedule,
    required RideCapacity capacity,
    required RidePricing pricing,
    required RidePreferences preferences,

    // Status
    @Default(RideStatus.draft) RideStatus status,

    // Vehicle reference (resolved through VehicleRepository)
    String? vehicleId,
    String? vehicleInfo,

    // Bookings (lightweight - detailed bookings stored separately)
    @Default([]) List<String> bookingIds,

    // Bookings list (populated by service layer when full booking data is needed)
    @Default([]) List<RideBooking> bookings,

    // Reviews (count only - detailed reviews stored separately)
    @Default(0) int reviewCount,
    @Default(0.0) double averageRating,

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

  // ── Convenience getters (bridge old flat API → composed sub-models) ──

  /// Origin location
  LocationPoint get origin => route.origin;

  /// Destination location
  LocationPoint get destination => route.destination;

  /// Departure time
  DateTime get departureTime => schedule.departureTime;

  /// Price per seat (as double for backward compat)
  double get pricePerSeat => pricing.pricePerSeat.amount;

  /// Currency string
  String? get currency => pricing.pricePerSeat.currency;

  /// Available seats
  int get availableSeats => capacity.available;

  /// Booked seats
  int get bookedSeats => capacity.booked;

  /// Remaining seats
  int get remainingSeats => capacity.remaining;

  /// Duration in minutes
  int? get durationMinutes => route.durationMinutes;

  /// Distance in km
  double? get distanceKm => route.distanceKm;

  // ── Business logic getters ──

  /// Is ride bookable
  bool get isBookable =>
      status == RideStatus.active && !capacity.isFull && !schedule.isPast;

  /// Is ride upcoming (within 24h)
  bool get isUpcoming => schedule.isUpcoming && status == RideStatus.active;

  /// Is ride happening soon
  bool get isHappeningSoon => schedule.isHappeningSoon;

  /// Get formatted price
  String get formattedPrice => pricing.formattedPrice;

  /// CO2 saved per passenger
  double get co2SavedPerPassenger => route.co2SavedPerPassenger;

  // ── Preference convenience getters ──

  /// Allow pets
  bool get allowPets => preferences.allowPets;

  /// Allow smoking
  bool get allowSmoking => preferences.allowSmoking;

  /// Allow luggage
  bool get allowLuggage => preferences.allowLuggage;

  /// Women only
  bool get isWomenOnly => preferences.isWomenOnly;

  /// Max detour minutes
  int? get maxDetourMinutes => preferences.maxDetourMinutes;

  /// Allow chat convenience getter
  bool get allowChat => preferences.allowChat;

  /// Arrival time
  DateTime? get arrivalTime => schedule.arrivalTime;

  /// Is price negotiable (delegates to pricing)
  bool get isPriceNegotiable => pricing.isNegotiable;

  /// Accepts online payment (delegates to pricing)
  bool get acceptsOnlinePayment => pricing.acceptsOnlinePayment;

  ///Is ride full
  bool get isFull => capacity.isFull;

  /// Accepted bookings (bookings with accepted status)
  List<RideBooking> get acceptedBookings =>
      bookings.where((b) => b.status == BookingStatus.accepted).toList();
}
