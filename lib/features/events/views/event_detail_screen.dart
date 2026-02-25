import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/app_spacing.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/core/widgets/premium_card.dart';
import 'package:sport_connect/features/events/models/event_model.dart';
import 'package:sport_connect/features/events/view_models/event_view_model.dart';

/// Full-screen event detail with hero banner, info sections and join/leave CTA.
class EventDetailScreen extends ConsumerStatefulWidget {
  const EventDetailScreen({super.key, required this.eventId});

  final String eventId;

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  final _dateFormatter = DateFormat('EEE, MMM d · h:mm a');

  // ------------------------------------------------------------------
  // Helpers
  // ------------------------------------------------------------------
  bool _isParticipant(EventModel event, String userId) =>
      event.participantIds.contains(userId);

  bool _isCreator(EventModel event, String userId) => event.creatorId == userId;

  // ------------------------------------------------------------------
  // Build
  // ------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventByIdProvider(widget.eventId));
    final detailVm = ref.watch(eventDetailViewModelProvider(widget.eventId));
    final currentUser = ref.watch(currentUserProvider).value;
    final userId = currentUser?.uid ?? '';

    // Listen for success / error messages from the view-model.
    ref.listen<EventDetailState>(eventDetailViewModelProvider(widget.eventId), (
      prev,
      next,
    ) {
      if (next.successMessage != null &&
          next.successMessage != prev?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        );
        ref
            .read(eventDetailViewModelProvider(widget.eventId).notifier)
            .clearMessages();
      }
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        );
        ref
            .read(eventDetailViewModelProvider(widget.eventId).notifier)
            .clearMessages();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: eventAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorBody(message: e.toString()),
        data: (event) {
          if (event == null) {
            return const _ErrorBody(message: 'Event not found.');
          }
          return _buildBody(event, userId, detailVm);
        },
      ),
    );
  }

  Widget _buildBody(
    EventModel event,
    String userId,
    EventDetailState detailState,
  ) {
    final isOwner = _isCreator(event, userId);
    final isJoined = _isParticipant(event, userId);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── Hero app bar ──
        _buildSliverAppBar(event, isOwner),

        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),

                // ── Title & type badge ──
                _TitleSection(event: event)
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.05, end: 0),

                SizedBox(height: 20.h),

                // ── Date & venue info cards ──
                _InfoRow(
                  icon: Icons.calendar_today_rounded,
                  label: _dateFormatter.format(event.startsAt),
                  sublabel: event.endsAt != null
                      ? 'Until ${_dateFormatter.format(event.endsAt!)}'
                      : null,
                ).animate().fadeIn(delay: 100.ms, duration: 350.ms),

                SizedBox(height: 12.h),

                if (event.venueName != null) ...[
                  _InfoRow(
                    icon: Icons.location_on_rounded,
                    label: event.venueName!,
                    sublabel: event.location.address,
                  ).animate().fadeIn(delay: 150.ms, duration: 350.ms),
                  SizedBox(height: 12.h),
                ],

                if (event.organizerName != null) ...[
                  _InfoRow(
                    icon: Icons.person_rounded,
                    label: event.organizerName!,
                    sublabel: 'Organizer',
                  ).animate().fadeIn(delay: 200.ms, duration: 350.ms),
                  SizedBox(height: 12.h),
                ],

                // ── Participants chip ──
                _ParticipantChip(
                  event: event,
                ).animate().fadeIn(delay: 250.ms, duration: 350.ms),

                SizedBox(height: 24.h),

                // ── Description ──
                if (event.description != null &&
                    event.description!.isNotEmpty) ...[
                  Text(
                    'About',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    event.description!,
                    style: TextStyle(
                      fontSize: 15.sp,
                      height: 1.55,
                      color: AppColors.textSecondary,
                    ),
                  ).animate().fadeIn(delay: 300.ms, duration: 350.ms),
                  SizedBox(height: 24.h),
                ],

                // ── Participant list preview ──
                if (event.participantIds.isNotEmpty) ...[
                  Text(
                    'Participants (${event.participantIds.length})',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _ParticipantAvatars(
                    participantIds: event.participantIds,
                  ).animate().fadeIn(delay: 350.ms, duration: 350.ms),
                  SizedBox(height: 24.h),
                ],

                // ── Action button ──
                if (!isOwner && event.isUpcoming)
                  _buildJoinLeaveButton(
                    event,
                    userId,
                    isJoined,
                    detailState,
                  ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

                if (isOwner && event.isUpcoming)
                  _buildOwnerActions(
                    event,
                    detailState,
                  ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

                // Bottom safe-area padding
                SizedBox(height: MediaQuery.of(context).padding.bottom + 32.h),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------------
  // Sliver app bar
  // ------------------------------------------------------------------
  SliverAppBar _buildSliverAppBar(EventModel event, bool isOwner) {
    return SliverAppBar(
      expandedHeight: 220.h,
      pinned: true,
      stretch: true,
      backgroundColor: event.type.color,
      leading: _CircleBackButton(onTap: () => context.pop()),
      actions: [
        if (isOwner)
          IconButton(
            icon: Icon(Icons.edit_rounded, color: Colors.white, size: 22.sp),
            onPressed: () =>
                context.push('/events/${event.id}/edit', extra: event),
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: _HeroBanner(event: event),
        collapseMode: CollapseMode.parallax,
      ),
    );
  }

  // ------------------------------------------------------------------
  // Join / Leave button
  // ------------------------------------------------------------------
  Widget _buildJoinLeaveButton(
    EventModel event,
    String userId,
    bool isJoined,
    EventDetailState detailState,
  ) {
    if (isJoined) {
      return PremiumButton(
        text: 'Leave Event',
        style: PremiumButtonStyle.ghost,
        icon: Icons.logout_rounded,
        fullWidth: true,
        isLoading: detailState.isLeaving,
        onPressed: () async {
          HapticFeedback.mediumImpact();
          await ref
              .read(eventDetailViewModelProvider(widget.eventId).notifier)
              .leaveEvent(userId);
        },
      );
    }

    final isFull = event.isFull;
    return PremiumButton(
      text: isFull ? 'Event Full' : 'Join Event',
      icon: isFull ? Icons.block_rounded : Icons.group_add_rounded,
      fullWidth: true,
      isLoading: detailState.isJoining,
      isDisabled: isFull,
      onPressed: isFull
          ? null
          : () async {
              HapticFeedback.mediumImpact();
              await ref
                  .read(eventDetailViewModelProvider(widget.eventId).notifier)
                  .joinEvent(userId);
            },
    );
  }

  // ------------------------------------------------------------------
  // Owner action buttons (Edit + Delete)
  // ------------------------------------------------------------------
  Widget _buildOwnerActions(EventModel event, EventDetailState detailState) {
    return Column(
      children: [
        PremiumButton(
          text: 'Edit Event',
          icon: Icons.edit_rounded,
          style: PremiumButtonStyle.secondary,
          fullWidth: true,
          onPressed: () =>
              context.push('/events/${event.id}/edit', extra: event),
        ),
        SizedBox(height: 12.h),
        PremiumButton(
          text: 'Delete Event',
          icon: Icons.delete_outline_rounded,
          style: PremiumButtonStyle.danger,
          fullWidth: true,
          isLoading: detailState.isDeleting,
          onPressed: () async {
            final confirm = await _confirmDelete();
            if (!confirm || !mounted) return;
            HapticFeedback.mediumImpact();
            final deleted = await ref
                .read(eventDetailViewModelProvider(widget.eventId).notifier)
                .deleteEvent();
            if (deleted && mounted) context.pop();
          },
        ),
      ],
    );
  }

  Future<bool> _confirmDelete() async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Event?'),
            content: const Text(
              'This action cannot be undone. All participants will be removed.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

// =============================================================================
// PRIVATE WIDGETS
// =============================================================================

class _CircleBackButton extends StatelessWidget {
  const _CircleBackButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.w),
      child: GestureDetector(
        onTap: onTap,
        child: CircleAvatar(
          backgroundColor: Colors.black26,
          radius: 18.r,
          child: Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 20.sp,
          ),
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.event});
  final EventModel event;

  @override
  Widget build(BuildContext context) {
    if (event.imageUrl != null && event.imageUrl!.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.network(event.imageUrl!, fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  event.type.color.withValues(alpha: 0.85),
                ],
              ),
            ),
          ),
          _SportOverlay(event: event),
        ],
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [event.type.color, event.type.color.withValues(alpha: 0.7)],
        ),
      ),
      child: _SportOverlay(event: event),
    );
  }
}

class _SportOverlay extends StatelessWidget {
  const _SportOverlay({required this.event});
  final EventModel event;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(event.type.icon, size: 52.sp, color: Colors.white70),
          SizedBox(height: 8.h),
          Text(
            event.type.label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _TitleSection extends StatelessWidget {
  const _TitleSection({required this.event});
  final EventModel event;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Type chip
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: event.type.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(event.type.icon, size: 14.sp, color: event.type.color),
              SizedBox(width: 4.w),
              Text(
                event.type.label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: event.type.color,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          event.title,
          style: TextStyle(
            fontSize: 26.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, this.sublabel});

  final IconData icon;
  final String label;
  final String? sublabel;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, size: 20.sp, color: AppColors.primary),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (sublabel != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    sublabel!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticipantChip extends StatelessWidget {
  const _ParticipantChip({required this.event});
  final EventModel event;

  @override
  Widget build(BuildContext context) {
    final color = event.isFull ? AppColors.warning : AppColors.primary;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.group_rounded, size: 18.sp, color: color),
          SizedBox(width: 6.w),
          Text(
            event.participantLabel,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          if (event.seatsLeft > 0) ...[
            SizedBox(width: 4.w),
            Text(
              '· ${event.seatsLeft} left',
              style: TextStyle(
                fontSize: 12.sp,
                color: color.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ParticipantAvatars extends StatelessWidget {
  const _ParticipantAvatars({required this.participantIds});
  final List<String> participantIds;

  @override
  Widget build(BuildContext context) {
    final displayCount = participantIds.length.clamp(0, 8);
    final overflow = participantIds.length - displayCount;

    return Row(
      children: [
        ...List.generate(displayCount, (i) {
          return Padding(
            padding: EdgeInsets.only(right: 4.w),
            child: CircleAvatar(
              radius: 18.r,
              backgroundColor: AppColors.primarySurface,
              child: Icon(
                Icons.person_rounded,
                size: 18.sp,
                color: AppColors.primary,
              ),
            ),
          );
        }),
        if (overflow > 0)
          CircleAvatar(
            radius: 18.r,
            backgroundColor: AppColors.primary,
            child: Text(
              '+$overflow',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48.sp,
              color: AppColors.error,
            ),
            SizedBox(height: 16.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: 24.h),
            PremiumButton(
              text: 'Go Back',
              style: PremiumButtonStyle.ghost,
              onPressed: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }
}
