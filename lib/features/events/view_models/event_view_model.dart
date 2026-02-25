import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/models/location/location_point.dart';
import 'package:sport_connect/features/events/models/event_model.dart';
import 'package:sport_connect/features/events/repositories/event_repository.dart';

part 'event_view_model.g.dart';

// ---------------------------------------------------------------------------
// Selection state (used inside event-picker sheets)
// ---------------------------------------------------------------------------

class EventSelectionState {
  const EventSelectionState({
    this.selectedEvent,
    this.filterType,
    this.searchQuery = '',
    this.isLoading = false,
    this.error,
  });

  final EventModel? selectedEvent;
  final EventType? filterType;
  final String searchQuery;
  final bool isLoading;
  final String? error;

  EventSelectionState copyWith({
    EventModel? selectedEvent,
    bool clearSelectedEvent = false,
    EventType? filterType,
    bool clearFilterType = false,
    String? searchQuery,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return EventSelectionState(
      selectedEvent: clearSelectedEvent
          ? null
          : (selectedEvent ?? this.selectedEvent),
      filterType: clearFilterType ? null : (filterType ?? this.filterType),
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

@riverpod
class EventSelectionViewModel extends _$EventSelectionViewModel {
  @override
  EventSelectionState build() => const EventSelectionState();

  /// Sets the currently selected event.
  void selectEvent(EventModel event) {
    state = state.copyWith(selectedEvent: event, clearError: true);
  }

  /// Clears the current selection.
  void clearSelection() {
    state = state.copyWith(clearSelectedEvent: true);
  }

  /// Sets or clears the sport-type filter chip.
  void setFilterType(EventType? type) {
    if (type == state.filterType || type == null) {
      state = state.copyWith(clearFilterType: true);
    } else {
      state = state.copyWith(filterType: type);
    }
  }

  /// Sets the search query for client-side filtering.
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Creates a new event and auto-selects it on success.
  Future<EventModel?> createEvent({
    required String creatorId,
    required String title,
    required EventType type,
    required LocationPoint location,
    required DateTime startsAt,
    DateTime? endsAt,
    String? description,
    String? venueName,
    String? organizerName,
    int maxParticipants = 0,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final event = EventModel(
        id: '',
        creatorId: creatorId,
        title: title.trim(),
        type: type,
        location: location,
        startsAt: startsAt,
        endsAt: endsAt,
        description: description?.trim().isEmpty ?? true
            ? null
            : description!.trim(),
        venueName: venueName?.trim().isEmpty ?? true ? null : venueName!.trim(),
        organizerName: organizerName?.trim().isEmpty ?? true
            ? null
            : organizerName!.trim(),
        maxParticipants: maxParticipants,
      );

      final eventId = await ref
          .read(eventRepositoryProvider)
          .createEvent(event);

      // Guard against provider disposal during the async gap
      if (!ref.mounted) return null;

      final created = event.copyWith(id: eventId);
      state = state.copyWith(isLoading: false, selectedEvent: created);
      return created;
    } catch (_) {
      if (!ref.mounted) return null;
      state = state.copyWith(
        isLoading: false,
        error: 'Unable to create event. Please try again.',
      );
      return null;
    }
  }
}

// ---------------------------------------------------------------------------
// Event detail view model — manages join/leave and single-event actions
// ---------------------------------------------------------------------------

class EventDetailState {
  const EventDetailState({
    this.isJoining = false,
    this.isLeaving = false,
    this.isDeleting = false,
    this.error,
    this.successMessage,
  });

  final bool isJoining;
  final bool isLeaving;
  final bool isDeleting;
  final String? error;
  final String? successMessage;

  EventDetailState copyWith({
    bool? isJoining,
    bool? isLeaving,
    bool? isDeleting,
    String? error,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return EventDetailState(
      isJoining: isJoining ?? this.isJoining,
      isLeaving: isLeaving ?? this.isLeaving,
      isDeleting: isDeleting ?? this.isDeleting,
      error: clearError ? null : (error ?? this.error),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}

@riverpod
class EventDetailViewModel extends _$EventDetailViewModel {
  @override
  EventDetailState build() => const EventDetailState();

  /// Joins the current user to the event.
  Future<bool> joinEvent(String eventId, String userId) async {
    state = state.copyWith(isJoining: true, clearError: true, clearSuccess: true);
    try {
      await ref.read(eventRepositoryProvider).joinEvent(eventId, userId);
      if (!ref.mounted) return false;
      state = state.copyWith(
        isJoining: false,
        successMessage: 'You joined the event!',
      );
      return true;
    } catch (_) {
      if (!ref.mounted) return false;
      state = state.copyWith(
        isJoining: false,
        error: 'Unable to join event. Please try again.',
      );
      return false;
    }
  }

  /// Leaves the event.
  Future<bool> leaveEvent(String eventId, String userId) async {
    state = state.copyWith(isLeaving: true, clearError: true, clearSuccess: true);
    try {
      await ref.read(eventRepositoryProvider).leaveEvent(eventId, userId);
      if (!ref.mounted) return false;
      state = state.copyWith(
        isLeaving: false,
        successMessage: 'You left the event.',
      );
      return true;
    } catch (_) {
      if (!ref.mounted) return false;
      state = state.copyWith(
        isLeaving: false,
        error: 'Unable to leave event. Please try again.',
      );
      return false;
    }
  }

  /// Deletes the event (only creator should call this).
  Future<bool> deleteEvent(String eventId) async {
    state = state.copyWith(isDeleting: true, clearError: true);
    try {
      await ref.read(eventRepositoryProvider).deleteEvent(eventId);
      if (!ref.mounted) return false;
      state = state.copyWith(isDeleting: false);
      return true;
    } catch (_) {
      if (!ref.mounted) return false;
      state = state.copyWith(
        isDeleting: false,
        error: 'Unable to delete event. Please try again.',
      );
      return false;
    }
  }

  /// Clears any error or success message.
  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }
}

// ---------------------------------------------------------------------------
// Stream providers
// ---------------------------------------------------------------------------

@riverpod
Stream<List<EventModel>> upcomingEventsStream(Ref ref) {
  return ref.watch(eventRepositoryProvider).streamUpcomingEvents();
}

@riverpod
Stream<List<EventModel>> eventsByTypeStream(Ref ref, EventType type) {
  return ref.watch(eventRepositoryProvider).streamEventsByType(type);
}

@riverpod
Stream<List<EventModel>> eventsByCreatorStream(Ref ref, String creatorId) {
  return ref.watch(eventRepositoryProvider).streamEventsByCreator(creatorId);
}

@riverpod
Stream<List<EventModel>> joinedEventsStream(Ref ref, String userId) {
  return ref.watch(eventRepositoryProvider).streamJoinedEvents(userId);
}

@riverpod
Future<EventModel?> eventById(Ref ref, String eventId) async {
  return ref.watch(eventRepositoryProvider).getEventById(eventId);
}
