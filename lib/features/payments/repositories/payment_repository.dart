import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/interfaces/repositories/i_payment_repository.dart';
import 'package:sport_connect/core/services/stripe_service.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/features/payments/models/payment_model.dart';

/// Payment Repository for Firestore operations
class PaymentRepository implements IPaymentRepository {
  final FirebaseFirestore _firestore;
  final StripeService _stripeService;

  PaymentRepository(this._firestore, this._stripeService);

  CollectionReference<PaymentTransaction> get _paymentsCollection => _firestore
      .collection(AppConstants.paymentsCollection)
      .withConverter<PaymentTransaction>(
        fromFirestore: (snap, _) =>
            PaymentTransaction.fromJson({...snap.data()!, 'id': snap.id}),
        toFirestore: (payment, _) => payment.toJson(),
      );

  CollectionReference<DriverPayout> get _payoutsCollection => _firestore
      .collection(AppConstants.payoutsCollection)
      .withConverter<DriverPayout>(
        fromFirestore: (snap, _) =>
            DriverPayout.fromJson({...snap.data()!, 'id': snap.id}),
        toFirestore: (payout, _) => payout.toJson(),
      );

  CollectionReference<DriverConnectedAccount>
  get _connectedAccountsCollection => _firestore
      .collection(AppConstants.connectedAccountsCollection)
      .withConverter<DriverConnectedAccount>(
        fromFirestore: (snap, _) => DriverConnectedAccount.fromJson({
          ...snap.data()!,
          'driverId': snap.id,
        }),
        toFirestore: (account, _) => account.toJson(),
      );

  /// Create payment transaction record
  @override
  Future<String> createPaymentTransaction(PaymentTransaction payment) async {
    try {
      final docRef = _paymentsCollection.doc();
      final paymentWithId = payment.copyWith(
        id: docRef.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await docRef.set(paymentWithId);
      TalkerService.info('Payment transaction created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      TalkerService.error('Error creating payment transaction: $e');
      rethrow;
    }
  }

  /// Update payment transaction status
  @override
  Future<void> updatePaymentStatus({
    required String paymentId,
    required PaymentStatus status,
    String? failureReason,
    DateTime? completedAt,
  }) async {
    try {
      await _paymentsCollection.doc(paymentId).update({
        'status': status.name,
        'updatedAt': DateTime.now(),
        'failureReason': ?failureReason,
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
  @override
  Future<PaymentTransaction?> getPaymentById(String paymentId) async {
    try {
      final doc = await _paymentsCollection.doc(paymentId).get();
      if (!doc.exists) return null;

      return doc.data();
    } catch (e) {
      TalkerService.error('Error getting payment: $e');
      rethrow;
    }
  }

  /// Get payments by ride
  @override
  Future<List<PaymentTransaction>> getPaymentsByRide(String rideId) async {
    try {
      final snapshot = await _paymentsCollection
          .where('rideId', isEqualTo: rideId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      TalkerService.error('Error getting payments by ride: $e');
      rethrow;
    }
  }

  /// Get rider's payment history
  @override
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

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      TalkerService.error('Error getting rider payment history: $e');
      rethrow;
    }
  }

  /// Stream rider's payment history
  @override
  Stream<List<PaymentTransaction>> streamRiderPaymentHistory({
    required String riderId,
    int limit = 20,
  }) {
    return _paymentsCollection
        .where('riderId', isEqualTo: riderId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Get driver's earnings transactions
  @override
  Future<List<PaymentTransaction>> getDriverEarnings({
    required String driverId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    try {
      Query<PaymentTransaction> query = _paymentsCollection
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

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      TalkerService.error('Error getting driver earnings: $e');
      rethrow;
    }
  }

  /// Calculate earnings summary for driver
  @override
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

      final payments = allPayments.docs.map((doc) => doc.data()).toList();

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
        final lastPayout = payoutsSnapshot.docs.first.data();
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
  @override
  Future<String> createPayout(DriverPayout payout) async {
    try {
      final docRef = _payoutsCollection.doc();
      final payoutWithId = payout.copyWith(
        id: docRef.id,
        createdAt: DateTime.now(),
      );

      await docRef.set(payoutWithId);
      TalkerService.info('Payout created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      TalkerService.error('Error creating payout: $e');
      rethrow;
    }
  }

  /// Update payout status
  @override
  Future<void> updatePayoutStatus({
    required String payoutId,
    required PayoutStatus status,
    String? failureReason,
    DateTime? arrivedAt,
  }) async {
    try {
      await _payoutsCollection.doc(payoutId).update({
        'status': status.name,
        'failureReason': failureReason,
        if (arrivedAt != null) 'arrivedAt': Timestamp.fromDate(arrivedAt),
      });

      TalkerService.info('Payout status updated: $payoutId -> ${status.name}');
    } catch (e) {
      TalkerService.error('Error updating payout status: $e');
      rethrow;
    }
  }

  /// Get driver payouts
  @override
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

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      TalkerService.error('Error getting driver payouts: $e');
      rethrow;
    }
  }

  /// Save driver connected account
  @override
  Future<void> saveConnectedAccount(DriverConnectedAccount account) async {
    try {
      await _connectedAccountsCollection
          .doc(account.driverId)
          .set(
            account.copyWith(
              createdAt: account.createdAt ?? DateTime.now(),
              updatedAt: DateTime.now(),
            ),
            SetOptions(merge: true),
          );

      TalkerService.info('Connected account saved: ${account.driverId}');
    } catch (e) {
      TalkerService.error('Error saving connected account: $e');
      rethrow;
    }
  }

  /// Get driver connected account
  @override
  Future<DriverConnectedAccount?> getConnectedAccount(String driverId) async {
    try {
      final doc = await _connectedAccountsCollection.doc(driverId).get();
      if (!doc.exists) return null;

      return doc.data();
    } catch (e) {
      TalkerService.error('Error getting connected account: $e');
      rethrow;
    }
  }

  /// Update connected account status
  @override
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
        'updatedAt': DateTime.now(),
        if (chargesEnabled && payoutsEnabled && detailsSubmitted)
          'onboardingCompletedAt': DateTime.now(),
      });

      TalkerService.info('Connected account status updated: $driverId');
    } catch (e) {
      TalkerService.error('Error updating connected account status: $e');
      rethrow;
    }
  }

  /// Process refund
  @override
  Future<void> processRefund({
    required String paymentId,
    double? amount,
    String? reason,
  }) async {
    try {
      final payment = await getPaymentById(paymentId);
      if (payment == null) throw Exception('Payment not found');

      // Call Stripe service to process refund
      // The Cloud Function also updates the Firestore payment record
      // (status, refundedAt, refundReason) — no client-side update needed
      await _stripeService.refundPayment(
        paymentIntentId: payment.stripePaymentIntentId!,
        amount: amount,
        reason: reason,
      );

      TalkerService.info('Refund processed: $paymentId');
    } catch (e) {
      TalkerService.error('Error processing refund: $e');
      rethrow;
    }
  }

  /// Get payout by ID
  @override
  Future<DriverPayout?> getPayoutById(String payoutId) async {
    try {
      final doc = await _payoutsCollection.doc(payoutId).get();
      if (!doc.exists) return null;
      return doc.data();
    } catch (e) {
      TalkerService.error('Error getting payout: $e');
      rethrow;
    }
  }

  /// Create driver connected account via Stripe and persist it to Firestore.
  @override
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
    try {
      final result = await _stripeService.createDriverConnectedAccount(
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

      if (result['accountId'] == null) return null;

      final account = DriverConnectedAccount(
        id: result['accountId'] as String,
        driverId: userId,
        stripeAccountId: result['accountId'] as String,
        email: email,
        country: country,
        chargesEnabled: false,
        payoutsEnabled: false,
        detailsSubmitted: false,
        onboardingCompleted: false,
        onboardingUrl: result['onboardingUrl'] as String?,
      );

      await saveConnectedAccount(account);
      TalkerService.info('Connected account created: $userId');
      return account;
    } catch (e) {
      TalkerService.error('Error creating connected account: $e');
      rethrow;
    }
  }
}
