import 'dart:io';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:sport_connect/core/utils/user_facing_error.dart';
import 'package:sport_connect/core/widgets/address_autocomplete_field.dart';
import 'package:sport_connect/core/widgets/dob_picker.dart';
import 'package:sport_connect/core/widgets/expertise_picker.dart';
import 'package:sport_connect/core/widgets/gender_segmented_field.dart';
import 'package:sport_connect/core/widgets/glass_panel.dart';
import 'package:sport_connect/core/widgets/intl_phone_input.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';
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

String _fuelTypeLabel(FuelType fuel) {
  return switch (fuel) {
    FuelType.gasoline => 'Gasoline',
    FuelType.diesel => 'Diesel',
    FuelType.electric => 'Electric',
    FuelType.hybrid => 'Hybrid',
    FuelType.pluginHybrid => 'Plug-in hybrid',
    FuelType.hydrogen => 'Hydrogen',
    FuelType.other => 'Other',
  };
}

IconData _fuelTypeIcon(FuelType fuel) {
  return switch (fuel) {
    FuelType.gasoline => Icons.local_gas_station_rounded,
    FuelType.diesel => Icons.local_gas_station_outlined,
    FuelType.electric => Icons.electric_car_rounded,
    FuelType.hybrid => Icons.energy_savings_leaf_rounded,
    FuelType.pluginHybrid => Icons.electrical_services_rounded,
    FuelType.hydrogen => Icons.water_drop_rounded,
    FuelType.other => Icons.more_horiz_rounded,
  };
}

String? _reactiveErrorText(
  AbstractControl<dynamic> control,
  Map<String, String Function(Object)>? validationMessages,
) {
  if (!(control.touched && control.invalid)) return null;
  if (control.errors.isEmpty) return null;

  final key = control.errors.keys.first;
  final error = control.errors[key];
  final builder = validationMessages?[key];

  if (builder != null) return builder((error ?? key) as Object);
  if (error is String) return error;
  return 'Invalid value';
}

class _VehicleColorOption {
  const _VehicleColorOption({
    required this.label,
    required this.color,
    this.aliases = const [],
  });

  final String label;
  final Color color;
  final List<String> aliases;
}

const List<_VehicleColorOption> _vehicleColorOptions = [
  _VehicleColorOption(
    label: 'Black',
    color: Color(0xFF111827),
    aliases: ['black', 'noir'],
  ),
  _VehicleColorOption(
    label: 'White',
    color: Color(0xFFF8FAFC),
    aliases: ['white', 'blanc', 'pearl'],
  ),
  _VehicleColorOption(
    label: 'Grey',
    color: Color(0xFF6B7280),
    aliases: ['grey', 'gray', 'gris', 'anthracite'],
  ),
  _VehicleColorOption(
    label: 'Silver',
    color: Color(0xFFCBD5E1),
    aliases: ['silver', 'argent'],
  ),
  _VehicleColorOption(
    label: 'Blue',
    color: Color(0xFF2563EB),
    aliases: ['blue', 'bleu', 'navy', 'midnight'],
  ),
  _VehicleColorOption(
    label: 'Red',
    color: Color(0xFFDC2626),
    aliases: ['red', 'rouge', 'bordeaux', 'burgundy'],
  ),
  _VehicleColorOption(
    label: 'Green',
    color: Color(0xFF16A34A),
    aliases: ['green', 'vert'],
  ),
  _VehicleColorOption(
    label: 'Beige / Brown',
    color: Color(0xFF92400E),
    aliases: ['brown', 'marron', 'bronze', 'champagne', 'beige'],
  ),
];

String _normalizeVehicleColorText(String? raw) {
  return (raw ?? '')
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-zàâäéèêëîïôöùûüç\s-]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ');
}

_VehicleColorOption? _matchedVehicleColor(String? raw) {
  final normalized = _normalizeVehicleColorText(raw);
  if (normalized.isEmpty) return null;

  for (final option in _vehicleColorOptions) {
    if (option.label.toLowerCase() == normalized) return option;
    for (final alias in option.aliases) {
      if (normalized.contains(alias)) return option;
    }
  }

  return null;
}

bool _isLightVehicleColor(Color color) => color.computeLuminance() > 0.68;

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
  Future<void> _showAccountSwitcherMenu() async {
    final l10n = AppLocalizations.of(context);

    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.g_mobiledata_rounded),
                title: Text(l10n.continueWithGoogle),
                onTap: () => Navigator.of(sheetContext).pop('google'),
              ),
              if (Platform.isIOS || Platform.isMacOS)
                ListTile(
                  leading: const Icon(Icons.apple),
                  title: Text(l10n.continueWithApple),
                  onTap: () => Navigator.of(sheetContext).pop('apple'),
                ),
            ],
          ),
        );
      },
    );

    if (!mounted || selected == null) return;

    switch (selected) {
      case 'google':
        await _changeGoogleAccount();
      case 'apple':
        await _changeAppleAccount();
    }
  }

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
    _VF.color: FormControl<String>(
      validators: [
        Validators.required,
        Validators.delegate((control) {
          final value = (control.value as String? ?? '').trim();
          if (value.isEmpty) return null;

          if (value.length > 32) {
            return {'vehicleColor': 'Color description is too long'};
          }

          if (!RegExp(r"^[\p{L}\s\-']+$", unicode: true).hasMatch(value)) {
            return {
              'vehicleColor':
                  'Use a clear color name, like grey, blue, or pearl white',
            };
          }

          return null;
        }),
      ],
    ),
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
      value: '3',
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
          if (parsed > 4) return {'seats': 'Maximum 4 passenger seats'};
          return null;
        }),
      ],
    ),
    _VF.fuelType: FormControl<FuelType>(value: FuelType.gasoline),
  });

  static const List<FuelType> _fuelTypes = [
    FuelType.gasoline,
    FuelType.diesel,
    FuelType.hybrid,
    FuelType.electric,
    FuelType.other,
  ];

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
    final patchedName = user.username.trim();
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

  Future<void> _changeGoogleAccount() async {
    try {
      final switched = await ref
          .read(authActionsViewModelProvider.notifier)
          .switchGoogleAccountForOnboarding();
      if (!mounted) return;
      if (!switched) {
        context.go(AppRoutes.onboarding.path);
        return;
      }
      context.go(AppRoutes.roleSelection.path);
    } on AuthException catch (e) {
      if (!mounted) return;
      AdaptiveSnackBar.show(
        context,
        message: e.message,
        type: AdaptiveSnackBarType.error,
      );
    } on Exception catch (e) {
      if (!mounted) return;
      AdaptiveSnackBar.show(
        context,
        message: userFacingError(e),
        type: AdaptiveSnackBarType.error,
      );
    }
  }

  Future<void> _changeAppleAccount() async {
    try {
      final switched = await ref
          .read(authActionsViewModelProvider.notifier)
          .switchAppleAccountForOnboarding();
      if (!mounted) return;
      if (!switched) {
        context.go(AppRoutes.onboarding.path);
        return;
      }
      context.go(AppRoutes.roleSelection.path);
    } on AuthException catch (e) {
      if (!mounted) return;
      AdaptiveSnackBar.show(
        context,
        message: e.message,
        type: AdaptiveSnackBarType.error,
      );
    } on Exception catch (e) {
      if (!mounted) return;
      AdaptiveSnackBar.show(
        context,
        message: userFacingError(e),
        type: AdaptiveSnackBarType.error,
      );
    }
  }

  @override
  void dispose() {
    _profileForm.dispose();
    _vehicleForm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider.select((a) => a.value));
    final vmState = ref.watch(onboardingViewModelProvider);
    final skipProfileStep = _skipProfileStep(context);
    final effectiveStep = _effectiveStep(vmState, skipProfileStep, currentUser);

    ref
      ..listen(currentUserProvider, (prev, next) {
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
      })
      ..listen(onboardingViewModelProvider, (prev, next) {
        final action = next.completedAction;
        if (action != null && action != prev?.completedAction) {
          switch (action) {
            case OnboardingAction.profileSaved:
            case OnboardingAction.vehicleSaved:
              _nextStep(next);
            case OnboardingAction.finalizedStripe:
              context.go(AppRoutes.driverStripeOnboarding.path);
            case OnboardingAction.finalized:
              context.go(AppRoutes.driverHome.path);
            case OnboardingAction.riderDone:
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, _) =>
          _previousStep(vmState, skipProfileStep: skipProfileStep),
      child: AdaptiveScaffold(
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
          actions: [
            AdaptiveAppBarAction(
              iosSymbol: 'person.crop.circle.badge.arrow.forward',
              icon: Icons.switch_account_rounded,
              onPressed: _showAccountSwitcherMenu,
            ),
          ],
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

            // ── Section: Personal Info ───────────────────────────────────
            _sectionLabel('Personal Info'),

            if (!needsManualName) ...[
              _buildNameDisplay(displayName, hasPhoto, photoUrl),
            ] else ...[
              ReactiveTextField<String>(
                    formControlName: _PF.name,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: l10n.authFullName,
                      hintText: l10n.authFullNameHint,
                      prefixIcon: const Icon(Icons.person_rounded),
                      helperText: 'We could not read your name from sign-in.',
                    ),
                    validationMessages: {
                      ValidationMessage.required: (_) => l10n.nameRequiredError,
                      ValidationMessage.minLength: (_) =>
                          l10n.nameMinLengthError,
                      ValidationMessage.maxLength: (_) => 'Name is too long',
                      'name': (error) => error as String,
                    },
                  )
                  .animate()
                  .fadeIn(duration: 300.ms, delay: 0.ms)
                  .slideY(
                    begin: 0.04,
                    end: 0,
                  ),
            ],

            SizedBox(height: 16.h),

            Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GenderSegmentedField(
                      formControlName: _PF.gender,
                      label: l10n.gender,
                      maleLabel: l10n.genderMale,
                      femaleLabel: l10n.genderFemale,
                      validationMessages: {
                        ValidationMessage.required: (_) =>
                            l10n.driverGenderRequired,
                      },
                    ),
                    SizedBox(height: 14.h),
                    DateOfBirthField(
                      formControlName: _PF.dob,
                      label: l10n.authDateOfBirth,
                      validationMessages: {
                        ValidationMessage.required: (_) => l10n.authDobError,
                        'minAge': (_) => l10n.authDobMinAge,
                      },
                    ),
                  ],
                )
                .animate()
                .fadeIn(duration: 300.ms, delay: 60.ms)
                .slideY(begin: 0.04, end: 0),

            SizedBox(height: 24.h),

            // ── Section: Contact & Address ──────────────────────────────
            _sectionLabel('Contact & Address'),

            IntlPhoneInput(
                  key: _phoneKey,
                  initialValue: switch (currentUser) {
                    final DriverModel driver => driver.phoneNumber,
                    final RiderModel rider => rider.phoneNumber,
                    _ => null,
                  },
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

            AddressAutocompleteField(
                  key: _addressKey,
                  label: 'Address',
                  hint: 'Search your address.',
                  initialValue: switch (currentUser) {
                    final DriverModel driver => driver.address,
                    final RiderModel rider => rider.address,
                    _ => null,
                  },
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
                              Expanded(
                                child: Text(
                                  'You must accept the terms to continue.',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.error,
                                  ),
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
                final isLoading = ref.watch(
                  onboardingViewModelProvider.select((s) => s.isLoading),
                );

                return Semantics(
                  button: true,
                  label: 'Save driver profile and continue',
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 250),
                    opacity: isFormReady ? 1.0 : 0.55,
                    child: PremiumButton(
                      text: isLoading
                          ? 'Saving...'
                          : l10n.driverSaveAndContinue,
                      onPressed: isLoading ? null : _saveProfileAndContinue,
                      isLoading: isLoading,
                      style: isFormReady
                          ? PremiumButtonStyle.ghost
                          : PremiumButtonStyle.primary,
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
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.18),
            ),
          ),
          child: Row(
            children: [
              if (hasPhoto)
                ClipRRect(
                  borderRadius: BorderRadius.circular(22.r),
                  child: CachedNetworkImage(
                    imageUrl: photoUrl!,
                    width: 44.w,
                    height: 44.w,
                    fit: BoxFit.cover,
                    errorWidget: (ctx, url, err) => _defaultAvatar(name),
                    placeholder: (ctx, url) => _defaultAvatar(name),
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
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Row(
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          size: 12.sp,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            'From your sign-in account',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
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
            fontWeight: FontWeight.w800,
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
                          'Help riders recognize your car at pickup.',
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

            SizedBox(height: 20.h),

            ReactiveFormConsumer(
                  builder: (context, form, _) {
                    return _VehicleLiveSummary(
                      form: form,
                      accent: AppColors.primary,
                    );
                  },
                )
                .animate()
                .fadeIn(duration: 300.ms, delay: 40.ms)
                .slideY(begin: 0.04, end: 0),

            SizedBox(height: 24.h),

            _sectionLabel('Car identity'),

            _VehicleSectionCard(
                  icon: Icons.directions_car_rounded,
                  title: 'What car should riders look for?',
                  subtitle: 'Keep this simple. Make and model are enough here.',
                  accent: AppColors.primary,
                  children: [
                    _VehicleTextField(
                      formControlName: _VF.make,
                      label: l10n.make,
                      hintText: l10n.vehicleMakeHint,
                      icon: Icons.business_rounded,
                      textInputAction: TextInputAction.next,
                      validationMessages: {
                        ValidationMessage.required: (_) =>
                            l10n.pleaseEnterVehicleMake,
                      },
                    ),
                    _VehicleTextField(
                      formControlName: _VF.model,
                      label: l10n.model,
                      hintText: l10n.vehicleModelHint,
                      icon: Icons.drive_eta_rounded,
                      textInputAction: TextInputAction.next,
                      validationMessages: {
                        ValidationMessage.required: (_) =>
                            l10n.pleaseEnterVehicleModel,
                      },
                    ),
                  ],
                )
                .animate()
                .fadeIn(duration: 300.ms, delay: 80.ms)
                .slideY(begin: 0.04, end: 0),

            SizedBox(height: 22.h),

            _sectionLabel('Recognition'),

            _VehicleSectionCard(
                  icon: Icons.visibility_rounded,
                  title: 'Help passengers find you',
                  subtitle:
                      'Color and plate are the details riders use at pickup.',
                  accent: AppColors.primary,
                  children: [
                    _VehicleColorSelector(
                      formControlName: _VF.color,
                      label: l10n.color,
                      validationMessages: {
                        ValidationMessage.required: (_) => l10n.requiredField,
                        'vehicleColor': (error) => error as String,
                      },
                    ),
                    _LicensePlateInput(
                      formControlName: _VF.licensePlate,
                      label: l10n.licensePlate,
                      hintText: l10n.licensePlateHint,
                      helperText:
                          'Only used when needed for pickup verification.',
                      validationMessages: {
                        ValidationMessage.required: (_) =>
                            l10n.pleaseEnterLicensePlate,
                        'licensePlate': (error) => error as String,
                      },
                    ),
                  ],
                )
                .animate()
                .fadeIn(duration: 300.ms, delay: 140.ms)
                .slideY(begin: 0.04, end: 0),

            SizedBox(height: 22.h),

            _sectionLabel('Passenger seats'),

            _VehicleSectionCard(
                  icon: Icons.event_seat_rounded,
                  title: 'How many passengers can you take?',
                  subtitle:
                      'This is available passenger seats, not total car seats.',
                  accent: AppColors.primary,
                  children: [
                    _SeatChipSelector(
                      formControlName: _VF.seats,
                      label: l10n.availableSeats,
                      validationMessages: {
                        ValidationMessage.required: (_) =>
                            l10n.pleaseEnterNumberOfSeats,
                        'seats': (error) => error as String,
                      },
                    ),
                  ],
                )
                .animate()
                .fadeIn(duration: 300.ms, delay: 200.ms)
                .slideY(begin: 0.04, end: 0),

            SizedBox(height: 22.h),

            _sectionLabel('More details'),

            _VehicleSectionCard(
                  icon: Icons.tune_rounded,
                  title: 'Vehicle details',
                  subtitle:
                      'Kept quieter because they are less important at pickup.',
                  accent: AppColors.primary,
                  children: [
                    _VehicleTextField(
                      formControlName: _VF.year,
                      label: l10n.year,
                      hintText: DateTime.now().year.toString(),
                      helperText: 'Registration year',
                      icon: Icons.calendar_today_outlined,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      validationMessages: {
                        ValidationMessage.required: (_) => l10n.requiredField,
                        'vehicleYear': (error) => error as String,
                      },
                    ),
                    _FuelTypeChipSelector(
                      formControlName: _VF.fuelType,
                      label: l10n.fuelType,
                      fuelTypes: _fuelTypes,
                    ),
                  ],
                )
                .animate()
                .fadeIn(duration: 300.ms, delay: 260.ms)
                .slideY(begin: 0.04, end: 0),

            SizedBox(height: 30.h),

            ReactiveFormConsumer(
              builder: (context, form, _) {
                final isFormReady = form.valid;
                final isLoading = ref.watch(
                  onboardingViewModelProvider.select((s) => s.isLoading),
                );

                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: isFormReady ? 1.0 : 0.55,
                  child: SizedBox(
                    width: double.infinity,
                    child: PremiumButton(
                      text: isLoading
                          ? 'Saving...'
                          : l10n.driverSaveAndContinue,
                      onPressed: isLoading ? null : _saveVehicleAndContinue,
                      isLoading: isLoading,
                      size: PremiumButtonSize.large,
                      style: isFormReady
                          ? PremiumButtonStyle.success
                          : PremiumButtonStyle.primary,
                      trailingIcon: Icons.adaptive.arrow_forward_rounded,
                    ),
                  ),
                );
              },
            ).animate().fadeIn(duration: 300.ms, delay: 320.ms),

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
                const Divider(height: 1, color: AppColors.divider),
                _buildBenefitItem(
                  icon: Icons.flash_on_rounded,
                  title: l10n.fastTransfers,
                  description: l10n.stripeFastTransfersDesc,
                  delay: 120,
                ),
                const Divider(height: 1, color: AppColors.divider),
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
}

// ─── Vehicle UI Components ────────────────────────────────────────────────────

class _VehicleLiveSummary extends StatelessWidget {
  const _VehicleLiveSummary({
    required this.form,
    required this.accent,
  });

  final FormGroup form;
  final Color accent;

  String _stringValue(String controlName) {
    return (form.control(controlName).value as String? ?? '').trim();
  }

  @override
  Widget build(BuildContext context) {
    final make = _stringValue(_VF.make);
    final model = _stringValue(_VF.model);
    final year = _stringValue(_VF.year);
    final color = _stringValue(_VF.color);
    final plate = _stringValue(_VF.licensePlate);
    final seats = _stringValue(_VF.seats);
    final fuel = form.control(_VF.fuelType).value as FuelType?;
    final colorOption = _matchedVehicleColor(color);
    final previewColor = colorOption?.color ?? AppColors.primary;
    final isLightColor = _isLightVehicleColor(previewColor);

    final hasIdentity = make.isNotEmpty || model.isNotEmpty;
    final title = hasIdentity
        ? [make, model].where((value) => value.isNotEmpty).join(' ')
        : 'Your vehicle';

    final subtitle = color.isNotEmpty
        ? [color, if (year.isNotEmpty) year].join(' • ')
        : 'Add color and plate so riders can find you';

    final detailsParts = [
      if (plate.isNotEmpty) plate.toUpperCase(),
      if (seats.isNotEmpty) '$seats passenger seat${seats == '1' ? '' : 's'}',
      if (fuel != null) _fuelTypeLabel(fuel),
    ];

    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 18,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58.w,
            height: 58.w,
            decoration: BoxDecoration(
              color: previewColor,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color: isLightColor
                    ? AppColors.border
                    : Colors.white.withValues(alpha: 0.65),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: previewColor.withValues(alpha: 0.22),
                  blurRadius: 16,
                  offset: Offset(0, 7.h),
                ),
              ],
            ),
            child: Icon(
              Icons.directions_car_filled_rounded,
              color: isLightColor ? AppColors.textPrimary : Colors.white,
              size: 29.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 6.h,
                  children: [
                    if (detailsParts.isEmpty)
                      _VehicleMiniTag(
                        text: 'Recognition details appear here',
                        accent: accent,
                        muted: true,
                      )
                    else
                      ...detailsParts.map(
                        (detail) => _VehicleMiniTag(
                          text: detail,
                          accent: accent,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleMiniTag extends StatelessWidget {
  const _VehicleMiniTag({
    required this.text,
    required this.accent,
    this.muted = false,
  });

  final String text;
  final Color accent;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: muted
            ? AppColors.textSecondary.withValues(alpha: 0.06)
            : accent.withValues(alpha: 0.085),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.5.sp,
          fontWeight: FontWeight.w700,
          color: muted ? AppColors.textSecondary : accent,
        ),
      ),
    );
  }
}

class _VehicleSectionCard extends StatelessWidget {
  const _VehicleSectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.children,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.46),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.022),
            blurRadius: 14,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: accent, size: 19.sp),
              ),
              SizedBox(width: 11.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        height: 1.28,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) SizedBox(height: 13.h),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _VehicleTextField extends StatelessWidget {
  const _VehicleTextField({
    required this.formControlName,
    required this.label,
    required this.hintText,
    required this.icon,
    this.helperText,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.validationMessages,
  });

  final String formControlName;
  final String label;
  final String hintText;
  final String? helperText;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final Map<String, String Function(Object)>? validationMessages;

  @override
  Widget build(BuildContext context) {
    return ReactiveValueListenableBuilder<String>(
      formControlName: formControlName,
      builder: (context, control, _) {
        final errorText = _reactiveErrorText(control, validationMessages);
        final hasError = errorText != null;
        final hasValue = (control.value ?? '').trim().isNotEmpty;

        final borderColor = hasError
            ? AppColors.error.withValues(alpha: 0.72)
            : hasValue
            ? AppColors.primary.withValues(alpha: 0.22)
            : AppColors.border.withValues(alpha: 0.38);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
                color: hasError ? AppColors.error : AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 7.h),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(15.r),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  SizedBox(width: 12.w),
                  Container(
                    width: 34.w,
                    height: 34.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.085),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      icon,
                      color: hasError ? AppColors.error : AppColors.primary,
                      size: 17.sp,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: ReactiveTextField<String>(
                      formControlName: formControlName,
                      showErrors: (_) => false,
                      keyboardType: keyboardType,
                      textInputAction: textInputAction,
                      textCapitalization: TextCapitalization.sentences,
                      inputFormatters: inputFormatters,
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: hintText,
                        hintStyle: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textTertiary,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 15.h),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              child: hasError
                  ? _VehicleFieldMessage(
                      key: ValueKey(errorText),
                      text: errorText,
                      color: AppColors.error,
                      icon: Icons.error_outline_rounded,
                    )
                  : helperText == null
                  ? const SizedBox.shrink(key: ValueKey('no-helper'))
                  : _VehicleFieldMessage(
                      key: ValueKey(helperText),
                      text: helperText!,
                      color: AppColors.textSecondary,
                      icon: Icons.info_outline_rounded,
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _VehicleColorSelector extends StatefulWidget {
  const _VehicleColorSelector({
    required this.formControlName,
    required this.label,
    required this.validationMessages,
  });

  final String formControlName;
  final String label;
  final Map<String, String Function(Object)> validationMessages;

  @override
  State<_VehicleColorSelector> createState() => _VehicleColorSelectorState();
}

class _VehicleColorSelectorState extends State<_VehicleColorSelector> {
  bool _showCustomInput = false;

  bool _isCommonValue(String value) {
    return _vehicleColorOptions.any(
      (option) => option.label.toLowerCase() == value.trim().toLowerCase(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ReactiveValueListenableBuilder<String>(
      formControlName: widget.formControlName,
      builder: (context, control, _) {
        final value = (control.value ?? '').trim();
        final matched = _matchedVehicleColor(value);
        final isCustomValue = value.isNotEmpty && !_isCommonValue(value);
        final errorText = _reactiveErrorText(
          control,
          widget.validationMessages,
        );
        final hasError = errorText != null;
        final shouldShowCustom = _showCustomInput || isCustomValue;

        void selectColor(_VehicleColorOption option) {
          HapticFeedback.selectionClick();
          setState(() => _showCustomInput = false);
          control.updateValue(option.label);
          control.markAsTouched();
        }

        void useCustom() {
          HapticFeedback.selectionClick();
          setState(() => _showCustomInput = true);
          if (_isCommonValue(value)) {
            control.updateValue('');
          }
          control.markAsTouched();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
                color: hasError ? AppColors.error : AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 9.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                for (final option in _vehicleColorOptions)
                  _ColorChoiceChip(
                    option: option,
                    selected:
                        _isCommonValue(value) &&
                        value.toLowerCase() == option.label.toLowerCase(),
                    onTap: () => selectColor(option),
                  ),
                _OtherColorChip(
                  selected: shouldShowCustom,
                  onTap: useCustom,
                ),
              ],
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: shouldShowCustom
                  ? Padding(
                      key: const ValueKey('custom-color-input'),
                      padding: EdgeInsets.only(top: 11.h),
                      child: _CustomVehicleColorInput(
                        formControlName: widget.formControlName,
                        hintText: 'Champagne, pearl white, bordeaux...',
                        color: matched?.color ?? AppColors.primary,
                        hasError: hasError,
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey('no-custom-color')),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              child: hasError
                  ? _VehicleFieldMessage(
                      key: ValueKey(errorText),
                      text: errorText,
                      color: AppColors.error,
                      icon: Icons.error_outline_rounded,
                    )
                  : _VehicleFieldMessage(
                      key: ValueKey('color-$value-${matched?.label}'),
                      text: value.isEmpty
                          ? 'Choose a common color or use Other color.'
                          : matched != null
                          ? 'Selected color: ${matched.label}'
                          : 'Custom color will be shown to riders as written.',
                      color: AppColors.textSecondary,
                      icon: value.isEmpty
                          ? Icons.info_outline_rounded
                          : Icons.palette_rounded,
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _ColorChoiceChip extends StatelessWidget {
  const _ColorChoiceChip({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _VehicleColorOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isLight = _isLightVehicleColor(option.color);

    return Material(
      color: selected
          ? AppColors.primary.withValues(alpha: 0.1)
          : AppColors.background.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(999.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(999.r),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999.r),
            border: Border.all(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.55)
                  : AppColors.border.withValues(alpha: 0.45),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 13.w,
                height: 13.w,
                decoration: BoxDecoration(
                  color: option.color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isLight
                        ? AppColors.border
                        : Colors.white.withValues(alpha: 0.35),
                  ),
                ),
              ),
              SizedBox(width: 7.w),
              Text(
                option.label,
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w800,
                  color: selected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OtherColorChip extends StatelessWidget {
  const _OtherColorChip({
    required this.selected,
    required this.onTap,
  });

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.primary.withValues(alpha: 0.1)
          : AppColors.background.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(999.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(999.r),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999.r),
            border: Border.all(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.55)
                  : AppColors.border.withValues(alpha: 0.45),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.edit_rounded,
                size: 14.sp,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
              SizedBox(width: 6.w),
              Text(
                'Other color',
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w800,
                  color: selected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomVehicleColorInput extends StatelessWidget {
  const _CustomVehicleColorInput({
    required this.formControlName,
    required this.hintText,
    required this.color,
    required this.hasError,
  });

  final String formControlName;
  final String hintText;
  final Color color;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final borderColor = hasError
        ? AppColors.error.withValues(alpha: 0.72)
        : AppColors.border.withValues(alpha: 0.42);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          SizedBox(width: 12.w),
          Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: _isLightVehicleColor(color)
                    ? AppColors.border
                    : Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: ReactiveTextField<String>(
              formControlName: formControlName,
              showErrors: (_) => false,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              inputFormatters: [
                LengthLimitingTextInputFormatter(32),
              ],
              style: TextStyle(
                fontSize: 14.5.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  fontSize: 13.2.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textTertiary,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 15.h),
              ),
            ),
          ),
          SizedBox(width: 10.w),
        ],
      ),
    );
  }
}

class _VehicleFieldMessage extends StatelessWidget {
  const _VehicleFieldMessage({
    required this.text,
    required this.color,
    required this.icon,
    super.key,
  });

  final String text;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 6.h, left: 2.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 12.5.sp, color: color),
          SizedBox(width: 5.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11.sp,
                height: 1.25,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 140.ms);
  }
}

class _LicensePlateInput extends StatelessWidget {
  const _LicensePlateInput({
    required this.formControlName,
    required this.label,
    required this.hintText,
    required this.helperText,
    required this.validationMessages,
  });

  final String formControlName;
  final String label;
  final String hintText;
  final String helperText;
  final Map<String, String Function(Object)> validationMessages;

  @override
  Widget build(BuildContext context) {
    return ReactiveValueListenableBuilder<String>(
      formControlName: formControlName,
      builder: (context, control, _) {
        final errorText = _reactiveErrorText(control, validationMessages);
        final hasError = errorText != null;
        final hasValue = (control.value ?? '').trim().isNotEmpty;

        final borderColor = hasError
            ? AppColors.error.withValues(alpha: 0.72)
            : hasValue
            ? AppColors.primary.withValues(alpha: 0.24)
            : AppColors.border.withValues(alpha: 0.42);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
                color: hasError ? AppColors.error : AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 7.h),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(15.r),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42.w,
                    height: 38.h,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(11.r),
                    ),
                    child: Center(
                      child: Text(
                        'FR',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.4,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: ReactiveTextField<String>(
                      formControlName: formControlName,
                      showErrors: (_) => false,
                      textCapitalization: TextCapitalization.characters,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[A-Za-z0-9\-\s]'),
                        ),
                        LengthLimitingTextInputFormatter(12),
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          return newValue.copyWith(
                            text: newValue.text.toUpperCase(),
                            selection: newValue.selection,
                          );
                        }),
                      ],
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: hintText,
                        hintStyle: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.7,
                          color: AppColors.textTertiary,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 16.h),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              child: hasError
                  ? _VehicleFieldMessage(
                      key: ValueKey(errorText),
                      text: errorText,
                      color: AppColors.error,
                      icon: Icons.error_outline_rounded,
                    )
                  : _VehicleFieldMessage(
                      key: ValueKey(helperText),
                      text: helperText,
                      color: AppColors.textSecondary,
                      icon: Icons.privacy_tip_outlined,
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _SeatChipSelector extends StatelessWidget {
  const _SeatChipSelector({
    required this.formControlName,
    required this.label,
    required this.validationMessages,
  });

  final String formControlName;
  final String label;
  final Map<String, String Function(Object)> validationMessages;

  @override
  Widget build(BuildContext context) {
    return ReactiveValueListenableBuilder<String>(
      formControlName: formControlName,
      builder: (context, control, _) {
        final selected = int.tryParse(control.value ?? '') ?? 3;
        final errorText = _reactiveErrorText(control, validationMessages);
        final hasError = errorText != null;

        void updateSeats(int value) {
          HapticFeedback.selectionClick();
          control.updateValue(value.toString());
          control.markAsTouched();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ChoiceHeader(
              label: label,
              helper: 'Choose seats available for passengers.',
              icon: Icons.event_seat_rounded,
              hasError: hasError,
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                for (var seats = 1; seats <= 4; seats++) ...[
                  Expanded(
                    child: _NumberChoiceChip(
                      value: seats,
                      selected: selected == seats,
                      onTap: () => updateSeats(seats),
                    ),
                  ),
                  if (seats < 4) SizedBox(width: 8.w),
                ],
              ],
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              child: hasError
                  ? _VehicleFieldMessage(
                      key: ValueKey(errorText),
                      text: errorText,
                      color: AppColors.error,
                      icon: Icons.error_outline_rounded,
                    )
                  : _VehicleFieldMessage(
                      key: ValueKey('$selected-seat-helper'),
                      text:
                          '$selected passenger seat${selected == 1 ? '' : 's'} available',
                      color: AppColors.textSecondary,
                      icon: Icons.info_outline_rounded,
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _NumberChoiceChip extends StatelessWidget {
  const _NumberChoiceChip({
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final int value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.primary
          : AppColors.background.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(13.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(13.r),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 46.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13.r),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.border.withValues(alpha: 0.45),
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.18),
                      blurRadius: 12,
                      offset: Offset(0, 5.h),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              '$value',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w900,
                color: selected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FuelTypeChipSelector extends StatelessWidget {
  const _FuelTypeChipSelector({
    required this.formControlName,
    required this.label,
    required this.fuelTypes,
  });

  final String formControlName;
  final String label;
  final List<FuelType> fuelTypes;

  @override
  Widget build(BuildContext context) {
    return ReactiveValueListenableBuilder<FuelType>(
      formControlName: formControlName,
      builder: (context, control, _) {
        final selected = control.value ?? FuelType.gasoline;

        void updateFuel(FuelType fuel) {
          HapticFeedback.selectionClick();
          control.updateValue(fuel);
          control.markAsTouched();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ChoiceHeader(
              label: label,
              helper: 'Optional detail used for ride context.',
              icon: Icons.local_gas_station_rounded,
              hasError: false,
            ),
            SizedBox(height: 10.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: fuelTypes
                  .map(
                    (fuel) => _FuelChoiceChip(
                      fuel: fuel,
                      selected: selected == fuel,
                      onTap: () => updateFuel(fuel),
                    ),
                  )
                  .toList(),
            ),
          ],
        );
      },
    );
  }
}

class _FuelChoiceChip extends StatelessWidget {
  const _FuelChoiceChip({
    required this.fuel,
    required this.selected,
    required this.onTap,
  });

  final FuelType fuel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = _fuelTypeLabel(fuel);

    return Material(
      color: selected
          ? AppColors.primary.withValues(alpha: 0.1)
          : AppColors.background.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(13.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(13.r),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 10.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13.r),
            border: Border.all(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.55)
                  : AppColors.border.withValues(alpha: 0.45),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _fuelTypeIcon(fuel),
                color: selected ? AppColors.primary : AppColors.textSecondary,
                size: 16.sp,
              ),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w800,
                  color: selected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChoiceHeader extends StatelessWidget {
  const _ChoiceHeader({
    required this.label,
    required this.helper,
    required this.icon,
    required this.hasError,
  });

  final String label;
  final String helper;
  final IconData icon;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16.sp,
          color: hasError ? AppColors.error : AppColors.primary,
        ),
        SizedBox(width: 7.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w800,
                  color: hasError ? AppColors.error : AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                helper,
                style: TextStyle(
                  fontSize: 11.sp,
                  height: 1.25,
                  fontWeight: FontWeight.w500,
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
