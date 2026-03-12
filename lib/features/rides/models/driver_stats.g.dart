// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DriverStats _$DriverStatsFromJson(Map json) => _DriverStats(
  driverId: json['driverId'] as String? ?? '',
  rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
  totalRides: (json['totalRides'] as num?)?.toInt() ?? 0,
  ridesThisWeek: (json['ridesThisWeek'] as num?)?.toInt() ?? 0,
  ridesThisMonth: (json['ridesThisMonth'] as num?)?.toInt() ?? 0,
  ridesCompleted: (json['ridesCompleted'] as num?)?.toInt() ?? 0,
  pendingRequests: (json['pendingRequests'] as num?)?.toInt() ?? 0,
  totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
  earningsThisWeek: (json['earningsThisWeek'] as num?)?.toDouble() ?? 0.0,
  earningsThisMonth: (json['earningsThisMonth'] as num?)?.toDouble() ?? 0.0,
  earningsToday: (json['earningsToday'] as num?)?.toDouble() ?? 0.0,
  totalDistance: (json['totalDistance'] as num?)?.toDouble() ?? 0.0,
  hoursOnline: (json['hoursOnline'] as num?)?.toDouble() ?? 0.0,
  hoursOnlineThisWeek: (json['hoursOnlineThisWeek'] as num?)?.toDouble() ?? 0.0,
  isOnline: json['isOnline'] as bool? ?? false,
  lastRideAt: const TimestampConverter().fromJson(json['lastRideAt']),
);

Map<String, dynamic> _$DriverStatsToJson(_DriverStats instance) =>
    <String, dynamic>{
      'driverId': instance.driverId,
      'rating': instance.rating,
      'totalRides': instance.totalRides,
      'ridesThisWeek': instance.ridesThisWeek,
      'ridesThisMonth': instance.ridesThisMonth,
      'ridesCompleted': instance.ridesCompleted,
      'pendingRequests': instance.pendingRequests,
      'totalEarnings': instance.totalEarnings,
      'earningsThisWeek': instance.earningsThisWeek,
      'earningsThisMonth': instance.earningsThisMonth,
      'earningsToday': instance.earningsToday,
      'totalDistance': instance.totalDistance,
      'hoursOnline': instance.hoursOnline,
      'hoursOnlineThisWeek': instance.hoursOnlineThisWeek,
      'isOnline': instance.isOnline,
      'lastRideAt': const TimestampConverter().toJson(instance.lastRideAt),
    };

_EarningsTransaction _$EarningsTransactionFromJson(Map json) =>
    _EarningsTransaction(
      id: json['id'] as String,
      rideId: json['rideId'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      type: json['type'] as String? ?? 'ride',
      createdAt: const RequiredTimestampConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$EarningsTransactionToJson(
  _EarningsTransaction instance,
) => <String, dynamic>{
  'id': instance.id,
  'rideId': instance.rideId,
  'amount': instance.amount,
  'description': instance.description,
  'type': instance.type,
  'createdAt': const RequiredTimestampConverter().toJson(instance.createdAt),
};
