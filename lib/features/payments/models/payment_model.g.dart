// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaymentTransaction _$PaymentTransactionFromJson(Map json) =>
    _PaymentTransaction(
      id: json['id'] as String,
      rideId: json['rideId'] as String,
      riderId: json['riderId'] as String,
      riderName: json['riderName'] as String,
      driverId: json['driverId'] as String,
      driverName: json['driverName'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      status: $enumDecode(_$PaymentStatusEnumMap, json['status']),
      platformFee: (json['platformFee'] as num).toDouble(),
      driverEarnings: (json['driverEarnings'] as num).toDouble(),
      paymentMethodType: $enumDecodeNullable(
        _$PaymentMethodTypeEnumMap,
        json['paymentMethodType'],
      ),
      paymentMethodLast4: json['paymentMethodLast4'] as String?,
      stripePaymentIntentId: json['stripePaymentIntentId'] as String?,
      stripeCustomerId: json['stripeCustomerId'] as String?,
      stripeChargeId: json['stripeChargeId'] as String?,
      stripeFee: (json['stripeFee'] as num?)?.toDouble() ?? 0,
      seatsBooked: (json['seatsBooked'] as num?)?.toInt(),
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
      completedAt: const TimestampConverter().fromJson(json['completedAt']),
      refundedAt: const TimestampConverter().fromJson(json['refundedAt']),
      failureReason: json['failureReason'] as String?,
      refundReason: json['refundReason'] as String?,
      metadata:
          (json['metadata'] as Map?)?.map((k, e) => MapEntry(k as String, e)) ??
          const {},
    );

Map<String, dynamic> _$PaymentTransactionToJson(
  _PaymentTransaction instance,
) => <String, dynamic>{
  'id': instance.id,
  'rideId': instance.rideId,
  'riderId': instance.riderId,
  'riderName': instance.riderName,
  'driverId': instance.driverId,
  'driverName': instance.driverName,
  'amount': instance.amount,
  'currency': instance.currency,
  'status': _$PaymentStatusEnumMap[instance.status]!,
  'platformFee': instance.platformFee,
  'driverEarnings': instance.driverEarnings,
  'paymentMethodType': _$PaymentMethodTypeEnumMap[instance.paymentMethodType],
  'paymentMethodLast4': instance.paymentMethodLast4,
  'stripePaymentIntentId': instance.stripePaymentIntentId,
  'stripeCustomerId': instance.stripeCustomerId,
  'stripeChargeId': instance.stripeChargeId,
  'stripeFee': instance.stripeFee,
  'seatsBooked': instance.seatsBooked,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
  'completedAt': const TimestampConverter().toJson(instance.completedAt),
  'refundedAt': const TimestampConverter().toJson(instance.refundedAt),
  'failureReason': instance.failureReason,
  'refundReason': instance.refundReason,
  'metadata': instance.metadata,
};

const _$PaymentStatusEnumMap = {
  PaymentStatus.pending: 'pending',
  PaymentStatus.processing: 'processing',
  PaymentStatus.succeeded: 'succeeded',
  PaymentStatus.failed: 'failed',
  PaymentStatus.cancelled: 'cancelled',
  PaymentStatus.refunded: 'refunded',
  PaymentStatus.partiallyRefunded: 'partiallyRefunded',
};

const _$PaymentMethodTypeEnumMap = {
  PaymentMethodType.card: 'card',
  PaymentMethodType.applePay: 'applePay',
  PaymentMethodType.googlePay: 'googlePay',
  PaymentMethodType.link: 'link',
};

_DriverPayout _$DriverPayoutFromJson(Map json) => _DriverPayout(
  id: json['id'] as String,
  driverId: json['driverId'] as String,
  driverName: json['driverName'] as String,
  connectedAccountId: json['connectedAccountId'] as String,
  amount: (json['amount'] as num).toDouble(),
  currency: json['currency'] as String,
  status: $enumDecode(_$PayoutStatusEnumMap, json['status']),
  stripePayoutId: json['stripePayoutId'] as String?,
  stripeTransferId: json['stripeTransferId'] as String?,
  transactionIds:
      (json['transactionIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  expectedArrivalDate: const TimestampConverter().fromJson(
    json['expectedArrivalDate'],
  ),
  arrivedAt: const TimestampConverter().fromJson(json['arrivedAt']),
  failureReason: json['failureReason'] as String?,
  isInstantPayout: json['isInstantPayout'] as bool?,
  metadata:
      (json['metadata'] as Map?)?.map((k, e) => MapEntry(k as String, e)) ??
      const {},
);

Map<String, dynamic> _$DriverPayoutToJson(_DriverPayout instance) =>
    <String, dynamic>{
      'id': instance.id,
      'driverId': instance.driverId,
      'driverName': instance.driverName,
      'connectedAccountId': instance.connectedAccountId,
      'amount': instance.amount,
      'currency': instance.currency,
      'status': _$PayoutStatusEnumMap[instance.status]!,
      'stripePayoutId': instance.stripePayoutId,
      'stripeTransferId': instance.stripeTransferId,
      'transactionIds': instance.transactionIds,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'expectedArrivalDate': const TimestampConverter().toJson(
        instance.expectedArrivalDate,
      ),
      'arrivedAt': const TimestampConverter().toJson(instance.arrivedAt),
      'failureReason': instance.failureReason,
      'isInstantPayout': instance.isInstantPayout,
      'metadata': instance.metadata,
    };

const _$PayoutStatusEnumMap = {
  PayoutStatus.pending: 'pending',
  PayoutStatus.inTransit: 'inTransit',
  PayoutStatus.paid: 'paid',
  PayoutStatus.failed: 'failed',
  PayoutStatus.cancelled: 'cancelled',
};

_DriverConnectedAccount _$DriverConnectedAccountFromJson(Map json) =>
    _DriverConnectedAccount(
      id: json['id'] as String,
      driverId: json['driverId'] as String,
      stripeAccountId: json['stripeAccountId'] as String,
      email: json['email'] as String,
      country: json['country'] as String,
      chargesEnabled: json['chargesEnabled'] as bool,
      payoutsEnabled: json['payoutsEnabled'] as bool,
      detailsSubmitted: json['detailsSubmitted'] as bool,
      onboardingCompleted: json['onboardingCompleted'] as bool?,
      onboardingCompletedAt: const TimestampConverter().fromJson(
        json['onboardingCompletedAt'],
      ),
      onboardingUrl: json['onboardingUrl'] as String?,
      accountHolderName: json['accountHolderName'] as String?,
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      availableBalance: (json['availableBalance'] as num?)?.toDouble() ?? 0.0,
      pendingBalance: (json['pendingBalance'] as num?)?.toDouble() ?? 0.0,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
      lastPayoutAt: const TimestampConverter().fromJson(json['lastPayoutAt']),
      requirements:
          (json['requirements'] as Map?)?.map(
            (k, e) => MapEntry(k as String, e),
          ) ??
          const {},
      metadata:
          (json['metadata'] as Map?)?.map((k, e) => MapEntry(k as String, e)) ??
          const {},
    );

Map<String, dynamic> _$DriverConnectedAccountToJson(
  _DriverConnectedAccount instance,
) => <String, dynamic>{
  'id': instance.id,
  'driverId': instance.driverId,
  'stripeAccountId': instance.stripeAccountId,
  'email': instance.email,
  'country': instance.country,
  'chargesEnabled': instance.chargesEnabled,
  'payoutsEnabled': instance.payoutsEnabled,
  'detailsSubmitted': instance.detailsSubmitted,
  'onboardingCompleted': instance.onboardingCompleted,
  'onboardingCompletedAt': const TimestampConverter().toJson(
    instance.onboardingCompletedAt,
  ),
  'onboardingUrl': instance.onboardingUrl,
  'accountHolderName': instance.accountHolderName,
  'totalEarnings': instance.totalEarnings,
  'availableBalance': instance.availableBalance,
  'pendingBalance': instance.pendingBalance,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
  'lastPayoutAt': const TimestampConverter().toJson(instance.lastPayoutAt),
  'requirements': instance.requirements,
  'metadata': instance.metadata,
};

_RiderPaymentMethod _$RiderPaymentMethodFromJson(Map json) =>
    _RiderPaymentMethod(
      id: json['id'] as String,
      riderId: json['riderId'] as String,
      stripeCustomerId: json['stripeCustomerId'] as String,
      stripePaymentMethodId: json['stripePaymentMethodId'] as String,
      brand: json['brand'] as String,
      last4: json['last4'] as String,
      exMonth: (json['exMonth'] as num).toInt(),
      exYear: (json['exYear'] as num).toInt(),
      isDefault: json['isDefault'] as bool? ?? false,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$RiderPaymentMethodToJson(_RiderPaymentMethod instance) =>
    <String, dynamic>{
      'id': instance.id,
      'riderId': instance.riderId,
      'stripeCustomerId': instance.stripeCustomerId,
      'stripePaymentMethodId': instance.stripePaymentMethodId,
      'brand': instance.brand,
      'last4': instance.last4,
      'exMonth': instance.exMonth,
      'exYear': instance.exYear,
      'isDefault': instance.isDefault,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };

_EarningsSummary _$EarningsSummaryFromJson(Map json) => _EarningsSummary(
  driverId: json['driverId'] as String,
  totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
  totalPlatformFees: (json['totalPlatformFees'] as num?)?.toDouble() ?? 0.0,
  totalStripeFees: (json['totalStripeFees'] as num?)?.toDouble() ?? 0.0,
  earningsToday: (json['earningsToday'] as num?)?.toDouble() ?? 0.0,
  earningsThisWeek: (json['earningsThisWeek'] as num?)?.toDouble() ?? 0.0,
  earningsThisMonth: (json['earningsThisMonth'] as num?)?.toDouble() ?? 0.0,
  earningsThisYear: (json['earningsThisYear'] as num?)?.toDouble() ?? 0.0,
  totalRidesCompleted: (json['totalRidesCompleted'] as num?)?.toInt() ?? 0,
  ridesCompletedToday: (json['ridesCompletedToday'] as num?)?.toInt() ?? 0,
  ridesCompletedThisWeek:
      (json['ridesCompletedThisWeek'] as num?)?.toInt() ?? 0,
  ridesCompletedThisMonth:
      (json['ridesCompletedThisMonth'] as num?)?.toInt() ?? 0,
  availableBalance: (json['availableBalance'] as num?)?.toDouble() ?? 0.0,
  pendingBalance: (json['pendingBalance'] as num?)?.toDouble() ?? 0.0,
  lastUpdated: const TimestampConverter().fromJson(json['lastUpdated']),
  lastPayoutDate: const TimestampConverter().fromJson(json['lastPayoutDate']),
);

Map<String, dynamic> _$EarningsSummaryToJson(
  _EarningsSummary instance,
) => <String, dynamic>{
  'driverId': instance.driverId,
  'totalEarnings': instance.totalEarnings,
  'totalPlatformFees': instance.totalPlatformFees,
  'totalStripeFees': instance.totalStripeFees,
  'earningsToday': instance.earningsToday,
  'earningsThisWeek': instance.earningsThisWeek,
  'earningsThisMonth': instance.earningsThisMonth,
  'earningsThisYear': instance.earningsThisYear,
  'totalRidesCompleted': instance.totalRidesCompleted,
  'ridesCompletedToday': instance.ridesCompletedToday,
  'ridesCompletedThisWeek': instance.ridesCompletedThisWeek,
  'ridesCompletedThisMonth': instance.ridesCompletedThisMonth,
  'availableBalance': instance.availableBalance,
  'pendingBalance': instance.pendingBalance,
  'lastUpdated': const TimestampConverter().toJson(instance.lastUpdated),
  'lastPayoutDate': const TimestampConverter().toJson(instance.lastPayoutDate),
};
