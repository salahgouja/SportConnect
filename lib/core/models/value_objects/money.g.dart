// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'money.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Money _$MoneyFromJson(Map json) => _Money(
  amount: (json['amount'] as num).toDouble(),
  currency: json['currency'] as String? ?? 'USD',
);

Map<String, dynamic> _$MoneyToJson(_Money instance) => <String, dynamic>{
  'amount': instance.amount,
  'currency': instance.currency,
};
