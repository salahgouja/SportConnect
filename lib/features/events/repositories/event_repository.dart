import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/interfaces/repositories/i_event_repository.dart';
import 'package:sport_connect/core/providers/firebase_providers.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/features/events/models/event_model.dart';

part 'event_repository.g.dart';

class EventRepository implements IEventRepository {
  EventRepository(this._firestore, this._storage);

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CollectionReference<EventModel> get _eventsCollection => _firestore
      .collection(AppConstants.eventsCollection)
      .withConverter(
        fromFirestore: (snap, _) => EventModel.fromJson(snap.data()!),
        toFirestore: (model, _) => model.toJson(),
      );

  @override
  Future<String> createEvent(EventModel event) async {
    final docRef = _eventsCollection.doc();
    final eventWithId = event.copyWith(
      id: docRef.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    TalkerService.info(
      'createEvent → docId=${docRef.id}, '
      'title=${eventWithId.title}, '
      'type=${eventWithId.type}, '
      'startsAt=${eventWithId.startsAt}',
    );

    await docRef.set(eventWithId);
    return docRef.id;
  }

  @override
  Future<EventModel?> getEventById(String eventId) async {
    final doc = await _eventsCollection.doc(eventId).get();
    if (!doc.exists) return null;
    return doc.data();
  }

  @override
  Stream<EventModel?> streamEventById(String eventId) {
    return _eventsCollection
        .doc(eventId)
        .snapshots()
        .map((snap) => snap.exists ? snap.data() : null);
  }

  @override
  Future<void> updateEvent(EventModel event) async {
    await _eventsCollection.doc(event.id).update({
      ...event.toJson(),
      'updatedAt': DateTime.now(),
    });
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    await _eventsCollection.doc(eventId).delete();
  }

  @override
  Future<void> cancelEvent(String eventId) async {
    await _eventsCollection.doc(eventId).update({
      'isActive': false,
      'updatedAt': DateTime.now(),
    });
  }

  @override
  Future<void> joinEvent(String eventId, String userId) async {
    final docRef = _eventsCollection.doc(eventId);

    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      if (!snap.exists) throw Exception('Event not found.');

      final data = snap.data()!;
      final participants = List<String>.from(data.participantIds);
      final maxParticipants = data.maxParticipants;

      if (participants.contains(userId)) return;

      if (maxParticipants > 0 && participants.length >= maxParticipants) {
        throw Exception('Event is full.');
      }

      tx.update(docRef, {
        'participantIds': FieldValue.arrayUnion([userId]),
        'updatedAt': DateTime.now(),
      });
    });
  }

  @override
  Future<void> leaveEvent(String eventId, String userId) async {
    await _eventsCollection.doc(eventId).update({
      'participantIds': FieldValue.arrayRemove([userId]),
      'updatedAt': DateTime.now(),
    });
  }

  @override
  Stream<List<EventModel>> streamUpcomingEvents() {
    return _eventsCollection
        .where('isActive', isEqualTo: true)
        .where('startsAt', isGreaterThan: Timestamp.now())
        .orderBy('startsAt')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => doc.data()).toList();
        });
  }

  @override
  Stream<List<EventModel>> streamEventsByCreator(String creatorId) {
    return _eventsCollection
        .where('creatorId', isEqualTo: creatorId)
        .orderBy('startsAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => doc.data()).toList();
        });
  }

  @override
  Stream<List<EventModel>> streamEventsByType(EventType type) {
    return _eventsCollection
        .where('isActive', isEqualTo: true)
        .where('type', isEqualTo: type.jsonValue)
        .where('startsAt', isGreaterThan: Timestamp.now())
        .orderBy('startsAt')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => doc.data()).toList();
        });
  }

  @override
  Stream<List<EventModel>> streamJoinedEvents(String userId) {
    return _eventsCollection
        .where('participantIds', arrayContains: userId)
        .where('isActive', isEqualTo: true)
        .orderBy('startsAt')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => doc.data()).toList();
        });
  }

  @override
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
}

@riverpod
IEventRepository eventRepository(Ref ref) {
  return EventRepository(
    ref.watch(firestoreInstanceProvider),
    ref.watch(storageInstanceProvider),
  );
}
