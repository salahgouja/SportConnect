import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/utils/form_validators.dart';
import 'package:sport_connect/core/widgets/custom_button.dart';
import 'package:sport_connect/core/widgets/intl_phone_input.dart';
import 'package:sport_connect/core/widgets/address_autocomplete_field.dart';
import 'package:sport_connect/core/widgets/premium_avatar.dart';
import 'package:sport_connect/core/widgets/permission_dialog_helper.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _phoneKey = GlobalKey<IntlPhoneInputState>();
  final _cityKey = GlobalKey<AddressAutocompleteFieldState>();

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
    final XFile? image = await _imagePicker.pickImage(
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).profileUpdated),
              backgroundColor: AppColors.success,
            ),
          );
        }

        if (next.error != null &&
            next.error != previous?.error &&
            context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).errorValue(next.error!),
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      });
    }

    final isDriver = _currentUser?.isDriver ?? false;
    final selectedGender = editState.gender ?? 'Male';
    final selectedDateOfBirth = editState.dateOfBirth ?? DateTime(1990, 1, 1);

    return PopScope(
      canPop: !editState.hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (editState.hasChanges) {
          final shouldPop = await _showDiscardChangesDialog();
          if (shouldPop == true && mounted) context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        // Sticky Bottom Bar
        bottomNavigationBar: Container(
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
            text: 'Save Changes',
            onPressed: editState.hasChanges ? _saveProfile : null,
            isLoading: editState.isLoading,
            icon: Icons.check_rounded,
          ),
        ),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              backgroundColor: AppColors.surface,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              pinned: true,
              leading: IconButton(
                tooltip: 'Back',
                onPressed: () => context.pop(),
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
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
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ClipOval(child: _buildProfileImage()),
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
                child: FormBuilder(
                  key: _formKey,
                  onChanged: () {
                    ref
                        .read(
                          profileEditViewModelProvider(
                            _currentUser!.uid,
                          ).notifier,
                        )
                        .markChanged();
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel(
                        AppLocalizations.of(context).personalInformation,
                      ),
                      _buildContainer(
                        children: [
                          FormBuilderTextField(
                            name: 'name',
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: const Icon(
                                Icons.person_outline_rounded,
                              ),
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(
                                errorText: 'Required',
                              ),
                              FormBuilderValidators.minLength(2),
                              FormBuilderValidators.maxLength(60),
                              (value) => FormValidators.name(value),
                            ]),
                          ),
                          SizedBox(height: 16.h),
                          FormBuilderTextField(
                            name: 'email',
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: const Icon(Icons.email_outlined),
                              filled: true,
                              fillColor: AppColors.background,
                            ),
                            readOnly: true,
                            enabled: false,
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
                            initialValue: _currentUser?.phoneNumber,
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
                              label: AppLocalizations.of(context).myVehicles,
                              value:
                                  '${_currentUser?.asDriver?.vehicles.length ?? 0} Active',
                              icon: Icons.directions_car_rounded,
                              onTap: () {
                                context.push(AppRoutes.driverVehicles.path);
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),
                      ],

                      _buildSectionLabel(AppLocalizations.of(context).aboutYou),
                      _buildContainer(
                        children: [
                          AddressAutocompleteField(
                            key: _cityKey,
                            label: 'City',
                            hint: 'Search your city...',
                            cityOnly: true,
                            initialValue: _currentUser?.city,
                            accentColor: AppColors.primary,
                            onSelected: (result) {
                              ref
                                  .read(
                                    profileEditViewModelProvider(
                                      _currentUser!.uid,
                                    ).notifier,
                                  )
                                  .setCityResult(result);
                            },
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
          (_formKey.currentState?.fields['name']!.value as String? ??
          _currentUser?.displayName ??
          ''),
      size: 110,
      hasBorder: false,
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
              Icons.arrow_forward_ios_rounded,
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
      _formKey.currentState?.patchValue({
        'name': user.displayName,
        'email': user.email,
        'phone': user.phoneNumber ?? '',
        'city': user.city ?? '',
        'country': user.country ?? '',
      });
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.saveAndValidate() || _currentUser == null)
      return;

    // Validate phone if entered
    final phoneError = _phoneKey.currentState?.validate();
    if (phoneError != null) return;

    try {
      final formValues = _formKey.currentState!.value;
      final editState = ref.read(
        profileEditViewModelProvider(_currentUser!.uid),
      );

      // Get phone from IntlPhoneInput
      final phoneStr = editState.phoneNumber?.trim().isNotEmpty == true
          ? editState.phoneNumber!
          : (formValues['phone'] as String? ?? '');

      // Get city from AddressAutocompleteField or form
      final cityStr =
          editState.cityResult?.address ??
          _cityKey.currentState?.text ??
          (formValues['city'] as String? ?? '');

      // Get country from AddressAutocompleteField result or form
      final countryStr =
          editState.cityResult?.country ??
          (formValues['country'] as String? ?? '');

      // 1. Create updated model using 'map' to preserve subclass type
      final updatedUser = _currentUser!.map(
        rider: (rider) => rider.copyWith(
          displayName: formValues['name'] as String? ?? '',
          phoneNumber: phoneStr,
          city: cityStr,
          country: countryStr,
          gender: editState.gender,
          dateOfBirth: editState.dateOfBirth,
          photoUrl: _currentUser!.photoUrl,
        ),
        driver: (driver) => driver.copyWith(
          displayName: formValues['name'] as String? ?? '',
          phoneNumber: phoneStr,
          city: cityStr,
          country: countryStr,
          gender: editState.gender,
          dateOfBirth: editState.dateOfBirth,
          photoUrl: _currentUser!.photoUrl,
        ),
      );

      await ref
          .read(profileEditViewModelProvider(_currentUser!.uid).notifier)
          .saveUserProfile(
            updatedUser: updatedUser,
            newPhotoFile: editState.newPhotoFile,
            removePhoto: editState.imageRemoved,
          );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).errorValue(e)),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // ... [Keep _changeProfilePicture, _showGenderPicker, _selectDateOfBirth, _showDiscardChangesDialog] ...
  // (These methods are identical to the previous version, omitted for brevity but required in the final file)

  void _changeProfilePicture() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => SafeArea(
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
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    color: AppColors.primary,
                  ),
                ),
                title: Text(
                  AppLocalizations.of(context).takePhoto,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final accepted =
                      await PermissionDialogHelper.showCameraRationale(
                        context,
                        customMessage:
                            'Camera access is needed to take a '
                            'new profile photo.',
                      );
                  if (!accepted) return;
                  final XFile? image = await _imagePicker.pickImage(
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
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.photo_library_rounded,
                    color: AppColors.secondary,
                  ),
                ),
                title: Text(
                  AppLocalizations.of(context).chooseFromGallery,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImageFromGallery();
                },
              ),
              if (_currentUser?.photoUrl != null &&
                  !ref
                      .watch(profileEditViewModelProvider(_currentUser!.uid))
                      .imageRemoved)
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(Icons.delete_rounded, color: AppColors.error),
                  ),
                  title: Text(
                    AppLocalizations.of(context).removePhoto,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _removePhoto();
                  },
                ),
              SizedBox(height: 10.h),
            ],
          ),
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
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => SafeArea(
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
                (gender) => ListTile(
                  leading: Radio<String>(
                    value: gender,
                    groupValue: currentGender,
                    onChanged: (value) {
                      editNotifier.setGender(value!);
                      Navigator.pop(context);
                    },
                    activeColor: AppColors.primary,
                  ),
                  title: Text(
                    gender,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  onTap: () {
                    editNotifier.setGender(gender);
                    Navigator.pop(context);
                  },
                ),
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }

  void _selectDateOfBirth() async {
    final editNotifier = ref.read(
      profileEditViewModelProvider(_currentUser!.uid).notifier,
    );
    final currentDate =
        ref.read(profileEditViewModelProvider(_currentUser!.uid)).dateOfBirth ??
        DateTime(1990, 1, 1);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(1920),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 13)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
            dialogTheme: DialogThemeData(backgroundColor: AppColors.surface),
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
      builder: (context) => AlertDialog(
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
