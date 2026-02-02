import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sport_connect/features/auth/models/user_model.dart';

part 'message_model.freezed.dart';
part 'message_model.g.dart';

/// Message type enum
enum MessageType { text, image, location, ride, system, audio }

/// Message status enum
enum MessageStatus { sending, sent, delivered, read, failed }

/// Chat type enum
enum ChatType { private, rideGroup, support }

/// Single message model
@freezed
abstract class MessageModel with _$MessageModel {
  const MessageModel._();

  const factory MessageModel({
    required String id,
    required String chatId,
    required String senderId,
    required String senderName,
    String? senderPhotoUrl,
    required String content,
    @Default(MessageType.text) MessageType type,
    @Default(MessageStatus.sending) MessageStatus status,

    // For image messages
    String? imageUrl,
    String? thumbnailUrl,

    // For location messages
    double? latitude,
    double? longitude,
    String? locationName,

    // For ride messages
    String? rideId,

    // Reply
    String? replyToMessageId,
    String? replyToContent,

    // Reactions
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

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  /// Check if message is from current user
  bool isFromUser(String userId) => senderId == userId;

  /// Check if read by user
  bool isReadBy(String userId) => readBy.contains(userId);

  /// Get total reaction count
  int get totalReactions =>
      reactions.values.fold(0, (sum, list) => sum + list.length);
}

/// Chat participant model
@freezed
abstract class ChatParticipant with _$ChatParticipant {
  const factory ChatParticipant({
    required String odid,
    required String displayName,
    String? photoUrl,
    @Default(false) bool isOnline,
    @Default(false) bool isAdmin,
    @Default(false) bool isMuted,
    @TimestampConverter() DateTime? lastSeenAt,
    @TimestampConverter() DateTime? joinedAt,
  }) = _ChatParticipant;

  factory ChatParticipant.fromJson(Map<String, dynamic> json) =>
      _$ChatParticipantFromJson(json);
}

/// Chat/Conversation model
@freezed
abstract class ChatModel with _$ChatModel {
  const ChatModel._();

  const factory ChatModel({
    required String id,
    @Default(ChatType.private) ChatType type,

    // Participants
    @Default([]) List<ChatParticipant> participants,
    @Default([]) List<String> participantIds,

    // For group chats
    String? groupName,
    String? groupPhotoUrl,
    String? description,

    // For ride chats
    String? rideId,

    // Last message info
    String? lastMessageContent,
    String? lastMessageSenderId,
    String? lastMessageSenderName,
    @Default(MessageType.text) MessageType lastMessageType,
    @TimestampConverter() DateTime? lastMessageAt,

    // Unread counts per user (userId -> count)
    @Default({}) Map<String, int> unreadCounts,

    // Settings
    @Default({}) Map<String, bool> mutedBy,
    @Default({}) Map<String, bool> pinnedBy,

    // Metadata
    @Default(true) bool isActive,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
  }) = _ChatModel;

  factory ChatModel.fromJson(Map<String, dynamic> json) =>
      _$ChatModelFromJson(json);

  /// Get other participant in private chat
  ChatParticipant? getOtherParticipant(String currentUserId) {
    if (type != ChatType.private || participants.length != 2) return null;
    return participants.firstWhere(
      (p) => p.odid != currentUserId,
      orElse: () => participants.first,
    );
  }

  /// Get chat title (group name or other participant's name)
  String getChatTitle(String currentUserId) {
    if (type == ChatType.rideGroup) return groupName ?? 'Ride Chat';
    if (type == ChatType.support) return 'Support';
    if (groupName != null) return groupName!;

    final other = getOtherParticipant(currentUserId);
    return other?.displayName ?? 'Unknown';
  }

  /// Get chat photo
  String? getChatPhoto(String currentUserId) {
    if (groupPhotoUrl != null) return groupPhotoUrl;
    return getOtherParticipant(currentUserId)?.photoUrl;
  }

  /// Get unread count for user
  int getUnreadCount(String userId) => unreadCounts[userId] ?? 0;

  /// Is muted by user
  bool isMutedBy(String userId) => mutedBy[userId] ?? false;

  /// Is pinned by user
  bool isPinnedBy(String userId) => pinnedBy[userId] ?? false;

  /// Is other participant online (for private chats)
  bool isOtherOnline(String currentUserId) {
    final other = getOtherParticipant(currentUserId);
    return other?.isOnline ?? false;
  }
}

/// Typing indicator model
@freezed
abstract class TypingIndicator with _$TypingIndicator {
  const factory TypingIndicator({
    required String odid,
    required String displayName,
    required String chatId,
    @TimestampConverter() DateTime? startedAt,
  }) = _TypingIndicator;

  factory TypingIndicator.fromJson(Map<String, dynamic> json) =>
      _$TypingIndicatorFromJson(json);
}
