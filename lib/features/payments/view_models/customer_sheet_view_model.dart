import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/services/stripe_service.dart';
import 'package:sport_connect/core/services/talker_service.dart';

part 'customer_sheet_view_model.g.dart';

/// State for the Customer Sheet feature
class CustomerSheetState {
  const CustomerSheetState({
    this.selectedPaymentOption,
    this.isLoading = false,
    this.errorMessage,
  });

  final CustomerSheetResult? selectedPaymentOption;
  final bool isLoading;
  final String? errorMessage;

  CustomerSheetState copyWith({
    CustomerSheetResult? selectedPaymentOption,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool clearSelection = false,
  }) {
    return CustomerSheetState(
      selectedPaymentOption: clearSelection
          ? null
          : selectedPaymentOption ?? this.selectedPaymentOption,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

@riverpod
class CustomerSheetViewModel extends _$CustomerSheetViewModel {
  @override
  CustomerSheetState build() => const CustomerSheetState();

  /// Open the Stripe Customer Sheet to manage payment methods
  Future<void> presentCustomerSheet() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final stripeService = ref.read(stripeServiceProvider);
      final result = await stripeService.presentCustomerSheet();

      if (!ref.mounted) return;

      if (result != null) {
        state = state.copyWith(
          selectedPaymentOption: result,
          isLoading: false,
        );
        TalkerService.info('Customer sheet: payment method updated');
      } else {
        // User dismissed without changing
        state = state.copyWith(isLoading: false);
      }
    } on StripePaymentException catch (e) {
      TalkerService.error('Customer sheet error: $e');
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    } catch (e, st) {
      TalkerService.error('Customer sheet error: $e');
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to open payment methods. Please try again.',
      );
    }
  }
}
