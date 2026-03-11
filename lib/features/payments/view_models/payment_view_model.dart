import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/services/stripe_service.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/payments/models/payment_model.dart';
import 'package:sport_connect/core/providers/repository_providers.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';

part 'payment_view_model.freezed.dart';
part 'payment_view_model.g.dart';

class DriverStripeOnboardingFlowState {
  final bool isLoading;
  final bool showWebView;
  final bool isVerifying;
  final bool completionHandled;
  final bool isConnected;
  final double webViewProgress;
  final String? onboardingUrl;
  final String? errorMessage;
  final String? successMessage;

  const DriverStripeOnboardingFlowState({
    this.isLoading = false,
    this.showWebView = false,
    this.isVerifying = false,
    this.completionHandled = false,
    this.isConnected = false,
    this.webViewProgress = 0,
    this.onboardingUrl,
    this.errorMessage,
    this.successMessage,
  });

  DriverStripeOnboardingFlowState copyWith({
    bool? isLoading,
    bool? showWebView,
    bool? isVerifying,
    bool? completionHandled,
    bool? isConnected,
    double? webViewProgress,
    String? onboardingUrl,
    String? errorMessage,
    String? successMessage,
    bool clearOnboardingUrl = false,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return DriverStripeOnboardingFlowState(
      isLoading: isLoading ?? this.isLoading,
      showWebView: showWebView ?? this.showWebView,
      isVerifying: isVerifying ?? this.isVerifying,
      completionHandled: completionHandled ?? this.completionHandled,
      isConnected: isConnected ?? this.isConnected,
      webViewProgress: webViewProgress ?? this.webViewProgress,
      onboardingUrl: clearOnboardingUrl
          ? null
          : (onboardingUrl ?? this.onboardingUrl),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
    );
  }
}

class PaymentHistoryFilterState {
  const PaymentHistoryFilterState({this.selectedFilter = 'all'});

  final String selectedFilter;

  PaymentHistoryFilterState copyWith({String? selectedFilter}) {
    return PaymentHistoryFilterState(
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }
}

@Riverpod(keepAlive: true)
class PaymentHistoryFilterViewModel extends _$PaymentHistoryFilterViewModel {
  @override
  PaymentHistoryFilterState build() => const PaymentHistoryFilterState();

  static const validFilters = <String>{
    'all',
    'completed',
    'pending',
    'refunded',
    'failed',
  };

  void setFilter(String filter) {
    if (!validFilters.contains(filter) || filter == state.selectedFilter) {
      return;
    }
    state = state.copyWith(selectedFilter: filter);
  }
}

final filteredRiderPaymentsProvider =
    Provider.family<List<PaymentTransaction>, List<PaymentTransaction>>((
      ref,
      payments,
    ) {
      final selectedFilter = ref
          .watch(paymentHistoryFilterViewModelProvider)
          .selectedFilter;

      switch (selectedFilter) {
        case 'completed':
          return payments
              .where((payment) => payment.status == PaymentStatus.succeeded)
              .toList();
        case 'pending':
          return payments
              .where(
                (payment) =>
                    payment.status == PaymentStatus.pending ||
                    payment.status == PaymentStatus.processing,
              )
              .toList();
        case 'refunded':
          return payments
              .where(
                (payment) =>
                    payment.status == PaymentStatus.refunded ||
                    payment.status == PaymentStatus.partiallyRefunded,
              )
              .toList();
        case 'failed':
          return payments
              .where(
                (payment) =>
                    payment.status == PaymentStatus.failed ||
                    payment.status == PaymentStatus.cancelled,
              )
              .toList();
        default:
          return payments;
      }
    });

class DriverEarningsPeriodState {
  const DriverEarningsPeriodState({this.selectedPeriod = 'thisWeek'});

  final String selectedPeriod;

  DriverEarningsPeriodState copyWith({String? selectedPeriod}) {
    return DriverEarningsPeriodState(
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
    );
  }
}

@Riverpod(keepAlive: true)
class DriverEarningsPeriodViewModel extends _$DriverEarningsPeriodViewModel {
  @override
  DriverEarningsPeriodState build() => const DriverEarningsPeriodState();

  static const validPeriods = <String>{
    'today',
    'thisWeek',
    'thisMonth',
    'allTime',
  };

  void setPeriod(String period) {
    if (!validPeriods.contains(period) || period == state.selectedPeriod) {
      return;
    }
    state = state.copyWith(selectedPeriod: period);
  }
}

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
}

/// Driver Onboarding View Model
///
/// Handles Stripe Connect account creation and onboarding for drivers.
@riverpod
class DriverOnboardingViewModel extends _$DriverOnboardingViewModel {
  @override
  FutureOr<void> build() {}

  /// Creates a connected account via Stripe and persists it via the repository.
  ///
  /// Prefills individual info to reduce onboarding friction.
  /// Returns the saved [DriverConnectedAccount] on success, or null on failure.
  Future<DriverConnectedAccount?> createConnectedAccount({
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
      final paymentRepo = ref.read(paymentRepositoryProvider);
      final account = await paymentRepo.createConnectedAccount(
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

      if (!ref.mounted) return account;

      state = const AsyncValue.data(null);
      return account;
    } catch (e, stack) {
      TalkerService.error('Error creating connected account: $e');
      if (ref.mounted) {
        state = AsyncValue.error(e, stack);
      }
      return null;
    }
  }
}

@riverpod
class DriverStripeOnboardingFlowViewModel
    extends _$DriverStripeOnboardingFlowViewModel {
  @override
  DriverStripeOnboardingFlowState build() =>
      const DriverStripeOnboardingFlowState();

  Future<void> checkExistingAccount(UserModel? user) async {
    if (user == null) return;

    try {
      final status = await ref.read(driverStripeStatusProvider.future);
      if (!ref.mounted) return;
      if (status.isConnected) {
        state = state.copyWith(isConnected: true, clearError: true);
      }
    } catch (e) {
      TalkerService.error('Error checking existing Stripe account: $e');
    }
  }

  Future<void> startOnboarding(UserModel? user) async {
    if (user == null) {
      state = state.copyWith(
        errorMessage: 'Please sign in to continue.',
        isLoading: false,
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      final country = _detectUserCountry(user);
      final nameParts = user.displayName.trim().split(RegExp(r'\s+'));
      final firstName = nameParts.first;
      final lastName = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : null;

      final result = await ref
          .read(driverOnboardingViewModelProvider.notifier)
          .createConnectedAccount(
            userId: user.uid,
            email: user.email,
            country: country,
            firstName: firstName,
            lastName: lastName,
            phone: user.phoneNumber,
            dateOfBirth: user.dateOfBirth,
            addressLine1: user.address,
            city: user.city,
          );

      if (!ref.mounted) return;

      if (result != null &&
          result.onboardingUrl != null &&
          result.stripeAccountId.isNotEmpty) {
        state = state.copyWith(
          isLoading: false,
          onboardingUrl: result.onboardingUrl,
          showWebView: true,
          completionHandled: false,
          webViewProgress: 0,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Stripe account creation failed.',
        );
      }
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Stripe setup failed.',
      );
    }
  }

  void failWebViewLoad(String message) {
    state = state.copyWith(
      errorMessage: message,
      showWebView: false,
      webViewProgress: 0,
      clearOnboardingUrl: true,
    );
  }

  void markCompletionHandled() {
    state = state.copyWith(
      completionHandled: true,
      showWebView: false,
      webViewProgress: 0,
      clearError: true,
    );
  }

  void setWebViewProgress(double progress) {
    final normalized = progress.clamp(0, 1).toDouble();
    if (normalized == state.webViewProgress) return;
    state = state.copyWith(webViewProgress: normalized);
  }

  Future<void> handleOnboardingComplete({
    required UserModel? user,
    required String successMessage,
    required String additionalInfoMessage,
    required String verifyFailedMessage,
  }) async {
    state = state.copyWith(
      isVerifying: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      await Future.delayed(const Duration(seconds: 2));
      if (user == null) {
        state = state.copyWith(
          isVerifying: false,
          errorMessage: verifyFailedMessage,
          completionHandled: false,
        );
        return;
      }

      ref.invalidate(driverStripeStatusProvider);
      final status = await ref.read(driverStripeStatusProvider.future);
      if (!ref.mounted) return;

      if (status.isConnected) {
        state = state.copyWith(
          isVerifying: false,
          isConnected: true,
          successMessage: successMessage,
        );
      } else {
        state = state.copyWith(
          isVerifying: false,
          errorMessage: additionalInfoMessage,
          completionHandled: false,
        );
      }
    } catch (e, stack) {
      TalkerService.error(
        'Stripe onboarding verification failed: $e',
        e,
        stack,
      );
      if (!ref.mounted) return;
      state = state.copyWith(
        isVerifying: false,
        completionHandled: false,
        errorMessage: verifyFailedMessage,
        showWebView: false,
        webViewProgress: 0,
      );
    }
  }

  void cancelOnboarding() {
    state = state.copyWith(
      showWebView: false,
      completionHandled: false,
      webViewProgress: 0,
      clearOnboardingUrl: true,
    );
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }

  String _detectUserCountry(UserModel user) {
    if (user.country != null && user.country!.isNotEmpty) {
      return user.country!.toUpperCase();
    }

    if (user.phoneNumber != null) {
      final phone = user.phoneNumber!;
      const phoneCountryMap = {
        '+216': 'TN',
        '+33': 'FR',
        '+49': 'DE',
        '+34': 'ES',
        '+39': 'IT',
        '+44': 'GB',
        '+1': 'US',
        '+32': 'BE',
        '+41': 'CH',
        '+352': 'LU',
        '+31': 'NL',
        '+351': 'PT',
        '+43': 'AT',
        '+212': 'MA',
        '+213': 'DZ',
      };

      for (final entry in phoneCountryMap.entries) {
        if (phone.startsWith(entry.key)) {
          return entry.value;
        }
      }
    }

    return 'FR';
  }
}

/// Rider Payment History Provider
@riverpod
Future<List<PaymentTransaction>> riderPaymentHistory(
  Ref ref,
  String riderId,
) async {
  final paymentRepo = ref.watch(paymentRepositoryProvider);
  return paymentRepo.getRiderPaymentHistory(riderId: riderId);
}

/// Rider Payment History Stream Provider
@riverpod
Stream<List<PaymentTransaction>> riderPaymentHistoryStream(
  Ref ref,
  String riderId,
) {
  final paymentRepo = ref.watch(paymentRepositoryProvider);
  return paymentRepo.streamRiderPaymentHistory(riderId: riderId);
}

/// Driver Connected Account View Model
@riverpod
class DriverConnectedAccountViewModel
    extends _$DriverConnectedAccountViewModel {
  @override
  Future<DriverConnectedAccount?> build(String driverId) async {
    final paymentRepo = ref.watch(paymentRepositoryProvider);
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
  final paymentRepo = ref.watch(paymentRepositoryProvider);
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
  final paymentRepo = ref.watch(paymentRepositoryProvider);
  return paymentRepo.getDriverEarnings(
    driverId: driverId,
    startDate: startDate,
    endDate: endDate,
  );
}

/// Driver Payouts Provider
@riverpod
Future<List<DriverPayout>> driverPayouts(Ref ref, String driverId) async {
  final paymentRepo = ref.watch(paymentRepositoryProvider);
  return paymentRepo.getDriverPayouts(driverId: driverId);
}

/// Single Payout Detail Provider
@riverpod
Future<DriverPayout?> payoutDetail(Ref ref, String payoutId) async {
  final paymentRepo = ref.watch(paymentRepositoryProvider);
  return paymentRepo.getPayoutById(payoutId);
}

/// Driver Payout View Model
@riverpod
class DriverPayoutViewModel extends _$DriverPayoutViewModel {
  @override
  FutureOr<void> build() {}

  /// Requests an instant payout to the driver's bank account.
  ///
  /// [stripeAccountId] - driver's Stripe Connect account ID from Firestore.
  Future<bool> requestInstantPayout({
    required String stripeAccountId,
    required double amount,
    required String currency,
  }) async {
    state = const AsyncValue.loading();

    try {
      final stripeService = ref.read(stripeServiceProvider);

      await stripeService.createInstantPayout(
        stripeAccountId: stripeAccountId,
        amount: amount, // Main currency unit — server converts to cents
        currency: currency,
      );

      if (!ref.mounted) return true;

      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      TalkerService.error('Error requesting payout: $e');
      if (ref.mounted) {
        state = AsyncValue.error(e, stack);
      }
      return false;
    }
  }

  /// Cancels a pending payout.
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
  final paymentRepo = ref.watch(paymentRepositoryProvider);
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
