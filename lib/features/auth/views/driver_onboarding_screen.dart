import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/features/vehicles/models/vehicle_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

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
  final _profileFormKey = GlobalKey<FormBuilderState>();

  final List<String> _availableInterests = [
    'Football',
    'Basketball',
    'Gym',
    'Tennis',
    'Running',
    'Cycling',
    'Swimming',
    'Yoga',
    'Hiking',
  ];

  // ── Vehicle form (Step 1) ──────────────────────────────────────────
  final _vehicleFormKey = GlobalKey<FormBuilderState>();

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
    super.dispose();
  }

  // ── Navigation helpers ──────────────────────────────────────────────

  void _nextStep() {
    // Validate the current step before advancing.
    if (_currentStep == 0) {
      if (!_profileFormKey.currentState!.validate()) return;
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
    _profileFormKey.currentState?.patchValue({
      'name': user.displayName,
      'phone': user.phoneNumber ?? '',
      'city': user.city ?? '',
      'bio': user.bio ?? '',
      'gender': user.gender,
      'dob': user.dateOfBirth,
      'interests': user.interests,
    });
  }

  Future<void> _saveProfileAndContinue() async {
    if (!_profileFormKey.currentState!.saveAndValidate()) return;
    final values = _profileFormKey.currentState!.value;

    setState(() => _isLoading = true);

    try {
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser == null) return;

      final updatedUser = currentUser.map(
        rider: (rider) => rider, // Should not reach this in driver flow
        driver: (driver) => driver.copyWith(
          displayName: values['name'],
          phoneNumber: (values['phone'] as String?)?.isEmpty ?? true
              ? null
              : values['phone'],
          city: values['city'],
          bio: (values['bio'] as String?)?.isEmpty ?? true
              ? null
              : values['bio'],
          gender: values['gender'],
          dateOfBirth: values['dob'],
          interests: (values['interests'] as List<dynamic>? ?? [])
              .cast<String>(),
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
    if (!_vehicleFormKey.currentState!.saveAndValidate()) return;
    final values = _vehicleFormKey.currentState!.value;
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
          make: values['make'] as String,
          model: values['model'] as String,
          year: int.parse(values['year'] as String),
          color: values['color'] as String,
          licensePlate: values['license_plate'] as String,
          capacity: int.parse(values['seats'] as String),
          fuelType: values['fuel_type'] as FuelType,
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
      _isProfilePopulated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _populateProfileFields(user);
      });
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
      child: FormBuilder(
        key: _profileFormKey,
        autovalidateMode: AutovalidateMode.disabled,
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
            FormBuilderTextField(
              name: 'name',
              decoration: InputDecoration(
                labelText: l10n.authFullName,
                hintText: l10n.authFullNameHint,
                prefixIcon: Icon(Icons.person_rounded),
              ),
              textInputAction: TextInputAction.next,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(errorText: "Name is required"),
                FormBuilderValidators.minLength(
                  2,
                  errorText: "Name Must be at least 2 characters",
                ),
              ]),
            ).animate().fadeIn(duration: 400.ms, delay: 50.ms),

            SizedBox(height: 16.h),

            // Phone (optional)
            FormBuilderTextField(
              name: 'phone',
              decoration: InputDecoration(
                labelText: l10n.authPhoneOptional,
                hintText: l10n.authPhoneHint,
                prefixIcon: Icon(Icons.phone_rounded),
              ),
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              validator: FormBuilderValidators.conditional(
                (value) => value != null && value.trim().isNotEmpty,
                FormBuilderValidators.phoneNumber(),
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

            SizedBox(height: 16.h),

            // City
            FormBuilderTextField(
              name: 'city',
              decoration: InputDecoration(
                labelText: l10n.driverCityLabel,
                hintText: l10n.driverCityHint,
                prefixIcon: Icon(Icons.location_city_rounded),
              ),
              textInputAction: TextInputAction.next,
              validator: FormBuilderValidators.required(
                errorText: l10n.driverCityLabel,
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 150.ms),

            SizedBox(height: 16.h),

            // About you (optional)
            FormBuilderTextField(
              name: 'bio',
              decoration: InputDecoration(
                labelText: l10n.authAboutYou,
                hintText: l10n.authAboutYouHint,
                prefixIcon: Icon(Icons.info_outline_rounded),
              ),
              maxLines: 3,
              maxLength: 160,
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline,
            ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

            SizedBox(height: 16.h),

            // Gender dropdown
            FormBuilderDropdown<String>(
              name: 'gender',
              decoration: InputDecoration(labelText: l10n.gender),
              items: const [
                DropdownMenuItem(value: 'Male', child: Text('Male')),
                DropdownMenuItem(value: 'Female', child: Text('Female')),
              ],
              validator: FormBuilderValidators.required(
                errorText: l10n.driverGenderRequired,
              ),
            ),
            SizedBox(height: 16.h),

            // Date of birth
            FormBuilderDateTimePicker(
              name: 'dob',
              inputType: InputType.date,
              decoration: InputDecoration(labelText: l10n.authDateOfBirth),
              lastDate: DateTime(
                DateTime.now().year - 18,
                DateTime.now().month,
                DateTime.now().day,
              ),
              firstDate: DateTime(1950),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(errorText: l10n.authDobError),
                (value) {
                  if (value == null) return null;
                  final age = DateTime.now().difference(value).inDays ~/ 365;
                  if (age < 18) return l10n.authDobMinAge;
                  return null;
                },
              ]),
            ),
            SizedBox(height: 20.h),

            // Sports interests
            FormBuilderFilterChips<String>(
              name: 'interests',
              decoration: InputDecoration(labelText: l10n.sportsInterests),
              options: _availableInterests
                  .map((i) => FormBuilderChipOption(value: i))
                  .toList(),
              validator: FormBuilderValidators.minLength(
                1,
                errorText: l10n.driverInterestsRequired,
              ),
              // Add these:
              backgroundColor: AppColors.surfaceVariant,
              selectedColor: AppColors.primary.withAlpha(40),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13.sp,
              ),
              selectedShadowColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
                side: BorderSide(color: AppColors.border),
              ),
              spacing: 4.w,
            ),
            SizedBox(height: 18.h),

            // Terms checkbox
            FormBuilderCheckbox(
              name: 'terms',
              title: Text(l10n.driverTermsLabel),
              validator: FormBuilderValidators.equal(
                true,
                errorText: l10n.driverTermsRequired,
              ),
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
      child: FormBuilder(
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
            FormBuilderTextField(
              name: "make",
              decoration: InputDecoration(
                labelText: 'Make',
                hintText: 'e.g., Toyota, Honda, BMW',
                prefixIcon: Icon(Icons.business_rounded),
              ),
              validator: FormBuilderValidators.required(
                errorText: 'Please enter vehicle make',
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

            SizedBox(height: 16.h),

            // Vehicle Model
            FormBuilderTextField(
              name: "model",
              decoration: InputDecoration(
                labelText: 'Model',
                hintText: 'e.g., Corolla, Civic, 3 Series',
                prefixIcon: Icon(Icons.directions_car_outlined),
              ),
              validator: FormBuilderValidators.required(
                errorText: 'Please enter vehicle model',
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 150.ms),

            SizedBox(height: 16.h),

            // Year and Color row
            Row(
              children: [
                Expanded(
                  child: FormBuilderTextField(
                    name: "year",
                    decoration: InputDecoration(
                      labelText: 'Year',
                      hintText: 'e.g., 2020',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(errorText: 'Required'),
                      FormBuilderValidators.integer(errorText: 'Numbers only'),
                      FormBuilderValidators.between(
                        1990,
                        DateTime.now().year.toDouble(),
                        errorText: 'Invalid year',
                      ),
                    ]),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: FormBuilderTextField(
                    name: "color",
                    decoration: InputDecoration(
                      labelText: 'Color',
                      hintText: 'e.g., White',
                      prefixIcon: Icon(Icons.palette_outlined),
                    ),
                    validator: FormBuilderValidators.required(
                      errorText: 'Required',
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

            SizedBox(height: 16.h),

            // License Plate
            FormBuilderTextField(
              name: "license_plate",
              decoration: InputDecoration(
                labelText: 'License Plate',
                hintText: 'e.g., ABC 123',
                prefixIcon: Icon(Icons.credit_card_rounded),
              ),
              textCapitalization: TextCapitalization.characters,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(
                  errorText: 'Please enter license plate',
                ),
                FormBuilderValidators.licensePlate(),
              ]),
            ).animate().fadeIn(duration: 400.ms, delay: 250.ms),

            SizedBox(height: 16.h),

            // Seats
            FormBuilderTextField(
              name: "seats",
              decoration: InputDecoration(
                labelText: 'Available Seats',
                hintText: '4',
                prefixIcon: Icon(Icons.event_seat_rounded),
              ),
              keyboardType: TextInputType.number,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(
                  errorText: 'Please enter number of seats',
                ),
                FormBuilderValidators.integer(
                  errorText: 'Must be a whole number',
                ),
                FormBuilderValidators.between(
                  1,
                  8,
                  errorText: 'Enter 1–8 seats',
                ),
              ]),
            ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

            SizedBox(height: 16.h),

            // Fuel Type dropdown
            FormBuilderDropdown<FuelType>(
              name: 'fuel_type',
              initialValue: FuelType.gasoline,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).fuelType,
              ),
              items: _fuelTypes
                  .map(
                    (fuel) =>
                        DropdownMenuItem(value: fuel, child: Text(fuel.name)),
                  )
                  .toList(),
            ),
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
