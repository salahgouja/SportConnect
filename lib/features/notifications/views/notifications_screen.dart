import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/models/user/user_model.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/app_spacing.dart';
import 'package:sport_connect/core/theme/platform_adaptive.dart';
import 'package:sport_connect/core/widgets/premium_avatar.dart';
import 'package:sport_connect/features/messaging/view_models/chat_view_model.dart';
import 'package:sport_connect/features/notifications/models/notification_model.dart';
import 'package:sport_connect/features/notifications/view_models/notification_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Notifications Screen with Firestore real-time updates
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  void _showStatusSnackBar(String message, {required Color backgroundColor}) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _markAllAsRead() async {
    await ref.read(notificationViewModelProvider.notifier).markAllAsRead();
    _showStatusSnackBar(
      AppLocalizations.of(context).allNotificationsMarkedAsRead,
      backgroundColor: AppColors.success,
    );
  }

  void _clearAll() {
    final userId = ref.read(notificationViewModelProvider).userId;
    if (userId == null) return;

    final scaffoldContext =
        context; // capture outer context to avoid using a deactivated dialog context

    showDialog<void>(
      context: scaffoldContext,
      barrierLabel: AppLocalizations.of(context).clearAllNotifications,
      builder: (dialogContext) => AlertDialog.adaptive(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.dialogRadius),
        ),
        title: Text(AppLocalizations.of(context).clearAllNotifications),
        content: Text(AppLocalizations.of(context).areYouSureYouWant2),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              dialogContext.pop();
              try {
                await ref
                    .read(notificationViewModelProvider.notifier)
                    .archiveAll();
                if (!scaffoldContext.mounted) return;
                ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context).allNotificationsCleared,
                    ),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                );
              } on Object catch (_) {
                if (!scaffoldContext.mounted) return;
                ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context).failedToClearNotifications,
                    ),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(
              AppLocalizations.of(context).clearAll,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vmState = ref.watch(notificationViewModelProvider);

    if (vmState.userId == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(0),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 64.sp,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: 16.h),
              Text(
                AppLocalizations.of(context).pleaseSignInToView,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final userId = vmState.userId!;
    return vmState.notifications.when(
      data: (notifications) => _buildContent(notifications, userId),
      loading: () => Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(0),
        body: _buildLoadingState(),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(0),
        body: _buildErrorState(
          onRetry: () =>
              ref.read(notificationViewModelProvider.notifier).refresh(),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.md),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 14.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          height: 12.h,
                          width: 160.w,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
            .animate(onPlay: (c) => c.repeat())
            .shimmer(duration: 1200.ms, color: AppColors.background);
      },
    );
  }

  Widget _buildErrorState({required VoidCallback onRetry}) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 64.sp,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16.h),
            Text(
              AppLocalizations.of(context).failedToLoadNotifications,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              AppLocalizations.of(context).checkYourConnectionAndTry,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(AppLocalizations.of(context).tryAgain),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(List<NotificationModel> notifications, String userId) {
    final normalizedQuery = _searchQuery.trim().toLowerCase();
    final filteredAllNotifications = normalizedQuery.isEmpty
        ? notifications
        : notifications.where((n) {
            final sender = n.senderName?.toLowerCase() ?? '';
            return n.title.toLowerCase().contains(normalizedQuery) ||
                n.body.toLowerCase().contains(normalizedQuery) ||
                sender.contains(normalizedQuery);
          }).toList();

    final unreadNotifications = filteredAllNotifications
        .where((n) => !n.isRead)
        .toList();
    final allNotifications = filteredAllNotifications;
    final unreadCount = notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(unreadCount),
      body: Column(
        children: [
          // Tabs
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecondary,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10.r),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(AppLocalizations.of(context).unread),
                      if (unreadCount > 0) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            unreadCount.toString(),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Tab(text: AppLocalizations.of(context).all),
              ],
            ),
          ),

          // Search
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).searchConversations,
                hintText: AppLocalizations.of(context).searchConversations,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      ),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Notifications list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildNotificationsList(unreadNotifications, userId),
                _buildNotificationsList(allNotifications, userId),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(int unreadCount) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        tooltip: AppLocalizations.of(context).goBackTooltip,
        icon: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            Icons.adaptive.arrow_back,
            color: AppColors.textPrimary,
            size: 20.sp,
          ),
        ),
        onPressed: () => context.pop(),
      ),
      title: Row(
        children: [
          Text(
            AppLocalizations.of(context).settingsNotifications,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          if (unreadCount > 0) ...[
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                AppLocalizations.of(context).valueNew(unreadCount),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          icon: Icon(Icons.adaptive.more, color: AppColors.textSecondary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          onSelected: (value) {
            if (value == 'mark_read') {
              _markAllAsRead();
            } else if (value == 'clear') {
              _clearAll();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'mark_read',
              child: Row(
                children: [
                  Icon(Icons.done_all, color: AppColors.primary, size: 20.sp),
                  SizedBox(width: 12.w),
                  Text(AppLocalizations.of(context).markAllAsRead),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'clear',
              child: Row(
                children: [
                  Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                    size: 20.sp,
                  ),
                  SizedBox(width: 12.w),
                  Text(AppLocalizations.of(context).clearAll2),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotificationsList(
    List<NotificationModel> notifications,
    String userId,
  ) {
    if (notifications.isEmpty) {
      return RefreshIndicator.adaptive(
        onRefresh: () async {
          ref.read(notificationViewModelProvider.notifier).refresh();
          await Future<void>.delayed(const Duration(milliseconds: 250));
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: 120.h),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 80.sp,
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    AppLocalizations.of(context).noNotifications,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    AppLocalizations.of(context).youReAllCaughtUp,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator.adaptive(
      onRefresh: () async {
        ref.read(notificationViewModelProvider.notifier).refresh();
        await Future<void>.delayed(const Duration(milliseconds: 250));
      },
      child: ListView.builder(
        padding: EdgeInsets.all(AppSpacing.md),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _NotificationTile(
                notification: notification,
                onTap: () => _handleNotificationTap(notification),
                onDismiss: () => _dismissNotification(notification.id),
              )
              .animate()
              .fadeIn(delay: Duration(milliseconds: 50 * index))
              .slideX(begin: 0.1, delay: Duration(milliseconds: 50 * index));
        },
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Mark as read
    if (!notification.isRead) {
      ref
          .read(notificationViewModelProvider.notifier)
          .markAsRead(notification.id);
    }

    // Navigate based on notification type
    switch (notification.type) {
      case NotificationType.rideBookingRequest:
      case NotificationType.rideBookingAccepted:
      case NotificationType.rideBookingRejected:
      case NotificationType.rideStartingSoon:
      case NotificationType.rideStarted:
      case NotificationType.rideCompleted:
        if (notification.referenceId != null) {
          context.pushNamed(
            AppRoutes.rideDetail.name,
            pathParameters: {'id': notification.referenceId!},
          );
        }
      case NotificationType.newMessage:
      case NotificationType.newGroupMessage:
        if (notification.referenceId != null) {
          // referenceId is the chatId
          // We need to fetch the chat to get participant info, then navigate
          _navigateToChatFromNotification(notification.referenceId!);
        }
      case NotificationType.newFollower:
      case NotificationType.followAccepted:
        if (notification.senderId != null) {
          context.pushNamed(
            AppRoutes.profile.name,
            pathParameters: {'userId': notification.senderId!},
          );
        }
      default:
        break;
    }
  }

  void _dismissNotification(String notificationId) {
    ref
        .read(notificationViewModelProvider.notifier)
        .deleteNotification(notificationId);
  }

  Future<void> _navigateToChatFromNotification(String chatId) async {
    final userId = ref.read(notificationViewModelProvider).userId;
    if (userId == null) return;

    try {
      final chatController = ref.read(chatActionsViewModelProvider);
      final chat = await chatController.getChatById(chatId);

      if (chat != null && context.mounted) {
        final title = chat.getChatTitle(userId);
        final photoUrl = chat.getChatPhoto(userId);

        // For group chats or if other participant is missing, use chat title
        final otherParticipant = chat.getOtherParticipant(userId);
        final receiverUser = UserModel.rider(
          uid: otherParticipant?.userId ?? chatId,
          email: '',
          displayName: title,
          photoUrl: photoUrl,
        );

        context.pushNamed(
          AppRoutes.chatDetail.name,
          pathParameters: {'id': chatId},
          extra: receiverUser,
        );
      }
    } on Exception {
      _showStatusSnackBar(
        AppLocalizations.of(context).couldNotOpenChat,
        backgroundColor: AppColors.error,
      );
    }
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16.r),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        child: Icon(Icons.delete, color: Colors.white, size: 24.sp),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: notification.isRead
                ? AppColors.surface
                : AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: notification.isRead
                  ? AppColors.divider
                  : AppColors.primary.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon or Avatar
              _buildNotificationIcon(),
              SizedBox(width: 12.w),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      notification.body,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      _formatTime(notification.createdAt),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon() {
    if (notification.senderPhotoUrl != null) {
      return PremiumAvatar(
        name: notification.senderName ?? '',
        imageUrl: notification.senderPhotoUrl,
        size: 44,
      );
    }

    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case NotificationType.rideBookingRequest:
      case NotificationType.rideBookingAccepted:
      case NotificationType.rideStartingSoon:
      case NotificationType.rideStarted:
      case NotificationType.rideCompleted:
        iconData = Icons.directions_car_rounded;
        iconColor = AppColors.primary;
      case NotificationType.rideBookingRejected:
      case NotificationType.rideBookingCancelled:
      case NotificationType.rideCancelled:
        iconData = Icons.cancel_rounded;
        iconColor = AppColors.error;
      case NotificationType.newMessage:
      case NotificationType.newGroupMessage:
        iconData = Icons.message_rounded;
        iconColor = AppColors.info;
      case NotificationType.achievementUnlocked:
      case NotificationType.levelUp:
        iconData = Icons.emoji_events_rounded;
        iconColor = AppColors.warning;
      case NotificationType.xpEarned:
        iconData = Icons.star_rounded;
        iconColor = AppColors.warning;
      default:
        iconData = Icons.notifications_rounded;
        iconColor = AppColors.textSecondary;
    }

    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(iconData, color: iconColor, size: 24.sp),
    );
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return DateFormat.MMMd().format(dateTime);
    }
  }
}
