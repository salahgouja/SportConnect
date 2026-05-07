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
import 'package:sport_connect/core/widgets/custom_button.dart';
import 'package:sport_connect/core/widgets/dob_picker.dart';
import 'package:sport_connect/core/widgets/expertise_picker.dart';
import 'package:sport_connect/core/widgets/gender_segmented_field.dart';
import 'package:sport_connect/core/widgets/glass_panel.dart';
import 'package:sport_connect/core/widgets/intl_phone_input.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';
import 'package:sport_connect/features/auth/view_models/onboarding_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

abstract final class _FormFields {
  static const name = 'name';
  static const gender = 'gender';
  static const dob = 'dob';
  static const expertise = 'expertise';
  static const terms = 'terms';
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

class RiderOnboardingScreen extends ConsumerStatefulWidget {
  const RiderOnboardingScreen({super.key});

  @override
  ConsumerState<RiderOnboardingScreen> createState() =>
      _RiderOnboardingScreenState();
}

class _RiderOnboardingScreenState extends ConsumerState<RiderOnboardingScreen> {
  final _form = FormGroup({
    _FormFields.name: FormControl<String>(
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
    _FormFields.gender: FormControl<String>(
      validators: [Validators.required],
    ),
    _FormFields.dob: FormControl<DateTime>(
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
    _FormFields.expertise: FormControl<Expertise>(
      value: Expertise.rookie,
      validators: [Validators.required],
    ),
    _FormFields.terms: FormControl<bool>(
      value: false,
      validators: [Validators.requiredTrue],
    ),
  });

  final _phoneKey = GlobalKey<IntlPhoneInputState>();
  final _addressKey = GlobalKey<AddressAutocompleteFieldState>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final user = ref.read(currentUserProvider).value;
      if (user == null) return;

      final notifier = ref.read(onboardingViewModelProvider.notifier);
      final state = ref.read(onboardingViewModelProvider);

      _populateProfileFields(user);

      if (!state.riderProfilePopulated) {
        notifier.markRiderProfilePopulated();
      }
    });
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

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

  void _populateProfileFields(UserModel user) {
    final existingName = _form.control(_FormFields.name).value as String?;
    final existingGender = _form.control(_FormFields.gender).value as String?;
    final existingDob = _form.control(_FormFields.dob).value as DateTime?;

    final patchedName = user.username.trim();

    final patchedGender = switch (user) {
      final RiderModel rider => _normalizeGenderValue(rider.gender),
      final DriverModel driver => _normalizeGenderValue(driver.gender),
      _ => null,
    };

    final patchedDob = switch (user) {
      final RiderModel rider => rider.dateOfBirth,
      final DriverModel driver => driver.dateOfBirth,
      _ => null,
    };

    _form.patchValue({
      _FormFields.name: patchedName.isNotEmpty ? patchedName : existingName,
      _FormFields.gender: patchedGender ?? existingGender,
      _FormFields.dob: patchedDob ?? existingDob,
      _FormFields.expertise: user.expertise,
    });
  }

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
        .slideY(begin: 0.04, end: 0);
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

  Future<void> _handleBack() async {
    final hasData =
        _form.dirty ||
        (_phoneKey.currentState?.phoneNumber.number.isNotEmpty ?? false);

    if (!hasData) {
      context.go(AppRoutes.roleSelection.path);
      return;
    }

    final confirmed = await showAdaptiveDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        title: Text(AppLocalizations.of(context).discardChangesTitle),
        content: const Text(
          'Your profile info will not be saved if you go back.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.of(context).keepEditing),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Discard',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.go(AppRoutes.roleSelection.path);
    }
  }

  Future<void> _completeOnboarding(OnboardingState vmState) async {
    final currentUser = ref.read(currentUserProvider).value;
    final signedInName = currentUser?.username.trim() ?? '';
    final currentNameValue =
        (_form.control(_FormFields.name).value as String?)?.trim() ?? '';

    if (signedInName.isNotEmpty && currentNameValue.isEmpty) {
      _form.control(_FormFields.name).updateValue(signedInName);
    }

    if (currentUser == null) {
      AdaptiveSnackBar.show(
        context,
        message: '⚠️ Profile not loaded yet. Please wait a moment.',
        type: AdaptiveSnackBarType.warning,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    if (!_form.valid) {
      _form.markAllAsTouched();

      final errors = <String>[];
      final needsManualName = currentUser.username.trim().isEmpty;

      if (needsManualName && _form.control(_FormFields.name).invalid) {
        errors.add('Full name');
      }
      if (_form.control(_FormFields.gender).invalid) errors.add('Gender');
      if (_form.control(_FormFields.dob).invalid) errors.add('Date of birth');
      if (_form.control(_FormFields.expertise).invalid) {
        errors.add('Expertise level');
      }
      if (_form.control(_FormFields.terms).invalid) {
        errors.add('Terms acceptance');
      }

      AdaptiveSnackBar.show(
        context,
        message: 'Please fix: ${errors.join(', ')}',
        type: AdaptiveSnackBarType.error,
      );
      return;
    }

    final phoneValid = _phoneKey.currentState?.validate() == null;
    final addressValid = _addressKey.currentState?.validate() == null;

    if (!phoneValid) {
      AdaptiveSnackBar.show(
        context,
        message: 'Please enter a valid phone number.',
        type: AdaptiveSnackBarType.error,
      );
      return;
    }

    if (!addressValid) {
      AdaptiveSnackBar.show(
        context,
        message: 'Please enter your address.',
        type: AdaptiveSnackBarType.error,
      );
      return;
    }

    HapticFeedback.mediumImpact();

    final values = _form.value;
    final dateOfBirth = values[_FormFields.dob] as DateTime?;

    final profileUpdates = <String, dynamic>{
      'username':
          ((values[_FormFields.name] as String?)?.trim().isNotEmpty ?? false)
          ? (values[_FormFields.name]! as String).trim()
          : currentUser.username.trim(),
      'phoneNumber': vmState.riderPhoneNumber,
      'address': _addressKey.currentState?.text.trim(),
      'gender': values[_FormFields.gender] as String?,
      'dateOfBirth': dateOfBirth == null ? null : _dateOnly(dateOfBirth),
      'expertise':
          ((values[_FormFields.expertise] as Expertise?) ?? Expertise.rookie)
              .name,
    };

    await ref
        .read(onboardingViewModelProvider.notifier)
        .completeRiderOnboarding(currentUser.uid, profileUpdates);
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

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider.select((a) => a.value));
    final l10n = AppLocalizations.of(context);
    final displayName = (currentUser?.username ?? '').trim();
    final photoUrl = currentUser?.photoUrl;
    final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;
    final needsManualName = displayName.isEmpty;

    ref
      ..listen(onboardingViewModelProvider, (prev, next) {
        if (next.completedAction == OnboardingAction.riderDone &&
            prev?.completedAction != OnboardingAction.riderDone) {
          AdaptiveSnackBar.show(
            context,
            message: '🎉 Profile complete! Welcome aboard.',
            type: AdaptiveSnackBarType.success,
            duration: const Duration(seconds: 2),
          );

          Future.delayed(const Duration(milliseconds: 600), () {
            if (context.mounted) context.go(AppRoutes.home.path);
          });
          return;
        }

        if (next.errorMessage != null &&
            next.errorMessage != prev?.errorMessage) {
          AdaptiveSnackBar.show(
            context,
            message: next.errorMessage!,
            type: AdaptiveSnackBarType.error,
            duration: const Duration(seconds: 5),
            action: 'Retry',
            onActionPressed: () => _completeOnboarding(next),
          );
        }
      })
      ..listen(currentUserProvider, (prev, next) {
        final user = next.value;

        if (user != null) {
          final notifier = ref.read(onboardingViewModelProvider.notifier);
          final state = ref.read(onboardingViewModelProvider);

          if (!state.riderProfilePopulated) {
            notifier.markRiderProfilePopulated();

            AdaptiveSnackBar.show(
              context,
              message: 'Your saved info has been pre-filled.',
              duration: const Duration(seconds: 2),
            );
          }

          _populateProfileFields(user);
        }

        if (next.hasError) {
          AdaptiveSnackBar.show(
            context,
            message: 'Failed to load your profile. Some fields may be empty.',
            type: AdaptiveSnackBarType.warning,
          );
        }
      });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, _) => _handleBack(),
      child: AdaptiveScaffold(
        appBar: AdaptiveAppBar(
          leading: IconButton(
            tooltip: l10n.goBackTooltip,
            onPressed: _handleBack,
            icon: Icon(Icons.adaptive.arrow_back_rounded),
          ),
          title: l10n.riderOnboardingTitle,
          actions: [
            AdaptiveAppBarAction(
              iosSymbol: 'person.crop.circle.badge.arrow.forward',
              icon: Icons.switch_account_rounded,
              onPressed: _showAccountSwitcherMenu,
            ),
          ],
        ),
        body: SafeArea(
          child: Semantics(
            container: true,
            label: 'Rider onboarding form',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 12.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Complete your profile',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            'Step 2 of 2',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: LinearProgressIndicator(
                          value: 1,
                          minHeight: 4.h,
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.12,
                          ),
                          valueColor: const AlwaysStoppedAnimation(
                            AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ReactiveForm(
                    formGroup: _form,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GlassPanel(
                            padding: EdgeInsets.all(16.w),
                            color: AppColors.surface.withValues(alpha: 0.62),
                            borderColor: AppColors.primary.withValues(
                              alpha: 0.2,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12.w),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                  child: Icon(
                                    Icons.person_add_alt_1_rounded,
                                    color: AppColors.primary,
                                    size: 28.sp,
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.completeRiderProfile,
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        l10n.riderProfileDescription,
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
                          ),
                          SizedBox(height: 24.h),

                          _sectionLabel('Personal Info'),

                          if (!needsManualName) ...[
                            _buildNameDisplay(displayName, hasPhoto, photoUrl),
                          ] else ...[
                            ReactiveTextField<String>(
                                  formControlName: _FormFields.name,
                                  decoration: InputDecoration(
                                    labelText: l10n.authFullName,
                                    hintText: l10n.authFullNameHint,
                                    prefixIcon: const Icon(
                                      Icons.person_rounded,
                                    ),
                                    helperText:
                                        'We could not read your name from sign-in.',
                                  ),
                                  textInputAction: TextInputAction.next,
                                  validationMessages: {
                                    ValidationMessage.required: (_) =>
                                        l10n.nameRequiredError,
                                    ValidationMessage.minLength: (_) =>
                                        l10n.nameMinLengthError,
                                    ValidationMessage.maxLength: (_) =>
                                        'Name is too long',
                                    'name': (error) => error as String,
                                  },
                                )
                                .animate()
                                .fadeIn(duration: 300.ms, delay: 0.ms)
                                .slideY(begin: 0.04, end: 0),
                          ],

                          SizedBox(height: 16.h),
                          Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GenderSegmentedField(
                                    formControlName: _FormFields.gender,
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
                                    formControlName: _FormFields.dob,
                                    label: l10n.authDateOfBirth,
                                    validationMessages: {
                                      ValidationMessage.required: (_) =>
                                          l10n.authDobError,
                                      'minAge': (_) => l10n.authDobMinAge,
                                    },
                                  ),
                                ],
                              )
                              .animate()
                              .fadeIn(duration: 300.ms, delay: 60.ms)
                              .slideY(begin: 0.04, end: 0),

                          SizedBox(height: 24.h),

                          _sectionLabel('Contact & Address'),

                          IntlPhoneInput(
                                key: _phoneKey,
                                initialValue: switch (currentUser) {
                                  final RiderModel rider => rider.phoneNumber,
                                  final DriverModel driver =>
                                    driver.phoneNumber,
                                  _ => null,
                                },
                                label: l10n.authPhoneOptional,
                                hint: l10n.authPhoneHint,
                                accentColor: AppColors.primary,
                                fillColor: AppColors.background,
                                onChanged: (phone) => ref
                                    .read(onboardingViewModelProvider.notifier)
                                    .setRiderDraftContact(
                                      phoneNumber: phone.isValid
                                          ? phone.fullNumber
                                          : null,
                                    ),
                              )
                              .animate()
                              .fadeIn(duration: 300.ms, delay: 180.ms)
                              .slideY(begin: 0.04, end: 0),

                          SizedBox(height: 16.h),

                          AddressAutocompleteField(
                                key: _addressKey,
                                label: 'Address',
                                hint: 'Search your address...',
                                initialValue: switch (currentUser) {
                                  final RiderModel rider => rider.address,
                                  final DriverModel driver => driver.address,
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
                              .slideY(begin: 0.04, end: 0),

                          SizedBox(height: 24.h),

                          _sectionLabel('Riding Details'),

                          ReactiveExpertisePicker(
                                formControlName: _FormFields.expertise,
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
                              .slideY(begin: 0.04, end: 0),

                          SizedBox(height: 24.h),

                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.2),
                              ),
                            ),
                            child: ReactiveCheckboxListTile(
                              formControlName: _FormFields.terms,
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
                                        ..onTap = () =>
                                            context.push(AppRoutes.terms.path),
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
                          ),

                          ReactiveFormConsumer(
                            builder: (context, form, _) {
                              final termsControl = form.control(
                                _FormFields.terms,
                              );
                              final showError =
                                  termsControl.touched && termsControl.invalid;

                              return AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: showError
                                    ? Padding(
                                        key: const ValueKey('terms-error'),
                                        padding: EdgeInsets.only(
                                          top: 6.h,
                                          left: 14.w,
                                        ),
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
                                    : const SizedBox.shrink(
                                        key: ValueKey('terms-ok'),
                                      ),
                              );
                            },
                          ),

                          SizedBox(height: 28.h),

                          ReactiveFormConsumer(
                            builder: (context, form, _) {
                              final isFormReady = form.valid;
                              final isVmLoading = ref.watch(
                                onboardingViewModelProvider.select(
                                  (s) => s.isLoading,
                                ),
                              );

                              return Semantics(
                                button: true,
                                label: 'Complete rider onboarding',
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 250),
                                  opacity: isFormReady ? 1.0 : 0.55,
                                  child: PremiumButton(
                                    text: isVmLoading
                                        ? 'Saving...'
                                        : l10n.completeSetupButton,
                                    onPressed: isVmLoading
                                        ? null
                                        : () => _completeOnboarding(
                                            ref.read(
                                              onboardingViewModelProvider,
                                            ),
                                          ),
                                    isLoading: isVmLoading,
                                    style: isFormReady
                                        ? PremiumButtonStyle.gradient
                                        : PremiumButtonStyle.primary,
                                  ),
                                ),
                              );
                            },
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
        ),
      ),
    );
  }
}
