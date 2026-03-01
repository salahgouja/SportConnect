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
import 'package:sport_connect/core/widgets/custom_button.dart';
import 'package:sport_connect/core/widgets/glass_panel.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

class RiderOnboardingScreen extends ConsumerStatefulWidget {
  const RiderOnboardingScreen({super.key});

  @override
  ConsumerState<RiderOnboardingScreen> createState() =>
      _RiderOnboardingScreenState();
}

class _RiderOnboardingScreenState extends ConsumerState<RiderOnboardingScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

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

  bool _isLoading = false;
  bool _isPopulated = false;
  UserModel? _currentUser;

  @override
  void dispose() {
    super.dispose();
  }

  void _populateProfileFields(UserModel user) {
    _formKey.currentState?.patchValue({
      'name': user.displayName,
      'phone': user.phoneNumber ?? '',
      'city': user.city ?? '',
      'bio': user.bio ?? '',
      'gender': user.gender,
      'dob': user.dateOfBirth,
      'interests': user.interests,
    });
  }

  Future<void> _completeOnboarding() async {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please wait, loading your profile...')),
      );
      return;
    }
    if (!_formKey.currentState!.saveAndValidate()) return;

    setState(() => _isLoading = true);

    try {
      final values = _formKey.currentState!.value;
      final updatedUser = _currentUser!.map(
        rider: (rider) => rider.copyWith(
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
    final l10n = AppLocalizations.of(context);

    if (!_isPopulated && user != null) {
      _currentUser = user;
      _isPopulated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _populateProfileFields(user);
      });
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
                        errorText: "Name is required",
                      ),
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

                  // Sports interests
                  FormBuilderFilterChips<String>(
                    name: 'interests',
                    decoration: InputDecoration(
                      labelText: l10n.sportsInterests,
                    ),
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
