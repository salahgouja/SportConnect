import 'dart:ui';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/config/app_config.dart';
import 'package:sport_connect/core/services/talker_service.dart';

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
  factory StripeService() => _instance;

  StripeService._internal() : _functions = FirebaseFunctions.instance;

  static final StripeService _instance = StripeService._internal();

  final FirebaseFunctions _functions;

  Future<Map<String, dynamic>> getAccountStatus({
    required String accountId,
  }) async {
    final result = await _functions.httpsCallable('getAccountStatus').call({
      'accountId': accountId,
    });

    return Map<String, dynamic>.from(result.data as Map);
  }

  Future<void> syncDriverBalance() async {
    await _functions.httpsCallable('syncDriverBalance').call();
  }

  /// Initialize Stripe with publishable key
  Future<void> initialize({required String publishableKey}) async {
    Stripe.publishableKey = publishableKey;
    await Stripe.instance.applySettings();

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
    } catch (e, st) {
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
    required int amountInCents,
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
        'amountInCents': amountInCents,
        'currency': currency.toLowerCase(),
        'customerId': customerId ?? existingCustomerId,
        'driverStripeAccountId': driverStripeAccountId,
        'description': description,
      });

      return response;
    } catch (e, st) {
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
  /// [currency] - ISO 4217 currency code for Google Pay
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
          //   buttonType: PlatformButtonType.book,
          // ),
          // Google Pay — shown automatically on Android when device has a card
          googlePay: PaymentSheetGooglePay(
            merchantCountryCode: merchantCountryCode,
            currencyCode: currencyUpper,
            testEnv: kDebugMode,
            buttonType: PlatformButtonType.book,
          ),
          returnURL: 'flutterstripe://redirect',
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
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Color(0xFF1E88E5),
              background: Color(0xFFF8FAFF),
              componentBackground: Color(0xFFFFFFFF),
              componentBorder: Color(0xFFE0E7FF),
              componentText: Color(0xFF1A1A2E),
              primaryText: Color(0xFF1A1A2E),
              secondaryText: Color(0xFF6B7280),
              placeholderText: Color(0xFF9CA3AF),
              icon: Color(0xFF1E88E5),
              error: Color(0xFFEF4444),
            ),
            shapes: PaymentSheetShape(
              borderRadius: 12,
              borderWidth: 1.5,
              shadow: PaymentSheetShadowParams(opacity: 0.04),
            ),
            primaryButton: PaymentSheetPrimaryButtonAppearance(
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
    } catch (e, st) {
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
    } catch (e, st) {
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
    } catch (e, st) {
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
    } catch (e, st) {
      TalkerService.error('Error creating account link: $e');
      if (e is StripePaymentException) rethrow;
      throw StripePaymentException('Failed to create account link: $e');
    }
  }

  /// Create instant payout to driver's debit card
  /// Uses Firebase Cloud Functions
  ///
  /// [stripeAccountId] - Driver's Stripe Connect account ID (from Firestore)
  /// [amountInCents] - Amount in cents (e.g., 100 = 1.00 EUR)
  Future<Map<String, dynamic>> createInstantPayout({
    required String stripeAccountId,
    required int amountInCents,
    required String currency,
  }) async {
    try {
      final response = await _callFunction('createInstantPayout', {
        'stripeAccountId': stripeAccountId,
        'amountInCents': amountInCents,
        'currency': currency.toLowerCase(),
      });

      return response;
    } catch (e, st) {
      TalkerService.error('Error creating instant payout: $e');
      if (e is StripePaymentException) rethrow;
      throw StripePaymentException('Payout failed: $e');
    }
  }

  /// Refund payment (for cancellations)
  /// Uses Firebase Cloud Functions
  Future<Map<String, dynamic>> refundPayment({
    required String paymentIntentId,
    int? amountInCents, // If null, full refund
    String? reason,
  }) async {
    try {
      final response = await _callFunction('refundPayment', {
        'paymentIntentId': paymentIntentId,
        'amountInCents': amountInCents,
        'reason': reason ?? 'requested_by_customer',
      });

      return response;
    } catch (e, st) {
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

  // ── Customer Sheet (beta) ─────────────────────────────────

  /// Fetch SetupIntent + EphemeralKey from Cloud Function
  Future<Map<String, dynamic>> _createCustomerSheetSetup() async {
    return _callFunction('createCustomerSheetSetup', {});
  }

  /// Initialize and present the Customer Sheet for managing saved payment methods.
  ///
  /// Returns the selected payment option (brand + last4), or null if dismissed.
  Future<CustomerSheetResult?> presentCustomerSheet() async {
    final setup = await _createCustomerSheetSetup();
    final setupIntentClientSecret = setup['setupIntentClientSecret'] as String;
    final customerId = setup['customerId'] as String;
    final ephemeralKeySecret = setup['ephemeralKeySecret'] as String;

    await Stripe.instance.initCustomerSheet(
      customerSheetInitParams: CustomerSheetInitParams.adapter(
        setupIntentClientSecret: setupIntentClientSecret,
        merchantDisplayName: 'SportConnect',
        customerId: customerId,
        customerEphemeralKeySecret: ephemeralKeySecret,
        returnURL: 'flutterstripe://redirect',
        billingDetailsCollectionConfiguration:
            const BillingDetailsCollectionConfiguration(
              name: CollectionMode.automatic,
              email: CollectionMode.never,
              phone: CollectionMode.never,
              address: AddressCollectionMode.never,
            ),
        appearance: const PaymentSheetAppearance(
          colors: PaymentSheetAppearanceColors(
            primary: Color(0xFF40916C),
            background: Color(0xFFF8FAF9),
            componentBackground: Color(0xFFFFFFFF),
            componentBorder: Color(0xFFD8E4DD),
            componentText: Color(0xFF1B2E24),
            primaryText: Color(0xFF1B2E24),
            secondaryText: Color(0xFF6B7280),
            placeholderText: Color(0xFF9CA3AF),
            icon: Color(0xFF40916C),
            error: Color(0xFFC1666B),
          ),
          shapes: PaymentSheetShape(
            borderRadius: 12,
            borderWidth: 1.5,
            shadow: PaymentSheetShadowParams(opacity: 0.04),
          ),
          primaryButton: PaymentSheetPrimaryButtonAppearance(
            shapes: PaymentSheetPrimaryButtonShape(blurRadius: 0),
            colors: PaymentSheetPrimaryButtonTheme(
              light: PaymentSheetPrimaryButtonThemeColors(
                background: Color(0xFF40916C),
                text: Color(0xFFFFFFFF),
                border: Color(0xFF40916C),
              ),
            ),
          ),
        ),
      ),
    );

    final result = await Stripe.instance.presentCustomerSheet();
    return result;
  }
}

/// Custom exception for Stripe payment errors
class StripePaymentException implements Exception {
  StripePaymentException(this.message, {this.code});
  final String message;
  final String? code;

  @override
  String toString() => code != null ? '[$code] $message' : message;
}
