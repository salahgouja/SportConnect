import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sport_connect/features/auth/models/models.dart';

part 'user_preferences.freezed.dart';
part 'user_preferences.g.dart';

/// User preferences
@freezed
abstract class UserPreferences with _$UserPreferences {
  const factory UserPreferences({
    @Default(true) bool notificationsEnabled,
    @Default(true) bool emailNotifications,
    @Default(true) bool rideReminders,
    @Default(true) bool chatNotifications,
    @Default(AppLocale.french) AppLocale language,
    @Default(20.0) double maxPickupRadius,
    @Default(true) bool allowMessages,
  }) = _UserPreferences;

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);
}
