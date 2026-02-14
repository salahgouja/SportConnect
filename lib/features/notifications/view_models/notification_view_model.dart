import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/features/notifications/models/notification_model.dart';
import 'package:sport_connect/features/notifications/repositories/notification_repository.dart';

part 'notification_view_model.g.dart';

/// State for managing notifications UI
class NotificationState {
  final bool isLoading;
  final String? errorMessage;
  final List<String> selectedNotificationIds;
  final NotificationFilter filter;

  const NotificationState({
    this.isLoading = false,
    this.errorMessage,
    this.selectedNotificationIds = const [],
    this.filter = NotificationFilter.all,
  });

  NotificationState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<String>? selectedNotificationIds,
    NotificationFilter? filter,
  }) {
    return NotificationState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedNotificationIds:
          selectedNotificationIds ?? this.selectedNotificationIds,
      filter: filter ?? this.filter,
    );
  }
}

/// Filter options for notifications
enum NotificationFilter { all, unread, rides, payments, messages }

/// ViewModel for notifications screen
@riverpod
class NotificationViewModel extends _$NotificationViewModel {
  @override
  NotificationState build() {
    return const NotificationState();
  }

  String? _getCurrentUserId() {
    final userAsync = ref.read(currentUserProvider);
    return userAsync.value?.uid;
  }

  /// Set filter
  void setFilter(NotificationFilter filter) {
    state = state.copyWith(filter: filter);
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    final userId = _getCurrentUserId();
    if (userId == null) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repository = ref.read(notificationRepositoryProvider);
      await repository.markAsRead(notificationId);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to mark as read: $e',
      );
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    final userId = _getCurrentUserId();
    if (userId == null) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repository = ref.read(notificationRepositoryProvider);
      await repository.markAllAsRead(userId);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to mark all as read: $e',
      );
    }
  }

  /// Archive all notifications for current user
  Future<void> archiveAll() async {
    final userId = _getCurrentUserId();
    if (userId == null) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repository = ref.read(notificationRepositoryProvider);
      await repository.archiveAll(userId);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to clear notifications: $e',
      );
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repository = ref.read(notificationRepositoryProvider);
      await repository.archiveNotification(notificationId);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to delete notification: $e',
      );
    }
  }

  /// Toggle selection for batch operations
  void toggleSelection(String notificationId) {
    final currentSelection = List<String>.from(state.selectedNotificationIds);
    if (currentSelection.contains(notificationId)) {
      currentSelection.remove(notificationId);
    } else {
      currentSelection.add(notificationId);
    }
    state = state.copyWith(selectedNotificationIds: currentSelection);
  }

  /// Clear selection
  void clearSelection() {
    state = state.copyWith(selectedNotificationIds: []);
  }

  /// Delete selected notifications
  Future<void> deleteSelected() async {
    if (state.selectedNotificationIds.isEmpty) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repository = ref.read(notificationRepositoryProvider);
      for (final id in state.selectedNotificationIds) {
        await repository.archiveNotification(id);
      }
      state = state.copyWith(isLoading: false, selectedNotificationIds: []);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to delete notifications: $e',
      );
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Stream provider for user notifications
@riverpod
Stream<List<NotificationModel>> userNotifications(Ref ref) {
  final userAsync = ref.watch(currentUserProvider);
  final user = userAsync.value;
  if (user == null) {
    return Stream.value([]);
  }

  final repository = ref.watch(notificationRepositoryProvider);
  return repository.streamUserNotifications(user.uid);
}

/// Provider for unread notification count
@riverpod
Stream<int> unreadNotificationCount(Ref ref) {
  final userAsync = ref.watch(currentUserProvider);
  final user = userAsync.value;
  if (user == null) {
    return Stream.value(0);
  }

  final repository = ref.watch(notificationRepositoryProvider);
  return repository.streamUnreadCount(user.uid);
}
