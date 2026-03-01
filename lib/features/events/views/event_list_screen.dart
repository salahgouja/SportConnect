import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/app_spacing.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/core/widgets/premium_card.dart';
import 'package:sport_connect/features/events/models/event_model.dart';
import 'package:sport_connect/features/events/view_models/event_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Browse / discover upcoming events, filter by sport type.
class EventListScreen extends ConsumerStatefulWidget {
  const EventListScreen({super.key});

  @override
  ConsumerState<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends ConsumerState<EventListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(eventListViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ──
          _buildAppBar(),

          // ── Search bar ──
          SliverToBoxAdapter(child: _buildSearchBar(vm)),

          // ── Filter chips ──
          SliverToBoxAdapter(child: _buildFilterChips(vm)),

          // ── Event list ──
          if (vm.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (vm.error != null)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 48.sp,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      AppLocalizations.of(context).unableToLoadData,
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    TextButton.icon(
                      onPressed: () =>
                          ref.invalidate(eventListViewModelProvider),
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(AppLocalizations.of(context).retry),
                    ),
                  ],
                ),
              ),
            )
          else if (vm.filteredEvents.isEmpty)
            SliverFillRemaining(child: _buildEmptyState(vm.filterType))
          else
            _buildEventList(vm.filteredEvents),
        ],
      ),
      floatingActionButton:
          FloatingActionButton.extended(
            onPressed: () => context.push(AppRoutes.createEvent.path),
            backgroundColor: AppColors.primary,
            icon: Icon(Icons.add_rounded, size: 22.sp),
            label: Text(
              'Create',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
          ).animate().scale(
            delay: 300.ms,
            duration: 400.ms,
            curve: Curves.easeOutBack,
          ),
    );
  }

  // -------------------------------------------------------------------
  // App bar
  // -------------------------------------------------------------------
  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_rounded,
          color: AppColors.textPrimary,
          size: 22.sp,
        ),
        onPressed: () => context.pop(),
      ),
      title: Text(
        'Discover Events',
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: false,
    );
  }

  // -------------------------------------------------------------------
  // Search bar
  // -------------------------------------------------------------------
  Widget _buildSearchBar(EventListState vm) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        4.h,
        AppSpacing.screenPadding,
        8.h,
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) =>
            ref.read(eventListViewModelProvider.notifier).setSearchQuery(v),
        decoration: InputDecoration(
          hintText: 'Search events…',
          hintStyle: TextStyle(fontSize: 14.sp, color: AppColors.textTertiary),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20.sp,
            color: AppColors.textTertiary,
          ),
          suffixIcon: vm.searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close_rounded, size: 18.sp),
                  onPressed: () {
                    _searchController.clear();
                    ref
                        .read(eventListViewModelProvider.notifier)
                        .setSearchQuery('');
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.surfaceVariant,
          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  // -------------------------------------------------------------------
  // Filter chips
  // -------------------------------------------------------------------
  Widget _buildFilterChips(EventListState vm) {
    return SizedBox(
      height: 44.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
        children: [
          _FilterChip(
            label: 'All',
            isSelected: vm.filterType == null,
            onTap: () => ref
                .read(eventListViewModelProvider.notifier)
                .setFilterType(null),
          ),
          ...EventType.values.map((type) {
            return _FilterChip(
              label: type.label,
              icon: type.icon,
              color: type.color,
              isSelected: vm.filterType == type,
              onTap: () => ref
                  .read(eventListViewModelProvider.notifier)
                  .setFilterType(vm.filterType == type ? null : type),
            );
          }),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 300.ms);
  }

  // -------------------------------------------------------------------
  // Event list
  // -------------------------------------------------------------------
  SliverPadding _buildEventList(List<EventModel> events) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        16.h,
        AppSpacing.screenPadding,
        100.h,
      ),
      sliver: SliverList.separated(
        itemCount: events.length,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final event = events[index];
          return _EventCard(event: event)
              .animate()
              .fadeIn(
                delay: Duration(milliseconds: 50 * index.clamp(0, 10)),
                duration: 350.ms,
              )
              .slideY(begin: 0.04, end: 0);
        },
      ),
    );
  }

  // -------------------------------------------------------------------
  // Empty state
  // -------------------------------------------------------------------
  Widget _buildEmptyState(EventType? filterType) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_busy_rounded,
              size: 56.sp,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: 16.h),
            Text(
              'No events found',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              filterType != null
                  ? 'No upcoming ${filterType.label.toLowerCase()} events.'
                  : 'Be the first to create one!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: 24.h),
            PremiumButton(
              text: 'Create Event',
              icon: Icons.add_rounded,
              size: PremiumButtonSize.small,
              onPressed: () => context.push(AppRoutes.createEvent.path),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// PRIVATE WIDGETS
// =============================================================================

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.color,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final chipColor = isSelected
        ? (color ?? AppColors.primary)
        : AppColors.textTertiary;
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: 200.ms,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected
                ? chipColor.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isSelected ? chipColor : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16.sp, color: chipColor),
                SizedBox(width: 4.w),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? chipColor : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventCard extends ConsumerWidget {
  const _EventCard({required this.event});
  final EventModel event;

  static final _fmt = DateFormat('EEE, MMM d · h:mm a');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PremiumCard(
      onTap: () => context.push('/events/${event.id}'),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image banner or colour fallback ──
          Container(
            height: 90.h,
            decoration: BoxDecoration(
              gradient: event.imageUrl == null || event.imageUrl!.isEmpty
                  ? LinearGradient(
                      colors: [
                        event.type.color,
                        event.type.color.withValues(alpha: 0.7),
                      ],
                    )
                  : null,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              image: event.imageUrl != null && event.imageUrl!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(event.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    event.type.icon,
                    size: 40.sp,
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                Positioned(
                  top: 10.h,
                  right: 12.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      event.type.label,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (!event.isUpcoming)
                  Positioned(
                    top: 10.h,
                    left: 12.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        'Past',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Details ──
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 6.h),
                _iconRow(
                  Icons.calendar_today_rounded,
                  _fmt.format(event.startsAt),
                ),
                if (event.venueName != null) ...[
                  SizedBox(height: 4.h),
                  _iconRow(Icons.location_on_rounded, event.venueName!),
                ],
                if (event.organizerName != null &&
                    event.organizerName!.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  _iconRow(
                    Icons.person_outline_rounded,
                    'by ${event.organizerName}',
                  ),
                ],
                SizedBox(height: 10.h),
                Row(
                  children: [
                    _participantBadge(),
                    const Spacer(),
                    if (event.isUpcoming && !event.isFull)
                      Text(
                        'Join →',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    if (event.isFull)
                      Text(
                        'Full',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.warning,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: AppColors.textTertiary),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _participantBadge() {
    final color = event.isFull ? AppColors.warning : AppColors.primary;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.group_rounded, size: 14.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            event.participantLabel,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
