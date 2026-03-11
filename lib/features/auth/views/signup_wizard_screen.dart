import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:sport_connect/core/utils/form_validators.dart';
import 'package:sport_connect/core/widgets/intl_phone_input.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';
import 'package:sport_connect/features/auth/view_models/social_auth_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

// ─── Step Theme ───────────────────────────────────────────────────────────────

class _StepTheme {
  final Color bg;
  final Color accent;
  final Color card;
  final Color text;
  final String label;

  const _StepTheme({
    required this.bg,
    required this.accent,
    required this.card,
    required this.text,
    required this.label,
  });
}

const _kBg = Color(0xFFF8FAF9);
const _kAccent = Color(0xFF40916C);
const _kCard = Color(0xFFFFFFFF);
const _kText = Color(0xFF1A1A1A);

const _stepThemes = [
  _StepTheme(
    bg: _kBg,
    accent: _kAccent,
    card: _kCard,
    text: _kText,
    label: 'Your Details',
  ),
  _StepTheme(
    bg: _kBg,
    accent: _kAccent,
    card: _kCard,
    text: _kText,
    label: 'Security',
  ),
  _StepTheme(
    bg: _kBg,
    accent: _kAccent,
    card: _kCard,
    text: _kText,
    label: 'Your Role',
  ),
  _StepTheme(
    bg: _kBg,
    accent: _kAccent,
    card: _kCard,
    text: _kText,
    label: 'Your Profile',
  ),
];

// ─── Main Screen ──────────────────────────────────────────────────────────────

class SignupWizardScreen extends ConsumerStatefulWidget {
  const SignupWizardScreen({super.key});

  @override
  ConsumerState<SignupWizardScreen> createState() => _SignupWizardScreenState();
}

class _SignupWizardScreenState extends ConsumerState<SignupWizardScreen> {
  // ── Controllers & State ──
  final List<GlobalKey<FormBuilderState>> _formKeys = List.generate(
    4,
    (_) => GlobalKey<FormBuilderState>(),
  );
  final _phoneKey = GlobalKey<IntlPhoneInputState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // ── Navigation ──
  void _goToStep(int target) async {
    final uiState = ref.read(signupWizardUiViewModelProvider);
    // Validate current step
    if (_formKeys[uiState.currentStep].currentState != null) {
      if (!_formKeys[uiState.currentStep].currentState!.saveAndValidate())
        return;
    }
    // Validate phone in step 0 (optional but format-checked if entered)
    if (uiState.currentStep == 0) {
      final phoneError = _phoneKey.currentState?.validate();
      if (phoneError != null) return;
    }
    if (uiState.currentStep == 0 && uiState.dateOfBirth == null) {
      _showError(AppLocalizations.of(context).authDobError);
      return;
    }
    if (uiState.currentStep == 0 && uiState.dateOfBirth != null) {
      final age = DateTime.now().difference(uiState.dateOfBirth!).inDays ~/ 365;
      if (age < 18) {
        _showError(AppLocalizations.of(context).authDobMinAge);
        return;
      }
    }
    if (uiState.currentStep == 1 && !uiState.agreedToTerms) {
      _showError(AppLocalizations.of(context).authAgreeTermsError);
      return;
    }

    if (target >= 4) {
      _handleSignup();
      return;
    }

    FocusScope.of(context).unfocus();
    HapticFeedback.mediumImpact();
    ref.read(signupWizardUiViewModelProvider.notifier).setCurrentStep(target);
  }

  void _prevStep() {
    final currentStep = ref.read(signupWizardUiViewModelProvider).currentStep;
    if (currentStep == 0) {
      context.pop();
      return;
    }
    HapticFeedback.lightImpact();
    ref.read(signupWizardUiViewModelProvider.notifier).previousStep();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  Future<void> _handleSignup() async {
    final uiState = ref.read(signupWizardUiViewModelProvider);
    final step0Values = _formKeys[0].currentState!.value;
    final step1Values = _formKeys[1].currentState!.value;
    final step3Values = _formKeys[3].currentState?.value ?? {};
    final success = await ref
        .read(registerViewModelProvider.notifier)
        .register(
          email: (step0Values['email'] as String).trim(),
          password: step1Values['password'] as String,
          displayName: (step0Values['name'] as String).trim(),
          role: uiState.selectedRole,
          phone: uiState.phoneNumber,
          bio: (step3Values['bio'] as String? ?? '').trim().isEmpty
              ? null
              : (step3Values['bio'] as String).trim(),
          interests: uiState.selectedInterests,
          profileImage: uiState.profileImage,
        );
    if (!mounted) return;

    if (success) {
      context.go(AppRoutes.emailVerification.path);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final xf = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (xf != null) {
      ref
          .read(signupWizardUiViewModelProvider.notifier)
          .setProfileImage(File(xf.path));
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _handleGoogleSignIn() async {
    await ref.read(socialAuthViewModelProvider.notifier).signInWithGoogle();
  }

  Future<void> _handleAppleSignIn() async {
    await ref.read(socialAuthViewModelProvider.notifier).signInWithApple();
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final wizardUiState = ref.watch(signupWizardUiViewModelProvider);
    final theme = _stepThemes[wizardUiState.currentStep];
    final registerState = ref.watch(registerViewModelProvider);
    final socialState = ref.watch(socialAuthViewModelProvider);
    final l10n = AppLocalizations.of(context);

    ref.listen(registerViewModelProvider, (previous, next) {
      if (next.hasError && previous?.error != next.error) {
        final error = next.error;
        final msg = error is AuthException
            ? error.message
            : error.toString().replaceFirst('Exception: ', '');
        final safeMessage = msg.isNotEmpty ? msg : l10n.signUpFailedPleaseTry;
        TalkerService.error('Signup failed: $safeMessage');
        _showError(safeMessage);
      }
    });

    ref.listen(socialAuthViewModelProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        final error = next.errorMessage!;
        final isAccountExists = error.contains(
          'account-exists-with-different-credential',
        );
        _showError(
          isAccountExists
              ? l10n.accountExistsError
              : l10n.signUpFailedPleaseTry,
        );
      }
    });

    return PopScope(
      canPop: wizardUiState.currentStep == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _prevStep();
      },
      child: Scaffold(
        backgroundColor: _kBg,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(theme),
              _buildStepIndicator(),
              Expanded(child: _buildCard(theme)),
              _buildBottomCTA(theme, registerState, socialState),
            ],
          ),
        ),
      ),
    );
  }

  // ── Top Bar ────────────────────────────────────────────────────────────────
  Widget _buildTopBar(_StepTheme theme) {
    final wizardUiState = ref.watch(signupWizardUiViewModelProvider);
    final l10n = AppLocalizations.of(context);
    final stepLabels = [
      l10n.yourDetailsStep,
      l10n.securityStep,
      l10n.yourRoleStep,
      l10n.yourProfileStep,
    ];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: _prevStep,
            child: AnimatedContainer(
              duration: 300.ms,
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: theme.accent.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                wizardUiState.currentStep == 0
                    ? Icons.close_rounded
                    : Icons.arrow_back_ios_new_rounded,
                size: 18.sp,
                color: theme.accent,
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSwitcher(
                  duration: 300.ms,
                  child: Text(
                    stepLabels[wizardUiState.currentStep],
                    key: ValueKey(wizardUiState.currentStep),
                    style: TextStyle(
                      fontFamily: 'Syne', // bold geometric
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: theme.text,
                    ),
                  ),
                ),
                Text(
                  l10n.stepOfCount(wizardUiState.currentStep + 1, 4),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: theme.accent.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          // Step dots
          Row(
            children: List.generate(
              4,
              (i) => AnimatedContainer(
                duration: 300.ms,
                margin: EdgeInsets.only(left: 5.w),
                width: i == wizardUiState.currentStep ? 20.w : 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: i <= wizardUiState.currentStep
                      ? theme.accent
                      : theme.accent.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Speedometer ─────────────────────────────────────────────────────────────
  Widget _buildStepIndicator() {
    final wizardUiState = ref.watch(signupWizardUiViewModelProvider);
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 4.h, 24.w, 12.h),
      child: Row(
        children: List.generate(4, (i) {
          return Expanded(
            child: AnimatedContainer(
              duration: 300.ms,
              margin: EdgeInsets.only(right: i < 3 ? 6.w : 0),
              height: 4.h,
              decoration: BoxDecoration(
                color: i <= wizardUiState.currentStep
                    ? _kAccent
                    : _kAccent.withOpacity(0.18),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Tinder Card Stack ───────────────────────────────────────────────────────
  Widget _buildCard(_StepTheme theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: _buildStepContent(theme),
        ),
      ),
    );
  }

  Widget _buildStepContent(_StepTheme theme) {
    final currentStep = ref.watch(signupWizardUiViewModelProvider).currentStep;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 24.h),
      child: IndexedStack(
        index: currentStep,
        children: [
          _buildStep1(theme),
          _buildStep2(theme),
          _buildStep3(theme),
          _buildStep4(theme),
        ],
      ),
    );
  }

  // ── Step 1: Basic Info ──────────────────────────────────────────────────────
  Widget _buildStep1(_StepTheme theme) {
    final l10n = AppLocalizations.of(context);
    final wizardUiState = ref.watch(signupWizardUiViewModelProvider);
    return FormBuilder(
      key: _formKeys[0],
      child: Column(
        key: const ValueKey('step1'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Welcome banner
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: theme.accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: theme.accent.withOpacity(0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: theme.accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.eco_outlined,
                    color: theme.accent,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.joinOurCommunityOfEco,
                        style: TextStyle(
                          fontFamily: 'Syne',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: theme.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          _StyledField(
            name: 'name',
            label: l10n.authFullName,
            hint: l10n.authFullNameHint,
            icon: Icons.person_outline_rounded,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(),
              FormBuilderValidators.minLength(2),
              FormBuilderValidators.maxLength(60),
              (value) => FormValidators.name(value),
            ]),
            theme: theme,
            capitalization: TextCapitalization.words,
          ),
          SizedBox(height: 14.h),
          _StyledField(
            name: 'email',
            label: l10n.authEmailAddress,
            hint: l10n.authEmailHint,
            icon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(),
              (value) => FormValidators.email(value),
            ]),
            theme: theme,
          ),
          SizedBox(height: 14.h),
          // International phone input with country codes
          IntlPhoneInput(
            key: _phoneKey,
            label: l10n.authPhoneOptional,
            hint: l10n.authPhoneHint,
            accentColor: theme.accent,
            fillColor: theme.accent.withOpacity(0.06),
            onChanged: (phone) => ref
                .read(signupWizardUiViewModelProvider.notifier)
                .setPhoneNumber(phone.isValid ? phone.fullNumber : null),
          ),
          SizedBox(height: 14.h),
          // DOB picker
          _DobPicker(
            selected: wizardUiState.dateOfBirth,
            accent: theme.accent,
            textColor: theme.text,
            cardBg: theme.card,
            onPicked: (d) => ref
                .read(signupWizardUiViewModelProvider.notifier)
                .setDateOfBirth(d),
          ),
          SizedBox(height: 28.h),
          _Divider(accent: theme.accent, label: l10n.orSignUpWith),
          SizedBox(height: 16.h),
          _GoogleButton(onPressed: _handleGoogleSignIn, l10n: l10n),
          SizedBox(height: 10.h),
          SignInWithAppleButton(
            onPressed: _handleAppleSignIn,
            text: l10n.continueWithApple,
            height: 48.h,
            borderRadius: BorderRadius.circular(14.r),
            style: SignInWithAppleButtonStyle.black,
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  // ── Step 2: Password ────────────────────────────────────────────────────────
  Widget _buildStep2(_StepTheme theme) {
    final l10n = AppLocalizations.of(context);
    final wizardUiState = ref.watch(signupWizardUiViewModelProvider);
    return FormBuilder(
      key: _formKeys[1],
      child: Column(
        key: const ValueKey('step2'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SecurityBadge(
            accent: theme.accent,
            text: l10n.use8CharactersWithLetters,
          ),
          SizedBox(height: 28.h),
          _StyledField(
            name: 'password',
            label: l10n.authCreatePassword,
            hint: l10n.authPasswordHint,
            icon: Icons.lock_outline_rounded,
            obscure: wizardUiState.obscurePassword,
            onChanged: (v) => ref
                .read(signupWizardUiViewModelProvider.notifier)
                .setPasswordText(v ?? ''),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(),
              (value) => FormValidators.password(value),
            ]),
            theme: theme,
            suffix: IconButton(
              icon: Icon(
                wizardUiState.obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: theme.accent,
              ),
              onPressed: () => ref
                  .read(signupWizardUiViewModelProvider.notifier)
                  .togglePasswordVisibility(),
            ),
          ),
          SizedBox(height: 14.h),
          _StyledField(
            name: 'confirm_password',
            label: l10n.authConfirmPassword,
            hint: l10n.authConfirmPasswordHint,
            icon: Icons.lock_outline_rounded,
            obscure: wizardUiState.obscureConfirmPassword,
            validator: (v) =>
                v !=
                    (_formKeys[1].currentState?.fields['password']?.value
                        as String?)
                ? 'Passwords do not match'
                : null,
            theme: theme,
            suffix: IconButton(
              icon: Icon(
                wizardUiState.obscureConfirmPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: theme.accent,
              ),
              onPressed: () => ref
                  .read(signupWizardUiViewModelProvider.notifier)
                  .toggleConfirmPasswordVisibility(),
            ),
          ),
          SizedBox(height: 20.h),
          _PasswordStrengthBar(
            password: wizardUiState.passwordText,
            accent: theme.accent,
          ),
          SizedBox(height: 28.h),
          _TermsCard(
            agreed: wizardUiState.agreedToTerms,
            accent: theme.accent,
            onToggle: () {
              ref
                  .read(signupWizardUiViewModelProvider.notifier)
                  .toggleTermsAgreement();
              HapticFeedback.selectionClick();
            },
            onTermsTap: () => context.push(AppRoutes.terms.path),
            onPrivacyTap: () => context.push(AppRoutes.privacy.path),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  // ── Step 3: Role & Interests ────────────────────────────────────────────────
  Widget _buildStep3(_StepTheme theme) {
    final l10n = AppLocalizations.of(context);
    final wizardUiState = ref.watch(signupWizardUiViewModelProvider);
    return FormBuilder(
      key: _formKeys[2],
      child: Column(
        key: const ValueKey('step3'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.iWantTo,
            style: TextStyle(
              fontFamily: 'Syne',
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: theme.text,
            ),
          ),
          SizedBox(height: 20.h),
          _RoleCard(
            role: UserRole.rider,
            isSelected: wizardUiState.selectedRole == UserRole.rider,
            accent: theme.accent,
            icon: Icons.person_pin_circle_rounded,
            title: l10n.wizardFindRides,
            desc: l10n.wizardFindRidesDesc,
            onTap: () {
              HapticFeedback.selectionClick();
              ref
                  .read(signupWizardUiViewModelProvider.notifier)
                  .setSelectedRole(UserRole.rider);
            },
          ),
          SizedBox(height: 12.h),
          _RoleCard(
            role: UserRole.driver,
            isSelected: wizardUiState.selectedRole == UserRole.driver,
            accent: theme.accent,
            icon: Icons.drive_eta_rounded,
            title: l10n.wizardOfferRides,
            desc: l10n.wizardOfferRidesDesc,
            onTap: () {
              HapticFeedback.selectionClick();
              ref
                  .read(signupWizardUiViewModelProvider.notifier)
                  .setSelectedRole(UserRole.driver);
            },
          ),
          SizedBox(height: 28.h),
          Text(
            l10n.yourInterestsOptional,
            style: TextStyle(
              fontFamily: 'Syne',
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: theme.text,
            ),
          ),
          SizedBox(height: 12.h),
          _InterestChips(
            interests: const [
              'Football',
              'Basketball',
              'Tennis',
              'Running',
              'Cycling',
              'Swimming',
              'Golf',
              'Gym',
              'Yoga',
              'Boxing',
              'Skiing',
              'Surfing',
            ],
            selected: wizardUiState.selectedInterests,
            accent: theme.accent,
            onToggle: (i) {
              HapticFeedback.selectionClick();
              ref
                  .read(signupWizardUiViewModelProvider.notifier)
                  .toggleInterest(i);
            },
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  // ── Step 4: Profile & Tree ──────────────────────────────────────────────────
  Widget _buildStep4(_StepTheme theme) {
    final l10n = AppLocalizations.of(context);
    final wizardUiState = ref.watch(signupWizardUiViewModelProvider);
    return FormBuilder(
      key: _formKeys[3],
      child: Column(
        key: const ValueKey('step4'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 8.h),

          // Avatar picker
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  Container(
                    width: 110.w,
                    height: 110.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.accent.withOpacity(0.12),
                      image: wizardUiState.profileImage != null
                          ? DecorationImage(
                              image: FileImage(wizardUiState.profileImage!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      border: Border.all(color: theme.accent, width: 3),
                    ),
                    child: wizardUiState.profileImage == null
                        ? Icon(
                            Icons.person_rounded,
                            size: 50.sp,
                            color: theme.accent.withOpacity(0.5),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      padding: EdgeInsets.all(7.w),
                      decoration: BoxDecoration(
                        color: theme.accent,
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.card, width: 2),
                      ),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        size: 16.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ).animate().scale(
            begin: const Offset(0.8, 0.8),
            duration: 400.ms,
            curve: Curves.elasticOut,
          ),
          SizedBox(height: 8.h),
          Text(
            l10n.addAProfilePhoto,
            style: TextStyle(
              fontFamily: 'Syne',
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: theme.text,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          _StyledField(
            name: 'bio',
            label: l10n.authAboutYou,
            hint: l10n.authAboutYouHint,
            icon: Icons.edit_note_rounded,
            maxLines: 3,
            theme: theme,
            validator: (value) => FormValidators.bio(value),
          ),
          SizedBox(height: 24.h),
          // Summary card
          Container(
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              color: theme.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: theme.accent.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Text(
                  'Almost There!',
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: theme.accent,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  l10n.emailValue(
                    (_formKeys[0].currentState?.fields['email']?.value
                            as String? ??
                        ''),
                  ),
                  style: TextStyle(fontSize: 13.sp, color: theme.text),
                ),
                Text(
                  l10n.roleValue(wizardUiState.selectedRole.displayName),
                  style: TextStyle(fontSize: 13.sp, color: theme.text),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  // ── Bottom CTA ──────────────────────────────────────────────────────────────
  Widget _buildBottomCTA(
    _StepTheme theme,
    AsyncValue<void> registerState,
    SocialAuthState socialState,
  ) {
    final currentStep = ref.watch(signupWizardUiViewModelProvider).currentStep;
    final isLast = currentStep == 3;
    final isLoading = registerState.isLoading || socialState.isLoading;

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: _kBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: () => _goToStep(currentStep + 1),
          child: AnimatedContainer(
            duration: 300.ms,
            height: 54.h,
            decoration: BoxDecoration(
              color: theme.accent,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: theme.accent.withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 24.w,
                      height: 24.w,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLast
                              ? AppLocalizations.of(context).createAccount
                              : AppLocalizations.of(context).wizardContinue,
                          style: TextStyle(
                            fontFamily: 'Syne',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(
                          isLast
                              ? Icons.check_rounded
                              : Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 20.sp,
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

// ─── Helper Widgets ───────────────────────────────────────────────────────────

class _SecurityBadge extends StatelessWidget {
  final Color accent;
  final String text;
  const _SecurityBadge({required this.accent, required this.text});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      color: accent.withOpacity(0.08),
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: accent.withOpacity(0.25)),
    ),
    child: Row(
      children: [
        Icon(Icons.verified_user_rounded, color: accent, size: 28.sp),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13.sp, color: accent),
          ),
        ),
      ],
    ),
  );
}

class _StyledField extends StatelessWidget {
  final String name;
  final String label, hint;
  final IconData icon;
  final bool obscure;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffix;
  final _StepTheme theme;
  final TextCapitalization capitalization;
  final ValueChanged<String?>? onChanged;

  const _StyledField({
    required this.name,
    required this.label,
    required this.hint,
    required this.icon,
    required this.theme,
    this.obscure = false,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
    this.suffix,
    this.capitalization = TextCapitalization.none,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) => FormBuilderTextField(
    name: name,
    obscureText: obscure,
    maxLines: maxLines,
    keyboardType: keyboardType,
    validator: validator,
    textCapitalization: capitalization,
    onChanged: onChanged,
    style: TextStyle(fontSize: 15.sp, color: theme.text),
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: theme.accent, size: 20.sp),
      suffixIcon: suffix,
      labelStyle: TextStyle(
        color: theme.accent.withOpacity(0.8),
        fontSize: 13.sp,
      ),
      hintStyle: TextStyle(
        color: theme.text.withOpacity(0.35),
        fontSize: 14.sp,
      ),
      filled: true,
      fillColor: theme.accent.withOpacity(0.06),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: theme.accent.withOpacity(0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: theme.accent.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: theme.accent, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: Colors.red.shade400),
      ),
    ),
  );
}

// ─── Custom Inline DOB Picker ─────────────────────────────────────────────────
// Tap the row to expand a three-column scroll-wheel (Day | Month | Year).
// No system dialog — fully on-brand with the Road Trip wizard theme.

class _DobPicker extends StatefulWidget {
  final DateTime? selected;
  final Color accent, textColor, cardBg;
  final ValueChanged<DateTime> onPicked;

  const _DobPicker({
    required this.selected,
    required this.accent,
    required this.textColor,
    required this.cardBg,
    required this.onPicked,
  });

  @override
  State<_DobPicker> createState() => _DobPickerState();
}

class _DobPickerState extends State<_DobPicker>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _expandCtrl;
  late Animation<double> _expandAnim;

  late FixedExtentScrollController _dayCtrl;
  late FixedExtentScrollController _monthCtrl;
  late FixedExtentScrollController _yearCtrl;

  static const double _itemH = 42.0;
  static const int _visibleItems = 3;

  late int _day;
  late int _month; // 0-indexed
  late int _year;

  static const _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  int get _daysInMonth => DateTime(_year, _month + 1 + 1, 0).day;

  @override
  void initState() {
    super.initState();
    final init = widget.selected ?? DateTime(DateTime.now().year - 25, 6, 15);
    _day = init.day;
    _month = init.month - 1;
    _year = init.year;

    _dayCtrl = FixedExtentScrollController(initialItem: _day - 1);
    _monthCtrl = FixedExtentScrollController(initialItem: _month);
    _yearCtrl = FixedExtentScrollController(initialItem: _year - 1920);

    _expandCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _expandAnim = CurvedAnimation(
      parent: _expandCtrl,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _expandCtrl.dispose();
    _dayCtrl.dispose();
    _monthCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _expandCtrl.forward() : _expandCtrl.reverse();
    HapticFeedback.selectionClick();
  }

  void _emit() {
    final clampedDay = _day.clamp(1, _daysInMonth);
    widget.onPicked(DateTime(_year, _month + 1, clampedDay));
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = widget.selected != null;
    final accent = widget.accent;
    final textCol = widget.textColor;
    final cardBg = widget.cardBg;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Trigger row ──────────────────────────────────────────────
        GestureDetector(
          onTap: _toggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.06),
              borderRadius: _expanded
                  ? BorderRadius.vertical(top: Radius.circular(14.r))
                  : BorderRadius.circular(14.r),
              border: Border.all(
                color: _expanded || hasValue ? accent : accent.withOpacity(0.2),
                width: _expanded ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.cake_outlined, color: accent, size: 20.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).authDateOfBirth,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: accent.withOpacity(0.75),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        hasValue
                            ? '${widget.selected!.day} '
                                  '${_monthNames[widget.selected!.month - 1]} '
                                  '${widget.selected!.year}'
                            : AppLocalizations.of(context).authDobPrompt,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: hasValue ? textCol : textCol.withOpacity(0.38),
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 260),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: accent,
                    size: 24.sp,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Expandable wheel panel ────────────────────────────────────
        SizeTransition(
          sizeFactor: _expandAnim,
          child: Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(14.r),
              ),
              border: Border(
                left: BorderSide(color: accent, width: 2),
                right: BorderSide(color: accent, width: 2),
                bottom: BorderSide(color: accent, width: 2),
              ),
            ),
            child: Column(
              children: [
                // Column labels
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
                  child: Row(
                    children: [
                      Expanded(child: _colLabel('DAY', accent)),
                      Expanded(child: _colLabel('MONTH', accent)),
                      Expanded(child: _colLabel('YEAR', accent)),
                    ],
                  ),
                ),

                // Wheel columns with overlay gradients
                SizedBox(
                  height: _itemH * _visibleItems,
                  child: Stack(
                    children: [
                      // Selection highlight
                      Positioned(
                        top: _itemH * (_visibleItems ~/ 2),
                        left: 10.w,
                        right: 10.w,
                        height: _itemH,
                        child: Container(
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.11),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(color: accent.withOpacity(0.3)),
                          ),
                        ),
                      ),
                      // Three ListWheelScrollViews
                      Row(
                        children: [
                          // Day
                          Expanded(
                            child: ListWheelScrollView.useDelegate(
                              controller: _dayCtrl,
                              itemExtent: _itemH,
                              physics: const FixedExtentScrollPhysics(),
                              perspective: 0.003,
                              onSelectedItemChanged: (i) {
                                setState(() => _day = i + 1);
                                _emit();
                              },
                              childDelegate: ListWheelChildBuilderDelegate(
                                childCount: 31,
                                builder: (_, i) => _wheelCell(
                                  '${i + 1}',
                                  i == _day - 1,
                                  accent,
                                  textCol,
                                ),
                              ),
                            ),
                          ),
                          // Month
                          Expanded(
                            child: ListWheelScrollView.useDelegate(
                              controller: _monthCtrl,
                              itemExtent: _itemH,
                              physics: const FixedExtentScrollPhysics(),
                              perspective: 0.003,
                              onSelectedItemChanged: (i) {
                                setState(() => _month = i);
                                _emit();
                              },
                              childDelegate: ListWheelChildBuilderDelegate(
                                childCount: 12,
                                builder: (_, i) => _wheelCell(
                                  _monthNames[i],
                                  i == _month,
                                  accent,
                                  textCol,
                                ),
                              ),
                            ),
                          ),
                          // Year
                          Expanded(
                            child: ListWheelScrollView.useDelegate(
                              controller: _yearCtrl,
                              itemExtent: _itemH,
                              physics: const FixedExtentScrollPhysics(),
                              perspective: 0.003,
                              onSelectedItemChanged: (i) {
                                setState(() => _year = 1920 + i);
                                _emit();
                              },
                              childDelegate: ListWheelChildBuilderDelegate(
                                childCount: DateTime.now().year - 1920 + 1,
                                builder: (_, i) => _wheelCell(
                                  '${1920 + i}',
                                  (1920 + i) == _year,
                                  accent,
                                  textCol,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Top fade mask
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: _itemH * 0.85,
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [cardBg, cardBg.withOpacity(0)],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Bottom fade mask
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: _itemH * 0.85,
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [cardBg, cardBg.withOpacity(0)],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 10.h),

                // Confirm button
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 14.h),
                  child: GestureDetector(
                    onTap: () {
                      _emit();
                      _toggle();
                    },
                    child: Container(
                      height: 42.h,
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Center(
                        child: Text(
                          'Confirm Date',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _colLabel(String label, Color accent) => Text(
    label,
    textAlign: TextAlign.center,
    style: TextStyle(
      fontSize: 10.sp,
      fontWeight: FontWeight.w700,
      color: accent.withOpacity(0.55),
      letterSpacing: 1.4,
    ),
  );

  Widget _wheelCell(String label, bool selected, Color accent, Color textCol) =>
      Center(
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 140),
          style: TextStyle(
            fontSize: selected ? 17.sp : 13.sp,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w400,
            color: selected ? accent : textCol.withOpacity(0.35),
          ),
          child: Text(label),
        ),
      );
}

class _Divider extends StatelessWidget {
  final Color accent;
  final String label;
  const _Divider({required this.accent, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Divider(color: accent.withOpacity(0.2))),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: accent.withOpacity(0.6)),
        ),
      ),
      Expanded(child: Divider(color: accent.withOpacity(0.2))),
    ],
  );
}

class _GoogleButton extends StatelessWidget {
  final VoidCallback onPressed;
  final AppLocalizations l10n;
  const _GoogleButton({required this.onPressed, required this.l10n});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 48.h,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
        side: const BorderSide(color: Color(0xFF747775)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/google_g_logo.svg',
            height: 20.sp,
            width: 20.sp,
          ),
          SizedBox(width: 10.w),
          Text(
            l10n.continueWithGoogle,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1F1F1F),
            ),
          ),
        ],
      ),
    ),
  );
}

class _PasswordStrengthBar extends StatelessWidget {
  final String password;
  final Color accent;
  const _PasswordStrengthBar({required this.password, required this.accent});

  @override
  Widget build(BuildContext context) {
    final pw = password;
    int s = 0;
    if (pw.length >= 8) s++;
    if (pw.contains(RegExp(r'[A-Z]'))) s++;
    if (pw.contains(RegExp(r'[0-9]'))) s++;
    if (pw.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) s++;
    final colors = [Colors.red, Colors.orange, Colors.lightBlue, Colors.green];
    final labels = ['Weak', 'Fair', 'Good', 'Strong'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).passwordStrength,
          style: TextStyle(fontSize: 12.sp, color: accent.withOpacity(0.7)),
        ),
        SizedBox(height: 6.h),
        Row(
          children: List.generate(
            4,
            (i) => Expanded(
              child: Container(
                height: 5.h,
                margin: EdgeInsets.only(right: i < 3 ? 4.w : 0),
                decoration: BoxDecoration(
                  color: i < s ? colors[s - 1] : accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
            ),
          ),
        ),
        if (pw.isNotEmpty) ...[
          SizedBox(height: 4.h),
          Text(
            labels[s > 0 ? s - 1 : 0],
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: s > 0 ? colors[s - 1] : Colors.red,
            ),
          ),
        ],
      ],
    );
  }
}

class _TermsCard extends StatelessWidget {
  final bool agreed;
  final Color accent;
  final VoidCallback onToggle, onTermsTap, onPrivacyTap;
  const _TermsCard({
    required this.agreed,
    required this.accent,
    required this.onToggle,
    required this.onTermsTap,
    required this.onPrivacyTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onToggle,
    child: AnimatedContainer(
      duration: 200.ms,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: agreed ? accent.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: agreed ? accent : accent.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: 200.ms,
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              color: agreed ? accent : Colors.transparent,
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(color: accent, width: 2),
            ),
            child: agreed
                ? Icon(Icons.check_rounded, size: 15.sp, color: Colors.white)
                : null,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 13.sp,
                  color: accent.withOpacity(0.8),
                ),
                children: [
                  const TextSpan(text: 'I agree to the '),
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = onTermsTap,
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = onPrivacyTap,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _RoleCard extends StatelessWidget {
  final UserRole role;
  final bool isSelected;
  final Color accent;
  final IconData icon;
  final String title, desc;
  final VoidCallback onTap;
  const _RoleCard({
    required this.role,
    required this.isSelected,
    required this.accent,
    required this.icon,
    required this.title,
    required this.desc,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: 250.ms,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: isSelected ? accent.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isSelected ? accent : accent.withOpacity(0.25),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: accent.withOpacity(0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: isSelected ? accent : accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              icon,
              size: 26.sp,
              color: isSelected ? Colors.white : accent,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? accent : Colors.black87,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  desc,
                  style: TextStyle(fontSize: 12.sp, color: Colors.black54),
                ),
              ],
            ),
          ),
          if (isSelected)
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
              child: Icon(
                Icons.check_rounded,
                size: 14.sp,
                color: Colors.white,
              ),
            ),
        ],
      ),
    ),
  );
}

class _InterestChips extends StatelessWidget {
  final List<String> interests;
  final List<String> selected;
  final Color accent;
  final ValueChanged<String> onToggle;
  const _InterestChips({
    required this.interests,
    required this.selected,
    required this.accent,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8.w,
    runSpacing: 8.h,
    children: interests.map((i) {
      final sel = selected.contains(i);
      return GestureDetector(
        onTap: () => onToggle(i),
        child: AnimatedContainer(
          duration: 200.ms,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
          decoration: BoxDecoration(
            color: sel ? accent.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(25.r),
            border: Border.all(
              color: sel ? accent : accent.withOpacity(0.3),
              width: sel ? 2 : 1,
            ),
          ),
          child: Text(
            i,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
              color: sel ? accent : Colors.black54,
            ),
          ),
        ),
      );
    }).toList(),
  );
}
