import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sport_connect/core/converters/timestamp_converter.dart';

part 'message_model.freezed.dart';
part 'message_model.g.dart';

enum MessageType { text, image, location, ride, system, audio }

enum MessageStatus { sending, sent, delivered, read, failed }

enum ChatType { private, rideGroup, eventGroup, support }

// ── MessageModel ──────────────────────────────────────────────────────────────

@freezed
abstract class MessageModel with _$MessageModel {
  const factory MessageModel({
    required String id,
    required String chatId,
    required String senderId,
    required String senderName,
    required String content,
    String? senderPhotoUrl,
    @Default(MessageType.text) MessageType type,
    @Default(MessageStatus.sending) MessageStatus status,

    // FIX: unified media field — replaces the old split imageUrl / (misused)
    // imageUrl-for-audio pattern. One field for image, audio, and video URLs.
    String? mediaUrl,
    String? thumbnailUrl,

    // Location
    double? latitude,
    double? longitude,
    String? locationName,

    // Ride attachment
    String? rideId,

    // Reply context
    String? replyToMessageId,
    String? replyToContent,

    // Reactions: emoji → [userId, ...]
    @Default({}) Map<String, List<String>> reactions,

    // Read receipts
    @Default([]) List<String> readBy,
    @Default([]) List<String> deliveredTo,

    // Metadata
    @Default(false) bool isEdited,
    @Default(false) bool isDeleted,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? editedAt,
  }) = _MessageModel;
  // FIX: private constructor BEFORE the factory — required by freezed so that
  // custom methods below can reference `this` on the generated concrete class.
  const MessageModel._();

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  bool isFromUser(String userId) => senderId == userId;
  bool isReadBy(String userId) => readBy.contains(userId);

  int get totalReactions =>
      reactions.values.fold(0, (sum, list) => sum + list.length);
}

// ── ChatParticipant ───────────────────────────────────────────────────────────

@freezed
abstract class ChatParticipant with _$ChatParticipant {
  const factory ChatParticipant({
    // FIX: Dart field renamed odid → userId for clarity, but the Firestore
    // document field is kept as 'odid' via @JsonKey for backward compatibility
    // with existing participant arrays already written to Firestore.
    // Removing @JsonKey(name: 'odid') would require a Firestore data migration.
    @JsonKey(name: 'odid') required String userId,
    required String displayName,
    String? photoUrl,
    @Default(false) bool isAdmin,
    @Default(false) bool isMuted,
    @TimestampConverter() DateTime? lastSeenAt,
    @TimestampConverter() DateTime? joinedAt,
  }) = _ChatParticipant;

  factory ChatParticipant.fromJson(Map<String, dynamic> json) =>
      _$ChatParticipantFromJson(json);
}

// ── ChatModel ─────────────────────────────────────────────────────────────────

@freezed
abstract class ChatModel with _$ChatModel {
  const factory ChatModel({
    required String id,
    @Default(ChatType.private) ChatType type,

    // Participants
    @Default([]) List<ChatParticipant> participants,
    @Default([]) List<String> participantIds,

    // Group
    String? groupName,
    String? groupPhotoUrl,
    String? description,

    // Ride / event
    String? rideId,
    String? eventId,

    // Last message preview
    String? lastMessageContent,
    String? lastMessageSenderId,
    String? lastMessageSenderName,
    @Default(MessageType.text) MessageType lastMessageType,
    @TimestampConverter() DateTime? lastMessageAt,

    // Unread counts: userId → count
    @Default({}) Map<String, int> unreadCounts,

    // Per-user settings
    @Default({}) Map<String, bool> mutedBy,
    @Default({}) Map<String, bool> pinnedBy,

    // One-sided deletion: userId → true
    @Default({}) Map<String, bool> deletedFor,

    @Default(true) bool isActive,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
  }) = _ChatModel;
  // FIX: private constructor before factory — required for custom methods below.
  const ChatModel._();

  factory ChatModel.fromJson(Map<String, dynamic> json) =>
      _$ChatModelFromJson(json);

  /// Returns the other participant in a private 1:1 chat, or null for groups.
  ChatParticipant? getOtherParticipant(String currentUserId) {
    if (type != ChatType.private || participants.length != 2) return null;
    return participants.firstWhere(
      (p) => p.userId != currentUserId,
      orElse: () => participants.first,
    );
  }

  String getChatTitle(String currentUserId) {
    return switch (type) {
      ChatType.rideGroup => groupName ?? 'Ride Chat',
      ChatType.eventGroup => groupName ?? 'Event Chat',
      ChatType.support => 'Support',
      _ =>
        groupName ??
            getOtherParticipant(currentUserId)?.displayName ??
            'Unknown',
    };
  }

  String? getChatPhoto(String currentUserId) =>
      groupPhotoUrl ?? getOtherParticipant(currentUserId)?.photoUrl;

  int getUnreadCount(String userId) => unreadCounts[userId] ?? 0;
  bool isMutedBy(String userId) => mutedBy[userId] ?? false;
  bool isPinnedBy(String userId) => pinnedBy[userId] ?? false;
}

// ── TypingIndicator ───────────────────────────────────────────────────────────

@freezed
abstract class TypingIndicator with _$TypingIndicator {
  const factory TypingIndicator({
    // No @JsonKey here: new Firestore writes use 'userId' (written by
    // setTyping in the repository). Existing indicators expire in ≤30 s
    // so backward-compat with the old 'odid' field is not needed.
    required String userId,
    required String displayName,
    required String chatId,
    @TimestampConverter() DateTime? startedAt,
  }) = _TypingIndicator;

  factory TypingIndicator.fromJson(Map<String, dynamic> json) =>
      _$TypingIndicatorFromJson(json);
}
