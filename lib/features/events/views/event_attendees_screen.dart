import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/events/view_models/event_view_model.dart';
import 'package:sport_connect/features/messaging/view_models/chat_view_model.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';

class EventAttendeesScreen extends ConsumerWidget {
  const EventAttendeesScreen({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventByIdProvider(eventId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.adaptive.arrow_back_rounded, size: 20.sp),
          onPressed: () => context.pop(),
        ),
        title: Text(
          eventAsync.value != null
              ? 'Attendees (${eventAsync.value!.participantIds.length})'
              : 'Attendees',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
      ),
      body: eventAsync.when(
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
        error: (e, _) => Center(
          child: Text('Failed to load attendees', style: TextStyle(color: AppColors.error)),
        ),
        data: (event) {
          if (event == null || event.participantIds.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group_off_rounded, size: 48.sp, color: AppColors.textTertiary),
                  SizedBox(height: 12.h),
                  Text('No attendees yet', style: TextStyle(fontSize: 15.sp, color: AppColors.textSecondary)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
            itemCount: event.participantIds.length,
            separatorBuilder: (_, _) => SizedBox(height: 8.h),
            itemBuilder: (context, i) => _AttendeeCard(
              userId: event.participantIds[i],
              eventId: eventId,
            ),
          );
        },
      ),
    );
  }
}

class _AttendeeCard extends ConsumerWidget {
  const _AttendeeCard({required this.userId, required this.eventId});

  final String userId;
  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider(userId));
    final profile = profileAsync.value;
    final currentUser = ref.watch(currentUserProvider).value;
    final isSelf = currentUser?.uid == userId;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24.r,
            backgroundColor: AppColors.primarySurface,
            backgroundImage: profile?.photoUrl != null ? NetworkImage(profile!.photoUrl!) : null,
            child: profile?.photoUrl == null
                ? Icon(Icons.person_rounded, size: 22.sp, color: AppColors.primary)
                : null,
          ),
          SizedBox(width: 12.w),
          // Name + expertise + rating
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        profile?.displayName ?? '…',
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isSelf) ...[
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text('You', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: AppColors.primary)),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    if (profile?.expertise != null) ...[
                      Icon(Icons.fitness_center_rounded, size: 12.sp, color: AppColors.textTertiary),
                      SizedBox(width: 3.w),
                      Text(
                        profile!.expertise.displayName,
                        style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                      ),
                      SizedBox(width: 10.w),
                    ],
                    Icon(Icons.star_rounded, size: 12.sp, color: AppColors.accent),
                    SizedBox(width: 3.w),
                    Text(
                      (profile?.rating.average ?? 0.0).toStringAsFixed(1),
                      style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Message button (skip for self)
          if (!isSelf)
            IconButton(
              onPressed: () => _openChat(context, ref, profile, currentUser),
              icon: Icon(Icons.chat_bubble_outline_rounded, size: 20.sp, color: AppColors.primary),
              tooltip: 'Message',
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                padding: EdgeInsets.all(8.w),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openChat(
    BuildContext context,
    WidgetRef ref,
    UserModel? profile,
    UserModel? currentUser,
  ) async {
    if (profile == null || currentUser == null) return;
    try {
      final chat = await ref.read(getOrCreateChatProvider(
        userId1: currentUser.uid,
        userId2: userId,
        userName1: currentUser.displayName,
        userName2: profile.displayName,
        userPhoto1: currentUser.photoUrl,
        userPhoto2: profile.photoUrl,
      ).future);
      if (!context.mounted) return;
      context.pushNamed(
        AppRoutes.chatDetail.name,
        pathParameters: {'id': chat.id},
        extra: profile,
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to open chat. Please try again.')),
        );
      }
    }
  }
}
