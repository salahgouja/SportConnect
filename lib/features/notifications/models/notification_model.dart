import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sport_connect/features/auth/models/user_model.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

/// Notification type enum
enum NotificationType {
  // Ride notifications
  rideBookingRequest,
  rideBookingAccepted,
  rideBookingRejected,
  rideBookingCancelled,
  rideStartingSoon,
  rideStarted,
  rideCompleted,
  rideCancelled,
  rideUpdated,

  // Message notifications
  newMessage,
  newGroupMessage,

  // Social notifications
  newFollower,
  followAccepted,

  // Gamification
  levelUp,
  achievementUnlocked,
  streakMilestone,
  leaderboardRank,
  xpEarned,

  // System
  accountVerified,
  profileIncomplete,
  systemAlert,
  promotion,
}

/// Notification priority
enum NotificationPriority { low, normal, high, urgent }

/// Notification model
@freezed
abstract class NotificationModel with _$NotificationModel {
  const NotificationModel._();

  const factory NotificationModel({
    required String id,
    required String userId,
    required NotificationType type,
    required String title,
    required String body,
    @Default(NotificationPriority.normal) NotificationPriority priority,

    // Related entity
    String? referenceId,
    String? referenceType,

    // Sender info (for social notifications)
    String? senderId,
    String? senderName,
    String? senderPhotoUrl,

    // Action
    String? actionUrl,
    @Default({}) Map<String, dynamic> data,

    // Status
    @Default(false) bool isRead,
    @Default(false) bool isArchived,
    @Default(false) bool isPushSent,

    // Timestamps
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? readAt,
    @TimestampConverter() DateTime? expiresAt,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  /// Get icon for notification type
  String get iconName {
    switch (type) {
      case NotificationType.rideBookingRequest:
        return 'person_add';
      case NotificationType.rideBookingAccepted:
        return 'check_circle';
      case NotificationType.rideBookingRejected:
        return 'cancel';
      case NotificationType.rideBookingCancelled:
        return 'event_busy';
      case NotificationType.rideStartingSoon:
        return 'schedule';
      case NotificationType.rideStarted:
        return 'directions_car';
      case NotificationType.rideCompleted:
        return 'flag';
      case NotificationType.rideCancelled:
        return 'block';
      case NotificationType.rideUpdated:
        return 'update';
      case NotificationType.newMessage:
      case NotificationType.newGroupMessage:
        return 'chat_bubble';
      case NotificationType.newFollower:
      case NotificationType.followAccepted:
        return 'person';
      case NotificationType.levelUp:
        return 'arrow_upward';
      case NotificationType.achievementUnlocked:
        return 'emoji_events';
      case NotificationType.streakMilestone:
        return 'local_fire_department';
      case NotificationType.leaderboardRank:
        return 'leaderboard';
      case NotificationType.xpEarned:
        return 'star';
      case NotificationType.accountVerified:
        return 'verified';
      case NotificationType.profileIncomplete:
        return 'warning';
      case NotificationType.systemAlert:
        return 'notifications';
      case NotificationType.promotion:
        return 'campaign';
    }
  }

  /// Get color for notification type
  String get colorName {
    switch (type) {
      case NotificationType.rideBookingAccepted:
      case NotificationType.rideCompleted:
      case NotificationType.accountVerified:
      case NotificationType.levelUp:
      case NotificationType.achievementUnlocked:
        return 'success';
      case NotificationType.rideBookingRejected:
      case NotificationType.rideBookingCancelled:
      case NotificationType.rideCancelled:
        return 'error';
      case NotificationType.rideStartingSoon:
      case NotificationType.profileIncomplete:
        return 'warning';
      case NotificationType.xpEarned:
      case NotificationType.streakMilestone:
        return 'gold';
      default:
        return 'primary';
    }
  }

  /// Is expired
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
}

/// Notification preferences
@freezed
abstract class NotificationPreferences with _$NotificationPreferences {
  const factory NotificationPreferences({
    // Push notifications
    @Default(true) bool pushEnabled,
    @Default(true) bool rideNotifications,
    @Default(true) bool messageNotifications,
    @Default(true) bool socialNotifications,
    @Default(true) bool gamificationNotifications,
    @Default(true) bool promotionNotifications,

    // Email notifications
    @Default(true) bool emailEnabled,
    @Default(true) bool emailRideSummary,
    @Default(true) bool emailWeeklyDigest,

    // Quiet hours
    @Default(false) bool quietHoursEnabled,
    @Default('22:00') String quietHoursStart,
    @Default('08:00') String quietHoursEnd,

    // Sound & vibration
    @Default(true) bool soundEnabled,
    @Default(true) bool vibrationEnabled,
  }) = _NotificationPreferences;

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferencesFromJson(json);
}
