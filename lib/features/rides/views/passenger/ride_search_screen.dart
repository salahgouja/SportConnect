import 'dart:async';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/models/location/location_point.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/app_spacing.dart';
import 'package:sport_connect/core/widgets/app_modal_sheet.dart';
import 'package:sport_connect/core/widgets/custom_button.dart';
import 'package:sport_connect/core/widgets/driver_info_widget.dart';
import 'package:sport_connect/core/widgets/map_location_picker.dart';
import 'package:sport_connect/core/widgets/skeleton_loader.dart';
import 'package:sport_connect/core/widgets/utility_widgets.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Ride Search Screen with filters - Enhanced UI
class RideSearchScreen extends ConsumerStatefulWidget {
  const RideSearchScreen({super.key, this.initialDestination});

  /// Optional pre-filled destination, for example from event detail.
  /// Keys: `destinationAddress`, `destinationLat`, `destinationLng`.
  final Map<String, dynamic>? initialDestination;

  @override
  ConsumerState<RideSearchScreen> createState() => _RideSearchScreenState();
}

class _RideSearchScreenState extends ConsumerState<RideSearchScreen> {
  RideSearchState get _searchState => ref.read(rideSearchViewModelProvider);

  RideSearchResultsData get _resultsState =>
      ref.read(rideSearchResultsProvider);

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_handleScroll);

    final dest = widget.initialDestination;

    if (dest != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(rideSearchViewModelProvider.notifier)
            .setInitialDestination(dest);
      });
    }
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;

    if (_scrollController.position.extentAfter < 240) {
      ref.read(rideSearchViewModelProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref
      ..watch(rideSearchViewModelProvider)
      ..watch(rideSearchResultsProvider);

    ref.listen(rideSearchViewModelProvider, (previous, next) {
      if (next.error != null &&
          next.error != previous?.error &&
          context.mounted) {
        AdaptiveSnackBar.show(
          context,
          message: AppLocalizations.of(context).searchFailedPleaseTryAgain,
          type: AdaptiveSnackBarType.error,
        );
      }
    });

    return AdaptiveScaffold(
      body: RefreshIndicator.adaptive(
        onRefresh: _handlePullToRefresh,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            _buildSliverAppBar(),

            MultiSliver(
              children: [
                SliverToBoxAdapter(child: _buildSearchCard()),
                SliverToBoxAdapter(child: _buildQuickDateSelection()),
                if (_hasActiveFilters)
                  SliverToBoxAdapter(child: _buildActiveFilters()),
              ],
            ),

            if (!_resultsState.hasSearched &&
                !_resultsState.isLoading &&
                _resultsState.visibleResults.isEmpty)
              ..._buildDiscoverySection()
            else
              MultiSliver(
                children: [
                  SliverToBoxAdapter(child: _buildResultsHeader()),
                  _buildResultsList(),
                ],
              ),

            SliverToBoxAdapter(child: SizedBox(height: 100.h)),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingFilterButton(),
    );
  }

  Future<void> _handlePullToRefresh() async {
    if (_resultsState.hasSearched) {
      await ref
          .read(rideSearchViewModelProvider.notifier)
          .searchRides(forceRefresh: true);

      return;
    }

    ref.invalidate(activeRidesProvider);
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  bool get _hasActiveFilters => _searchState.hasActiveFilters;

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 56.h,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        tooltip: AppLocalizations.of(context).goBackTooltip,
        onPressed: () =>
            context.canPop() ? context.pop() : context.go(AppRoutes.home.path),
        icon: Icon(
          Icons.adaptive.arrow_back_rounded,
          color: Colors.white,
          size: 20.sp,
        ),
      ),
      title: Text(
        AppLocalizations.of(context).findARide,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          tooltip: AppLocalizations.of(context).filters,
          onPressed: _showAdvancedFilters,
          icon: Badge(
            isLabelVisible: _hasActiveFilters,
            backgroundColor: AppColors.warning,
            smallSize: 8.w,
            child: Icon(Icons.tune_rounded, color: Colors.white, size: 22.sp),
          ),
        ),
        SizedBox(width: 4.w),
      ],
    );
  }

  Widget _buildSearchCard() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: AppSpacing.shadowMd,
      ),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 2.w,
                      height: 28.h,
                      margin: EdgeInsets.symmetric(vertical: 2.h),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [AppColors.primary, AppColors.error],
                        ),
                        borderRadius: BorderRadius.circular(1.r),
                      ),
                    ),
                    Icon(
                      Icons.location_on,
                      color: AppColors.error,
                      size: 16.sp,
                    ),
                  ],
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildCompactInputField(
                        hint: 'Pickup location',
                        icon: Icons.my_location_rounded,
                        isFrom: true,
                      ),
                      Divider(
                        height: 16.h,
                        thickness: 1,
                        color: AppColors.border.withValues(alpha: 0.5),
                      ),
                      _buildCompactInputField(
                        hint: 'Where to?',
                        icon: Icons.search_rounded,
                        isFrom: false,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: _swapLocations,
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: const BoxDecoration(
                      color: AppColors.primarySurface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.swap_vert_rounded,
                      color: AppColors.primary,
                      size: 20.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 12.h),

          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 340.w;

              if (compact) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildCompactDateSelector()),
                        SizedBox(width: 8.w),
                        _buildCompactSeatSelector(),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    SizedBox(
                      width: double.infinity,
                      child: _buildSearchButton(expanded: true),
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: _buildCompactDateSelector()),
                  SizedBox(width: 8.w),
                  _buildCompactSeatSelector(),
                  SizedBox(width: 8.w),
                  _buildSearchButton(),
                ],
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1);
  }

  void _swapLocations() {
    unawaited(HapticFeedback.lightImpact());
    ref.read(rideSearchViewModelProvider.notifier).swapLocations();
  }

  Widget _buildCompactInputField({
    required String hint,
    required IconData icon,
    required bool isFrom,
  }) {
    final location = isFrom
        ? _searchState.draftOrigin
        : _searchState.draftDestination;

    final address = location?.address ?? '';

    return GestureDetector(
      onTap: () => _openLocationPicker(isFrom: isFrom),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Row(
          children: [
            Expanded(
              child: Text(
                address.isEmpty ? hint : address,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: address.isEmpty
                      ? AppColors.textTertiary
                      : AppColors.textPrimary,
                  fontWeight: address.isEmpty
                      ? FontWeight.w400
                      : FontWeight.w500,
                ),
              ),
            ),
            if (address.isNotEmpty) ...[
              SizedBox(width: 6.w),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (isFrom) {
                    ref
                        .read(rideSearchViewModelProvider.notifier)
                        .setDraftOrigin(null);
                  } else {
                    ref
                        .read(rideSearchViewModelProvider.notifier)
                        .setDraftDestination(null);
                  }
                },
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Icon(
                    Icons.close_rounded,
                    size: 16.sp,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompactDateSelector() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _searchState.draftDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 90)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: AppColors.primary,
                  onSurface: AppColors.textPrimary,
                ),
              ),
              child: child!,
            );
          },
        );

        if (!mounted) return;

        if (date != null) {
          ref.read(rideSearchViewModelProvider.notifier).setDraftDate(date);
          ref.read(rideSearchViewModelProvider.notifier).setSelectedDateChip(2);
        }
      },
      child: Container(
        constraints: BoxConstraints(minHeight: 42.h),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              color: AppColors.primary,
              size: 16.sp,
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                _formatDate(_searchState.draftDate),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactSeatSelector() {
    return Container(
      constraints: BoxConstraints(minHeight: 42.h),
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _searchState.draftSeats > 1
                ? () {
                    unawaited(HapticFeedback.selectionClick());
                    ref
                        .read(rideSearchViewModelProvider.notifier)
                        .setDraftSeats(_searchState.draftSeats - 1);
                  }
                : null,
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Icon(
                Icons.remove_rounded,
                color: _searchState.draftSeats > 1
                    ? AppColors.primary
                    : AppColors.textTertiary,
                size: 18.sp,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person_rounded,
                  size: 14.sp,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 2.w),
                Text(
                  AppLocalizations.of(context).value2(_searchState.draftSeats),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _searchState.draftSeats < 4
                ? () {
                    unawaited(HapticFeedback.selectionClick());
                    ref
                        .read(rideSearchViewModelProvider.notifier)
                        .setDraftSeats(_searchState.draftSeats + 1);
                  }
                : null,
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Icon(
                Icons.add_rounded,
                color: _searchState.draftSeats < 4
                    ? AppColors.primary
                    : AppColors.textTertiary,
                size: 18.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchButton({bool expanded = false}) {
    return GestureDetector(
      onTap: _performSearch,
      child: Container(
        width: expanded ? double.infinity : null,
        padding: EdgeInsets.symmetric(
          horizontal: expanded ? 16.w : 12.w,
          vertical: 12.h,
        ),
        decoration: BoxDecoration(
          gradient: AppColors.heroGradient,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: _searchState.isLoading
              ? SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: const CircularProgressIndicator.adaptive(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search_rounded,
                      color: Colors.white,
                      size: 22.sp,
                    ),
                    if (expanded) ...[
                      SizedBox(width: 8.w),
                      Flexible(
                        child: Text(
                          AppLocalizations.of(context).findARide,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _performSearch() async {
    if (_searchState.isLoading) return;

    unawaited(HapticFeedback.mediumImpact());

    final error = await ref
        .read(rideSearchViewModelProvider.notifier)
        .searchRides();

    if (error != null && mounted) {
      AdaptiveSnackBar.show(
        context,
        message: error,
        type: AdaptiveSnackBarType.error,
      );
    }
  }

  Widget _buildQuickDateSelection() {
    final now = DateTime.now();
    final dates = [
      ('Today', now),
      ('Tomorrow', now.add(const Duration(days: 1))),
      ('This Weekend', _getNextWeekend()),
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(dates.length, (index) {
                final isSelected = _searchState.selectedDateChip == index;

                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: GestureDetector(
                    onTap: () {
                      unawaited(HapticFeedback.selectionClick());
                      ref
                          .read(rideSearchViewModelProvider.notifier)
                          .setSelectedDateChip(index);
                      ref
                          .read(rideSearchViewModelProvider.notifier)
                          .setDraftDate(dates[index].$2);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      constraints: BoxConstraints(maxWidth: 150.w),
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.cardBg,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                          width: isSelected ? 1.5 : 1,
                        ),
                        boxShadow: isSelected ? AppSpacing.shadowSm : null,
                      ),
                      child: Text(
                        dates[index].$1,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  DateTime _getNextWeekend() {
    final now = DateTime.now();

    if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
      return now;
    }

    final daysUntilSaturday = DateTime.saturday - now.weekday;
    return now.add(Duration(days: daysUntilSaturday));
  }

  Widget _buildActiveFilters() {
    final filters = <Widget>[];

    if (_searchState.draftMaxPrice < 100) {
      filters.add(
        _buildFilterTag(
          AppLocalizations.of(context).maxValue(_searchState.draftMaxPrice),
          () {
            ref
                .read(rideSearchViewModelProvider.notifier)
                .setDraftMaxPrice(100);
          },
        ),
      );
    }

    if (_searchState.draftFemaleOnly) {
      filters.add(
        _buildFilterTag(AppLocalizations.of(context).femaleOnly, () {
          ref
              .read(rideSearchViewModelProvider.notifier)
              .setDraftFemaleOnly(false);
        }),
      );
    }

    if (_searchState.draftVerifiedOnly) {
      filters.add(
        _buildFilterTag(AppLocalizations.of(context).verifiedDriver2, () {
          ref
              .read(rideSearchViewModelProvider.notifier)
              .setDraftVerifiedOnly(false);
        }),
      );
    }

    if (_searchState.draftPetFriendly) {
      filters.add(
        _buildFilterTag(AppLocalizations.of(context).petFriendly, () {
          ref
              .read(rideSearchViewModelProvider.notifier)
              .setDraftPetFriendly(false);
        }),
      );
    }

    if (_searchState.draftNoSmoking) {
      filters.add(
        _buildFilterTag(AppLocalizations.of(context).noSmoking, () {
          ref
              .read(rideSearchViewModelProvider.notifier)
              .setDraftNoSmoking(false);
        }),
      );
    }

    if (_searchState.draftLuggageRequired) {
      filters.add(
        _buildFilterTag(AppLocalizations.of(context).allowLuggageToggle, () {
          ref
              .read(rideSearchViewModelProvider.notifier)
              .setDraftLuggageRequired(false);
        }),
      );
    }

    if (_searchState.draftMinRating > 0) {
      filters.add(
        _buildFilterTag(
          AppLocalizations.of(
            context,
          ).valueRating(_searchState.draftMinRating.toStringAsFixed(1)),
          () {
            ref.read(rideSearchViewModelProvider.notifier).setDraftMinRating(0);
          },
        ),
      );
    }

    if (_searchState.draftVehicleType != 'any') {
      filters.add(
        _buildFilterTag(_vehicleTypeLabel(_searchState.draftVehicleType), () {
          ref
              .read(rideSearchViewModelProvider.notifier)
              .setDraftVehicleType('any');
        }),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context).activeFilters,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              GestureDetector(
                onTap: () {
                  unawaited(HapticFeedback.lightImpact());
                  ref.read(rideSearchViewModelProvider.notifier).resetFilters();
                },
                child: Text(
                  AppLocalizations.of(context).clearAll2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Wrap(spacing: 8.w, runSpacing: 8.h, children: filters),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildFilterTag(String label, VoidCallback onRemove) {
    return Container(
      constraints: BoxConstraints(maxWidth: 220.w),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              unawaited(HapticFeedback.lightImpact());
              onRemove();
            },
            child: Icon(
              Icons.close_rounded,
              size: 14.sp,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDiscoverySection() {
    final l10n = AppLocalizations.of(context);

    return [
      SliverToBoxAdapter(
        child: Container(
          margin: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 16.h),
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withValues(alpha: 0.08),
                AppColors.primary.withValues(alpha: 0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.directions_car_rounded,
                size: 48.sp,
                color: AppColors.primary,
              ),
              SizedBox(height: 12.h),
              Text(
                l10n.whereTo,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                l10n.findARide,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.howItWorks,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 12.h),
              _buildStepTile(
                icon: Icons.location_on_rounded,
                color: AppColors.primary,
                title: l10n.pickupAndDropoff,
                subtitle: l10n.enterPickupAndDestination,
                step: '1',
              ),
              SizedBox(height: 8.h),
              _buildStepTile(
                icon: Icons.calendar_today_rounded,
                color: AppColors.info,
                title: l10n.selectDate,
                subtitle: l10n.chooseWhenYouWantToTravel,
                step: '2',
              ),
              SizedBox(height: 8.h),
              _buildStepTile(
                icon: Icons.search_rounded,
                color: AppColors.success,
                title: l10n.findAndBook,
                subtitle: l10n.browseAvailableRidesAndBook,
                step: '3',
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
      ),
      SliverToBoxAdapter(
        child: Container(
          margin: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 8.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.info.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.verified_user_rounded,
                color: AppColors.info,
                size: 28.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.verifiedDrivers,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      l10n.allDriversAreVerified,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 350.ms, duration: 400.ms),
      ),
    ];
  }

  Widget _buildStepTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String step,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Icon(icon, color: color, size: 20.sp),
        ],
      ),
    );
  }

  Widget _buildResultsHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(
                    context,
                  ).valueRidesAvailable(_resultsState.totalCount),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  _formatDate(_searchState.draftDate),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: _showSortOptions,
            child: Container(
              constraints: BoxConstraints(maxWidth: 150.w),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.sort_rounded,
                    size: 16.sp,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 4.w),
                  Flexible(
                    child: Text(
                      _getSortLabel(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 16.sp,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 150.ms);
  }

  String _getSortLabel() {
    switch (_searchState.draftSortBy) {
      case 'price_low':
        return 'Price ↑';
      case 'price_high':
        return 'Price ↓';
      case 'rating':
        return 'Rating';
      case 'duration':
        return 'Duration';
      case 'departure':
        return 'Departure';
      default:
        return 'Recommended';
    }
  }

  Widget _buildFloatingFilterButton() {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 200),
      offset: _searchState.isFilterPanelOpen ? const Offset(0, 2) : Offset.zero,
      child: FloatingActionButton.extended(
        heroTag: 'ride_search_filter_fab',
        onPressed: _showAdvancedFilters,
        backgroundColor: AppColors.primary,
        icon: Icon(Icons.filter_list_rounded, size: 20.sp),
        label: Text(
          AppLocalizations.of(context).filtersValue(
            _hasActiveFilters ? ' (${_getActiveFilterCount()})' : '',
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  int _getActiveFilterCount() {
    return _searchState.activeFilterCount;
  }

  void _showAdvancedFilters() {
    if (_searchState.isFilterPanelOpen) return;

    unawaited(HapticFeedback.mediumImpact());
    ref.read(rideSearchViewModelProvider.notifier).setFilterPanelOpen(true);

    unawaited(
      AppModalSheet.show<void>(
        context: context,
        forceMaxHeight: true,
        maxHeightFactor: 0.8,
        showDragHandle: false,
        showCloseButton: false,
        child: Consumer(
          builder: (context, ref, child) {
            final searchState = ref.watch(rideSearchViewModelProvider);

            return Container(
              height: MediaQuery.sizeOf(context).height * 0.75,
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.border),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 40.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context).filters,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            TextButton(
                              onPressed: () {
                                ref
                                    .read(rideSearchViewModelProvider.notifier)
                                    .resetFilters();
                              },
                              child: Text(
                                AppLocalizations.of(context).reset,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFilterSectionTitle(
                            AppLocalizations.of(context).priceRange,
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Text(
                                AppLocalizations.of(context).text52,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                constraints: BoxConstraints(maxWidth: 140.w),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySurface,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  AppLocalizations.of(
                                    context,
                                  ).maxValue(searchState.draftMaxPrice),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                AppLocalizations.of(context).text100,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppColors.primary,
                              inactiveTrackColor: AppColors.border,
                              thumbColor: AppColors.primary,
                              overlayColor: AppColors.primary.withValues(
                                alpha: 0.2,
                              ),
                              trackHeight: 4.h,
                            ),
                            child: AdaptiveSlider(
                              value: searchState.draftMaxPrice.toDouble(),
                              min: 5,
                              max: 100,
                              divisions: 20,
                              onChanged: (value) {
                                ref
                                    .read(rideSearchViewModelProvider.notifier)
                                    .setDraftMaxPrice(value.toInt());
                              },
                            ),
                          ),

                          SizedBox(height: 20.h),

                          _buildFilterSectionTitle(
                            AppLocalizations.of(context).minimumRating,
                          ),
                          SizedBox(height: 12.h),
                          Wrap(
                            spacing: 8.w,
                            runSpacing: 8.h,
                            children: [0.0, 3.0, 4.0, 4.5, 4.8].map((rating) {
                              final isSelected =
                                  searchState.draftMinRating == rating;

                              return GestureDetector(
                                onTap: () {
                                  unawaited(HapticFeedback.selectionClick());
                                  ref
                                      .read(
                                        rideSearchViewModelProvider.notifier,
                                      )
                                      .setDraftMinRating(rating);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 8.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(10.r),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.border,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (rating > 0) ...[
                                        Icon(
                                          Icons.star_rounded,
                                          size: 14.sp,
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.xpGold,
                                        ),
                                        SizedBox(width: 2.w),
                                      ],
                                      Text(
                                        rating == 0
                                            ? AppLocalizations.of(context).any
                                            : AppLocalizations.of(
                                                context,
                                              ).value13(rating),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w500,
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          SizedBox(height: 24.h),

                          _buildFilterSectionTitle(
                            AppLocalizations.of(context).preferences,
                          ),
                          SizedBox(height: 12.h),
                          Wrap(
                            spacing: 10.w,
                            runSpacing: 10.h,
                            children: [
                              _buildToggleChip(
                                label: AppLocalizations.of(context).femaleOnly,
                                icon: Icons.female_rounded,
                                isSelected: searchState.draftFemaleOnly,
                                onTap: () {
                                  ref
                                      .read(
                                        rideSearchViewModelProvider.notifier,
                                      )
                                      .setDraftFemaleOnly(
                                        !searchState.draftFemaleOnly,
                                      );
                                },
                              ),
                              _buildToggleChip(
                                label: AppLocalizations.of(
                                  context,
                                ).verifiedDriver2,
                                icon: Icons.verified_user_rounded,
                                isSelected: searchState.draftVerifiedOnly,
                                onTap: () {
                                  ref
                                      .read(
                                        rideSearchViewModelProvider.notifier,
                                      )
                                      .setDraftVerifiedOnly(
                                        !searchState.draftVerifiedOnly,
                                      );
                                },
                              ),
                              _buildToggleChip(
                                label: AppLocalizations.of(context).petFriendly,
                                icon: Icons.pets_rounded,
                                isSelected: searchState.draftPetFriendly,
                                onTap: () {
                                  ref
                                      .read(
                                        rideSearchViewModelProvider.notifier,
                                      )
                                      .setDraftPetFriendly(
                                        !searchState.draftPetFriendly,
                                      );
                                },
                              ),
                              _buildToggleChip(
                                label: AppLocalizations.of(context).noSmoking,
                                icon: Icons.smoke_free_rounded,
                                isSelected: searchState.draftNoSmoking,
                                onTap: () {
                                  ref
                                      .read(
                                        rideSearchViewModelProvider.notifier,
                                      )
                                      .setDraftNoSmoking(
                                        !searchState.draftNoSmoking,
                                      );
                                },
                              ),
                              _buildToggleChip(
                                label: AppLocalizations.of(
                                  context,
                                ).allowLuggageToggle,
                                icon: Icons.luggage_rounded,
                                isSelected: searchState.draftLuggageRequired,
                                onTap: () {
                                  ref
                                      .read(
                                        rideSearchViewModelProvider.notifier,
                                      )
                                      .setDraftLuggageRequired(
                                        !searchState.draftLuggageRequired,
                                      );
                                },
                              ),
                            ],
                          ),

                          SizedBox(height: 24.h),

                          _buildFilterSectionTitle(
                            AppLocalizations.of(context).vehicleType,
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            children: [
                              _buildVehicleOption(
                                Icons.directions_car,
                                AppLocalizations.of(context).any,
                                'any',
                                searchState.draftVehicleType == 'any',
                              ),
                              SizedBox(width: 10.w),
                              _buildVehicleOption(
                                Icons.electric_car,
                                AppLocalizations.of(context).electric,
                                'electric',
                                searchState.draftVehicleType == 'electric',
                              ),
                              SizedBox(width: 10.w),
                              _buildVehicleOption(
                                Icons.local_taxi,
                                AppLocalizations.of(context).comfort,
                                'comfort',
                                searchState.draftVehicleType == 'comfort',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: const BoxDecoration(
                      color: AppColors.cardBg,
                      border: Border(
                        top: BorderSide(color: AppColors.border),
                      ),
                    ),
                    child: SafeArea(
                      child: PremiumButton(
                        text: AppLocalizations.of(context).applyFilters,
                        onPressed: () {
                          context.pop();
                          unawaited(HapticFeedback.mediumImpact());
                        },
                        style: PremiumButtonStyle.gradient,
                        icon: Icons.check_rounded,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ).whenComplete(() {
        if (!mounted) return;

        ref
            .read(rideSearchViewModelProvider.notifier)
            .setFilterPanelOpen(false);
      }),
    );
  }

  Widget _buildFilterSectionTitle(String title) {
    return Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildToggleChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        unawaited(HapticFeedback.selectionClick());
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        constraints: BoxConstraints(maxWidth: 220.w),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16.sp,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            SizedBox(width: 6.w),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleOption(
    IconData icon,
    String label,
    String type,
    bool isSelected,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          unawaited(HapticFeedback.selectionClick());
          ref
              .read(rideSearchViewModelProvider.notifier)
              .setDraftVehicleType(type);
        },
        child: Container(
          constraints: BoxConstraints(minHeight: 76.h),
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primarySurface
                : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 24.sp,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              SizedBox(height: 4.h),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openLocationPicker({required bool isFrom}) async {
    LatLng? initialLocation;

    if (isFrom && _searchState.draftOrigin != null) {
      initialLocation = LatLng(
        _searchState.draftOrigin!.latitude,
        _searchState.draftOrigin!.longitude,
      );
    } else if (!isFrom && _searchState.draftDestination != null) {
      initialLocation = LatLng(
        _searchState.draftDestination!.latitude,
        _searchState.draftDestination!.longitude,
      );
    }

    final result = await MapLocationPicker.show(
      context,
      title: isFrom ? 'Select Pickup Location' : 'Select Destination',
      initialLocation: initialLocation,
    );

    if (result != null) {
      final locationPoint = LocationPoint(
        address: result.address,
        latitude: result.location.latitude,
        longitude: result.location.longitude,
      );

      if (isFrom) {
        ref
            .read(rideSearchViewModelProvider.notifier)
            .setDraftOrigin(locationPoint);
      } else {
        ref
            .read(rideSearchViewModelProvider.notifier)
            .setDraftDestination(locationPoint);
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final normalizedDate = DateTime(date.year, date.month, date.day);

    if (normalizedDate == today) {
      return 'Today';
    }

    if (normalizedDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    }

    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}';
  }

  Widget _buildResultsList() {
    if (_resultsState.isLoading) {
      return const SliverFillRemaining(
        child: SkeletonLoader(),
      );
    }

    if (_resultsState.error != null) {
      return SliverFillRemaining(
        child: EmptyState(
          icon: Icons.error_outline,
          title: _resultsState.hasSearched
              ? AppLocalizations.of(context).searchFailed
              : AppLocalizations.of(context).somethingWentWrong,
          subtitle: _resultsState.hasSearched
              ? _resultsState.error!
              : AppLocalizations.of(context).unableToLoadRidesTryAgain,
          actionText: AppLocalizations.of(context).retry,
          onActionPressed: () {
            if (_resultsState.hasSearched) {
              unawaited(_performSearch());
              return;
            }

            ref.invalidate(activeRidesProvider);
            ref.read(rideSearchViewModelProvider.notifier).resetPagination();
          },
        ),
      );
    }

    if (_resultsState.visibleResults.isEmpty) {
      return SliverFillRemaining(
        child: EmptyState(
          icon: Icons.search_off_rounded,
          title: AppLocalizations.of(context).noRidesFound,
          subtitle: AppLocalizations.of(
            context,
          ).tryAdjustingFiltersOrDifferentDate,
          actionText: AppLocalizations.of(context).clearFilters,
          onActionPressed: () {
            ref.read(rideSearchViewModelProvider.notifier).resetFilters();
          },
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return _buildRideModelCard(_resultsState.visibleResults[index])
                .animate()
                .fadeIn(
                  duration: 350.ms,
                  delay: Duration(milliseconds: 50 + (index * 60)),
                )
                .slideX(begin: 0.1, curve: Curves.easeOutCubic);
          },
          childCount: _resultsState.visibleResults.length,
        ),
      ),
    );
  }

  String _vehicleTypeLabel(String type) {
    switch (type) {
      case 'electric':
        return AppLocalizations.of(context).electric;
      case 'comfort':
        return AppLocalizations.of(context).comfort;
      default:
        return type;
    }
  }

  Widget _buildRideModelCard(RideModel ride) {
    final departureTimeFormatted = DateFormat(
      'h:mm a',
    ).format(ride.departureTime);

    final estimatedArrival = ride.departureTime.add(
      Duration(minutes: ride.durationMinutes ?? 60),
    );

    final arrivalTimeFormatted = DateFormat('h:mm a').format(estimatedArrival);
    final durationFormatted = _formatDuration(ride.durationMinutes ?? 60);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: AppSpacing.shadowSm,
        border: Border.all(
          color: ride.status == RideStatus.full
              ? AppColors.textSecondary.withValues(alpha: 0.3)
              : AppColors.border.withValues(alpha: 0.5),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          onTap: () => context.pushNamed(
            AppRoutes.rideDetail.name,
            pathParameters: {'id': ride.id},
          ),
          borderRadius: BorderRadius.circular(16.r),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(14.w),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DriverAvatarWidget(driverId: ride.driverId, radius: 22),
                        SizedBox(width: 10.w),
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
                              SizedBox(height: 2.h),
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 8.w,
                                runSpacing: 2.h,
                                children: [
                                  DriverRatingWidget(
                                    driverId: ride.driverId,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    durationFormatted,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          constraints: BoxConstraints(maxWidth: 92.w),
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withValues(alpha: 0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            AppLocalizations.of(context).value5(
                              (ride.pricePerSeatInCents / 100).toStringAsFixed(
                                2,
                              ),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12.h),

                    Row(
                      children: [
                        Column(
                          children: [
                            Text(
                              departureTimeFormatted,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Container(
                              width: 2.w,
                              height: 24.h,
                              margin: EdgeInsets.symmetric(vertical: 4.h),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [AppColors.primary, AppColors.error],
                                ),
                                borderRadius: BorderRadius.circular(1.r),
                              ),
                            ),
                            Text(
                              arrivalTimeFormatted,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 8.w,
                                    height: 8.w,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      ride.origin.address,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: AppColors.error,
                                    size: 12.sp,
                                  ),
                                  SizedBox(width: 6.w),
                                  Expanded(
                                    child: Text(
                                      ride.destination.address,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildRideCardBottomBar(ride),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRideCardBottomBar(RideModel ride) {
    final chips = <Widget>[
      if (ride.status == RideStatus.full)
        _buildInfoChip(
          Icons.do_not_disturb_rounded,
          AppLocalizations.of(context).fullyBooked.toUpperCase(),
          AppColors.textSecondary,
        )
      else
        _buildInfoChip(
          Icons.event_seat_rounded,
          AppLocalizations.of(context).valueSeats(ride.remainingSeats),
          AppColors.primary,
        ),
      if (ride.isEco)
        _buildInfoChip(
          Icons.eco_rounded,
          AppLocalizations.of(context).eco,
          AppColors.success,
        ),
      if (ride.isPremium)
        _buildInfoChip(
          Icons.star_rounded,
          'Premium',
          AppColors.warning,
        ),
      if (ride.xpReward > 0)
        _buildInfoChip(
          Icons.bolt_rounded,
          '+${ride.xpReward} XP',
          AppColors.primary,
        ),
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.cardBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16.r),
          bottomRight: Radius.circular(16.r),
        ),
        border: Border(
          top: BorderSide(
            color: AppColors.border.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Wrap(
              spacing: 8.w,
              runSpacing: 6.h,
              children: chips,
            ),
          ),
          SizedBox(width: 8.w),
          _buildBookBadge(ride),
        ],
      ),
    );
  }

  Widget _buildBookBadge(RideModel ride) {
    final isFull = ride.status == RideStatus.full;

    return Opacity(
      opacity: isFull ? 0.45 : 1.0,
      child: Container(
        constraints: BoxConstraints(maxWidth: 96.w),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isFull ? AppColors.textSecondary : AppColors.primary,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          isFull
              ? AppLocalizations.of(context).fullyBooked
              : AppLocalizations.of(context).book,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      constraints: BoxConstraints(maxWidth: 120.w),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: color),
          SizedBox(width: 4.w),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) return '${minutes}min';

    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    if (mins == 0) return '${hours}h';

    return '${hours}h ${mins}min';
  }

  void _showSortOptions() {
    unawaited(
      AppModalSheet.show<void>(
        context: context,
        maxHeightFactor: 0.55,
        showDragHandle: false,
        showCloseButton: false,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.r),
              topRight: Radius.circular(24.r),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.only(top: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).sortBy2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      _buildSortOption(
                        icon: Icons.recommend_rounded,
                        title: AppLocalizations.of(context).recommended,
                        subtitle: AppLocalizations.of(
                          context,
                        ).bestMatchForYourSearch,
                        value: 'recommended',
                      ),
                      _buildSortOption(
                        icon: Icons.arrow_downward_rounded,
                        title: AppLocalizations.of(context).lowestPrice2,
                        subtitle: AppLocalizations.of(
                          context,
                        ).showCheapestRidesFirst,
                        value: 'price_low',
                      ),
                      _buildSortOption(
                        icon: Icons.access_time_rounded,
                        title: AppLocalizations.of(context).earliestDeparture2,
                        subtitle: AppLocalizations.of(
                          context,
                        ).showRidesLeavingSoonest,
                        value: 'departure',
                      ),
                      _buildSortOption(
                        icon: Icons.star_rounded,
                        title: AppLocalizations.of(context).highestRated2,
                        subtitle: AppLocalizations.of(
                          context,
                        ).showBestRatedDriversFirst,
                        value: 'rating',
                      ),
                      _buildSortOption(
                        icon: Icons.timer_rounded,
                        title: AppLocalizations.of(context).shortestDuration,
                        subtitle: AppLocalizations.of(
                          context,
                        ).showFastestRoutesFirst,
                        value: 'duration',
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.paddingOf(context).bottom),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
  }) {
    final isSelected = _searchState.draftSortBy == value;

    return AdaptiveListTile(
      onTap: () {
        context.pop();
        unawaited(HapticFeedback.selectionClick());
        ref.read(rideSearchViewModelProvider.notifier).setDraftSortBy(value);
      },
      leading: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.primarySurface,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : AppColors.primary,
          size: 20.sp,
        ),
      ),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
      ),
      trailing: isSelected
          ? Icon(
              Icons.check_circle_rounded,
              color: AppColors.primary,
              size: 22.sp,
            )
          : null,
    );
  }
}
