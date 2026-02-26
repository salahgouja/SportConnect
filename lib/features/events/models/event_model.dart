import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sport_connect/core/converters/timestamp_converter.dart';
import 'package:sport_connect/core/models/location/location_point.dart';

part 'event_model.freezed.dart';
part 'event_model.g.dart';

/// Sport categories with display metadata.
enum EventType {
  @JsonValue('football')
  football,
  @JsonValue('basketball')
  basketball,
  @JsonValue('volleyball')
  volleyball,
  @JsonValue('tennis')
  tennis,
  @JsonValue('running')
  running,
  @JsonValue('gym')
  gym,
  @JsonValue('swimming')
  swimming,
  @JsonValue('cycling')
  cycling,
  @JsonValue('hiking')
  hiking,
  @JsonValue('yoga')
  yoga,
  @JsonValue('martial_arts')
  martialArts,
  @JsonValue('other')
  other,
}

/// Extension to provide display helpers for [EventType].
extension EventTypeX on EventType {
  /// The JSON string value stored in Firestore for this type.
  ///
  /// Must match the `@JsonValue` annotations above.
  String get jsonValue {
    switch (this) {
      case EventType.martialArts:
        return 'martial_arts';
      default:
        return name; // enum name matches @JsonValue for all others
    }
  }

  String get label {
    switch (this) {
      case EventType.football:
        return 'Football';
      case EventType.basketball:
        return 'Basketball';
      case EventType.volleyball:
        return 'Volleyball';
      case EventType.tennis:
        return 'Tennis';
      case EventType.running:
        return 'Running';
      case EventType.gym:
        return 'Gym';
      case EventType.swimming:
        return 'Swimming';
      case EventType.cycling:
        return 'Cycling';
      case EventType.hiking:
        return 'Hiking';
      case EventType.yoga:
        return 'Yoga';
      case EventType.martialArts:
        return 'Martial Arts';
      case EventType.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case EventType.football:
        return Icons.sports_soccer;
      case EventType.basketball:
        return Icons.sports_basketball;
      case EventType.volleyball:
        return Icons.sports_volleyball;
      case EventType.tennis:
        return Icons.sports_tennis;
      case EventType.running:
        return Icons.directions_run;
      case EventType.gym:
        return Icons.fitness_center;
      case EventType.swimming:
        return Icons.pool;
      case EventType.cycling:
        return Icons.directions_bike;
      case EventType.hiking:
        return Icons.terrain;
      case EventType.yoga:
        return Icons.self_improvement;
      case EventType.martialArts:
        return Icons.sports_martial_arts;
      case EventType.other:
        return Icons.sports;
    }
  }

  Color get color {
    switch (this) {
      case EventType.football:
        return const Color(0xFF43A047);
      case EventType.basketball:
        return const Color(0xFFEF6C00);
      case EventType.volleyball:
        return const Color(0xFFFDD835);
      case EventType.tennis:
        return const Color(0xFF66BB6A);
      case EventType.running:
        return const Color(0xFF29B6F6);
      case EventType.gym:
        return const Color(0xFF8E24AA);
      case EventType.swimming:
        return const Color(0xFF0288D1);
      case EventType.cycling:
        return const Color(0xFFFF7043);
      case EventType.hiking:
        return const Color(0xFF5D4037);
      case EventType.yoga:
        return const Color(0xFFAB47BC);
      case EventType.martialArts:
        return const Color(0xFFD32F2F);
      case EventType.other:
        return const Color(0xFF78909C);
    }
  }
}

@freezed
abstract class EventModel with _$EventModel {
  const EventModel._();

  const factory EventModel({
    required String id,
    required String creatorId,
    required String title,
    required EventType type,
    required LocationPoint location,
    @RequiredTimestampConverter() required DateTime startsAt,
    @TimestampConverter() DateTime? endsAt,
    String? description,

    /// Venue / facility name (e.g. "Downtown Sports Complex").
    String? venueName,

    /// Display name of the organiser (denormalized for fast rendering).
    String? organizerName,

    /// Cover image URL (Firebase Storage).
    String? imageUrl,
    @Default([]) List<String> participantIds,
    @Default(0) int maxParticipants,
    @Default(true) bool isActive,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
  }) = _EventModel;

  factory EventModel.fromJson(Map<String, dynamic> json) =>
      _$EventModelFromJson(json);

  bool get isUpcoming => startsAt.isAfter(DateTime.now());

  bool get isFull =>
      maxParticipants > 0 && participantIds.length >= maxParticipants;

  int get seatsLeft {
    if (maxParticipants <= 0) return -1; // -1 means unlimited
    return (maxParticipants - participantIds.length).clamp(0, maxParticipants);
  }

  /// Formatted participant count string for UI badges.
  String get participantLabel {
    if (maxParticipants <= 0) return '${participantIds.length} joined';
    return '${participantIds.length}/$maxParticipants';
  }
}
