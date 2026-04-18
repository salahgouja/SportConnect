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
  totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
  earningsToday: (json['earningsToday'] as num?)?.toDouble() ?? 0.0,
  earningsThisWeek: (json['earningsThisWeek'] as num?)?.toDouble() ?? 0.0,
  earningsThisMonth: (json['earningsThisMonth'] as num?)?.toDouble() ?? 0.0,
  totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
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
      'totalEarnings': instance.totalEarnings,
      'earningsToday': instance.earningsToday,
      'earningsThisWeek': instance.earningsThisWeek,
      'earningsThisMonth': instance.earningsThisMonth,
      'totalSpent': instance.totalSpent,
      'totalDistance': instance.totalDistance,
      'lastRideAt': const TimestampConverter().toJson(instance.lastRideAt),
    };

_EarningsTransaction _$EarningsTransactionFromJson(Map json) =>
    _EarningsTransaction(
      id: json['id'] as String,
      rideId: json['rideId'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      createdAt: const RequiredTimestampConverter().fromJson(json['createdAt']),
      type:
          $enumDecodeNullable(_$TransactionTypeEnumMap, json['type']) ??
          TransactionType.ride,
    );

Map<String, dynamic> _$EarningsTransactionToJson(
  _EarningsTransaction instance,
) => <String, dynamic>{
  'id': instance.id,
  'rideId': instance.rideId,
  'amount': instance.amount,
  'description': instance.description,
  'createdAt': const RequiredTimestampConverter().toJson(instance.createdAt),
  'type': _$TransactionTypeEnumMap[instance.type]!,
};

const _$TransactionTypeEnumMap = {
  TransactionType.ride: 'ride',
  TransactionType.bonus: 'bonus',
  TransactionType.refund: 'refund',
  TransactionType.payout: 'payout',
};
