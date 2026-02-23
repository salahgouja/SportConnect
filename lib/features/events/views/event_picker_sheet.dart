import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/app_spacing.dart';
import 'package:sport_connect/features/events/models/event_model.dart';
import 'package:sport_connect/features/events/view_models/event_view_model.dart';
import 'package:sport_connect/features/events/views/create_event_sheet.dart';

/// Rich full-screen event picker for linking a sport event to a ride.
///
/// Features:
///   - Animated gradient header with togglable search
///   - Horizontal category filter row ("All" + every EventType)
///   - Event cards with real swipe gestures:
///       swipe-right → SELECT  (green overlay)
///       swipe-left  → SKIP    (grey overlay)
///   - Countdown chip, capacity chip, sport-type chip on every card
///   - Persistent confirm / create-event bar at the bottom
class EventPickerSheet extends ConsumerStatefulWidget {
  const EventPickerSheet({super.key, this.preselected});

  final EventModel? preselected;

  static Future<EventModel?> show(
    BuildContext context, {
    EventModel? preselected,
  }) {
    return showModalBottomSheet<EventModel>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EventPickerSheet(preselected: preselected),
    );
  }

  @override
  ConsumerState<EventPickerSheet> createState() => _EventPickerSheetState();
}

class _EventPickerSheetState extends ConsumerState<EventPickerSheet>
    with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  EventType? _activeFilter;
  EventModel? _selected;
  bool _showSearch = false;

  // Per-card horizontal drag offset
  final Map<String, double> _swipeDx = {};

  @override
  void initState() {
    super.initState();
    _selected = widget.preselected;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<EventModel> _applyFilters(List<EventModel> events) {
    var filtered = events.where((e) => e.isUpcoming && e.isActive).toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));

    if (_activeFilter != null) {
      filtered = filtered.where((e) => e.type == _activeFilter).toList();
    }

    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((e) {
        final h =
            '${e.title} ${e.venueName ?? ""} ${e.location.address} ${e.type.label}'
                .toLowerCase();
        return h.contains(query);
      }).toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(upcomingEventsStreamProvider);

    return Container(
      constraints: BoxConstraints(maxHeight: 0.92.sh),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(),
          _buildCategoryRow(),
          if (_showSearch) _buildSearchBar(),
          Expanded(
            child: eventsAsync.when(
              data: (events) {
                final filtered = _applyFilters(events);
                if (filtered.isEmpty) return _buildEmptyState();
                return _buildEventList(filtered);
              },
              loading: _buildShimmer,
              error: (_, __) => _buildErrorState(),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  // ── Handle ─────────────────────────────────────────────────────────────────
  Widget _buildHandle() => Padding(
    padding: EdgeInsets.only(top: 12.h, bottom: 4.h),
    child: Container(
      width: 40.w,
      height: 4.h,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(2.r),
      ),
    ),
  );

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 16.w, 0),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.sports_rounded, color: Colors.white, size: 26.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pick a Sport Event',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Swipe \u2190 skip  \u00b7  swipe \u2192 select',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) _searchController.clear();
              });
            },
            icon: AnimatedSwitcher(
              duration: 200.ms,
              child: Icon(
                _showSearch ? Icons.search_off_rounded : Icons.search_rounded,
                key: ValueKey(_showSearch),
                color: _showSearch
                    ? AppColors.primary
                    : AppColors.textSecondary,
                size: 24.sp,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              minimumSize: Size.zero,
            ),
            child: Text(
              'Skip',
              style: TextStyle(fontSize: 13.sp, color: AppColors.textTertiary),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms);
  }

  // ── Category Row ───────────────────────────────────────────────────────────
  Widget _buildCategoryRow() {
    return SizedBox(
      height: 80.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        itemCount: EventType.values.length + 1,
        itemBuilder: (context, i) {
          if (i == 0) {
            return _CategoryChip(
              label: 'All',
              icon: Icons.auto_awesome_rounded,
              color: AppColors.primary,
              isActive: _activeFilter == null,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _activeFilter = null);
              },
            );
          }
          final type = EventType.values[i - 1];
          final isActive = _activeFilter == type;
          return _CategoryChip(
            label: type.label,
            icon: type.icon,
            color: type.color,
            isActive: isActive,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _activeFilter = isActive ? null : type);
            },
          );
        },
      ),
    );
  }

  // ── Search Bar ─────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        autofocus: true,
        style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search by event name or venue...',
          hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 14.sp),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20.sp,
            color: AppColors.primary,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear_rounded, size: 18.sp),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.surfaceVariant,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.2);
  }

  // ── Event List ─────────────────────────────────────────────────────────────
  Widget _buildEventList(List<EventModel> events) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final isSelected = _selected?.id == event.id;
        final dx = _swipeDx[event.id] ?? 0.0;

        return _SwipeableEventCard(
              key: ValueKey(event.id),
              event: event,
              isSelected: isSelected,
              swipeDx: dx,
              onSwipeUpdate: (d) => setState(() => _swipeDx[event.id] = d),
              onSwipeCommit: (direction) {
                setState(() => _swipeDx[event.id] = 0);
                if (direction > 0) {
                  HapticFeedback.mediumImpact();
                  setState(() => _selected = event);
                }
              },
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selected = isSelected ? null : event);
              },
            )
            .animate(delay: Duration(milliseconds: 40 * index))
            .fadeIn(duration: 300.ms)
            .slideY(begin: 0.08, curve: Curves.easeOutCubic);
      },
    );
  }

  // ── Empty State ────────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_busy_rounded,
                size: 40.sp,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              _activeFilter != null
                  ? 'No ${_activeFilter!.label} events'
                  : 'No upcoming events',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Be the first to create one!',
              style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            FilledButton.icon(
              onPressed: _handleCreateEvent,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Event'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildShimmer() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      itemCount: 5,
      itemBuilder: (_, i) => Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child:
            Container(
                  height: 130.h,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                )
                .animate(onPlay: (c) => c.repeat())
                .shimmer(duration: 1200.ms, color: Colors.white54),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded, size: 48.sp, color: AppColors.error),
          SizedBox(height: 12.h),
          Text(
            'Unable to load events',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Bar ─────────────────────────────────────────────────────────────
  Widget _buildBottomBar() {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.border.withValues(alpha: 0.4)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _handleCreateEvent,
                icon: Icon(Icons.add_rounded, size: 18.sp),
                label: Text('New Event', style: TextStyle(fontSize: 14.sp)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.6),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: _selected != null
                    ? () => Navigator.of(context).pop(_selected)
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primary.withValues(
                    alpha: 0.25,
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_selected != null) ...[
                      Icon(
                        _selected!.type.icon,
                        size: 16.sp,
                        color: Colors.white,
                      ),
                      SizedBox(width: 6.w),
                    ],
                    Flexible(
                      child: Text(
                        _selected != null
                            ? _truncate(_selected!.title, 18)
                            : 'Choose an Event',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
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

  String _truncate(String s, int max) =>
      s.length > max ? '${s.substring(0, max)}\u2026' : s;

  Future<void> _handleCreateEvent() async {
    final created = await CreateEventSheet.show(context);
    if (created != null && mounted) setState(() => _selected = created);
  }
}

// =============================================================================
// _CategoryChip
// =============================================================================

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 200.ms,
        margin: EdgeInsets.only(right: 10.w),
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.12) : AppColors.surface,
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(
            color: isActive ? color : AppColors.border,
            width: isActive ? 1.5 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16.sp,
              color: isActive ? color : AppColors.textSecondary,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? color : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// _SwipeableEventCard  —  swipe right to select, swipe left to skip
// =============================================================================

class _SwipeableEventCard extends StatelessWidget {
  const _SwipeableEventCard({
    super.key,
    required this.event,
    required this.isSelected,
    required this.swipeDx,
    required this.onSwipeUpdate,
    required this.onSwipeCommit,
    required this.onTap,
  });

  final EventModel event;
  final bool isSelected;
  final double swipeDx;
  final ValueChanged<double> onSwipeUpdate;

  /// +1 = committed right (select), -1 = committed left (skip), 0 = reset.
  final ValueChanged<int> onSwipeCommit;
  final VoidCallback onTap;

  static const double _threshold = 80.0;

  @override
  Widget build(BuildContext context) {
    final progress = (swipeDx / _threshold).clamp(-1.0, 1.0);
    final showSelect = swipeDx > 20;
    final showSkip = swipeDx < -20;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: GestureDetector(
        onHorizontalDragUpdate: (d) => onSwipeUpdate(swipeDx + d.delta.dx),
        onHorizontalDragEnd: (_) {
          if (swipeDx >= _threshold) {
            onSwipeCommit(1);
          } else if (swipeDx <= -_threshold) {
            onSwipeCommit(-1);
          } else {
            onSwipeCommit(0);
          }
        },
        onTap: onTap,
        child: Transform.translate(
          offset: Offset(swipeDx * 0.35, 0),
          child: Transform.rotate(
            angle: swipeDx * 0.003 * math.pi / 180,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Main card
                AnimatedContainer(
                  duration: 200.ms,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? event.type.color.withValues(alpha: 0.07)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isSelected
                          ? event.type.color
                          : showSelect
                          ? AppColors.success
                          : showSkip
                          ? AppColors.error
                          : AppColors.border,
                      width: isSelected || swipeDx.abs() > 10 ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? AppSpacing.shadowMd
                        : AppSpacing.shadowSm,
                  ),
                  child: Column(
                    children: [
                      _buildColorBar(),
                      Padding(
                        padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
                        child: _buildBody(),
                      ),
                    ],
                  ),
                ),

                // SELECT hint overlay
                if (showSelect)
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Opacity(
                        opacity: progress.clamp(0.0, 1.0),
                        child: Padding(
                          padding: EdgeInsets.only(left: 16.w),
                          child: _HintBadge(
                            label: 'SELECT',
                            icon: Icons.check_circle_rounded,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ),
                  ),

                // SKIP hint overlay
                if (showSkip)
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Opacity(
                        opacity: (-progress).clamp(0.0, 1.0),
                        child: Padding(
                          padding: EdgeInsets.only(right: 16.w),
                          child: _HintBadge(
                            label: 'SKIP',
                            icon: Icons.skip_next_rounded,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorBar() => Container(
    height: 6.h,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [event.type.color, event.type.color.withValues(alpha: 0.4)],
      ),
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
  );

  Widget _buildBody() {
    final now = DateTime.now();
    final diff = event.startsAt.difference(now);
    final dateStr = DateFormat('EEE d MMM \u00b7 HH:mm').format(event.startsAt);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56.w,
          height: 56.w,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                event.type.color.withValues(alpha: 0.2),
                event.type.color.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: event.type.color.withValues(alpha: 0.3)),
          ),
          child: Icon(event.type.icon, color: event.type.color, size: 28.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      event.title,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isSelected) ...[
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 12.sp,
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 5.h),
              _InfoRow(icon: Icons.schedule_rounded, label: dateStr),
              SizedBox(height: 3.h),
              _InfoRow(
                icon: Icons.location_on_outlined,
                label: event.venueName ?? event.location.address,
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 6.w,
                runSpacing: 4.h,
                children: [
                  _Chip(
                    label: event.type.label,
                    color: event.type.color,
                    icon: event.type.icon,
                  ),
                  _Chip(
                    label: _formatCountdown(diff),
                    color: diff.inHours < 24
                        ? AppColors.warning
                        : AppColors.primary,
                    icon: Icons.timer_rounded,
                  ),
                  if (event.maxParticipants > 0)
                    _Chip(
                      label: event.isFull
                          ? 'Full'
                          : '${event.participantLabel} spots',
                      color: event.isFull ? AppColors.error : AppColors.success,
                      icon: Icons.people_rounded,
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatCountdown(Duration d) {
    if (d.inDays > 0) return 'In ${d.inDays}d';
    if (d.inHours > 0) return 'In ${d.inHours}h';
    if (d.inMinutes > 0) return 'In ${d.inMinutes}m';
    return 'Starting now';
  }
}

// =============================================================================
// Small shared helpers
// =============================================================================

class _HintBadge extends StatelessWidget {
  const _HintBadge({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16.sp),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13.sp, color: AppColors.textTertiary),
        SizedBox(width: 5.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color, required this.icon});

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
