import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sport_connect/features/auth/models/user_model.dart';

part 'call_model.freezed.dart';
part 'call_model.g.dart';

/// Call type enum
enum CallType { voice, video }

/// Call status enum
enum CallStatus {
  pending, // Call initiated, waiting for answer
  ringing, // Callee's phone is ringing
  connecting, // Call is being connected
  ongoing, // Call is active
  ended, // Call ended normally
  missed, // Call was not answered
  declined, // Call was declined
  failed, // Call failed due to error
}

/// Call model for voice and video calls
@freezed
abstract class CallModel with _$CallModel {
  const CallModel._();

  const factory CallModel({
    required String id,
    required String chatId,
    required CallType type,
    required String callerId,
    required String callerName,
    String? callerPhotoUrl,
    required String calleeId,
    required String calleeName,
    String? calleePhotoUrl,
    @Default(CallStatus.pending) CallStatus status,

    // WebRTC signaling info
    String? channelName,
    String? sessionId,

    // Call timing
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? answeredAt,
    @TimestampConverter() DateTime? endedAt,

    // Call duration in seconds
    @Default(0) int duration,

    // End reason
    String? endReason,
  }) = _CallModel;

  factory CallModel.fromJson(Map<String, dynamic> json) =>
      _$CallModelFromJson(json);

  /// Check if call is from current user
  bool isFromUser(String userId) => callerId == userId;

  /// Check if call is active
  bool get isActive =>
      status == CallStatus.pending ||
      status == CallStatus.ringing ||
      status == CallStatus.connecting ||
      status == CallStatus.ongoing;

  /// Get the other user's ID
  String getreceiverId(String currentUserId) =>
      callerId == currentUserId ? calleeId : callerId;

  /// Get the other user's name
  String getreceiverName(String currentUserId) =>
      callerId == currentUserId ? calleeName : callerName;

  /// Get formatted duration
  String get formattedDuration {
    final mins = duration ~/ 60;
    final secs = duration % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

/// Call history entry for displaying in UI
@freezed
abstract class CallHistoryEntry with _$CallHistoryEntry {
  const factory CallHistoryEntry({
    required String id,
    required CallType type,
    required String receiverId,
    required String receiverName,
    String? receiverPhotoUrl,
    required bool isOutgoing,
    required CallStatus status,
    required int duration,
    @TimestampConverter() DateTime? timestamp,
  }) = _CallHistoryEntry;

  factory CallHistoryEntry.fromJson(Map<String, dynamic> json) =>
      _$CallHistoryEntryFromJson(json);

  factory CallHistoryEntry.fromCall(CallModel call, String currentUserId) {
    return CallHistoryEntry(
      id: call.id,
      type: call.type,
      receiverId: call.getreceiverId(currentUserId),
      receiverName: call.getreceiverName(currentUserId),
      receiverPhotoUrl: call.callerId == currentUserId
          ? call.calleePhotoUrl
          : call.callerPhotoUrl,
      isOutgoing: call.callerId == currentUserId,
      status: call.status,
      duration: call.duration,
      timestamp: call.createdAt,
    );
  }
}
