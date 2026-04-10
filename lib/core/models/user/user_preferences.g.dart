// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserPreferences _$UserPreferencesFromJson(Map json) => _UserPreferences(
  notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
  emailNotifications: json['emailNotifications'] as bool? ?? true,
  rideReminders: json['rideReminders'] as bool? ?? true,
  chatNotifications: json['chatNotifications'] as bool? ?? true,
  language: json['language'] as String? ?? 'en',
  maxPickupRadius: (json['maxPickupRadius'] as num?)?.toDouble() ?? 20.0,
  allowMessages: json['allowMessages'] as bool? ?? true,
);

Map<String, dynamic> _$UserPreferencesToJson(_UserPreferences instance) =>
    <String, dynamic>{
      'notificationsEnabled': instance.notificationsEnabled,
      'emailNotifications': instance.emailNotifications,
      'rideReminders': instance.rideReminders,
      'chatNotifications': instance.chatNotifications,
      'language': instance.language,
      'maxPickupRadius': instance.maxPickupRadius,
      'allowMessages': instance.allowMessages,
    };
