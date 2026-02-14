import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sport_connect/core/models/value_objects/money.dart';

part 'ride_pricing.freezed.dart';
part 'ride_pricing.g.dart';

/// Ride pricing information
@freezed
abstract class RidePricing with _$RidePricing {
  const RidePricing._();

  const factory RidePricing({
    required Money pricePerSeat,
    @Default(false) bool isNegotiable,
    @Default(false) bool acceptsOnlinePayment,
  }) = _RidePricing;

  factory RidePricing.fromJson(Map<String, dynamic> json) =>
      _$RidePricingFromJson(json);

  /// Get formatted price
  String get formattedPrice => pricePerSeat.formatted;

  /// Calculate total price for seats
  Money totalForSeats(int seats) => pricePerSeat * seats;

  /// Check if free ride
  bool get isFree => pricePerSeat.isZero;
}
