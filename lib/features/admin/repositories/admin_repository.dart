import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/services/firebase_service.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final firebase = ref.watch(firebaseServiceProvider);
  return AdminRepository(firebase.firestore, firebase.functions);
});

final adminRefundRequestsProvider = StreamProvider<List<AdminIssue>>((ref) {
  return ref.watch(adminRepositoryProvider).watchRefundRequests();
});

final adminDisputesProvider = StreamProvider<List<AdminIssue>>((ref) {
  return ref.watch(adminRepositoryProvider).watchDisputes();
});

final adminSupportTicketsProvider = StreamProvider<List<AdminIssue>>((ref) {
  return ref.watch(adminRepositoryProvider).watchSupportTickets();
});

class AdminIssue {
  const AdminIssue({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.createdAt,
    required this.data,
  });

  final String id;
  final String title;
  final String subtitle;
  final String status;
  final DateTime? createdAt;
  final Map<String, dynamic> data;

  int get amountInCents =>
      _readInt(data['remainingAmountInCents']) ??
      _readInt(data['amountInCents']) ??
      0;

  static int? _readInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.round();
    return null;
  }
}

class AdminRepository {
  const AdminRepository(this._firestore, this._functions);

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  Stream<List<AdminIssue>> watchRefundRequests() {
    return _firestore
        .collection('refund_requests')
        .orderBy('updatedAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (doc) => _issueFromDoc(
                  doc,
                  title:
                      'Refund ${_money(doc.data()['remainingAmountInCents'] ?? doc.data()['amountInCents'])}',
                  fallbackSubtitle: doc.data()['reason'] as String?,
                ),
              )
              .toList(),
        );
  }

  Stream<List<AdminIssue>> watchDisputes() {
    return _firestore
        .collection(AppConstants.disputesCollection)
        .orderBy('updatedAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (doc) => _issueFromDoc(
                  doc,
                  title: 'Dispute ${doc.data()['disputeType'] ?? ''}'.trim(),
                  fallbackSubtitle: doc.data()['description'] as String?,
                ),
              )
              .toList(),
        );
  }

  Stream<List<AdminIssue>> watchSupportTickets() {
    return _firestore
        .collection(AppConstants.supportTicketsCollection)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (doc) => _issueFromDoc(
                  doc,
                  title: doc.data()['subject'] as String? ?? 'Support ticket',
                  fallbackSubtitle: doc.data()['message'] as String?,
                ),
              )
              .toList(),
        );
  }

  Future<void> approveRefundRequest({
    required String refundRequestId,
    int? amountInCents,
    String? note,
  }) {
    return _call('approveRefundRequest', {
      'refundRequestId': refundRequestId,
      'amountInCents': ?amountInCents,
      'note': ?note,
    });
  }

  Future<void> rejectRefundRequest({
    required String refundRequestId,
    String? note,
  }) {
    return _call('rejectRefundRequest', {
      'refundRequestId': refundRequestId,
      'note': ?note,
    });
  }

  Future<void> approveDisputeRefund({
    required String disputeId,
    int? amountInCents,
    String? note,
  }) {
    return _call('approveDisputeRefund', {
      'disputeId': disputeId,
      'amountInCents': ?amountInCents,
      'note': ?note,
    });
  }

  Future<void> rejectDispute({
    required String disputeId,
    String? note,
  }) {
    return _call('rejectDispute', {
      'disputeId': disputeId,
      'note': ?note,
    });
  }

  Future<void> resolveSupportTicket({
    required String ticketId,
    String? note,
  }) {
    return _call('resolveSupportTicket', {
      'ticketId': ticketId,
      'note': ?note,
    });
  }

  Future<void> _call(String name, Map<String, dynamic> data) async {
    await _functions.httpsCallable(name).call<void>(data);
  }

  static AdminIssue _issueFromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc, {
    required String title,
    String? fallbackSubtitle,
  }) {
    final data = doc.data();
    return AdminIssue(
      id: doc.id,
      title: title.isEmpty ? 'Issue' : title,
      subtitle: fallbackSubtitle?.trim().isNotEmpty == true
          ? fallbackSubtitle!.trim()
          : 'No details provided',
      status: data['status'] as String? ?? 'open',
      createdAt: _date(data['updatedAt']) ?? _date(data['createdAt']),
      data: data,
    );
  }

  static DateTime? _date(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  static String _money(Object? cents) {
    final amount = AdminIssue._readInt(cents) ?? 0;
    return 'EUR ${(amount / 100).toStringAsFixed(2)}';
  }
}
