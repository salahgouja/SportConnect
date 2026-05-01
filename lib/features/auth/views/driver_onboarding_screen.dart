import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/address_autocomplete_field.dart';
import 'package:sport_connect/core/widgets/expertise_picker.dart';
import 'package:sport_connect/core/widgets/glass_panel.dart';
import 'package:sport_connect/core/widgets/intl_phone_input.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/auth/view_models/onboarding_view_model.dart';
import 'package:sport_connect/features/vehicles/models/vehicle_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

abstract final class _PF {
  static const name = 'name';
  static const gender = 'gender';
  static const dob = 'dob';
  static const expertise = 'expertise';
  static const terms = 'terms';
}

abstract final class _VF {
  static const make = 'make';
  static const model = 'model';
  static const year = 'year';
  static const color = 'color';
  static const licensePlate = 'license_plate';
  static const seats = 'seats';
  static const fuelType = 'fuel_type';
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

DateTime _adultCutoffDate({int years = 18}) {
  final today = DateTime.now();
  return DateTime(today.year - years, today.month, today.day);
}

DateTime _hiddenDatePickerCurrentDate() => DateTime(1900);

bool _isAtLeastAge(DateTime value, {int years = 18}) {
  final birthDate = _dateOnly(value);
  final cutoff = _adultCutoffDate(years: years);
  return !birthDate.isAfter(cutoff);
}

String? _normalizeGenderValue(String? value) {
  switch (value?.trim().toLowerCase()) {
    case 'male':
      return 'Male';
    case 'female':
      return 'Female';
    default:
      return null;
  }
}

class DriverOnboardingScreen extends ConsumerStatefulWidget {
  const DriverOnboardingScreen({super.key});

  @override
  ConsumerState<DriverOnboardingScreen> createState() =>
      _DriverOnboardingScreenState();
}

class _DriverOnboardingScreenState
    extends ConsumerState<DriverOnboardingScreen> {
  // ── Profile form (Step 0) ────────────────────────────────────────────
  final _profileForm = FormGroup({
    _PF.name: FormControl<String>(
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
    _PF.gender: FormControl<String>(validators: [Validators.required]),
    _PF.dob: FormControl<DateTime>(
      validators: [
        Validators.required,
        Validators.delegate((control) {
          final value = control.value as DateTime?;
          if (value == null) return null;
          if (!_isAtLeastAge(value)) return {'minAge': true};
          return null;
        }),
      ],
    ),
    _PF.expertise: FormControl<Expertise>(
      value: Expertise.rookie,
      validators: [Validators.required],
    ),
    _PF.terms: FormControl<bool>(
      value: false,
      validators: [Validators.requiredTrue],
    ),
  });

  final _phoneKey = GlobalKey<IntlPhoneInputState>();
  final _addressKey = GlobalKey<AddressAutocompleteFieldState>();

  // ── Vehicle form (Step 1) ───────────────────────────────────────────
  final _vehicleForm = FormGroup({
    _VF.make: FormControl<String>(validators: [Validators.required]),
    _VF.model: FormControl<String>(validators: [Validators.required]),
    _VF.year: FormControl<String>(
      validators: [
        Validators.required,
        Validators.delegate((control) {
          final value = control.value as String?;
          if (value == null || value.trim().isEmpty) return null;
          final year = int.tryParse(value.trim());
          if (year == null) return {'vehicleYear': 'Please enter a valid year'};
          if (year < 1980) return {'vehicleYear': 'Vehicle is too old'};
          if (year > DateTime.now().year) {
            return {'vehicleYear': 'Invalid year'};
          }
          return null;
        }),
      ],
    ),
    _VF.color: FormControl<String>(validators: [Validators.required]),
    _VF.licensePlate: FormControl<String>(
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
    _VF.seats: FormControl<String>(
      validators: [
        Validators.required,
        Validators.delegate((control) {
          final raw = control.value as String?;
          if (raw == null || raw.isEmpty) return null;
          final parsed = int.tryParse(raw);
          if (parsed == null) {
            return {'seats': 'Please select number of seats'};
          }
          if (parsed < 1) return {'seats': 'Minimum 1 seat'};
          if (parsed > 8) return {'seats': 'Maximum 8 seats'};
          return null;
        }),
      ],
    ),
    _VF.fuelType: FormControl<FuelType>(value: FuelType.gasoline),
  });

  static const List<FuelType> _fuelTypes = [
    FuelType.gasoline,
    FuelType.diesel,
    FuelType.electric,
    FuelType.hybrid,
    FuelType.pluginHybrid,
    FuelType.hydrogen,
    FuelType.other,
  ];

  static const List<int> _seatOptions = [1, 2, 3, 4, 5, 6, 7, 8];

  List<String> get _vehicleYears {
    final currentYear = DateTime.now().year;
    return List.generate(
      currentYear - 1980 + 1,
      (index) => (currentYear - index).toString(),
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final user = ref.read(currentUserProvider).value;
      if (user == null) return;

      final skipProfileStep = _skipProfileStep(context);
      final notifier = ref.read(onboardingViewModelProvider.notifier);
      final state = ref.read(onboardingViewModelProvider);

      if (!state.driverProfilePopulated) {
        notifier.markDriverProfilePopulated();
        _populateProfileFields(user);
      }

      if (skipProfileStep && state.driverCurrentStep == 0) {
        notifier.setDriverCurrentStep(1);
      }
    });
  }

  bool _skipProfileStep(BuildContext context) {
    final state = GoRouterState.of(context);
    return state.uri.queryParameters['skipProfile'] == 'true';
  }

  /// Computes the correct effective step, accounting for:
  /// - skipProfile flag (profile already filled → skip to vehicle)
  /// - driver already having vehicles (refresh at stripe step → jump to stripe)
  int _effectiveStep(
    OnboardingState vmState,
    bool skipProfileStep,
    UserModel? currentUser,
  ) {
    final driver = currentUser is DriverModel ? currentUser : null;

    // If driver already has vehicles, they must be on the stripe step.
    if (driver != null && driver.vehicleIds.isNotEmpty) {
      // Sync the VM step so back-button logic is also correct.
      if (vmState.driverCurrentStep < 2) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ref
                .read(onboardingViewModelProvider.notifier)
                .setDriverCurrentStep(2);
          }
        });
        return 2;
      }
      return vmState.driverCurrentStep;
    }

    // Profile already filled but no vehicles yet → vehicle step.
    if (skipProfileStep && vmState.driverCurrentStep == 0) {
      return 1;
    }

    return vmState.driverCurrentStep;
  }

  // ── Navigation helpers ──────────────────────────────────────────────

  void _nextStep(OnboardingState vmState) {
    if (vmState.driverCurrentStep == 0) {
      _profileForm.markAllAsTouched();
      if (!_profileForm.valid) return;

      final phoneError = _phoneKey.currentState?.validate();
      if (phoneError != null) return;

      final addressError = _addressKey.currentState?.validate();
      if (addressError != null) return;
    } else if (vmState.driverCurrentStep == 1) {
      _vehicleForm.markAllAsTouched();
      if (!_vehicleForm.valid) return;
    }

    if (vmState.driverCurrentStep < 2) {
      ref.read(onboardingViewModelProvider.notifier).advanceDriverStep();
    }
  }

  void _previousStep(OnboardingState vmState, {required bool skipProfileStep}) {
    final currentUser = ref.read(currentUserProvider).value;
    final effectiveStep = _effectiveStep(vmState, skipProfileStep, currentUser);

    if (skipProfileStep && effectiveStep <= 1) {
      context.go(AppRoutes.roleSelection.path);
      return;
    }

    if (effectiveStep > 0) {
      ref.read(onboardingViewModelProvider.notifier).retreatDriverStep();
    }
  }

  // ── Profile helpers (Step 0) ───────────────────────────────────────

  void _populateProfileFields(UserModel user) {
    final existingName = _profileForm.control(_PF.name).value as String?;
    final existingGender = _profileForm.control(_PF.gender).value as String?;
    final existingDob = _profileForm.control(_PF.dob).value as DateTime?;
    final patchedName = (user.username).trim();
    final patchedGender = switch (user) {
      DriverModel(:final gender) => _normalizeGenderValue(gender),
      RiderModel(:final gender) => _normalizeGenderValue(gender),
      _ => null,
    };
    final patchedDob = switch (user) {
      DriverModel(:final dateOfBirth) => dateOfBirth,
      RiderModel(:final dateOfBirth) => dateOfBirth,
      _ => null,
    };

    _profileForm.patchValue({
      _PF.name: patchedName.isNotEmpty ? patchedName : existingName,
      _PF.gender: patchedGender ?? existingGender,
      _PF.dob: patchedDob ?? existingDob,
      _PF.expertise: user.expertise,
    });
  }

  Future<void> _saveProfileAndContinue() async {
    _profileForm.markAllAsTouched();
    if (!_profileForm.valid) return;

    final phoneError = _phoneKey.currentState?.validate();
    if (phoneError != null) return;

    final addressError = _addressKey.currentState?.validate();
    if (addressError != null) return;

    final values = _profileForm.value;
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;

    final vmState = ref.read(onboardingViewModelProvider);
    final dateOfBirth = values[_PF.dob] as DateTime?;

    final profileUpdates = <String, dynamic>{
      'username': (values[_PF.name] as String? ?? '').trim(),
      'phoneNumber': (vmState.driverPhoneNumber?.isNotEmpty ?? false)
          ? vmState.driverPhoneNumber
          : null,
      'address': _addressKey.currentState?.text.trim() ?? '',
      'gender': values[_PF.gender] as String?,
      'dateOfBirth': dateOfBirth == null ? null : _dateOnly(dateOfBirth),
      'expertise':
          ((values[_PF.expertise] as Expertise?) ?? Expertise.rookie).name,
    };

    await ref
        .read(onboardingViewModelProvider.notifier)
        .saveDriverProfile(currentUser.uid, profileUpdates);
  }

  // ── Vehicle + Stripe helpers ───────────────────────────────────────

  Future<void> _saveVehicleAndContinue() async {
    _vehicleForm.markAllAsTouched();
    if (!_vehicleForm.valid) return;
    final values = _vehicleForm.value;

    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;

    final vehicle = VehicleModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      ownerId: currentUser.uid,
      ownerName: currentUser.username,
      ownerPhotoUrl: currentUser.photoUrl,
      make: (values[_VF.make] as String?)!,
      model: (values[_VF.model] as String?)!,
      year: int.parse((values[_VF.year] as String?)!),
      color: (values[_VF.color] as String?)!,
      licensePlate: (values[_VF.licensePlate] as String?)!,
      capacity: int.parse((values[_VF.seats] as String?)!),
      fuelType: (values[_VF.fuelType] as FuelType?)!,
      isActive: true,
    );

    await ref
        .read(onboardingViewModelProvider.notifier)
        .saveVehicle(currentUser.uid, vehicle);
  }

  Future<void> _setupStripe() async {
    await ref
        .read(onboardingViewModelProvider.notifier)
        .finalizeDriverSetupForStripe();
  }

  @override
  void dispose() {
    _profileForm.dispose();
    _vehicleForm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider).value;
    final vmState = ref.watch(onboardingViewModelProvider);
    final skipProfileStep = _skipProfileStep(context);
    final effectiveStep = _effectiveStep(vmState, skipProfileStep, currentUser);

    ref.listen(currentUserProvider, (prev, next) {
      final user = next.value;
      if (user == null) return;

      final notifier = ref.read(onboardingViewModelProvider.notifier);
      final state = ref.read(onboardingViewModelProvider);

      if (!state.driverProfilePopulated) {
        notifier.markDriverProfilePopulated();
        _populateProfileFields(user);
      } else {
        // Keep name/gender/dob in sync if user data arrives slightly later.
        _populateProfileFields(user);
      }

      if (skipProfileStep && state.driverCurrentStep == 0) {
        notifier.setDriverCurrentStep(1);
      }
    });

    ref.listen(onboardingViewModelProvider, (prev, next) {
      final action = next.completedAction;
      if (action != null && action != prev?.completedAction) {
        switch (action) {
          case OnboardingAction.profileSaved:
          case OnboardingAction.vehicleSaved:
            _nextStep(next);
            break;
          case OnboardingAction.finalizedStripe:
            context.go(AppRoutes.driverStripeOnboarding.path);
            break;
          case OnboardingAction.finalized:
            context.go(AppRoutes.driverHome.path);
            break;
          default:
            break;
        }
      }

      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        AdaptiveSnackBar.show(
          context,
          message: next.errorMessage!,
          type: AdaptiveSnackBarType.error,
        );
      }
    });

    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        leading: effectiveStep > 0
            ? IconButton(
                tooltip: AppLocalizations.of(context).previousStepTooltip,
                onPressed: () =>
                    _previousStep(vmState, skipProfileStep: skipProfileStep),
                icon: Icon(
                  Icons.adaptive.arrow_back_rounded,
                  color: AppColors.textPrimary,
                  size: 20.sp,
                ),
              )
            : IconButton(
                tooltip: AppLocalizations.of(context).goBackTooltip,
                onPressed: () => context.go(AppRoutes.roleSelection.path),
                icon: Icon(
                  Icons.adaptive.arrow_back_rounded,
                  color: AppColors.textPrimary,
                  size: 20.sp,
                ),
              ),
        title: AppLocalizations.of(context).driverSetup,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildProgressIndicator(
              vmState,
              skipProfileStep: skipProfileStep,
              effectiveStep: effectiveStep,
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0.04, 0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOut,
                          ),
                        ),
                    child: child,
                  ),
                ),
                child: KeyedSubtree(
                  key: ValueKey(effectiveStep),
                  child: switch (effectiveStep) {
                    0 => _buildProfileStep(vmState, currentUser),
                    1 => _buildVehicleStep(vmState),
                    _ => _buildStripeStep(vmState),
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Step progress bar ──────────────────────────────────────────────

  Widget _buildProgressIndicator(
    OnboardingState vmState, {
    required bool skipProfileStep,
    required int effectiveStep,
  }) {
    final steps = skipProfileStep
        ? [
            (
              AppLocalizations.of(context).vehicle,
              Icons.directions_car_outlined,
              1,
            ),
            (
              AppLocalizations.of(context).payouts,
              Icons.account_balance_outlined,
              2,
            ),
          ]
        : [
            (
              AppLocalizations.of(context).navProfile,
              Icons.person_outline_rounded,
              0,
            ),
            (
              AppLocalizations.of(context).vehicle,
              Icons.directions_car_outlined,
              1,
            ),
            (
              AppLocalizations.of(context).payouts,
              Icons.account_balance_outlined,
              2,
            ),
          ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      child: Column(
        children: [
          Row(
            children: [
              for (int i = 0; i < steps.length; i++) ...[
                _buildStepIndicator(
                  steps[i].$3,
                  steps[i].$1,
                  steps[i].$2,
                  effectiveStep,
                ),
                if (i < steps.length - 1)
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      height: 2,
                      margin: EdgeInsets.symmetric(horizontal: 6.w),
                      decoration: BoxDecoration(
                        gradient: effectiveStep > steps[i].$3
                            ? const LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.primaryLight,
                                ],
                              )
                            : null,
                        color: effectiveStep > steps[i].$3
                            ? null
                            : AppColors.border,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _stepSubtitle(effectiveStep),
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                skipProfileStep
                    ? 'Step ${effectiveStep - 1 + 1} of 2'
                    : 'Step ${effectiveStep + 1} of 3',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _stepSubtitle(int step) => switch (step) {
    0 => 'Tell us about yourself',
    1 => 'Add your vehicle details',
    _ => 'Connect your payout account',
  };

  Widget _buildStepIndicator(
    int step,
    String label,
    IconData icon,
    int currentStep,
  ) {
    final isCompleted = currentStep > step;
    final isActive = currentStep >= step;
    final isCurrent = currentStep == step;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isCurrent ? 44.w : 40.w,
          height: isCurrent ? 44.w : 40.w,
          decoration: BoxDecoration(
            gradient: isActive
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryLight, AppColors.primary],
                  )
                : null,
            color: isActive ? null : AppColors.surfaceVariant,
            shape: BoxShape.circle,
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: isCompleted
                ? Icon(Icons.check_rounded, color: Colors.white, size: 18.sp)
                : Icon(
                    icon,
                    color: isActive ? Colors.white : AppColors.textTertiary,
                    size: 18.sp,
                  ),
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
            color: isActive ? AppColors.textPrimary : AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  // ── Section label helper ──────────────────────────────────────────

  Widget _sectionLabel(String text) => Padding(
    padding: EdgeInsets.only(bottom: 10.h, top: 4.h),
    child: Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
        color: AppColors.textSecondary,
      ),
    ),
  );

  // ── Step 0: Profile ────────────────────────────────────────────────

  Widget _buildProfileStep(OnboardingState vmState, UserModel? currentUser) {
    final l10n = AppLocalizations.of(context);
    final displayName = (currentUser?.username ?? '').trim();
    final photoUrl = currentUser?.photoUrl;
    final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;
    final needsManualName = displayName.isEmpty;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: ReactiveForm(
        formGroup: _profileForm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header panel ─────────────────────────────────────────────
            GlassPanel(
              padding: EdgeInsets.all(16.w),
              color: AppColors.surface.withValues(alpha: 0.62),
              borderColor: AppColors.primary.withValues(alpha: 0.2),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Icon(
                      Icons.drive_eta_rounded,
                      color: AppColors.primary,
                      size: 28.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.driverProfileTitle,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          l10n.driverProfileSubtitle,
                          style: TextStyle(
                            fontSize: 12.sp,
                            height: 1.4,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            SizedBox(height: 24.h),

            // ── Section: Identity ────────────────────────────────────────
            _sectionLabel('Your Identity'),

            if (!needsManualName) ...[
              _buildNameDisplay(displayName, hasPhoto, photoUrl),
            ] else ...[
              ReactiveTextField<String>(
                    formControlName: _PF.name,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: l10n.authFullName,
                      hintText: 'Enter your full name',
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                      helperText: 'We could not read your name from sign-in.',
                    ),
                    validationMessages: {
                      ValidationMessage.required: (_) =>
                          'Please enter your name',
                      ValidationMessage.minLength: (_) =>
                          'Name must be at least 2 characters',
                      ValidationMessage.maxLength: (_) =>
                          'Name must be at most 60 characters',
                      'name': (error) => error as String,
                    },
                  )
                  .animate()
                  .fadeIn(duration: 300.ms, delay: 30.ms)
                  .slideY(
                    begin: 0.04,
                    end: 0,
                  ),
            ],

            SizedBox(height: 20.h),

            // ── Section: Personal Details ────────────────────────────────
            _sectionLabel('Personal Details'),

            Row(
              children: [
                Expanded(
                  child:
                      ReactiveDropdownField<String>(
                            formControlName: _PF.gender,
                            decoration: InputDecoration(labelText: l10n.gender),
                            items: [
                              DropdownMenuItem(
                                value: 'Male',
                                child: Text(l10n.genderMale),
                              ),
                              DropdownMenuItem(
                                value: 'Female',
                                child: Text(l10n.genderFemale),
                              ),
                            ],
                            validationMessages: {
                              ValidationMessage.required: (_) =>
                                  l10n.driverGenderRequired,
                            },
                          )
                          .animate()
                          .fadeIn(duration: 300.ms, delay: 60.ms)
                          .slideY(begin: 0.04, end: 0),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child:
                      ReactiveDatePicker<DateTime>(
                            formControlName: _PF.dob,
                            firstDate: DateTime(1950),
                            lastDate: _adultCutoffDate(),
                            currentDate: _hiddenDatePickerCurrentDate(),
                            builder: (context, picker, child) {
                              final value = picker.value;
                              final control = picker.control;
                              final showError =
                                  control.touched && control.invalid;
                              String? errorText;

                              if (showError) {
                                if (control.hasError(
                                  ValidationMessage.required,
                                )) {
                                  errorText = l10n.authDobError;
                                } else if (control.hasError('minAge')) {
                                  errorText = l10n.authDobMinAge;
                                }
                              }

                              return InkWell(
                                onTap: picker.showPicker,
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: l10n.authDateOfBirth,
                                    prefixIcon: const Icon(
                                      Icons.calendar_month_rounded,
                                    ),
                                    suffixIcon: const Icon(
                                      Icons.arrow_drop_down_rounded,
                                      color: AppColors.textSecondary,
                                    ),
                                    errorText: errorText,
                                  ),
                                  child: Text(
                                    value != null
                                        ? '${value.day}/${value.month}/${value.year}'
                                        : 'DD/MM/YYYY',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                    style: TextStyle(
                                      color: value != null
                                          ? AppColors.textPrimary
                                          : AppColors.textSecondary,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                          .animate()
                          .fadeIn(duration: 300.ms, delay: 120.ms)
                          .slideY(begin: 0.04, end: 0),
                ),
              ],
            ),

            SizedBox(height: 20.h),

            // ── Section: Contact & Address ──────────────────────────────
            _sectionLabel('Contact & Address'),

            IntlPhoneInput(
                  key: _phoneKey,
                  label: l10n.authPhoneOptional,
                  hint: l10n.authPhoneHint,
                  accentColor: AppColors.primary,
                  fillColor: AppColors.background,
                  onChanged: (phone) => ref
                      .read(onboardingViewModelProvider.notifier)
                      .setDriverDraftContact(
                        phoneNumber: phone.isValid ? phone.fullNumber : null,
                      ),
                )
                .animate()
                .fadeIn(duration: 300.ms, delay: 180.ms)
                .slideY(
                  begin: 0.04,
                  end: 0,
                ),

            SizedBox(height: 16.h),

            // REPLACE the existing AddressAutocompleteField block with this
            AddressAutocompleteField(
                  key: _addressKey,
                  label: 'Address',
                  hint: 'Search your address...',
                  accentColor: AppColors.primary,
                  fillColor: AppColors.background,
                  onSelected: (_) {},
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Address is required';
                    }
                    return null;
                  },
                )
                .animate()
                .fadeIn(duration: 300.ms, delay: 240.ms)
                .slideY(
                  begin: 0.04,
                  end: 0,
                ),

            SizedBox(height: 20.h),

            // ── Section: Driving Details ─────────────────────────────────
            _sectionLabel('Driving Details'),

            ReactiveExpertisePicker(
                  formControlName: _PF.expertise,
                  label: l10n.expertiseLevel,
                  accent: AppColors.primary,
                  textColor: AppColors.textPrimary,
                  cardBg: AppColors.surface,
                  validationMessages: {
                    ValidationMessage.required: (_) =>
                        l10n.expertiseLevelRequired,
                  },
                )
                .animate()
                .fadeIn(duration: 300.ms, delay: 300.ms)
                .slideY(
                  begin: 0.04,
                  end: 0,
                ),

            SizedBox(height: 20.h),

            // ── Terms ────────────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: ReactiveCheckboxListTile(
                formControlName: _PF.terms,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AppColors.primary,
                title: Text.rich(
                  TextSpan(
                    text: 'I agree to the ',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                    ),
                    children: [
                      TextSpan(
                        text: 'Terms & Conditions',
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => context.push(AppRoutes.terms.path),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 300.ms, delay: 360.ms),

            ReactiveFormConsumer(
              builder: (context, form, _) {
                final ctrl = form.control(_PF.terms);
                final showError = ctrl.touched && ctrl.invalid;

                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: showError
                      ? Padding(
                          key: const ValueKey('terms-error'),
                          padding: EdgeInsets.only(top: 6.h, left: 14.w),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                size: 14.sp,
                                color: AppColors.error,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                'You must accept the terms to continue.',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(key: ValueKey('terms-ok')),
                );
              },
            ),

            SizedBox(height: 28.h),

            ReactiveFormConsumer(
              builder: (context, form, _) {
                final isFormReady = form.valid;
                final currentVmState = ref.watch(onboardingViewModelProvider);

                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: isFormReady ? 1.0 : 0.55,
                  child: SizedBox(
                    width: double.infinity,
                    child: PremiumButton(
                      text: currentVmState.isLoading
                          ? 'Saving...'
                          : l10n.driverSaveAndContinue,
                      onPressed: currentVmState.isLoading
                          ? null
                          : _saveProfileAndContinue,
                      isLoading: currentVmState.isLoading,
                      size: PremiumButtonSize.large,
                      style: isFormReady
                          ? PremiumButtonStyle.success
                          : PremiumButtonStyle.primary,
                      trailingIcon: Icons.adaptive.arrow_forward_rounded,
                    ),
                  ),
                );
              },
            ).animate().fadeIn(duration: 300.ms, delay: 420.ms),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  /// Displays the user's name from Google/Apple sign-in as a read-only card.
  Widget _buildNameDisplay(String name, bool hasPhoto, String? photoUrl) {
    return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              if (hasPhoto)
                ClipRRect(
                  borderRadius: BorderRadius.circular(22.r),
                  child: Image.network(
                    photoUrl!,
                    width: 44.w,
                    height: 44.w,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, st) => _defaultAvatar(name),
                  ),
                )
              else
                _defaultAvatar(name),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isNotEmpty ? name : 'Your Name',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          size: 12.sp,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'From your sign-in account',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.lock_outline_rounded,
                size: 16.sp,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms, delay: 30.ms)
        .slideY(
          begin: 0.04,
          end: 0,
        );
  }

  Widget _defaultAvatar(String name) {
    final initials = name.trim().isNotEmpty
        ? name
              .trim()
              .split(' ')
              .map((w) => w.isNotEmpty ? w[0] : '')
              .take(2)
              .join()
              .toUpperCase()
        : '?';

    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryLight, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ── Step 1: Vehicle ─────────────────────────────────────────────────

  Widget _buildVehicleStep(OnboardingState vmState) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: ReactiveForm(
        formGroup: _vehicleForm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header panel ──────────────────────────────────────────────
            GlassPanel(
              padding: EdgeInsets.all(16.w),
              color: AppColors.surface.withValues(alpha: 0.62),
              borderColor: AppColors.primary.withValues(alpha: 0.2),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Icon(
                      Icons.directions_car_rounded,
                      color: AppColors.primary,
                      size: 28.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.addYourVehicle,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          l10n.driverVehicleStepSubtitle,
                          style: TextStyle(
                            fontSize: 12.sp,
                            height: 1.4,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            SizedBox(height: 24.h),

            // ── Section: Vehicle Identity ────────────────────────────────
            _sectionLabel('Vehicle Identity'),

            ReactiveTextField<String>(
                  formControlName: _VF.make,
                  decoration: InputDecoration(
                    labelText: l10n.make,
                    hintText: l10n.vehicleMakeHint,
                    prefixIcon: const Icon(Icons.business_rounded),
                  ),
                  validationMessages: {
                    ValidationMessage.required: (_) =>
                        l10n.pleaseEnterVehicleMake,
                  },
                )
                .animate()
                .fadeIn(duration: 300.ms, delay: 60.ms)
                .slideY(
                  begin: 0.04,
                  end: 0,
                ),

            SizedBox(height: 16.h),

            ReactiveTextField<String>(
                  formControlName: _VF.model,
                  decoration: InputDecoration(
                    labelText: l10n.model,
                    hintText: l10n.vehicleModelHint,
                    prefixIcon: const Icon(Icons.directions_car_outlined),
                  ),
                  validationMessages: {
                    ValidationMessage.required: (_) =>
                        l10n.pleaseEnterVehicleModel,
                  },
                )
                .animate()
                .fadeIn(duration: 300.ms, delay: 120.ms)
                .slideY(
                  begin: 0.04,
                  end: 0,
                ),

            SizedBox(height: 16.h),

            Row(
                  children: [
                    Expanded(
                      child: ReactiveDropdownField<String>(
                        formControlName: _VF.year,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: l10n.year,
                          prefixIcon: const Icon(Icons.calendar_today_outlined),
                        ),
                        items: _vehicleYears
                            .map(
                              (year) => DropdownMenuItem(
                                value: year,
                                child: Text(year),
                              ),
                            )
                            .toList(),
                        validationMessages: {
                          ValidationMessage.required: (_) => l10n.requiredField,
                          'vehicleYear': (error) => error as String,
                        },
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ReactiveTextField<String>(
                        formControlName: _VF.color,
                        decoration: InputDecoration(
                          labelText: l10n.color,
                          hintText: l10n.vehicleColorHint,
                          prefixIcon: const Icon(Icons.palette_outlined),
                        ),
                        validationMessages: {
                          ValidationMessage.required: (_) => l10n.requiredField,
                        },
                      ),
                    ),
                  ],
                )
                .animate()
                .fadeIn(duration: 300.ms, delay: 180.ms)
                .slideY(
                  begin: 0.04,
                  end: 0,
                ),

            SizedBox(height: 20.h),

            // ── Section: Registration ────────────────────────────────────
            _sectionLabel('Registration'),

            ReactiveTextField<String>(
                  formControlName: _VF.licensePlate,
                  decoration: InputDecoration(
                    labelText: l10n.licensePlate,
                    hintText: l10n.licensePlateHint,
                    prefixIcon: const Icon(Icons.credit_card_rounded),
                    helperText: l10n.licensePlateHelperText,
                  ),
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[A-Za-z0-9\-\s]'),
                    ),
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      return newValue.copyWith(
                        text: newValue.text.toUpperCase(),
                        selection: newValue.selection,
                      );
                    }),
                  ],
                  validationMessages: {
                    ValidationMessage.required: (_) =>
                        l10n.pleaseEnterLicensePlate,
                    'licensePlate': (error) => error as String,
                  },
                )
                .animate()
                .fadeIn(duration: 300.ms, delay: 240.ms)
                .slideY(begin: 0.04, end: 0),

            SizedBox(height: 20.h),

            // ── Section: Capacity ────────────────────────────────────────
            _sectionLabel('Capacity & Fuel'),

            _buildSeatSelector()
                .animate()
                .fadeIn(duration: 300.ms, delay: 300.ms)
                .slideY(begin: 0.04, end: 0),
            SizedBox(height: 16.h),

            ReactiveDropdownField<FuelType>(
                  formControlName: _VF.fuelType,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l10n.fuelType,
                    prefixIcon: const Icon(Icons.local_gas_station_rounded),
                  ),
                  items: _fuelTypes
                      .map(
                        (fuel) => DropdownMenuItem(
                          value: fuel,
                          child: Text(
                            fuel.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                )
                .animate()
                .fadeIn(duration: 300.ms, delay: 340.ms)
                .slideY(begin: 0.04, end: 0),

            SizedBox(height: 32.h),

            ReactiveFormConsumer(
              builder: (context, form, _) {
                final isFormReady = form.valid;
                final currentVmState = ref.watch(onboardingViewModelProvider);

                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: isFormReady ? 1.0 : 0.55,
                  child: SizedBox(
                    width: double.infinity,
                    child: PremiumButton(
                      text: currentVmState.isLoading
                          ? 'Saving...'
                          : l10n.driverSaveAndContinue,
                      onPressed: currentVmState.isLoading
                          ? null
                          : _saveVehicleAndContinue,
                      isLoading: currentVmState.isLoading,
                      size: PremiumButtonSize.large,
                      style: isFormReady
                          ? PremiumButtonStyle.success
                          : PremiumButtonStyle.primary,
                      trailingIcon: Icons.adaptive.arrow_forward_rounded,
                    ),
                  ),
                );
              },
            ).animate().fadeIn(duration: 300.ms, delay: 400.ms),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  // ── Step 2: Stripe payouts ─────────────────────────────────────────

  Widget _buildStripeStep(OnboardingState vmState) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header panel ───────────────────────────────────────────────
          GlassPanel(
            padding: EdgeInsets.all(16.w),
            color: AppColors.surface.withValues(alpha: 0.62),
            borderColor: AppColors.primary.withValues(alpha: 0.2),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(
                    Icons.account_balance_rounded,
                    color: AppColors.primary,
                    size: 28.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.setupPayouts,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        l10n.driverStripeStepSubtitle,
                        style: TextStyle(
                          fontSize: 12.sp,
                          height: 1.4,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),

          SizedBox(height: 24.h),

          _sectionLabel('Why connect payouts?'),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.06),
                  AppColors.secondary.withValues(alpha: 0.04),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              children: [
                _buildBenefitItem(
                  icon: Icons.security_rounded,
                  title: l10n.securePayments,
                  description: l10n.stripePoweredByMillions,
                  delay: 60,
                ),
                Divider(height: 1, color: AppColors.divider),
                _buildBenefitItem(
                  icon: Icons.flash_on_rounded,
                  title: l10n.fastTransfers,
                  description: l10n.stripeFastTransfersDesc,
                  delay: 120,
                ),
                Divider(height: 1, color: AppColors.divider),
                _buildBenefitItem(
                  icon: Icons.receipt_long_rounded,
                  title: l10n.easyTracking,
                  description: l10n.stripeEarningsDesc,
                  delay: 180,
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

          SizedBox(height: 32.h),

          SizedBox(
            width: double.infinity,
            child: PremiumButton(
              text: l10n.connectWithStripe,
              onPressed: vmState.isLoading ? null : _setupStripe,
              isLoading: vmState.isLoading,
              size: PremiumButtonSize.large,
              style: PremiumButtonStyle.success,
              icon: Icons.link_rounded,
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String description,
    int delay = 0,
  }) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
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
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  description,
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

  Widget _buildSeatSelector() {
    final l10n = AppLocalizations.of(context);

    return ReactiveValueListenableBuilder<String>(
      formControlName: _VF.seats,
      builder: (context, control, child) {
        final selected = int.tryParse(control.value ?? '') ?? 4;
        final hasError = control.touched && control.invalid;

        void updateSeats(int value) {
          final clamped = value.clamp(1, 8);
          control.updateValue(clamped.toString());
          control.markAsTouched();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.availableSeats,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: hasError ? AppColors.error : AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 10.h),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: hasError ? AppColors.error : AppColors.border,
                  width: hasError ? 1.4 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42.w,
                    height: 42.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.event_seat_rounded,
                      color: AppColors.primary,
                      size: 22.sp,
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Text(
                      '$selected seat${selected == 1 ? '' : 's'} available',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  _SeatCountButton(
                    icon: Icons.remove_rounded,
                    enabled: selected > 1,
                    onTap: () => updateSeats(selected - 1),
                  ),
                  SizedBox(width: 10.w),
                  SizedBox(
                    width: 32.w,
                    child: Text(
                      '$selected',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  _SeatCountButton(
                    icon: Icons.add_rounded,
                    enabled: selected < 8,
                    onTap: () => updateSeats(selected + 1),
                  ),
                ],
              ),
            ),
            if (hasError) ...[
              SizedBox(height: 6.h),
              Text(
                l10n.pleaseEnterNumberOfSeats,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.error,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _SeatCountButton extends StatelessWidget {
  const _SeatCountButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled
          ? AppColors.primary.withValues(alpha: 0.1)
          : AppColors.border.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(10.r),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(10.r),
        child: SizedBox(
          width: 36.w,
          height: 36.w,
          child: Icon(
            icon,
            size: 20.sp,
            color: enabled ? AppColors.primary : AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}
