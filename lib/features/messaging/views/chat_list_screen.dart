import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/app_spacing.dart';
import 'package:sport_connect/core/widgets/premium_avatar.dart';
import 'package:sport_connect/core/widgets/premium_text_field.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/messaging/models/message_model.dart';
import 'package:sport_connect/features/messaging/view_models/chat_view_model.dart';
import 'package:sport_connect/features/profile/view_models/user_search_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/widgets/skeleton_loader.dart';
import 'package:sport_connect/features/messaging/view_models/chat_list_view_model.dart';

/// Chat List Screen with real-time Firestore data
class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uiState = ref.watch(chatListUiViewModelProvider);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Search
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: PremiumSearchField(
                hint: l10n.searchChatsOrPeople,
                onChanged: (value) => ref
                    .read(chatListUiViewModelProvider.notifier)
                    .setSearchQuery(value),
              ),
            ),

            // Tabs
            _buildTabs(),

            // Chat list
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDirectChats(),
                  _buildGroupChats(uiState.searchQuery),
                  _buildRideChats(uiState.searchQuery),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshChatsForUser(String userId) async {
    ref.invalidate(userChatsProvider(userId));
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  Widget _withChatPullToRefresh({
    required String userId,
    required Widget child,
  }) {
    final refreshableChild = child is ScrollView
        ? child
        : ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: 120.h),
              child,
            ],
          );

    return RefreshIndicator.adaptive(
      onRefresh: () => _refreshChatsForUser(userId),
      child: refreshableChild,
    );
  }

  Widget _buildHeader() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 8.h),
        child: Text(
          'Chats',
          style: TextStyle(
            fontSize: 32.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.8,
            height: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: AppSpacing.shadowSm,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
        tabs: [
          Tab(text: AppLocalizations.of(context).direct),
          Tab(text: AppLocalizations.of(context).groups),
          Tab(text: AppLocalizations.of(context).rides),
        ],
      ),
    );
  }

  Widget _buildDirectChats() {
    final searchQuery = ref.watch(chatListUiViewModelProvider).searchQuery;
    final currentUserAsync = ref.watch(currentUserProvider);

    return currentUserAsync.when(
      loading: () => SkeletonLoader(type: SkeletonType.chatTile, itemCount: 6),
      error: (error, stack) => Center(
        child: Text(AppLocalizations.of(context).pleaseLoginToViewChats),
      ),
      data: (currentUser) {
        if (currentUser == null) {
          return Center(
            child: Text(AppLocalizations.of(context).pleaseLoginToViewChats),
          );
        }

        final chatsAsync = ref.watch(userChatsProvider(currentUser.uid));
        final peopleAsync = searchQuery.length >= 2
            ? ref.watch(searchResultsProvider(searchQuery))
            : const AsyncData(<UserModel>[]);

        return chatsAsync.when(
          loading: () =>
              SkeletonLoader(type: SkeletonType.chatTile, itemCount: 6),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48.sp, color: AppColors.error),
                SizedBox(height: 16.h),
                Text(
                  AppLocalizations.of(context).failedToLoadChats,
                  style: TextStyle(fontSize: 16.sp),
                ),
                SizedBox(height: 8.h),
                ElevatedButton(
                  onPressed: () =>
                      ref.refresh(userChatsProvider(currentUser.uid)),
                  child: Text(AppLocalizations.of(context).retry),
                ),
              ],
            ),
          ),
          data: (chats) {
            final blockedIds = currentUser.blockedUsers.toSet();
            final directChats = chats
                .where((c) => c.type == ChatType.private)
                .where((c) {
                  final other = c.getOtherParticipant(currentUser.uid);
                  final otherId = (other != null && other.odid.isNotEmpty)
                      ? other.odid
                      : c.participantIds.firstWhere(
                          (id) => id != currentUser.uid,
                          orElse: () => '',
                        );

                  if (searchQuery.isNotEmpty && blockedIds.contains(otherId)) {
                    return false;
                  }

                  if (searchQuery.isEmpty) return true;
                  final title = c.getChatTitle(currentUser.uid).toLowerCase();
                  return title.contains(searchQuery);
                })
                .toList();

            final peopleMatches = (peopleAsync.value ?? const <UserModel>[])
                .where((user) {
                  if (user.uid == currentUser.uid) {
                    return false;
                  }
                  if (blockedIds.contains(user.uid)) {
                    return false;
                  }
                  if (searchQuery.isEmpty) {
                    return false;
                  }
                  final name = user.displayName.toLowerCase();
                  final email = user.email.toLowerCase();
                  return name.contains(searchQuery) ||
                      email.contains(searchQuery);
                })
                .toList(growable: false);

            final showPeopleSearchBlock = searchQuery.length >= 2;

            if (directChats.isEmpty && !showPeopleSearchBlock) {
              return _withChatPullToRefresh(
                userId: currentUser.uid,
                child: _buildEmptyState(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: AppLocalizations.of(context).noConversationsYet,
                  subtitle: AppLocalizations.of(context).startAConversationWith,
                ),
              );
            }

            return _withChatPullToRefresh(
              userId: currentUser.uid,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: directChats.length + (showPeopleSearchBlock ? 1 : 0),
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  indent: 88.w,
                  color: AppColors.border.withValues(alpha: 0.5),
                ),
                itemBuilder: (context, index) {
                  if (showPeopleSearchBlock && index == 0) {
                    return _buildPeopleSearchSection(
                      peopleAsync: peopleAsync,
                      peopleMatches: peopleMatches,
                      currentUser: currentUser,
                    );
                  }

                  final chatIndex = showPeopleSearchBlock ? index - 1 : index;
                  final chat = directChats[chatIndex];
                  return _buildSwipeableChatTile(chat, currentUser.uid)
                      .animate()
                      .fadeIn(
                        duration: 300.ms,
                        delay: Duration(milliseconds: 50 + (index * 60)),
                      )
                      .slideX(begin: 0.1, curve: Curves.easeOutCubic);
                },
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openChatWithUser(UserModel currentUser, UserModel user) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: AppLocalizations.of(context).creatingChatLabel,
      builder: (context) =>
          const Center(child: CircularProgressIndicator.adaptive()),
    );

    try {
      final chatModel = await ref.read(
        getOrCreateChatProvider(
          userId1: currentUser.uid,
          userId2: user.uid,
          userName1: currentUser.displayName,
          userName2: user.displayName,
          userPhoto1: currentUser.photoUrl,
          userPhoto2: user.photoUrl,
        ).future,
      );

      if (!mounted) return;
      context.pop();
      context.pushNamed(
        AppRoutes.chatDetail.name,
        pathParameters: {'id': chatModel.id},
        queryParameters: {
          'receiverId': user.uid,
          'receiverName': user.displayName,
          if (user.photoUrl != null) 'receiverPhotoUrl': user.photoUrl!,
        },
        extra: user,
      );
    } catch (_) {
      if (!mounted) return;
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).failedToCreateChatTryAgain,
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );
    }
  }

  Widget _buildPeopleSearchSection({
    required AsyncValue<List<UserModel>> peopleAsync,
    required List<UserModel> peopleMatches,
    required UserModel currentUser,
  }) {
    if (peopleAsync.isLoading) {
      return Padding(
        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.h),
        child: Row(
          children: [
            SizedBox(
              width: 16.w,
              height: 16.w,
              child: const CircularProgressIndicator.adaptive(strokeWidth: 2),
            ),
            SizedBox(width: 10.w),
            Text(
              AppLocalizations.of(context).peopleResults,
              style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    if (peopleMatches.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_search_rounded,
                size: 16.sp,
                color: AppColors.primary,
              ),
              SizedBox(width: 6.w),
              Text(
                AppLocalizations.of(context).peopleResults,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  '${peopleMatches.length}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ...peopleMatches.map((user) {
            return Container(
              margin: EdgeInsets.only(bottom: 6.h),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.4),
                ),
              ),
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 10.w),
                leading: user.photoUrl != null
                    ? CircleAvatar(
                        radius: 18.r,
                        backgroundImage: NetworkImage(user.photoUrl!),
                      )
                    : PremiumAvatar(name: user.displayName, size: 36),
                title: Text(
                  user.displayName,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  user.email,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Icon(
                  Icons.north_east_rounded,
                  size: 18.sp,
                  color: AppColors.primary,
                ),
                onTap: () => _openChatWithUser(currentUser, user),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGroupChats(String searchQuery) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return currentUserAsync.when(
      loading: () => SkeletonLoader(type: SkeletonType.chatTile, itemCount: 4),
      error: (error, stack) => Center(
        child: Text(AppLocalizations.of(context).pleaseLoginToViewChats),
      ),
      data: (currentUser) {
        if (currentUser == null) {
          return Center(
            child: Text(AppLocalizations.of(context).pleaseLoginToViewChats),
          );
        }

        final chatsAsync = ref.watch(userChatsProvider(currentUser.uid));

        return chatsAsync.when(
          loading: () =>
              SkeletonLoader(type: SkeletonType.chatTile, itemCount: 4),
          error: (error, stack) => _buildChatErrorState(
            onRetry: () => ref.invalidate(userChatsProvider(currentUser.uid)),
          ),
          data: (chats) {
            final groupChats = chats
                .where(
                  (c) =>
                      c.type == ChatType.support ||
                      c.type == ChatType.eventGroup ||
                      c.groupName != null,
                )
                .where((c) => c.type != ChatType.rideGroup)
                .where((c) {
                  if (searchQuery.isEmpty) return true;
                  final title = c.getChatTitle(currentUser.uid).toLowerCase();
                  return title.contains(searchQuery);
                })
                .toList();

            if (groupChats.isEmpty) {
              return _withChatPullToRefresh(
                userId: currentUser.uid,
                child: _buildEmptyState(
                  icon: Icons.group_outlined,
                  title: AppLocalizations.of(context).noGroupChats,
                  subtitle: AppLocalizations.of(context).joinOrCreateAGroup,
                ),
              );
            }

            return _withChatPullToRefresh(
              userId: currentUser.uid,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: groupChats.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  indent: 88.w,
                  color: AppColors.border.withValues(alpha: 0.5),
                ),
                itemBuilder: (context, index) {
                  final chat = groupChats[index];
                  return _buildSwipeableChatTile(chat, currentUser.uid);
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRideChats(String searchQuery) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return currentUserAsync.when(
      loading: () => SkeletonLoader(type: SkeletonType.chatTile, itemCount: 4),
      error: (error, stack) => Center(
        child: Text(AppLocalizations.of(context).pleaseLoginToViewChats),
      ),
      data: (currentUser) {
        if (currentUser == null) {
          return Center(
            child: Text(AppLocalizations.of(context).pleaseLoginToViewChats),
          );
        }

        final chatsAsync = ref.watch(userChatsProvider(currentUser.uid));

        return chatsAsync.when(
          loading: () =>
              SkeletonLoader(type: SkeletonType.chatTile, itemCount: 4),
          error: (error, stack) => _buildChatErrorState(
            onRetry: () => ref.invalidate(userChatsProvider(currentUser.uid)),
          ),
          data: (chats) {
            final rideChats = chats
                .where((c) => c.type == ChatType.rideGroup)
                .where((c) {
                  if (searchQuery.isEmpty) return true;
                  final title = c.getChatTitle(currentUser.uid).toLowerCase();
                  return title.contains(searchQuery);
                })
                .toList();

            if (rideChats.isEmpty) {
              return _withChatPullToRefresh(
                userId: currentUser.uid,
                child: _buildEmptyState(
                  icon: Icons.directions_car_outlined,
                  title: AppLocalizations.of(context).noRideChats,
                  subtitle: AppLocalizations.of(context).joinARideToChat,
                ),
              );
            }

            return _withChatPullToRefresh(
              userId: currentUser.uid,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: rideChats.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  indent: 88.w,
                  color: AppColors.border.withValues(alpha: 0.5),
                ),
                itemBuilder: (context, index) {
                  final chat = rideChats[index];
                  return _buildSwipeableChatTile(chat, currentUser.uid);
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildChatErrorState({required VoidCallback onRetry}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off_rounded, size: 48.sp, color: AppColors.error),
          SizedBox(height: 16.h),
          Text(
            AppLocalizations.of(context).failedToLoadChats,
            style: TextStyle(fontSize: 16.sp, color: AppColors.textPrimary),
          ),
          SizedBox(height: 8.h),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(AppLocalizations.of(context).retry),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40.sp, color: AppColors.primary),
          ),
          SizedBox(height: 16.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Swipeable wrapper ──────────────────────────────────────────────────────
  /// Wraps a chat tile in a [Dismissible]:
  ///   • Swipe RIGHT  → mute / unmute
  ///   • Swipe LEFT   → delete (confirm dialog, bounces back while feature pending)
  Widget _buildSwipeableChatTile(ChatModel chat, String currentUserId) {
    final isMuted = chat.mutedBy[currentUserId] == true;

    return Dismissible(
      key: ValueKey('chat_${chat.id}'),
      // Mute action (swipe right)
      background: Container(
        margin: EdgeInsets.symmetric(vertical: 2.h),
        decoration: BoxDecoration(
          color: isMuted ? AppColors.warning : AppColors.success,
          borderRadius: BorderRadius.circular(12.r),
        ),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isMuted ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              color: Colors.white,
              size: 24.sp,
            ),
            SizedBox(height: 4.h),
            Text(
              isMuted
                  ? AppLocalizations.of(context).unmuteChat
                  : AppLocalizations.of(context).muteChat,
              style: TextStyle(
                color: Colors.white,
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      // Delete/leave action (swipe left)
      secondaryBackground: Container(
        margin: EdgeInsets.symmetric(vertical: 2.h),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12.r),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.delete_outline_rounded,
              color: Colors.white,
              size: 24.sp,
            ),
            SizedBox(height: 4.h),
            Text(
              AppLocalizations.of(context).deleteChat,
              style: TextStyle(
                color: Colors.white,
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Mute / unmute
          final messenger = ScaffoldMessenger.of(context);
          try {
            await ref
                .read(chatActionsViewModelProvider)
                .toggleMute(
                  chatId: chat.id,
                  userId: currentUserId,
                  mute: !isMuted,
                );
            messenger.showSnackBar(
              SnackBar(
                content: Text(
                  isMuted
                      ? AppLocalizations.of(context).chatUnmuted
                      : AppLocalizations.of(context).chatMuted,
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: isMuted
                    ? AppColors.warning
                    : AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                duration: 2.seconds,
              ),
            );
          } catch (_) {
            messenger.showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context).couldNotClearChatTryAgain,
                ),
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                duration: 2.seconds,
              ),
            );
          }
          return false; // card stays in place
        } else {
          // Confirm before deleting
          final confirmed = await showDialog<bool>(
            context: context,
            barrierLabel: AppLocalizations.of(context).deleteConversationTitle,
            builder: (ctx) => AlertDialog.adaptive(
              title: Text(AppLocalizations.of(context).deleteConversationTitle),
              content: Text(
                AppLocalizations.of(context).deleteConversationMessage,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: Text(AppLocalizations.of(context).actionCancel),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                  child: Text(AppLocalizations.of(context).actionDelete),
                ),
              ],
            ),
          );
          if (confirmed != true) {
            return false;
          }

          try {
            await ref
                .read(chatActionsViewModelProvider)
                .clearChat(chatId: chat.id, userId: currentUserId);

            if (!mounted) return false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context).conversationRemoved),
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.success,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                duration: 2.seconds,
              ),
            );
            return true;
          } catch (_) {
            if (!mounted) return false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context).couldNotClearChatTryAgain,
                ),
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                duration: 2.seconds,
              ),
            );
            return false;
          }
        }
      },
      child: _buildChatTile(chat, currentUserId),
    );
  }

  Widget _buildChatTile(ChatModel chat, String currentUserId) {
    final title = chat.getChatTitle(currentUserId);
    final photoUrl = chat.getChatPhoto(currentUserId);
    final unreadCount = chat.getUnreadCount(currentUserId);
    final lastMessage =
        chat.lastMessageContent ?? AppLocalizations.of(context).noMessagesYet;
    final lastMessageTime = _formatTime(chat.lastMessageAt);
    final otherParticipant = chat.getOtherParticipant(currentUserId);
    final fallbackParticipantId = chat.participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );

    return InkWell(
      onTap: () {
        // Create minimal UserModel for the other participant
        final receiverUser = UserModel.rider(
          uid: otherParticipant?.odid ?? fallbackParticipantId,
          email: '', // Not needed for chat display
          displayName: title,
          photoUrl: photoUrl,
        );

        // Route to correct screen based on chat type
        final routeName = switch (chat.type) {
          ChatType.rideGroup => AppRoutes.chatGroup.name,
          ChatType.eventGroup => AppRoutes.chatGroup.name,
          _ => AppRoutes.chatDetail.name,
        };

        context.pushNamed(
          routeName,
          pathParameters: {'id': chat.id},
          queryParameters: {
            'receiverId': receiverUser.uid,
            'receiverName': receiverUser.displayName,
            if (receiverUser.photoUrl != null)
              'receiverPhotoUrl': receiverUser.photoUrl!,
          },
          extra: receiverUser,
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                photoUrl != null
                    ? CircleAvatar(
                        radius: 28.r,
                        backgroundImage: NetworkImage(photoUrl),
                      )
                    : PremiumAvatar(name: title, size: 56),
              ],
            ),
            SizedBox(width: 12.w),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: unreadCount > 0
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        lastMessageTime,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: unreadCount > 0
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight: unreadCount > 0
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: unreadCount > 0
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontWeight: unreadCount > 0
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unreadCount > 0)
                        Container(
                          margin: EdgeInsets.only(left: 8.w),
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            unreadCount > 99
                                ? AppLocalizations.of(context).text99
                                : AppLocalizations.of(
                                    context,
                                  ).value2(unreadCount),
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return AppLocalizations.of(context).timeNow;
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}
