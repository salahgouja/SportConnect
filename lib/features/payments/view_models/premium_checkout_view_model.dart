import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/providers/repository_providers.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/services/stripe_service.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/payments/models/premium_plan.dart';
import 'package:sport_connect/features/payments/services/premium_iap_service.dart';

part 'premium_checkout_view_model.g.dart';

class PremiumCheckoutState {
  const PremiumCheckoutState({
    this.selectedPlan = PremiumPlan.monthly,
    this.isProcessing = false,
    this.isCompleted = false,
    this.errorMessage,
  });
  final PremiumPlan selectedPlan;
  final bool isProcessing;
  final bool isCompleted;
  final String? errorMessage;

  PremiumCheckoutState copyWith({
    PremiumPlan? selectedPlan,
    bool? isProcessing,
    bool? isCompleted,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PremiumCheckoutState(
      selectedPlan: selectedPlan ?? this.selectedPlan,
      isProcessing: isProcessing ?? this.isProcessing,
      isCompleted: isCompleted ?? this.isCompleted,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

@riverpod
class PremiumCheckoutViewModel extends _$PremiumCheckoutViewModel {
  @override
  PremiumCheckoutState build() => const PremiumCheckoutState();

  void selectPlan(PremiumPlan plan) {
    if (state.isProcessing || plan == state.selectedPlan) return;
    state = state.copyWith(selectedPlan: plan, clearError: true);
  }

  void clearError() {
    if (state.errorMessage == null) return;
    state = state.copyWith(clearError: true);
  }

  Future<bool> completeCheckout() async {
    if (state.isProcessing) return false;

    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) {
      state = state.copyWith(errorMessage: 'Please sign in and try again.');
      return false;
    }

    state = state.copyWith(isProcessing: true, clearError: true);

    try {
      var premiumSource = 'stripe_fallback';
      String? premiumTransactionId;

      final iapService = ref.read(premiumIapServiceProvider);
      if (iapService.isSupportedPlatform) {
        final purchaseResult = await iapService.purchasePlan(
          state.selectedPlan,
        );
        if (!purchaseResult.isSuccess) {
          if (!ref.mounted) return false;
          state = state.copyWith(
            isProcessing: false,
            errorMessage:
                purchaseResult.errorMessage ??
                'Unable to complete purchase. Please try again.',
          );
          return false;
        }

        premiumSource = 'iap';
        premiumTransactionId = purchaseResult.purchase?.purchaseID;
      }

      await _syncStripeCustomer(currentUser);

      await ref.read(profileRepositoryProvider).updateProfile(currentUser.uid, {
        'isPremium': true,
        'premiumPlan': state.selectedPlan.name,
        'premiumSource': premiumSource,
        'premiumUpdatedAt': DateTime.now(),
        if (premiumTransactionId != null && premiumTransactionId.isNotEmpty)
          'premiumTransactionId': premiumTransactionId,
      });

      if (!ref.mounted) return false;

      ref.invalidate(currentUserProvider);
      state = state.copyWith(isProcessing: false, isCompleted: true);
      return true;
    } on Exception catch (e, st) {
      TalkerService.error('Premium checkout failed', e, st);
      if (!ref.mounted) return false;
      state = state.copyWith(
        isProcessing: false,
        errorMessage: 'Unable to complete checkout. Please try again.',
      );
      return false;
    }
  }

  Future<void> _syncStripeCustomer(UserModel currentUser) async {
    try {
      final existingCustomerId = currentUser is DriverModel
          ? currentUser.stripeCustomerId
          : null;

      await ref
          .read(stripeServiceProvider)
          .getOrCreateCustomer(
            userId: currentUser.uid,
            email: currentUser.email,
            name: currentUser.displayName,
            phone: currentUser.phoneNumber,
            existingCustomerId: existingCustomerId,
          );
    } on Exception catch (e, st) {
      // Keep premium activation successful even if Stripe metadata sync fails.
      TalkerService.warning(
        'Premium purchase succeeded but Stripe customer sync failed: $e',
      );
      TalkerService.error('Stripe customer sync error', e, st);
    }
  }
}

final premiumIapServiceProvider = Provider<PremiumIapService>(
  (ref) => PremiumIapService(),
);
