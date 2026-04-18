import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/interfaces/repositories/i_notification_repository.dart';
import 'package:sport_connect/core/providers/repository_providers.dart';
import 'package:sport_connect/features/notifications/models/notification_model.dart';

part 'notification_repository.g.dart';

/// Notification Repository for Firestore operations
class NotificationRepository implements INotificationRepository {
  NotificationRepository(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference<NotificationModel> get _notificationsCollection =>
      _firestore
          .collection(AppConstants.notificationsCollection)
          .withConverter<NotificationModel>(
            fromFirestore: (snapshot, _) =>
                NotificationModel.fromJson(snapshot.data()!),
            toFirestore: (notification, _) => notification.toJson(),
          );

  // ==================== NOTIFICATION OPERATIONS ====================

  /// Create a notification
  @override
  Future<String> createNotification(NotificationModel notification) async {
    final docRef = _notificationsCollection.doc();
    final notificationWithId = notification.copyWith(
      id: docRef.id,
      createdAt: DateTime.now(),
    );
    await docRef.set(notificationWithId);
    return docRef.id;
  }

  /// Get notification by ID
  @override
  Future<NotificationModel?> getNotificationById(String id) async {
    final doc = await _notificationsCollection.doc(id).get();
    if (!doc.exists) return null;
    return doc.data();
  }

  /// Stream user's notifications
  @override
  Stream<List<NotificationModel>> streamUserNotifications(String userId) {
    return _notificationsCollection
        .where('userId', isEqualTo: userId)
        .where('isArchived', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Stream unread notification count
  @override
  Stream<int> streamUnreadCount(String userId) {
    return _notificationsCollection
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .where('isArchived', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Get user's notifications (paginated)
  @override
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
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// Mark notification as read
  @override
  Future<void> markAsRead(String notificationId) async {
    await _notificationsCollection.doc(notificationId).update({
      'isRead': true,
      'readAt': DateTime.now(),
    });
  }

  /// Mark all user notifications as read.
  /// Chunks into batches of 499 to stay within Firestore's 500-op limit.
  @override
  Future<void> markAllAsRead(String userId) async {
    final snapshot = await _notificationsCollection
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    final docs = snapshot.docs;
    final now = DateTime.now();
    for (var i = 0; i < docs.length; i += 499) {
      final chunk = docs.sublist(i, (i + 499).clamp(0, docs.length));
      final batch = _firestore.batch();
      for (final doc in chunk) {
        batch.update(doc.reference, {'isRead': true, 'readAt': now});
      }
      await batch.commit();
    }
  }

  /// Archive notification (soft delete)
  @override
  Future<void> archiveNotification(String notificationId) async {
    await _notificationsCollection.doc(notificationId).update({
      'isArchived': true,
    });
  }

  /// Archive all user notifications.
  /// Chunks into batches of 499 to stay within Firestore's 500-op limit.
  @override
  Future<void> archiveAll(String userId) async {
    final snapshot = await _notificationsCollection
        .where('userId', isEqualTo: userId)
        .where('isArchived', isEqualTo: false)
        .get();

    final docs = snapshot.docs;
    for (var i = 0; i < docs.length; i += 499) {
      final chunk = docs.sublist(i, (i + 499).clamp(0, docs.length));
      final batch = _firestore.batch();
      for (final doc in chunk) {
        batch.update(doc.reference, {'isArchived': true});
      }
      await batch.commit();
    }
  }

  /// Delete notification permanently
  @override
  Future<void> deleteNotification(String notificationId) async {
    await _notificationsCollection.doc(notificationId).delete();
  }

  /// Send ride booking request notification
  @override
  Future<void> sendRideBookingRequest({
    required String toUserId,
    required String fromUserId,
    required String fromUserName,
    required String rideId,
    required String rideName,
    String? fromUserPhoto,
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
  @override
  Future<void> sendRideBookingAccepted({
    required String toUserId,
    required String driverName,
    required String rideId,
    required String rideName,
    String? driverPhoto,
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
  @override
  Future<void> sendRideBookingRejected({
    required String toUserId,
    required String driverName,
    required String rideId,
    required String rideName,
    String? driverPhoto,
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
  @override
  Future<void> sendRideCancelled({
    required String toUserId,
    required String driverName,
    required String rideId,
    required String rideName,
    String? driverPhoto,
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
  @override
  Future<void> sendNewMessageNotification({
    required String toUserId,
    required String fromUserId,
    required String fromUserName,
    required String chatId,
    required String messagePreview,
    String? fromUserPhoto,
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
  @override
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
      ),
    );
  }

  /// Send level-up notification
  @override
  Future<void> sendLevelUpNotification({
    required String userId,
    required int newLevel,
  }) async {
    await createNotification(
      NotificationModel(
        id: '',
        userId: userId,
        type: NotificationType.levelUp,
        title: 'Level Up! 🎉',
        body: 'Congratulations! You reached Level $newLevel. Keep riding!',
      ),
    );
  }

  @override
  Future<void> sendDriverArrivedAtPickup({
    required String toUserId,
    required String driverName,
    required String rideId,
    required String rideName,
    String? driverPhoto,
  }) async {
    await createNotification(
      NotificationModel(
        id: '',
        userId: toUserId,
        type: NotificationType.rideUpdated,
        title: 'Driver has arrived! 🚗',
        body:
            '$driverName has arrived at your pickup for $rideName. Head out now!',
        priority: NotificationPriority.high,
        data: {'rideId': rideId, 'driverPhoto': driverPhoto},
      ),
    );
  }

  /// Send event cancelled notification to a participant.
  @override
  Future<void> sendEventCancelled({
    required String toUserId,
    required String organizerName,
    required String eventId,
    required String eventTitle,
    String? organizerPhoto,
    String? reason,
  }) async {
    final body = reason != null && reason.isNotEmpty
        ? '$organizerName cancelled "$eventTitle": $reason'
        : '$organizerName cancelled "$eventTitle"';
    await createNotification(
      NotificationModel(
        id: '',
        userId: toUserId,
        type: NotificationType.eventCancelled,
        title: 'Event Cancelled',
        body: body,
        senderId: organizerName,
        senderName: organizerName,
        senderPhotoUrl: organizerPhoto,
        referenceId: eventId,
        referenceType: 'event',
        priority: NotificationPriority.high,
      ),
    );
  }
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
