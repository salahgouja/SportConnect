import 'dart:io';

import 'package:sport_connect/features/messaging/models/message_model.dart';

/// Chat operations repository interface
abstract class IChatRepository {
  // Chat Management
  Future<String> createChat(ChatModel chat);
  Future<ChatModel?> getChatById(String chatId);
  Future<ChatModel?> getChatByRideId(String rideId);
  Future<ChatModel?> getOrCreateDirectChat(String userId1, String userId2);
  Future<ChatModel> getOrCreatePrivateChat({
    required String userId1,
    required String userId2,
    required String userName1,
    required String userName2,
    String? userPhoto1,
    String? userPhoto2,
  });
  Stream<List<ChatModel>> getUserChats(String userId);
  Stream<List<ChatModel>> streamUserChats(String userId);

  // Message Operations
  Future<String> sendMessage(MessageModel message);
  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
  });
  Future<void> markAsRead(String chatId, String userId);
  Stream<List<MessageModel>> getChatMessages(String chatId, {int limit = 50});
  Stream<List<MessageModel>> streamMessages(String chatId, {int limit = 50});
  Future<List<MessageModel>> loadMoreMessages({
    required String chatId,
    required DateTime beforeTimestamp,
    int limit = 20,
  });
  Future<void> editMessage({
    required String chatId,
    required String messageId,
    required String newContent,
  });
  Future<void> addReaction({
    required String chatId,
    required String messageId,
    required String odid,
    required String reaction,
  });

  // Typing Indicators
  Future<void> setTypingStatus(String chatId, String userId, bool isTyping);
  Stream<Map<String, bool>> getTypingStatus(String chatId);
  Future<void> setTyping({
    required String chatId,
    required String odid,
    required String displayName,
    required bool isTyping,
  });
  Stream<List<TypingIndicator>> streamTypingIndicators(String chatId);

  // Chat Actions
  Future<void> toggleMute({
    required String chatId,
    required String odid,
    required bool mute,
  });
  Future<void> clearChat({required String chatId, required String userId});

  // Media Uploads
  Future<String> uploadChatImage({
    required String chatId,
    required File imageFile,
    required String fileName,
  });

  Future<String> uploadAudioMessage({
    required String chatId,
    required File audioFile,
    required String fileName,
  });
}
