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
    if (type == state.filterType) {
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
