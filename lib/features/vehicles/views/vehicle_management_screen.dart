import 'dart:io';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/platform_adaptive.dart';
import 'package:sport_connect/core/widgets/app_modal_sheet.dart';
import 'package:sport_connect/core/widgets/skeleton_loader.dart';
import 'package:sport_connect/core/widgets/permission_dialog_helper.dart';
import 'package:sport_connect/features/vehicles/models/vehicle_model.dart';
import 'package:sport_connect/features/vehicles/view_models/vehicle_management_view_model.dart';
import 'package:sport_connect/features/vehicles/view_models/vehicle_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

/// Vehicle Management Screen - manage driver vehicles in Firestore
class VehicleManagementScreen extends ConsumerStatefulWidget {
  const VehicleManagementScreen({super.key});

  @override
  ConsumerState<VehicleManagementScreen> createState() =>
      _VehicleManagementScreenState();
}

class _VehicleManagementScreenState
    extends ConsumerState<VehicleManagementScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final vmState = ref.watch(vehicleViewModelProvider);

    ref.listen(vehicleViewModelProvider, (previous, next) {
      if (next.actionType == null || next.actionType == previous?.actionType) {
        return;
      }

      final message = next.actionMessage;
      if (message != null) {
        AdaptiveSnackBar.show(
          context,
          message: message,
          type: AdaptiveSnackBarType.success,
        );
      }

      ref.read(vehicleViewModelProvider.notifier).clearAction();
    });

    if (vmState.userId == null) {
      return AdaptiveScaffold(
        appBar: _buildAppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 64.sp,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: 16.h),
              Text(
                AppLocalizations.of(context).pleaseSignInToManage,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final userId = vmState.userId!;
    return vmState.vehicles.when(
      data: (vehicles) => _buildContent(vehicles, userId),
      loading: () => AdaptiveScaffold(
        appBar: _buildAppBar(),
        body: const SkeletonLoader(type: SkeletonType.compactTile, itemCount: 3),
      ),
      error: (e, _) => AdaptiveScaffold(
        appBar: _buildAppBar(),
        body: Center(child: Text(AppLocalizations.of(context).errorValue(e))),
      ),
    );
  }

  AdaptiveAppBar _buildAppBar() {
    return AdaptiveAppBar(
      leading: IconButton(
        tooltip: AppLocalizations.of(context).goBackTooltip,
        icon: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(
            Icons.adaptive.arrow_back,
            color: AppColors.textPrimary,
            size: 20.w,
          ),
        ),
        onPressed: () => context.pop(),
      ),
      title: AppLocalizations.of(context).myVehicles,
      actions: [
        AdaptiveAppBarAction(
          title: AppLocalizations.of(context).addVehicle,
          icon: Icons.add,
          onPressed: () => _showAddVehicleSheet(context),
        ),
      ],
    );
  }

  Widget _buildContent(List<VehicleModel> vehicles, String userId) {
    return AdaptiveScaffold(
      appBar: _buildAppBar(),
      body: vehicles.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: vehicles.length,
              itemBuilder: (context, index) {
                final vehicle = vehicles[index];
                return _VehicleCard(
                      vehicle: vehicle,
                      onTap: () => _showVehicleFlow(vehicle),
                      onSetActive: () => _setActiveVehicle(userId, vehicle.id),
                      onEdit: () =>
                          _showVehicleFlow(vehicle, initialPageIndex: 1),
                      onDelete: () => _confirmDeleteVehicle(vehicle),
                    )
                    .animate()
                    .fadeIn(delay: Duration(milliseconds: 100 * index))
                    .slideY(
                      begin: 0.1,
                      delay: Duration(milliseconds: 100 * index),
                    );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.directions_car_outlined,
              size: 64.sp,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            AppLocalizations.of(context).noVehiclesAdded,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            AppLocalizations.of(context).addYourFirstVehicleTo,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
          SizedBox(height: 32.h),
          ElevatedButton.icon(
            onPressed: () => _showAddVehicleSheet(context),
            icon: const Icon(Icons.add),
            label: Text(AppLocalizations.of(context).addVehicle),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddVehicleSheet(BuildContext context) {
    AppModalSheet.show<void>(
      context: context,
      title: AppLocalizations.of(context).addVehicle,
      forceMaxHeight: true,
      maxHeightFactor: 0.9,
      child: _AddVehicleSheet(
        onSave: (vehicle) async {
          final userId = ref.read(vehicleViewModelProvider).userId;
          if (userId == null) return;

          final newVehicle = vehicle.copyWith(ownerId: userId);
          final success = await ref
              .read(vehicleViewModelProvider.notifier)
              .createVehicle(newVehicle);
          if (success && context.mounted) {
            context.pop();
          }
        },
      ),
    );
  }

  void _showVehicleFlow(
    VehicleModel vehicle, {
    int initialPageIndex = 0,
  }) {
    final l10n = AppLocalizations.of(context);
    AppModalSheet.showPages<void>(
      context: context,
      initialPageIndex: initialPageIndex,
      pageListBuilder: (sheetContext) => [
        AppModalSheet.page(
          context: sheetContext,
          title: vehicle.displayName,
          maxHeightFactor: 0.82,
          stickyActionBar: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: WoltModalSheet.of(sheetContext).showNext,
                      icon: const Icon(Icons.edit_outlined),
                      label: Text(l10n.editVehicle),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                        _confirmDeleteVehicle(vehicle);
                      },
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: Text(l10n.deleteVehicle),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          child: _VehicleDetailsSheet(vehicle: vehicle),
        ),
        AppModalSheet.page(
          context: sheetContext,
          title: l10n.editVehicle,
          forceMaxHeight: true,
          maxHeightFactor: 0.9,
          leadingNavBarWidget: IconButton(
            tooltip: l10n.goBackTooltip,
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: WoltModalSheet.of(sheetContext).showPrevious,
          ),
          child: _AddVehicleSheet(
            vehicle: vehicle,
            onSave: (updatedVehicle) async {
              final success = await ref
                  .read(vehicleViewModelProvider.notifier)
                  .updateVehicle(updatedVehicle);
              if (success && sheetContext.mounted) {
                Navigator.of(sheetContext).pop();
              }
            },
          ),
        ),
      ],
    );
  }

  Future<void> _setActiveVehicle(String userId, String vehicleId) async {
    await ref
        .read(vehicleViewModelProvider.notifier)
        .setActiveVehicle(vehicleId);
  }

  void _confirmDeleteVehicle(VehicleModel vehicle) {
    showDialog<void>(
      context: context,
      barrierLabel: AppLocalizations.of(context).deleteVehicle,
      builder: (context) => AlertDialog.adaptive(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.dialogRadius),
        ),
        title: Text(AppLocalizations.of(context).deleteVehicle),
        content: Text(
          AppLocalizations.of(context).areYouSureYouWant4(vehicle.displayName),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              context.pop();
              await ref
                  .read(vehicleViewModelProvider.notifier)
                  .deleteVehicle(vehicle.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(
              AppLocalizations.of(context).actionDelete,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({
    required this.vehicle,
    required this.onTap,
    required this.onSetActive,
    required this.onEdit,
    required this.onDelete,
  });
  final VehicleModel vehicle;
  final VoidCallback onTap;
  final VoidCallback onSetActive;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: vehicle.isActive
              ? AppColors.primary.withValues(alpha: 0.5)
              : AppColors.border,
          width: vehicle.isActive ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Vehicle Image
                    Container(
                      width: 80.w,
                      height: 80.w,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: vehicle.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16.r),
                              child: Image.network(
                                vehicle.imageUrl!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(
                              Icons.directions_car,
                              size: 40.sp,
                              color: AppColors.primary,
                            ),
                    ),
                    SizedBox(width: 16.w),

                    // Vehicle Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  vehicle.displayName,
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (vehicle.isActive)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context).active,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            vehicle.licensePlate,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              _InfoChip(
                                icon: Icons.airline_seat_recline_normal,
                                label: '${vehicle.capacity} seats',
                              ),
                              SizedBox(width: 8.w),
                              _InfoChip(
                                icon: Icons.local_gas_station,
                                label: vehicle.fuelType.name,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12.h),
                const Divider(color: AppColors.divider),
                SizedBox(height: 8.h),

                // Actions
                Row(
                  children: [
                    // Verification status
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: _getVerificationColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getVerificationIcon(),
                            size: 14.sp,
                            color: _getVerificationColor(),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            _getVerificationText(context),
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: _getVerificationColor(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (!vehicle.isActive)
                      TextButton.icon(
                        onPressed: onSetActive,
                        icon: Icon(Icons.check_circle_outline, size: 16.sp),
                        label: Text(AppLocalizations.of(context).setActive),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                    IconButton(
                      tooltip: AppLocalizations.of(context).editVehicle,
                      onPressed: onEdit,
                      icon: Icon(
                        Icons.edit_outlined,
                        size: 20.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    IconButton(
                      tooltip: AppLocalizations.of(context).deleteVehicle,
                      onPressed: onDelete,
                      icon: Icon(
                        Icons.delete_outline,
                        size: 20.sp,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getVerificationColor() {
    switch (vehicle.verificationStatus) {
      case VehicleVerificationStatus.verified:
        return AppColors.success;
      case VehicleVerificationStatus.pending:
        return AppColors.warning;
      case VehicleVerificationStatus.rejected:
        return AppColors.error;
    }
  }

  IconData _getVerificationIcon() {
    switch (vehicle.verificationStatus) {
      case VehicleVerificationStatus.verified:
        return Icons.verified;
      case VehicleVerificationStatus.pending:
        return Icons.hourglass_empty;
      case VehicleVerificationStatus.rejected:
        return Icons.cancel;
    }
  }

  String _getVerificationText(BuildContext context) {
    switch (vehicle.verificationStatus) {
      case VehicleVerificationStatus.verified:
        return AppLocalizations.of(context).verified;
      case VehicleVerificationStatus.pending:
        return AppLocalizations.of(context).pending;
      case VehicleVerificationStatus.rejected:
        return AppLocalizations.of(context).rejected;
    }
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: AppColors.textSecondary),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _AddVehicleSheet extends ConsumerStatefulWidget {
  const _AddVehicleSheet({required this.onSave, this.vehicle});
  final VehicleModel? vehicle;
  final Function(VehicleModel) onSave;

  @override
  ConsumerState<_AddVehicleSheet> createState() => _AddVehicleSheetState();
}

class _AddVehicleSheetState extends ConsumerState<_AddVehicleSheet> {
  late final FormGroup _form;

  String get _providerKey => widget.vehicle?.id ?? '__new_vehicle__';

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;
    _form = FormGroup({
      'make': FormControl<String>(
        value: v?.make ?? '',
        validators: [Validators.required],
      ),
      'model': FormControl<String>(
        value: v?.model ?? '',
        validators: [Validators.required],
      ),
      'year': FormControl<String>(
        value: v?.year.toString() ?? '',
        validators: [
          Validators.required,
          Validators.delegate((control) {
            final value = control.value as String?;
            if (value == null || value.trim().isEmpty) return null;
            final year = int.tryParse(value.trim());
            if (year == null) {
              return {'vehicleYear': 'Please enter a valid year'};
            }
            if (year < 1980) return {'vehicleYear': 'Vehicle is too old'};
            if (year > DateTime.now().year) {
              return {'vehicleYear': 'Invalid year'};
            }
            return null;
          }),
        ],
      ),
      'color': FormControl<String>(
        value: v?.color ?? '',
        validators: [Validators.required],
      ),
      'license_plate': FormControl<String>(
        value: v?.licensePlate ?? '',
        validators: [
          Validators.required,
          Validators.delegate((control) {
            final value = control.value as String?;
            if (value == null || value.trim().isEmpty) return null;
            final trimmed = value.trim().toUpperCase();
            if (trimmed.length < 2) {
              return {'licensePlate': 'License plate is too short'};
            }
            if (trimmed.length > 12) {
              return {'licensePlate': 'License plate is too long'};
            }
            if (!RegExp(r'^[A-Z0-9\-\s]+$').hasMatch(trimmed)) {
              return {'licensePlate': 'Invalid license plate format'};
            }
            return null;
          }),
        ],
      ),
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final container = ProviderScope.containerOf(context, listen: false);
      container
          .read(addVehicleSheetUiViewModelProvider(_providerKey).notifier)
          .init(widget.vehicle);
    });
  }

  Future<void> _pickImage() async {
    final accepted = await PermissionDialogHelper.showCameraRationale(
      context,
      customMessage: AppLocalizations.of(context).uploadVehiclePhotoPermission,
    );
    if (!accepted) return;
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (!mounted) return;
      final container = ProviderScope.containerOf(context, listen: false);
      container
          .read(addVehicleSheetUiViewModelProvider(_providerKey).notifier)
          .setImageFile(File(image.path));
    }
  }

  Future<void> _save() async {
    _form.markAllAsTouched();
    if (!_form.valid) return;

    final container = ProviderScope.containerOf(context, listen: false);
    final notifier = container.read(
      addVehicleSheetUiViewModelProvider(_providerKey).notifier,
    );
    final uiState = container.read(
      addVehicleSheetUiViewModelProvider(_providerKey),
    );
    notifier.setLoading(true);

    final values = _form.value;
    final vehicle = VehicleModel(
      id: widget.vehicle?.id ?? '',
      ownerId: widget.vehicle?.ownerId ?? '',
      make: (values['make'] as String).trim(),
      model: (values['model'] as String).trim(),
      year: int.parse((values['year'] as String).trim()),
      color: (values['color'] as String).trim(),
      licensePlate: (values['license_plate'] as String).trim().toUpperCase(),
      capacity: uiState.capacity,
      fuelType: uiState.fuelType,
      imageUrl: widget.vehicle?.imageUrl,
      isActive: widget.vehicle?.isActive ?? false,
      verificationStatus:
          widget.vehicle?.verificationStatus ??
          VehicleVerificationStatus.pending,
    );

    await widget.onSave(vehicle);
    if (!mounted) return;
    notifier.setLoading(false);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.vehicle != null;
    final uiState = ref.watch(addVehicleSheetUiViewModelProvider(_providerKey));

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
            child: ReactiveForm(
              formGroup: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(18.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primarySurface,
                          AppColors.accentSurface,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56.w,
                          height: 56.w,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(18.r),
                          ),
                          child: Icon(
                            isEditing
                                ? Icons.tune_rounded
                                : Icons.add_road_rounded,
                            color: AppColors.primary,
                            size: 28.sp,
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEditing
                                    ? AppLocalizations.of(context).saveChanges
                                    : AppLocalizations.of(context).addVehicle,
                                style: TextStyle(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                isEditing
                                    ? 'Update your vehicle details and keep the profile current.'
                                    : 'Add a polished vehicle profile so riders can trust the trip before they book.',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  height: 1.45,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Image picker
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 120.w,
                        height: 120.w,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: uiState.imageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(20.r),
                                child: Image.file(
                                  uiState.imageFile!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate,
                                    size: 40.sp,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    AppLocalizations.of(context).addPhoto,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Make
                  _buildTextField(
                    formControlName: 'make',
                    label: AppLocalizations.of(context).make,
                    hint: 'e.g., Toyota',
                    icon: Icons.business,
                  ),
                  SizedBox(height: 16.h),

                  // Model
                  _buildTextField(
                    formControlName: 'model',
                    label: AppLocalizations.of(context).model,
                    hint: 'e.g., Camry',
                    icon: Icons.directions_car,
                  ),
                  SizedBox(height: 16.h),

                  // Year and Color
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          formControlName: 'year',
                          label: AppLocalizations.of(context).year,
                          hint: 'e.g., 2022',
                          icon: Icons.calendar_today,
                          keyboardType: TextInputType.number,
                          validationMessages: {
                            ValidationMessage.required: (_) =>
                                AppLocalizations.of(context).pleaseEnterValue(
                                  AppLocalizations.of(context).year,
                                ),
                            'vehicleYear': (error) => error as String,
                          },
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _buildTextField(
                          formControlName: 'color',
                          label: AppLocalizations.of(context).color,
                          hint: 'e.g., Silver',
                          icon: Icons.color_lens,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // License plate
                  _buildTextField(
                    formControlName: 'license_plate',
                    label: AppLocalizations.of(context).licensePlate,
                    hint: 'e.g., ABC 1234',
                    icon: Icons.credit_card,
                    validationMessages: {
                      ValidationMessage.required: (_) =>
                          AppLocalizations.of(context).pleaseEnterValue(
                            AppLocalizations.of(context).licensePlate,
                          ),
                      'licensePlate': (error) => error as String,
                    },
                  ),
                  SizedBox(height: 24.h),

                  // Capacity
                  Text(
                    AppLocalizations.of(context).passengerCapacity,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: List.generate(6, (index) {
                      final seats = index + 1;
                      final isSelected = seats == uiState.capacity;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            ref
                                .read(
                                  addVehicleSheetUiViewModelProvider(
                                    _providerKey,
                                  ).notifier,
                                )
                                .setCapacity(seats);
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: index < 5 ? 8.w : 0),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.background,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.border,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                AppLocalizations.of(context).value2(seats),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 24.h),

                  // Fuel type
                  Text(
                    AppLocalizations.of(context).fuelType,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: FuelType.values.map((type) {
                      final isSelected = type == uiState.fuelType;
                      return GestureDetector(
                        onTap: () {
                          ref
                              .read(
                                addVehicleSheetUiViewModelProvider(
                                  _providerKey,
                                ).notifier,
                              )
                              .setFuelType(type);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 10.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.background,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          ),
                          child: Text(
                            type.name,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ),

        // Save button
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: uiState.isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                child: uiState.isLoading
                    ? SizedBox(
                        height: 20.h,
                        width: 20.h,
                        child: const CircularProgressIndicator.adaptive(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        isEditing
                            ? AppLocalizations.of(context).saveChanges
                            : AppLocalizations.of(context).addVehicle,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String formControlName,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    Map<String, String Function(Object)>? validationMessages,
  }) {
    return ReactiveTextField<String>(
      formControlName: formControlName,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      validationMessages:
          validationMessages ??
          {
            ValidationMessage.required: (_) =>
                AppLocalizations.of(context).pleaseEnterValue(label),
          },
    );
  }
}

class _VehicleDetailsSheet extends StatelessWidget {
  const _VehicleDetailsSheet({required this.vehicle});
  final VehicleModel vehicle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primarySurface, AppColors.accentSurface],
              ),
              borderRadius: BorderRadius.circular(28.r),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.12),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 148.w,
                  height: 148.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: vehicle.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(24.r),
                          child: Image.network(
                            vehicle.imageUrl!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          Icons.directions_car_filled_rounded,
                          size: 64.sp,
                          color: AppColors.primary,
                        ),
                ),
                SizedBox(height: 18.h),
                Text(
                  vehicle.displayName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  vehicle.licensePlate,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 14.h),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _buildStatusChip(
                      vehicle.isActive ? 'Active vehicle' : 'Inactive',
                      vehicle.isActive ? AppColors.success : AppColors.info,
                    ),
                    _buildStatusChip(
                      _verificationLabel(),
                      vehicle.isVerified
                          ? AppColors.primary
                          : AppColors.warning,
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 18.h),

          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.airline_seat_recline_normal_rounded,
                  label: l10n.capacity,
                  value: '${vehicle.capacity}',
                  accent: AppColors.primary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.local_gas_station_rounded,
                  label: l10n.fuelType,
                  value: vehicle.fuelType.name,
                  accent: AppColors.info,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.route_rounded,
                  label: l10n.totalRides,
                  value: '${vehicle.totalRides}',
                  accent: AppColors.warning,
                ),
              ),
            ],
          ),

          SizedBox(height: 18.h),

          Container(
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vehicle details',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 14.h),
                _buildDetailRow(l10n.color, vehicle.color),
                _buildDetailRow(l10n.year, '${vehicle.year}'),
                _buildDetailRow(
                  l10n.capacity,
                  l10n.valuePassengers(vehicle.capacity),
                ),
                _buildDetailRow(l10n.fuelType, vehicle.fuelType.name),
                if (vehicle.averageRating > 0)
                  _buildDetailRow(
                    l10n.rating,
                    l10n.value8(vehicle.averageRating.toStringAsFixed(1)),
                  ),
              ],
            ),
          ),

          if (vehicle.enabledFeatures.isNotEmpty) ...[
            SizedBox(height: 18.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.features,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: vehicle.enabledFeatures
                        .map(
                          (feature) => Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Text(
                              feature,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _verificationLabel() {
    switch (vehicle.verificationStatus) {
      case VehicleVerificationStatus.verified:
        return 'Verified';
      case VehicleVerificationStatus.rejected:
        return 'Needs review';
      case VehicleVerificationStatus.pending:
        return 'Pending review';
    }
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
    required Color accent,
  }) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: accent, size: 18.sp),
          ),
          SizedBox(height: 10.h),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
