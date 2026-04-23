// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'money.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Money _$MoneyFromJson(Map json) => _Money(
  amountInCents: (json['amountInCents'] as num).toInt(),
  currency: json['currency'] as String? ?? 'EUR',
);

Map<String, dynamic> _$MoneyToJson(_Money instance) => <String, dynamic>{
  'amountInCents': instance.amountInCents,
  'currency': instance.currency,
};
