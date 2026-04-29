import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/services/firebase_service.dart';
import 'package:sport_connect/features/messaging/models/message_model.dart';

part 'chat_repository.g.dart';

@Riverpod(keepAlive: true)
ChatRepository chatRepository(Ref ref) {
  return ChatRepository(
    ref.watch(firebaseServiceProvider).firestore,
    ref.watch(firebaseServiceProvider).storage,
  );
}

class ChatRepository {
  ChatRepository(this._firestore, this._storage);

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  // ── Collection references ────────────────────────────────────────────────

  CollectionReference<ChatModel> get _chatsCollection => _firestore
      .collection(AppConstants.chatsCollection)
      .withConverter(
        fromFirestore: (snap, _) => ChatModel.fromJson(snap.data()!),
        toFirestore: (chat, _) => chat.toJson(),
      );

  CollectionReference<MessageModel> _messagesCollection(String chatId) =>
      _chatsCollection
          .doc(chatId)
          .collection(AppConstants.messagesCollection)
          .withConverter(
            fromFirestore: (snap, _) => MessageModel.fromJson(snap.data()!),
            toFirestore: (msg, _) => msg.toJson(),
          );

  CollectionReference<TypingIndicator> _typingCollection(String chatId) =>
      _chatsCollection
          .doc(chatId)
          .collection(AppConstants.typingCollection)
          .withConverter(
            fromFirestore: (snap, _) => TypingIndicator.fromJson(snap.data()!),
            toFirestore: (t, _) => t.toJson(),
          );

  // ── Raw doc references (used when FieldValue sentinels are needed) ────────

  DocumentReference<Map<String, dynamic>> _rawChatRef(String chatId) =>
      _firestore.collection(AppConstants.chatsCollection).doc(chatId);

  DocumentReference<Map<String, dynamic>> _rawMessageRef(
    String chatId,
    String messageId,
  ) => _firestore
      .collection(AppConstants.chatsCollection)
      .doc(chatId)
      .collection(AppConstants.messagesCollection)
      .doc(messageId);

  // ── Chat CRUD ─────────────────────────────────────────────────────────────

  @override
  Future<String> createChat(ChatModel chat) async {
    final docRef = _chatsCollection.doc();
    final now = DateTime.now();
    await docRef.set(
      chat.copyWith(
        id: docRef.id,
        createdAt: now,
        updatedAt: now,
        lastMessageAt: chat.lastMessageAt ?? now,
      ),
    );
    return docRef.id;
  }

  @override
  Future<ChatModel> getOrCreatePrivateChat({
    required String userId1,
    required String userId2,
    required String userName1,
    required String userName2,
    String? userPhoto1,
    String? userPhoto2,
  }) async {
    final query = await _chatsCollection
        .where('type', isEqualTo: ChatType.private.name)
        .where('participantIds', arrayContains: userId1)
        .get();

    for (final doc in query.docs) {
      final chat = doc.data();
      if (chat.participantIds.contains(userId2)) return chat;
    }

    final newChat = ChatModel(
      id: '',
      participantIds: [userId1, userId2],
      participants: [
        ChatParticipant(
          userId: userId1,
          username: userName1,
          photoUrl: userPhoto1,
          joinedAt: DateTime.now(),
        ),
        ChatParticipant(
          userId: userId2,
          username: userName2,
          photoUrl: userPhoto2,
          joinedAt: DateTime.now(),
        ),
      ],
    );

    final chatId = await createChat(newChat);
    return newChat.copyWith(id: chatId);
  }

  @override
  Future<ChatModel> createRideChat({
    required String rideId,
    required String driverId,
    required String driverName,
    required String rideName,
    String? driverPhoto,
  }) async {
    final chat = ChatModel(
      id: '',
      type: ChatType.rideGroup,
      rideId: rideId,
      groupName: rideName,
      participantIds: [driverId],
      participants: [
        ChatParticipant(
          userId: driverId,
          username: driverName,
          photoUrl: driverPhoto,
          isAdmin: true,
          joinedAt: DateTime.now(),
        ),
      ],
    );
    final chatId = await createChat(chat);
    return chat.copyWith(id: chatId);
  }

  @override
  Future<ChatModel> createEventChat({
    required String eventId,
    required String creatorId,
    required String creatorName,
    required String eventName,
    String? creatorPhoto,
  }) async {
    final chat = ChatModel(
      id: '',
      type: ChatType.eventGroup,
      eventId: eventId,
      groupName: eventName,
      participantIds: [creatorId],
      participants: [
        ChatParticipant(
          userId: creatorId,
          username: creatorName,
          photoUrl: creatorPhoto,
          isAdmin: true,
          joinedAt: DateTime.now(),
        ),
      ],
    );
    final chatId = await createChat(chat);
    return chat.copyWith(id: chatId);
  }

  @override
  Future<ChatModel?> getChatById(String chatId) async {
    final doc = await _chatsCollection.doc(chatId).get();
    return doc.exists ? doc.data() : null;
  }

  @override
  Future<ChatModel?> getChatByRideId(String rideId) async {
    final query = await _chatsCollection
        .where('type', isEqualTo: ChatType.rideGroup.name)
        .where('rideId', isEqualTo: rideId)
        .limit(1)
        .get();
    return query.docs.isEmpty ? null : query.docs.first.data();
  }

  @override
  Stream<List<ChatModel>> streamUserChats(String userId) => _chatsCollection
      .where('participantIds', arrayContains: userId)
      .orderBy('lastMessageAt', descending: true)
      .snapshots()
      .map(
        (snap) => snap.docs
            .map((d) => d.data())
            .where((chat) => chat.isVisibleFor(userId))
            .toList(),
      );

  @override
  Future<ChatModel?> getOrCreateDirectChat(
    String userId1,
    String userId2,
  ) async {
    final query = await _chatsCollection
        .where('type', isEqualTo: ChatType.private.name)
        .where('participantIds', arrayContains: userId1)
        .get();

    for (final doc in query.docs) {
      final chat = doc.data();
      if (chat.participantIds.contains(userId2)) return chat;
    }
    return null;
  }

  // ── Participant management ────────────────────────────────────────────────
  @override
  Future<void> addParticipant({
    required String chatId,
    required ChatParticipant participant,
  }) async {
    await _chatsCollection.doc(chatId).update({
      'participantIds': FieldValue.arrayUnion([participant.userId]),
      'participants': FieldValue.arrayUnion([participant.toJson()]),
      // FIX: serverTimestamp instead of DateTime.now() — avoids clock skew
      // on devices whose clocks are wrong.
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Idempotent — adds [userId] to participants only if not already present.
  ///
  /// [FieldValue.arrayUnion] is atomic and idempotent at the Firestore server
  /// level, so no read-then-write transaction is required. This also sidesteps
  /// the [Transaction.get] return-type ambiguity in some cloud_firestore
  /// versions where [DocumentSnapshot.data] is typed as [Object?] rather than
  /// [Map<String, dynamic>?], causing a compile error on the `[]` operator.
  @override
  Future<void> ensureParticipant({
    required String chatId,
    required String userId,
    String? displayName,
    String? photoUrl,
  }) async {
    final updates = <String, dynamic>{
      'participantIds': FieldValue.arrayUnion([userId]),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (displayName != null) {
      updates['participants'] = FieldValue.arrayUnion([
        ChatParticipant(
          userId: userId,
          username: displayName,
          photoUrl: photoUrl,
          joinedAt: DateTime.now(),
        ).toJson(),
      ]);
    }

    await _chatsCollection.doc(chatId).update(updates);
  }

  @override
  Future<void> removeParticipant({
    required String chatId,
    required String userId,
  }) async {
    final chat = await getChatById(chatId);
    if (chat == null) return;

    await _chatsCollection.doc(chatId).update({
      'participantIds': FieldValue.arrayRemove([userId]),
      'participants': chat.participants
          .where((p) => p.userId != userId)
          .map((p) => p.toJson())
          .toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Chat settings ─────────────────────────────────────────────────────────

  @override
  Future<void> toggleMute({
    required String chatId,
    required String userId,
    required bool mute,
  }) async {
    await _chatsCollection.doc(chatId).update({
      'mutedBy.$userId': mute,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> togglePin({
    required String chatId,
    required String userId,
    required bool pin,
  }) async {
    await _chatsCollection.doc(chatId).update({
      'pinnedBy.$userId': pin,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> clearChat({
    required String chatId,
    required String userId,
  }) async {
    await _chatsCollection.doc(chatId).update({
      'deletedAtBy.$userId': FieldValue.serverTimestamp(),
      'unreadCounts.$userId': 0,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> clearChatHistoryForUser({
    required String chatId,
    required String userId,
  }) async {
    await _chatsCollection.doc(chatId).update({
      'clearedAtBy.$userId': FieldValue.serverTimestamp(),
      'unreadCounts.$userId': 0,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Messages ──────────────────────────────────────────────────────────────

  @override
  Future<String> sendMessage(MessageModel message) async {
    // Enforce message length to prevent Firestore document size abuse.
    if (message.content.length > 2000) {
      throw ArgumentError(
        'Message content must not exceed 2000 characters '
        '(got ${message.content.length}).',
      );
    }

    final chat = await getChatById(message.chatId);
    final List<String> participantIds;

    if (chat != null) {
      // Verify sender is a participant — prevents message injection by
      // authenticated users who happen to know a chatId.
      if (!chat.participantIds.contains(message.senderId)) {
        throw StateError(
          'sendMessage: ${message.senderId} is not a participant '
          'in chat ${message.chatId}',
        );
      }

      // FIX: Parallel fetch — was sequential (N+1). Fetches all recipient
      // docs concurrently before checking blocked status.
      final recipientDocs = await Future.wait(
        chat.participantIds
            .where((id) => id != message.senderId)
            .map(
              (id) => _firestore
                  .collection(AppConstants.usersCollection)
                  .doc(id)
                  .get(),
            ),
      );

      for (final doc in recipientDocs) {
        final blocked = List<String>.from(
          doc.data()?['blockedUsers'] as List? ?? [],
        );
        if (blocked.contains(message.senderId)) {
          throw StateError(
            'sendMessage: ${doc.id} has blocked ${message.senderId}',
          );
        }
      }

      participantIds = chat.participantIds;
    } else if (message.chatId.startsWith('draft-')) {
      participantIds = _extractParticipantsFromDraftId(message.chatId);

      if (participantIds.length != 2 ||
          !participantIds.contains(message.senderId)) {
        throw StateError('Invalid draft chat id: ${message.chatId}');
      }
    } else {
      throw StateError('sendMessage: chat does not exist: ${message.chatId}');
    }

    final docRef = _messagesCollection(message.chatId).doc();
    final messageWithId = message.copyWith(
      id: docRef.id,
      // Local DateTime for optimistic UI — overridden with serverTimestamp below.
      createdAt: DateTime.now(),
      status: MessageStatus.sent,
    );

    final batch = _firestore.batch();

    // FIX M-2: Override createdAt with serverTimestamp so clients with wrong
    // clocks cannot backdate or forward-date messages.
    final messageJson = messageWithId.toJson()
      ..['createdAt'] = FieldValue.serverTimestamp();
    batch.set(_rawMessageRef(message.chatId, docRef.id), messageJson);

    // FIX: Use serverTimestamp for lastMessageAt and updatedAt — was
    // DateTime.now() which propagates client clock skew to the ordering query.
    batch.set(
      _rawChatRef(message.chatId),
      {
        'lastMessageContent': message.content,
        'lastMessageSenderId': message.senderId,
        'lastMessageSenderName': message.senderName,
        'lastMessageType': message.type.name,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'participantIds': participantIds,
        'deletedAtBy.${message.senderId}': FieldValue.delete(),
      },
      SetOptions(merge: true),
    );

    await batch.commit();
    return docRef.id;
  }

  // FIX: Removed pointless try/catch — String.split and replaceFirst never
  // throw checked exceptions. The original catch silenced real errors.
  List<String> _extractParticipantsFromDraftId(String draftChatId) {
    final parts = draftChatId.replaceFirst('draft-', '').split('__');
    return parts.length == 2 ? parts : const [];
  }

  @override
  Stream<List<MessageModel>> streamMessages(String chatId, {int limit = 50}) =>
      _messagesCollection(chatId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map((snap) => snap.docs.map((d) => d.data()).toList());

  @override
  Stream<List<MessageModel>> streamMessagesForUser({
    required String chatId,
    required String userId,
    int limit = 50,
  }) {
    return _chatsCollection.doc(chatId).snapshots().asyncExpand((chatSnap) {
      final chat = chatSnap.data();
      final clearedAt = chat?.clearedAtBy[userId];

      Query<MessageModel> query = _messagesCollection(chatId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (clearedAt != null) {
        query = _messagesCollection(chatId)
            .where('isDeleted', isEqualTo: false)
            .where('createdAt', isGreaterThan: Timestamp.fromDate(clearedAt))
            .orderBy('createdAt', descending: true)
            .limit(limit);
      }

      return query.snapshots().map(
        (snap) => snap.docs.map((d) => d.data()).toList(),
      );
    });
  }

  @override
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

    return query.docs.map((d) => d.data()).toList();
  }

  // FIX: Was using `whereNotIn: [userId]` which checks the scalar field value
  // rather than array membership — always returned nothing or threw.
  // Replaced with a client-side filter after a bounded fetch.
  @override
  Future<void> markAsRead(String chatId, String userId) async {
    final snapshot = await _messagesCollection(chatId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .get();

    final unreadDocs = snapshot.docs.where((doc) {
      final msg = doc.data();
      return msg.senderId != userId && !msg.isReadBy(userId);
    }).toList();

    if (unreadDocs.isEmpty) return;

    final batch = _firestore.batch();
    for (final doc in unreadDocs) {
      batch.update(doc.reference, {
        'readBy': FieldValue.arrayUnion([userId]),
        'status': MessageStatus.read.name,
      });
    }
    batch.update(_rawChatRef(chatId), {'unreadCounts.$userId': 0});
    await batch.commit();
  }

  @override
  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
  }) => _messagesCollection(chatId).doc(messageId).update({
    'isDeleted': true,
    'content': 'This message was deleted',
  });

  @override
  Future<void> editMessage({
    required String chatId,
    required String messageId,
    required String newContent,
  }) => _rawMessageRef(chatId, messageId).update({
    'content': newContent,
    'isEdited': true,
    // FIX: serverTimestamp instead of DateTime.now().
    'editedAt': FieldValue.serverTimestamp(),
  });

  @override
  Future<void> addReaction({
    required String chatId,
    required String messageId,
    required String userId,
    required String reaction,
  }) => _messagesCollection(chatId).doc(messageId).update({
    'reactions.$reaction': FieldValue.arrayUnion([userId]),
  });

  Future<void> removeReaction({
    required String chatId,
    required String messageId,
    required String userId,
    required String reaction,
  }) => _messagesCollection(chatId).doc(messageId).update({
    'reactions.$reaction': FieldValue.arrayRemove([userId]),
  });

  // ── Typing indicators ─────────────────────────────────────────────────────

  @override
  Future<void> setTyping({
    required String chatId,
    required String userId,
    required String username,
    required bool isTyping,
  }) async {
    final ref = _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .collection(AppConstants.typingCollection)
        .doc(userId);

    if (isTyping) {
      await ref.set({
        'userId': userId,
        'username': username,
        'chatId': chatId,
        'startedAt': FieldValue.serverTimestamp(),
        // FIX M-3: expiresAt lets the server-side query filter out stale
        // indicators from users who killed the app without calling setTyping(false).
        'expiresAt': Timestamp.fromDate(
          DateTime.now().add(const Duration(seconds: 30)),
        ),
      });
    } else {
      await ref.delete();
    }
  }

  @override
  Stream<List<TypingIndicator>> streamTypingIndicators(String chatId) =>
      _firestore
          .collection(AppConstants.chatsCollection)
          .doc(chatId)
          .collection(AppConstants.typingCollection)
          .where('expiresAt', isGreaterThan: Timestamp.now())
          .snapshots()
          .map(
            (snap) => snap.docs
                .map((d) => TypingIndicator.fromJson(d.data()))
                .toList(),
          );

  // ── File uploads ──────────────────────────────────────────────────────────

  static const int _maxUploadBytes = 5 * 1024 * 1024; // 5 MB

  @override
  Future<String> uploadChatImage({
    required String chatId,
    required File imageFile,
    required String fileName,
  }) async {
    final size = await imageFile.length();
    if (size > _maxUploadBytes) {
      throw Exception('Image must be smaller than 5 MB');
    }
    final ref = _storage
        .ref()
        .child('chats')
        .child(chatId)
        .child('attachments')
        .child(fileName);
    await ref.putFile(imageFile);
    return ref.getDownloadURL();
  }

  @override
  Future<String> uploadAudioMessage({
    required String chatId,
    required File audioFile,
    required String fileName,
  }) async {
    final size = await audioFile.length();
    if (size > _maxUploadBytes) {
      throw Exception('Audio message must be smaller than 5 MB');
    }
    final ref = _storage.ref().child('chats/$chatId/audio/$fileName');
    await ref.putFile(audioFile);
    return ref.getDownloadURL();
  }

  @override
  Future<List<MessageModel>> loadMoreMessagesForUser({
    required String chatId,
    required String userId,
    required DateTime beforeTimestamp,
    int limit = 20,
  }) async {
    final chat = await getChatById(chatId);
    final clearedAt = chat?.clearedAtBy[userId];

    Query<MessageModel> query = _messagesCollection(chatId)
        .where('isDeleted', isEqualTo: false)
        .where('createdAt', isLessThan: Timestamp.fromDate(beforeTimestamp))
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (clearedAt != null) {
      query = _messagesCollection(chatId)
          .where('isDeleted', isEqualTo: false)
          .where('createdAt', isGreaterThan: Timestamp.fromDate(clearedAt))
          .where('createdAt', isLessThan: Timestamp.fromDate(beforeTimestamp))
          .orderBy('createdAt', descending: true)
          .limit(limit);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((d) => d.data()).toList();
  }
}
