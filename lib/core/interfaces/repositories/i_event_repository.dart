import 'package:sport_connect/features/events/models/event_model.dart';

/// Events operations repository interface.
abstract class IEventRepository {
  Future<String> createEvent(EventModel event);
  Future<EventModel?> getEventById(String eventId);
  Future<void> updateEvent(EventModel event);
  Future<void> deleteEvent(String eventId);

  /// Adds [userId] to the event's participant list atomically.
  Future<void> joinEvent(String eventId, String userId);

  /// Removes [userId] from the event's participant list atomically.
  Future<void> leaveEvent(String eventId, String userId);

  Stream<List<EventModel>> streamUpcomingEvents();
  Stream<List<EventModel>> streamEventsByCreator(String creatorId);
  Stream<List<EventModel>> streamEventsByType(EventType type);

  /// Streams events the given [userId] has joined.
  Stream<List<EventModel>> streamJoinedEvents(String userId);
}
