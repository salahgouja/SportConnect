import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sport_connect/core/converters/timestamp_converter.dart';

part 'driver_stats.freezed.dart';
part 'driver_stats.g.dart';

enum TransactionType { ride, bonus, refund, payout }

/// Driver statistics - converted to Freezed for consistency
@freezed
abstract class DriverStats with _$DriverStats {
  const factory DriverStats({
    @Default('') String driverId,
    @Default(0.0) double rating,

    // Rides
    @Default(0) int totalRides,
    @Default(0) int ridesToday,
    @Default(0) int ridesThisWeek,
    @Default(0) int ridesThisMonth,
    @Default(0) int pendingRequests,

    // Earnings
    @Default(0.0) double totalEarnings,
    @Default(0.0) double earningsToday,
    @Default(0.0) double earningsThisWeek,
    @Default(0.0) double earningsThisMonth,
    @Default(0.0) double totalSpent,

    // Distance & status
    @Default(0.0) double totalDistance,
    @Default(null) @TimestampConverter() DateTime? lastRideAt,
  }) = _DriverStats;

  factory DriverStats.fromJson(Map<String, dynamic> json) =>
      _$DriverStatsFromJson(json);
}

/// Earnings Transaction - converted to Freezed
@freezed
abstract class EarningsTransaction with _$EarningsTransaction {
  const factory EarningsTransaction({
    required String id,
    required String rideId,
    required double amount,
    required String description,
    @RequiredTimestampConverter() required DateTime createdAt,
    @Default(TransactionType.ride)
    TransactionType type, // ride, bonus, refund, payout
  }) = _EarningsTransaction;

  factory EarningsTransaction.fromJson(Map<String, dynamic> json) =>
      _$EarningsTransactionFromJson(json);
}
