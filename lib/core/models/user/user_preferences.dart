import 'package:freezed_annotation/freezed_annotation.dart';

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
    @Default(true) bool marketingEmails,
    @Default('en') String language,
    @Default('system') String theme,
    @Default(5.0) double maxPickupRadius,
    @Default(true) bool showOnlineStatus,
    @Default(true) bool allowMessages,
  }) = _UserPreferences;

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);
}
