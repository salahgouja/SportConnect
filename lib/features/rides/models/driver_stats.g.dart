// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DriverStats _$DriverStatsFromJson(Map json) => _DriverStats(
  driverId: json['driverId'] as String? ?? '',
  rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
  totalRides: (json['totalRides'] as num?)?.toInt() ?? 0,
  ridesToday: (json['ridesToday'] as num?)?.toInt() ?? 0,
  ridesThisWeek: (json['ridesThisWeek'] as num?)?.toInt() ?? 0,
  ridesThisMonth: (json['ridesThisMonth'] as num?)?.toInt() ?? 0,
  pendingRequests: (json['pendingRequests'] as num?)?.toInt() ?? 0,
  totalEarningsInCents: (json['totalEarningsInCents'] as num?)?.toInt() ?? 0,
  earningsTodayInCents: (json['earningsTodayInCents'] as num?)?.toInt() ?? 0,
  earningsThisWeekInCents:
      (json['earningsThisWeekInCents'] as num?)?.toInt() ?? 0,
  earningsThisMonthInCents:
      (json['earningsThisMonthInCents'] as num?)?.toInt() ?? 0,
  totalSpentInCents: (json['totalSpentInCents'] as num?)?.toInt() ?? 0,
  totalDistance: (json['totalDistance'] as num?)?.toDouble() ?? 0.0,
  lastRideAt: json['lastRideAt'] == null
      ? null
      : const TimestampConverter().fromJson(json['lastRideAt']),
);

Map<String, dynamic> _$DriverStatsToJson(_DriverStats instance) =>
    <String, dynamic>{
      'driverId': instance.driverId,
      'rating': instance.rating,
      'totalRides': instance.totalRides,
      'ridesToday': instance.ridesToday,
      'ridesThisWeek': instance.ridesThisWeek,
      'ridesThisMonth': instance.ridesThisMonth,
      'pendingRequests': instance.pendingRequests,
      'totalEarningsInCents': instance.totalEarningsInCents,
      'earningsTodayInCents': instance.earningsTodayInCents,
      'earningsThisWeekInCents': instance.earningsThisWeekInCents,
      'earningsThisMonthInCents': instance.earningsThisMonthInCents,
      'totalSpentInCents': instance.totalSpentInCents,
      'totalDistance': instance.totalDistance,
      'lastRideAt': const TimestampConverter().toJson(instance.lastRideAt),
    };

_EarningsTransaction _$EarningsTransactionFromJson(Map json) =>
    _EarningsTransaction(
      id: json['id'] as String,
      rideId: json['rideId'] as String,
      amountInCents: (json['amountInCents'] as num).toInt(),
      description: json['description'] as String,
      createdAt: const RequiredTimestampConverter().fromJson(json['createdAt']),
      type:
          $enumDecodeNullable(_$EarningsTransactionTypeEnumMap, json['type']) ??
          EarningsTransactionType.ride,
    );

Map<String, dynamic> _$EarningsTransactionToJson(
  _EarningsTransaction instance,
) => <String, dynamic>{
  'id': instance.id,
  'rideId': instance.rideId,
  'amountInCents': instance.amountInCents,
  'description': instance.description,
  'createdAt': const RequiredTimestampConverter().toJson(instance.createdAt),
  'type': _$EarningsTransactionTypeEnumMap[instance.type]!,
};

const _$EarningsTransactionTypeEnumMap = {
  EarningsTransactionType.ride: 'ride',
  EarningsTransactionType.bonus: 'bonus',
  EarningsTransactionType.refund: 'refund',
  EarningsTransactionType.payout: 'payout',
};
