import 'dart:io';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/address_autocomplete_field.dart';
import 'package:sport_connect/core/widgets/app_modal_sheet.dart';
import 'package:sport_connect/core/widgets/custom_button.dart';
import 'package:sport_connect/core/widgets/intl_phone_input.dart';
import 'package:sport_connect/core/widgets/permission_dialog_helper.dart';
import 'package:sport_connect/core/widgets/premium_avatar.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

DateTime _hiddenDatePickerCurrentDate() => DateTime(1900);

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _form = FormGroup({
    'name': FormControl<String>(
      validators: [
        Validators.required,
        Validators.minLength(2),
        Validators.maxLength(60),
        Validators.delegate((control) {
          final value = control.value as String?;
          if (value == null || value.trim().isEmpty) return null;
          final trimmed = value.trim();
          if (RegExp('[0-9]').hasMatch(trimmed)) {
            return {'name': 'Name cannot contain numbers'};
          }
          if (!RegExp(r"^[\p{L}\s\-'.]+$", unicode: true).hasMatch(trimmed)) {
            return {'name': 'Name contains invalid characters'};
          }
          return null;
        }),
      ],
    ),
    'email': FormControl<String>(),
  });
  final _phoneKey = GlobalKey<IntlPhoneInputState>();
  final _addressKey = GlobalKey<AddressAutocompleteFieldState>();

  bool _isPopulated = false;
  UserModel? _currentUser;

  // Image picker
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickImageFromGallery() async {
    final accepted = await PermissionDialogHelper.showCameraRationale(
      context,
      customMessage:
          'Access to your photo library is needed to '
          'update your profile picture.',
    );
    if (!accepted) return;
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (image != null) {
      ref
          .read(profileEditViewModelProvider(_currentUser!.uid).notifier)
          .setPhotoFile(File(image.path));
    }
  }

  void _removePhoto() {
    ref
        .read(profileEditViewModelProvider(_currentUser!.uid).notifier)
        .removePhoto();
  }

  @override
  Widget build(BuildContext context) {
    // Populate form from user data reactively, only once.
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.value;
    final editState = ref.watch(
      profileEditViewModelProvider(_currentUser?.uid ?? ''),
    );
    if (user != null && !_isPopulated) {
      _currentUser = user;
      _populateFromUser(user);
      _isPopulated = true;
      _form.valueChanges.listen((_) {
        ref.read(profileEditViewModelProvider(user.uid).notifier).markChanged();
      });
      Future.microtask(() {
        ref
            .read(profileEditViewModelProvider(user.uid).notifier)
            .initFromUser(user);
      });
    }

    if (_currentUser != null) {
      ref.listen(profileEditViewModelProvider(_currentUser!.uid), (
        previous,
        next,
      ) {
        if (next.isSaved && previous?.isSaved != true && context.mounted) {
          AdaptiveSnackBar.show(
            context,
            message: AppLocalizations.of(context).profileUpdated,
            type: AdaptiveSnackBarType.success,
          );
        }

        if (next.error != null &&
            next.error != previous?.error &&
            context.mounted) {
          AdaptiveSnackBar.show(
            context,
            message: AppLocalizations.of(context).errorValue(next.error!),
            type: AdaptiveSnackBarType.error,
          );
        }
      });
    }

    final isDriver = _currentUser?.isDriver ?? false;
    final selectedGender = editState.gender ?? 'Male';
    final selectedDateOfBirth = editState.dateOfBirth ?? DateTime(1990);

    return SafeArea(
      top: false,
      child: PopScope(
        canPop: !editState.hasChanges,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          if (editState.hasChanges) {
            final shouldPop = await _showDiscardChangesDialog();
            if (shouldPop == true && context.mounted) context.pop();
          }
        },
        child:
            // Sticky Bottom Bar
            Stack(
              children: [
                CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverAppBar(
                      backgroundColor: AppColors.surface,
                      surfaceTintColor: Colors.transparent,
                      elevation: 0,
                      pinned: true,
                      leading: IconButton(
                        tooltip: AppLocalizations.of(context).goBackTooltip,
                        onPressed: () => context.pop(),
                        icon: Icon(
                          Icons.adaptive.arrow_back_rounded,
                          color: AppColors.textPrimary,
                          size: 20.sp,
                        ),
                      ),
                      centerTitle: true,
                      title: Text(
                        AppLocalizations.of(context).settingsEditProfile,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),

                    // Profile Picture
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.h),
                        child: Center(
                          child: GestureDetector(
                            onTap: _changeProfilePicture,
                            child: Column(
                              children: [
                                Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.surface,
                                          width: 4,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.1,
                                            ),
                                            blurRadius: 15,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: ClipOval(
                                        child: _buildProfileImage(),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(8.w),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.surface,
                                          width: 2,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.camera_alt_rounded,
                                        color: Colors.white,
                                        size: 16.sp,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  AppLocalizations.of(context).changePhoto,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Form
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: ReactiveForm(
                          formGroup: _form,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionLabel(
                                AppLocalizations.of(
                                  context,
                                ).personalInformation,
                              ),
                              _buildContainer(
                                children: [
                                  ReactiveTextField<String>(
                                    formControlName: 'name',
                                    decoration: InputDecoration(
                                      labelText: AppLocalizations.of(
                                        context,
                                      ).authFullName,
                                      prefixIcon: const Icon(
                                        Icons.person_outline_rounded,
                                      ),
                                    ),
                                    validationMessages: {
                                      ValidationMessage.required: (_) =>
                                          AppLocalizations.of(
                                            context,
                                          ).requiredField,
                                      ValidationMessage.minLength: (_) =>
                                          'Name must be at least 2 characters',
                                      ValidationMessage.maxLength: (_) =>
                                          'Name is too long',
                                      'name': (error) => error as String,
                                    },
                                  ),
                                  SizedBox(height: 16.h),
                                  ReactiveTextField<String>(
                                    formControlName: 'email',
                                    decoration: InputDecoration(
                                      labelText: AppLocalizations.of(
                                        context,
                                      ).authEmail,
                                      prefixIcon: const Icon(
                                        Icons.email_outlined,
                                      ),
                                      filled: true,
                                      fillColor: AppColors.background,
                                    ),
                                    readOnly: true,
                                  ),
                                  SizedBox(height: 16.h),
                                  IntlPhoneInput(
                                    key: _phoneKey,
                                    label: 'Phone Number',
                                    hint: 'Enter your phone number',
                                    accentColor: AppColors.primary,
                                    fillColor: AppColors.primary.withValues(
                                      alpha: 0.06,
                                    ),
                                    initialValue: switch (_currentUser) {
                                      final RiderModel rider =>
                                        rider.asRider?.phoneNumber,
                                      final DriverModel driver =>
                                        driver.asDriver?.phoneNumber,
                                      _ => null,
                                    },
                                    onChanged: (phone) {
                                      ref
                                          .read(
                                            profileEditViewModelProvider(
                                              _currentUser!.uid,
                                            ).notifier,
                                          )
                                          .setPhoneNumber(phone.fullNumber);
                                    },
                                  ),
                                ],
                              ),

                              SizedBox(height: 24.h),

                              // Driver Specific Section
                              if (isDriver) ...[
                                _buildSectionLabel(
                                  AppLocalizations.of(context).driverSettings,
                                ),
                                _buildContainer(
                                  children: [
                                    _buildActionTile(
                                      label: AppLocalizations.of(
                                        context,
                                      ).myVehicles,
                                      value:
                                          '${_currentUser?.asDriver?.vehicles.length ?? 0} Active',
                                      icon: Icons.directions_car_rounded,
                                      onTap: () {
                                        context.push(
                                          AppRoutes.driverVehicles.path,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: 24.h),
                              ],

                              _buildSectionLabel(
                                AppLocalizations.of(context).aboutYou,
                              ),
                              _buildContainer(
                                children: [
                                  AddressAutocompleteField(
                                    key: _addressKey,
                                    label: 'Address',
                                    hint: 'Search your address...',
                                    initialValue: switch (_currentUser) {
                                      final RiderModel rider =>
                                        rider.asRider?.address,
                                      final DriverModel driver =>
                                        driver.asDriver?.address,
                                      _ => null,
                                    },
                                    accentColor: AppColors.primary,
                                    onSelected: (result) {
                                      ref
                                          .read(
                                            profileEditViewModelProvider(
                                              _currentUser!.uid,
                                            ).notifier,
                                          )
                                          .setAddressResult(result);
                                    },
                                  ),
                                  SizedBox(height: 20.h),
                                  Text(
                                    'Sport Expertise Level',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  SizedBox(height: 10.h),
                                  Wrap(
                                    spacing: 8.w,
                                    children: Expertise.values.map((level) {
                                      final isSelected =
                                          editState.expertise == level;
                                      return ChoiceChip(
                                        label: Text(level.displayName),
                                        selected: isSelected,
                                        onSelected: (_) => ref
                                            .read(
                                              profileEditViewModelProvider(
                                                _currentUser!.uid,
                                              ).notifier,
                                            )
                                            .setExpertise(level),
                                        selectedColor: AppColors.primary,
                                        labelStyle: TextStyle(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.textPrimary,
                                        ),
                                        backgroundColor: AppColors.background,
                                        side: BorderSide(
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.border,
                                        ),
                                        showCheckmark: false,
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),

                              SizedBox(height: 24.h),

                              _buildSectionLabel(
                                AppLocalizations.of(context).demographics,
                              ),
                              _buildActionTile(
                                label: AppLocalizations.of(context).gender,
                                value: selectedGender,
                                icon: Icons.wc_rounded,
                                onTap: _showGenderPicker,
                              ),
                              SizedBox(height: 12.h),
                              _buildActionTile(
                                label: AppLocalizations.of(context).birthday,
                                value:
                                    '${selectedDateOfBirth.day.toString().padLeft(2, '0')}/${selectedDateOfBirth.month.toString().padLeft(2, '0')}/${selectedDateOfBirth.year}',
                                icon: Icons.cake_rounded,
                                onTap: _selectDateOfBirth,
                              ),
                              SizedBox(height: 24.h),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: PremiumButton(
                      text: AppLocalizations.of(context).saveChanges,
                      onPressed: editState.hasChanges ? _saveProfile : null,
                      isLoading: editState.isLoading,
                      icon: Icons.check_rounded,
                    ),
                  ),
                ),
              ],
            ),
      ),
    );
  }

  // --- Helpers ---

  Widget _buildProfileImage() {
    final editState = ref.watch(
      profileEditViewModelProvider(_currentUser!.uid),
    );
    if (editState.newPhotoFile != null) {
      return Image.file(
        editState.newPhotoFile!,
        width: 110.w,
        height: 110.w,
        fit: BoxFit.cover,
      );
    }
    // Using the photoUrl from the model
    if (_currentUser?.photoUrl != null && !editState.imageRemoved) {
      return Image.network(
        _currentUser!.photoUrl!,
        width: 110.w,
        height: 110.w,
        fit: BoxFit.cover,
      );
    }
    return PremiumAvatar(
      name:
          _form.control('name').value as String? ??
          _currentUser?.username ??
          '',
      size: 110,
      borderColor: Colors.transparent,
    );
  }

  Widget _buildSectionLabel(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h, left: 4.w),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildContainer({required List<Widget> children}) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildActionTile({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20.sp),
            ),
            SizedBox(width: 16.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(
              Icons.adaptive.arrow_forward_rounded,
              size: 14.sp,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  // --- Logic ---

  void _populateFromUser(UserModel user) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _form.patchValue({
        'name': user.username,
        'email': user.email,
      });
    });
  }

  Future<void> _saveProfile() async {
    _form.markAllAsTouched();
    if (!_form.valid || _currentUser == null) {
      return;
    }

    // Validate phone if entered
    final phoneError = _phoneKey.currentState?.validate();
    if (phoneError != null) return;

    try {
      final formValues = _form.value;
      final editState = ref.read(
        profileEditViewModelProvider(_currentUser!.uid),
      );

      // Get phone from IntlPhoneInput
      final phoneStr = editState.phoneNumber?.trim().isNotEmpty == true
          ? editState.phoneNumber!
          : (formValues['phone'] as String? ?? '');

      // Get address from AddressAutocompleteField or form
      final addressStr =
          editState.addressResult?.address ??
          _addressKey.currentState?.text ??
          (formValues['address'] as String? ?? '');

      // 1. Create updated model using 'map' to preserve subclass type
      final updatedUser = _currentUser!.map(
        rider: (rider) => rider.copyWith(
          username: formValues['name'] as String? ?? '',
          phoneNumber: phoneStr,
          address: addressStr,
          gender: editState.gender,
          dateOfBirth: editState.dateOfBirth,
          photoUrl: _currentUser!.photoUrl,
        ),
        driver: (driver) => driver.copyWith(
          username: formValues['name'] as String? ?? '',
          phoneNumber: phoneStr,
          address: addressStr,
          gender: editState.gender,
          dateOfBirth: editState.dateOfBirth,
          photoUrl: _currentUser!.photoUrl,
        ),
        pending: (value) => value, // No editing
      );

      await ref
          .read(profileEditViewModelProvider(_currentUser!.uid).notifier)
          .saveUserProfile(
            updatedUser: updatedUser,
            newPhotoFile: editState.newPhotoFile,
            removePhoto: editState.imageRemoved,
          );
    } catch (e, st) {
      if (!mounted) return;
      AdaptiveSnackBar.show(
        context,
        message: AppLocalizations.of(context).errorValue(e),
        type: AdaptiveSnackBarType.error,
      );
    }
  }

  // ... [Keep _changeProfilePicture, _showGenderPicker, _selectDateOfBirth, _showDiscardChangesDialog] ...
  // (These methods are identical to the previous version, omitted for brevity but required in the final file)

  void _changeProfilePicture() {
    AppModalSheet.show<void>(
      context: context,
      title: AppLocalizations.of(context).changeProfilePhoto,
      maxHeightFactor: 0.72,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              AppLocalizations.of(context).changeProfilePhoto,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 20.h),
            AdaptiveListTile(
              leading: Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: AppColors.primary,
                ),
              ),
              title: Text(
                AppLocalizations.of(context).takePhoto,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              onTap: () async {
                context.pop();
                final accepted =
                    await PermissionDialogHelper.showCameraRationale(
                      context,
                      customMessage:
                          'Camera access is needed to take a '
                          'new profile photo.',
                    );
                if (!accepted) return;
                final image = await _imagePicker.pickImage(
                  source: ImageSource.camera,
                );
                if (image != null) {
                  ref
                      .read(
                        profileEditViewModelProvider(
                          _currentUser!.uid,
                        ).notifier,
                      )
                      .setPhotoFile(File(image.path));
                }
              },
            ),
            AdaptiveListTile(
              leading: Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: const Icon(
                  Icons.photo_library_rounded,
                  color: AppColors.secondary,
                ),
              ),
              title: Text(
                AppLocalizations.of(context).chooseFromGallery,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              onTap: () async {
                context.pop();
                await _pickImageFromGallery();
              },
            ),
            if (_currentUser?.photoUrl != null &&
                !ref
                    .watch(profileEditViewModelProvider(_currentUser!.uid))
                    .imageRemoved)
              AdaptiveListTile(
                leading: Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: const Icon(
                    Icons.delete_rounded,
                    color: AppColors.error,
                  ),
                ),
                title: Text(
                  AppLocalizations.of(context).removePhoto,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
                onTap: () {
                  context.pop();
                  _removePhoto();
                },
              ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  void _showGenderPicker() {
    final editNotifier = ref.read(
      profileEditViewModelProvider(_currentUser!.uid).notifier,
    );
    final currentGender =
        ref.read(profileEditViewModelProvider(_currentUser!.uid)).gender ??
        'Male';
    AppModalSheet.show<void>(
      context: context,
      title: AppLocalizations.of(context).selectGender,
      maxHeightFactor: 0.62,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              AppLocalizations.of(context).selectGender,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            ...['Male', 'Female', 'Other', 'Prefer not to say'].map(
              (gender) => AdaptiveListTile(
                leading: Radio<String>(
                  value: gender,
                  groupValue: currentGender,
                  onChanged: (value) {
                    editNotifier.setGender(value!);
                    context.pop();
                  },
                  activeColor: AppColors.primary,
                ),
                title: Text(
                  gender,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                onTap: () {
                  editNotifier.setGender(gender);
                  context.pop();
                },
              ),
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateOfBirth() async {
    final editNotifier = ref.read(
      profileEditViewModelProvider(_currentUser!.uid).notifier,
    );
    final currentDate =
        ref.read(profileEditViewModelProvider(_currentUser!.uid)).dateOfBirth ??
        DateTime(1990);
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(1920),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 13)),
      currentDate: _hiddenDatePickerCurrentDate(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onSurface: AppColors.textPrimary,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != currentDate) {
      editNotifier.setDateOfBirth(picked);
    }
  }

  Future<bool?> _showDiscardChangesDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(AppLocalizations.of(context).discardChanges),
        content: Text(AppLocalizations.of(context).youHaveUnsavedChanges),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            child: Text(AppLocalizations.of(context).discard),
          ),
        ],
      ),
    );
  }
}
