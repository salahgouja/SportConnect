import 'package:sport_connect/features/payments/models/payment_model.dart';

/// Payment Repository for Firestore operations
abstract class IPaymentRepository {
  /// Create payment transaction record
  Future<String> createPaymentTransaction(PaymentTransaction payment);

  /// Update payment transaction status
  Future<void> updatePaymentStatus({
    required String paymentId,
    required PaymentStatus status,
    String? failureReason,
    DateTime? completedAt,
  });

  /// Get payment transaction by ID
  Future<PaymentTransaction?> getPaymentById(String paymentId);

  /// Get payments by ride
  Future<List<PaymentTransaction>> getPaymentsByRide(String rideId);

  /// Get rider's payment history
  Future<List<PaymentTransaction>> getRiderPaymentHistory({
    required String riderId,
    int limit = 20,
  });

  /// Stream rider's payment history
  Stream<List<PaymentTransaction>> streamRiderPaymentHistory({
    required String riderId,
    int limit = 20,
  });

  /// Get driver's earnings transactions
  Future<List<PaymentTransaction>> getDriverEarnings({
    required String driverId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  });

  /// Calculate earnings summary for driver
  Future<EarningsSummary> calculateEarningsSummary(String driverId);

  /// Create payout record
  Future<String> createPayout(DriverPayout payout);

  /// Update payout status
  Future<void> updatePayoutStatus({
    required String payoutId,
    required PayoutStatus status,
    String? failureReason,
    DateTime? arrivedAt,
  });

  /// Get driver payouts
  Future<List<DriverPayout>> getDriverPayouts({
    required String driverId,
    int limit = 20,
  });

  /// Save driver connected account
  Future<void> saveConnectedAccount(DriverConnectedAccount account);

  /// Get driver connected account
  Future<DriverConnectedAccount?> getConnectedAccount(String driverId);

  /// Get current driver's connected account (uses Firebase Auth)
  Future<DriverConnectedAccount?> getCurrentDriverConnectedAccount();

  /// Update connected account status
  Future<void> updateConnectedAccountStatus({
    required String driverId,
    required bool chargesEnabled,
    required bool payoutsEnabled,
    required bool detailsSubmitted,
  });

  /// Process refund
  Future<void> processRefund({
    required String paymentId,
    double? amount,
    String? reason,
  });
}
