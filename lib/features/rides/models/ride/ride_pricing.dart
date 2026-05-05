import 'package:freezed_annotation/freezed_annotation.dart';

part 'ride_pricing.freezed.dart';
part 'ride_pricing.g.dart';

/// Ride pricing information
@freezed
abstract class RidePricing with _$RidePricing {
  const factory RidePricing({
    required int pricePerSeatInCents,
  }) = _RidePricing;
  const RidePricing._();

  factory RidePricing.fromJson(Map<String, dynamic> json) =>
      _$RidePricingFromJson(json);

  /// Get formatted price
  String get formattedPrice =>
      '€${(pricePerSeatInCents / 100).toStringAsFixed(2)}';

  /// Calculate total price for seats
  int totalForSeats(int seats) => pricePerSeatInCents * seats;
}
