import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/custom_button.dart';
import 'package:sport_connect/core/widgets/premium_text_field.dart';
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
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController(); // Often read-only
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController(); // Maps to city/country

  // State
  String _selectedGender = 'Male';
  DateTime _dateOfBirth = DateTime(1990, 1, 1);
  bool _isLoading = false;
  bool _hasChanges = false;
  bool _isPopulated = false;
  UserModel? _currentUser; // Keep a reference to the actual model for mapping

  // Image picker
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  bool _imageRemoved = false;

  final List<String> _interests = [];
  final List<String> _availableInterests = [
    'Football',
    'Basketball',
    'Tennis',
    'Golf',
    'Swimming',
    'Running',
    'Cycling',
    'Yoga',
    'Gym',
    'Hiking',
    'Soccer',
    'Baseball',
    'Hockey',
    'Volleyball',
    'Cricket',
  ];

  @override
  void initState() {
    super.initState();
    // Listeners to track changes (no provider reads here).
    _nameController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _bioController.addListener(_onFieldChanged);
    _locationController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
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
      setState(() {
        _selectedImage = File(image.path);
        _imageRemoved = false;
        _hasChanges = true;
      });
    }
  }

  void _removePhoto() {
    setState(() {
      _selectedImage = null;
      _imageRemoved = true;
      _hasChanges = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Populate form from user data reactively, only once.
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.value;
    if (user != null && !_isPopulated) {
      _currentUser = user;
      _populateFromUser(user);
      _isPopulated = true;
    }

    final isDriver = _currentUser?.isDriver ?? false;

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_hasChanges) {
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
            onPressed: _hasChanges ? _saveProfile : null,
            isLoading: _isLoading,
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel(
                        AppLocalizations.of(context).personalInformation,
                      ),
                      _buildContainer(
                        children: [
                          PremiumTextField(
                            controller: _nameController,
                            label: 'Full Name',
                            prefixIcon: Icons.person_outline_rounded,
                            validator: (v) =>
                                (v?.isEmpty ?? true) ? 'Required' : null,
                          ),
                          SizedBox(height: 16.h),
                          PremiumTextField(
                            controller: _emailController,
                            label: 'Email',
                            prefixIcon: Icons.email_outlined,
                            readOnly:
                                true, // Typically email is managed separately
                            enabled: false,
                            fillColor: AppColors.background,
                          ),
                          SizedBox(height: 16.h),
                          PremiumTextField(
                            controller: _phoneController,
                            label: 'Phone Number',
                            prefixIcon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
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
                                  '${_currentUser?.asDriver!.vehicles.length ?? 0} Active',
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
                          PremiumTextField(
                            controller: _bioController,
                            label: 'Bio',
                            prefixIcon: Icons.edit_note_rounded,
                            maxLines: 3,
                            maxLength: 150,
                          ),
                          SizedBox(height: 16.h),
                          PremiumTextField(
                            controller: _locationController,
                            label: 'City',
                            prefixIcon: Icons.location_city_rounded,
                          ),
                        ],
                      ),

                      SizedBox(height: 24.h),

                      _buildSectionLabel(
                        AppLocalizations.of(context).demographics,
                      ),
                      _buildActionTile(
                        label: AppLocalizations.of(context).gender,
                        value: _selectedGender,
                        icon: Icons.wc_rounded,
                        onTap: _showGenderPicker,
                      ),
                      SizedBox(height: 12.h),
                      _buildActionTile(
                        label: AppLocalizations.of(context).birthday,
                        value:
                            '${_dateOfBirth.day}/${_dateOfBirth.month}/${_dateOfBirth.year}',
                        icon: Icons.cake_rounded,
                        onTap: _selectDateOfBirth,
                      ),

                      SizedBox(height: 24.h),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionLabel(
                            AppLocalizations.of(context).sportsInterests,
                          ),
                          GestureDetector(
                            onTap: _showInterestsDialog,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: Text(
                                AppLocalizations.of(context).add,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Interests Wrap
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: _interests.isEmpty
                            ? Center(
                                child: Text(
                                  AppLocalizations.of(
                                    context,
                                  ).noInterestsSelected,
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              )
                            : Wrap(
                                spacing: 8.w,
                                runSpacing: 8.h,
                                children: _interests.map((interest) {
                                  return Chip(
                                    label: Text(
                                      interest,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    backgroundColor: AppColors.primary
                                        .withValues(alpha: 0.1),
                                    side: BorderSide.none,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    padding: EdgeInsets.zero,
                                    labelPadding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                    ),
                                    deleteIcon: Icon(
                                      Icons.close_rounded,
                                      size: 14.sp,
                                      color: AppColors.primary,
                                    ),
                                    onDeleted: () {
                                      setState(() {
                                        _interests.remove(interest);
                                        _hasChanges = true;
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                      ),
                      SizedBox(height: 40.h),
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
    if (_selectedImage != null) {
      return Image.file(
        _selectedImage!,
        width: 110.w,
        height: 110.w,
        fit: BoxFit.cover,
      );
    }
    // Using the photoUrl from the model
    if (_currentUser?.photoUrl != null && !_imageRemoved) {
      return Image.network(
        _currentUser!.photoUrl!,
        width: 110.w,
        height: 110.w,
        fit: BoxFit.cover,
      );
    }
    return PremiumAvatar(
      name: _nameController.text,
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
    setState(() {
      _nameController.text = user.displayName;
      _emailController.text = user.email;
      _phoneController.text = user.phoneNumber ?? '';
      _bioController.text = user.bio ?? '';
      _locationController.text = user.city ?? '';

      _selectedGender = user.gender ?? 'Male';
      _dateOfBirth = user.dateOfBirth ?? DateTime(1990);
      _interests.clear();
      _interests.addAll(user.interests);
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || _currentUser == null) return;
    setState(() => _isLoading = true);

    try {
      // 1. Create updated model using 'map' to preserve subclass type
      final updatedUser = _currentUser!.map(
        rider: (rider) => rider.copyWith(
          displayName: _nameController.text,
          phoneNumber: _phoneController.text,
          bio: _bioController.text,
          city: _locationController.text, // Simplified location
          gender: _selectedGender,
          dateOfBirth: _dateOfBirth,
          interests: _interests,
          // If you upload an image, you'd get the URL first and pass it here
          // photoUrl: uploadedPhotoUrl ?? rider.photoUrl,
        ),
        driver: (driver) => driver.copyWith(
          displayName: _nameController.text,
          phoneNumber: _phoneController.text,
          bio: _bioController.text,
          city: _locationController.text,
          gender: _selectedGender,
          dateOfBirth: _dateOfBirth,
          interests: _interests,
        ),
      );

      // 2. Call view model action
      await ref
          .read(profileActionsViewModelProvider)
          .updateProfile(updatedUser.uid, updatedUser.toJson());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).profileUpdated),
            backgroundColor: AppColors.success,
          ),
        );
        setState(() {
          _isLoading = false;
          _hasChanges = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).errorValue(e)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // ... [Keep _changeProfilePicture, _showGenderPicker, _selectDateOfBirth, _showInterestsDialog, _showDiscardChangesDialog] ...
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
                    setState(() {
                      _selectedImage = File(image.path);
                      _imageRemoved = false;
                      _hasChanges = true;
                    });
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
              if (_currentUser?.photoUrl != null && !_imageRemoved)
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
                    groupValue: _selectedGender,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value!;
                        _hasChanges = true;
                      });
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
                    setState(() {
                      _selectedGender = gender;
                      _hasChanges = true;
                    });
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
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth,
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
            dialogBackgroundColor: AppColors.surface,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
        _hasChanges = true;
      });
    }
  }

  void _showInterestsDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            maxChildSize: 0.9,
            minChildSize: 0.4,
            expand: false,
            builder: (context, scrollController) => Padding(
              padding: EdgeInsets.all(20.w),
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
                  SizedBox(height: 20.h),
                  Text(
                    AppLocalizations.of(context).selectSportsInterests,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: _availableInterests.length,
                      itemBuilder: (context, index) {
                        final interest = _availableInterests[index];
                        final isSelected = _interests.contains(interest);
                        return CheckboxListTile(
                          value: isSelected,
                          activeColor: AppColors.primary,
                          title: Text(
                            interest,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          onChanged: (value) {
                            setModalState(() {
                              if (value == true) {
                                _interests.add(interest);
                              } else {
                                _interests.remove(interest);
                              }
                            });
                            setState(() => _hasChanges = true);
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context).actionDone,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
