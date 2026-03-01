import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/models/location/location_point.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/app_spacing.dart';
import 'package:sport_connect/core/widgets/driver_info_widget.dart';
import 'package:sport_connect/core/widgets/map_location_picker.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/features/events/models/event_model.dart';
import 'package:sport_connect/features/events/views/widgets/inline_event_selector.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/models/ride_search_filters.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Two-phase screen:
///   Phase 1 → compact search form (no scroll needed)
///   Phase 2 → results list slides up, form collapses to a sticky summary bar
class RiderRequestRideScreen extends ConsumerStatefulWidget {
  const RiderRequestRideScreen({super.key});

  @override
  ConsumerState<RiderRequestRideScreen> createState() =>
      _RiderRequestRideScreenState();
}

class _RiderRequestRideScreenState extends ConsumerState<RiderRequestRideScreen>
    with SingleTickerProviderStateMixin {
  // ── Location ────────────────────────────────────────────────
  LatLng? _fromLocation;
  LatLng? _toLocation;
  String _fromAddress = '';
  String _toAddress = '';

  // ── Params ──────────────────────────────────────────────────
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  int _passengers = 1;
  EventModel? _event;

  // ── UI state ────────────────────────────────────────────────
  bool _isSearching = false;
  bool _showResults = false;
  String _sort = 'recommended';

  late final AnimationController _resultsAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _resultsAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _resultsAnim, curve: Curves.easeOutCubic),
        );
  }

  @override
  void dispose() {
    _resultsAnim.dispose();
    super.dispose();
  }

  bool get _canSearch => _fromLocation != null && _toLocation != null;

  // ════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // ── Thin top app bar ────────────────────────────────────
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20.sp,
            color: AppColors.textPrimary,
          ),
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(AppRoutes.home.path),
        ),
        title: Text(
          'Find a Ride',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_showResults)
            TextButton(
              onPressed: _resetSearch,
              child: Text(
                'Edit',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),

      body: Stack(
        children: [
          // ── Phase 1: Search form ─────────────────────────────
          AnimatedOpacity(
            opacity: _showResults ? 0 : 1,
            duration: 200.ms,
            child: _showResults
                ? const SizedBox.shrink()
                : _buildSearchFormBuilder(),
          ),

          // ── Phase 2: Results panel slides up ────────────────
          if (_showResults)
            Positioned.fill(
              child: SlideTransition(
                position: _slideAnim,
                child: _buildResultsPanel(),
              ),
            ),
          // ── Sticky bottom CTA (only in search phase) ────────
          if (!_showResults)
            Positioned(left: 0, right: 0, bottom: 0, child: _buildSearchCta()),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // PHASE 1 — SEARCH FORM
  // All fits on one screen without scrolling on any normal phone
  // ════════════════════════════════════════════════════════════
  Widget _buildSearchFormBuilder() {
    return SingleChildScrollView(
      // 👈 Replaced Padding with SingleChildScrollView
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 100.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRouteCard(),
          SizedBox(height: 12.h),
          _buildParamsRow(),
          SizedBox(height: 12.h),
          InlineEventSelector(
            selected: _event,
            onChanged: (e) => setState(() => _event = e),
          ),
        ],
      ),
    );
  }

  // ── Route Card ──────────────────────────────────────────────
  Widget _buildRouteCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: AppSpacing.shadowMd,
      ),
      child: Column(
        children: [
          _locationTile(
            icon: Icons.radio_button_checked_rounded,
            iconColor: AppColors.primary,
            label: _fromAddress.isEmpty ? 'From where?' : _fromAddress,
            isEmpty: _fromAddress.isEmpty,
            onTap: () => _pickLocation(isFrom: true),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                // Dotted line
                SizedBox(
                  width: 20.w,
                  child: Column(
                    children: List.generate(
                      3,
                      (_) => Container(
                        margin: EdgeInsets.symmetric(vertical: 2.h),
                        width: 3.w,
                        height: 3.h,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(child: Divider(color: AppColors.border)),
                // Swap button
                GestureDetector(
                  onTap: _swapLocations,
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.swap_vert_rounded,
                      size: 18.sp,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _locationTile(
            icon: Icons.location_on_rounded,
            iconColor: AppColors.error,
            label: _toAddress.isEmpty ? 'To where?' : _toAddress,
            isEmpty: _toAddress.isEmpty,
            onTap: () => _pickLocation(isFrom: false),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.06, end: 0);
  }

  Widget _locationTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required bool isEmpty,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20.sp),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: isEmpty ? FontWeight.w400 : FontWeight.w600,
                  color: isEmpty
                      ? AppColors.textTertiary
                      : AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18.sp,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  // ── Date · Time · Passengers ────────────────────────────────
  Widget _buildParamsRow() {
    final l10n = AppLocalizations.of(context);
    final dateLabel = _isToday(_date)
        ? l10n.today
        : _isTomorrow(_date)
        ? l10n.tomorrow
        : DateFormat('d MMM').format(_date);
    final timeLabel = _time.format(context);

    return Row(
          children: [
            // Date
            Expanded(
              child: _paramTile(
                icon: Icons.calendar_today_rounded,
                label: dateLabel,
                onTap: _pickDate,
              ),
            ),
            SizedBox(width: 8.w),
            // Time
            Expanded(
              child: _paramTile(
                icon: Icons.access_time_rounded,
                label: timeLabel,
                onTap: _pickTime,
              ),
            ),
            SizedBox(width: 8.w),
            // Passengers
            _passengerCounter(),
          ],
        )
        .animate()
        .fadeIn(duration: 300.ms, delay: 80.ms)
        .slideY(begin: 0.06, end: 0);
  }

  Widget _paramTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: AppSpacing.shadowSm,
        ),
        child: Row(
          children: [
            Icon(icon, size: 16.sp, color: AppColors.primary),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _passengerCounter() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: AppSpacing.shadowSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _passengers > 1
                ? () {
                    HapticFeedback.lightImpact();
                    setState(() => _passengers--);
                  }
                : null,
            child: Icon(
              Icons.remove_circle_outline_rounded,
              size: 22.sp,
              color: _passengers > 1 ? AppColors.primary : AppColors.border,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Column(
              children: [
                Text(
                  '$_passengers',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'seat${_passengers > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _passengers < 6
                ? () {
                    HapticFeedback.lightImpact();
                    setState(() => _passengers++);
                  }
                : null,
            child: Icon(
              Icons.add_circle_outline_rounded,
              size: 22.sp,
              color: _passengers < 6 ? AppColors.primary : AppColors.border,
            ),
          ),
        ],
      ),
    );
  }

  // ── Search CTA ───────────────────────────────────────────────
  Widget _buildSearchCta() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.border.withValues(alpha: 0.4)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: PremiumButton(
          text: _isSearching ? 'Searching…' : 'Search Rides',
          onPressed: _canSearch ? _performSearch : null,
          isLoading: _isSearching,
          icon: Icons.search_rounded,
          style: PremiumButtonStyle.primary,
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // PHASE 2 — RESULTS PANEL
  // ════════════════════════════════════════════════════════════
  Widget _buildResultsPanel() {
    return Column(
      children: [
        // Compact summary bar
        _buildSummaryBar(),
        // Results list
        Expanded(child: _buildResultsList()),
      ],
    );
  }

  Widget _buildSummaryBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppSpacing.shadowSm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.radio_button_checked_rounded,
                      size: 12.sp,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 4.w),
                    Flexible(
                      child: Text(
                        _fromAddress,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 12.sp,
                      color: AppColors.error,
                    ),
                    SizedBox(width: 4.w),
                    Flexible(
                      child: Text(
                        _toAddress,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          // Param pills
          _pill(
            Icons.calendar_today_rounded,
            _isToday(_date)
                ? AppLocalizations.of(context).today
                : DateFormat('d MMM').format(_date),
          ),
          SizedBox(width: 6.w),
          _pill(Icons.people_rounded, '$_passengers'),
        ],
      ),
    );
  }

  Widget _pill(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: AppColors.primary),
          SizedBox(width: 4.w),
          Text(
            label,
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

  Widget _buildResultsList() {
    final searchState = ref.watch(rideSearchViewModelProvider);

    if (searchState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (searchState.error != null) {
      return _buildErrorState(searchState.error!);
    }
    if (searchState.rides.isEmpty) {
      return _buildEmptyState();
    }

    final sorted = _sortRides(List.of(searchState.rides));
    return Column(
      children: [
        _buildResultsHeader(sorted.length),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 32.h),
            itemCount: sorted.length,
            itemBuilder: (_, i) => _buildRideCard(sorted[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsHeader(int count) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 8.w, 4.h),
      child: Row(
        children: [
          Text(
            '$count ride${count != 1 ? 's' : ''} found',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () => context.push(AppRoutes.searchRides.path),
            icon: Icon(Icons.filter_list_rounded, size: 16.sp),
            label: Text('Filters', style: TextStyle(fontSize: 13.sp)),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(horizontal: 8.w),
            ),
          ),
          TextButton.icon(
            onPressed: _showSortSheet,
            icon: Icon(Icons.tune_rounded, size: 16.sp),
            label: Text('Sort', style: TextStyle(fontSize: 13.sp)),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              padding: EdgeInsets.symmetric(horizontal: 8.w),
            ),
          ),
        ],
      ),
    );
  }

  // ── Ride Card ────────────────────────────────────────────────
  Widget _buildRideCard(RideModel ride) {
    return GestureDetector(
      onTap: () => context.pushNamed(
        AppRoutes.rideDetail.name,
        pathParameters: {'id': ride.id},
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: AppSpacing.shadowSm,
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar
                DriverAvatarWidget(driverId: ride.driverId, radius: 22.r),
                SizedBox(width: 10.w),
                // Name + rating
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DriverNameWidget(
                        driverId: ride.driverId,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      DriverRatingWidget(
                        driverId: ride.driverId,
                        showIcon: true,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Price — prominent
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${ride.pricePerSeat.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'per seat',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Divider(height: 1, color: AppColors.divider),
            SizedBox(height: 10.h),
            // Meta row
            Wrap(
              spacing: 8.w, // Horizontal space between items
              runSpacing: 8.h, // Vertical space if it wraps to a new line
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _metaChip(
                  Icons.access_time_rounded,
                  DateFormat('HH:mm').format(ride.departureTime),
                ),
                SizedBox(width: 8.w),
                _metaChip(
                  Icons.airline_seat_recline_normal_rounded,
                  '${ride.remainingSeats} left',
                ),
                const Spacer(),
                // Feature icons
                if (ride.allowPets) _featureIcon(Icons.pets_rounded),
                if (ride.isPriceNegotiable)
                  _featureIcon(Icons.handshake_rounded),
                if (ride.allowLuggage) _featureIcon(Icons.luggage_rounded),
                // Event badge
                if (ride.eventName?.isNotEmpty == true)
                  _eventBadge(ride.eventName!),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(duration: 220.ms).slideY(begin: 0.05, end: 0),
    );
  }

  Widget _metaChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.sp, color: AppColors.textTertiary),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _featureIcon(IconData icon) {
    return Padding(
      padding: EdgeInsets.only(left: 6.w),
      child: Icon(icon, size: 16.sp, color: AppColors.textTertiary),
    );
  }

  Widget _eventBadge(String name) {
    return Container(
      margin: EdgeInsets.only(left: 6.w),
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_rounded, size: 11.sp, color: AppColors.primary),
          SizedBox(width: 3.w),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 60.w),
            child: Text(
              name,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty / Error ────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 56.sp,
            color: AppColors.textTertiary,
          ),
          SizedBox(height: 12.h),
          Text(
            'No rides found',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Try adjusting your search',
            style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
          ),
          SizedBox(height: 20.h),
          OutlinedButton(
            onPressed: _resetSearch,
            child: const Text('Edit Search'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String err) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48.sp,
              color: AppColors.error,
            ),
            SizedBox(height: 12.h),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              err,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // SORT SHEET
  // ════════════════════════════════════════════════════════════
  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
              child: Text(
                'Sort by',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            ...[
              ('recommended', Icons.auto_awesome_rounded, 'Recommended'),
              ('earliest', Icons.schedule_rounded, 'Earliest departure'),
              ('price', Icons.attach_money_rounded, 'Lowest price'),
              ('rating', Icons.star_rounded, 'Highest rated'),
            ].map((e) {
              final isActive = _sort == e.$1;
              return ListTile(
                leading: Icon(
                  e.$2,
                  color: isActive ? AppColors.primary : AppColors.textSecondary,
                ),
                title: Text(
                  e.$3,
                  style: TextStyle(
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    color: isActive ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                trailing: isActive
                    ? Icon(
                        Icons.check_rounded,
                        color: AppColors.primary,
                        size: 20.sp,
                      )
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _sort = e.$1);
                },
              );
            }),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // ACTIONS
  // ════════════════════════════════════════════════════════════
  Future<void> _pickLocation({required bool isFrom}) async {
    final result = await MapLocationPicker.show(
      context,
      title: isFrom ? 'Pickup Location' : 'Drop-off Location',
      initialLocation: isFrom ? _fromLocation : _toLocation,
      showQuickPicks: true,
    );
    if (result != null && mounted) {
      setState(() {
        if (isFrom) {
          _fromLocation = result.location;
          _fromAddress = result.address;
        } else {
          _toLocation = result.location;
          _toAddress = result.address;
        }
      });
    }
  }

  void _swapLocations() {
    HapticFeedback.lightImpact();
    setState(() {
      final tmpL = _fromLocation;
      final tmpA = _fromAddress;
      _fromLocation = _toLocation;
      _fromAddress = _toAddress;
      _toLocation = tmpL;
      _toAddress = tmpA;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null && mounted) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null && mounted) setState(() => _time = picked);
  }

  Future<void> _performSearch() async {
    HapticFeedback.mediumImpact();
    setState(() => _isSearching = true);

    final dt = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );

    final filters = RideSearchFilters(
      origin: LocationPoint(
        address: _fromAddress,
        latitude: _fromLocation!.latitude,
        longitude: _fromLocation!.longitude,
      ),
      destination: LocationPoint(
        address: _toAddress,
        latitude: _toLocation!.latitude,
        longitude: _toLocation!.longitude,
      ),
      departureDate: dt,
      minSeats: _passengers,
    );

    ref.read(rideSearchViewModelProvider.notifier).updateFilters(filters);

    try {
      await ref.read(rideSearchViewModelProvider.notifier).searchRides();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Search failed. Please try again.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _showResults = true;
        });
        _resultsAnim.forward();
      }
    }
  }

  void _resetSearch() {
    _resultsAnim.reverse().then((_) {
      if (mounted) setState(() => _showResults = false);
    });
  }

  List<RideModel> _sortRides(List<RideModel> list) {
    switch (_sort) {
      case 'earliest':
        list.sort((a, b) => a.departureTime.compareTo(b.departureTime));
      case 'price':
        list.sort((a, b) => a.pricePerSeat.compareTo(b.pricePerSeat));
      case 'rating':
        list.sort((a, b) => b.averageRating.compareTo(a.averageRating));
      default:
        break;
    }
    return list;
  }

  // ── Date helpers ─────────────────────────────────────────────
  bool _isToday(DateTime d) {
    final n = DateTime.now();
    return d.year == n.year && d.month == n.month && d.day == n.day;
  }

  bool _isTomorrow(DateTime d) {
    final t = DateTime.now().add(const Duration(days: 1));
    return d.year == t.year && d.month == t.month && d.day == t.day;
  }
}
