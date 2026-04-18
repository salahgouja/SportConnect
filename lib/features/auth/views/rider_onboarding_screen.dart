import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/address_autocomplete_field.dart';
import 'package:sport_connect/core/widgets/custom_button.dart';
import 'package:sport_connect/core/widgets/glass_panel.dart';
import 'package:sport_connect/core/widgets/intl_phone_input.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/auth/view_models/onboarding_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

class RiderOnboardingScreen extends ConsumerStatefulWidget {
  const RiderOnboardingScreen({super.key});

  @override
  ConsumerState<RiderOnboardingScreen> createState() =>
      _RiderOnboardingScreenState();
}

class _RiderOnboardingScreenState extends ConsumerState<RiderOnboardingScreen> {
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
    'gender': FormControl<String>(validators: [Validators.required]),
    'dob': FormControl<DateTime>(
      validators: [
        Validators.required,
        Validators.delegate((control) {
          final value = control.value as DateTime?;
          if (value == null) return null;
          final age = DateTime.now().difference(value).inDays ~/ 365;
          if (age < 18) return {'minAge': true};
          return null;
        }),
      ],
    ),
    'expertise': FormControl<Expertise>(
      value: Expertise.rookie,
      validators: [Validators.required],
    ),
    'terms': FormControl<bool>(
      value: false,
      validators: [Validators.requiredTrue],
    ),
  });
  final _phoneKey = GlobalKey<IntlPhoneInputState>();
  final _cityKey = GlobalKey<AddressAutocompleteFieldState>();

  bool _didScheduleProfilePrefill = false;

  void _populateProfileFields(UserModel user) {
    _form.patchValue({
      'name': user.displayName,
      'gender': user.gender,
      'dob': user.dateOfBirth,
      'expertise': user.expertise,
    });
  }

  Future<void> _completeOnboarding(OnboardingState vmState) async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).loadingProfileMessage),
        ),
      );
      return;
    }
    if (!_form.valid) {
      _form.markAllAsTouched();
      return;
    }

    // Validate external widgets
    final phoneValid = _phoneKey.currentState?.validate() ?? true;
    final cityValid = _cityKey.currentState?.validate() ?? true;
    if (phoneValid != true || cityValid != true) return;

    final values = _form.value;
    final phoneStr = vmState.riderPhoneNumber;
    final cityStr = vmState.riderCity ?? _cityKey.currentState?.text;
    final updatedUser = currentUser.map(
      rider: (rider) => rider.copyWith(
        displayName: values['name'] as String? ?? '',
        phoneNumber: phoneStr,
        city: cityStr,
        country: vmState.riderCountry,
        gender: values['gender'] as String?,
        dateOfBirth: values['dob'] as DateTime?,
        expertise: (values['expertise'] as Expertise?) ?? Expertise.rookie,
      ),
      driver: (driver) => driver,
    );

    ref
        .read(onboardingViewModelProvider.notifier)
        .completeRiderOnboarding(updatedUser.uid, updatedUser.toJson());
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.value;
    final l10n = AppLocalizations.of(context);
    final vmState = ref.watch(onboardingViewModelProvider);

    // Navigate to home on successful onboarding.
    ref.listen(onboardingViewModelProvider, (prev, next) {
      if (next.completedAction == 'riderDone' &&
          prev?.completedAction != 'riderDone') {
        context.go(AppRoutes.home.path);
      }
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    if (!vmState.riderProfilePopulated && user != null) {
      if (!_didScheduleProfilePrefill) {
        _didScheduleProfilePrefill = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ref
              .read(onboardingViewModelProvider.notifier)
              .markRiderProfilePopulated();
          _populateProfileFields(user);
        });
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          tooltip: l10n.goBackTooltip,
          onPressed: () => context.go(AppRoutes.roleSelection.path),
          icon: Icon(Icons.adaptive.arrow_back_rounded),
        ),
        title: Text(l10n.riderOnboardingTitle),
      ),
      body: SafeArea(
        child: Semantics(
          container: true,
          label: 'Rider onboarding form',
          child: ReactiveForm(
            formGroup: _form,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GlassPanel(
                    padding: EdgeInsets.all(20.w),
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
                          l10n.completeRiderProfile,
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          l10n.riderProfileDescription,
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
                  // Full name
                  ReactiveTextField<String>(
                    formControlName: 'name',
                    decoration: InputDecoration(
                      labelText: l10n.authFullName,
                      hintText: l10n.authFullNameHint,
                      prefixIcon: const Icon(Icons.person_rounded),
                    ),
                    textInputAction: TextInputAction.next,
                    validationMessages: {
                      ValidationMessage.required: (_) => l10n.nameRequiredError,
                      ValidationMessage.minLength: (_) =>
                          l10n.nameMinLengthError,
                      ValidationMessage.maxLength: (_) => 'Name is too long',
                      'name': (error) => error as String,
                    },
                  ).animate().fadeIn(duration: 400.ms, delay: 50.ms),

                  SizedBox(height: 16.h),

                  // Phone (optional) — international input
                  IntlPhoneInput(
                    key: _phoneKey,
                    initialValue: user?.phoneNumber,
                    label: l10n.authPhoneOptional,
                    hint: l10n.authPhoneHint,
                    accentColor: AppColors.primary,
                    fillColor: AppColors.background,
                    onChanged: (phone) => ref
                        .read(onboardingViewModelProvider.notifier)
                        .setRiderDraftContact(
                          phoneNumber: phone.isValid ? phone.fullNumber : null,
                        ),
                  ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

                  SizedBox(height: 16.h),

                  // City — autocomplete with map picker
                  AddressAutocompleteField(
                    key: _cityKey,
                    label: l10n.driverCityLabel,
                    hint: l10n.driverCityHint,
                    cityOnly: true,
                    initialValue: user?.city,
                    accentColor: AppColors.primary,
                    fillColor: AppColors.background,
                    onSelected: (result) => ref
                        .read(onboardingViewModelProvider.notifier)
                        .setRiderDraftContact(
                          city: result.address,
                          country: result.country,
                        ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.driverCityLabel;
                      }
                      return null;
                    },
                  ).animate().fadeIn(duration: 400.ms, delay: 150.ms),

                  SizedBox(height: 16.h),

                  // Gender dropdown
                  ReactiveDropdownField<String>(
                    formControlName: 'gender',
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
                  ),
                  SizedBox(height: 16.h),

                  // Date of birth
                  ReactiveDatePicker<DateTime>(
                    formControlName: 'dob',
                    firstDate: DateTime(1950),
                    lastDate: DateTime(
                      DateTime.now().year - 18,
                      DateTime.now().month,
                      DateTime.now().day,
                    ),
                    builder: (context, picker, child) {
                      final value = picker.value;
                      final control = picker.control;
                      final showError = control.touched && control.invalid;
                      String? errorText;
                      if (showError) {
                        if (control.hasError(ValidationMessage.required)) {
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
                            errorText: errorText,
                          ),
                          child: Text(
                            value != null
                                ? '${value.day}/${value.month}/${value.year}'
                                : l10n.authDobPrompt,
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 16.h),

                  // Expertise level
                  ReactiveDropdownField<Expertise>(
                    formControlName: 'expertise',
                    decoration: InputDecoration(
                      labelText: l10n.expertiseLevel,
                      prefixIcon: const Icon(Icons.workspace_premium_rounded),
                    ),
                    items: Expertise.values
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(e.displayName),
                          ),
                        )
                        .toList(),
                    validationMessages: {
                      ValidationMessage.required: (_) =>
                          l10n.expertiseLevelRequired,
                    },
                  ),
                  SizedBox(height: 20.h),

                  // Terms checkbox
                  ReactiveCheckboxListTile(
                    formControlName: 'terms',
                    title: Text(l10n.driverTermsLabel),
                  ),

                  SizedBox(height: 28.h),
                  Semantics(
                    button: true,
                    label: 'Complete rider onboarding',
                    child: PremiumButton(
                      text: l10n.completeSetupButton,
                      onPressed: vmState.isLoading
                          ? null
                          : () => _completeOnboarding(vmState),
                      isLoading: vmState.isLoading,
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
