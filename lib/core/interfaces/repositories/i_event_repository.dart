import 'dart:io';

import 'package:sport_connect/core/models/location/location_point.dart';
import 'package:sport_connect/features/events/models/event_model.dart';

/// Events operations repository interface.
abstract class IEventRepository {
  Future<String> createEvent(EventModel event);
  Future<EventModel?> getEventById(String eventId);
  Stream<EventModel?> streamEventById(String eventId);
  Future<void> updateEvent(EventModel event);
  Future<void> deleteEvent(String eventId);

  /// Soft-deletes the event by setting isActive to false.
  Future<void> cancelEvent(String eventId);

  /// Adds [userId] to the event's participant list atomically.
  Future<void> joinEvent(String eventId, String userId);

  /// Removes [userId] from the event's participant list atomically.
  Future<void> leaveEvent(String eventId, String userId);

  Stream<List<EventModel>> streamUpcomingEvents();
  Stream<List<EventModel>> streamEventsByCreator(String creatorId);
  Stream<List<EventModel>> streamEventsByType(EventType type);

  /// Streams events the given [userId] has joined.
  Stream<List<EventModel>> streamJoinedEvents(String userId);

  /// Uploads an event cover image and returns its download URL.
  Future<String> uploadEventImage(String eventId, File file);

  // ── Event-Ride Integration ──

  /// Sets the ride status for a participant: 'driving', 'need_ride', 'self_arranged'.
  Future<void> setRideStatus(String eventId, String userId, String status);

  /// Links a ride to an event.
  Future<void> linkRideToEvent(String eventId, String rideId);

  /// Unlinks a ride from an event.
  Future<void> unlinkRideFromEvent(String eventId, String rideId);

  /// Sets the meetup pin location for post-event coordination.
  Future<void> setMeetupPin(String eventId, LocationPoint location);

  /// Sets the chat group ID for the event.
  Future<void> setChatGroupId(String eventId, String chatGroupId);

  /// Streams rides linked to a specific event.
  Stream<List<EventModel>> streamEventsWithLinkedRides(String eventId);
}
