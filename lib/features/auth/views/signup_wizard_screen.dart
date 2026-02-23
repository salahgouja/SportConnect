import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/app_spacing.dart';
import 'package:sport_connect/core/utils/validators.dart';
import 'package:sport_connect/core/widgets/custom_button.dart';
import 'package:sport_connect/core/widgets/premium_text_field.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Wizard step data
class _WizardStep {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _WizardStep({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

/// Premium Signup Wizard with multi-step flow
class SignupWizardScreen extends ConsumerStatefulWidget {
  const SignupWizardScreen({super.key});

  @override
  ConsumerState<SignupWizardScreen> createState() => _SignupWizardScreenState();
}

class _SignupWizardScreenState extends ConsumerState<SignupWizardScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Form keys for each step
  final List<GlobalKey<FormState>> _formKeys = List.generate(
    4,
    (_) => GlobalKey<FormState>(),
  );

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();

  // State
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  UserRole _selectedRole = UserRole.rider;
  File? _profileImage;
  DateTime? _dateOfBirth;
  final List<String> _selectedInterests = [];

  final List<_WizardStep> _steps = [
    _WizardStep(
      title: 'Welcome',
      subtitle: 'Let\'s get you started',
      icon: Icons.waving_hand_rounded,
      color: AppColors.primary,
    ),
    _WizardStep(
      title: 'Security',
      subtitle: 'Create a secure password',
      icon: Icons.lock_rounded,
      color: AppColors.info,
    ),
    _WizardStep(
      title: 'Your Role',
      subtitle: 'How will you use SportConnect?',
      icon: Icons.person_rounded,
      color: AppColors.warning,
    ),
    _WizardStep(
      title: 'Profile',
      subtitle: 'Make it personal',
      icon: Icons.face_rounded,
      color: AppColors.secondary,
    ),
  ];

  final List<String> _availableInterests = [
    '⚽ Football',
    '🏀 Basketball',
    '🎾 Tennis',
    '🏃 Running',
    '🚴 Cycling',
    '🏊 Swimming',
    '⛳ Golf',
    '🏋️ Gym',
    '🧘 Yoga',
    '🥊 Boxing',
    '🎿 Skiing',
    '🏄 Surfing',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
      HapticFeedback.lightImpact();
    }
  }

  void _nextStep() {
    if (_formKeys[_currentStep].currentState != null) {
      if (!_formKeys[_currentStep].currentState!.validate()) return;
    }

    // Step 0: validate DOB (minimum age 18)
    if (_currentStep == 0 && _dateOfBirth == null) {
      _showError('Please enter your date of birth.');
      return;
    }
    if (_currentStep == 0 && _dateOfBirth != null) {
      final age = DateTime.now().difference(_dateOfBirth!).inDays ~/ 365;
      if (age < 18) {
        _showError(
          'You must be at least 18 years old to use SportConnect.',
        );
        return;
      }
    }

    if (_currentStep == 1 && !_agreedToTerms) {
      _showError('Please agree to the Terms of Service');
      return;
    }

    FocusScope.of(context).unfocus();
    HapticFeedback.mediumImpact();

    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _handleSignup();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      HapticFeedback.lightImpact();
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  Future<void> _handleSignup() async {
    try {
      await ref
          .read(registerViewModelProvider.notifier)
          .register(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            displayName: _nameController.text.trim(),
            role: _selectedRole,
            phone: _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
            bio: _bioController.text.trim().isEmpty
                ? null
                : _bioController.text.trim(),
            interests: _selectedInterests,
            profileImage: _profileImage,
          );

      // Registration successful - navigation handled by listener
    } catch (_) {
      _showError('Unable to create your account right now. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentStep == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _previousStep();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildProgressIndicator(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) =>
                      setState(() => _currentStep = index),
                  children: [
                    _buildStep1(),
                    _buildStep2(),
                    _buildStep3(),
                    _buildStep4(),
                  ],
                ),
              ),
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final step = _steps[_currentStep];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Row(
        children: [
          // Back button
          if (_currentStep > 0)
            GestureDetector(
              onTap: _previousStep,
              child: Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: AppSpacing.shadowSm,
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18.sp,
                  color: AppColors.textPrimary,
                ),
              ),
            ).animate().fadeIn(duration: 200.ms)
          else
            GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: AppSpacing.shadowSm,
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 18.sp,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

          SizedBox(width: 16.w),

          // Title section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    step.title,
                    key: ValueKey(step.title),
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    step.subtitle,
                    key: ValueKey(step.subtitle),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Step icon
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [step.color, step.color.withAlpha((255 * 0.7).toInt())],
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: step.color.withAlpha((0.3 * 255).toInt()),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(step.icon, color: Colors.white, size: 24.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          // 1. Step Indicators (Nodes & Lines)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < _steps.length; i++) ...[
                // The Step Node (Circle + Text)
                _buildStepNode(i),

                // The Connector Line (Add between nodes, but not after the last one)
                if (i < _steps.length - 1)
                  Expanded(
                    child: AnimatedContainer(
                      margin: EdgeInsets.only(top: 16.w - 1.h),
                      height: 2.h,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      decoration: BoxDecoration(
                        color: i < _currentStep
                            ? AppColors
                                  .success // Completed connection
                            : AppColors.surface, // Inactive connection
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ).animate().fadeIn(),
                  ),
              ],
            ],
          ),

          SizedBox(height: 24.h),

          // 2. Animated Progress Bar (Smooth Math)
          TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: 0,
              end: (_currentStep + 1) / _steps.length,
            ),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: LinearProgressIndicator(
                  value: value,
                  backgroundColor: AppColors.surface,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    // Smooth color transition based on step
                    _steps[_currentStep].color,
                  ),
                  minHeight: 6.h,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Helper widget to keep the main tree clean
  Widget _buildStepNode(int index) {
    final isCompleted = index < _currentStep;
    final isCurrent = index == _currentStep;
    final step = _steps[index];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // The Circle
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: isCompleted
                ? AppColors.success
                : isCurrent
                ? step.color
                : AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: isCompleted || isCurrent
                  ? Colors.transparent
                  : AppColors.border,
              width: 2,
            ),
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: step.color.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: isCompleted
                ? Icon(Icons.check_rounded, size: 18.sp, color: Colors.white)
                : Text(
                    AppLocalizations.of(context).value2(index + 1),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: isCurrent ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
          ),
        ),

        SizedBox(height: 8.h),

        // The Label
        SizedBox(
          width: 60.w, // Constrain width to prevent text from hitting neighbors
          child: Text(
            step.title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
              color: isCurrent
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Form(
        key: _formKeys[0],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 16.h),

            // Welcome message
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withAlpha((0.1 * 255).toInt()),
                    AppColors.secondary.withAlpha((0.05 * 255).toInt()),
                  ],
                ),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: AppColors.primary.withAlpha((0.2 * 255).toInt()),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context).text2,
                    style: TextStyle(fontSize: 48.sp),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    AppLocalizations.of(context).join10000EcoRiders,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    AppLocalizations.of(context).get100XpWelcomeBonus,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),

            SizedBox(height: 32.h),

            // Name field
            PremiumTextField(
              controller: _nameController,
              label: 'Full Name',
              hint: 'Enter your full name',
              prefixIcon: Icons.person_outline_rounded,
              validator: Validators.name,
              textCapitalization: TextCapitalization.words,
            ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),

            SizedBox(height: 20.h),

            // Email field
            PremiumTextField(
              controller: _emailController,
              label: 'Email Address',
              hint: 'you@example.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
            ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),

            SizedBox(height: 20.h),

            // Phone field (optional)
            PremiumTextField(
              controller: _phoneController,
              label: 'Phone Number (Optional)',
              hint: '+216 XX XXX XXX',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),

            SizedBox(height: 20.h),

            // Date of Birth field (required for age verification)
            GestureDetector(
              onTap: () async {
                final now = DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _dateOfBirth ??
                      DateTime(now.year - 18, now.month, now.day),
                  firstDate: DateTime(1920),
                  lastDate: now,
                  helpText: 'Select your date of birth',
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: AppColors.primary,
                          onSurface: AppColors.textPrimary,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  setState(() => _dateOfBirth = picked);
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 16.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: _dateOfBirth != null
                        ? AppColors.primary.withAlpha(100)
                        : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.cake_outlined,
                      color: _dateOfBirth != null
                          ? AppColors.primary
                          : AppColors.textTertiary,
                      size: 22.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date of Birth *',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.textTertiary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            _dateOfBirth != null
                                ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                                : 'Tap to select (must be 18+)',
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: _dateOfBirth != null
                                  ? AppColors.textPrimary
                                  : AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down_rounded,
                      color: AppColors.textTertiary,
                      size: 24.sp,
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 450.ms).slideX(begin: -0.1),

            SizedBox(height: 32.h),

            // Social signup options
            Text(
              AppLocalizations.of(context).orSignUpWith,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 500.ms),

            SizedBox(height: 16.h),

            // Professional social signup options
            _ProfessionalSocialButton(
              icon: Icons.g_mobiledata_rounded,
              iconColor: Colors.white,
              label: 'Continue with Google',
              backgroundColor: const Color(0xFF4285F4),
              onPressed: _handleGoogleSignIn,
            ),
            SizedBox(height: 12.h),
            _ProfessionalSocialButton(
              icon: Icons.apple_rounded,
              iconColor: Colors.white,
              label: 'Continue with Apple',
              backgroundColor: const Color(0xFF1A1A1A),
              onPressed: _handleAppleSignIn,
            ).animate().fadeIn(delay: 650.ms).slideY(begin: 0.1),
          ],
        ),
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      final authActions = ref.read(authActionsViewModelProvider);
      await authActions.signInWithGoogle();
      // Route guard handles redirect based on needsRoleSelection field in Firestore
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _handleAppleSignIn() async {
    try {
      final authActions = ref.read(authActionsViewModelProvider);
      await authActions.signInWithApple();
      // Route guard handles redirect based on needsRoleSelection field in Firestore
    } catch (e) {
      _showError(e.toString());
    }
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Form(
        key: _formKeys[1],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 16.h),

            // Security tips
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.info.withAlpha((0.1 * 255).toInt()),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: AppColors.info.withAlpha((0.3 * 255).toInt()),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.shield_rounded,
                    color: AppColors.info,
                    size: 24.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context).strongPasswordTips,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          AppLocalizations.of(
                            context,
                          ).use8CharactersWithLetters,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms),

            SizedBox(height: 32.h),

            // Password field
            PremiumTextField(
              controller: _passwordController,
              label: 'Create Password',
              hint: 'Min 8 characters',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: _obscurePassword,
              validator: Validators.password,
              suffix: IconButton(
                tooltip: 'Toggle password visibility',
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textTertiary,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),

            SizedBox(height: 20.h),

            // Confirm password field
            PremiumTextField(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              hint: 'Re-enter your password',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: _obscureConfirmPassword,
              validator: (value) =>
                  Validators.confirmPassword(value, _passwordController.text),
              suffix: IconButton(
                tooltip: 'Toggle password visibility',
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textTertiary,
                ),
                onPressed: () {
                  setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  );
                },
              ),
            ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),

            SizedBox(height: 24.h),

            // Password strength indicator
            _buildPasswordStrength(),

            SizedBox(height: 32.h),

            // Terms checkbox
            _buildTermsCheckbox().animate().fadeIn(delay: 400.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordStrength() {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _passwordController,
      builder: (context, value, child) {
        final password = value.text;
        int strength = 0;
        if (password.length >= 8) strength++;
        if (password.contains(RegExp(r'[A-Z]'))) strength++;
        if (password.contains(RegExp(r'[0-9]'))) strength++;
        if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

        final colors = [
          AppColors.error,
          AppColors.warning,
          AppColors.info,
          AppColors.success,
        ];
        final labels = ['Weak', 'Fair', 'Good', 'Strong'];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).passwordStrength,
              style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: 8.h),
            Row(
              children: List.generate(4, (index) {
                return Expanded(
                  child: Container(
                    height: 4.h,
                    margin: EdgeInsets.only(right: index < 3 ? 4.w : 0),
                    decoration: BoxDecoration(
                      color: index < strength
                          ? colors[strength - 1]
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 4.h),
            if (password.isNotEmpty)
              Text(
                labels[strength > 0 ? strength - 1 : 0],
                style: TextStyle(
                  fontSize: 12.sp,
                  color: strength > 0 ? colors[strength - 1] : AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ).animate().fadeIn(delay: 350.ms);
      },
    );
  }

  Widget _buildTermsCheckbox() {
    return InkWell(
      onTap: () {
        setState(() => _agreedToTerms = !_agreedToTerms);
        HapticFeedback.selectionClick();
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: _agreedToTerms
              ? AppColors.success.withAlpha((0.1 * 255).toInt())
              : AppColors.cardBg,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: _agreedToTerms ? AppColors.success : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                color: _agreedToTerms ? AppColors.success : Colors.transparent,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(
                  color: _agreedToTerms ? AppColors.success : AppColors.border,
                  width: 2,
                ),
              ),
              child: _agreedToTerms
                  ? Icon(Icons.check_rounded, size: 16.sp, color: Colors.white)
                  : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                  ),
                  children: [
                    const TextSpan(text: 'I agree to the '),
                    TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          context.push(AppRoutes.terms.path);
                        },
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          context.push(AppRoutes.privacy.path);
                        },
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

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Form(
        key: _formKeys[2],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 8.h),

            Text(
              AppLocalizations.of(context).iWantTo,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ).animate().fadeIn(delay: 100.ms),

            SizedBox(height: 20.h),

            // Role selection cards
            _RoleSelectionCard(
              role: UserRole.rider,
              isSelected: _selectedRole == UserRole.rider,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedRole = UserRole.rider);
              },
              icon: Icons.person_pin_circle_rounded,
              title: 'Find Rides',
              description:
                  'Search for rides to sporting events, practices, and games',
              gradient: const [AppColors.info, AppColors.infoDark],
            ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),

            SizedBox(height: 16.h),

            _RoleSelectionCard(
              role: UserRole.driver,
              isSelected: _selectedRole == UserRole.driver,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedRole = UserRole.driver);
              },
              icon: Icons.drive_eta_rounded,
              title: 'Offer Rides',
              description: 'Share your car and earn money while helping others',
              gradient: const [AppColors.primary, AppColors.primaryLight],
            ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),

            SizedBox(height: 32.h),

            // Interests section
            Text(
              AppLocalizations.of(context).yourInterestsOptional,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ).animate().fadeIn(delay: 500.ms),

            SizedBox(height: 4.h),

            Text(
              AppLocalizations.of(context).selectSportsYouReInterested,
              style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
            ).animate().fadeIn(delay: 500.ms),

            SizedBox(height: 16.h),

            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: _availableInterests.map((interest) {
                final isSelected = _selectedInterests.contains(interest);
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      if (isSelected) {
                        _selectedInterests.remove(interest);
                      } else {
                        _selectedInterests.add(interest);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withAlpha((0.1 * 255).toInt())
                          : AppColors.cardBg,
                      borderRadius: BorderRadius.circular(25.r),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      interest,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ).animate().fadeIn(delay: 600.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Form(
        key: _formKeys[3],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 16.h),

            // Profile picture
            Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        Container(
                          width: 140.w,
                          height: 140.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: _profileImage == null
                                ? AppColors.primaryGradient
                                : null,
                            image: _profileImage != null
                                ? DecorationImage(
                                    image: FileImage(_profileImage!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withAlpha(
                                  (0.3 * 255).toInt(),
                                ),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: _profileImage == null
                              ? Icon(
                                  Icons.person_rounded,
                                  size: 60.sp,
                                  color: Colors.white.withAlpha(
                                    (0.8 * 255).toInt(),
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              color: AppColors.cardBg,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.background,
                                width: 3,
                              ),
                              boxShadow: AppSpacing.shadowMd,
                            ),
                            child: Icon(
                              Icons.camera_alt_rounded,
                              size: 20.sp,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .animate()
                .fadeIn(delay: 100.ms)
                .scale(begin: const Offset(0.8, 0.8)),

            SizedBox(height: 12.h),

            Text(
              AppLocalizations.of(context).addAProfilePhoto,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms),

            Text(
              AppLocalizations.of(context).thisHelpsOthersRecognizeYou,
              style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms),

            SizedBox(height: 32.h),

            // Bio field
            PremiumTextField(
              controller: _bioController,
              label: 'About You (Optional)',
              hint: 'Tell us a bit about yourself...',
              prefixIcon: Icons.edit_note_rounded,
              maxLines: 3,
            ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),

            SizedBox(height: 32.h),

            // Account summary
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppColors.success.withAlpha((0.1 * 255).toInt()),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: AppColors.success.withAlpha((0.3 * 255).toInt()),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                    size: 48.sp,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    AppLocalizations.of(context).readyToJoin,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    AppLocalizations.of(
                      context,
                    ).emailValue(_emailController.text),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(
                      context,
                    ).roleValue(_selectedRole.displayName),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final isLastStep = _currentStep == _steps.length - 1;

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).toInt()),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: PremiumButton(
          text: isLastStep ? 'Create Account' : 'Continue',
          onPressed: _nextStep,
          isLoading: ref.watch(registerViewModelProvider).isLoading,
          style: PremiumButtonStyle.gradient,
          icon: isLastStep ? Icons.check_rounded : Icons.arrow_forward_rounded,
          iconRight: true,
        ),
      ),
    );
  }
}

/// Role selection card widget
class _RoleSelectionCard extends StatelessWidget {
  final UserRole role;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradient;

  const _RoleSelectionCard({
    required this.role,
    required this.isSelected,
    required this.onTap,
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: isSelected
              ? gradient[0].withAlpha((0.1 * 255).toInt())
              : AppColors.cardBg,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? gradient[0] : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: gradient[0].withAlpha((0.2 * 255).toInt()),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                gradient: isSelected ? LinearGradient(colors: gradient) : null,
                color: isSelected ? null : AppColors.surface,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                icon,
                size: 28.sp,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? gradient[0] : AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
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
            if (isSelected)
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 16.sp,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Professional social login button with clean styling
class _ProfessionalSocialButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Color backgroundColor;
  final VoidCallback onPressed;

  const _ProfessionalSocialButton({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.backgroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [
              BoxShadow(
                color: backgroundColor.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24.sp, color: iconColor),
              SizedBox(width: 12.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: iconColor,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
