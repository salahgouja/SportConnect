import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/interfaces/repositories/i_notification_repository.dart';
import 'package:sport_connect/features/notifications/models/notification_model.dart';

part 'notification_repository.g.dart';

/// Notification Repository for Firestore operations
class NotificationRepository implements INotificationRepository {
  final FirebaseFirestore _firestore;

  NotificationRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> get _notificationsCollection =>
      _firestore.collection(AppConstants.notificationsCollection);

  // ==================== NOTIFICATION OPERATIONS ====================

  /// Create a notification
  Future<String> createNotification(NotificationModel notification) async {
    final docRef = _notificationsCollection.doc();
    final notificationWithId = notification.copyWith(
      id: docRef.id,
      createdAt: DateTime.now(),
    );
    await docRef.set(notificationWithId.toJson());
    return docRef.id;
  }

  /// Get notification by ID
  Future<NotificationModel?> getNotificationById(String id) async {
    final doc = await _notificationsCollection.doc(id).get();
    if (!doc.exists) return null;
    return NotificationModel.fromJson(doc.data()!);
  }

  /// Stream user's notifications
  Stream<List<NotificationModel>> streamUserNotifications(String userId) {
    return _notificationsCollection
        .where('userId', isEqualTo: userId)
        .where('isArchived', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NotificationModel.fromJson(doc.data()))
              .toList(),
        );
  }

  /// Stream unread notification count
  Stream<int> streamUnreadCount(String userId) {
    return _notificationsCollection
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .where('isArchived', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Get user's notifications (paginated)
  Future<List<NotificationModel>> getUserNotifications({
    required String userId,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    var query = _notificationsCollection
        .where('userId', isEqualTo: userId)
        .where('isArchived', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => NotificationModel.fromJson(doc.data()))
        .toList();
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await _notificationsCollection.doc(notificationId).update({
      'isRead': true,
      'readAt': FieldValue.serverTimestamp(),
    });
  }

  /// Mark all user notifications as read
  Future<void> markAllAsRead(String userId) async {
    final batch = _firestore.batch();
    final snapshot = await _notificationsCollection
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  /// Archive notification (soft delete)
  Future<void> archiveNotification(String notificationId) async {
    await _notificationsCollection.doc(notificationId).update({
      'isArchived': true,
    });
  }

  /// Archive all user notifications
  Future<void> archiveAll(String userId) async {
    final batch = _firestore.batch();
    final snapshot = await _notificationsCollection
        .where('userId', isEqualTo: userId)
        .where('isArchived', isEqualTo: false)
        .get();

    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isArchived': true});
    }

    await batch.commit();
  }

  /// Delete notification permanently
  Future<void> deleteNotification(String notificationId) async {
    await _notificationsCollection.doc(notificationId).delete();
  }

  /// Send ride booking request notification
  Future<void> sendRideBookingRequest({
    required String toUserId,
    required String fromUserId,
    required String fromUserName,
    String? fromUserPhoto,
    required String rideId,
    required String rideName,
  }) async {
    await createNotification(
      NotificationModel(
        id: '',
        userId: toUserId,
        type: NotificationType.rideBookingRequest,
        title: 'New Ride Request',
        body: '$fromUserName wants to join your ride "$rideName"',
        senderId: fromUserId,
        senderName: fromUserName,
        senderPhotoUrl: fromUserPhoto,
        referenceId: rideId,
        referenceType: 'ride',
        priority: NotificationPriority.high,
      ),
    );
  }

  /// Send ride booking accepted notification
  Future<void> sendRideBookingAccepted({
    required String toUserId,
    required String driverName,
    String? driverPhoto,
    required String rideId,
    required String rideName,
  }) async {
    await createNotification(
      NotificationModel(
        id: '',
        userId: toUserId,
        type: NotificationType.rideBookingAccepted,
        title: 'Booking Accepted!',
        body: '$driverName accepted your request for "$rideName"',
        senderName: driverName,
        senderPhotoUrl: driverPhoto,
        referenceId: rideId,
        referenceType: 'ride',
        priority: NotificationPriority.high,
      ),
    );
  }

  /// Send ride booking rejected notification
  Future<void> sendRideBookingRejected({
    required String toUserId,
    required String driverName,
    String? driverPhoto,
    required String rideId,
    required String rideName,
    String? reason,
  }) async {
    final body = reason != null && reason.isNotEmpty
        ? '$driverName declined your request for "$rideName": $reason'
        : '$driverName declined your request for "$rideName"';

    await createNotification(
      NotificationModel(
        id: '',
        userId: toUserId,
        type: NotificationType.rideBookingRejected,
        title: 'Booking Declined',
        body: body,
        senderName: driverName,
        senderPhotoUrl: driverPhoto,
        referenceId: rideId,
        referenceType: 'ride',
        priority: NotificationPriority.high,
      ),
    );
  }

  /// Send ride cancelled notification to a passenger
  Future<void> sendRideCancelled({
    required String toUserId,
    required String driverName,
    String? driverPhoto,
    required String rideId,
    required String rideName,
    String? reason,
  }) async {
    final body = reason != null && reason.isNotEmpty
        ? '$driverName cancelled the ride "$rideName": $reason'
        : '$driverName cancelled the ride "$rideName"';

    await createNotification(
      NotificationModel(
        id: '',
        userId: toUserId,
        type: NotificationType.rideCancelled,
        title: 'Ride Cancelled',
        body: body,
        senderName: driverName,
        senderPhotoUrl: driverPhoto,
        referenceId: rideId,
        referenceType: 'ride',
        priority: NotificationPriority.urgent,
      ),
    );
  }

  /// Send new message notification
  Future<void> sendNewMessageNotification({
    required String toUserId,
    required String fromUserId,
    required String fromUserName,
    String? fromUserPhoto,
    required String chatId,
    required String messagePreview,
  }) async {
    await createNotification(
      NotificationModel(
        id: '',
        userId: toUserId,
        type: NotificationType.newMessage,
        title: 'New Message',
        body: '$fromUserName: $messagePreview',
        senderId: fromUserId,
        senderName: fromUserName,
        senderPhotoUrl: fromUserPhoto,
        referenceId: chatId,
        referenceType: 'chat',
      ),
    );
  }

  /// Send achievement notification
  Future<void> sendAchievementNotification({
    required String userId,
    required String achievementName,
    required String achievementDescription,
  }) async {
    await createNotification(
      NotificationModel(
        id: '',
        userId: userId,
        type: NotificationType.achievementUnlocked,
        title: 'Achievement Unlocked! 🏆',
        body: 'You earned "$achievementName" - $achievementDescription',
        priority: NotificationPriority.normal,
      ),
    );
  }
}

@riverpod
NotificationRepository notificationRepository(Ref ref) {
  return NotificationRepository(FirebaseFirestore.instance);
}

/// Provider for streaming user notifications
@riverpod
Stream<List<NotificationModel>> userNotificationsStream(
  Ref ref,
  String userId,
) {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.streamUserNotifications(userId);
}

/// Provider for streaming unread count
@riverpod
Stream<int> unreadNotificationCount(Ref ref, String userId) {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.streamUnreadCount(userId);
}
