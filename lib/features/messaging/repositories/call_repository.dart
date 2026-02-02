import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/features/messaging/models/call_model.dart';

part 'call_repository.g.dart';

/// Call Repository for Firestore operations
class CallRepository {
  final FirebaseFirestore _firestore;

  CallRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> get _callsCollection =>
      _firestore.collection('calls');

  // ==================== CALL OPERATIONS ====================

  /// Create a new call
  Future<CallModel> createCall({
    required String chatId,
    required CallType type,
    required String callerId,
    required String callerName,
    String? callerPhotoUrl,
    required String calleeId,
    required String calleeName,
    String? calleePhotoUrl,
  }) async {
    final docRef = _callsCollection.doc();
    final channelName = 'call_${docRef.id}';

    final call = CallModel(
      id: docRef.id,
      chatId: chatId,
      type: type,
      callerId: callerId,
      callerName: callerName,
      callerPhotoUrl: callerPhotoUrl,
      calleeId: calleeId,
      calleeName: calleeName,
      calleePhotoUrl: calleePhotoUrl,
      status: CallStatus.pending,
      channelName: channelName,
      createdAt: DateTime.now(),
    );

    await docRef.set(call.toJson());
    return call;
  }

  /// Get call by ID
  Future<CallModel?> getCallById(String callId) async {
    final doc = await _callsCollection.doc(callId).get();
    if (!doc.exists) return null;
    return CallModel.fromJson(doc.data()!);
  }

  /// Stream call updates
  Stream<CallModel?> streamCall(String callId) {
    return _callsCollection
        .doc(callId)
        .snapshots()
        .map((doc) => doc.exists ? CallModel.fromJson(doc.data()!) : null);
  }

  /// Stream incoming calls for a user
  Stream<List<CallModel>> streamIncomingCalls(String userId) {
    return _callsCollection
        .where('calleeId', isEqualTo: userId)
        .where(
          'status',
          whereIn: [CallStatus.pending.name, CallStatus.ringing.name],
        )
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CallModel.fromJson(doc.data()))
              .toList(),
        );
  }

  /// Get call history for a user
  Future<List<CallHistoryEntry>> getCallHistory({
    required String userId,
    int limit = 50,
  }) async {
    // Get calls where user is caller
    final callerQuery = await _callsCollection
        .where('callerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    // Get calls where user is callee
    final calleeQuery = await _callsCollection
        .where('calleeId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    // Combine and sort
    final allCalls = [
      ...callerQuery.docs.map((doc) => CallModel.fromJson(doc.data())),
      ...calleeQuery.docs.map((doc) => CallModel.fromJson(doc.data())),
    ];

    allCalls.sort(
      (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
        a.createdAt ?? DateTime.now(),
      ),
    );

    // Convert to history entries
    return allCalls
        .take(limit)
        .map((call) => CallHistoryEntry.fromCall(call, userId))
        .toList();
  }

  /// Update call status
  Future<void> updateCallStatus({
    required String callId,
    required CallStatus status,
    String? endReason,
  }) async {
    final updates = <String, dynamic>{'status': status.name};

    if (status == CallStatus.ongoing) {
      updates['answeredAt'] = FieldValue.serverTimestamp();
    }

    if (status == CallStatus.ended ||
        status == CallStatus.missed ||
        status == CallStatus.declined ||
        status == CallStatus.failed) {
      updates['endedAt'] = FieldValue.serverTimestamp();
      if (endReason != null) {
        updates['endReason'] = endReason;
      }
    }

    await _callsCollection.doc(callId).update(updates);
  }

  /// Answer a call
  Future<void> answerCall(String callId) async {
    await updateCallStatus(callId: callId, status: CallStatus.ongoing);
  }

  /// Decline a call
  Future<void> declineCall(String callId) async {
    await updateCallStatus(
      callId: callId,
      status: CallStatus.declined,
      endReason: 'declined',
    );
  }

  /// End a call
  Future<void> endCall({required String callId, required int duration}) async {
    await _callsCollection.doc(callId).update({
      'status': CallStatus.ended.name,
      'endedAt': FieldValue.serverTimestamp(),
      'duration': duration,
      'endReason': 'ended',
    });
  }

  /// Mark call as missed
  Future<void> markCallMissed(String callId) async {
    await updateCallStatus(
      callId: callId,
      status: CallStatus.missed,
      endReason: 'no_answer',
    );
  }

  /// Update WebRTC session ID for a call
  Future<void> updateSessionId({
    required String callId,
    required String sessionId,
  }) async {
    await _callsCollection.doc(callId).update({'sessionId': sessionId});
  }

  /// Get active call for chat
  Future<CallModel?> getActiveCallForChat(String chatId) async {
    final query = await _callsCollection
        .where('chatId', isEqualTo: chatId)
        .where(
          'status',
          whereIn: [
            CallStatus.pending.name,
            CallStatus.ringing.name,
            CallStatus.connecting.name,
            CallStatus.ongoing.name,
          ],
        )
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return CallModel.fromJson(query.docs.first.data());
  }
}

@riverpod
CallRepository callRepository(Ref ref) {
  return CallRepository(FirebaseFirestore.instance);
}
