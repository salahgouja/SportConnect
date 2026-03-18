import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:sport_connect/core/utils/form_validators.dart';
import 'package:sport_connect/core/widgets/custom_button.dart';
import 'package:sport_connect/core/widgets/glass_panel.dart';
import 'package:sport_connect/core/widgets/intl_phone_input.dart';
import 'package:sport_connect/core/widgets/address_autocomplete_field.dart';
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
  final _formKey = GlobalKey<FormBuilderState>();
  final _phoneKey = GlobalKey<IntlPhoneInputState>();
  final _cityKey = GlobalKey<AddressAutocompleteFieldState>();

  bool _didScheduleProfilePrefill = false;

  void _populateProfileFields(UserModel user) {
    _formKey.currentState?.patchValue({
      'name': user.displayName,
      'phone': user.phoneNumber ?? '',
      'city': user.city ?? '',
      'gender': user.gender,
      'dob': user.dateOfBirth,
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
    if (!_formKey.currentState!.saveAndValidate()) return;

    // Validate external widgets
    final phoneValid = _phoneKey.currentState?.validate() ?? true;
    final cityValid = _cityKey.currentState?.validate() ?? true;
    if (phoneValid != true || cityValid != true) return;

    final values = _formKey.currentState!.value;
    final phoneStr = vmState.riderPhoneNumber;
    final cityStr = vmState.riderCity ?? _cityKey.currentState?.text;
    final updatedUser = currentUser.map(
      rider: (rider) => rider.copyWith(
        displayName: values['name'],
        phoneNumber: phoneStr,
        city: cityStr,
        country: vmState.riderCountry,
        gender: values['gender'],
        dateOfBirth: values['dob'],
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
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(l10n.riderOnboardingTitle),
      ),
      body: SafeArea(
        child: Semantics(
          container: true,
          label: 'Rider onboarding form',
          child: FormBuilder(
            key: _formKey,
            autovalidateMode: AutovalidateMode.disabled,
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
                  FormBuilderTextField(
                    name: 'name',
                    decoration: InputDecoration(
                      labelText: l10n.authFullName,
                      hintText: l10n.authFullNameHint,
                      prefixIcon: Icon(Icons.person_rounded),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(
                        errorText: l10n.nameRequiredError,
                      ),
                      FormBuilderValidators.minLength(
                        2,
                        errorText: l10n.nameMinLengthError,
                      ),
                      FormBuilderValidators.maxLength(60),
                      (value) => FormValidators.name(value),
                    ]),
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
                  FormBuilderDropdown<String>(
                    name: 'gender',
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
                    validator: FormBuilderValidators.required(
                      errorText: l10n.driverGenderRequired,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Date of birth
                  FormBuilderDateTimePicker(
                    name: 'dob',
                    inputType: InputType.date,
                    decoration: InputDecoration(
                      labelText: l10n.authDateOfBirth,
                    ),
                    lastDate: DateTime(
                      DateTime.now().year - 18,
                      DateTime.now().month,
                      DateTime.now().day,
                    ),
                    firstDate: DateTime(1950),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(
                        errorText: l10n.authDobError,
                      ),
                      (value) {
                        if (value == null) return null;
                        final age =
                            DateTime.now().difference(value).inDays ~/ 365;
                        if (age < 18) return l10n.authDobMinAge;
                        return null;
                      },
                    ]),
                  ),
                  SizedBox(height: 20.h),

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
