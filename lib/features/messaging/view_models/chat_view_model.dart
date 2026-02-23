import 'dart:async';
import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sport_connect/features/messaging/models/message_model.dart';
import 'package:sport_connect/features/messaging/repositories/chat_repository.dart';

part 'chat_view_model.g.dart';

/// State for chat list
class ChatListState {
  final List<ChatModel> chats;
  final List<ChatModel> pinnedChats;
  final bool isLoading;
  final String? error;

  const ChatListState({
    this.chats = const [],
    this.pinnedChats = const [],
    this.isLoading = false,
    this.error,
  });

  ChatListState copyWith({
    List<ChatModel>? chats,
    List<ChatModel>? pinnedChats,
    bool? isLoading,
    String? error,
  }) {
    return ChatListState(
      chats: chats ?? this.chats,
      pinnedChats: pinnedChats ?? this.pinnedChats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  int get totalUnread => chats.fold(
    0,
    (sum, chat) => sum + (chat.unreadCounts.values.fold(0, (a, b) => a + b)),
  );
}

final chatActionsViewModelProvider = Provider<ChatActionsViewModel>((ref) {
  return ChatActionsViewModel(ref);
});

class ChatActionsViewModel {
  ChatActionsViewModel(this._ref);

  final Ref _ref;

  Future<String> uploadChatImage({
    required String chatId,
    required File imageFile,
    required String fileName,
  }) {
    return _ref
        .read(chatRepositoryProvider)
        .uploadChatImage(
          chatId: chatId,
          imageFile: imageFile,
          fileName: fileName,
        );
  }

  Future<void> toggleMute({
    required String chatId,
    required String userId,
    required bool mute,
  }) {
    return _ref
        .read(chatRepositoryProvider)
        .toggleMute(chatId: chatId, odid: userId, mute: mute);
  }

  Future<ChatModel?> getChatById(String chatId) {
    return _ref.read(chatRepositoryProvider).getChatById(chatId);
  }

  Future<void> clearChat({required String chatId, required String userId}) {
    return _ref
        .read(chatRepositoryProvider)
        .clearChat(chatId: chatId, userId: userId);
  }

  Future<void> blockUser({
    required String chatId,
    required String userId,
    required String blockedUserId,
  }) {
    return _ref
        .read(chatRepositoryProvider)
        .blockUser(
          chatId: chatId,
          userId: userId,
          blockedUserId: blockedUserId,
        );
  }
}

/// User Chats Stream Provider
@riverpod
Stream<List<ChatModel>> userChats(Ref ref, String userId) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.streamUserChats(userId);
}

/// Chat Detail View Model
@riverpod
class ChatDetailViewModel extends _$ChatDetailViewModel {
  StreamSubscription<List<MessageModel>>? _messagesSubscription;
  StreamSubscription<List<TypingIndicator>>? _typingSubscription;
  Timer? _typingTimer;

  @override
  ChatDetailState build(String chatId, String currentUserId) {
    // Clean up on dispose
    ref.onDispose(() {
      _messagesSubscription?.cancel();
      _typingSubscription?.cancel();
      _typingTimer?.cancel();
    });

    // Start listening to messages
    _listenToMessages();
    _listenToTyping();

    return const ChatDetailState();
  }

  void _listenToMessages() {
    final repository = ref.read(chatRepositoryProvider);
    _messagesSubscription = repository
        .streamMessages(chatId)
        .listen(
          (messages) {
            state = state.copyWith(messages: messages, isLoading: false);
          },
          onError: (e) {
            state = state.copyWith(error: e.toString(), isLoading: false);
          },
        );
  }

  /// Marks unread messages as read.
  ///
  /// Must be called explicitly by the consumer widget rather than
  /// automatically during provider initialization to avoid write side effects
  /// in `build()`.
  Future<void> markVisibleMessagesAsRead() async {
    await _markMessagesAsRead(state.messages);
  }

  void _listenToTyping() {
    final repository = ref.read(chatRepositoryProvider);
    _typingSubscription = repository.streamTypingIndicators(chatId).listen((
      indicators,
    ) {
      // Filter out current user
      final others = indicators.where((t) => t.odid != currentUserId).toList();
      state = state.copyWith(typingUsers: others);
    });
  }

  Future<void> _markMessagesAsRead(List<MessageModel> messages) async {
    final unreadIds = messages
        .where((m) => !m.isReadBy(currentUserId) && m.senderId != currentUserId)
        .map((m) => m.id)
        .toList();

    if (unreadIds.isEmpty) return;

    final repository = ref.read(chatRepositoryProvider);
    await repository.markAsRead(chatId, currentUserId);
  }

  Future<bool> sendMessage({
    required String content,
    required String senderName,
    String? senderPhotoUrl,
    MessageType type = MessageType.text,
    String? imageUrl,
    double? latitude,
    double? longitude,
    String? replyToMessageId,
    String? replyToContent,
  }) async {
    state = state.copyWith(isSending: true);

    try {
      final repository = ref.read(chatRepositoryProvider);

      final message = MessageModel(
        id: '',
        chatId: chatId,
        senderId: currentUserId,
        senderName: senderName,
        senderPhotoUrl: senderPhotoUrl,
        content: content,
        type: type,
        imageUrl: imageUrl,
        latitude: latitude,
        longitude: longitude,
        replyToMessageId: replyToMessageId,
        replyToContent: replyToContent,
      );

      await repository.sendMessage(message);
      state = state.copyWith(isSending: false);

      // Stop typing indicator
      await setTyping(false, senderName);

      return true;
    } catch (e) {
      state = state.copyWith(isSending: false, error: e.toString());
      return false;
    }
  }

  Future<void> loadMoreMessages() async {
    if (state.isLoadingMore || state.messages.isEmpty) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final repository = ref.read(chatRepositoryProvider);
      final oldestMessage = state.messages.last;

      final olderMessages = await repository.loadMoreMessages(
        chatId: chatId,
        beforeTimestamp: oldestMessage.createdAt ?? DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, ...olderMessages],
        isLoadingMore: false,
        hasMoreMessages: olderMessages.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  Future<void> setTyping(bool isTyping, String displayName) async {
    // Debounce typing indicator
    _typingTimer?.cancel();

    if (isTyping) {
      // Check if provider is still mounted before using ref
      if (!ref.mounted) return;

      final repository = ref.read(chatRepositoryProvider);
      await repository.setTyping(
        chatId: chatId,
        odid: currentUserId,
        displayName: displayName,
        isTyping: true,
      );

      // Auto-stop after 5 seconds of inactivity
      _typingTimer = Timer(const Duration(seconds: 5), () {
        // Check if provider is still mounted before the delayed callback
        if (ref.mounted) {
          setTyping(false, displayName);
        }
      });
    } else {
      // Check if provider is still mounted before using ref
      if (!ref.mounted) return;

      final repository = ref.read(chatRepositoryProvider);
      await repository.setTyping(
        chatId: chatId,
        odid: currentUserId,
        displayName: displayName,
        isTyping: false,
      );
    }
  }

  Future<void> deleteMessage(String messageId) async {
    final repository = ref.read(chatRepositoryProvider);
    await repository.deleteMessage(messageId);
  }

  Future<void> editMessage(String messageId, String newContent) async {
    final repository = ref.read(chatRepositoryProvider);
    await repository.editMessage(
      chatId: chatId,
      messageId: messageId,
      newContent: newContent,
    );
  }

  Future<void> addReaction(String messageId, String reaction) async {
    final repository = ref.read(chatRepositoryProvider);
    await repository.addReaction(
      chatId: chatId,
      messageId: messageId,
      odid: currentUserId,
      reaction: reaction,
    );
  }

  void setReplyTo(MessageModel? message) {
    state = state.copyWith(replyToMessage: message);
  }

  void clearReply() {
    state = state.copyWith(replyToMessage: null);
  }
}

/// State for chat detail
class ChatDetailState {
  final List<MessageModel> messages;
  final List<TypingIndicator> typingUsers;
  final bool isLoading;
  final bool isSending;
  final bool isLoadingMore;
  final bool hasMoreMessages;
  final String? error;
  final MessageModel? replyToMessage;

  const ChatDetailState({
    this.messages = const [],
    this.typingUsers = const [],
    this.isLoading = true,
    this.isSending = false,
    this.isLoadingMore = false,
    this.hasMoreMessages = true,
    this.error,
    this.replyToMessage,
  });

  ChatDetailState copyWith({
    List<MessageModel>? messages,
    List<TypingIndicator>? typingUsers,
    bool? isLoading,
    bool? isSending,
    bool? isLoadingMore,
    bool? hasMoreMessages,
    String? error,
    MessageModel? replyToMessage,
  }) {
    return ChatDetailState(
      messages: messages ?? this.messages,
      typingUsers: typingUsers ?? this.typingUsers,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMoreMessages: hasMoreMessages ?? this.hasMoreMessages,
      error: error,
      replyToMessage: replyToMessage,
    );
  }

  String get typingText {
    if (typingUsers.isEmpty) return '';
    if (typingUsers.length == 1) {
      return '${typingUsers.first.displayName} is typing...';
    }
    return '${typingUsers.length} people are typing...';
  }
}

/// Create or get private chat
@riverpod
Future<ChatModel> getOrCreateChat(
  Ref ref, {
  required String userId1,
  required String userId2,
  required String userName1,
  required String userName2,
  String? userPhoto1,
  String? userPhoto2,
}) async {
  final repository = ref.read(chatRepositoryProvider);
  return repository.getOrCreatePrivateChat(
    userId1: userId1,
    userId2: userId2,
    userName1: userName1,
    userName2: userName2,
    userPhoto1: userPhoto1,
    userPhoto2: userPhoto2,
  );
}
