import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/providers/repository_providers.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/services/stripe_service.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/payments/models/payment_model.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';

part 'payment_view_model.freezed.dart';
part 'payment_view_model.g.dart';

class DriverStripeOnboardingFlowState {
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
  final bool isLoading;
  final bool showWebView;
  final bool isVerifying;
  final bool completionHandled;
  final bool isConnected;
  final double webViewProgress;
  final String? onboardingUrl;
  final String? errorMessage;
  final String? successMessage;

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
  const PaymentHistoryFilterState({this.selectedFilter = 'completed'});

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

@riverpod
List<PaymentTransaction> filteredRiderPayments(
  Ref ref,
  List<PaymentTransaction> payments,
) {
  final selectedFilter = ref
      .watch(paymentHistoryFilterViewModelProvider)
      .selectedFilter;

  return switch (selectedFilter) {
    'completed' =>
      payments.where((p) => p.status == PaymentStatus.succeeded).toList(),
    'pending' =>
      payments
          .where(
            (p) =>
                p.status == PaymentStatus.pending ||
                p.status == PaymentStatus.processing,
          )
          .toList(),
    'refunded' =>
      payments
          .where(
            (p) =>
                p.status == PaymentStatus.refunded ||
                p.status == PaymentStatus.partiallyRefunded,
          )
          .toList(),
    'failed' =>
      payments
          .where(
            (p) =>
                p.status == PaymentStatus.failed ||
                p.status == PaymentStatus.cancelled,
          )
          .toList(),
    _ => payments,
  };
}

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

      const currency = 'EUR';

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
        amountInCents:
            ride.pricing.pricePerSeatInCents.amountInCents * seatsBooked,
        currency: currency,
        customerId: customerId,
        description:
            '${ride.route.origin.address} → ${ride.route.destination.address}',
      );

      // Process payment with Payment Sheet (pass ephemeral key for saved cards
      // and currency for Google/Apple Pay)
      final success = await stripeService.processPaymentWithSheet(
        paymentIntentClientSecret: paymentIntentData['clientSecret'] as String,
        customerId: customerId,
        ephemeralKeySecret: paymentIntentData['ephemeralKey'] as String?,
        currency: currency,
      );

      if (success) {
        final paymentIntentId = paymentIntentData['paymentIntentId'] as String?;
        if (paymentIntentId == null || paymentIntentId.isEmpty) {
          throw StateError('Payment intent response did not include an ID.');
        }

        // Payment succeeded - get the updated payment record from Firestore
        // (Firebase webhook will update it automatically)
        final payment = await paymentRepo.getPaymentById(paymentIntentId);
        if (payment == null) {
          throw StateError('Payment record not found for $paymentIntentId.');
        }

        // Check if provider is still mounted after async operation
        if (!ref.mounted) return payment;

        state = const AsyncValue.data(null);
        return payment;
      } else {
        throw Exception('Payment cancelled by user');
      }
    } catch (e, st) {
      TalkerService.error('Error processing payment: $e');

      // Check if provider is still mounted before setting error state
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
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
    } catch (e, st) {
      TalkerService.error('Error getting/creating customer: $e');
      rethrow;
    }
  }

  /// Refund payment
  Future<void> refundBookingPayment({
    required String paymentId,
    int? amountInCents,
    String? reason,
  }) async {
    state = const AsyncValue.loading();

    try {
      final paymentRepo = ref.read(paymentRepositoryProvider);
      await paymentRepo.processRefund(
        paymentId: paymentId,
        amountInCents: amountInCents,
        reason: reason,
      );

      // Check if provider is still mounted after async operation
      if (!ref.mounted) return;

      state = const AsyncValue.data(null);
    } catch (e, st) {
      TalkerService.error('Error processing refund: $e');

      // Check if provider is still mounted before setting error state
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
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
  /// Returns the saved [ConnectedAccountCreationResult] on success, or null on failure.
  Future<ConnectedAccountCreationResult?> createConnectedAccount({
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
    } catch (e, st) {
      TalkerService.error('Error creating connected account: $e');
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
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
    } catch (e, st) {
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
      final nameParts = user.username.trim().split(RegExp(r'\s+'));
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
            phone: switch (user) {
              final RiderModel rider => rider.phoneNumber,
              final DriverModel driver => driver.phoneNumber,
              _ => null,
            },
            dateOfBirth: switch (user) {
              final RiderModel rider => rider.dateOfBirth,
              final DriverModel driver => driver.dateOfBirth,
              _ => null,
            },
            addressLine1: switch (user) {
              final RiderModel rider => rider.address,
              final DriverModel driver => driver.address,
              _ => null,
            },
            city: switch (user) {
              final RiderModel rider => rider.city,
              final DriverModel driver => driver.city,
              _ => null,
            },
          );

      if (!ref.mounted) return;

      if (result != null &&
          result.onboardingUrl != null &&
          result.account.stripeAccountId.isNotEmpty) {
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
    } on Exception {
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
      if (user == null) {
        state = state.copyWith(
          isVerifying: false,
          errorMessage: verifyFailedMessage,
          completionHandled: false,
        );
        return;
      }

      final driver = user is DriverModel ? user : null;
      if (driver == null) {
        state = state.copyWith(
          isVerifying: false,
          errorMessage: verifyFailedMessage,
          completionHandled: false,
        );
        return;
      }

      final paymentRepo = ref.read(paymentRepositoryProvider);
      final connectedAccount = await paymentRepo.getConnectedAccount(
        driver.uid,
      );
      final stripeAccountId =
          connectedAccount?.stripeAccountId ?? driver.stripeAccountId;
      if (stripeAccountId == null || stripeAccountId.isEmpty) {
        state = state.copyWith(
          isVerifying: false,
          errorMessage: verifyFailedMessage,
          completionHandled: false,
        );
        return;
      }

      final result = await paymentRepo.refreshConnectedAccountFromServer(
        driverId: driver.uid,
        accountId: stripeAccountId,
      );

      if (!ref.mounted) return;

      final isReady =
          result != null &&
          result.chargesEnabled &&
          result.payoutsEnabled &&
          result.detailsSubmitted &&
          result.capabilities.transfers.name == 'active';

      state = state.copyWith(
        isVerifying: false,
        isConnected: isReady,
        successMessage: isReady ? successMessage : additionalInfoMessage,
        showWebView: false,
        webViewProgress: 0,
        clearOnboardingUrl: true,
      );
    } catch (e, st) {
      TalkerService.error(
        'Stripe onboarding verification failed: $e',
        e,
        st,
      );

      if (!ref.mounted) return;

      state = state.copyWith(
        isVerifying: false,
        completionHandled: false,
        errorMessage: verifyFailedMessage,
        showWebView: false,
        webViewProgress: 0,
        clearOnboardingUrl: true,
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
    final country = switch (user) {
      final RiderModel rider => rider.country,
      final DriverModel driver => driver.country,
      _ => null,
    };
    if (country != null && country.isNotEmpty) {
      return country.toUpperCase();
    }
    final phone = switch (user) {
      final RiderModel rider => rider.phoneNumber,
      final DriverModel driver => driver.phoneNumber,
      _ => null,
    };
    if (phone != null) {
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
    } catch (e, st) {
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
    required int amountInCents,
    required String currency,
  }) async {
    state = const AsyncValue.loading();

    try {
      final stripeService = ref.read(stripeServiceProvider);

      await stripeService.createInstantPayout(
        stripeAccountId: stripeAccountId,
        amountInCents: amountInCents, // Amount in cents
        currency: currency,
      );

      if (!ref.mounted) return true;

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      TalkerService.error('Error requesting payout: $e');
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
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
    } catch (e, st) {
      TalkerService.error('Error cancelling payout: $e');
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
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
    @Default(0) int availableBalanceInCents,
    @Default(0) int pendingBalanceInCents,
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
  final stripeService = ref.watch(stripeServiceProvider);
  final authUser = ref.watch(authStateProvider).value;
  final userModel = ref.watch(currentUserProvider).value;

  if (authUser == null) return const DriverStripeStatus();

  try {
    final connectedAccount = await paymentRepo.getConnectedAccount(
      authUser.uid,
    );
    final driver = userModel is DriverModel ? userModel : null;

    final accountId =
        connectedAccount?.stripeAccountId ?? driver?.stripeAccountId;

    if (accountId == null || accountId.isEmpty) {
      return const DriverStripeStatus();
    }

    try {
      final liveStatus = await stripeService.getAccountStatus(
        accountId: accountId,
      );

      int balanceInCents(String centsKey, String legacyMajorKey) {
        final cents = liveStatus[centsKey] as num?;
        if (cents != null) return cents.round();

        final legacyMajor = liveStatus[legacyMajorKey] as num?;
        return legacyMajor == null ? 0 : (legacyMajor * 100).round();
      }

      final liveChargesEnabled = liveStatus['chargesEnabled'] == true;
      final livePayoutsEnabled = liveStatus['payoutsEnabled'] == true;
      final liveDetailsSubmitted = liveStatus['detailsSubmitted'] == true;
      final liveCapabilities = liveStatus['capabilities'];
      final liveTransfersActive =
          liveCapabilities is Map && liveCapabilities['transfers'] == 'active';
      final liveAvailableBalance = balanceInCents(
        'availableBalanceInCents',
        'availableBalance',
      );
      final livePendingBalance = balanceInCents(
        'pendingBalanceInCents',
        'pendingBalance',
      );

      return DriverStripeStatus(
        isConnected:
            liveChargesEnabled &&
            livePayoutsEnabled &&
            liveDetailsSubmitted &&
            liveTransfersActive,
        payoutsEnabled: livePayoutsEnabled,
        chargesEnabled: liveChargesEnabled,
        detailsSubmitted: liveDetailsSubmitted,
        availableBalanceInCents: liveAvailableBalance,
        pendingBalanceInCents: livePendingBalance,
        stripeAccountId: accountId,
      );
    } catch (e, st) {
      TalkerService.warning(
        'Live Stripe status fetch failed, falling back to cached status: $e',
      );

      final cachedChargesEnabled = connectedAccount?.chargesEnabled ?? false;
      final cachedPayoutsEnabled = connectedAccount?.payoutsEnabled ?? false;
      final cachedDetailsSubmitted =
          connectedAccount?.detailsSubmitted ?? false;

      return DriverStripeStatus(
        isConnected:
            (connectedAccount?.isFullySetup ?? false) ||
            (cachedChargesEnabled &&
                cachedPayoutsEnabled &&
                cachedDetailsSubmitted),
        payoutsEnabled: cachedPayoutsEnabled,
        chargesEnabled: cachedChargesEnabled,
        detailsSubmitted: cachedDetailsSubmitted,
        availableBalanceInCents: connectedAccount?.availableBalanceInCents ?? 0,
        pendingBalanceInCents: connectedAccount?.pendingBalanceInCents ?? 0,
        stripeAccountId: accountId,
      );
    }
  } catch (e, st) {
    TalkerService.error('Error loading driverStripeStatus: $e', e, st);
    return const DriverStripeStatus();
  }
}

@Riverpod(keepAlive: true)
Stream<DriverConnectedAccount?> currentDriverConnectedAccount(Ref ref) {
  final user = ref.watch(currentUserProvider).value;
  final paymentRepo = ref.watch(paymentRepositoryProvider);

  final driver = user is DriverModel ? user : null;
  if (driver == null) {
    return Stream<DriverConnectedAccount?>.value(null);
  }

  return paymentRepo.streamConnectedAccount(driver.uid);
}
