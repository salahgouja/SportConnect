import 'package:flutter/material.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/features/events/models/event_model.dart';
import 'package:sport_connect/features/events/view_models/event_view_model.dart';

/// Drop-in replacement for EventPickerSheet.
///
/// ```dart
/// InlineEventSelector(
///   selected: _event,
///   onChanged: (e) => setState(() => _event = e),
/// )
/// ```
class InlineEventSelector extends ConsumerStatefulWidget {
  const InlineEventSelector({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final EventModel? selected;
  final ValueChanged<EventModel?> onChanged;

  @override
  ConsumerState<InlineEventSelector> createState() =>
      _InlineEventSelectorState();
}

class _InlineEventSelectorState extends ConsumerState<InlineEventSelector> {
  bool _expanded = false;
  EventType? _filterType;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: 300.ms,
      curve: Curves.easeOutCubic,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildTrigger(), if (_expanded) _buildExpandedContent()],
      ),
    );
  }

  // ── Trigger row ─────────────────────────────────────────────
  Widget _buildTrigger() {
    final hasEvent = widget.selected != null;
    return AnimatedContainer(
      duration: 200.ms,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
      decoration: BoxDecoration(
        color: hasEvent
            ? widget.selected!.type.color.withValues(alpha: 0.07)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: hasEvent
              ? widget.selected!.type.color
              : _expanded
              ? AppColors.primary
              : AppColors.border,
          width: hasEvent || _expanded ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Tappable expand zone ────────────────────────────
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _expanded = !_expanded);
              },
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  AnimatedSwitcher(
                    duration: 200.ms,
                    child: Icon(
                      hasEvent
                          ? widget.selected!.type.icon
                          : _expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.event_rounded,
                      key: ValueKey(hasEvent ? widget.selected!.id : _expanded),
                      size: 20.sp,
                      color: hasEvent
                          ? widget.selected!.type.color
                          : _expanded
                          ? AppColors.primary
                          : AppColors.textTertiary,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: hasEvent
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.selected!.title,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                DateFormat(
                                  'EEE d MMM · HH:mm',
                                ).format(widget.selected!.startsAt),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            _expanded
                                ? 'Pick an event'
                                : 'Link to a sport event (optional)',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: _expanded
                                  ? AppColors.textPrimary
                                  : AppColors.textTertiary,
                            ),
                          ),
                  ),
                  if (!hasEvent)
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 20.sp,
                      color: AppColors.textTertiary,
                    ),
                ],
              ),
            ),
          ),

          // ── Close button — isolated tap zone ────────────────
          if (hasEvent)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                widget.onChanged(null);
                setState(() => _expanded = false);
              },
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.only(left: 12.w),
                child: Icon(
                  Icons.close_rounded,
                  size: 20.sp,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Expanded content ─────────────────────────────────────────
  Widget _buildExpandedContent() {
    return Padding(
          padding: EdgeInsets.only(top: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sport-type filter chips
              _buildTypeFilterRow(),
              SizedBox(height: 10.h),
              // Event cards scroll
              _buildEventList(),
              SizedBox(height: 10.h),
              // Create new event CTA
              _buildCreateEventButton(),
              SizedBox(height: 4.h),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 200.ms)
        .slideY(begin: -0.05, end: 0, curve: Curves.easeOutCubic);
  }

  // ── Type filter chips ────────────────────────────────────────
  Widget _buildTypeFilterRow() {
    return SizedBox(
      height: 34.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _filterChip(
            null,
            'All',
            Icons.auto_awesome_rounded,
            AppColors.primary,
          ),
          ...EventType.values.map(
            (t) => _filterChip(t, t.label, t.icon, t.color),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(
    EventType? type,
    String label,
    IconData icon,
    Color color,
  ) {
    final active = _filterType == type;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _filterType = type);
      },
      child: AnimatedContainer(
        duration: 150.ms,
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.12) : AppColors.background,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: active ? color : AppColors.border,
            width: active ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13.sp,
              color: active ? color : AppColors.textSecondary,
            ),
            SizedBox(width: 5.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? color : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Event card list ──────────────────────────────────────────
  Widget _buildEventList() {
    final eventsAsync = ref.watch(upcomingEventsStreamProvider);

    return eventsAsync.when(
      loading: _shimmerRow,
      error: (_, _) => Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Text(
          'Could not load events',
          style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
        ),
      ),
      data: (events) {
        var filtered = events.where((e) => e.isUpcoming && e.isActive).toList()
          ..sort((a, b) => a.startsAt.compareTo(b.startsAt));

        if (_filterType != null) {
          filtered = filtered.where((e) => e.type == _filterType).toList();
        }

        if (filtered.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Text(
              'No upcoming events${_filterType != null ? ' for ${_filterType!.label}' : ''}',
              style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
            ),
          );
        }

        return SizedBox(
          height: 110.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: filtered.length,
            itemBuilder: (_, i) => _eventCard(filtered[i]),
          ),
        );
      },
    );
  }

  Widget _eventCard(EventModel event) {
    final isSelected = widget.selected?.id == event.id;
    final diff = event.startsAt.difference(DateTime.now());

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        if (isSelected) {
          widget.onChanged(null);
          // keep expanded so user can pick another
        } else {
          widget.onChanged(event);
          setState(() => _expanded = false);
        }
      },
      child: AnimatedContainer(
        duration: 200.ms,
        width: 190.w,
        margin: EdgeInsets.only(right: 10.w),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isSelected
              ? event.type.color.withValues(alpha: 0.09)
              : AppColors.background,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected ? event.type.color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type + check
            Row(
              children: [
                Icon(event.type.icon, size: 14.sp, color: event.type.color),
                SizedBox(width: 5.w),
                Expanded(
                  child: Text(
                    event.type.label,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: event.type.color,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.cancel_rounded,
                    size: 16.sp,
                    color: event.type.color,
                  ),
              ],
            ),
            SizedBox(height: 5.h),
            // Title
            Text(
              event.title,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 3.h),
            // Date
            Text(
              DateFormat('EEE d MMM').format(event.startsAt),
              style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
            ),
            const Spacer(),
            // Countdown
            Container(
              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: diff.inHours < 24
                    ? AppColors.warning.withValues(alpha: 0.12)
                    : AppColors.primarySurface,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                _countdown(diff),
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: diff.inHours < 24
                      ? AppColors.warning
                      : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerRow() {
    return SizedBox(
      height: 110.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (_, _) =>
            Container(
                  width: 190.w,
                  margin: EdgeInsets.only(right: 10.w),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                )
                .animate(onPlay: (c) => c.repeat())
                .shimmer(duration: 1200.ms, color: Colors.white38),
      ),
    );
  }

  // ── Create event CTA ─────────────────────────────────────────
  Widget _buildCreateEventButton() {
    return OutlinedButton.icon(
      onPressed: () async {
        // Navigate to dedicated create event screen
        // GoRouter handles this cleanly — no sheets, no navigator bugs
        final created = await context.push<EventModel>(
          AppRoutes.createEvent.path,
        );
        if (created != null && mounted) {
          widget.onChanged(created);
          setState(() => _expanded = false);
        }
      },
      icon: Icon(Icons.add_rounded, size: 18.sp),
      label: Text(
        'Create new event',
        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
        padding: EdgeInsets.symmetric(vertical: 11.h, horizontal: 16.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  String _countdown(Duration d) {
    if (d.inDays > 0) return 'In ${d.inDays}d';
    if (d.inHours > 0) return 'In ${d.inHours}h';
    if (d.inMinutes > 0) return 'In ${d.inMinutes}m';
    return 'Now';
  }
}
