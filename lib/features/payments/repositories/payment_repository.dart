import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/interfaces/repositories/i_payment_repository.dart';
import 'package:sport_connect/core/services/stripe_service.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/features/payments/models/payment_model.dart';

/// Payment Repository for Firestore operations
class PaymentRepository implements IPaymentRepository {
  PaymentRepository(this._firestore, this._stripeService);
  final FirebaseFirestore _firestore;
  final StripeService _stripeService;

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
    } on Exception catch (e) {
      TalkerService.error('Error creating payment transaction: $e');
      rethrow;
    }
  }

  // FIX P-1: Valid payment state transitions.
  static const _validTransitions = <String, Set<String>>{
    'pending': {'processing', 'failed'},
    'processing': {'succeeded', 'failed'},
    'succeeded': {'refunded', 'partiallyRefunded'},
    'failed': {},
    'refunded': {},
    'partiallyRefunded': {'refunded'},
    'refunding': {'refunded', 'failed'},
  };

  /// Update payment transaction status — enforces valid state machine.
  @override
  Future<void> updatePaymentStatus({
    required String paymentId,
    required PaymentStatus status,
    String? failureReason,
    DateTime? completedAt,
  }) async {
    try {
      // FIX P-1: Read current status first and reject invalid transitions.
      final current = await _paymentsCollection.doc(paymentId).get();
      if (current.exists) {
        final currentStatus = current.data()!.status.name;
        final allowed = _validTransitions[currentStatus] ?? {};
        if (!allowed.contains(status.name)) {
          throw StateError(
            'Invalid payment transition: $currentStatus → ${status.name}',
          );
        }
      }

      await _paymentsCollection.doc(paymentId).update({
        'status': status.name,
        'updatedAt': DateTime.now(),
        'failureReason': ?failureReason,
        if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt),
      });

      TalkerService.info(
        'Payment status updated: $paymentId -> ${status.name}',
      );
    } on Exception catch (e) {
      TalkerService.error('Error updating payment status: $e');
      rethrow;
    }
  }

  /// Get payment transaction by Firestore document ID or Stripe paymentIntentId.
  ///
  /// The Cloud Function creates payment docs with `.add()` (auto-generated Firestore
  /// ID), so [paymentId] may be either the Firestore doc ID or the Stripe
  /// paymentIntentId (pi_xxx). We try the doc lookup first (fast path), then
  /// fall back to a field query.
  @override
  Future<PaymentTransaction?> getPaymentById(String paymentId) async {
    try {
      // Fast path: try direct document lookup (works if caller has Firestore ID)
      final doc = await _paymentsCollection.doc(paymentId).get();
      if (doc.exists) return doc.data();

      // Fallback: query by Stripe paymentIntentId field (pi_xxx)
      final snapshot = await _paymentsCollection
          .where('paymentIntentId', isEqualTo: paymentId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return snapshot.docs.first.data();
    } on Exception catch (e) {
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
    } on Exception catch (e) {
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
    } on Exception catch (e) {
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
      var query = _paymentsCollection
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
    } on Exception catch (e) {
      TalkerService.error('Error getting driver earnings: $e');
      rethrow;
    }
  }

  /// Calculate earnings summary for driver.
  ///
  /// P-2: Uses the pre-computed `driver_stats` document as a fast path.
  /// Cloud Functions `recomputeDriverStats` keeps it up to date after every
  /// payment success and every refund.  Falls back to a full payments scan
  /// only when the doc doesn't exist yet (first-time / cold-start scenario).
  @override
  Future<EarningsSummary> calculateEarningsSummary(String driverId) async {
    try {
      // Fast path: read the pre-aggregated driver_stats document.
      final statsDoc = await _firestore
          .collection(AppConstants.driverStatsCollection)
          .doc(driverId)
          .get();

      // Always fetch payout info — it's a single bounded query.
      final payoutsSnapshot = await _payoutsCollection
          .where('driverId', isEqualTo: driverId)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      DateTime? lastPayoutDate;
      if (payoutsSnapshot.docs.isNotEmpty) {
        lastPayoutDate = payoutsSnapshot.docs.first.data().arrivedAt;
      }

      if (statsDoc.exists) {
        final data = statsDoc.data()!;
        TalkerService.info(
          'calculateEarningsSummary: using driver_stats fast path for $driverId',
        );
        return EarningsSummary(
          driverId: driverId,
          totalEarnings: (data['totalEarnings'] as num?)?.toDouble() ?? 0.0,
          totalPlatformFees:
              (data['totalPlatformFees'] as num?)?.toDouble() ?? 0.0,
          totalStripeFees: (data['totalStripeFees'] as num?)?.toDouble() ?? 0.0,
          earningsToday: (data['earningsToday'] as num?)?.toDouble() ?? 0.0,
          earningsThisWeek:
              (data['earningsThisWeek'] as num?)?.toDouble() ?? 0.0,
          earningsThisMonth:
              (data['earningsThisMonth'] as num?)?.toDouble() ?? 0.0,
          earningsThisYear:
              (data['earningsThisYear'] as num?)?.toDouble() ?? 0.0,
          totalRidesCompleted: (data['totalRides'] as num?)?.toInt() ?? 0,
          ridesCompletedToday: (data['ridesToday'] as num?)?.toInt() ?? 0,
          ridesCompletedThisWeek: (data['ridesThisWeek'] as num?)?.toInt() ?? 0,
          ridesCompletedThisMonth:
              (data['ridesThisMonth'] as num?)?.toInt() ?? 0,
          lastUpdated:
              (data['lastUpdatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          lastPayoutDate: lastPayoutDate,
        );
      }

      // Fallback: full payments scan — only runs before the first Cloud
      // Function execution or if driver_stats was manually deleted.
      TalkerService.info(
        'calculateEarningsSummary: driver_stats missing for $driverId — '
        'falling back to full payments scan',
      );

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final monthStart = DateTime(now.year, now.month);
      final yearStart = DateTime(now.year);

      final allPayments = await _paymentsCollection
          .where('driverId', isEqualTo: driverId)
          .where('status', isEqualTo: PaymentStatus.succeeded.name)
          .get();

      final payments = allPayments.docs.map((doc) => doc.data()).toList();

      double totalEarnings = 0;
      double totalPlatformFees = 0;
      double totalStripeFees = 0;
      final totalRides = payments.length;

      double earningsToday = 0;
      double earningsThisWeek = 0;
      double earningsThisMonth = 0;
      double earningsThisYear = 0;

      var ridesToday = 0;
      var ridesThisWeek = 0;
      var ridesThisMonth = 0;

      for (final payment in payments) {
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
    } on Exception catch (e) {
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
    } on Exception catch (e) {
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
        'updatedAt': DateTime.now(),
        'failureReason': ?failureReason,
        if (arrivedAt != null) 'arrivedAt': Timestamp.fromDate(arrivedAt),
      });

      TalkerService.info('Payout status updated: $payoutId -> ${status.name}');
    } on Exception catch (e) {
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
    } on Exception catch (e) {
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
    } on Exception catch (e) {
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
    } on Exception catch (e) {
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
    double? availableBalance,
    double? pendingBalance,
  }) async {
    try {
      await _connectedAccountsCollection.doc(driverId).update({
        'chargesEnabled': chargesEnabled,
        'payoutsEnabled': payoutsEnabled,
        'detailsSubmitted': detailsSubmitted,
        'availableBalance': ?availableBalance,
        'pendingBalance': ?pendingBalance,
        'onboardingCompleted':
            chargesEnabled && payoutsEnabled && detailsSubmitted,
        'updatedAt': DateTime.now(),
        if (chargesEnabled && payoutsEnabled && detailsSubmitted)
          'onboardingCompletedAt': DateTime.now(),
      });

      TalkerService.info('Connected account status updated: $driverId');
    } on Exception catch (e) {
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
    } on Exception catch (e) {
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
    } on Exception catch (e) {
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
    } on Exception catch (e) {
      TalkerService.error('Error creating connected account: $e');
      rethrow;
    }
  }
}
