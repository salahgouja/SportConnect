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
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';
import 'package:sport_connect/core/providers/user_providers.dart';

/// Chat List Screen with real-time Firestore data
class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  StreamSubscription? _incomingCallSubscription;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }


  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _incomingCallSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                controller: _searchController,
                hint: AppLocalizations.of(context).searchConversations,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
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
                  _buildGroupChats(),
                  _buildRideChats(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          FloatingActionButton(
            heroTag: 'chat_list_fab',
            onPressed: () => _showNewChatBottomSheet(context),
            backgroundColor: AppColors.primary,
            child: Icon(Icons.edit_rounded, color: Colors.white, size: 24.sp),
          ).animate().scale(
            begin: const Offset(0, 0),
            duration: 400.ms,
            delay: 300.ms,
            curve: Curves.easeOutBack,
          ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppLocalizations.of(context).messages,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context).comingSoon),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
                icon: Icon(
                  Icons.archive_outlined,
                  color: AppColors.textSecondary,
                  size: 24.sp,
                ),
              ),
            ],
          ),
        ],
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
    final currentUserAsync = ref.watch(currentUserProvider);

    return currentUserAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
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
          loading: () => const Center(child: CircularProgressIndicator()),
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
            final directChats = chats
                .where((c) => c.type == ChatType.private)
                .where((c) {
                  if (_searchQuery.isEmpty) return true;
                  final title = c.getChatTitle(currentUser.uid).toLowerCase();
                  return title.contains(_searchQuery);
                })
                .toList();

            if (directChats.isEmpty) {
              return _buildEmptyState(
                icon: Icons.chat_bubble_outline_rounded,
                title: AppLocalizations.of(context).noConversationsYet,
                subtitle: AppLocalizations.of(context).startAConversationWith,
              );
            }

            return ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              itemCount: directChats.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                indent: 88.w,
                color: AppColors.border.withValues(alpha: 0.5),
              ),
              itemBuilder: (context, index) {
                final chat = directChats[index];
                return _buildChatTile(chat, currentUser.uid)
                    .animate()
                    .fadeIn(
                      duration: 300.ms,
                      delay: Duration(milliseconds: 50 + (index * 60)),
                    )
                    .slideX(begin: 0.1, curve: Curves.easeOutCubic);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildGroupChats() {
    final currentUserAsync = ref.watch(currentUserProvider);

    return currentUserAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
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
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildChatErrorState(
            onRetry: () => ref.invalidate(userChatsProvider(currentUser.uid)),
          ),
          data: (chats) {
            final groupChats = chats
                .where((c) => c.type == ChatType.support || c.groupName != null)
                .where((c) => c.type != ChatType.rideGroup)
                .toList();

            if (groupChats.isEmpty) {
              return _buildEmptyState(
                icon: Icons.group_outlined,
                title: AppLocalizations.of(context).noGroupChats,
                subtitle: AppLocalizations.of(context).joinOrCreateAGroup,
              );
            }

            return ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              itemCount: groupChats.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                indent: 88.w,
                color: AppColors.border.withValues(alpha: 0.5),
              ),
              itemBuilder: (context, index) {
                final chat = groupChats[index];
                return _buildChatTile(chat, currentUser.uid);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildRideChats() {
    final currentUserAsync = ref.watch(currentUserProvider);

    return currentUserAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
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
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildChatErrorState(
            onRetry: () => ref.invalidate(userChatsProvider(currentUser.uid)),
          ),
          data: (chats) {
            final rideChats = chats
                .where((c) => c.type == ChatType.rideGroup)
                .toList();

            if (rideChats.isEmpty) {
              return _buildEmptyState(
                icon: Icons.directions_car_outlined,
                title: AppLocalizations.of(context).noRideChats,
                subtitle: AppLocalizations.of(context).joinARideToChat,
              );
            }

            return ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              itemCount: rideChats.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                indent: 88.w,
                color: AppColors.border.withValues(alpha: 0.5),
              ),
              itemBuilder: (context, index) {
                final chat = rideChats[index];
                return _buildChatTile(
                  chat,
                  currentUser.uid,
                ); // ✅ Pass currentUser.uid
              },
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

  Widget _buildChatTile(ChatModel chat, String currentUserId) {
    final title = chat.getChatTitle(currentUserId);
    final photoUrl = chat.getChatPhoto(currentUserId);
    final unreadCount = chat.getUnreadCount(currentUserId);
    final isOnline = chat.isOtherOnline(currentUserId);
    final lastMessage = chat.lastMessageContent ?? 'No messages yet';
    final lastMessageTime = _formatTime(chat.lastMessageAt);
    final otherParticipant = chat.getOtherParticipant(currentUserId);

    return InkWell(
      onTap: () {
        // Create minimal UserModel for the other participant
        final receiverUser = UserModel.rider(
          uid: otherParticipant?.odid ?? '',
          email: '', // Not needed for chat display
          displayName: title,
          photoUrl: photoUrl,
        );

        context.pushNamed(
          AppRoutes.chatDetail.name,
          pathParameters: {'id': chat.id},
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
                if (isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14.w,
                      height: 14.w,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.background,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
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
      return 'now';
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

  void _showNewChatBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _NewChatBottomSheet(),
    );
  }
}

/// Separate stateful widget for new chat bottom sheet with user search
class _NewChatBottomSheet extends ConsumerStatefulWidget {
  const _NewChatBottomSheet();

  @override
  ConsumerState<_NewChatBottomSheet> createState() =>
      _NewChatBottomSheetState();
}

class _NewChatBottomSheetState extends ConsumerState<_NewChatBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounceTimer;
  List<UserModel> _searchResults = [];
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty || query.length < 2) {
      setState(() {
        _searchResults = [];
        _searchQuery = query;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _searchQuery = query;
      _error = null;
    });

    try {
      final profileActions = ref.read(profileActionsViewModelProvider);
      final results = await profileActions.searchUsers(query: query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to search users';
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToChat(UserModel user) async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Get or create the chat using the repository
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

      if (mounted) {
        // Close loading dialog
        context.pop();
        // Close bottom sheet
        context.pop();

        // Navigate to the actual chat with the real chat ID from Firestore
        context.pushNamed(
          AppRoutes.chatDetail.name,
          pathParameters: {'id': chatModel.id},
          extra: user,
        );
      }
    } catch (e) {
      if (mounted) {
        // Close loading dialog
        context.pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create chat: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                Icon(Icons.edit_rounded, color: AppColors.primary, size: 24.sp),
                SizedBox(width: 12.w),
                Text(
                  AppLocalizations.of(context).newMessage,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => context.pop(),
                  icon: Icon(Icons.close, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          // Search field for users
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).searchUsersByName,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Search results
          Expanded(child: _buildSearchContent()),
        ],
      ),
    );
  }

  Widget _buildSearchContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: AppColors.error),
            SizedBox(height: 16.h),
            Text(
              _error!,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    if (_searchQuery.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search_rounded,
              size: 48.sp,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16.h),
            Text(
              AppLocalizations.of(context).searchForAUserTo,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: 8.h),
            Text(
              AppLocalizations.of(context).typeAtLeast2Characters,
              style: TextStyle(fontSize: 12.sp, color: AppColors.textTertiary),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48.sp,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16.h),
            Text(
              AppLocalizations.of(context).noUsersFoundForValue(_searchQuery),
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      itemCount: _searchResults.length,
      separatorBuilder: (context, index) =>
          Divider(height: 1, color: AppColors.border.withValues(alpha: 0.5)),
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return _buildUserTile(user);
      },
    );
  }

  Widget _buildUserTile(UserModel user) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 8.h),
      leading: user.photoUrl != null
          ? CircleAvatar(
              radius: 24.r,
              backgroundImage: NetworkImage(user.photoUrl!),
            )
          : PremiumAvatar(name: user.displayName, size: 48),
      title: Text(
        user.displayName,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: user.bio != null && user.bio!.isNotEmpty
          ? Text(
              user.bio!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textSecondary,
      ),
      onTap: () => _navigateToChat(user),
    );
  }
}
