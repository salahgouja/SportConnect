import 'package:freezed_annotation/freezed_annotation.dart';

part 'ride_preferences.freezed.dart';
part 'ride_preferences.g.dart';

/// Ride preferences and rules
@freezed
abstract class RidePreferences with _$RidePreferences {
  const factory RidePreferences({
    @Default(false) bool allowPets,
    @Default(false) bool allowSmoking,
    @Default(true) bool allowLuggage,
    @Default(false) bool isWomenOnly,
    @Default(true) bool allowChat,
    int? maxDetourMinutes,
  }) = _RidePreferences;

  factory RidePreferences.fromJson(Map<String, dynamic> json) =>
      _$RidePreferencesFromJson(json);
}
