import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/models/location/location_point.dart';
import 'package:sport_connect/core/services/firebase_service.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/features/events/models/event_model.dart';
import 'package:sport_connect/features/messaging/models/message_model.dart';

part 'event_repository.g.dart';

@Riverpod(keepAlive: true)
EventRepository eventRepository(Ref ref) {
  return EventRepository(
    ref.watch(firebaseServiceProvider).firestore,
    ref.watch(firebaseServiceProvider).storage,
  );
}

class EventPageCursor {
  const EventPageCursor._(this.document);

  final DocumentSnapshot<EventModel> document;
}

class EventPage {
  const EventPage({
    required this.events,
    required this.hasMore,
    this.nextCursor,
  });

  final List<EventModel> events;
  final EventPageCursor? nextCursor;
  final bool hasMore;
}

class EventRepository {
  EventRepository(this._firestore, this._storage);

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  Future<bool> _isPremiumSubscriber({
    required Transaction tx,
    required String userId,
  }) async {
    final userSnap = await tx.get(
      _firestore.collection(AppConstants.usersCollection).doc(userId),
    );
    final userData = userSnap.data();
    return userData is Map<String, dynamic> && userData['isPremium'] == true;
  }

  List<String> _premiumEventChatParticipants({
    required bool creatorIsPremium,
    required String creatorId,
    required bool userIsPremium,
    required String userId,
  }) {
    return <String>{
      creatorId,
      if (userIsPremium) userId,
    }.toList();
  }

  String _resolveEventChatId(EventModel event) {
    final configuredChatId = event.chatGroupId?.trim();
    if (configuredChatId != null && configuredChatId.isNotEmpty) {
      return configuredChatId;
    }
    return event.id;
  }

  Map<String, dynamic> _eventChatCreatePayload({
    required String chatId,
    required EventModel event,
    required List<String> participantIds,
    required DateTime now,
  }) {
    return {
      'id': chatId,
      'type': ChatType.eventGroup.name,
      'eventId': event.id,
      'premiumOnly': true,
      'groupName': event.title,
      if ((event.imageUrl ?? '').isNotEmpty) 'groupPhotoUrl': event.imageUrl,

      'participantIds': participantIds,
      'participants': <Map<String, dynamic>>[],

      'lastMessageContent': null,
      'lastMessageSenderId': null,
      'lastMessageSenderName': null,
      'lastMessageType': MessageType.system.name,

      'unreadCounts': <String, int>{},
      'mutedBy': <String, bool>{},
      'pinnedBy': <String, bool>{},

      // New timestamp-based visibility fields.
      'deletedAtBy': <String, dynamic>{},
      'clearedAtBy': <String, dynamic>{},

      'isActive': true,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> _eventChatMergePayload({
    required List<String> participantIds,
  }) {
    return {
      if (participantIds.isNotEmpty)
        'participantIds': FieldValue.arrayUnion(participantIds),

      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  CollectionReference<EventModel> get _eventsCollection => _firestore
      .collection(AppConstants.eventsCollection)
      .withConverter(
        fromFirestore: (snap, _) => EventModel.fromJson(snap.data()!),
        toFirestore: (model, _) => model.toJson(),
      );

  Future<String> createEvent(EventModel event) async {
    final docRef = _eventsCollection.doc();
    final eventWithId = event.copyWith(
      id: docRef.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final recurringInfo = eventWithId.isRecurring
        ? 'recurring=true, pattern=${eventWithId.recurringPattern?.label}, endDate=${eventWithId.recurringEndDate}'
        : 'recurring=false';

    TalkerService.info(
      'createEvent → docId=${docRef.id}, '
      'title=${eventWithId.title}, '
      'type=${eventWithId.type}, '
      'startsAt=${eventWithId.startsAt}, '
      '$recurringInfo',
    );

    await docRef.set(eventWithId);
    return docRef.id;
  }

  Future<EventModel?> getEventById(String eventId) async {
    final doc = await _eventsCollection.doc(eventId).get();
    if (!doc.exists) return null;
    return doc.data();
  }

  Stream<EventModel?> streamEventById(String eventId) {
    return _eventsCollection
        .doc(eventId)
        .snapshots()
        .map((snap) => snap.exists ? snap.data() : null);
  }

  Future<void> updateEvent(EventModel event) async {
    await _eventsCollection.doc(event.id).update({
      ...event.toJson(),
      'updatedAt': DateTime.now(),
    });
  }

  Future<void> deleteEvent(String eventId) async {
    await _eventsCollection.doc(eventId).delete();
  }

  Future<void> cancelEvent(String eventId) async {
    await _eventsCollection.doc(eventId).update({
      'isActive': false,
      'updatedAt': DateTime.now(),
    });
  }

  Future<void> joinEvent(String eventId, String userId) async {
    final docRef = _eventsCollection.doc(eventId);
    final now = DateTime.now();

    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      if (!snap.exists) {
        throw Exception('Event not found.');
      }

      final event = snap.data()!;
      final participants = List<String>.from(event.participantIds);

      if (participants.contains(userId)) {
        return;
      }

      final maxParticipants = event.maxParticipants;
      if (maxParticipants > 0 && participants.length >= maxParticipants) {
        throw Exception('Event is full.');
      }

      tx.update(docRef, {
        'participantIds': FieldValue.arrayUnion([userId]),
        'updatedAt': now,
      });
    });
  }

  Future<String> ensureEventGroupChat({
    required EventModel event,
    required String userId,
  }) async {
    final now = DateTime.now();
    final eventRef = _eventsCollection.doc(event.id);

    return _firestore.runTransaction((tx) async {
      final eventSnap = await tx.get(eventRef);
      final latestEvent = eventSnap.exists ? eventSnap.data()! : event;

      final isParticipant =
          latestEvent.participantIds.contains(userId) ||
          latestEvent.creatorId == userId;

      if (!isParticipant) {
        throw Exception('Join the event before opening the group chat.');
      }

      final userIsPremium = await _isPremiumSubscriber(
        tx: tx,
        userId: userId,
      );

      if (!userIsPremium) {
        throw Exception(
          'Event group chat is a Premium feature. Upgrade to access attendee chat.',
        );
      }

      final creatorIsPremium = await _isPremiumSubscriber(
        tx: tx,
        userId: latestEvent.creatorId,
      );

      final chatId = _resolveEventChatId(latestEvent);

      final participantIds = _premiumEventChatParticipants(
        creatorIsPremium: creatorIsPremium,
        creatorId: latestEvent.creatorId,
        userIsPremium: userIsPremium,
        userId: userId,
      );

      final chatRef = _firestore
          .collection(AppConstants.chatsCollection)
          .doc(chatId);

      final chatSnap = await tx.get(chatRef);

      if (chatSnap.exists) {
        tx.set(
          chatRef,
          _eventChatMergePayload(participantIds: participantIds),
          SetOptions(merge: true),
        );
      } else {
        tx.set(
          chatRef,
          _eventChatCreatePayload(
            chatId: chatId,
            event: latestEvent,
            participantIds: participantIds,
            now: now,
          ),
        );
      }

      return chatId;
    });
  }

  Future<void> leaveEvent(String eventId, String userId) async {
    final docRef = _eventsCollection.doc(eventId);
    final now = DateTime.now();

    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      if (!snap.exists) {
        throw Exception('Event not found.');
      }

      final event = snap.data()!;
      final participants = List<String>.from(event.participantIds);

      if (!participants.contains(userId)) {
        return;
      }

      tx.update(docRef, {
        'participantIds': FieldValue.arrayRemove([userId]),
        'updatedAt': now,
      });
    });
  }

  Stream<List<EventModel>> streamUpcomingEvents() {
    return _eventsCollection
        .where('isActive', isEqualTo: true)
        .where('startsAt', isGreaterThan: Timestamp.now())
        .orderBy('startsAt')
        .limit(50)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => doc.data()).toList();
        });
  }

  Future<EventPage> fetchUpcomingEventsPage({
    EventType? type,
    EventPageCursor? startAfter,
    int limit = 30,
  }) async {
    var query = _eventsCollection
        .where('isActive', isEqualTo: true)
        .where('startsAt', isGreaterThan: Timestamp.now());

    if (type != null) {
      query = query.where('type', isEqualTo: type.jsonValue);
    }

    query = query.orderBy('startsAt').limit(limit);

    final cursor = startAfter;
    if (cursor != null) {
      query = query.startAfterDocument(cursor.document);
    }

    final snapshot = await query.get();
    final docs = snapshot.docs;

    return EventPage(
      events: docs.map((doc) => doc.data()).toList(),
      nextCursor: docs.isEmpty ? null : EventPageCursor._(docs.last),
      hasMore: docs.length == limit,
    );
  }

  Stream<List<EventModel>> streamEventsByCreator(String creatorId) {
    return _eventsCollection
        .where('creatorId', isEqualTo: creatorId)
        .orderBy('startsAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => doc.data()).toList();
        });
  }

  Stream<List<EventModel>> streamEventsByType(EventType type) {
    return _eventsCollection
        .where('isActive', isEqualTo: true)
        .where('type', isEqualTo: type.jsonValue)
        .where('startsAt', isGreaterThan: Timestamp.now())
        .orderBy('startsAt')
        .limit(50)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => doc.data()).toList();
        });
  }

  Stream<List<EventModel>> streamJoinedEvents(String userId) {
    return _eventsCollection
        .where('participantIds', arrayContains: userId)
        .where('isActive', isEqualTo: true)
        .orderBy('startsAt')
        .limit(50)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => doc.data()).toList();
        });
  }

  Future<String> uploadEventImage(String eventId, File file) async {
    final ref = _storage
        .ref()
        .child('events')
        .child(eventId)
        .child('cover.jpg');
    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: {'eventId': eventId},
    );
    await ref.putFile(file, metadata);
    return ref.getDownloadURL();
  }

  // ── Event-Ride Integration ──

  Future<void> setRideStatus(
    String eventId,
    String userId,
    String status,
  ) async {
    await _eventsCollection.doc(eventId).update({
      'rideStatuses.$userId': status,
      'updatedAt': DateTime.now(),
    });
  }

  Future<void> linkRideToEvent(String eventId, String rideId) async {
    await _eventsCollection.doc(eventId).update({
      'linkedRideIds': FieldValue.arrayUnion([rideId]),
      'updatedAt': DateTime.now(),
    });
  }

  Future<void> unlinkRideFromEvent(String eventId, String rideId) async {
    await _eventsCollection.doc(eventId).update({
      'linkedRideIds': FieldValue.arrayRemove([rideId]),
      'updatedAt': DateTime.now(),
    });
  }

  Future<void> setMeetupPin(String eventId, LocationPoint location) async {
    await _eventsCollection.doc(eventId).update({
      'meetupPinLocation': location.toJson(),
      'updatedAt': DateTime.now(),
    });
  }

  Future<void> setChatGroupId(String eventId, String chatGroupId) async {
    await _eventsCollection.doc(eventId).update({
      'chatGroupId': chatGroupId,
      'updatedAt': DateTime.now(),
    });
  }

  Stream<List<EventModel>> streamEventsWithLinkedRides(String eventId) {
    // This queries events that have at least one linked ride
    return _eventsCollection
        .where('linkedRideIds', arrayContains: eventId)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
