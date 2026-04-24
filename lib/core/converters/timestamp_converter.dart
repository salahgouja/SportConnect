import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

/// Timestamp converter for Firestore nullable DateTime fields.
class TimestampConverter implements JsonConverter<DateTime?, dynamic> {
  const TimestampConverter();

  @override
  DateTime? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is Timestamp) return json.toDate();
    if (json is DateTime) return json;
    if (json is String) return DateTime.tryParse(json);
    if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
    return null;
  }

  @override
  dynamic toJson(DateTime? date) {
    if (date == null) return null;
    return Timestamp.fromDate(date);
  }
}

/// Timestamp converter for required DateTime fields.
class RequiredTimestampConverter implements JsonConverter<DateTime, dynamic> {
  const RequiredTimestampConverter();

  @override
  DateTime fromJson(dynamic json) {
    final parsed = const TimestampConverter().fromJson(json);

    if (parsed == null) {
      throw FormatException('Invalid required timestamp value: $json');
    }

    return parsed;
  }

  @override
  dynamic toJson(DateTime date) {
    return Timestamp.fromDate(date);
  }
}

/// Converter for Firestore maps like:
///
/// deletedAtBy: {
///   userId1: Timestamp,
///   userId2: Timestamp,
/// }
class TimestampMapConverter
    implements JsonConverter<Map<String, DateTime>, dynamic> {
  const TimestampMapConverter();

  @override
  Map<String, DateTime> fromJson(dynamic json) {
    if (json == null) return {};

    if (json is! Map) {
      throw FormatException('Expected timestamp map, got: ${json.runtimeType}');
    }

    final result = <String, DateTime>{};

    for (final entry in json.entries) {
      final key = entry.key.toString();
      final value = const TimestampConverter().fromJson(entry.value);

      if (value != null) {
        result[key] = value;
      }
    }

    return result;
  }

  @override
  Map<String, dynamic> toJson(Map<String, DateTime> object) {
    return object.map(
      (key, value) => MapEntry(key, Timestamp.fromDate(value)),
    );
  }
}
