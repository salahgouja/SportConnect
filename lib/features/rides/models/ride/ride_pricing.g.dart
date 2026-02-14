// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_pricing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RidePricing _$RidePricingFromJson(Map json) => _RidePricing(
  pricePerSeat: Money.fromJson(
    Map<String, dynamic>.from(json['pricePerSeat'] as Map),
  ),
  isNegotiable: json['isNegotiable'] as bool? ?? false,
  acceptsOnlinePayment: json['acceptsOnlinePayment'] as bool? ?? false,
);

Map<String, dynamic> _$RidePricingToJson(_RidePricing instance) =>
    <String, dynamic>{
      'pricePerSeat': instance.pricePerSeat.toJson(),
      'isNegotiable': instance.isNegotiable,
      'acceptsOnlinePayment': instance.acceptsOnlinePayment,
    };
