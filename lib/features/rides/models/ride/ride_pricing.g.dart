// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_pricing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RidePricing _$RidePricingFromJson(Map json) => _RidePricing(
  pricePerSeatInCents: Money.fromJson(
    Map<String, dynamic>.from(json['pricePerSeatInCents'] as Map),
  ),
);

Map<String, dynamic> _$RidePricingToJson(_RidePricing instance) =>
    <String, dynamic>{
      'pricePerSeatInCents': instance.pricePerSeatInCents.toJson(),
    };
