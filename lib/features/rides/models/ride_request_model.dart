import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sport_connect/core/converters/timestamp_converter.dart';
import 'package:sport_connect/core/models/location/location_point.dart';
import 'package:intl/intl.dart';
import 'package:sport_connect/core/models/value_objects/money.dart';

part 'ride_request_model.freezed.dart';
part 'ride_request_model.g.dart';

/// Status of a ride request
enum RideRequestStatus { pending, accepted, rejected, cancelled, expired }

/// Model representing a request to join a ride
/// No circular dependencies - uses IDs only
@freezed
abstract class RideRequestModel with _$RideRequestModel {
  const RideRequestModel._();

  const factory RideRequestModel({
    required String id,
    required String rideId,
    String? eventId,
    String? eventName,
    required String requesterId,
    required String driverId,
    required RideRequestStatus status,
    required LocationPoint pickupLocation,
    required LocationPoint dropoffLocation,
    required int requestedSeats,
    String? message,
    String? rejectionReason,
    @RequiredTimestampConverter() required DateTime createdAt,
    @TimestampConverter() DateTime? updatedAt,
    @TimestampConverter() DateTime? respondedAt,
    @TimestampConverter() DateTime? expiresAt,
    @Default({}) Map<String, dynamic> metadata,

    // Denormalized display fields (populated by service layer)
    String? passengerName,
    String? passengerPhotoUrl,
    @Default(0.0) double passengerRating,
    @Default(0.0) double pricePerSeat,
  }) = _RideRequestModel;

  factory RideRequestModel.fromJson(Map<String, dynamic> json) =>
      _$RideRequestModelFromJson(json);

  /// Create a new ride request
  factory RideRequestModel.create({
    required String id,
    required String rideId,
    String? eventId,
    String? eventName,
    required String requesterId,
    required String driverId,
    required LocationPoint pickupLocation,
    required LocationPoint dropoffLocation,
    required int requestedSeats,
    String? message,
    Duration expiresIn = const Duration(hours: 24),
  }) {
    final now = DateTime.now();
    return RideRequestModel(
      id: id,
      rideId: rideId,
      eventId: eventId,
      eventName: eventName,
      requesterId: requesterId,
      driverId: driverId,
      status: RideRequestStatus.pending,
      pickupLocation: pickupLocation,
      dropoffLocation: dropoffLocation,
      requestedSeats: requestedSeats,
      message: message,
      createdAt: now,
      expiresAt: now.add(expiresIn),
    );
  }

  /// Convenience getter: seats requested (alias)
  int get seatsRequested => requestedSeats;

  /// Convenience getter: from location address
  String get fromLocation => pickupLocation.address;

  /// Convenience getter: to location address
  String get toLocation => dropoffLocation.address;

  /// Convenience getter: requested date (uses createdAt as fallback)
  DateTime get requestedDate => createdAt;

  /// Convenience getter: requested time
  String get requestedTime => DateFormat('HH:mm').format(createdAt);

  /// Convenience getter: lightweight passenger proxy for view layer
  PassengerProxy get passenger => PassengerProxy(
    displayName: passengerName ?? 'Unknown',
    photoUrl: passengerPhotoUrl,
    ratingValue: passengerRating,
  );

  /// Check if request is pending
  bool get isPending => status == RideRequestStatus.pending;

  /// Check if request is accepted
  bool get isAccepted => status == RideRequestStatus.accepted;

  /// Check if request is rejected
  bool get isRejected => status == RideRequestStatus.rejected;

  /// Check if request is cancelled
  bool get isCancelled => status == RideRequestStatus.cancelled;

  /// Check if request is expired
  bool get isExpired {
    if (status == RideRequestStatus.expired) return true;
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Check if request is still active
  bool get isActive => isPending && !isExpired;

  /// Check if request needs action (pending and not expired)
  bool get needsAction => isPending && !isExpired;

  /// Get status display text
  String get statusText {
    switch (status) {
      case RideRequestStatus.pending:
        return isExpired ? 'Expired' : 'Pending';
      case RideRequestStatus.accepted:
        return 'Accepted';
      case RideRequestStatus.rejected:
        return 'Rejected';
      case RideRequestStatus.cancelled:
        return 'Cancelled';
      case RideRequestStatus.expired:
        return 'Expired';
    }
  }

  /// Get time remaining before expiration
  Duration? get timeRemaining {
    if (expiresAt == null) return null;
    final now = DateTime.now();
    if (now.isAfter(expiresAt!)) return Duration.zero;
    return expiresAt!.difference(now);
  }

  /// Get formatted time remaining
  String get timeRemainingText {
    final remaining = timeRemaining;
    if (remaining == null) return '';
    if (remaining.inHours > 0) {
      return '${remaining.inHours}h remaining';
    }
    if (remaining.inMinutes > 0) {
      return '${remaining.inMinutes}m remaining';
    }
    return 'Expires soon';
  }

  /// Get total price
  Money get totalPrice =>
      Money(amount: pricePerSeat * requestedSeats, currency: 'USD');

  /// Convenience getter for note (alias for message)
  String? get note => message;
}

/// Lightweight proxy mimicking UserModel interface for view backward compat
class PassengerProxy {
  final String displayName;
  final String? photoUrl;
  final RatingProxy rating;

  PassengerProxy({
    required this.displayName,
    this.photoUrl,
    required double ratingValue,
  }) : rating = RatingProxy(ratingValue);
}

class RatingProxy {
  final double average;
  const RatingProxy(this.average);
}
