import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/custom_button.dart';
import 'package:sport_connect/core/widgets/premium_text_field.dart';
import 'package:sport_connect/features/profile/repositories/profile_repository.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/features/vehicles/models/vehicle_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';
import 'package:sport_connect/core/theme/platform_adaptive.dart';

class VehiclesScreen extends ConsumerStatefulWidget {
  const VehiclesScreen({super.key});

  @override
  ConsumerState<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends ConsumerState<VehiclesScreen> {
  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      // We use a Stack to float the button with a custom position if needed,
      // but standard FAB works well here.
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'vehicles_add_fab',
        onPressed: () => _showAddVehicleSheet(null),
        backgroundColor: AppColors.primary,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          AppLocalizations.of(context).addRide,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return Center(
              child: Text(AppLocalizations.of(context).userNotFound),
            );
          }

          // Load vehicles from the repository using provider
          final vehiclesAsync = ref.watch(driverVehiclesProvider(user.uid));

          return vehiclesAsync.when(
            data: (vehicles) {
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildSliverAppBar(vehicles.length),
                  if (vehicles.isEmpty)
                    SliverFillRemaining(child: _buildEmptyState())
                  else
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          if (index == vehicles.length) {
                            return _buildTipsCard();
                          }
                          return _buildDismissibleVehicleCard(
                            vehicles[index],
                            user.uid,
                          );
                        }, childCount: vehicles.length + 1),
                      ),
                    ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: Text(AppLocalizations.of(context).errorLoadingVehicles),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text(AppLocalizations.of(context).errorLoadingVehicles),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(int count) {
    return SliverAppBar(
      backgroundColor: AppColors.surface,
      expandedHeight: 140.h,
      floating: false,
      pinned: true,
      elevation: 0,
      leading: IconButton(
        tooltip: 'Go back',
        onPressed: () => context.pop(),
        icon: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppColors.background,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
            size: 20.sp,
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: EdgeInsets.only(left: 16.w, bottom: 16.h),
        title: Text(
          AppLocalizations.of(context).myGarage,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 24.sp,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.surface, AppColors.background],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20.w,
                top: 40.h,
                child: Icon(
                  Icons.directions_car_filled_rounded,
                  size: 150.sp,
                  color: AppColors.primary.withValues(alpha: 0.05),
                ),
              ),
              Positioned(
                left: 20.w,
                top: 60.h,
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context).valueVehicles(count),
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Wraps the card in Swipe-to-Action logic
  Widget _buildDismissibleVehicleCard(VehicleModel vehicle, String uid) {
    return Dismissible(
      key: Key(vehicle.id),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Swipe Left -> Delete
          _showDeleteConfirmation(vehicle, uid);
          return false; // Let the dialog handle the actual delete
        } else if (direction == DismissDirection.startToEnd) {
          // Swipe Right -> Set Default
          if (!vehicle.isActive) {
            final actions = ref.read(profileActionsViewModelProvider);
            await actions.setDefaultVehicle(uid, vehicle.id);
            HapticFeedback.mediumImpact();
          }
          return false; // Don't remove from list, just trigger action
        }
        return false;
      },
      background: Container(
        margin: EdgeInsets.only(bottom: 20.h),
        decoration: BoxDecoration(
          color: AppColors.success,
          borderRadius: BorderRadius.circular(24.r),
        ),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 24.w),
        child: Row(
          children: [
            Icon(Icons.star_rounded, color: Colors.white, size: 28.sp),
            SizedBox(width: 8.w),
            Text(
              AppLocalizations.of(context).setDefault,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        margin: EdgeInsets.only(bottom: 20.h),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(24.r),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 24.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              AppLocalizations.of(context).actionDelete,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              Icons.delete_outline_rounded,
              color: Colors.white,
              size: 28.sp,
            ),
          ],
        ),
      ),
      child: _buildDigitalKeyCard(vehicle, uid),
    );
  }

  /// The new "Hero" Card Design
  Widget _buildDigitalKeyCard(VehicleModel vehicle, String uid) {
    final baseColor = _getVehicleColor(vehicle.color);
    return GestureDetector(
      onTap: () => _showEditVehicleSheet(vehicle, uid),
      child: Container(
        height: 190.h,
        margin: EdgeInsets.only(bottom: 20.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: baseColor.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            // 1. Dynamic Gradient Background
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.r),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      baseColor.withValues(alpha: 0.12),
                      AppColors.surface.withValues(alpha: 0.5),
                    ],
                  ),
                ),
              ),
            ),

            // 2. Large Watermark Icon
            Positioned(
              right: -20.w,
              bottom: -20.h,
              child: Icon(
                _getVehicleIcon(vehicle.fuelType),
                size: 140.sp,
                color: baseColor.withValues(alpha: 0.08),
              ),
            ),

            // 3. Status Badge (Top Right)
            Positioned(
              top: 16.h,
              right: 16.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: vehicle.isVerified
                          ? AppColors.success.withValues(alpha: 0.1)
                          : Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: vehicle.isVerified
                            ? AppColors.success.withValues(alpha: 0.3)
                            : Colors.orange.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          vehicle.isVerified
                              ? Icons.verified_rounded
                              : Icons.hourglass_top_rounded,
                          size: 14.sp,
                          color: vehicle.isVerified
                              ? AppColors.success
                              : Colors.orange,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          vehicle.isVerified
                              ? AppLocalizations.of(context).verified
                              : AppLocalizations.of(context).pending,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: vehicle.isVerified
                                ? AppColors.success
                                : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (vehicle.isActive) ...[
                    SizedBox(height: 6.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        'DEFAULT',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // 4. Main Content
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon and Make
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          _getVehicleIcon(vehicle.fuelType),
                          color: baseColor,
                          size: 24.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vehicle.make,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            vehicle.model,
                            style: TextStyle(
                              fontSize: 20.sp,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Bottom Glass Panel
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                      child: Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Plate
                            _buildMiniInfo(
                              Icons
                                  .horizontal_rule_rounded, // Abstract plate look
                              vehicle.licensePlate,
                              AppLocalizations.of(context).plate,
                            ),
                            Container(
                              width: 1,
                              height: 24.h,
                              color: AppColors.border,
                            ),
                            // Year
                            _buildMiniInfo(
                              Icons.calendar_today_rounded,
                              vehicle.year.toString(),
                              AppLocalizations.of(context).year,
                            ),
                            Container(
                              width: 1,
                              height: 24.h,
                              color: AppColors.border,
                            ),
                            // Seats Visualizer
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context).seats2,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Row(
                                  children: List.generate(
                                    4, // Show max 4 dots visually to save space
                                    (index) => Padding(
                                      padding: EdgeInsets.only(right: 2.w),
                                      child: CircleAvatar(
                                        radius: 3.sp,
                                        backgroundColor:
                                            index < vehicle.capacity
                                            ? AppColors.textPrimary
                                            : AppColors.border,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniInfo(IconData icon, String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 150.w,
                height: 150.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.05),
                ),
              ),
              Container(
                width: 110.w,
                height: 110.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
              ),
              Icon(
                Icons.no_crash_rounded,
                size: 60.sp,
                color: AppColors.primary,
              ),
            ],
          ),
          SizedBox(height: 32.h),
          Text(
            AppLocalizations.of(context).garageIsEmpty,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              AppLocalizations.of(context).addAVehicleToStart,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 40.h),
          PremiumButton(
            text: 'Add Your First Ride',
            onPressed: () => _showAddVehicleSheet(null),
            icon: Icons.add_circle_outline_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildTipsCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FE), // Very light cool grey
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.lightbulb_rounded,
              color: AppColors.primary,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).quickTip,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  AppLocalizations.of(context).swipeRightOnAVehicle,
                  style: TextStyle(
                    fontSize: 12.sp,
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

  // --- Logic Helpers (Kept mostly same, added Haptic) ---

  IconData _getVehicleIcon(FuelType fuelType) {
    switch (fuelType) {
      case FuelType.electric:
        return Icons.electric_car_rounded;
      case FuelType.hybrid:
        return Icons.battery_charging_full_rounded;
      case FuelType.diesel:
        return Icons.local_shipping_rounded;
      default:
        return Icons.directions_car_rounded;
    }
  }

  Color _getVehicleColor(String color) {
    // Enhanced palette
    switch (color.toLowerCase()) {
      case 'white':
        return Colors.blueGrey; // White on white bg is bad, so blueGrey
      case 'black':
        return const Color(0xFF2C3E50);
      case 'silver':
        return Colors.grey.shade600;
      case 'blue':
        return const Color(0xFF2980B9);
      case 'red':
        return const Color(0xFFC0392B);
      case 'green':
        return const Color(0xFF27AE60);
      case 'yellow':
        return const Color(0xFFF39C12);
      default:
        return AppColors.primary;
    }
  }

  void _showDeleteConfirmation(VehicleModel vehicle, String uid) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.dialogRadius),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            SizedBox(width: 12.w),
            Text(AppLocalizations.of(context).deleteRide),
          ],
        ),
        content: Text(
          AppLocalizations.of(context).areYouSureYouWant6(vehicle.make),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              AppLocalizations.of(context).keepIt,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              context.pop();
              await ref
                  .read(profileActionsViewModelProvider)
                  .removeVehicle(uid, vehicle.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context).vehicleRemovedFromGarage,
                    ),
                    backgroundColor: AppColors.textPrimary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text(
              AppLocalizations.of(context).actionDelete,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddVehicleSheet(String? uid) => _showVehicleFormSheet(null);
  void _showEditVehicleSheet(VehicleModel vehicle, String uid) =>
      _showVehicleFormSheet(vehicle);

  // Form Sheet Logic (Reused existing structure but cleaned UI)
  void _showVehicleFormSheet(VehicleModel? vehicle) {
    final isEditing = vehicle != null;
    final makeController = TextEditingController(text: vehicle?.make ?? '');
    final modelController = TextEditingController(text: vehicle?.model ?? '');
    final yearController = TextEditingController(
      text: vehicle?.year.toString() ?? '',
    );
    final colorController = TextEditingController(text: vehicle?.color ?? '');
    final plateController = TextEditingController(
      text: vehicle?.licensePlate ?? '',
    );
    var capacity = vehicle?.capacity ?? 4;
    var fuelType = vehicle?.fuelType ?? FuelType.gasoline;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) => Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                SizedBox(height: 12.h),
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: EdgeInsets.all(24.w),
                    children: [
                      Text(
                        isEditing
                            ? AppLocalizations.of(context).editRide
                            : AppLocalizations.of(context).newRide,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // Two columns for Make/Model
                      Row(
                        children: [
                          Expanded(
                            child: PremiumTextField(
                              controller: makeController,
                              label: 'Make',
                              hint: 'Tesla',
                              prefixIcon: Icons.business_outlined,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: PremiumTextField(
                              controller: modelController,
                              label: 'Model',
                              hint: 'Model 3',
                              prefixIcon: Icons.directions_car_outlined,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      // Year & Color
                      Row(
                        children: [
                          Expanded(
                            child: PremiumTextField(
                              controller: yearController,
                              label: 'Year',
                              hint: '2023',
                              keyboardType: TextInputType.number,
                              prefixIcon: Icons.calendar_today_outlined,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: PremiumTextField(
                              controller: colorController,
                              label: 'Color',
                              hint: 'Red',
                              prefixIcon: Icons.palette_outlined,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      PremiumTextField(
                        controller: plateController,
                        label: 'License Plate',
                        hint: 'ABC 1234',
                        prefixIcon: Icons.grid_3x3,
                      ),

                      SizedBox(height: 24.h),

                      // Modern Seat Selector
                      Text(
                        AppLocalizations.of(context).seatsCapacity,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      SizedBox(
                        height: 50.h,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: 8,
                          separatorBuilder: (_, _) => SizedBox(width: 12.w),
                          itemBuilder: (context, index) {
                            final count = index + 1;
                            final isSelected = capacity == count;
                            return GestureDetector(
                              onTap: () {
                                setModalState(() => capacity = count);
                                HapticFeedback.selectionClick();
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 50.h,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.background,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.border,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    AppLocalizations.of(context).value2(count),
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.textSecondary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // Fuel Type Chips
                      Text(
                        AppLocalizations.of(context).fuelType,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Wrap(
                        spacing: 10.w,
                        runSpacing: 10.h,
                        children:
                            [
                              FuelType.gasoline,
                              FuelType.diesel,
                              FuelType.hybrid,
                              FuelType.electric,
                            ].map((type) {
                              final isSelected = fuelType == type;
                              return ChoiceChip(
                                label: Text(type.displayName),
                                selected: isSelected,
                                onSelected: (val) {
                                  setModalState(() => fuelType = type);
                                  HapticFeedback.selectionClick();
                                },
                                backgroundColor: AppColors.background,
                                selectedColor: AppColors.primary,
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 8.h,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.r),
                                  side: BorderSide(
                                    color: isSelected
                                        ? Colors.transparent
                                        : AppColors.border,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),

                      SizedBox(height: 40.h),

                      PremiumButton(
                        text: isEditing ? 'Update Vehicle' : 'Add to Garage',
                        onPressed: () async {
                          // ... (Validation and Save logic same as before) ...
                          // Copying logic from previous message for brevity
                          if (makeController.text.isEmpty ||
                              modelController.text.isEmpty) {
                            return;
                          }

                          final user = ref
                              .read(currentUserStreamProvider)
                              .value;
                          if (user == null) return;

                          final newVehicle = VehicleModel(
                            id:
                                vehicle?.id ??
                                DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                            ownerId: user.uid,
                            make: makeController.text,
                            model: modelController.text,
                            year: int.tryParse(yearController.text) ?? 2023,
                            color: colorController.text,
                            licensePlate: plateController.text,
                            capacity: capacity,
                            isActive: vehicle?.isActive ?? false,
                            verificationStatus:
                                VehicleVerificationStatus.pending,
                            fuelType: fuelType,
                          );

                          context.pop();
                          final actions = ref.read(
                            profileActionsViewModelProvider,
                          );
                          if (isEditing) {
                            await actions.updateVehicle(user.uid, newVehicle);
                          } else {
                            await actions.addVehicle(user.uid, newVehicle);
                          }
                        },
                        icon: isEditing
                            ? Icons.save_rounded
                            : Icons.add_rounded,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).viewInsets.bottom + 20.h,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
