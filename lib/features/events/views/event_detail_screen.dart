import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/models/location/location_point.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/app_spacing.dart';
import 'package:sport_connect/core/widgets/map_location_picker.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/core/widgets/premium_card.dart';
import 'package:sport_connect/features/events/models/event_model.dart';
import 'package:sport_connect/features/events/view_models/event_view_model.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:sport_connect/l10n/generated/app_localizations.dart';

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
            return _ErrorBody(
              message: AppLocalizations.of(context).eventNotFound,
            );
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

                _OrganizerRow(
                  creatorId: event.creatorId,
                ).animate().fadeIn(delay: 200.ms, duration: 350.ms),
                SizedBox(height: 12.h),

                // ── Participants chip ──
                _ParticipantChip(
                  event: event,
                ).animate().fadeIn(delay: 250.ms, duration: 350.ms),

                SizedBox(height: 16.h),

                // ── Status badge ──
                _StatusBadge(
                  isOwner: isOwner,
                  isJoined: isJoined,
                  event: event,
                ).animate().fadeIn(delay: 275.ms, duration: 350.ms),

                SizedBox(height: 24.h),

                // ── Description ──
                if (event.description != null &&
                    event.description!.isNotEmpty) ...[
                  Text(
                    AppLocalizations.of(context).eventAbout,
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
                    AppLocalizations.of(
                      context,
                    ).eventParticipantsCount(event.participantIds.length),
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

                SizedBox(height: 24.h),

                if (isOwner && event.isUpcoming)
                  _buildOwnerActions(
                    event,
                    detailState,
                  ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

                // ── #27: Event Attendee Ride Counter ──
                if (event.participantIds.isNotEmpty) ...[
                  SizedBox(height: 16.h),
                  _RideStatusCounter(
                    event: event,
                  ).animate().fadeIn(delay: 410.ms, duration: 350.ms),
                ],

                // ── #24: RSVP with Ride Status ──
                if (!isOwner && isJoined && event.isUpcoming) ...[
                  SizedBox(height: 16.h),
                  _RideStatusSelector(
                    event: event,
                    userId: userId,
                    onStatusSelected: (status) async {
                      HapticFeedback.selectionClick();
                      await ref
                          .read(
                            eventDetailViewModelProvider(
                              widget.eventId,
                            ).notifier,
                          )
                          .setRideStatus(userId, status);
                    },
                  ).animate().fadeIn(delay: 420.ms, duration: 350.ms),
                ],

                // ── #22: Rides to This Event ──
                if (event.isUpcoming || event.isOngoing) ...[
                  SizedBox(height: 24.h),
                  _EventRidesSection(
                    eventId: widget.eventId,
                    event: event,
                  ).animate().fadeIn(delay: 430.ms, duration: 350.ms),
                ],

                // ── #31: Parking Info ──
                if (event.parkingInfo != null &&
                    event.parkingInfo!.isNotEmpty) ...[
                  SizedBox(height: 16.h),
                  _ParkingInfoCard(
                    info: event.parkingInfo!,
                  ).animate().fadeIn(delay: 440.ms, duration: 350.ms),
                ],

                // ── #28: Recurring Event Info ──
                if (event.isRecurring) ...[
                  SizedBox(height: 16.h),
                  _RecurringEventBadge(
                    event: event,
                  ).animate().fadeIn(delay: 445.ms, duration: 350.ms),
                ],

                // ── #32: Cost Split Badge ──
                if (event.costSplitEnabled) ...[
                  SizedBox(height: 12.h),
                  _CostSplitBadge().animate().fadeIn(
                    delay: 448.ms,
                    duration: 350.ms,
                  ),
                ],

                // ── #30: Post-Event Meetup Pin ──
                if ((event.isOngoing || event.hasEnded) && isJoined) ...[
                  SizedBox(height: 16.h),
                  _MeetupPinSection(
                    event: event,
                    isOwner: isOwner,
                    onSetPin: () => _setMeetupPin(event),
                  ).animate().fadeIn(delay: 450.ms, duration: 350.ms),
                ],

                // ── #29: Event Chat Group ──
                if (isJoined && event.participantIds.length >= 2) ...[
                  SizedBox(height: 16.h),
                  _EventChatButton(
                    event: event,
                  ).animate().fadeIn(delay: 455.ms, duration: 350.ms),
                ],

                // ── #23: Need Ride Home button ──
                if ((event.isOngoing || event.hasEnded) && isJoined) ...[
                  SizedBox(height: 16.h),
                  PremiumButton(
                    text: AppLocalizations.of(context).eventNeedRideHome,
                    icon: Icons.home_rounded,
                    style: PremiumButtonStyle.secondary,
                    fullWidth: true,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      context.push(
                        AppRoutes.searchRides.path,
                        extra: {
                          'originAddress':
                              event.venueName ?? event.location.address,
                          'originLat': event.location.latitude,
                          'originLng': event.location.longitude,
                        },
                      );
                    },
                  ).animate().fadeIn(delay: 460.ms, duration: 350.ms),
                ],

                // ── Find Rides CTA (#26: Auto-Suggest Carpool) ──
                if (event.isUpcoming) ...[
                  SizedBox(height: 16.h),
                  PremiumButton(
                    text: AppLocalizations.of(context).eventFindRides,
                    icon: Icons.directions_car_rounded,
                    style: PremiumButtonStyle.secondary,
                    fullWidth: true,
                    onPressed: () => context.push(
                      AppRoutes.searchRides.path,
                      extra: {
                        'destinationAddress':
                            event.venueName ?? event.location.address,
                        'destinationLat': event.location.latitude,
                        'destinationLng': event.location.longitude,
                      },
                    ),
                  ).animate().fadeIn(delay: 470.ms, duration: 350.ms),
                  SizedBox(height: 8.h),
                  // #21: Offer a ride to this event (Event-Linked Carpool)
                  PremiumButton(
                    text: AppLocalizations.of(context).eventOfferRide,
                    icon: Icons.add_road_rounded,
                    style: PremiumButtonStyle.ghost,
                    fullWidth: true,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      context.push(
                        AppRoutes.driverOfferRide.path,
                        extra: {
                          'eventId': event.id,
                          'eventName': event.title,
                          'destinationAddress':
                              event.venueName ?? event.location.address,
                          'destinationLat': event.location.latitude,
                          'destinationLng': event.location.longitude,
                        },
                      );
                    },
                  ).animate().fadeIn(delay: 480.ms, duration: 350.ms),
                ],

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
        IconButton(
          icon: Icon(
            Icons.calendar_month_rounded,
            color: Colors.white,
            size: 22.sp,
          ),
          onPressed: () => _addToCalendar(event),
        ),
        IconButton(
          icon: Icon(Icons.share_rounded, color: Colors.white, size: 22.sp),
          onPressed: () {
            final dateStr = DateFormat(
              'EEE, MMM d · h:mm a',
            ).format(event.startsAt);
            SharePlus.instance.share(
              ShareParams(
                text:
                    '${event.title} — ${event.type.label}\n'
                    '$dateStr\n'
                    '${event.location.address}\n\n'
                    'Join me on SportConnect!\n'
                    'https://sportconnect.app/events/${event.id}',
              ),
            );
          },
        ),
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
        text: AppLocalizations.of(context).eventLeave,
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
      text: isFull
          ? AppLocalizations.of(context).eventFull
          : AppLocalizations.of(context).eventJoin,
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
          text: AppLocalizations.of(context).eventEdit,
          icon: Icons.edit_rounded,
          style: PremiumButtonStyle.secondary,
          fullWidth: true,
          onPressed: () =>
              context.push('/events/${event.id}/edit', extra: event),
        ),
        SizedBox(height: 12.h),
        PremiumButton(
          text: AppLocalizations.of(context).eventDelete,
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
    final l10n = AppLocalizations.of(context);
    return await showDialog<bool>(
          context: context,
          barrierLabel: 'Delete event dialog',
          builder: (ctx) => AlertDialog(
            title: Text(l10n.eventDeleteConfirmTitle),
            content: Text(l10n.eventDeleteWarning),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(l10n.actionCancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: Text(l10n.actionDelete),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Opens map to set post-event meetup pin (#30).
  Future<void> _setMeetupPin(EventModel event) async {
    final result = await MapLocationPicker.show(
      context,
      title: AppLocalizations.of(context).eventSetMeetupPoint,
      initialLocation: event.location.toLatLng(),
    );
    if (result != null && mounted) {
      final pin = LocationPoint(
        latitude: result.location.latitude,
        longitude: result.location.longitude,
        address: result.address,
      );
      await ref
          .read(eventDetailViewModelProvider(widget.eventId).notifier)
          .setMeetupPin(pin);
    }
  }

  void _addToCalendar(EventModel event) {
    final start = event.startsAt.toUtc().toIso8601String().replaceAll(
      RegExp(r'[-:]'),
      '',
    );
    final end = (event.endsAt ?? event.startsAt.add(const Duration(hours: 2)))
        .toUtc()
        .toIso8601String()
        .replaceAll(RegExp(r'[-:]'), '');
    final title = Uri.encodeComponent(event.title);
    final location = Uri.encodeComponent(
      event.venueName ?? event.location.address,
    );
    final details = Uri.encodeComponent(
      event.description ?? '${event.type.label} on SportConnect',
    );
    final url = Uri.parse(
      'https://calendar.google.com/calendar/render'
      '?action=TEMPLATE'
      '&text=$title'
      '&dates=$start/$end'
      '&location=$location'
      '&details=$details',
    );
    launchUrl(url, mode: LaunchMode.externalApplication);
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

class _OrganizerRow extends ConsumerWidget {
  const _OrganizerRow({required this.creatorId});
  final String creatorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final organizerAsync = ref.watch(userProfileProvider(creatorId));
    final organizer = organizerAsync.value;
    final name = organizer?.displayName ?? 'Organizer';

    return PremiumCard(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18.r,
            backgroundColor: AppColors.primarySurface,
            backgroundImage: organizer?.photoUrl != null
                ? NetworkImage(organizer!.photoUrl!)
                : null,
            child: organizer?.photoUrl == null
                ? Icon(
                    Icons.person_rounded,
                    size: 18.sp,
                    color: AppColors.primary,
                  )
                : null,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  AppLocalizations.of(context).eventOrganizer,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textTertiary,
                  ),
                ),
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
              '· ${AppLocalizations.of(context).eventSeatsLeftCount(event.seatsLeft)}',
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

class _ParticipantAvatars extends ConsumerWidget {
  const _ParticipantAvatars({required this.participantIds});
  final List<String> participantIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayCount = participantIds.length.clamp(0, 8);
    final overflow = participantIds.length - displayCount;

    return Row(
      children: [
        ...List.generate(displayCount, (i) {
          final userAsync = ref.watch(userProfileProvider(participantIds[i]));
          final photoUrl = userAsync.value?.photoUrl;
          return Padding(
            padding: EdgeInsets.only(right: 4.w),
            child: CircleAvatar(
              radius: 18.r,
              backgroundColor: AppColors.primarySurface,
              backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
              child: photoUrl == null
                  ? Icon(
                      Icons.person_rounded,
                      size: 18.sp,
                      color: AppColors.primary,
                    )
                  : null,
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
              text: AppLocalizations.of(context).goBack,
              style: PremiumButtonStyle.ghost,
              onPressed: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Status badge — shows the user's relationship to the event ──
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.isOwner,
    required this.isJoined,
    required this.event,
  });

  final bool isOwner;
  final bool isJoined;
  final EventModel event;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (IconData icon, String label, Color color) = switch ((
      isOwner,
      isJoined,
      event.isUpcoming,
    )) {
      (true, _, true) => (
        Icons.stars_rounded,
        l10n.eventYouAreOrganizer,
        AppColors.primary,
      ),
      (true, _, false) => (
        Icons.stars_rounded,
        l10n.eventOrganizedThis,
        AppColors.textTertiary,
      ),
      (false, true, true) => (
        Icons.check_circle_rounded,
        l10n.eventYoureGoing,
        AppColors.success,
      ),
      (false, true, false) => (
        Icons.check_circle_rounded,
        l10n.eventYouAttended,
        AppColors.textTertiary,
      ),
      (false, false, true) => (
        Icons.info_outline_rounded,
        l10n.eventNotJoinedYet,
        AppColors.warning,
      ),
      _ => (
        Icons.event_busy_rounded,
        l10n.eventHasEnded,
        AppColors.textTertiary,
      ),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: color),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          if (event.isUpcoming) ...[
            _CountdownText(startsAt: event.startsAt, color: color),
          ],
        ],
      ),
    );
  }
}

// ── Relative countdown text (e.g. "In 2h 15m") ──
class _CountdownText extends StatelessWidget {
  const _CountdownText({required this.startsAt, required this.color});

  final DateTime startsAt;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final diff = startsAt.difference(DateTime.now());
    if (diff.isNegative) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final String text;
    if (diff.inDays > 0) {
      text = l10n.eventCountdownDaysHours(
        diff.inDays,
        diff.inHours.remainder(24),
      );
    } else if (diff.inHours > 0) {
      text = l10n.eventCountdownHoursMinutes(
        diff.inHours,
        diff.inMinutes.remainder(60),
      );
    } else {
      text = l10n.eventCountdownMinutes(diff.inMinutes);
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: color.withValues(alpha: 0.7),
      ),
    );
  }
}

// ── #27: Ride Status Counter ──
class _RideStatusCounter extends StatelessWidget {
  const _RideStatusCounter({required this.event});

  final EventModel event;

  @override
  Widget build(BuildContext context) {
    final driving = event.driversCount;
    final needRide = event.needRideCount;
    final selfArranged = event.selfArrangedCount;

    if (driving == 0 && needRide == 0 && selfArranged == 0) {
      return const SizedBox.shrink();
    }

    return PremiumCard(
      child: Row(
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 18.sp,
            color: AppColors.primary,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              event.rideStatusSummary,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── #24: Ride Status Selector (I'm driving / Need ride / Self-arranged) ──
class _RideStatusSelector extends StatelessWidget {
  const _RideStatusSelector({
    required this.event,
    required this.userId,
    required this.onStatusSelected,
  });

  final EventModel event;
  final String userId;
  final ValueChanged<String> onStatusSelected;

  static List<(String, IconData, String)> _options(AppLocalizations l10n) => [
    ('driving', Icons.directions_car_rounded, l10n.eventImDriving),
    ('need_ride', Icons.hail_rounded, l10n.eventNeedRide),
    (
      'self_arranged',
      Icons.check_circle_outline_rounded,
      l10n.eventSelfArranged,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final current = event.rideStatusFor(userId);
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.eventHowGettingThere,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: _options(l10n).map((opt) {
            final (value, icon, label) = opt;
            final selected = current == value;
            return ChoiceChip(
              avatar: Icon(
                icon,
                size: 18.sp,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
              label: Text(label),
              selected: selected,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : AppColors.textPrimary,
              ),
              onSelected: (_) => onStatusSelected(value),
              side: BorderSide(
                color: selected
                    ? AppColors.primary
                    : AppColors.textTertiary.withValues(alpha: 0.3),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── #22: Event Rides Section (rides linked to this event) ──
class _EventRidesSection extends ConsumerWidget {
  const _EventRidesSection({required this.eventId, required this.event});

  final String eventId;
  final EventModel event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ridesAsync = ref.watch(eventLinkedRidesProvider(eventId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.directions_car_rounded,
              size: 20.sp,
              color: AppColors.primary,
            ),
            SizedBox(width: 8.w),
            Text(
              AppLocalizations.of(context).eventRidesToEvent,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        ridesAsync.when(
          data: (rides) {
            if (rides.isEmpty) {
              return PremiumCard(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Column(
                      children: [
                        Icon(
                          Icons.no_transfer_rounded,
                          size: 32.sp,
                          color: AppColors.textTertiary,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          AppLocalizations.of(context).eventNoRidesOffered,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return Column(
              children: rides.take(5).map((ride) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: _EventRideTile(ride: ride),
                );
              }).toList(),
            );
          },
          loading: () => Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: SizedBox(
                width: 24.w,
                height: 24.w,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          error: (_, __) => PremiumCard(
            child: Center(
              child: Text(
                AppLocalizations.of(context).eventCouldNotLoadRides,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Single ride tile for event rides list ──
class _EventRideTile extends StatelessWidget {
  const _EventRideTile({required this.ride});

  final RideModel ride;

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('h:mm a');
    return PremiumCard(
      onTap: () =>
          context.push(AppRoutes.rideDetail.path.replaceFirst(':id', ride.id)),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.directions_car_rounded,
              size: 20.sp,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${ride.origin.address} → ${ride.destination.address}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  '${timeFormat.format(ride.departureTime)} · ${AppLocalizations.of(context).valueSeatsLeft(ride.remainingSeats)}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            size: 20.sp,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }
}

// ── #31: Parking Info Card ──
class _ParkingInfoCard extends StatelessWidget {
  const _ParkingInfoCard({required this.info});

  final String info;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.local_parking_rounded,
            size: 20.sp,
            color: AppColors.primary,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).eventParkingInfo,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  info,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── #28: Recurring Event Badge ──
class _RecurringEventBadge extends StatelessWidget {
  const _RecurringEventBadge({required this.event});

  final EventModel event;

  static const _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final days = event.recurringDays
        .where((d) => d >= 1 && d <= 7)
        .map((d) => _dayNames[d - 1])
        .join(', ');

    final endStr = event.recurringEndDate != null
        ? ' ${l10n.eventUntilDate(DateFormat('MMM d').format(event.recurringEndDate!))}'
        : '';

    return PremiumCard(
      child: Row(
        children: [
          Icon(Icons.repeat_rounded, size: 20.sp, color: AppColors.primary),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.eventRecurringTitle,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (days.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    '${l10n.eventEvery} $days$endStr',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
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

// ── #32: Cost Split Badge ──
class _CostSplitBadge extends StatelessWidget {
  const _CostSplitBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.payments_outlined, size: 16.sp, color: AppColors.primary),
          SizedBox(width: 6.w),
          Text(
            AppLocalizations.of(context).eventCostSplitEnabled,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── #30: Meetup Pin Section ──
class _MeetupPinSection extends StatelessWidget {
  const _MeetupPinSection({
    required this.event,
    required this.isOwner,
    required this.onSetPin,
  });

  final EventModel event;
  final bool isOwner;
  final VoidCallback onSetPin;

  @override
  Widget build(BuildContext context) {
    final pin = event.meetupPinLocation;

    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.pin_drop_rounded,
                size: 20.sp,
                color: AppColors.primary,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  AppLocalizations.of(context).eventMeetupPoint,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          if (pin != null)
            Text(
              pin.address,
              style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
            )
          else if (isOwner)
            PremiumButton(
              text: AppLocalizations.of(context).eventSetMeetupPoint,
              icon: Icons.add_location_alt_rounded,
              style: PremiumButtonStyle.ghost,
              size: PremiumButtonSize.small,
              onPressed: onSetPin,
            )
          else
            Text(
              AppLocalizations.of(context).eventNoMeetupPoint,
              style: TextStyle(fontSize: 13.sp, color: AppColors.textTertiary),
            ),
        ],
      ),
    );
  }
}

// ── #29: Event Chat Button ──
class _EventChatButton extends StatelessWidget {
  const _EventChatButton({required this.event});

  final EventModel event;

  @override
  Widget build(BuildContext context) {
    return PremiumButton(
      text: AppLocalizations.of(context).eventGroupChat,
      icon: Icons.chat_bubble_outline_rounded,
      style: PremiumButtonStyle.secondary,
      fullWidth: true,
      onPressed: () {
        HapticFeedback.lightImpact();
        final chatId = event.chatGroupId ?? event.id;
        context.push(AppRoutes.chatGroup.path.replaceFirst(':id', chatId));
      },
    );
  }
}
