import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/utils/validators.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/core/widgets/premium_text_field.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/features/vehicles/models/vehicle_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Driver Onboarding Screen - Multi-step wizard for new drivers
/// Step 1: Complete driver profile (name, phone, city, bio, gender, DOB, interests)
/// Step 2: Add vehicle information
/// Step 3: Setup Stripe for payouts
class DriverOnboardingScreen extends ConsumerStatefulWidget {
  const DriverOnboardingScreen({super.key});

  @override
  ConsumerState<DriverOnboardingScreen> createState() =>
      _DriverOnboardingScreenState();
}

class _DriverOnboardingScreenState
    extends ConsumerState<DriverOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;
  bool _isProfilePopulated = false;

  // ── Profile form (Step 0) ──────────────────────────────────────────
  final _profileFormKey = GlobalKey<FormState>();
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

  // ── Vehicle form (Step 1) ──────────────────────────────────────────
  final _vehicleFormKey = GlobalKey<FormState>();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _colorController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _seatsController = TextEditingController(text: '4');
  FuelType _selectedFuelType = FuelType.gasoline;

  final List<FuelType> _fuelTypes = [
    FuelType.gasoline,
    FuelType.diesel,
    FuelType.electric,
    FuelType.hybrid,
    FuelType.hydrogen,
  ];

  @override
  void dispose() {
    _pageController.dispose();
    // Profile
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _bioController.dispose();
    // Vehicle
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _licensePlateController.dispose();
    _seatsController.dispose();
    super.dispose();
  }

  // ── Navigation helpers ──────────────────────────────────────────────

  void _nextStep() {
    // Validate the current step before advancing.
    if (_currentStep == 0) {
      if (!_profileFormKey.currentState!.validate()) return;
      if (!_validateProfileNonTextFields()) return;
    } else if (_currentStep == 1) {
      if (!_vehicleFormKey.currentState!.validate()) return;
    }

    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  // ── Profile helpers (Step 0) ───────────────────────────────────────

  void _populateProfileFields(UserModel user) {
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
      helpText: AppLocalizations.of(context).authDobPicker,
    );

    if (picked != null) {
      final age = now.difference(picked).inDays ~/ 365;
      if (age < 18) {
        setState(() {
          _dateOfBirthError = AppLocalizations.of(context).authDobMinAge;
        });
        return;
      }
      setState(() {
        _dateOfBirth = picked;
        _dateOfBirthError = null;
      });
    }
  }

  bool _validateProfileNonTextFields() {
    var isValid = true;
    setState(() {
      _genderError = null;
      _dateOfBirthError = null;
      _interestsError = null;
      _termsError = null;

      if (_gender == null) {
        _genderError = AppLocalizations.of(context).driverGenderRequired;
        isValid = false;
      }
      if (_dateOfBirth == null) {
        _dateOfBirthError = AppLocalizations.of(context).authDobError;
        isValid = false;
      }
      if (_selectedInterests.isEmpty) {
        _interestsError =
            AppLocalizations.of(context).driverInterestsRequired;
        isValid = false;
      }
      if (!_agreedToTerms) {
        _termsError = AppLocalizations.of(context).driverTermsRequired;
        isValid = false;
      }
    });
    return isValid;
  }

  Future<void> _saveProfileAndContinue() async {
    if (!_profileFormKey.currentState!.validate()) return;
    if (!_validateProfileNonTextFields()) return;

    setState(() => _isLoading = true);

    try {
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser == null) return;

      final updatedUser = currentUser.map(
        rider: (rider) => rider, // Should not reach this in driver flow
        driver: (driver) => driver.copyWith(
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
      );

      await ref
          .read(profileActionsViewModelProvider)
          .updateProfile(updatedUser.uid, updatedUser.toJson());

      if (!mounted) return;
      _nextStep();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Vehicle + Stripe helpers ───────────────────────────────────────

  Future<void> _saveVehicleAndContinue() async {
    if (!_vehicleFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final currentUser = ref.read(currentUserProvider).value;

      if (currentUser != null) {
        final driver = currentUser.asDriver!;

        // Create vehicle object
        final vehicle = VehicleModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          ownerId: driver.uid,
          ownerName: driver.displayName,
          ownerPhotoUrl: driver.photoUrl,
          make: _makeController.text.trim(),
          model: _modelController.text.trim(),
          year: int.parse(_yearController.text.trim()),
          color: _colorController.text.trim(),
          licensePlate: _licensePlateController.text.trim().toUpperCase(),
          capacity: int.parse(_seatsController.text.trim()),
          fuelType: _selectedFuelType,
          isActive: true,
          verificationStatus: VehicleVerificationStatus.pending,
        );

        // Add vehicle to user's profile using actions provider
        // to avoid auto-dispose family provider lifecycle issues.
        final profileActions = ref.read(profileActionsViewModelProvider);
        await profileActions.addVehicle(currentUser.uid, vehicle);

        if (!mounted) return;
        _nextStep();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              ).errorSavingVehicleValue(e.toString()),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _setupStripe() async {
    // Clear the needsRoleSelection flag — driver setup is complete
    final authActions = ref.read(authActionsViewModelProvider);
    final uid = authActions.currentUser?.uid;
    if (uid != null) {
      await authActions.clearNeedsRoleSelection(uid);
    }
    if (mounted) context.go(AppRoutes.driverStripeOnboarding.path);
  }

  Future<void> _skipStripeForNow() async {
    // Clear the needsRoleSelection flag — driver setup is complete
    final authActions = ref.read(authActionsViewModelProvider);
    final uid = authActions.currentUser?.uid;
    if (uid != null) {
      await authActions.clearNeedsRoleSelection(uid);
    }
    if (mounted) context.go(AppRoutes.driverHome.path);
  }

  @override
  Widget build(BuildContext context) {
    // Pre-populate profile fields from the current user (once).
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.value;
    if (!_isProfilePopulated && user != null) {
      _populateProfileFields(user);
      _isProfilePopulated = true;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                tooltip: 'Previous step',
                onPressed: _previousStep,
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textPrimary,
                  size: 20.sp,
                ),
              )
            : IconButton(
                tooltip: 'Go back',
                onPressed: () => context.go(AppRoutes.roleSelection.path),
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textPrimary,
                  size: 20.sp,
                ),
              ),
        title: Text(
          AppLocalizations.of(context).driverSetup,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(),

          // Page content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildProfileStep(),
                _buildVehicleStep(),
                _buildStripeStep(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Row(
        children: [
          _buildStepIndicator(
            0,
            AppLocalizations.of(context).navProfile,
            Icons.person_outline_rounded,
          ),
          Expanded(
            child: Container(
              height: 2,
              margin: EdgeInsets.symmetric(horizontal: 8.w),
              decoration: BoxDecoration(
                color: _currentStep >= 1 ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          _buildStepIndicator(
            1,
            AppLocalizations.of(context).vehicle,
            Icons.directions_car_outlined,
          ),
          Expanded(
            child: Container(
              height: 2,
              margin: EdgeInsets.symmetric(horizontal: 8.w),
              decoration: BoxDecoration(
                color: _currentStep >= 2 ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          _buildStepIndicator(
            2,
            AppLocalizations.of(context).payouts,
            Icons.account_balance_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, IconData icon) {
    final isActive = _currentStep >= step;
    final isCurrent = _currentStep == step;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.surfaceVariant,
            shape: BoxShape.circle,
            border: isCurrent
                ? Border.all(color: AppColors.primaryLight, width: 2)
                : null,
          ),
          child: Icon(
            icon,
            color: isActive ? Colors.white : AppColors.textTertiary,
            size: 20.sp,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive ? AppColors.textPrimary : AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  // ── Step 0: Profile ─────────────────────────────────────────────────

  Widget _buildProfileStep() {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Form(
        key: _profileFormKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildStepHeader(
              icon: Icons.person_add_alt_1_rounded,
              title: l10n.driverProfileTitle,
              subtitle: l10n.driverProfileSubtitle,
            ).animate().fadeIn(duration: 400.ms),

            SizedBox(height: 24.h),

            // Full name
            PremiumTextField(
              controller: _nameController,
              label: l10n.authFullName,
              hint: l10n.authFullNameHint,
              prefixIcon: Icons.person_rounded,
              textInputAction: TextInputAction.next,
              validator: Validators.name,
            ).animate().fadeIn(duration: 400.ms, delay: 50.ms),

            SizedBox(height: 16.h),

            // Phone (optional)
            PremiumTextField(
              controller: _phoneController,
              label: l10n.authPhoneOptional,
              hint: l10n.authPhoneHint,
              prefixIcon: Icons.phone_rounded,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) return null;
                return Validators.phone(value);
              },
            ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

            SizedBox(height: 16.h),

            // City
            PremiumTextField(
              controller: _cityController,
              label: l10n.driverCityLabel,
              hint: l10n.driverCityHint,
              prefixIcon: Icons.location_city_rounded,
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  Validators.required(value, fieldName: l10n.driverCityLabel),
            ).animate().fadeIn(duration: 400.ms, delay: 150.ms),

            SizedBox(height: 16.h),

            // About you (optional)
            PremiumTextField(
              controller: _bioController,
              label: l10n.authAboutYou,
              hint: l10n.authAboutYouHint,
              prefixIcon: Icons.info_outline_rounded,
              maxLines: 3,
              maxLength: 160,
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline,
            ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

            SizedBox(height: 16.h),

            // Gender dropdown
            Text(
              l10n.gender,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 250.ms),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: _genderError != null
                      ? AppColors.error
                      : AppColors.inputBorder,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _gender,
                  isExpanded: true,
                  hint: Text(
                    l10n.selectGender,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary,
                  ),
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
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 250.ms),
            if (_genderError != null) ...[
              SizedBox(height: 6.h),
              Text(
                _genderError!,
                style: TextStyle(color: AppColors.error, fontSize: 12.sp),
              ),
            ],

            SizedBox(height: 16.h),

            // Date of birth
            Text(
              l10n.authDateOfBirth,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
            SizedBox(height: 8.h),
            InkWell(
              onTap: _pickDateOfBirth,
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: _dateOfBirthError != null
                        ? AppColors.error
                        : AppColors.inputBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      color: AppColors.textSecondary,
                      size: 20.sp,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      _dateOfBirth == null
                          ? l10n.authDobPrompt
                          : '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}',
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: _dateOfBirth == null
                            ? AppColors.textTertiary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
            if (_dateOfBirthError != null) ...[
              SizedBox(height: 6.h),
              Text(
                _dateOfBirthError!,
                style: TextStyle(color: AppColors.error, fontSize: 12.sp),
              ),
            ],

            SizedBox(height: 20.h),

            // Sports interests
            Text(
              l10n.sportsInterests,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 350.ms),
            SizedBox(height: 10.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: _availableInterests.map((interest) {
                final isSelected = _selectedInterests.contains(interest);
                return FilterChip(
                  label: Text(interest),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  backgroundColor: AppColors.surface,
                  selectedColor: AppColors.primary.withAlpha(50),
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
            ).animate().fadeIn(duration: 400.ms, delay: 350.ms),
            if (_interestsError != null) ...[
              SizedBox(height: 6.h),
              Text(
                _interestsError!,
                style: TextStyle(color: AppColors.error, fontSize: 12.sp),
              ),
            ],

            SizedBox(height: 18.h),

            // Terms checkbox
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _agreedToTerms,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (value) {
                setState(() {
                  _agreedToTerms = value ?? false;
                  _termsError = null;
                });
              },
              title: Text(
                l10n.driverTermsLabel,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
            if (_termsError != null)
              Text(
                _termsError!,
                style: TextStyle(color: AppColors.error, fontSize: 12.sp),
              ),

            SizedBox(height: 28.h),

            // Save & Continue
            SizedBox(
              width: double.infinity,
              child: PremiumButton(
                text: l10n.driverSaveAndContinue,
                onPressed: _isLoading ? null : _saveProfileAndContinue,
                isLoading: _isLoading,
                style: PremiumButtonStyle.primary,
                size: PremiumButtonSize.large,
                trailingIcon: Icons.arrow_forward_rounded,
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 450.ms),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  // ── Step 1: Vehicle ────────────────────────────────────────────────

  Widget _buildVehicleStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Form(
        key: _vehicleFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildStepHeader(
              icon: Icons.directions_car_rounded,
              title: AppLocalizations.of(context).addYourVehicle,
              subtitle: 'Tell us about your car so riders know what to expect.',
            ).animate().fadeIn(duration: 400.ms),

            SizedBox(height: 24.h),

            // Vehicle Make
            PremiumTextField(
              controller: _makeController,
              label: 'Make',
              hint: 'e.g., Toyota, Honda, BMW',
              prefixIcon: Icons.business_rounded,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter vehicle make';
                }
                return null;
              },
            ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

            SizedBox(height: 16.h),

            // Vehicle Model
            PremiumTextField(
              controller: _modelController,
              label: 'Model',
              hint: 'e.g., Corolla, Civic, 3 Series',
              prefixIcon: Icons.directions_car_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter vehicle model';
                }
                return null;
              },
            ).animate().fadeIn(duration: 400.ms, delay: 150.ms),

            SizedBox(height: 16.h),

            // Year and Color row
            Row(
              children: [
                Expanded(
                  child: PremiumTextField(
                    controller: _yearController,
                    label: 'Year',
                    hint: 'e.g., 2020',
                    prefixIcon: Icons.calendar_today_outlined,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }

                      // Use regex to ensure it's strictly numbers before parsing
                      if (!RegExp(r'^\d+$').hasMatch(value.trim())) {
                        return 'Numbers only';
                      }

                      final year = int.tryParse(value.trim());
                      if (year == null ||
                          year < 1990 ||
                          year > DateTime.now().year) {
                        return 'Invalid year';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: PremiumTextField(
                    controller: _colorController,
                    label: 'Color',
                    hint: 'e.g., White',
                    prefixIcon: Icons.palette_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

            SizedBox(height: 16.h),

            // License Plate
            PremiumTextField(
              controller: _licensePlateController,
              label: 'License Plate',
              hint: 'e.g., ABC 123',
              prefixIcon: Icons.credit_card_rounded,
              textCapitalization: TextCapitalization.characters,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter license plate';
                }
                return null;
              },
            ).animate().fadeIn(duration: 400.ms, delay: 250.ms),

            SizedBox(height: 16.h),

            // Seats
            PremiumTextField(
              controller: _seatsController,
              label: 'Available Seats',
              hint: '4',
              prefixIcon: Icons.event_seat_rounded,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter number of seats';
                }
                final seats = int.tryParse(value);
                if (seats == null || seats < 1 || seats > 8) {
                  return 'Enter 1-8 seats';
                }
                return null;
              },
            ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

            SizedBox(height: 16.h),

            // Fuel Type dropdown
            Text(
              AppLocalizations.of(context).fuelType,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 350.ms),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<FuelType>(
                  value: _selectedFuelType,
                  isExpanded: true,
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary,
                  ),
                  items: _fuelTypes.map((fuel) {
                    return DropdownMenuItem(
                      value: fuel,
                      child: Text(
                        fuel.displayName,
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedFuelType = value!);
                  },
                ),
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 350.ms),

            SizedBox(height: 32.h),

            // Continue button
            SizedBox(
              width: double.infinity,
              child: PremiumButton(
                text: 'Save & Continue',
                onPressed: _isLoading ? null : _saveVehicleAndContinue,
                isLoading: _isLoading,
                style: PremiumButtonStyle.primary,
                size: PremiumButtonSize.large,
                trailingIcon: Icons.arrow_forward_rounded,
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 400.ms),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildStripeStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildStepHeader(
            icon: Icons.account_balance_rounded,
            title: AppLocalizations.of(context).setupPayouts,
            subtitle:
                'Connect your bank account to receive payments from your rides.',
          ).animate().fadeIn(duration: 400.ms),

          SizedBox(height: 32.h),

          // Stripe benefits card
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withAlpha(15),
                  AppColors.secondary.withAlpha(10),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.primary.withAlpha(30)),
            ),
            child: Column(
              children: [
                _buildBenefitItem(
                  icon: Icons.security_rounded,
                  title: AppLocalizations.of(context).securePayments,
                  description: 'Powered by Stripe, trusted by millions',
                ),
                SizedBox(height: 16.h),
                _buildBenefitItem(
                  icon: Icons.flash_on_rounded,
                  title: AppLocalizations.of(context).fastTransfers,
                  description: 'Get paid within 2-3 business days',
                ),
                SizedBox(height: 16.h),
                _buildBenefitItem(
                  icon: Icons.receipt_long_rounded,
                  title: AppLocalizations.of(context).easyTracking,
                  description: 'View all your earnings in one place',
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

          SizedBox(height: 32.h),

          // Setup Stripe button
          SizedBox(
            width: double.infinity,
            child: PremiumButton(
              text: 'Connect with Stripe',
              onPressed: _setupStripe,
              style: PremiumButtonStyle.primary,
              size: PremiumButtonSize.large,
              icon: Icons.link_rounded,
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

          SizedBox(height: 16.h),

          // Skip button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _skipStripeForNow,
              child: Text(
                AppLocalizations.of(context).skipForNowILl,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 250.ms),

          SizedBox(height: 16.h),

          // Info note
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.info.withAlpha(15),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.info.withAlpha(30)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.info,
                  size: 20.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).youCanStillOfferRides,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
        ],
      ),
    );
  }

  Widget _buildStepHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(15),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Icon(icon, color: AppColors.primary, size: 32.sp),
        ),
        SizedBox(height: 16.h),
        Text(
          title,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(20),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20.sp),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
