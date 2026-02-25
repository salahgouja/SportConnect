import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/interfaces/repositories/i_event_repository.dart';
import 'package:sport_connect/features/events/models/event_model.dart';

part 'event_repository.g.dart';

class EventRepository implements IEventRepository {
  EventRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<EventModel> get _eventsCollection =>
      _firestore.collection(AppConstants.eventsCollection).withConverter(
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
  Future<void> updateEvent(EventModel event) async {
    await _eventsCollection.doc(event.id).update({
      ...event.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    await _eventsCollection.doc(eventId).delete();
  }

  @override
  Future<void> joinEvent(String eventId, String userId) async {
    await _firestore
        .collection(AppConstants.eventsCollection)
        .doc(eventId)
        .update({
      'participantIds': FieldValue.arrayUnion([userId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> leaveEvent(String eventId, String userId) async {
    await _firestore
        .collection(AppConstants.eventsCollection)
        .doc(eventId)
        .update({
      'participantIds': FieldValue.arrayRemove([userId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<List<EventModel>> streamUpcomingEvents() {
    return _eventsCollection
        .where('isActive', isEqualTo: true)
        .where('startsAt', isGreaterThan: FieldValue.serverTimestamp())
        .orderBy('startsAt')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => doc.data())
              .toList();
        });
  }

  @override
  Stream<List<EventModel>> streamEventsByCreator(String creatorId) {
    return _eventsCollection
        .where('creatorId', isEqualTo: creatorId)
        .orderBy('startsAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => doc.data())
              .toList();
        });
  }

  @override
  Stream<List<EventModel>> streamEventsByType(EventType type) {
    return _eventsCollection
        .where('isActive', isEqualTo: true)
        .where('type', isEqualTo: type)
        .where('startsAt', isGreaterThan: Timestamp.now())
        .orderBy('startsAt')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => doc.data())
              .toList();
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
          return snapshot.docs
              .map((doc) => doc.data())
              .toList();
        });
  }
}

@Riverpod(keepAlive: true)
IEventRepository eventRepository(Ref ref) {
  return EventRepository(FirebaseFirestore.instance);
}
