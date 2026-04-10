import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sport_connect/core/converters/timestamp_converter.dart';
import 'package:sport_connect/core/models/location/location_point.dart';

part 'ride_booking.freezed.dart';
part 'ride_booking.g.dart';

/// Booking status enum
enum BookingStatus { pending, accepted, rejected, cancelled, completed }

/// Booking model for ride reservations
/// Now stored separately from rides for better scalability
@freezed
abstract class RideBooking with _$RideBooking {
  const factory RideBooking({
    required String id,
    required String rideId,
    required String passengerId,
    String? driverId,
    @Default(1) int seatsBooked,
    @Default(BookingStatus.pending) BookingStatus status,
    LocationPoint? pickupLocation,
    LocationPoint? dropoffLocation,
    String? note,
    // No denormalized user data - fetch via passengerId for single source of truth
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? respondedAt,
    // Payment tracking — stamped when Stripe payment succeeds
    String? paymentIntentId,
    @TimestampConverter() DateTime? paidAt,
    // Pickup OTP — shown to passenger, driver enters this to confirm pickup
    String? pickupOtp,
  }) = _RideBooking;

  factory RideBooking.fromJson(Map<String, dynamic> json) =>
      _$RideBookingFromJson(json);
}
