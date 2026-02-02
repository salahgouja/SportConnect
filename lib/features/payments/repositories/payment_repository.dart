import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/services/stripe_service.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/features/payments/models/payment_model.dart';

part 'payment_repository.g.dart';

/// Payment Repository for Firestore operations
class PaymentRepository {
  final FirebaseFirestore _firestore;
  final StripeService _stripeService;

  PaymentRepository(this._firestore, this._stripeService);

  // Collection references
  CollectionReference<Map<String, dynamic>> get _paymentsCollection =>
      _firestore.collection('payments');

  CollectionReference<Map<String, dynamic>> get _payoutsCollection =>
      _firestore.collection('payouts');

  CollectionReference<Map<String, dynamic>> get _connectedAccountsCollection =>
      _firestore.collection('driver_connected_accounts');

  /// Create payment transaction record
  Future<String> createPaymentTransaction(PaymentTransaction payment) async {
    try {
      final docRef = _paymentsCollection.doc();
      final paymentWithId = payment.copyWith(
        id: docRef.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await docRef.set(paymentWithId.toJson());
      TalkerService.info('Payment transaction created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      TalkerService.error('Error creating payment transaction: $e');
      rethrow;
    }
  }

  /// Update payment transaction status
  Future<void> updatePaymentStatus({
    required String paymentId,
    required PaymentStatus status,
    String? failureReason,
    DateTime? completedAt,
  }) async {
    try {
      await _paymentsCollection.doc(paymentId).update({
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
        if (failureReason != null) 'failureReason': failureReason,
        if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt),
      });

      TalkerService.info(
        'Payment status updated: $paymentId -> ${status.name}',
      );
    } catch (e) {
      TalkerService.error('Error updating payment status: $e');
      rethrow;
    }
  }

  /// Get payment transaction by ID
  Future<PaymentTransaction?> getPaymentById(String paymentId) async {
    try {
      final doc = await _paymentsCollection.doc(paymentId).get();
      if (!doc.exists) return null;

      return PaymentTransaction.fromJson(doc.data()!);
    } catch (e) {
      TalkerService.error('Error getting payment: $e');
      rethrow;
    }
  }

  /// Get payments by ride
  Future<List<PaymentTransaction>> getPaymentsByRide(String rideId) async {
    try {
      final snapshot = await _paymentsCollection
          .where('rideId', isEqualTo: rideId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => PaymentTransaction.fromJson(doc.data()))
          .toList();
    } catch (e) {
      TalkerService.error('Error getting payments by ride: $e');
      rethrow;
    }
  }

  /// Get rider's payment history
  Future<List<PaymentTransaction>> getRiderPaymentHistory({
    required String riderId,
    int limit = 20,
  }) async {
    try {
      final snapshot = await _paymentsCollection
          .where('riderId', isEqualTo: riderId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => PaymentTransaction.fromJson(doc.data()))
          .toList();
    } catch (e) {
      TalkerService.error('Error getting rider payment history: $e');
      rethrow;
    }
  }

  /// Stream rider's payment history
  Stream<List<PaymentTransaction>> streamRiderPaymentHistory({
    required String riderId,
    int limit = 20,
  }) {
    return _paymentsCollection
        .where('riderId', isEqualTo: riderId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PaymentTransaction.fromJson(doc.data()))
              .toList(),
        );
  }

  /// Get driver's earnings transactions
  Future<List<PaymentTransaction>> getDriverEarnings({
    required String driverId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _paymentsCollection
          .where('driverId', isEqualTo: driverId)
          .where('status', isEqualTo: PaymentStatus.succeeded.name);

      if (startDate != null) {
        query = query.where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }
      if (endDate != null) {
        query = query.where(
          'createdAt',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      final snapshot = await query
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => PaymentTransaction.fromJson(doc.data()))
          .toList();
    } catch (e) {
      TalkerService.error('Error getting driver earnings: $e');
      rethrow;
    }
  }

  /// Calculate earnings summary for driver
  Future<EarningsSummary> calculateEarningsSummary(String driverId) async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final monthStart = DateTime(now.year, now.month, 1);
      final yearStart = DateTime(now.year, 1, 1);

      // Get all successful payments
      final allPayments = await _paymentsCollection
          .where('driverId', isEqualTo: driverId)
          .where('status', isEqualTo: PaymentStatus.succeeded.name)
          .get();

      final payments = allPayments.docs
          .map((doc) => PaymentTransaction.fromJson(doc.data()))
          .toList();

      // Calculate totals
      double totalEarnings = 0;
      double totalPlatformFees = 0;
      double totalStripeFees = 0;
      int totalRides = payments.length;

      double earningsToday = 0;
      double earningsThisWeek = 0;
      double earningsThisMonth = 0;
      double earningsThisYear = 0;

      int ridesToday = 0;
      int ridesThisWeek = 0;
      int ridesThisMonth = 0;

      DateTime? lastPayoutDate;

      for (var payment in payments) {
        totalEarnings += payment.driverEarnings;
        totalPlatformFees += payment.platformFee;
        totalStripeFees += payment.stripeFee;

        if (payment.completedAt != null) {
          if (payment.completedAt!.isAfter(todayStart)) {
            earningsToday += payment.driverEarnings;
            ridesToday++;
          }
          if (payment.completedAt!.isAfter(weekStart)) {
            earningsThisWeek += payment.driverEarnings;
            ridesThisWeek++;
          }
          if (payment.completedAt!.isAfter(monthStart)) {
            earningsThisMonth += payment.driverEarnings;
            ridesThisMonth++;
          }
          if (payment.completedAt!.isAfter(yearStart)) {
            earningsThisYear += payment.driverEarnings;
          }
        }
      }

      // Get payout info
      final payoutsSnapshot = await _payoutsCollection
          .where('driverId', isEqualTo: driverId)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (payoutsSnapshot.docs.isNotEmpty) {
        final lastPayout = DriverPayout.fromJson(
          payoutsSnapshot.docs.first.data(),
        );
        lastPayoutDate = lastPayout.arrivedAt;
      }

      return EarningsSummary(
        driverId: driverId,
        totalEarnings: totalEarnings,
        totalPlatformFees: totalPlatformFees,
        totalStripeFees: totalStripeFees,
        earningsToday: earningsToday,
        earningsThisWeek: earningsThisWeek,
        earningsThisMonth: earningsThisMonth,
        earningsThisYear: earningsThisYear,
        totalRidesCompleted: totalRides,
        ridesCompletedToday: ridesToday,
        ridesCompletedThisWeek: ridesThisWeek,
        ridesCompletedThisMonth: ridesThisMonth,
        lastUpdated: DateTime.now(),
        lastPayoutDate: lastPayoutDate,
      );
    } catch (e) {
      TalkerService.error('Error calculating earnings summary: $e');
      rethrow;
    }
  }

  /// Create payout record
  Future<String> createPayout(DriverPayout payout) async {
    try {
      final docRef = _payoutsCollection.doc();
      final payoutWithId = payout.copyWith(
        id: docRef.id,
        createdAt: DateTime.now(),
      );

      await docRef.set(payoutWithId.toJson());
      TalkerService.info('Payout created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      TalkerService.error('Error creating payout: $e');
      rethrow;
    }
  }

  /// Update payout status
  Future<void> updatePayoutStatus({
    required String payoutId,
    required PayoutStatus status,
    String? failureReason,
    DateTime? arrivedAt,
  }) async {
    try {
      await _payoutsCollection.doc(payoutId).update({
        'status': status.name,
        if (failureReason != null) 'failureReason': failureReason,
        if (arrivedAt != null) 'arrivedAt': Timestamp.fromDate(arrivedAt),
      });

      TalkerService.info('Payout status updated: $payoutId -> ${status.name}');
    } catch (e) {
      TalkerService.error('Error updating payout status: $e');
      rethrow;
    }
  }

  /// Get driver payouts
  Future<List<DriverPayout>> getDriverPayouts({
    required String driverId,
    int limit = 20,
  }) async {
    try {
      final snapshot = await _payoutsCollection
          .where('driverId', isEqualTo: driverId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => DriverPayout.fromJson(doc.data()))
          .toList();
    } catch (e) {
      TalkerService.error('Error getting driver payouts: $e');
      rethrow;
    }
  }

  /// Save driver connected account
  Future<void> saveConnectedAccount(DriverConnectedAccount account) async {
    try {
      await _connectedAccountsCollection
          .doc(account.driverId)
          .set(
            account
                .copyWith(
                  createdAt: account.createdAt ?? DateTime.now(),
                  updatedAt: DateTime.now(),
                )
                .toJson(),
            SetOptions(merge: true),
          );

      TalkerService.info('Connected account saved: ${account.driverId}');
    } catch (e) {
      TalkerService.error('Error saving connected account: $e');
      rethrow;
    }
  }

  /// Get driver connected account
  Future<DriverConnectedAccount?> getConnectedAccount(String driverId) async {
    try {
      final doc = await _connectedAccountsCollection.doc(driverId).get();
      if (!doc.exists) return null;

      return DriverConnectedAccount.fromJson(doc.data()!);
    } catch (e) {
      TalkerService.error('Error getting connected account: $e');
      rethrow;
    }
  }

  /// Get current driver's connected account (uses Firebase Auth)
  Future<DriverConnectedAccount?> getCurrentDriverConnectedAccount() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return null;

      return getConnectedAccount(currentUser.uid);
    } catch (e) {
      TalkerService.error('Error getting current driver connected account: $e');
      rethrow;
    }
  }

  /// Update connected account status
  Future<void> updateConnectedAccountStatus({
    required String driverId,
    required bool chargesEnabled,
    required bool payoutsEnabled,
    required bool detailsSubmitted,
  }) async {
    try {
      await _connectedAccountsCollection.doc(driverId).update({
        'chargesEnabled': chargesEnabled,
        'payoutsEnabled': payoutsEnabled,
        'detailsSubmitted': detailsSubmitted,
        'onboardingCompleted':
            chargesEnabled && payoutsEnabled && detailsSubmitted,
        'updatedAt': FieldValue.serverTimestamp(),
        if (chargesEnabled && payoutsEnabled && detailsSubmitted)
          'onboardingCompletedAt': FieldValue.serverTimestamp(),
      });

      TalkerService.info('Connected account status updated: $driverId');
    } catch (e) {
      TalkerService.error('Error updating connected account status: $e');
      rethrow;
    }
  }

  /// Process refund
  Future<void> processRefund({
    required String paymentId,
    double? amount,
    String? reason,
  }) async {
    try {
      final payment = await getPaymentById(paymentId);
      if (payment == null) throw Exception('Payment not found');

      // Call Stripe service to process refund
      await _stripeService.refundPayment(
        paymentIntentId: payment.stripePaymentIntentId!,
        amount: amount,
        reason: reason,
      );

      // Update payment record
      await _paymentsCollection.doc(paymentId).update({
        'status': amount == null || amount == payment.amount
            ? PaymentStatus.refunded.name
            : PaymentStatus.partiallyRefunded.name,
        'refundedAt': FieldValue.serverTimestamp(),
        'refundReason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      TalkerService.info('Refund processed: $paymentId');
    } catch (e) {
      TalkerService.error('Error processing refund: $e');
      rethrow;
    }
  }
}

/// Payment Repository Provider
@riverpod
PaymentRepository paymentRepository(Ref ref) {
  return PaymentRepository(FirebaseFirestore.instance, StripeService());
}
