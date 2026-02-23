import 'package:sport_connect/features/events/models/event_model.dart';

/// Events operations repository interface.
abstract class IEventRepository {
  Future<String> createEvent(EventModel event);
  Future<EventModel?> getEventById(String eventId);
  Future<void> updateEvent(EventModel event);
  Future<void> deleteEvent(String eventId);
  Stream<List<EventModel>> streamUpcomingEvents();
  Stream<List<EventModel>> streamEventsByCreator(String creatorId);
  Stream<List<EventModel>> streamEventsByType(EventType type);
}
