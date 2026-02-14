import 'package:sport_connect/features/messaging/models/message_model.dart';

/// Chat operations repository interface
abstract class IChatRepository {
  // Chat Management
  Future<String> createChat(ChatModel chat);
  Future<ChatModel?> getChatById(String chatId);
  Future<ChatModel?> getOrCreateDirectChat(String userId1, String userId2);
  Stream<List<ChatModel>> getUserChats(String userId);

  // Message Operations
  Future<String> sendMessage(MessageModel message);
  Future<void> deleteMessage(String messageId);
  Future<void> markAsRead(String chatId, String userId);
  Stream<List<MessageModel>> getChatMessages(String chatId, {int limit = 50});

  // Typing Indicators
  Future<void> setTypingStatus(String chatId, String userId, bool isTyping);
  Stream<Map<String, bool>> getTypingStatus(String chatId);
}
