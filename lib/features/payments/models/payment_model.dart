import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sport_connect/core/converters/timestamp_converter.dart';

part 'payment_model.freezed.dart';
part 'payment_model.g.dart';

/// Payment status enum
enum PaymentStatus {
  pending,
  processing,
  succeeded,
  failed,
  cancelled,
  refunded,
  partiallyRefunded,
}

/// Payment method type
enum PaymentMethodType { card, applePay, googlePay, link }

/// Payout status
enum PayoutStatus { pending, inTransit, paid, failed, cancelled }

/// Transaction type
enum TransactionType { payment, refund, payout, platformFee, stripeFee }

/// Payment Transaction Model
@freezed
abstract class PaymentTransaction with _$PaymentTransaction {
  const PaymentTransaction._();

  const factory PaymentTransaction({
    required String id,
    required String rideId,
    required String riderId,
    required String riderName,
    required String driverId,
    required String driverName,

    // Payment details
    required double amount, // Total amount in dollars
    required String currency,
    required PaymentStatus status,
    PaymentMethodType? paymentMethodType,
    String? paymentMethodLast4,

    // Stripe IDs
    String? stripePaymentIntentId,
    String? stripeCustomerId,
    String? stripeChargeId,

    // Fee breakdown
    required double platformFee,
    @Default(0) double stripeFee,
    required double driverEarnings,
    int? seatsBooked,

    // Timestamps
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
    @TimestampConverter() DateTime? completedAt,
    @TimestampConverter() DateTime? refundedAt,

    // Additional info
    String? failureReason,
    String? refundReason,
    @Default({}) Map<String, dynamic> metadata,
  }) = _PaymentTransaction;

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) =>
      _$PaymentTransactionFromJson(json);

  /// Get formatted amount
  String get formattedAmount =>
      '${amount.toStringAsFixed(2)} ${currency.toUpperCase()}';

  /// Get formatted platform fee
  String get formattedPlatformFee =>
      '${platformFee.toStringAsFixed(2)} ${currency.toUpperCase()}';

  /// Get formatted driver earnings
  String get formattedDriverEarnings =>
      '${driverEarnings.toStringAsFixed(2)} ${currency.toUpperCase()}';

  /// Check if payment is successful
  bool get isSuccessful => status == PaymentStatus.succeeded;

  /// Check if payment can be refunded
  bool get canBeRefunded =>
      status == PaymentStatus.succeeded &&
      refundedAt == null &&
      createdAt != null &&
      DateTime.now().difference(createdAt!).inDays <= 30;
}

/// Driver Payout Model
@freezed
abstract class DriverPayout with _$DriverPayout {
  const DriverPayout._();

  const factory DriverPayout({
    required String id,
    required String driverId,
    required String driverName,
    required String connectedAccountId,

    // Payout details
    required double amount, // Amount in dollars
    required String currency,
    required PayoutStatus status,

    // Stripe IDs
    String? stripePayoutId,
    String? stripeTransferId,

    // Related transactions
    @Default([]) List<String> transactionIds,

    // Bank details (last 4 digits)
    String? bankAccountLast4,
    String? bankName,

    // Timestamps
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? expectedArrivalDate,
    @TimestampConverter() DateTime? arrivedAt,

    // Additional info
    String? failureReason,
    bool? isInstantPayout,
    @Default({}) Map<String, dynamic> metadata,
  }) = _DriverPayout;

  factory DriverPayout.fromJson(Map<String, dynamic> json) =>
      _$DriverPayoutFromJson(json);

  /// Get formatted amount
  String get formattedAmount =>
      '${amount.toStringAsFixed(2)} ${currency.toUpperCase()}';

  /// Check if payout is completed
  bool get isCompleted => status == PayoutStatus.paid;

  /// Check if payout is pending
  bool get isPending => status == PayoutStatus.pending;
}

/// Driver Connected Account Model
@freezed
abstract class DriverConnectedAccount with _$DriverConnectedAccount {
  const DriverConnectedAccount._();

  const factory DriverConnectedAccount({
    required String id,
    required String driverId,
    required String stripeAccountId,

    // Account details
    required String email,
    required String country,
    required bool chargesEnabled,
    required bool payoutsEnabled,
    required bool detailsSubmitted,

    // Onboarding
    bool? onboardingCompleted,
    @TimestampConverter() DateTime? onboardingCompletedAt,
    String? onboardingUrl,

    // Bank account info (masked)
    String? bankAccountLast4,
    String? bankName,
    String? accountHolderName,

    // Earnings summary
    @Default(0.0) double totalEarnings,
    @Default(0.0) double availableBalance,
    @Default(0.0) double pendingBalance,

    // Timestamps
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
    @TimestampConverter() DateTime? lastPayoutAt,

    // Additional info
    @Default({}) Map<String, dynamic> requirements,
    @Default({}) Map<String, dynamic> metadata,
  }) = _DriverConnectedAccount;

  factory DriverConnectedAccount.fromJson(Map<String, dynamic> json) =>
      _$DriverConnectedAccountFromJson(json);

  /// Check if account is fully setup
  bool get isFullySetup => chargesEnabled && payoutsEnabled && detailsSubmitted;

  /// Check if onboarding is needed
  bool get needsOnboarding =>
      !chargesEnabled || !payoutsEnabled || !detailsSubmitted;

  /// Default currency based on country
  String get defaultCurrency {
    const countryToCurrency = {
      'FR': 'EUR',
      'DE': 'EUR',
      'ES': 'EUR',
      'IT': 'EUR',
      'NL': 'EUR',
      'BE': 'EUR',
      'AT': 'EUR',
      'PT': 'EUR',
      'US': 'USD',
      'GB': 'GBP',
      'CA': 'CAD',
      'AU': 'AUD',
    };
    return countryToCurrency[country.toUpperCase()] ?? 'EUR';
  }

  /// Get formatted total earnings
  String get formattedTotalEarnings =>
      '${totalEarnings.toStringAsFixed(2)} $defaultCurrency';

  /// Get formatted available balance
  String get formattedAvailableBalance =>
      '${availableBalance.toStringAsFixed(2)} $defaultCurrency';
}

/// Rider Payment Method Model
@freezed
abstract class RiderPaymentMethod with _$RiderPaymentMethod {
  const RiderPaymentMethod._();

  const factory RiderPaymentMethod({
    required String id,
    required String riderId,
    required String stripeCustomerId,
    required String stripePaymentMethodId,

    // Card details
    required String brand, // visa, mastercard, amex, etc.
    required String last4,
    required int exMonth,
    required int exYear,

    // Flags
    @Default(false) bool isDefault,

    // Timestamps
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
  }) = _RiderPaymentMethod;

  factory RiderPaymentMethod.fromJson(Map<String, dynamic> json) =>
      _$RiderPaymentMethodFromJson(json);

  /// Get formatted card info
  String get cardDisplay => '$brand •••• $last4';

  /// Check if card is expired
  bool get isExpired {
    final now = DateTime.now();
    final expDate = DateTime(exYear, exMonth + 1, 0);
    return now.isAfter(expDate);
  }

  /// Get expiration display
  String get expirationDisplay =>
      '${exMonth.toString().padLeft(2, '0')}/$exYear';
}

/// Earnings Summary Model for drivers
@freezed
abstract class EarningsSummary with _$EarningsSummary {
  const EarningsSummary._();

  const factory EarningsSummary({
    required String driverId,

    // Total earnings
    @Default(0.0) double totalEarnings,
    @Default(0.0) double totalPlatformFees,
    @Default(0.0) double totalStripeFees,

    // Period earnings
    @Default(0.0) double earningsToday,
    @Default(0.0) double earningsThisWeek,
    @Default(0.0) double earningsThisMonth,
    @Default(0.0) double earningsThisYear,

    // Ride stats
    @Default(0) int totalRidesCompleted,
    @Default(0) int ridesCompletedToday,
    @Default(0) int ridesCompletedThisWeek,
    @Default(0) int ridesCompletedThisMonth,

    // Balance
    @Default(0.0) double availableBalance,
    @Default(0.0) double pendingBalance,

    // Timestamps
    @TimestampConverter() DateTime? lastUpdated,
    @TimestampConverter() DateTime? lastPayoutDate,
  }) = _EarningsSummary;

  factory EarningsSummary.fromJson(Map<String, dynamic> json) =>
      _$EarningsSummaryFromJson(json);

  /// Get average earnings per ride
  double get averagePerRide =>
      totalRidesCompleted > 0 ? totalEarnings / totalRidesCompleted : 0.0;
}
