import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/models/location/location_point.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/features/events/models/event_model.dart';
import 'package:sport_connect/core/providers/repository_providers.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';

part 'event_view_model.g.dart';

// ---------------------------------------------------------------------------
// Create-event form state
// ---------------------------------------------------------------------------

class CreateEventSubmissionResult {
  const CreateEventSubmissionResult({required this.event, this.warningMessage});

  final EventModel event;
  final String? warningMessage;
}

class CreateEventFormState {
  CreateEventFormState({
    this.title = '',
    this.venueName = '',
    this.description = '',
    this.type = EventType.running,
    DateTime? startsAt,
    this.endsAt,
    this.location,
    this.maxParticipants = 0,
    this.imageFile,
    this.isRecurring = false,
    this.recurringDays = const [],
    this.recurringEndDate,
    this.costSplitEnabled = false,
    this.isSubmitting = false,
    this.isUploadingImage = false,
    this.hasAttemptedSubmit = false,
    this.error,
    this.warningMessage,
  }) : startsAt = startsAt ?? DateTime.now().add(const Duration(hours: 2));

  factory CreateEventFormState.initial() => CreateEventFormState(
    startsAt: DateTime.now().add(const Duration(hours: 2)),
  );

  final String title;
  final String venueName;
  final String description;
  final EventType type;
  final DateTime startsAt;
  final DateTime? endsAt;
  final LocationPoint? location;
  final int maxParticipants;
  final File? imageFile;
  final bool isRecurring;
  final List<int> recurringDays;
  final DateTime? recurringEndDate;
  final bool costSplitEnabled;
  final bool isSubmitting;
  final bool isUploadingImage;
  final bool hasAttemptedSubmit;
  final String? error;
  final String? warningMessage;

  CreateEventFormState copyWith({
    String? title,
    String? venueName,
    String? description,
    EventType? type,
    DateTime? startsAt,
    DateTime? endsAt,
    bool clearEndsAt = false,
    LocationPoint? location,
    bool clearLocation = false,
    int? maxParticipants,
    File? imageFile,
    bool clearImageFile = false,
    bool? isRecurring,
    List<int>? recurringDays,
    DateTime? recurringEndDate,
    bool clearRecurringEndDate = false,
    bool? costSplitEnabled,
    bool? isSubmitting,
    bool? isUploadingImage,
    bool? hasAttemptedSubmit,
    String? error,
    bool clearError = false,
    String? warningMessage,
    bool clearWarningMessage = false,
  }) {
    return CreateEventFormState(
      title: title ?? this.title,
      venueName: venueName ?? this.venueName,
      description: description ?? this.description,
      type: type ?? this.type,
      startsAt: startsAt ?? this.startsAt,
      endsAt: clearEndsAt ? null : (endsAt ?? this.endsAt),
      location: clearLocation ? null : (location ?? this.location),
      maxParticipants: maxParticipants ?? this.maxParticipants,
      imageFile: clearImageFile ? null : (imageFile ?? this.imageFile),
      isRecurring: isRecurring ?? this.isRecurring,
      recurringDays: recurringDays ?? this.recurringDays,
      recurringEndDate: clearRecurringEndDate
          ? null
          : (recurringEndDate ?? this.recurringEndDate),
      costSplitEnabled: costSplitEnabled ?? this.costSplitEnabled,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      hasAttemptedSubmit: hasAttemptedSubmit ?? this.hasAttemptedSubmit,
      error: clearError ? null : (error ?? this.error),
      warningMessage: clearWarningMessage
          ? null
          : (warningMessage ?? this.warningMessage),
    );
  }

  bool get isBusy => isSubmitting || isUploadingImage;

  List<int> get sortedRecurringDays {
    final sorted = List<int>.from(recurringDays);
    sorted.sort();
    return sorted;
  }

  String? get titleError {
    final normalized = title.trim();
    if (normalized.isEmpty) return 'Title is required';
    if (normalized.length < 3) {
      return 'Title must be at least 3 characters';
    }
    return null;
  }

  String? get locationError {
    if (location == null) return 'Please pick a location.';
    return null;
  }

  String? get startsAtError {
    if (!startsAt.isAfter(DateTime.now())) {
      return 'Start time must be in the future.';
    }
    return null;
  }

  String? get endsAtError {
    final end = endsAt;
    if (end != null && !end.isAfter(startsAt)) {
      return 'End time must be after start time.';
    }
    return null;
  }

  String? get recurringError {
    if (!isRecurring) return null;
    if (recurringDays.isEmpty) {
      return 'Select at least one day for a recurring event.';
    }
    final endDate = recurringEndDate;
    if (endDate != null && _dateOnly(endDate).isBefore(_dateOnly(startsAt))) {
      return 'Repeat end date must be on or after the start date.';
    }
    return null;
  }

  String? get submissionBlockReason {
    if (isBusy) return 'Please wait for the current submission to finish.';
    return titleError ??
        locationError ??
        startsAtError ??
        endsAtError ??
        recurringError;
  }

  bool get canSubmit => submissionBlockReason == null;

  String get participantLabel {
    if (maxParticipants == 0) return 'Unlimited';
    return '$maxParticipants spots';
  }
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

@riverpod
class CreateEventFormViewModel extends _$CreateEventFormViewModel {
  @override
  CreateEventFormState build() => CreateEventFormState.initial();

  void setTitle(String value) {
    state = state.copyWith(title: value, clearError: true);
  }

  void setVenueName(String value) {
    state = state.copyWith(venueName: value, clearError: true);
  }

  void setDescription(String value) {
    state = state.copyWith(description: value, clearError: true);
  }

  void setType(EventType type) {
    state = state.copyWith(type: type, clearError: true);
  }

  void setStartsAt(DateTime value) {
    final nextStartsAt = DateTime(
      value.year,
      value.month,
      value.day,
      value.hour,
      value.minute,
    );
    final currentEnd = state.endsAt;
    final nextEndsAt = currentEnd != null && !currentEnd.isAfter(nextStartsAt)
        ? nextStartsAt.add(const Duration(hours: 2))
        : currentEnd;
    final recurringEndDate = state.recurringEndDate;
    final normalizedRecurringEndDate =
        recurringEndDate != null &&
            _dateOnly(recurringEndDate).isBefore(_dateOnly(nextStartsAt))
        ? _dateOnly(nextStartsAt)
        : recurringEndDate;

    state = state.copyWith(
      startsAt: nextStartsAt,
      endsAt: nextEndsAt,
      recurringEndDate: normalizedRecurringEndDate,
      clearError: true,
    );
  }

  void setEndsAt(DateTime? value) {
    state = state.copyWith(
      endsAt: value,
      clearEndsAt: value == null,
      clearError: true,
    );
  }

  void setLocation(LocationPoint? value) {
    state = state.copyWith(
      location: value,
      clearLocation: value == null,
      clearError: true,
    );
  }

  void setMaxParticipants(int value) {
    state = state.copyWith(maxParticipants: value, clearError: true);
  }

  void setImageFile(File? file) {
    state = state.copyWith(
      imageFile: file,
      clearImageFile: file == null,
      clearError: true,
      clearWarningMessage: true,
    );
  }

  void setIsRecurring(bool value) {
    state = state.copyWith(
      isRecurring: value,
      recurringDays: value ? state.sortedRecurringDays : const [],
      clearRecurringEndDate: !value,
      clearError: true,
    );
  }

  void toggleRecurringDay(int day) {
    final nextDays = List<int>.from(state.recurringDays);
    if (nextDays.contains(day)) {
      nextDays.remove(day);
    } else {
      nextDays.add(day);
    }
    nextDays.sort();
    state = state.copyWith(recurringDays: nextDays, clearError: true);
  }

  void setRecurringEndDate(DateTime? value) {
    final normalizedValue = value == null ? null : _dateOnly(value);
    state = state.copyWith(
      recurringEndDate: normalizedValue,
      clearRecurringEndDate: normalizedValue == null,
      clearError: true,
    );
  }

  void setCostSplitEnabled(bool value) {
    state = state.copyWith(costSplitEnabled: value, clearError: true);
  }

  void clearFeedback() {
    state = state.copyWith(clearError: true, clearWarningMessage: true);
  }

  Future<CreateEventSubmissionResult?> submit() async {
    if (state.isBusy) return null;

    state = state.copyWith(
      hasAttemptedSubmit: true,
      clearError: true,
      clearWarningMessage: true,
    );

    final authUser = ref.read(authStateProvider).value;
    if (authUser == null) {
      state = state.copyWith(error: 'Please sign in to create an event.');
      return null;
    }

    final validationError = state.submissionBlockReason;
    if (validationError != null) {
      state = state.copyWith(error: validationError);
      return null;
    }

    final repo = ref.read(eventRepositoryProvider);
    final imageFile = state.imageFile;
    final draft = EventModel(
      id: '',
      creatorId: authUser.uid,
      title: state.title.trim(),
      type: state.type,
      location: state.location!,
      startsAt: state.startsAt,
      endsAt: state.endsAt,
      description: state.description.trim().isEmpty
          ? null
          : state.description.trim(),
      venueName: state.venueName.trim().isEmpty ? null : state.venueName.trim(),
      organizerName: authUser.displayName,
      maxParticipants: state.maxParticipants,
      participantIds: [authUser.uid],
      isRecurring: state.isRecurring,
      recurringDays: state.sortedRecurringDays,
      recurringEndDate: state.recurringEndDate,
      costSplitEnabled: state.costSplitEnabled,
    );

    state = state.copyWith(isSubmitting: true);

    try {
      final eventId = await repo.createEvent(draft);
      if (!ref.mounted) return null;

      var created = draft.copyWith(id: eventId);
      String? warningMessage;

      if (imageFile != null) {
        state = state.copyWith(isUploadingImage: true);
        try {
          final imageUrl = await repo.uploadEventImage(eventId, imageFile);
          if (!ref.mounted) return null;

          created = created.copyWith(imageUrl: imageUrl);
          await repo.updateEvent(created);
          if (!ref.mounted) return null;
        } catch (e, st) {
          TalkerService.error('createEvent image upload failed', e, st);
          warningMessage =
              'Event created, but the cover image could not be uploaded.';
        } finally {
          if (ref.mounted) {
            state = state.copyWith(isUploadingImage: false);
          }
        }
      }

      if (!ref.mounted) return null;

      state = state.copyWith(
        isSubmitting: false,
        warningMessage: warningMessage,
      );
      return CreateEventSubmissionResult(
        event: created,
        warningMessage: warningMessage,
      );
    } catch (e, st) {
      TalkerService.error('createEvent submit failed', e, st);
      if (!ref.mounted) return null;
      state = state.copyWith(
        isSubmitting: false,
        isUploadingImage: false,
        error: 'Unable to create event: $e',
      );
      return null;
    }
  }
}

class EditEventFormState {
  const EditEventFormState({
    this.title = '',
    this.venueName = '',
    this.description = '',
    this.type = EventType.running,
    this.startsAt,
    this.endsAt,
    this.location,
    this.maxParticipants = 0,
    this.imageFile,
    this.existingImageUrl,
    this.removeExistingImage = false,
    this.isRecurring = false,
    this.recurringDays = const [],
    this.recurringEndDate,
    this.costSplitEnabled = false,
    this.isSubmitting = false,
    this.hasAttemptedSubmit = false,
    this.isSaved = false,
    this.error,
  });

  factory EditEventFormState.fromEvent(EventModel event) => EditEventFormState(
    title: event.title,
    venueName: event.venueName ?? '',
    description: event.description ?? '',
    type: event.type,
    startsAt: event.startsAt,
    endsAt: event.endsAt,
    location: event.location,
    maxParticipants: event.maxParticipants,
    existingImageUrl: event.imageUrl,
    isRecurring: event.isRecurring,
    recurringDays: event.recurringDays,
    recurringEndDate: event.recurringEndDate,
    costSplitEnabled: event.costSplitEnabled,
  );

  final String title;
  final String venueName;
  final String description;
  final EventType type;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final LocationPoint? location;
  final int maxParticipants;
  final File? imageFile;
  final String? existingImageUrl;
  final bool removeExistingImage;
  final bool isRecurring;
  final List<int> recurringDays;
  final DateTime? recurringEndDate;
  final bool costSplitEnabled;
  final bool isSubmitting;
  final bool hasAttemptedSubmit;
  final bool isSaved;
  final String? error;

  EditEventFormState copyWith({
    String? title,
    String? venueName,
    String? description,
    EventType? type,
    DateTime? startsAt,
    Object? endsAt = _sentinel,
    LocationPoint? location,
    bool clearLocation = false,
    int? maxParticipants,
    Object? imageFile = _sentinel,
    Object? existingImageUrl = _sentinel,
    bool? removeExistingImage,
    bool? isRecurring,
    List<int>? recurringDays,
    Object? recurringEndDate = _sentinel,
    bool? costSplitEnabled,
    bool? isSubmitting,
    bool? hasAttemptedSubmit,
    bool? isSaved,
    String? error,
    bool clearError = false,
  }) {
    return EditEventFormState(
      title: title ?? this.title,
      venueName: venueName ?? this.venueName,
      description: description ?? this.description,
      type: type ?? this.type,
      startsAt: startsAt ?? this.startsAt,
      endsAt: identical(endsAt, _sentinel) ? this.endsAt : endsAt as DateTime?,
      location: clearLocation ? null : (location ?? this.location),
      maxParticipants: maxParticipants ?? this.maxParticipants,
      imageFile: identical(imageFile, _sentinel)
          ? this.imageFile
          : imageFile as File?,
      existingImageUrl: identical(existingImageUrl, _sentinel)
          ? this.existingImageUrl
          : existingImageUrl as String?,
      removeExistingImage: removeExistingImage ?? this.removeExistingImage,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringDays: recurringDays ?? this.recurringDays,
      recurringEndDate: identical(recurringEndDate, _sentinel)
          ? this.recurringEndDate
          : recurringEndDate as DateTime?,
      costSplitEnabled: costSplitEnabled ?? this.costSplitEnabled,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      hasAttemptedSubmit: hasAttemptedSubmit ?? this.hasAttemptedSubmit,
      isSaved: isSaved ?? this.isSaved,
      error: clearError ? null : error,
    );
  }

  static const _sentinel = Object();

  bool get hasExistingImage =>
      !removeExistingImage && (existingImageUrl?.isNotEmpty ?? false);

  String? get titleError {
    final normalized = title.trim();
    if (normalized.isEmpty) return 'Title is required';
    if (normalized.length < 3) return 'Title must be at least 3 characters';
    return null;
  }

  String? get startsAtError {
    final start = startsAt;
    if (start == null) return 'Start time is required';
    if (!start.isAfter(DateTime.now())) {
      return 'Start time must be in the future.';
    }
    return null;
  }

  String? get locationError {
    if (location == null) return 'Please select a location.';
    return null;
  }

  String? get endsAtError {
    final start = startsAt;
    final end = endsAt;
    if (start != null && end != null && !end.isAfter(start)) {
      return 'End time must be after start time.';
    }
    return null;
  }

  String? get recurringError {
    if (!isRecurring) return null;
    if (recurringDays.isEmpty) {
      return 'Select at least one day for a recurring event.';
    }
    final start = startsAt;
    final endDate = recurringEndDate;
    if (start != null &&
        endDate != null &&
        _dateOnly(endDate).isBefore(_dateOnly(start))) {
      return 'Repeat end date must be on or after the start date.';
    }
    return null;
  }

  String? get submissionBlockReason =>
      titleError ??
      locationError ??
      startsAtError ??
      endsAtError ??
      recurringError;
}

@riverpod
class EditEventFormViewModel extends _$EditEventFormViewModel {
  late final String _eventId;
  EventModel? _originalEvent;

  @override
  EditEventFormState build(String eventId) {
    _eventId = eventId;
    return const EditEventFormState();
  }

  void initFromEvent(EventModel event) {
    if (_originalEvent?.id == event.id && state.title.isNotEmpty) {
      return;
    }
    _originalEvent = event;
    state = EditEventFormState.fromEvent(event);
  }

  void setTitle(String value) =>
      state = state.copyWith(title: value, isSaved: false, clearError: true);

  void setVenueName(String value) => state = state.copyWith(
    venueName: value,
    isSaved: false,
    clearError: true,
  );

  void setDescription(String value) => state = state.copyWith(
    description: value,
    isSaved: false,
    clearError: true,
  );

  void setType(EventType value) =>
      state = state.copyWith(type: value, isSaved: false, clearError: true);

  void setStartsAt(DateTime value) {
    final nextStart = DateTime(
      value.year,
      value.month,
      value.day,
      value.hour,
      value.minute,
    );
    final nextEnd = state.endsAt != null && !state.endsAt!.isAfter(nextStart)
        ? nextStart.add(const Duration(hours: 2))
        : state.endsAt;
    state = state.copyWith(
      startsAt: nextStart,
      endsAt: nextEnd,
      isSaved: false,
      clearError: true,
    );
  }

  void setEndsAt(DateTime? value) =>
      state = state.copyWith(endsAt: value, isSaved: false, clearError: true);

  void setLocation(LocationPoint value) =>
      state = state.copyWith(location: value, isSaved: false, clearError: true);

  void setMaxParticipants(int value) => state = state.copyWith(
    maxParticipants: value,
    isSaved: false,
    clearError: true,
  );

  void setImageFile(File? value) {
    state = state.copyWith(
      imageFile: value,
      removeExistingImage: value == null ? state.removeExistingImage : false,
      isSaved: false,
      clearError: true,
    );
  }

  void clearSelectedImage() {
    state = state.copyWith(
      imageFile: null,
      existingImageUrl: state.hasExistingImage ? null : state.existingImageUrl,
      removeExistingImage: state.imageFile == null
          ? true
          : state.removeExistingImage,
      isSaved: false,
      clearError: true,
    );
  }

  void setRecurring(bool value) => state = state.copyWith(
    isRecurring: value,
    recurringDays: value ? state.recurringDays : const [],
    recurringEndDate: value ? state.recurringEndDate : null,
    isSaved: false,
    clearError: true,
  );

  void toggleRecurringDay(int day) {
    final nextDays = [...state.recurringDays];
    if (nextDays.contains(day)) {
      nextDays.remove(day);
    } else {
      nextDays.add(day);
    }
    nextDays.sort();
    state = state.copyWith(
      recurringDays: nextDays,
      isSaved: false,
      clearError: true,
    );
  }

  void setRecurringEndDate(DateTime? value) => state = state.copyWith(
    recurringEndDate: value == null ? null : _dateOnly(value),
    isSaved: false,
    clearError: true,
  );

  void setCostSplitEnabled(bool value) => state = state.copyWith(
    costSplitEnabled: value,
    isSaved: false,
    clearError: true,
  );

  Future<EventModel?> submit() async {
    if (state.isSubmitting) return null;
    final originalEvent = _originalEvent;
    if (originalEvent == null) {
      state = state.copyWith(error: 'Unable to load the original event.');
      return null;
    }

    state = state.copyWith(
      hasAttemptedSubmit: true,
      isSubmitting: true,
      isSaved: false,
      clearError: true,
    );

    final validationError = state.submissionBlockReason;
    if (validationError != null) {
      state = state.copyWith(isSubmitting: false, error: validationError);
      return null;
    }

    try {
      final repo = ref.read(eventRepositoryProvider);
      String? imageUrl = state.removeExistingImage
          ? null
          : state.existingImageUrl;
      if (state.imageFile != null) {
        imageUrl = await repo.uploadEventImage(_eventId, state.imageFile!);
      }

      final updated = originalEvent.copyWith(
        title: state.title.trim(),
        type: state.type,
        location: state.location!,
        startsAt: state.startsAt!,
        endsAt: state.endsAt,
        description: state.description.trim().isEmpty
            ? null
            : state.description.trim(),
        venueName: state.venueName.trim().isEmpty
            ? null
            : state.venueName.trim(),
        imageUrl: imageUrl,
        maxParticipants: state.maxParticipants,
        isRecurring: state.isRecurring,
        recurringDays: [...state.recurringDays]..sort(),
        recurringEndDate: state.recurringEndDate,
        costSplitEnabled: state.costSplitEnabled,
        updatedAt: DateTime.now(),
      );

      await repo.updateEvent(updated);
      state = state.copyWith(
        isSubmitting: false,
        isSaved: true,
        imageFile: null,
        existingImageUrl: updated.imageUrl,
      );
      _originalEvent = updated;
      return updated;
    } catch (e, st) {
      TalkerService.error('editEvent submit failed', e, st);
      state = state.copyWith(
        isSubmitting: false,
        isSaved: false,
        error: 'Unable to update event. Please try again.',
      );
      return null;
    }
  }
}

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

@Riverpod(keepAlive: true)
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
    bool isRecurring = false,
    List<int> recurringDays = const [],
    DateTime? recurringEndDate,
    bool costSplitEnabled = false,
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
        participantIds: [creatorId],
        isRecurring: isRecurring,
        recurringDays: recurringDays,
        recurringEndDate: recurringEndDate,
        costSplitEnabled: costSplitEnabled,
      );

      final eventId = await ref
          .read(eventRepositoryProvider)
          .createEvent(event);

      // Guard against provider disposal during the async gap
      if (!ref.mounted) return null;

      final created = event.copyWith(id: eventId);
      state = state.copyWith(isLoading: false, selectedEvent: created);
      return created;
    } catch (e, st) {
      TalkerService.error('createEvent failed', e, st);
      if (!ref.mounted) return null;
      state = state.copyWith(
        isLoading: false,
        error: 'Unable to create event: $e',
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
    this.isLoading = false,
    this.isJoining = false,
    this.isLeaving = false,
    this.isDeleting = false,
    this.error,
    this.successMessage,
  });

  final bool isLoading;
  final bool isJoining;
  final bool isLeaving;
  final bool isDeleting;
  final String? error;
  final String? successMessage;

  EventDetailState copyWith({
    bool? isLoading,
    bool? isJoining,
    bool? isLeaving,
    bool? isDeleting,
    String? error,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return EventDetailState(
      isLoading: isLoading ?? this.isLoading,
      isJoining: isJoining ?? this.isJoining,
      isLeaving: isLeaving ?? this.isLeaving,
      isDeleting: isDeleting ?? this.isDeleting,
      error: clearError ? null : (error ?? this.error),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
    );
  }
}

@riverpod
class EventDetailViewModel extends _$EventDetailViewModel {
  @override
  EventDetailState build(String eventId) => const EventDetailState();

  /// Joins the current user to the event.
  Future<bool> joinEvent(String userId) async {
    state = state.copyWith(
      isJoining: true,
      clearError: true,
      clearSuccess: true,
    );
    try {
      await ref.read(eventRepositoryProvider).joinEvent(eventId, userId);
      if (!ref.mounted) return false;
      state = state.copyWith(
        isJoining: false,
        successMessage: 'You joined the event!',
      );
      return true;
    } catch (e, st) {
      TalkerService.error('joinEvent failed', e, st);
      if (!ref.mounted) return false;
      state = state.copyWith(
        isJoining: false,
        error: 'Unable to join event. Please try again.',
      );
      return false;
    }
  }

  /// Leaves the event.
  Future<bool> leaveEvent(String userId) async {
    state = state.copyWith(
      isLeaving: true,
      clearError: true,
      clearSuccess: true,
    );
    try {
      await ref.read(eventRepositoryProvider).leaveEvent(eventId, userId);
      if (!ref.mounted) return false;
      state = state.copyWith(
        isLeaving: false,
        successMessage: 'You left the event.',
      );
      return true;
    } catch (e, st) {
      TalkerService.error('leaveEvent failed', e, st);
      if (!ref.mounted) return false;
      state = state.copyWith(
        isLeaving: false,
        error: 'Unable to leave event. Please try again.',
      );
      return false;
    }
  }

  /// Updates the event with new data.
  Future<bool> updateEvent(EventModel event) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(eventRepositoryProvider).updateEvent(event);
      if (!ref.mounted) return false;
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Event updated successfully.',
      );
      return true;
    } catch (e, st) {
      TalkerService.error('updateEvent failed', e, st);
      if (!ref.mounted) return false;
      state = state.copyWith(
        isLoading: false,
        error: 'Unable to update event. Please try again.',
      );
      return false;
    }
  }

  /// Uploads a cover image and updates the event's imageUrl.
  Future<String?> uploadImage(File file) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = ref.read(eventRepositoryProvider);
      final url = await repo.uploadEventImage(eventId, file);
      if (!ref.mounted) return null;
      state = state.copyWith(isLoading: false);
      return url;
    } catch (e, st) {
      TalkerService.error('uploadImage failed', e, st);
      if (!ref.mounted) return null;
      state = state.copyWith(
        isLoading: false,
        error: 'Unable to upload image. Please try again.',
      );
      return null;
    }
  }

  /// Soft-deletes the event by setting isActive to false.
  Future<bool> cancelEvent() async {
    state = state.copyWith(isDeleting: true, clearError: true);
    try {
      await ref.read(eventRepositoryProvider).cancelEvent(eventId);
      if (!ref.mounted) return false;
      state = state.copyWith(
        isDeleting: false,
        successMessage: 'Event cancelled.',
      );
      return true;
    } catch (e, st) {
      TalkerService.error('cancelEvent failed', e, st);
      if (!ref.mounted) return false;
      state = state.copyWith(
        isDeleting: false,
        error: 'Unable to cancel event. Please try again.',
      );
      return false;
    }
  }

  /// Hard-deletes the event (only creator should call this).
  Future<bool> deleteEvent() async {
    state = state.copyWith(isDeleting: true, clearError: true);
    try {
      await ref.read(eventRepositoryProvider).deleteEvent(eventId);
      if (!ref.mounted) return false;
      state = state.copyWith(isDeleting: false);
      return true;
    } catch (e, st) {
      TalkerService.error('deleteEvent failed', e, st);
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

  // ── Event-Ride Integration methods ──

  /// Sets the ride status for a participant (#24 RSVP with Ride Status).
  Future<bool> setRideStatus(String userId, String status) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );
    try {
      await ref
          .read(eventRepositoryProvider)
          .setRideStatus(eventId, userId, status);
      if (!ref.mounted) return false;
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Ride status updated!',
      );
      return true;
    } catch (e, st) {
      TalkerService.error('setRideStatus failed', e, st);
      if (!ref.mounted) return false;
      state = state.copyWith(
        isLoading: false,
        error: 'Unable to update ride status.',
      );
      return false;
    }
  }

  /// Links a ride to this event (#21 Event-Linked Carpools).
  Future<bool> linkRide(String rideId) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );
    try {
      await ref.read(eventRepositoryProvider).linkRideToEvent(eventId, rideId);
      if (!ref.mounted) return false;
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Ride linked to event!',
      );
      return true;
    } catch (e, st) {
      TalkerService.error('linkRide failed', e, st);
      if (!ref.mounted) return false;
      state = state.copyWith(isLoading: false, error: 'Unable to link ride.');
      return false;
    }
  }

  /// Sets the post-event meetup pin location (#30).
  Future<bool> setMeetupPin(LocationPoint location) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );
    try {
      await ref.read(eventRepositoryProvider).setMeetupPin(eventId, location);
      if (!ref.mounted) return false;
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Meetup point set!',
      );
      return true;
    } catch (e, st) {
      TalkerService.error('setMeetupPin failed', e, st);
      if (!ref.mounted) return false;
      state = state.copyWith(
        isLoading: false,
        error: 'Unable to set meetup point.',
      );
      return false;
    }
  }

  /// Sets the chat group ID for this event (#29).
  Future<bool> setChatGroup(String chatGroupId) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );
    try {
      await ref
          .read(eventRepositoryProvider)
          .setChatGroupId(eventId, chatGroupId);
      if (!ref.mounted) return false;
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Event chat created!',
      );
      return true;
    } catch (e, st) {
      TalkerService.error('setChatGroup failed', e, st);
      if (!ref.mounted) return false;
      state = state.copyWith(
        isLoading: false,
        error: 'Unable to create event chat.',
      );
      return false;
    }
  }
}

// ---------------------------------------------------------------------------
// Event list view model — browse / discover screen
// ---------------------------------------------------------------------------

/// UI state for the event list (discover) screen.
class EventListState {
  const EventListState({
    this.allEvents = const [],
    this.filteredEvents = const [],
    this.filterType,
    this.searchQuery = '',
    this.searchFieldKey = 0,
    this.isLoading = false,
    this.error,
  });

  final List<EventModel> allEvents;
  final List<EventModel> filteredEvents;
  final EventType? filterType;
  final String searchQuery;
  final int searchFieldKey;
  final bool isLoading;
  final String? error;

  EventListState copyWith({
    List<EventModel>? allEvents,
    List<EventModel>? filteredEvents,
    EventType? filterType,
    bool clearFilterType = false,
    String? searchQuery,
    int? searchFieldKey,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return EventListState(
      allEvents: allEvents ?? this.allEvents,
      filteredEvents: filteredEvents ?? this.filteredEvents,
      filterType: clearFilterType ? null : (filterType ?? this.filterType),
      searchQuery: searchQuery ?? this.searchQuery,
      searchFieldKey: searchFieldKey ?? this.searchFieldKey,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// ViewModel for the event list screen.
///
/// Watches the upcoming events stream and applies client-side filtering
/// by type and search query.  Views should watch only this provider.
@riverpod
class EventListViewModel extends _$EventListViewModel {
  // Persisted across stream rebuilds via instance variables (not frozen state).
  EventType? _filterType;
  String _searchQuery = '';
  int _searchFieldKey = 0;

  @override
  EventListState build() {
    final eventsAsync = ref.watch(upcomingEventsStreamProvider);
    final all = eventsAsync.value ?? const [];
    return EventListState(
      allEvents: all,
      filteredEvents: _applyFilters(all),
      filterType: _filterType,
      searchQuery: _searchQuery,
      searchFieldKey: _searchFieldKey,
      isLoading: eventsAsync.isLoading,
      error: eventsAsync.error?.toString(),
    );
  }

  /// Toggles or clears the sport-type filter.
  void setFilterType(EventType? type) {
    _filterType = type;
    state = _withFiltersApplied();
  }

  /// Updates the search query for client-side text search.
  void setSearchQuery(String query) {
    _searchQuery = query.trim().toLowerCase();
    state = _withFiltersApplied();
  }

  void clearSearch() {
    _searchQuery = '';
    _searchFieldKey += 1;
    state = _withFiltersApplied();
  }

  // ── Private ──

  EventListState _withFiltersApplied() {
    return state.copyWith(
      filteredEvents: _applyFilters(state.allEvents),
      filterType: _filterType,
      clearFilterType: _filterType == null,
      searchQuery: _searchQuery,
      searchFieldKey: _searchFieldKey,
    );
  }

  List<EventModel> _applyFilters(List<EventModel> events) {
    var filtered = events.where((e) => e.isActive).toList();
    if (_filterType != null) {
      filtered = filtered.where((e) => e.type == _filterType).toList();
    }
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (e) =>
                e.title.toLowerCase().contains(_searchQuery) ||
                e.location.address.toLowerCase().contains(_searchQuery) ||
                (e.venueName?.toLowerCase().contains(_searchQuery) ?? false) ||
                (e.organizerName?.toLowerCase().contains(_searchQuery) ??
                    false),
          )
          .toList();
    }
    return filtered;
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
Stream<EventModel?> eventById(Ref ref, String eventId) {
  return ref.watch(eventRepositoryProvider).streamEventById(eventId);
}

/// Streams rides linked to a specific event by querying rides with matching eventId.
@riverpod
Stream<List<RideModel>> eventLinkedRides(Ref ref, String eventId) {
  return ref.watch(rideRepositoryProvider).streamRidesByEventId(eventId);
}
