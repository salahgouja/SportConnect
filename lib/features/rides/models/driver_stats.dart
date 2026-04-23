import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sport_connect/core/converters/timestamp_converter.dart';
part 'driver_stats.freezed.dart';
part 'driver_stats.g.dart';

/// Transaction types exposed by the driver earnings feed.
///
/// Keep this narrower than payment/payout enums so earnings UI only models the
/// categories it actually renders from the `transactions` collection.
enum EarningsTransactionType { ride, bonus, refund, payout }

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
    @Default(0) int totalEarningsInCents,
    @Default(0) int earningsTodayInCents,
    @Default(0) int earningsThisWeekInCents,
    @Default(0) int earningsThisMonthInCents,
    @Default(0) int totalSpentInCents,

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
    required int amountInCents,
    required String description,
    @RequiredTimestampConverter() required DateTime createdAt,
    @Default(EarningsTransactionType.ride)
    EarningsTransactionType type, // ride, bonus, refund, payout
  }) = _EarningsTransaction;

  factory EarningsTransaction.fromJson(Map<String, dynamic> json) =>
      _$EarningsTransactionFromJson(json);
}
