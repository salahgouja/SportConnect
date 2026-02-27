import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sport_connect/features/notifications/models/notification_model.dart';

/// Notification Repository Interface for Firestore operations
abstract class INotificationRepository {
  // ==================== NOTIFICATION OPERATIONS ====================

  /// Create a notification
  Future<String> createNotification(NotificationModel notification);

  /// Get notification by ID
  Future<NotificationModel?> getNotificationById(String id);

  /// Stream user's notifications
  Stream<List<NotificationModel>> streamUserNotifications(String userId);

  /// Stream unread notification count
  Stream<int> streamUnreadCount(String userId);

  /// Get user's notifications (paginated)
  Future<List<NotificationModel>> getUserNotifications({
    required String userId,
    int limit = 20,
    DocumentSnapshot? startAfter,
  });

  /// Mark notification as read
  Future<void> markAsRead(String notificationId);

  /// Mark all user notifications as read
  Future<void> markAllAsRead(String userId);

  /// Archive notification (soft delete)
  Future<void> archiveNotification(String notificationId);

  /// Archive all user notifications
  Future<void> archiveAll(String userId);

  /// Delete notification permanently
  Future<void> deleteNotification(String notificationId);

  /// Send ride booking request notification
  Future<void> sendRideBookingRequest({
    required String toUserId,
    required String fromUserId,
    required String fromUserName,
    String? fromUserPhoto,
    required String rideId,
    required String rideName,
  });

  /// Send ride booking accepted notification
  Future<void> sendRideBookingAccepted({
    required String toUserId,
    required String driverName,
    String? driverPhoto,
    required String rideId,
    required String rideName,
  });

  /// Send ride booking rejected notification
  Future<void> sendRideBookingRejected({
    required String toUserId,
    required String driverName,
    String? driverPhoto,
    required String rideId,
    required String rideName,
    String? reason,
  });

  /// Send ride cancelled notification
  Future<void> sendRideCancelled({
    required String toUserId,
    required String driverName,
    String? driverPhoto,
    required String rideId,
    required String rideName,
    String? reason,
  });

  /// Send new message notification
  Future<void> sendNewMessageNotification({
    required String toUserId,
    required String fromUserId,
    required String fromUserName,
    String? fromUserPhoto,
    required String chatId,
    required String messagePreview,
  });

  /// Send achievement notification
  Future<void> sendAchievementNotification({
    required String userId,
    required String achievementName,
    required String achievementDescription,
  });
}
