import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/services/firebase_service.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/app_spacing.dart';
import 'package:sport_connect/core/widgets/premium_avatar.dart';
import 'package:sport_connect/core/widgets/premium_text_field.dart';
import 'package:sport_connect/features/messaging/models/message_model.dart';
import 'package:sport_connect/features/messaging/models/call_model.dart';
import 'package:sport_connect/features/messaging/repositories/call_repository.dart';
import 'package:sport_connect/features/messaging/view_models/chat_view_model.dart';
import 'package:sport_connect/features/messaging/views/chat_detail_screen.dart';
import 'package:sport_connect/features/messaging/views/voice_call_screen.dart';
import 'package:sport_connect/features/messaging/views/video_call_screen.dart';

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

  String get _currentUserId => FirebaseService.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _listenForIncomingCalls();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _incomingCallSubscription?.cancel();
    super.dispose();
  }

  void _listenForIncomingCalls() {
    if (_currentUserId.isEmpty) return;

    final callRepository = ref.read(callRepositoryProvider);
    _incomingCallSubscription = callRepository
        .streamIncomingCalls(_currentUserId)
        .listen((calls) {
          if (calls.isNotEmpty) {
            final call = calls.first;
            _showIncomingCallDialog(call);
          }
        });
  }

  void _showIncomingCallDialog(CallModel call) {
    final routeName = call.type == CallType.video
        ? 'incoming-video-call'
        : 'incoming-voice-call';

    context.pushNamed(
      routeName,
      queryParameters: {
        'callId': call.id,
        'chatId': call.chatId,
        'callerName': call.callerName,
        'callerId': call.callerId,
        if (call.callerPhotoUrl != null) 'callerPhotoUrl': call.callerPhotoUrl!,
      },
    );
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
                hint: 'Search conversations...',
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
            'Messages',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => _showCallHistory(),
                icon: Icon(
                  Icons.phone_rounded,
                  color: AppColors.textSecondary,
                  size: 24.sp,
                ),
              ),
              IconButton(
                onPressed: () {},
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
        color: AppColors.surfaceVariant.withOpacity(0.5),
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
        tabs: const [
          Tab(text: 'Direct'),
          Tab(text: 'Groups'),
          Tab(text: 'Rides'),
        ],
      ),
    );
  }

  Widget _buildDirectChats() {
    if (_currentUserId.isEmpty) {
      return const Center(child: Text('Please login to view chats'));
    }

    final chatsAsync = ref.watch(userChatsProvider(_currentUserId));

    return chatsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: AppColors.error),
            SizedBox(height: 16.h),
            Text('Failed to load chats', style: TextStyle(fontSize: 16.sp)),
            SizedBox(height: 8.h),
            ElevatedButton(
              onPressed: () => ref.refresh(userChatsProvider(_currentUserId)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (chats) {
        // Filter by chat type and search query
        final directChats = chats
            .where((c) => c.type == ChatType.private)
            .where((c) {
              if (_searchQuery.isEmpty) return true;
              final title = c.getChatTitle(_currentUserId).toLowerCase();
              return title.contains(_searchQuery);
            })
            .toList();

        if (directChats.isEmpty) {
          return _buildEmptyState(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'No conversations yet',
            subtitle: 'Start a conversation with your ride partners',
          );
        }

        return ListView.separated(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          itemCount: directChats.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            indent: 88.w,
            color: AppColors.border.withOpacity(0.5),
          ),
          itemBuilder: (context, index) {
            final chat = directChats[index];
            return _buildChatTile(chat)
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
  }

  Widget _buildGroupChats() {
    if (_currentUserId.isEmpty) {
      return const Center(child: Text('Please login to view chats'));
    }

    final chatsAsync = ref.watch(userChatsProvider(_currentUserId));

    return chatsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (chats) {
        final groupChats = chats
            .where((c) => c.type == ChatType.support || c.groupName != null)
            .where((c) => c.type != ChatType.rideGroup)
            .toList();

        if (groupChats.isEmpty) {
          return _buildEmptyState(
            icon: Icons.group_outlined,
            title: 'No group chats',
            subtitle: 'Join or create a group to start chatting',
          );
        }

        return ListView.separated(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          itemCount: groupChats.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            indent: 88.w,
            color: AppColors.border.withOpacity(0.5),
          ),
          itemBuilder: (context, index) {
            final chat = groupChats[index];
            return _buildChatTile(chat);
          },
        );
      },
    );
  }

  Widget _buildRideChats() {
    if (_currentUserId.isEmpty) {
      return const Center(child: Text('Please login to view chats'));
    }

    final chatsAsync = ref.watch(userChatsProvider(_currentUserId));

    return chatsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (chats) {
        final rideChats = chats
            .where((c) => c.type == ChatType.rideGroup)
            .toList();

        if (rideChats.isEmpty) {
          return _buildEmptyState(
            icon: Icons.directions_car_outlined,
            title: 'No ride chats',
            subtitle: 'Join a ride to chat with fellow travelers',
          );
        }

        return ListView.separated(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          itemCount: rideChats.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            indent: 88.w,
            color: AppColors.border.withOpacity(0.5),
          ),
          itemBuilder: (context, index) {
            final chat = rideChats[index];
            return _buildChatTile(chat);
          },
        );
      },
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
              color: AppColors.primary.withOpacity(0.1),
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

  Widget _buildChatTile(ChatModel chat) {
    final title = chat.getChatTitle(_currentUserId);
    final photoUrl = chat.getChatPhoto(_currentUserId);
    final unreadCount = chat.getUnreadCount(_currentUserId);
    final isOnline = chat.isOtherOnline(_currentUserId);
    final lastMessage = chat.lastMessageContent ?? 'No messages yet';
    final lastMessageTime = _formatTime(chat.lastMessageAt);
    final otherParticipant = chat.getOtherParticipant(_currentUserId);

    return InkWell(
      onTap: () {
        context.pushNamed(
          'chat-detail',
          pathParameters: {'id': chat.id},
          queryParameters: {
            'userId': otherParticipant?.odid ?? '',
            'name': title,
            if (photoUrl != null) 'photoUrl': photoUrl,
          },
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
                            unreadCount > 99 ? '99+' : '$unreadCount',
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

  void _showCallHistory() async {
    if (_currentUserId.isEmpty) return;

    final callRepository = ref.read(callRepositoryProvider);
    final history = await callRepository.getCallHistory(userId: _currentUserId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
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
                  Icon(
                    Icons.phone_rounded,
                    color: AppColors.primary,
                    size: 24.sp,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Call History',
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
            Expanded(
              child: history.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 64.sp,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No call history',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final entry = history[index];
                        return _buildCallHistoryTile(entry);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallHistoryTile(CallHistoryEntry entry) {
    final isOutgoing = entry.isOutgoing;
    final isMissed = entry.status == CallStatus.missed;
    final isDeclined = entry.status == CallStatus.declined;

    IconData statusIcon;
    Color statusColor;

    if (isMissed || isDeclined) {
      statusIcon = isOutgoing
          ? Icons.call_made_rounded
          : Icons.call_received_rounded;
      statusColor = AppColors.error;
    } else {
      statusIcon = isOutgoing
          ? Icons.call_made_rounded
          : Icons.call_received_rounded;
      statusColor = AppColors.success;
    }

    return ListTile(
      leading: Stack(
        children: [
          entry.receiverPhotoUrl != null
              ? CircleAvatar(
                  radius: 24.r,
                  backgroundImage: NetworkImage(entry.receiverPhotoUrl!),
                )
              : PremiumAvatar(name: entry.receiverName, size: 48),
        ],
      ),
      title: Text(
        entry.receiverName,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Row(
        children: [
          Icon(statusIcon, size: 16.sp, color: statusColor),
          SizedBox(width: 4.w),
          Text(
            entry.type == CallType.video ? 'Video call' : 'Voice call',
            style: TextStyle(
              fontSize: 14.sp,
              color: isMissed ? AppColors.error : AppColors.textSecondary,
            ),
          ),
          if (entry.duration > 0) ...[
            Text(' • ', style: TextStyle(color: AppColors.textSecondary)),
            Text(
              _formatDuration(entry.duration),
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatTime(entry.timestamp),
            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
          ),
          SizedBox(height: 4.h),
          Icon(
            entry.type == CallType.video
                ? Icons.videocam_rounded
                : Icons.phone_rounded,
            size: 20.sp,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    if (mins > 0) {
      return '${mins}m ${secs}s';
    }
    return '${secs}s';
  }

  void _showNewChatBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
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
                  Icon(
                    Icons.edit_rounded,
                    color: AppColors.primary,
                    size: 24.sp,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'New Message',
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
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // Placeholder for contacts list
            Expanded(
              child: Center(
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
                      'Search for a user to start chatting',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
