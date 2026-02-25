import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/utils/validators.dart';
import 'package:sport_connect/core/widgets/custom_button.dart';
import 'package:sport_connect/core/widgets/glass_panel.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';

class RiderOnboardingScreen extends ConsumerStatefulWidget {
  const RiderOnboardingScreen({super.key});

  @override
  ConsumerState<RiderOnboardingScreen> createState() =>
      _RiderOnboardingScreenState();
}

class _RiderOnboardingScreenState extends ConsumerState<RiderOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _bioController = TextEditingController();

  final List<String> _availableInterests = [
    'Football',
    'Basketball',
    'Tennis',
    'Running',
    'Cycling',
    'Swimming',
    'Gym',
    'Yoga',
    'Hiking',
  ];

  final Set<String> _selectedInterests = <String>{};

  DateTime? _dateOfBirth;
  String? _gender;
  bool _agreedToTerms = false;

  String? _genderError;
  String? _dateOfBirthError;
  String? _interestsError;
  String? _termsError;

  bool _isLoading = false;
  bool _isPopulated = false;
  UserModel? _currentUser;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _populateFields(UserModel user) {
    _nameController.text = user.displayName;
    _phoneController.text = user.phoneNumber ?? '';
    _cityController.text = user.city ?? '';
    _bioController.text = user.bio ?? '';
    _gender = user.gender;
    _dateOfBirth = user.dateOfBirth;
    _selectedInterests
      ..clear()
      ..addAll(user.interests);
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 20),
      firstDate: DateTime(1950),
      lastDate: DateTime(now.year - 18, now.month, now.day),
      helpText: 'You must be at least 18 years old',
    );

    if (picked != null) {
      final age = now.difference(picked).inDays ~/ 365;
      if (age < 18) {
        setState(() {
          _dateOfBirthError =
              'You must be at least 18 years old to use SportConnect.';
        });
        return;
      }
      setState(() {
        _dateOfBirth = picked;
        _dateOfBirthError = null;
      });
    }
  }

  bool _validateNonTextFields() {
    var isValid = true;

    setState(() {
      _genderError = null;
      _dateOfBirthError = null;
      _interestsError = null;
      _termsError = null;

      if (_gender == null) {
        _genderError = 'Please select your gender.';
        isValid = false;
      }

      if (_dateOfBirth == null) {
        _dateOfBirthError = 'Please select your date of birth.';
        isValid = false;
      }

      if (_selectedInterests.isEmpty) {
        _interestsError = 'Please select at least one interest.';
        isValid = false;
      }

      if (!_agreedToTerms) {
        _termsError = 'You must accept Terms and Privacy to continue.';
        isValid = false;
      }
    });

    return isValid;
  }

  Future<void> _completeOnboarding() async {
    if (!_formKey.currentState!.validate() || _currentUser == null) return;
    if (!_validateNonTextFields()) return;

    setState(() => _isLoading = true);

    try {
      final updatedUser = _currentUser!.map(
        rider: (rider) => rider.copyWith(
          displayName: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          city: _cityController.text.trim(),
          bio: _bioController.text.trim().isEmpty
              ? null
              : _bioController.text.trim(),
          gender: _gender,
          dateOfBirth: _dateOfBirth,
          interests: _selectedInterests.toList(),
        ),
        driver: (driver) => driver,
      );

      await ref
          .read(profileActionsViewModelProvider)
          .updateProfile(updatedUser.uid, updatedUser.toJson());

      await ref
          .read(authActionsViewModelProvider)
          .clearNeedsRoleSelection(updatedUser.uid);

      if (!mounted) return;
      context.go(AppRoutes.home.path);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'We could not complete setup right now. Please try again.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.value;

    if (!_isPopulated && user != null) {
      _currentUser = user;
      _populateFields(user);
      _isPopulated = true;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          tooltip: 'Back to role selection',
          onPressed: () => context.go(AppRoutes.roleSelection.path),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Rider onboarding'),
      ),
      body: SafeArea(
        child: Semantics(
          container: true,
          label: 'Rider onboarding form',
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GlassPanel(
                    padding: EdgeInsets.all(20.w),
                    radius: 20,
                    color: AppColors.surface.withValues(alpha: 0.62),
                    borderColor: AppColors.primary.withValues(alpha: 0.2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.person_add_alt_1_rounded,
                          color: AppColors.primary,
                          size: 32.sp,
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          'Complete your rider profile',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Add your details so we can personalize rides and matching for you.',
                          style: TextStyle(
                            fontSize: 14.sp,
                            height: 1.4,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  AutofillGroup(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.name],
                          decoration: const InputDecoration(
                            labelText: 'Full name',
                          ),
                          validator: Validators.name,
                        ),
                        SizedBox(height: 14.h),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.telephoneNumber],
                          decoration: const InputDecoration(
                            labelText: 'Phone number',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return null;
                            }
                            return Validators.phone(value);
                          },
                        ),
                        SizedBox(height: 14.h),
                        TextFormField(
                          controller: _cityController,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.addressCity],
                          decoration: const InputDecoration(labelText: 'City'),
                          validator: (value) =>
                              Validators.required(value, fieldName: 'City'),
                        ),
                        SizedBox(height: 14.h),
                        TextFormField(
                          controller: _bioController,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          maxLines: 3,
                          maxLength: 160,
                          decoration: const InputDecoration(
                            labelText: 'About you (optional)',
                            hintText: 'Tell other riders a bit about you',
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 14.h),
                  DropdownButtonFormField<String>(
                    initialValue: _gender,
                    decoration: const InputDecoration(labelText: 'Gender'),
                    items: const [
                      DropdownMenuItem(value: 'Male', child: Text('Male')),
                      DropdownMenuItem(value: 'Female', child: Text('Female')),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _gender = value;
                        _genderError = null;
                      });
                    },
                  ),
                  if (_genderError != null) ...[
                    SizedBox(height: 6.h),
                    Text(
                      _genderError!,
                      style: TextStyle(color: AppColors.error, fontSize: 12.sp),
                    ),
                  ],
                  SizedBox(height: 14.h),
                  Semantics(
                    button: true,
                    label: 'Select date of birth',
                    child: InkWell(
                      onTap: _pickDateOfBirth,
                      borderRadius: BorderRadius.circular(12.r),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date of birth',
                        ),
                        child: Text(
                          _dateOfBirth == null
                              ? 'Select your date of birth'
                              : '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}',
                          style: TextStyle(
                            color: _dateOfBirth == null
                                ? AppColors.textTertiary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_dateOfBirthError != null) ...[
                    SizedBox(height: 6.h),
                    Text(
                      _dateOfBirthError!,
                      style: TextStyle(color: AppColors.error, fontSize: 12.sp),
                    ),
                  ],
                  SizedBox(height: 20.h),
                  Text(
                    'Sports interests',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Semantics(
                    container: true,
                    label: 'Sports interests selection',
                    child: Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: _availableInterests.map((interest) {
                        final isSelected = _selectedInterests.contains(
                          interest,
                        );
                        return FilterChip(
                          label: Text(interest),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                          backgroundColor: AppColors.surface,
                          selectedColor: AppColors.primary.withValues(
                            alpha: 0.2,
                          ),
                          checkmarkColor: AppColors.primary,
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedInterests.add(interest);
                              } else {
                                _selectedInterests.remove(interest);
                              }
                              _interestsError = null;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  if (_interestsError != null) ...[
                    SizedBox(height: 6.h),
                    Text(
                      _interestsError!,
                      style: TextStyle(color: AppColors.error, fontSize: 12.sp),
                    ),
                  ],
                  SizedBox(height: 18.h),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _agreedToTerms,
                    onChanged: (value) {
                      setState(() {
                        _agreedToTerms = value ?? false;
                        _termsError = null;
                      });
                    },
                    title: Text(
                      'I agree to the Terms of Service and Privacy Policy.',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  if (_termsError != null) ...[
                    Text(
                      _termsError!,
                      style: TextStyle(color: AppColors.error, fontSize: 12.sp),
                    ),
                  ],
                  SizedBox(height: 28.h),
                  Semantics(
                    button: true,
                    label: 'Complete rider onboarding',
                    child: PremiumButton(
                      text: 'Complete setup',
                      onPressed: _isLoading ? null : _completeOnboarding,
                      isLoading: _isLoading,
                      style: PremiumButtonStyle.gradient,
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
}
