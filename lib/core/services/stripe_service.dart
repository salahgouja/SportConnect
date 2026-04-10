import 'dart:ui';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/core/config/app_config.dart';

part 'stripe_service.g.dart';

/// Riverpod provider for StripeService singleton
@Riverpod(keepAlive: true)
StripeService stripeService(Ref ref) => StripeService();

/// Stripe Service for payment processing and Connect functionality
///
/// Architecture:
/// - Uses Firebase Cloud Functions for server-side Stripe operations
/// - Uses Firebase Firestore for data storage
/// - All sensitive operations handled server-side for security
class StripeService {
  static final StripeService _instance = StripeService._internal();
  factory StripeService() => _instance;
  StripeService._internal();

  late FirebaseFunctions _functions;

  /// Initialize Stripe with publishable key
  Future<void> initialize({required String publishableKey}) async {
    Stripe.publishableKey = publishableKey;
    await Stripe.instance.applySettings();

    // Initialize Firebase Functions
    _functions = FirebaseFunctions.instance;

    // Connect to emulator if in development mode
    if (AppConfig.useEmulators) {
      _functions.useFunctionsEmulator(
        AppConfig.emulatorHost,
        AppConfig.functionsEmulatorPort,
      );
      TalkerService.info(
        'Stripe service using Functions emulator at ${AppConfig.emulatorHost}:${AppConfig.functionsEmulatorPort}',
      );
    }

    TalkerService.info(
      'Stripe initialized with key: ${publishableKey.substring(0, 20)}...',
    );
  }

  /// Call Firebase Cloud Function
  Future<Map<String, dynamic>> _callFunction(
    String name,
    Map<String, dynamic> data,
  ) async {
    try {
      final callable = _functions.httpsCallable(name);
      final result = await callable.call<Map<String, dynamic>>(data);
      return result.data;
    } on FirebaseFunctionsException catch (e) {
      TalkerService.error('Firebase Functions error: ${e.code} - ${e.message}');
      throw StripePaymentException(
        e.message ?? 'Function call failed',
        code: e.code,
      );
    } catch (e) {
      TalkerService.error('Error calling function $name: $e');
      throw StripePaymentException('Failed to call function: $e');
    }
  }

  /// Create Payment Intent for ride booking
  /// Uses Firebase Cloud Functions for secure server-side processing
  ///
  /// [driverStripeAccountId] - Driver's Stripe Connect account ID (from Firestore)
  /// If null, payment goes to platform (driver can be paid manually later)
  Future<Map<String, dynamic>> createPaymentIntent({
    required String rideId,
    required String riderId,
    required String riderName,
    required String driverId,
    required String driverName,
    required double amount, // Total amount in main currency unit (e.g., euros)
    required String currency,
    String? customerId,
    String? existingCustomerId,
    String? driverStripeAccountId,
    String? description,
  }) async {
    try {
      final response = await _callFunction('createPaymentIntent', {
        'rideId': rideId,
        'riderId': riderId,
        'riderName': riderName,
        'driverId': driverId,
        'driverName': driverName,
        'amount': amount,
        'currency': currency.toLowerCase(),
        'customerId': customerId ?? existingCustomerId,
        'driverStripeAccountId': driverStripeAccountId,
        'description': description,
      });

      return response;
    } catch (e) {
      TalkerService.error('Error creating payment intent: $e');
      if (e is StripePaymentException) rethrow;
      throw StripePaymentException('Failed to create payment: $e');
    }
  }

  /// Process payment using Payment Sheet (Recommended for mobile)
  ///
  /// Uses Stripe's conversion-optimized Payment Sheet UI which supports
  /// saved cards, Apple Pay, Google Pay, and localized payment methods.
  ///
  /// [currency] - ISO 4217 currency code (e.g. 'eur', 'usd') for Google Pay
  Future<bool> processPaymentWithSheet({
    required String paymentIntentClientSecret,
    required String customerId,
    String? ephemeralKeySecret,
    String currency = 'eur',
    String merchantCountryCode = 'FR',
  }) async {
    // P-5: Guard against empty/null clientSecret before touching the Stripe SDK,
    // which would throw a cryptic internal exception.
    if (paymentIntentClientSecret.isEmpty) {
      throw ArgumentError(
        'paymentIntentClientSecret must not be empty. '
        'The payment intent may have failed to create.',
      );
    }

    try {
      final currencyUpper = currency.toUpperCase();

      // Initialize Payment Sheet with branded appearance
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentClientSecret,
          merchantDisplayName: 'SportConnect',
          customerId: customerId,
          customerEphemeralKeySecret: ephemeralKeySecret,
          // Apple Pay — shown automatically on iOS when device has a card
          // applePay: PaymentSheetApplePay(
          //   merchantCountryCode: merchantCountryCode,
          // ),
          // Google Pay — shown automatically on Android when device has a card
          googlePay: PaymentSheetGooglePay(
            merchantCountryCode: merchantCountryCode,
            currencyCode: currencyUpper,
            testEnv: kDebugMode,
          ),
          // Allow SEPA direct debit and other delayed payment methods
          allowsDelayedPaymentMethods: true,
          // Collect billing details for fraud prevention
          billingDetailsCollectionConfiguration:
              const BillingDetailsCollectionConfiguration(
            name: CollectionMode.automatic,
            email: CollectionMode.never,
            phone: CollectionMode.never,
            address: AddressCollectionMode.never,
          ),
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: const Color(0xFF1E88E5),
              background: const Color(0xFFF8FAFF),
              componentBackground: const Color(0xFFFFFFFF),
              componentBorder: const Color(0xFFE0E7FF),
              componentText: const Color(0xFF1A1A2E),
              primaryText: const Color(0xFF1A1A2E),
              secondaryText: const Color(0xFF6B7280),
              placeholderText: const Color(0xFF9CA3AF),
              icon: const Color(0xFF1E88E5),
              error: const Color(0xFFEF4444),
            ),
            shapes: const PaymentSheetShape(
              borderRadius: 12,
              borderWidth: 1.5,
              shadow: PaymentSheetShadowParams(opacity: 0.04),
            ),
            primaryButton: const PaymentSheetPrimaryButtonAppearance(
              shapes: PaymentSheetPrimaryButtonShape(blurRadius: 0),
              colors: PaymentSheetPrimaryButtonTheme(
                light: PaymentSheetPrimaryButtonThemeColors(
                  background: Color(0xFF1E88E5),
                  text: Color(0xFFFFFFFF),
                  border: Color(0xFF1E88E5),
                ),
              ),
            ),
          ),
        ),
      );

      // Present Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      TalkerService.info('Payment successful');
      return true;
    } on StripeException catch (e) {
      final msg = e.error.localizedMessage ?? '';
      // User deliberately dismissed the sheet — not an error
      if (e.error.code == FailureCode.Canceled) {
        return false;
      }
      TalkerService.error('Stripe error: $msg');
      throw StripePaymentException(msg.isNotEmpty ? msg : 'Payment failed');
    } catch (e) {
      TalkerService.error('Payment error: $e');
      throw StripePaymentException('Payment processing failed');
    }
  }

  /// Create or retrieve Stripe customer
  /// Uses Firebase Cloud Functions
  ///
  /// [existingCustomerId] - If user already has a customer ID in Firestore, pass it here
  Future<Map<String, dynamic>> getOrCreateCustomer({
    required String userId,
    required String email,
    String? name,
    String? phone,
    String? existingCustomerId,
  }) async {
    try {
      final response = await _callFunction('getOrCreateCustomer', {
        'email': email,
        'name': name,
        'phone': phone,
        'existingCustomerId': existingCustomerId,
      });

      return response;
    } catch (e) {
      TalkerService.error('Error creating/getting customer: $e');
      if (e is StripePaymentException) rethrow;
      throw StripePaymentException('Failed to create customer: $e');
    }
  }

  /// Create Connected Account for driver (Stripe Connect)
  /// Uses Firebase Cloud Functions - Express accounts for easy onboarding
  ///
  /// Prefills individual info (name, phone, DOB, address) from user profile
  /// to reduce onboarding friction. Stripe won't ask for prefilled fields.
  Future<Map<String, dynamic>> createDriverConnectedAccount({
    required String userId,
    required String email,
    required String country, // ISO country code (e.g., 'US', 'FR', 'TN')
    String? firstName,
    String? lastName,
    String? phone,
    DateTime? dateOfBirth,
    String? addressLine1,
    String? city,
  }) async {
    try {
      final response = await _callFunction('createConnectedAccount', {
        'userId': userId,
        'email': email,
        'country': country,
        'firstName': ?firstName,
        'lastName': ?lastName,
        'phone': ?phone,
        if (dateOfBirth != null) 'dateOfBirth': dateOfBirth.toIso8601String(),
        'addressLine1': ?addressLine1,
        'city': ?city,
      });

      return response;
    } catch (e) {
      TalkerService.error('Error creating connected account: $e');
      if (e is StripePaymentException) rethrow;
      throw StripePaymentException('Failed to create account: $e');
    }
  }

  /// Create Account Onboarding Link
  /// Uses Firebase Cloud Functions
  Future<Map<String, dynamic>> createAccountLink({
    required String accountId,
    required String refreshUrl,
    required String returnUrl,
  }) async {
    try {
      final response = await _callFunction('createAccountLink', {
        'accountId': accountId,
        'refreshUrl': refreshUrl,
        'returnUrl': returnUrl,
      });

      return response;
    } catch (e) {
      TalkerService.error('Error creating account link: $e');
      if (e is StripePaymentException) rethrow;
      throw StripePaymentException('Failed to create account link: $e');
    }
  }

  /// Get Connected Account Status
  /// Uses Firebase Cloud Functions
  Future<Map<String, dynamic>> getAccountStatus({
    required String accountId,
  }) async {
    try {
      final response = await _callFunction('getAccountStatus', {
        'accountId': accountId,
      });

      return response;
    } catch (e) {
      TalkerService.error('Error getting account status: $e');
      if (e is StripePaymentException) rethrow;
      throw StripePaymentException('Failed to get account status: $e');
    }
  }

  /// Sync driver's Stripe balance to Firestore
  Future<Map<String, dynamic>> syncDriverBalance() async {
    try {
      final response = await _callFunction('syncDriverBalance', {});
      return response;
    } catch (e) {
      TalkerService.error('Error syncing balance: $e');
      if (e is StripePaymentException) rethrow;
      throw StripePaymentException('Failed to sync balance: $e');
    }
  }

  /// Create instant payout to driver's debit card
  /// Uses Firebase Cloud Functions
  ///
  /// [stripeAccountId] - Driver's Stripe Connect account ID (from Firestore)
  /// [amount] - Amount in main currency unit (e.g., euros). Server converts to cents.
  Future<Map<String, dynamic>> createInstantPayout({
    required String stripeAccountId,
    required double amount,
    required String currency,
  }) async {
    try {
      final response = await _callFunction('createInstantPayout', {
        'stripeAccountId': stripeAccountId,
        'amount': amount,
        'currency': currency.toLowerCase(),
      });

      return response;
    } catch (e) {
      TalkerService.error('Error creating instant payout: $e');
      if (e is StripePaymentException) rethrow;
      throw StripePaymentException('Payout failed: $e');
    }
  }

  /// Refund payment (for cancellations)
  /// Uses Firebase Cloud Functions
  Future<Map<String, dynamic>> refundPayment({
    required String paymentIntentId,
    double? amount, // If null, full refund
    String? reason,
  }) async {
    try {
      final response = await _callFunction('refundPayment', {
        'paymentIntentId': paymentIntentId,
        'amount': ?amount,
        'reason': reason ?? 'requested_by_customer',
      });

      return response;
    } catch (e) {
      TalkerService.error('Error processing refund: $e');
      if (e is StripePaymentException) rethrow;
      throw StripePaymentException('Refund failed: $e');
    }
  }

  /// Calculate platform fees (client-side preview)
  Map<String, double> calculateFees({
    required double totalAmount,
    double platformFeePercent = 15.0,
    double stripeFeePercent = 2.9,
    double stripeFixedFee = 0.30,
  }) {
    final platformFee = totalAmount * (platformFeePercent / 100);
    final stripeFee = (totalAmount * (stripeFeePercent / 100)) + stripeFixedFee;
    final driverEarnings = totalAmount - platformFee - stripeFee;

    return {
      'totalAmount': totalAmount,
      'platformFee': platformFee,
      'stripeFee': stripeFee,
      'driverEarnings': driverEarnings,
    };
  }

  /// Check if service is properly initialized
  bool get isInitialized => Stripe.publishableKey.isNotEmpty;
}

/// Custom exception for Stripe payment errors
class StripePaymentException implements Exception {
  final String message;
  final String? code;

  StripePaymentException(this.message, {this.code});

  @override
  String toString() => code != null ? '[$code] $message' : message;
}
