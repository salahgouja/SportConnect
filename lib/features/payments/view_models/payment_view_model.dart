import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/services/stripe_service.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/features/payments/models/payment_model.dart';
import 'package:sport_connect/features/payments/repositories/payment_repository.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';

part 'payment_view_model.freezed.dart';
part 'payment_view_model.g.dart';

/// Payment Processing View Model
@riverpod
class PaymentViewModel extends _$PaymentViewModel {
  @override
  FutureOr<void> build() {}

  /// Process booking payment for rider
  /// Uses Firebase Cloud Functions for secure payment processing
  Future<PaymentTransaction> processBookingPayment({
    required RideModel ride,
    required String riderId,
    required String riderName,
    required int seatsBooked,
    required String customerId,
  }) async {
    state = const AsyncValue.loading();

    try {
      final stripeService = ref.read(stripeServiceProvider);
      final paymentRepo = ref.read(paymentRepositoryProvider);

      // Calculate total amount
      final totalAmount = ride.pricing.pricePerSeat.amount * seatsBooked;
      final currency = ride.pricing.pricePerSeat.currency;

      // Create Stripe Payment Intent via Firebase Cloud Function
      // This automatically handles:
      // - Payment creation
      // - Destination charges (driver transfer)
      // - Fee calculation
      // - Firestore record creation
      final paymentIntentData = await stripeService.createPaymentIntent(
        rideId: ride.id,
        riderId: riderId,
        riderName: riderName,
        driverId: ride.driverId,
        driverName: '', // Resolved at view layer
        amount: totalAmount, // Main currency unit — server converts to cents
        currency: currency,
        customerId: customerId,
        description:
            '${ride.route.origin.address} → ${ride.route.destination.address}',
      );

      // Process payment with Payment Sheet
      final success = await stripeService.processPaymentWithSheet(
        paymentIntentClientSecret: paymentIntentData['clientSecret'],
        customerId: customerId,
      );

      if (success) {
        // Payment succeeded - get the updated payment record from Firestore
        // (Firebase webhook will update it automatically)
        final payment = await paymentRepo.getPaymentById(
          paymentIntentData['paymentIntentId'],
        );

        // Check if provider is still mounted after async operation
        if (!ref.mounted) return payment!;

        state = const AsyncValue.data(null);
        return payment!;
      } else {
        throw Exception('Payment cancelled by user');
      }
    } catch (e, stack) {
      TalkerService.error('Error processing payment: $e');

      // Check if provider is still mounted before setting error state
      if (ref.mounted) {
        state = AsyncValue.error(e, stack);
      }
      rethrow;
    }
  }

  /// Get or create Stripe customer for rider
  Future<String> getOrCreateCustomer({
    required String userId,
    required String email,
    String? name,
    String? phone,
    String? existingCustomerId,
  }) async {
    try {
      final stripeService = ref.read(stripeServiceProvider);
      final result = await stripeService.getOrCreateCustomer(
        userId: userId,
        email: email,
        name: name,
        phone: phone,
        existingCustomerId: existingCustomerId,
      );
      return result['customerId'] as String;
    } catch (e) {
      TalkerService.error('Error getting/creating customer: $e');
      rethrow;
    }
  }

  /// Refund payment
  Future<void> refundBookingPayment({
    required String paymentId,
    double? amount,
    String? reason,
  }) async {
    state = const AsyncValue.loading();

    try {
      final paymentRepo = ref.read(paymentRepositoryProvider);
      await paymentRepo.processRefund(
        paymentId: paymentId,
        amount: amount,
        reason: reason,
      );

      // Check if provider is still mounted after async operation
      if (!ref.mounted) return;

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      TalkerService.error('Error processing refund: $e');

      // Check if provider is still mounted before setting error state
      if (ref.mounted) {
        state = AsyncValue.error(e, stack);
      }
      rethrow;
    }
  }

  /// Create connected account for driver
  ///
  /// Prefills individual info to reduce onboarding friction.
  Future<Map<String, dynamic>?> createConnectedAccount({
    required String userId,
    required String email,
    required String country,
    String? firstName,
    String? lastName,
    String? phone,
    DateTime? dateOfBirth,
    String? addressLine1,
    String? city,
  }) async {
    state = const AsyncValue.loading();

    try {
      final stripeService = ref.read(stripeServiceProvider);
      final paymentRepo = ref.read(paymentRepositoryProvider);

      final result = await stripeService.createDriverConnectedAccount(
        userId: userId,
        email: email,
        country: country,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        dateOfBirth: dateOfBirth,
        addressLine1: addressLine1,
        city: city,
      );

      // Save connected account to repository
      if (result['accountId'] != null) {
        final connectedAccount = DriverConnectedAccount(
          id: result['accountId'],
          driverId: userId,
          stripeAccountId: result['accountId'],
          email: email,
          country: country,
          chargesEnabled: false,
          payoutsEnabled: false,
          detailsSubmitted: false,
          onboardingCompleted: false,
          onboardingUrl: result['onboardingUrl'],
        );
        await paymentRepo.saveConnectedAccount(connectedAccount);
      }

      // Check if provider is still mounted after async operation
      if (!ref.mounted) return result;

      state = const AsyncValue.data(null);
      return result;
    } catch (e, stack) {
      TalkerService.error('Error creating connected account: $e');

      // Check if provider is still mounted before setting error state
      if (!ref.mounted) return null;

      state = AsyncValue.error(e, stack);
      return null;
    }
  }

  /// Request instant payout for driver
  /// [stripeAccountId] - Driver's Stripe Connect account ID from Firestore
  Future<bool> requestInstantPayout({
    required String userId,
    required String stripeAccountId,
    required double amount,
    required String currency,
    bool isFullySetup = true,
  }) async {
    state = const AsyncValue.loading();

    try {
      final stripeService = ref.read(stripeServiceProvider);

      await stripeService.createInstantPayout(
        stripeAccountId: stripeAccountId,
        amount: amount, // Main currency unit — server converts to cents
        currency: currency,
      );

      // Check if provider is still mounted after async operation
      if (!ref.mounted) return true;

      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      TalkerService.error('Error requesting payout: $e');

      // Check if provider is still mounted before setting error state
      if (ref.mounted) {
        state = AsyncValue.error(e, stack);
      }
      return false;
    }
  }

  /// Get connected account status for a driver
  Future<Map<String, dynamic>> getConnectedAccountStatus(String userId) async {
    try {
      final repo = ref.read(paymentRepositoryProvider);
      final account = await repo.getConnectedAccount(userId);

      if (account == null) {
        return {'isConnected': false, 'requiresMoreInfo': false};
      }

      return {
        'isConnected': account.onboardingCompleted,
        'requiresMoreInfo': !account.detailsSubmitted,
        'chargesEnabled': account.chargesEnabled,
        'payoutsEnabled': account.payoutsEnabled,
        'accountId': account.stripeAccountId,
      };
    } catch (e) {
      TalkerService.error('Error getting connected account status: $e');
      return {'isConnected': false, 'requiresMoreInfo': false};
    }
  }
}

/// Rider Payment History Provider
@riverpod
Future<List<PaymentTransaction>> riderPaymentHistory(
  Ref ref,
  String riderId,
) async {
  final paymentRepo = ref.read(paymentRepositoryProvider);
  return paymentRepo.getRiderPaymentHistory(riderId: riderId);
}

/// Rider Payment History Stream Provider
@riverpod
Stream<List<PaymentTransaction>> riderPaymentHistoryStream(
  Ref ref,
  String riderId,
) {
  final paymentRepo = ref.read(paymentRepositoryProvider);
  return paymentRepo.streamRiderPaymentHistory(riderId: riderId);
}

/// Driver Connected Account View Model
@riverpod
class DriverConnectedAccountViewModel
    extends _$DriverConnectedAccountViewModel {
  @override
  Future<DriverConnectedAccount?> build(String driverId) async {
    final paymentRepo = ref.read(paymentRepositoryProvider);
    return paymentRepo.getConnectedAccount(driverId);
  }

  /// Refresh connected account status
  /// Status is automatically updated via webhooks
  /// This method just refreshes the local state from Firestore
  Future<void> refreshAccountStatus() async {
    try {
      // Refresh from Firestore (webhooks keep it updated)
      ref.invalidateSelf();
    } catch (e) {
      TalkerService.error('Error refreshing account status: $e');
      rethrow;
    }
  }
}

/// Driver Earnings Summary Provider
@riverpod
Future<EarningsSummary> driverEarningsSummary(Ref ref, String driverId) async {
  final paymentRepo = ref.read(paymentRepositoryProvider);
  return paymentRepo.calculateEarningsSummary(driverId);
}

/// Driver Earnings Transactions Provider
@riverpod
Future<List<PaymentTransaction>> driverEarningsTransactions(
  Ref ref,
  String driverId, {
  DateTime? startDate,
  DateTime? endDate,
}) async {
  final paymentRepo = ref.read(paymentRepositoryProvider);
  return paymentRepo.getDriverEarnings(
    driverId: driverId,
    startDate: startDate,
    endDate: endDate,
  );
}

/// Driver Payouts Provider
@riverpod
Future<List<DriverPayout>> driverPayouts(Ref ref, String driverId) async {
  final paymentRepo = ref.read(paymentRepositoryProvider);
  return paymentRepo.getDriverPayouts(driverId: driverId);
}

/// Single Payout Detail Provider
@riverpod
Future<DriverPayout?> payoutDetail(Ref ref, String payoutId) async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection('payouts')
        .doc(payoutId)
        .get();
    if (doc.exists) {
      return DriverPayout.fromJson({...doc.data()!, 'id': doc.id});
    }
  } catch (e) {
    TalkerService.error('Error fetching payout detail: $e');
  }
  return null;
}

/// Driver Payout View Model
@riverpod
class DriverPayoutViewModel extends _$DriverPayoutViewModel {
  @override
  FutureOr<void> build() {}

  /// Cancel a pending payout
  Future<bool> cancelPayout(String payoutId) async {
    state = const AsyncValue.loading();
    try {
      final paymentRepo = ref.read(paymentRepositoryProvider);
      await paymentRepo.updatePayoutStatus(
        payoutId: payoutId,
        status: PayoutStatus.cancelled,
      );

      if (!ref.mounted) return true;
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      TalkerService.error('Error cancelling payout: $e');
      if (ref.mounted) {
        state = AsyncValue.error(e, stack);
      }
      return false;
    }
  }
}

/// Driver Stripe Status model for UI display
///
/// Represents the current state of a driver's Stripe Connect account.
@freezed
abstract class DriverStripeStatus with _$DriverStripeStatus {
  const factory DriverStripeStatus({
    @Default(false) bool isConnected,
    @Default(false) bool payoutsEnabled,
    @Default(false) bool chargesEnabled,
    @Default(false) bool detailsSubmitted,
    @Default(0.0) double availableBalance,
    @Default(0.0) double pendingBalance,
    @Default('EUR') String currency,
    String? stripeAccountId,
  }) = _DriverStripeStatus;

  factory DriverStripeStatus.fromJson(Map<String, dynamic> json) =>
      _$DriverStripeStatusFromJson(json);
}

/// Provider to get current driver's Stripe status
@riverpod
Future<DriverStripeStatus> driverStripeStatus(Ref ref) async {
  final paymentRepo = ref.read(paymentRepositoryProvider);
  final user = ref.watch(authStateProvider).value;
  if (user == null) return const DriverStripeStatus();

  try {
    final connectedAccount = await paymentRepo.getConnectedAccount(user.uid);

    if (connectedAccount == null) {
      return const DriverStripeStatus();
    }

    return DriverStripeStatus(
      isConnected: true,
      payoutsEnabled: connectedAccount.payoutsEnabled,
      chargesEnabled: connectedAccount.chargesEnabled,
      detailsSubmitted: connectedAccount.detailsSubmitted,
      availableBalance: connectedAccount.availableBalance,
      pendingBalance: connectedAccount.pendingBalance,
      currency: connectedAccount.defaultCurrency,
      stripeAccountId: connectedAccount.stripeAccountId,
    );
  } catch (e) {
    return const DriverStripeStatus();
  }
}
