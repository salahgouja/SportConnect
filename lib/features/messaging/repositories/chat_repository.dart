import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/interfaces/repositories/i_chat_repository.dart';
import 'package:sport_connect/core/models/models.dart';
import 'package:sport_connect/core/providers/firebase_providers.dart';
import 'package:sport_connect/features/messaging/models/message_model.dart';

part 'chat_repository.g.dart';

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
  CollectionReference<UserModel> get _usersCollection => _firestore
      .collection(AppConstants.usersCollection)
      .withConverter<UserModel>(
        fromFirestore: (snapshot, _) => UserModel.fromJson(snapshot.data()!),
        toFirestore: (user, _) => user.toJson(),
      );

  /// Sub-collection stores metadata only: {blockedAt, chatId}.
  /// No [UserModel] converter — the documents are not user documents.
  CollectionReference _blockedUsersCollection(String userId) => _firestore
      .collection(AppConstants.usersCollection)
      .doc(userId)
      .collection(AppConstants.blockedUsersCollection);

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

  /// Get chat by ID
  @override
  Future<ChatModel?> getChatById(String chatId) async {
    final doc = await _chatsCollection.doc(chatId).get();
    if (!doc.exists) return null;
    return doc.data();
  }

  /// Stream user's chats
  Stream<List<ChatModel>> streamUserChats(String userId) {
    return _chatsCollection
        .where('participantIds', arrayContains: userId)
        // .where('isActive', isEqualTo: true)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
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
    final docRef = _messagesCollection(message.chatId).doc();
    final messageWithId = message.copyWith(
      id: docRef.id,
      createdAt: DateTime.now(),
      status: MessageStatus.sent,
    );

    // Use batch for atomic operation
    final batch = _firestore.batch();

    // Add message
    batch.set(docRef, messageWithId.toJson());

    // Update or create chat's last message info
    // Using set with merge to handle cases where chat might not exist yet
    batch.set(_chatsCollection.doc(message.chatId), {
      'lastMessageContent': message.content,
      'lastMessageSenderId': message.senderId,
      'lastMessageSenderName': message.senderName,
      'lastMessageType': message.type.name,
      'lastMessageAt': DateTime.now(),
      'updatedAt': DateTime.now(),
    }, SetOptions(merge: true));

    await batch.commit();
    return docRef.id;
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
  Future<void> deleteMessage(String messageId) async {
    // Find the message across all chats (this is inefficient, better to pass chatId)
    // For now, we'll need to query or change interface to include chatId
    // Implementing a version that requires knowing the chatId
    throw UnimplementedError(
      'deleteMessage requires chatId parameter. Use deleteChatMessage instead.',
    );
  }

  /// Delete message with chatId (helper method)
  Future<void> deleteChatMessage({
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
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
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
    final typingRef = _typingCollection(chatId).doc(odid);

    if (isTyping) {
      await typingRef.set(
        TypingIndicator(
          odid: odid,
          displayName: displayName,
          chatId: chatId,
          startedAt: DateTime.now(),
        ),
      );
    } else {
      await typingRef.delete();
    }
  }

  /// Stream typing indicators
  Stream<List<TypingIndicator>> streamTypingIndicators(String chatId) {
    return _typingCollection(chatId).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
    );
  }

  // ==================== ONLINE STATUS ====================

  /// Update online status
  Future<void> updateOnlineStatus({
    required String chatId,
    required String odid,
    required bool isOnline,
  }) async {
    final chat = await getChatById(chatId);
    if (chat == null) return;

    final updatedParticipants = chat.participants.map((p) {
      if (p.odid == odid) {
        return p.copyWith(
          isOnline: isOnline,
          lastSeenAt: isOnline ? null : DateTime.now(),
        );
      }
      return p;
    }).toList();

    await _chatsCollection.doc(chatId).update({
      'participants': updatedParticipants.map((p) => p.toJson()).toList(),
    });
  }

  // ==================== FILE UPLOADS ====================

  /// Clear all messages in a chat for the current user (soft delete)
  Future<void> clearChat({
    required String chatId,
    required String userId,
  }) async {
    // Set a 'clearedAt' timestamp for this user so the client
    // filters out messages sent before this point.
    await _chatsCollection.doc(chatId).update({
      'clearedAt.$userId': DateTime.now(),
    });
  }

  /// Block a user atomically:
  /// 1. Writes metadata to the blocked-users sub-collection.
  /// 2. Adds the UID to the [UserModel.blockedUsers] array for fast query filtering.
  /// 3. Auto-mutes the chat in the same batch.
  Future<void> blockUser({
    required String chatId,
    required String userId,
    required String blockedUserId,
  }) async {
    final batch = _firestore.batch();

    // 1. Write block metadata to sub-collection
    final blockDoc = _blockedUsersCollection(userId).doc(blockedUserId);
    batch.set(blockDoc, {
      'blockedAt': FieldValue.serverTimestamp(),
      'chatId': chatId,
    });

    // 2. Mirror the UID into the UserModel.blockedUsers array for fast Firestore queries
    final userDoc = _usersCollection.doc(userId);
    batch.update(userDoc, {
      'blockedUsers': FieldValue.arrayUnion([blockedUserId]),
    });

    // 3. Mute the chat for the blocker
    batch.set(_chatsCollection.doc(chatId), {
      'mutedBy.$userId': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await batch.commit();
  }

  /// Unblock a user atomically — reverses every write done in [blockUser].
  Future<void> unblockUser({
    required String userId,
    required String blockedUserId,
    String? chatId,
  }) async {
    final batch = _firestore.batch();

    // 1. Remove sub-collection document
    final blockDoc = _blockedUsersCollection(userId).doc(blockedUserId);
    batch.delete(blockDoc);

    // 2. Remove from UserModel.blockedUsers array
    final userDoc = _usersCollection.doc(userId);
    batch.update(userDoc, {
      'blockedUsers': FieldValue.arrayRemove([blockedUserId]),
    });

    // 3. Unmute the chat if provided
    if (chatId != null) {
      batch.set(_chatsCollection.doc(chatId), {
        'mutedBy.$userId': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }

  /// Returns whether [blockedUserId] is blocked by [userId].
  /// Reads a single document — O(1), safe to call before sending messages.
  Future<bool> isUserBlocked({
    required String userId,
    required String blockedUserId,
  }) async {
    final doc = await _blockedUsersCollection(userId).doc(blockedUserId).get();
    return doc.exists;
  }

  /// Streams the list of blocked UIDs for [userId].
  /// Backed by the sub-collection so the UI reacts in real time.
  Stream<List<String>> streamBlockedUserIds(String userId) {
    return _blockedUsersCollection(userId).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => doc.id).toList(),
    );
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
        .child('chat_images')
        .child(chatId)
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
    final storageRef = _storage
        .ref()
        .child('chats/$chatId/audio/$fileName');
    await storageRef.putFile(audioFile);
    return storageRef.getDownloadURL();
  }
}

@riverpod
IChatRepository chatRepository(Ref ref) {
  return ChatRepository(
    ref.watch(firestoreInstanceProvider),
    ref.watch(storageInstanceProvider),
  );
}
