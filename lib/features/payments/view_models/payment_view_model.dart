import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/services/stripe_service.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/features/payments/models/payment_model.dart';
import 'package:sport_connect/features/payments/repositories/payment_repository.dart';
import 'package:sport_connect/features/rides/models/ride_model.dart';

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
      final stripeService = StripeService();
      final paymentRepo = ref.read(paymentRepositoryProvider);

      // Calculate total amount
      final totalAmount = ride.pricePerSeat * seatsBooked;
      final currency = ride.currency ?? 'usd';

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
        driverName: ride.driverName,
        amount: totalAmount * 100, // Convert to cents
        currency: currency,
        customerId: customerId,
        description: '${ride.origin.address} → ${ride.destination.address}',
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

        state = const AsyncValue.data(null);
        return payment!;
      } else {
        throw Exception('Payment cancelled by user');
      }
    } catch (e, stack) {
      TalkerService.error('Error processing payment: $e');
      state = AsyncValue.error(e, stack);
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
      final stripeService = StripeService();
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

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      TalkerService.error('Error processing refund: $e');
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Create connected account for driver
  Future<Map<String, dynamic>?> createConnectedAccount({
    required String userId,
    required String email,
    required String country,
  }) async {
    state = const AsyncValue.loading();

    try {
      final stripeService = StripeService();

      final result = await stripeService.createDriverConnectedAccount(
        userId: userId,
        email: email,
        country: country,
        refreshUrl: 'sportconnect://driver/onboarding/refresh',
        returnUrl: 'sportconnect://driver/onboarding/complete',
      );

      state = const AsyncValue.data(null);
      return result;
    } catch (e, stack) {
      TalkerService.error('Error creating connected account: $e');
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
      final stripeService = StripeService();

      await stripeService.createInstantPayout(
        driverId: userId,
        stripeAccountId: stripeAccountId,
        amount: amount * 100, // Convert to cents/millimes
        currency: currency,
        isFullySetup: isFullySetup,
      );

      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      TalkerService.error('Error requesting payout: $e');
      state = AsyncValue.error(e, stack);
      return false;
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

  /// Create connected account for driver
  /// Uses Firebase Cloud Functions for secure server-side processing
  Future<DriverConnectedAccount> createConnectedAccount({
    required String email,
    required String country,
  }) async {
    state = const AsyncValue.loading();

    try {
      final stripeService = StripeService();
      final paymentRepo = ref.read(paymentRepositoryProvider);

      // Create Stripe Connect account and get onboarding URL
      // The Firebase Cloud Function returns both accountId and onboardingUrl
      final accountData = await stripeService.createDriverConnectedAccount(
        userId: driverId,
        email: email,
        country: country,
        refreshUrl: 'sportconnect://driver/onboarding/refresh',
        returnUrl: 'sportconnect://driver/onboarding/complete',
      );

      // Create local record (Firebase Function also saves to Firestore)
      final connectedAccount = DriverConnectedAccount(
        id: accountData['accountId'],
        driverId: driverId,
        stripeAccountId: accountData['accountId'],
        email: email,
        country: country,
        chargesEnabled: false,
        payoutsEnabled: false,
        detailsSubmitted: false,
        onboardingCompleted: false,
        onboardingUrl: accountData['onboardingUrl'],
      );

      // Optionally save locally if not already done by function
      await paymentRepo.saveConnectedAccount(connectedAccount);

      state = AsyncValue.data(connectedAccount);
      return connectedAccount;
    } catch (e, stack) {
      TalkerService.error('Error creating connected account: $e');
      state = AsyncValue.error(e, stack);
      rethrow;
    }
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

/// Driver Payout View Model
@riverpod
class DriverPayoutViewModel extends _$DriverPayoutViewModel {
  @override
  FutureOr<void> build() {}

  /// Request instant payout
  Future<DriverPayout> requestInstantPayout({
    required String driverId,
    required String stripeAccountId,
    required double amount,
    required String currency,
    bool isFullySetup = true,
  }) async {
    state = const AsyncValue.loading();

    try {
      final stripeService = StripeService();
      final paymentRepo = ref.read(paymentRepositoryProvider);

      // Get connected account
      final connectedAccount = await paymentRepo.getConnectedAccount(driverId);
      if (connectedAccount == null) {
        throw Exception('No connected account found');
      }

      // Request instant payout via Firebase Cloud Function
      final payoutData = await stripeService.createInstantPayout(
        driverId: driverId,
        stripeAccountId: stripeAccountId,
        amount: amount * 100, // Convert to cents
        currency: currency,
        isFullySetup: isFullySetup,
      );

      // Payout record created by Cloud Function, just refresh
      ref.invalidateSelf();

      state = const AsyncValue.data(null);

      return DriverPayout(
        id: payoutData['payoutId'],
        driverId: driverId,
        driverName: '',
        connectedAccountId: connectedAccount.stripeAccountId,
        amount: amount,
        currency: currency,
        status: PayoutStatus.inTransit,
        stripePayoutId: payoutData['payoutId'],
        isInstantPayout: true,
        expectedArrivalDate: DateTime.fromMillisecondsSinceEpoch(
          payoutData['arrivalDate'] * 1000,
        ),
      );
    } catch (e, stack) {
      TalkerService.error('Error requesting instant payout: $e');
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

/// Driver Stripe Status model for UI display
class DriverStripeStatus {
  final bool isConnected;
  final bool payoutsEnabled;
  final bool chargesEnabled;
  final bool detailsSubmitted;
  final double availableBalance;
  final double pendingBalance;
  final String? stripeAccountId;

  DriverStripeStatus({
    required this.isConnected,
    required this.payoutsEnabled,
    required this.chargesEnabled,
    required this.detailsSubmitted,
    required this.availableBalance,
    required this.pendingBalance,
    this.stripeAccountId,
  });
}

/// Provider to get current driver's Stripe status
@riverpod
Future<DriverStripeStatus> driverStripeStatus(Ref ref) async {
  final paymentRepo = ref.read(paymentRepositoryProvider);

  // Get current user ID - we need to import auth provider
  // For now, use the payment repository to check if connected
  try {
    // This will be called with the logged-in user context
    // The payment repository should have methods to get the current driver's status
    final connectedAccount = await paymentRepo
        .getCurrentDriverConnectedAccount();

    if (connectedAccount == null) {
      return DriverStripeStatus(
        isConnected: false,
        payoutsEnabled: false,
        chargesEnabled: false,
        detailsSubmitted: false,
        availableBalance: 0.0,
        pendingBalance: 0.0,
      );
    }

    return DriverStripeStatus(
      isConnected: true,
      payoutsEnabled: connectedAccount.payoutsEnabled,
      chargesEnabled: connectedAccount.chargesEnabled,
      detailsSubmitted: connectedAccount.detailsSubmitted,
      availableBalance: connectedAccount.availableBalance,
      pendingBalance: connectedAccount.pendingBalance,
      stripeAccountId: connectedAccount.stripeAccountId,
    );
  } catch (e) {
    return DriverStripeStatus(
      isConnected: false,
      payoutsEnabled: false,
      chargesEnabled: false,
      detailsSubmitted: false,
      availableBalance: 0.0,
      pendingBalance: 0.0,
    );
  }
}
