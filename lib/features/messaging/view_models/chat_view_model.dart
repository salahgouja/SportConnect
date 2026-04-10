import 'dart:async';
import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sport_connect/features/messaging/models/message_model.dart';
import 'package:sport_connect/core/providers/repository_providers.dart';

part 'chat_view_model.g.dart';

const String kDraftChatPrefix = 'draft-';

String buildDraftChatId(String userId1, String userId2) {
  final sorted = [userId1, userId2]..sort();
  return '$kDraftChatPrefix${sorted[0]}__${sorted[1]}';
}

bool isDraftChatId(String chatId) => chatId.startsWith(kDraftChatPrefix);

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

  Future<String> uploadAudioMessage({
    required String chatId,
    required File audioFile,
    required String fileName,
  }) {
    return _ref
        .read(chatRepositoryProvider)
        .uploadAudioMessage(
          chatId: chatId,
          audioFile: audioFile,
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

  Future<ChatModel> getOrCreatePrivateChat({
    required String userId1,
    required String userId2,
    required String userName1,
    required String userName2,
    String? userPhoto1,
    String? userPhoto2,
  }) {
    return _ref
        .read(chatRepositoryProvider)
        .getOrCreatePrivateChat(
          userId1: userId1,
          userId2: userId2,
          userName1: userName1,
          userName2: userName2,
          userPhoto1: userPhoto1,
          userPhoto2: userPhoto2,
        );
  }

  Future<void> clearChat({required String chatId, required String userId}) {
    return _ref
        .read(chatRepositoryProvider)
        .clearChat(chatId: chatId, userId: userId);
  }

  Future<void> blockUser({
    String? chatId,
    required String userId,
    required String blockedUserId,
  }) async {
    await _ref.read(profileRepositoryProvider).blockUser(userId, blockedUserId);

    if (chatId != null && chatId.isNotEmpty) {
      await _ref
          .read(chatRepositoryProvider)
          .toggleMute(chatId: chatId, odid: userId, mute: true);
    }
  }

  Future<void> unblockUser({
    String? chatId,
    required String userId,
    required String blockedUserId,
  }) async {
    await _ref
        .read(profileRepositoryProvider)
        .unblockUser(userId, blockedUserId);

    if (chatId != null && chatId.isNotEmpty) {
      await _ref
          .read(chatRepositoryProvider)
          .toggleMute(chatId: chatId, odid: userId, mute: false);
    }
  }
}

/// User Chats Stream Provider
@riverpod
Stream<List<ChatModel>> userChats(Ref ref, String userId) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.streamUserChats(userId);
}

final blockedUserIdsProvider = StreamProvider.family<List<String>, String>((
  ref,
  userId,
) {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.streamBlockedUserIds(userId);
});

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

    if (isDraftChatId(chatId)) {
      return const ChatDetailState(isLoading: false);
    }

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
            if (!ref.mounted) return;
            state = state.copyWith(messages: messages, isLoading: false);
          },
          onError: (e) {
            if (!ref.mounted) return;
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
    if (isDraftChatId(chatId)) return;
    await _markMessagesAsRead(state.messages);
  }

  void _listenToTyping() {
    final repository = ref.read(chatRepositoryProvider);
    _typingSubscription = repository.streamTypingIndicators(chatId).listen((
      indicators,
    ) {
      if (!ref.mounted) return;
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
      if (!ref.mounted) return false;
      state = state.copyWith(isSending: false);

      // Stop typing indicator
      await setTyping(false, senderName);
      if (!ref.mounted) return false;

      // Write an in-app notification for every other chat participant.
      // Fire-and-forget: a notification failure must never break messaging.
      try {
        final chat = await ref.read(chatRepositoryProvider).getChatById(chatId);
        if (!ref.mounted) return true;
        if (chat != null) {
          final notificationRepo = ref.read(notificationRepositoryProvider);
          final preview = type == MessageType.text
              ? (content.length > 60 ? '${content.substring(0, 60)}…' : content)
              : '[${type.name}]';
          for (final participantId in chat.participantIds) {
            if (participantId == currentUserId) continue;
            await notificationRepo.sendNewMessageNotification(
              toUserId: participantId,
              fromUserId: currentUserId,
              fromUserName: senderName,
              fromUserPhoto: senderPhotoUrl,
              chatId: chatId,
              messagePreview: preview,
            );
          }
        }
      } catch (_) {
        // Notification failure is non-fatal
      }

      return true;
    } catch (e) {
      if (!ref.mounted) return false;
      state = state.copyWith(isSending: false, error: e.toString());
      return false;
    }
  }

  Future<bool> sendImageMessage({
    required File imageFile,
    required String fileName,
    required String senderName,
    String? senderPhotoUrl,
  }) async {
    if (!ref.mounted) return false;
    state = state.copyWith(isSending: true, error: null);
    try {
      final imageUrl = await ref
          .read(chatRepositoryProvider)
          .uploadChatImage(
            chatId: chatId,
            imageFile: imageFile,
            fileName: fileName,
          );
      if (!ref.mounted) return false;

      return await sendMessage(
        content: 'Photo',
        senderName: senderName,
        senderPhotoUrl: senderPhotoUrl,
        type: MessageType.image,
        imageUrl: imageUrl,
        replyToMessageId: state.replyToMessage?.id,
        replyToContent: state.replyToMessage?.content,
      );
    } catch (e) {
      if (!ref.mounted) return false;
      state = state.copyWith(isSending: false, error: e.toString());
      return false;
    }
  }

  Future<bool> sendAudioMessage({
    required File audioFile,
    required String fileName,
    required String durationText,
    required String senderName,
    String? senderPhotoUrl,
  }) async {
    if (!ref.mounted) return false;
    state = state.copyWith(isSending: true, error: null);
    try {
      final audioUrl = await ref
          .read(chatRepositoryProvider)
          .uploadAudioMessage(
            chatId: chatId,
            audioFile: audioFile,
            fileName: fileName,
          );
      if (!ref.mounted) return false;

      return await sendMessage(
        content: 'Voice message ($durationText)',
        senderName: senderName,
        senderPhotoUrl: senderPhotoUrl,
        type: MessageType.audio,
        imageUrl: audioUrl,
        replyToMessageId: state.replyToMessage?.id,
        replyToContent: state.replyToMessage?.content,
      );
    } catch (e) {
      if (!ref.mounted) return false;
      state = state.copyWith(isSending: false, error: e.toString());
      return false;
    }
  }

  Future<bool> sendLocationMessage({
    required String content,
    required double latitude,
    required double longitude,
    required String senderName,
    String? senderPhotoUrl,
  }) {
    return sendMessage(
      content: content,
      senderName: senderName,
      senderPhotoUrl: senderPhotoUrl,
      type: MessageType.location,
      latitude: latitude,
      longitude: longitude,
      replyToMessageId: state.replyToMessage?.id,
      replyToContent: state.replyToMessage?.content,
    );
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

      if (!ref.mounted) return;

      state = state.copyWith(
        messages: [...state.messages, ...olderMessages],
        isLoadingMore: false,
        hasMoreMessages: olderMessages.length >= 20,
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  Future<void> setTyping(bool isTyping, String displayName) async {
    if (isDraftChatId(chatId)) return;

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
    await repository.deleteMessage(chatId: chatId, messageId: messageId);
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

  void setEmojiPickerVisible(bool visible) {
    if (state.showEmojiPicker == visible) return;
    state = state.copyWith(showEmojiPicker: visible);
  }

  void beginRecording(String path) {
    state = state.copyWith(
      isRecording: true,
      recordingPath: path,
      recordingDuration: Duration.zero,
    );
  }

  void updateRecordingDuration(Duration duration) {
    if (!state.isRecording) return;
    state = state.copyWith(recordingDuration: duration);
  }

  void clearRecording() {
    state = state.copyWith(
      isRecording: false,
      recordingPath: null,
      recordingDuration: Duration.zero,
    );
  }

  void handleComposerTextChanged(String text, String displayName) {
    final trimmed = text.trim();
    if (trimmed.isNotEmpty && !state.isLocallyTyping) {
      state = state.copyWith(isLocallyTyping: true);
      unawaited(setTyping(true, displayName));
    }

    _typingTimer?.cancel();

    if (trimmed.isEmpty) {
      if (state.isLocallyTyping) {
        state = state.copyWith(isLocallyTyping: false);
        unawaited(setTyping(false, displayName));
      }
      return;
    }

    _typingTimer = Timer(const Duration(seconds: 2), () {
      if (!ref.mounted) return;
      state = state.copyWith(isLocallyTyping: false);
      unawaited(setTyping(false, displayName));
    });
  }
}

/// State for chat detail
class ChatDetailState {
  static const _unset = Object();

  final List<MessageModel> messages;
  final List<TypingIndicator> typingUsers;
  final bool isLoading;
  final bool isSending;
  final bool isLoadingMore;
  final bool hasMoreMessages;
  final bool showEmojiPicker;
  final bool isLocallyTyping;
  final bool isRecording;
  final String? recordingPath;
  final Duration recordingDuration;
  final String? error;
  final MessageModel? replyToMessage;

  const ChatDetailState({
    this.messages = const [],
    this.typingUsers = const [],
    this.isLoading = true,
    this.isSending = false,
    this.isLoadingMore = false,
    this.hasMoreMessages = true,
    this.showEmojiPicker = false,
    this.isLocallyTyping = false,
    this.isRecording = false,
    this.recordingPath,
    this.recordingDuration = Duration.zero,
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
    bool? showEmojiPicker,
    bool? isLocallyTyping,
    bool? isRecording,
    Object? recordingPath = _unset,
    Duration? recordingDuration,
    String? error,
    Object? replyToMessage = _unset,
  }) {
    return ChatDetailState(
      messages: messages ?? this.messages,
      typingUsers: typingUsers ?? this.typingUsers,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMoreMessages: hasMoreMessages ?? this.hasMoreMessages,
      showEmojiPicker: showEmojiPicker ?? this.showEmojiPicker,
      isLocallyTyping: isLocallyTyping ?? this.isLocallyTyping,
      isRecording: isRecording ?? this.isRecording,
      recordingPath: recordingPath == _unset
          ? this.recordingPath
          : recordingPath as String?,
      recordingDuration: recordingDuration ?? this.recordingDuration,
      error: error,
      replyToMessage: replyToMessage == _unset
          ? this.replyToMessage
          : replyToMessage as MessageModel?,
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
  final existing = await repository.getOrCreateDirectChat(userId1, userId2);
  if (existing != null) {
    return existing;
  }

  // Return a local draft chat. The first sent message will persist it.
  return ChatModel(
    id: buildDraftChatId(userId1, userId2),
    type: ChatType.private,
    participantIds: [userId1, userId2],
    participants: [
      ChatParticipant(
        odid: userId1,
        displayName: userName1,
        photoUrl: userPhoto1,
      ),
      ChatParticipant(
        odid: userId2,
        displayName: userName2,
        photoUrl: userPhoto2,
      ),
    ],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

/// Fetch the ride group chat for a given ride ID, or null if none exists.
@riverpod
Future<ChatModel?> rideChatByRideId(Ref ref, {required String rideId}) async {
  final repository = ref.read(chatRepositoryProvider);
  return repository.getChatByRideId(rideId);
}
