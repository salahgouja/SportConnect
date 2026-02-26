import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/permission_dialog_helper.dart';
import 'package:sport_connect/features/vehicles/models/vehicle_model.dart';
import 'package:sport_connect/features/vehicles/repositories/vehicle_repository.dart';
import 'package:sport_connect/features/vehicles/view_models/vehicle_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';
import 'package:sport_connect/core/theme/platform_adaptive.dart';

/// Driver Vehicle Management Screen with Firestore
class DriverVehicleScreen extends ConsumerStatefulWidget {
  const DriverVehicleScreen({super.key});

  @override
  ConsumerState<DriverVehicleScreen> createState() =>
      _DriverVehicleScreenState();
}

class _DriverVehicleScreenState extends ConsumerState<DriverVehicleScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authStateAsync = ref.watch(authStateProvider);

    return authStateAsync.when(
      data: (user) {
        if (user == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
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

        final userId = user.uid;
        final vehiclesAsync = ref.watch(userVehiclesStreamProvider(userId));

        return vehiclesAsync.when(
          data: (vehicles) => _buildContent(vehicles, userId),
          loading: () => Scaffold(
            backgroundColor: AppColors.background,
            appBar: _buildAppBar(),
            body: const Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Scaffold(
            backgroundColor: AppColors.background,
            appBar: _buildAppBar(),
            body: Center(
              child: Text(AppLocalizations.of(context).errorValue(e)),
            ),
          ),
        );
      },
      loading: () => Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: Center(child: Text(AppLocalizations.of(context).errorValue(e))),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        tooltip: 'Go back',
        icon: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
            size: 20.w,
          ),
        ),
        onPressed: () => context.pop(),
      ),
      title: Text(
        AppLocalizations.of(context).myVehicles,
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          tooltip: 'Add vehicle',
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.add, color: AppColors.primary, size: 20.w),
          ),
          onPressed: () => _showAddVehicleSheet(context),
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildContent(List<VehicleModel> vehicles, String userId) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                      onTap: () => _showVehicleDetails(vehicle),
                      onSetActive: () => _setActiveVehicle(userId, vehicle.id),
                      onEdit: () => _showEditVehicleSheet(context, vehicle),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddVehicleSheet(
        onSave: (vehicle) async {
          final user = ref.read(currentUserProvider).value;
          if (user == null) return;

          final newVehicle = vehicle.copyWith(ownerId: user.uid);
          await ref
              .read(vehicleViewModelProvider.notifier)
              .createVehicle(newVehicle);
          if (mounted) context.pop();
        },
      ),
    );
  }

  void _showEditVehicleSheet(BuildContext context, VehicleModel vehicle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddVehicleSheet(
        vehicle: vehicle,
        onSave: (updatedVehicle) async {
          await ref
              .read(vehicleViewModelProvider.notifier)
              .updateVehicle(updatedVehicle);
          if (mounted) context.pop();
        },
      ),
    );
  }

  void _showVehicleDetails(VehicleModel vehicle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _VehicleDetailsSheet(vehicle: vehicle),
    );
  }

  void _setActiveVehicle(String userId, String vehicleId) async {
    await ref
        .read(vehicleViewModelProvider.notifier)
        .setActiveVehicle(vehicleId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).vehicleSetAsActive),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _confirmDeleteVehicle(VehicleModel vehicle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context).vehicleDeleted),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(
              AppLocalizations.of(context).actionDelete,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final VehicleModel vehicle;
  final VoidCallback onTap;
  final VoidCallback onSetActive;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _VehicleCard({
    required this.vehicle,
    required this.onTap,
    required this.onSetActive,
    required this.onEdit,
    required this.onDelete,
  });

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
                                label: vehicle.fuelType.displayName,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12.h),
                Divider(color: AppColors.divider),
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
                            _getVerificationText(),
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
                      tooltip: 'Edit vehicle',
                      onPressed: onEdit,
                      icon: Icon(
                        Icons.edit_outlined,
                        size: 20.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Delete vehicle',
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

  String _getVerificationText() {
    switch (vehicle.verificationStatus) {
      case VehicleVerificationStatus.verified:
        return 'Verified';
      case VehicleVerificationStatus.pending:
        return 'Pending';
      case VehicleVerificationStatus.rejected:
        return 'Rejected';
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

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

class _AddVehicleSheet extends StatefulWidget {
  final VehicleModel? vehicle;
  final Function(VehicleModel) onSave;

  const _AddVehicleSheet({this.vehicle, required this.onSave});

  @override
  State<_AddVehicleSheet> createState() => _AddVehicleSheetState();
}

class _AddVehicleSheetState extends State<_AddVehicleSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _makeController;
  late TextEditingController _modelController;
  late TextEditingController _yearController;
  late TextEditingController _colorController;
  late TextEditingController _licensePlateController;
  late int _capacity;
  late FuelType _fuelType;
  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _makeController = TextEditingController(text: widget.vehicle?.make ?? '');
    _modelController = TextEditingController(text: widget.vehicle?.model ?? '');
    _yearController = TextEditingController(
      text: widget.vehicle?.year.toString() ?? '',
    );
    _colorController = TextEditingController(text: widget.vehicle?.color ?? '');
    _licensePlateController = TextEditingController(
      text: widget.vehicle?.licensePlate ?? '',
    );
    _capacity = widget.vehicle?.capacity ?? 4;
    _fuelType = widget.vehicle?.fuelType ?? FuelType.gasoline;
  }

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _licensePlateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final accepted = await PermissionDialogHelper.showCameraRationale(
      context,
      customMessage:
          'Access to your photo library is needed to '
          'upload a photo of your vehicle.',
    );
    if (!accepted) return;
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final vehicle = VehicleModel(
      id: widget.vehicle?.id ?? '',
      ownerId: widget.vehicle!.ownerId,
      make: _makeController.text.trim(),
      model: _modelController.text.trim(),
      year: int.parse(_yearController.text.trim()),
      color: _colorController.text.trim(),
      licensePlate: _licensePlateController.text.trim().toUpperCase(),
      capacity: _capacity,
      fuelType: _fuelType,
      imageUrl: widget.vehicle?.imageUrl,
      isActive: widget.vehicle?.isActive ?? false,
      verificationStatus:
          widget.vehicle?.verificationStatus ??
          VehicleVerificationStatus.pending,
    );

    await widget.onSave(vehicle);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.vehicle != null;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                Icon(
                  isEditing ? Icons.edit : Icons.add,
                  color: AppColors.primary,
                ),
                SizedBox(width: 12.w),
                Text(
                  isEditing
                      ? AppLocalizations.of(context).editVehicle
                      : AppLocalizations.of(context).addVehicle,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => context.pop(),
                  icon: Icon(Icons.close, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          child: _imageFile != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(20.r),
                                  child: Image.file(
                                    _imageFile!,
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
                      controller: _makeController,
                      label: AppLocalizations.of(context).make,
                      hint: 'e.g., Toyota',
                      icon: Icons.business,
                    ),
                    SizedBox(height: 16.h),

                    // Model
                    _buildTextField(
                      controller: _modelController,
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
                            controller: _yearController,
                            label: AppLocalizations.of(context).year,
                            hint: 'e.g., 2022',
                            icon: Icons.calendar_today,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: _buildTextField(
                            controller: _colorController,
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
                      controller: _licensePlateController,
                      label: AppLocalizations.of(context).licensePlate,
                      hint: 'e.g., ABC 1234',
                      icon: Icons.credit_card,
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
                        final isSelected = seats == _capacity;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _capacity = seats),
                            child: Container(
                              margin: EdgeInsets.only(
                                right: index < 5 ? 8.w : 0,
                              ),
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
                        final isSelected = type == _fuelType;
                        return GestureDetector(
                          onTap: () => setState(() => _fuelType = type),
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
                              _getFuelTypeName(type),
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
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20.h,
                          width: 20.h,
                          child: const CircularProgressIndicator(
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
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $label';
            }
            return null;
          },
        ),
      ],
    );
  }

  String _getFuelTypeName(FuelType type) {
    switch (type) {
      case FuelType.gasoline:
        return 'Gasoline';
      case FuelType.diesel:
        return 'Diesel';
      case FuelType.electric:
        return 'Electric';
      case FuelType.hybrid:
        return 'Hybrid';
      case FuelType.pluginHybrid:
        return 'Plug-in Hybrid';
      case FuelType.hydrogen:
        return 'Hydrogen';
      case FuelType.other:
        return 'Other';
    }
  }
}

class _VehicleDetailsSheet extends StatelessWidget {
  final VehicleModel vehicle;

  const _VehicleDetailsSheet({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vehicle image
                  Center(
                    child: Container(
                      width: 150.w,
                      height: 150.w,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: vehicle.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(20.r),
                              child: Image.network(
                                vehicle.imageUrl!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(
                              Icons.directions_car,
                              size: 60.sp,
                              color: AppColors.primary,
                            ),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Vehicle name
                  Center(
                    child: Text(
                      vehicle.displayName,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Center(
                    child: Text(
                      vehicle.licensePlate,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Details grid
                  _buildDetailRow(
                    AppLocalizations.of(context).color,
                    vehicle.color,
                  ),
                  _buildDetailRow(
                    AppLocalizations.of(context).capacity,
                    AppLocalizations.of(
                      context,
                    ).valuePassengers(vehicle.capacity),
                  ),
                  _buildDetailRow(
                    AppLocalizations.of(context).fuelType,
                    vehicle.fuelType.displayName,
                  ),
                  _buildDetailRow(
                    AppLocalizations.of(context).totalRides,
                    AppLocalizations.of(context).value2(vehicle.totalRides),
                  ),
                  if (vehicle.averageRating > 0)
                    _buildDetailRow(
                      AppLocalizations.of(context).rating,
                      AppLocalizations.of(
                        context,
                      ).value8(vehicle.averageRating.toStringAsFixed(1)),
                    ),
                  SizedBox(height: 16.h),

                  // Features
                  if (vehicle.enabledFeatures.isNotEmpty) ...[
                    Text(
                      AppLocalizations.of(context).features,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: vehicle.enabledFeatures
                          .map(
                            (feature) => Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Text(
                                feature,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
