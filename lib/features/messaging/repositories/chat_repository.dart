import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/interfaces/repositories/i_chat_repository.dart';
import 'package:sport_connect/features/messaging/models/message_model.dart';

/// Chat Repository for Firestore operations
class ChatRepository implements IChatRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  ChatRepository(this._firestore, this._storage);

  CollectionReference<ChatModel> get _chatsCollection => _firestore
      .collection(AppConstants.chatsCollection)
      .withConverter<ChatModel>(
        fromFirestore: (snapshot, _) => ChatModel.fromJson(snapshot.data()!),
        toFirestore: (chat, _) => chat.toJson(),
      );

  CollectionReference<MessageModel> _messagesCollection(String chatId) =>
      _chatsCollection
          .doc(chatId)
          .collection(AppConstants.messagesCollection)
          .withConverter<MessageModel>(
            fromFirestore: (snapshot, _) =>
                MessageModel.fromJson(snapshot.data()!),
            toFirestore: (message, _) => message.toJson(),
          );
  CollectionReference<TypingIndicator> _typingCollection(String chatId) =>
      _chatsCollection
          .doc(chatId)
          .collection(AppConstants.typingCollection)
          .withConverter<TypingIndicator>(
            fromFirestore: (snapshot, _) =>
                TypingIndicator.fromJson(snapshot.data()!),
            toFirestore: (typing, _) => typing.toJson(),
          );

  // ==================== CHAT OPERATIONS ====================

  /// Create a new chat
  @override
  Future<String> createChat(ChatModel chat) async {
    final docRef = _chatsCollection.doc();
    final now = DateTime.now();
    final chatWithId = chat.copyWith(
      id: docRef.id,
      createdAt: now,
      updatedAt: now,
      // Initialize lastMessageAt so chat appears in queries ordered by this field
      lastMessageAt: chat.lastMessageAt ?? now,
    );
    await docRef.set(chatWithId);
    return docRef.id;
  }

  /// Get or create private chat between two users
  @override
  Future<ChatModel> getOrCreatePrivateChat({
    required String userId1,
    required String userId2,
    required String userName1,
    required String userName2,
    String? userPhoto1,
    String? userPhoto2,
  }) async {
    // Check if chat already exists
    final query = await _chatsCollection
        .where('type', isEqualTo: ChatType.private.name)
        .where('participantIds', arrayContains: userId1)
        .get();

    for (final doc in query.docs) {
      final chat = doc.data();
      if (chat.participantIds.contains(userId2)) {
        return chat;
      }
    }

    // Create new chat
    final newChat = ChatModel(
      id: '',
      type: ChatType.private,
      participantIds: [userId1, userId2],
      participants: [
        ChatParticipant(
          odid: userId1,
          displayName: userName1,
          photoUrl: userPhoto1,
          joinedAt: DateTime.now(),
        ),
        ChatParticipant(
          odid: userId2,
          displayName: userName2,
          photoUrl: userPhoto2,
          joinedAt: DateTime.now(),
        ),
      ],
    );

    final chatId = await createChat(newChat);
    return newChat.copyWith(id: chatId);
  }

  /// Create a ride group chat
  Future<ChatModel> createRideChat({
    required String rideId,
    required String driverId,
    required String driverName,
    String? driverPhoto,
    required String rideName,
  }) async {
    final chat = ChatModel(
      id: '',
      type: ChatType.rideGroup,
      rideId: rideId,
      groupName: rideName,
      participantIds: [driverId],
      participants: [
        ChatParticipant(
          odid: driverId,
          displayName: driverName,
          photoUrl: driverPhoto,
          isAdmin: true,
          joinedAt: DateTime.now(),
        ),
      ],
    );

    final chatId = await createChat(chat);
    return chat.copyWith(id: chatId);
  }

  /// Create an event group chat
  Future<ChatModel> createEventChat({
    required String eventId,
    required String creatorId,
    required String creatorName,
    String? creatorPhoto,
    required String eventName,
  }) async {
    final chat = ChatModel(
      id: '',
      type: ChatType.eventGroup,
      eventId: eventId,
      groupName: eventName,
      participantIds: [creatorId],
      participants: [
        ChatParticipant(
          odid: creatorId,
          displayName: creatorName,
          photoUrl: creatorPhoto,
          isAdmin: true,
          joinedAt: DateTime.now(),
        ),
      ],
    );

    final chatId = await createChat(chat);
    return chat.copyWith(id: chatId);
  }

  /// Get chat by ID
  @override
  Future<ChatModel?> getChatById(String chatId) async {
    final doc = await _chatsCollection.doc(chatId).get();
    if (!doc.exists) return null;
    return doc.data();
  }

  /// Get a ride group chat by ride ID.
  Future<ChatModel?> getChatByRideId(String rideId) async {
    final query = await _chatsCollection
        .where('type', isEqualTo: ChatType.rideGroup.name)
        .where('rideId', isEqualTo: rideId)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    return query.docs.first.data();
  }

  /// Stream user's chats
  @override
  Stream<List<ChatModel>> streamUserChats(String userId) {
    return _chatsCollection
        .where('participantIds', arrayContains: userId)
        // .where('isActive', isEqualTo: true)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => doc.data())
              .where((chat) => !(chat.deletedFor[userId] ?? false))
              .toList(),
        );
  }

  /// Add participant to chat
  Future<void> addParticipant({
    required String chatId,
    required ChatParticipant participant,
  }) async {
    await _chatsCollection.doc(chatId).update({
      'participantIds': FieldValue.arrayUnion([participant.odid]),
      'participants': FieldValue.arrayUnion([participant.toJson()]),
      'updatedAt': DateTime.now(),
    });
  }

  /// Ensure user is a participant in the chat (idempotent operation)
  /// Used to fix permission issues by adding missing users to participantIds
  Future<void> ensureParticipant({
    required String chatId,
    required String userId,
    String? displayName,
    String? photoUrl,
  }) async {
    final chat = await getChatById(chatId);
    if (chat == null) return;

    // Check if user is already a participant
    if (chat.participantIds.contains(userId)) {
      return;
    }

    // Add user to participantIds
    await _chatsCollection.doc(chatId).update({
      'participantIds': FieldValue.arrayUnion([userId]),
      if (displayName != null && photoUrl != null)
        'participants': FieldValue.arrayUnion([
          ChatParticipant(
            odid: userId,
            displayName: displayName,
            photoUrl: photoUrl,
            joinedAt: DateTime.now(),
          ).toJson(),
        ]),
      'updatedAt': DateTime.now(),
    });
  }

  /// Remove participant from chat
  Future<void> removeParticipant({
    required String chatId,
    required String odid,
  }) async {
    final chat = await getChatById(chatId);
    if (chat == null) return;

    final updatedParticipants = chat.participants
        .where((p) => p.odid != odid)
        .toList();

    await _chatsCollection.doc(chatId).update({
      'participantIds': FieldValue.arrayRemove([odid]),
      'participants': updatedParticipants.map((p) => p.toJson()).toList(),
      'updatedAt': DateTime.now(),
    });
  }

  /// Mute/unmute chat
  Future<void> toggleMute({
    required String chatId,
    required String odid,
    required bool mute,
  }) async {
    await _chatsCollection.doc(chatId).update({
      'mutedBy.$odid': mute,
      'updatedAt': DateTime.now(),
    });
  }

  /// Pin/unpin chat
  Future<void> togglePin({
    required String chatId,
    required String odid,
    required bool pin,
  }) async {
    await _chatsCollection.doc(chatId).update({
      'pinnedBy.$odid': pin,
      'updatedAt': DateTime.now(),
    });
  }

  // ==================== MESSAGE OPERATIONS ====================

  /// Send a message
  @override
  Future<String> sendMessage(MessageModel message) async {
    // M-5: Enforce message length limit to prevent Firestore bloat.
    if (message.content.length > 2000) {
      throw ArgumentError(
        'Message content must not exceed 2000 characters (got ${message.content.length}).',
      );
    }

    final chat = await getChatById(message.chatId);
    late final List<String> participantIds;

    // If chat exists, use its participants
    if (chat != null) {
      // FIX M-1: Verify the sender is actually a participant in the chat.
      // Without this check any authenticated user who knows a chatId can inject
      // messages into someone else's conversation.
      if (!chat.participantIds.contains(message.senderId)) {
        throw StateError(
          'sendMessage: sender ${message.senderId} is not a participant in chat ${message.chatId}',
        );
      }

      // FIX M-4: Check whether any recipient has blocked the sender.
      // If so, reject the message to honour the block.
      for (final recipientId in chat.participantIds) {
        if (recipientId == message.senderId) continue;
        final recipientDoc = await _firestore
            .collection(AppConstants.usersCollection)
            .doc(recipientId)
            .get();
        final blockedUsers = List<String>.from(
          recipientDoc.data()?['blockedUsers'] as List? ?? [],
        );
        if (blockedUsers.contains(message.senderId)) {
          throw StateError(
            'sendMessage: recipient $recipientId has blocked sender ${message.senderId}',
          );
        }
      }

      participantIds = chat.participantIds;
    } else {
      // Chat doesn't exist - need to determine participants
      // For draft chats (format: "draft-user1__user2"), extract both user IDs
      if (message.chatId.startsWith('draft-')) {
        participantIds = _extractParticipantsFromDraftId(message.chatId);
      } else {
        // For non-draft chats, only add sender (shouldn't happen in normal flow)
        participantIds = <String>[message.senderId];
      }
    }

    final docRef = _messagesCollection(message.chatId).doc();
    final messageWithId = message.copyWith(
      id: docRef.id,
      createdAt: DateTime.now(), // local copy for in-memory use
      status: MessageStatus.sent,
    );

    // Use batch for atomic operation
    final batch = _firestore.batch();

    // Write message using a raw reference so we can set createdAt to
    // FieldValue.serverTimestamp() — prevents backdating/forward-dating by
    // clients whose device clocks are wrong (M-2).
    final rawMsgRef = _firestore
        .collection(AppConstants.chatsCollection)
        .doc(message.chatId)
        .collection(AppConstants.messagesCollection)
        .doc(docRef.id);
    final messageJson = messageWithId.toJson();
    messageJson['createdAt'] = FieldValue.serverTimestamp();
    batch.set(rawMsgRef, messageJson);

    // Update or create chat's last message info.
    batch.set(
      _firestore.collection(AppConstants.chatsCollection).doc(message.chatId),
      {
        'lastMessageContent': message.content,
        'lastMessageSenderId': message.senderId,
        'lastMessageSenderName': message.senderName,
        'lastMessageType': message.type.name,
        'lastMessageAt': DateTime.now(),
        'updatedAt': DateTime.now(),
        'participantIds':
            participantIds, // Ensure both participants are in the document
        for (final participantId in participantIds)
          'deletedFor.$participantId': FieldValue.delete(),
      },
      SetOptions(merge: true),
    );

    await batch.commit();
    return docRef.id;
  }

  /// Extract participant IDs from a draft chat ID
  /// Draft chat IDs have format: "draft-user1__user2"
  List<String> _extractParticipantsFromDraftId(String draftChatId) {
    try {
      final parts = draftChatId.replaceFirst('draft-', '').split('__');
      if (parts.length == 2) {
        return parts;
      }
    } catch (_) {}
    // Fallback: shouldn't reach here in normal operation
    return <String>[];
  }

  /// Stream messages for a chat
  Stream<List<MessageModel>> streamMessages(String chatId, {int limit = 50}) {
    return _messagesCollection(chatId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Load more messages (pagination)
  Future<List<MessageModel>> loadMoreMessages({
    required String chatId,
    required DateTime beforeTimestamp,
    int limit = 20,
  }) async {
    final query = await _messagesCollection(chatId)
        .where('isDeleted', isEqualTo: false)
        .where('createdAt', isLessThan: Timestamp.fromDate(beforeTimestamp))
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return query.docs.map((doc) => doc.data()).toList();
  }

  /// Mark messages as read
  @override
  Future<void> markAsRead(String chatId, String userId) async {
    // Update all unread messages
    final unreadMessages = await _messagesCollection(
      chatId,
    ).where('readBy', whereNotIn: [userId]).get();

    final batch = _firestore.batch();

    for (final doc in unreadMessages.docs) {
      batch.update(doc.reference, {
        'readBy': FieldValue.arrayUnion([userId]),
        'status': MessageStatus.read.name,
      });
    }

    // Reset unread count
    batch.update(_chatsCollection.doc(chatId), {'unreadCounts.$userId': 0});

    await batch.commit();
  }

  /// Delete message (soft delete)
  @override
  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
  }) async {
    await _messagesCollection(chatId).doc(messageId).update({
      'isDeleted': true,
      'content': 'This message was deleted',
    });
  }

  // ==================== INTERFACE IMPLEMENTATIONS ====================

  @override
  Stream<List<ChatModel>> getUserChats(String userId) {
    return _chatsCollection
        .where('participantIds', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => doc.data())
              .where((chat) => !(chat.deletedFor[userId] ?? false))
              .toList(),
        );
  }

  @override
  Future<ChatModel?> getOrCreateDirectChat(
    String userId1,
    String userId2,
  ) async {
    // Check if chat already exists
    final query = await _chatsCollection
        .where('type', isEqualTo: ChatType.private.name)
        .where('participantIds', arrayContains: userId1)
        .get();

    for (final doc in query.docs) {
      final chat = doc.data();
      if (chat.participantIds.contains(userId2)) {
        return chat;
      }
    }

    // Chat doesn't exist, return null (caller should create it with proper user info)
    return null;
  }

  @override
  Stream<List<MessageModel>> getChatMessages(String chatId, {int limit = 50}) {
    return _messagesCollection(chatId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  @override
  Future<void> setTypingStatus(
    String chatId,
    String userId,
    bool isTyping,
  ) async {
    final typingRef = _typingCollection(chatId).doc(userId);

    if (isTyping) {
      await typingRef.set(
        TypingIndicator(
          odid: userId,
          chatId: chatId,
          displayName: '',
          startedAt: DateTime.now(),
        ),
      );
    } else {
      await typingRef.delete();
    }
  }

  @override
  Stream<Map<String, bool>> getTypingStatus(String chatId) {
    return _typingCollection(chatId).snapshots().map(
      (snapshot) => {for (final doc in snapshot.docs) doc.id: true},
    );
  }

  // ==================== EXISTING HELPER METHODS ====================

  /// Mark messages as read (original helper method with list)
  Future<void> markMessagesAsRead({
    required String chatId,
    required String odid,
    required List<String> messageIds,
  }) async {
    final batch = _firestore.batch();

    for (final messageId in messageIds) {
      batch.update(_messagesCollection(chatId).doc(messageId), {
        'readBy': FieldValue.arrayUnion([odid]),
        'status': MessageStatus.read.name,
      });
    }

    // Reset unread count
    batch.update(_chatsCollection.doc(chatId), {'unreadCounts.$odid': 0});

    await batch.commit();
  }

  /// Edit message
  Future<void> editMessage({
    required String chatId,
    required String messageId,
    required String newContent,
  }) async {
    await _messagesCollection(chatId).doc(messageId).update({
      'content': newContent,
      'isEdited': true,
      'editedAt': DateTime.now(),
    });
  }

  /// Add reaction to message
  Future<void> addReaction({
    required String chatId,
    required String messageId,
    required String odid,
    required String reaction,
  }) async {
    await _messagesCollection(chatId).doc(messageId).update({
      'reactions.$reaction': FieldValue.arrayUnion([odid]),
    });
  }

  /// Remove reaction from message
  Future<void> removeReaction({
    required String chatId,
    required String messageId,
    required String odid,
    required String reaction,
  }) async {
    await _messagesCollection(chatId).doc(messageId).update({
      'reactions.$reaction': FieldValue.arrayRemove([odid]),
    });
  }

  // ==================== TYPING INDICATORS ====================

  /// Set typing status
  Future<void> setTyping({
    required String chatId,
    required String odid,
    required String displayName,
    required bool isTyping,
  }) async {
    // FIX M-3: Write to the raw collection so we can add expiresAt = now+30s.
    // If the user kills the app while typing the indicator will auto-expire
    // rather than staying "forever" in Firestore.
    final rawTypingRef = _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .collection(AppConstants.typingCollection)
        .doc(odid);

    if (isTyping) {
      await rawTypingRef.set({
        'odid': odid,
        'displayName': displayName,
        'chatId': chatId,
        'startedAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(
          DateTime.now().add(const Duration(seconds: 30)),
        ),
      });
    } else {
      await rawTypingRef.delete();
    }
  }

  /// Stream typing indicators — only returns non-expired indicators (M-3).
  Stream<List<TypingIndicator>> streamTypingIndicators(String chatId) {
    // FIX M-3: Filter server-side to only return indicators that have not
    // yet expired, so stale indicators from killed apps are invisible.
    return _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .collection(AppConstants.typingCollection)
        .where('expiresAt', isGreaterThan: Timestamp.now())
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TypingIndicator.fromJson(doc.data()))
              .toList(),
        );
  }

  // ==================== FILE UPLOADS ====================

  /// Clear all messages in a chat for the current user (soft delete)
  @override
  Future<void> clearChat({
    required String chatId,
    required String userId,
  }) async {
    // Hide this chat only for the requesting user.
    await _chatsCollection.doc(chatId).update({
      'deletedFor.$userId': true,
      'unreadCounts.$userId': 0,
      'updatedAt': DateTime.now(),
    });
  }

  /// Upload chat image to Firebase Storage and return download URL
  @override
  Future<String> uploadChatImage({
    required String chatId,
    required File imageFile,
    required String fileName,
  }) async {
    final storageRef = _storage
        .ref()
        .child('chats')
        .child(chatId)
        .child('attachments')
        .child(fileName);
    await storageRef.putFile(imageFile);
    return storageRef.getDownloadURL();
  }

  /// Upload audio message to Firebase Storage and return download URL
  @override
  Future<String> uploadAudioMessage({
    required String chatId,
    required File audioFile,
    required String fileName,
  }) async {
    final storageRef = _storage.ref().child('chats/$chatId/audio/$fileName');
    await storageRef.putFile(audioFile);
    return storageRef.getDownloadURL();
  }
}
