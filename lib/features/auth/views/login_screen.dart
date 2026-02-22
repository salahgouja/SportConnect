import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/utils/validators.dart';
import 'package:sport_connect/core/widgets/custom_button.dart';
import 'package:sport_connect/core/widgets/premium_text_field.dart';
import 'package:sport_connect/core/widgets/utility_widgets.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Professional Login Screen with clean, modern design
/// No animated characters - just elegant branding and smooth UX
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _rememberMe = false;
  bool _isSocialLoading = false;
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadSavedCredentials();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email');
    final rememberMe = prefs.getBool('remember_me') ?? false;

    if (rememberMe && savedEmail != null) {
      setState(() {
        _emailController.text = savedEmail;
        _rememberMe = true;
      });
    }
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('saved_email', _emailController.text.trim());
      await prefs.setBool('remember_me', true);
    } else {
      await prefs.remove('saved_email');
      await prefs.setBool('remember_me', false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    await _saveCredentials();
    try {
      await ref
          .read(loginViewModelProvider.notifier)
          .login(
            _emailController.text.trim(),
            _passwordController.text,
            _rememberMe,
          );
    } catch (e) {
      if (!mounted) return;
      final errorMessage = _getAuthErrorMessage(e);
      TalkerService.error('Login failed: $errorMessage');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade600,
          duration: const Duration(seconds: 5),
          margin: EdgeInsets.all(16.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isSocialLoading) return;
    setState(() => _isSocialLoading = true);
    try {
      final authActions = ref.read(authActionsViewModelProvider);
      await authActions.signInWithGoogle();
      // Route guard handles redirect based on needsRoleSelection field in Firestore
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).signInFailedPleaseTry),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSocialLoading = false);
    }
  }

  Future<void> _handleAppleSignIn() async {
    if (_isSocialLoading) return;
    setState(() => _isSocialLoading = true);
    try {
      final authActions = ref.read(authActionsViewModelProvider);
      await authActions.signInWithApple();
      // Route guard handles redirect based on needsRoleSelection field in Firestore
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).signInFailedPleaseTry),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSocialLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 40.h),

                    // Professional logo header
                    _buildLogoHeader(),

                    SizedBox(height: 32.h),

                    // Welcome text
                    _buildWelcomeText(),

                    SizedBox(height: 32.h),

                    // Social login buttons
                    _buildSocialButtons(),

                    SizedBox(height: 24.h),

                    // Divider
                    _buildDivider(),

                    SizedBox(height: 24.h),

                    // Email field
                    _buildEmailField(),

                    SizedBox(height: 16.h),

                    // Password field
                    _buildPasswordField(),

                    SizedBox(height: 14.h),

                    // Remember me & Forgot password
                    _buildOptionsRow(),

                    SizedBox(height: 28.h),

                    // Sign in button
                    _buildSignInButton(loginState),

                    SizedBox(height: 28.h),

                    // Sign up link
                    _buildSignUpLink(),

                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoHeader() {
    return Column(
      children: [
        // Logo icon
        Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 24,
                    spreadRadius: 0,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.directions_run_rounded,
                  size: 40.sp,
                  color: Colors.white,
                ),
              ),
            )
            .animate()
            .fadeIn(duration: 500.ms)
            .scale(
              begin: const Offset(0.8, 0.8),
              curve: Curves.easeOutBack,
              duration: 600.ms,
            ),

        SizedBox(height: 16.h),

        // App name
        Text(
          AppLocalizations.of(context).sportconnect,
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
      ],
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      children: [
        Text(
              AppLocalizations.of(context).welcomeBack,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: 150.ms)
            .slideY(begin: 0.2, curve: Curves.easeOutCubic),
        SizedBox(height: 8.h),
        Text(
          AppLocalizations.of(context).signInToContinueYour,
          style: TextStyle(fontSize: 15.sp, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
      ],
    );
  }

  Widget _buildEmailField() {
    return PremiumTextField(
      controller: _emailController,
      focusNode: _emailFocus,
      label: AppLocalizations.of(context).email,
      hint: AppLocalizations.of(context).enterYourEmail,
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator: Validators.email,
    ).animate().fadeIn(duration: 400.ms, delay: 350.ms);
  }

  Widget _buildPasswordField() {
    return PremiumTextField(
      controller: _passwordController,
      focusNode: _passwordFocus,
      label: AppLocalizations.of(context).password,
      hint: AppLocalizations.of(context).enterYourPassword,
      prefixIcon: Icons.lock_outline_rounded,
      obscureText: true,
      textInputAction: TextInputAction.done,
      validator: Validators.password,
      onSubmitted: (_) => _handleLogin(),
    ).animate().fadeIn(duration: 400.ms, delay: 400.ms);
  }

  Widget _buildOptionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Remember Me
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              _rememberMe = !_rememberMe;
            });
          },
          child: Row(
            children: [
              AnimatedContainer(
                duration: 200.ms,
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  color: _rememberMe ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(5.r),
                  border: Border.all(
                    color: _rememberMe ? AppColors.primary : AppColors.border,
                    width: 2,
                  ),
                ),
                child: _rememberMe
                    ? Icon(
                        Icons.check_rounded,
                        size: 14.sp,
                        color: Colors.white,
                      )
                    : null,
              ),
              SizedBox(width: 8.w),
              Text(
                AppLocalizations.of(context).rememberMe,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        // Forgot Password
        TextButton(
          onPressed: _showForgotPasswordDialog,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: EdgeInsets.zero,
          ),
          child: Text(
            AppLocalizations.of(context).authForgotPassword,
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 450.ms);
  }

  Widget _buildSignInButton(AsyncValue<void> loginState) {
    return PremiumButton(
      text: AppLocalizations.of(context).authSignIn,
      onPressed: _handleLogin,
      isLoading: loginState.isLoading || _isSocialLoading,
      style: PremiumButtonStyle.gradient,
      size: ButtonSize.large,
    ).animate().fadeIn(duration: 400.ms, delay: 500.ms);
  }

  Widget _buildDivider() {
    return TextDivider(
      text: AppLocalizations.of(context).orSignInWithEmail,
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
  }

  Widget _buildSocialButtons() {
    return Stack(
      children: [
        Column(
          children: [
            // Google button - theme-consistent subtle styling
            _ThemeSocialButton(
              icon: Icons.g_mobiledata_rounded,
              label: AppLocalizations.of(context).continueWithGoogle,
              isApple: false,
              onPressed: _handleGoogleSignIn,
            ).animate().fadeIn(duration: 300.ms, delay: 250.ms),

            SizedBox(height: 12.h),

            // Apple button - theme-consistent subtle styling
            _ThemeSocialButton(
              icon: Icons.apple_rounded,
              label: AppLocalizations.of(context).continueWithApple,
              isApple: true,
              onPressed: _handleAppleSignIn,
            ).animate().fadeIn(duration: 300.ms, delay: 300.ms),
          ],
        ),
        if (_isSocialLoading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppLocalizations.of(context).donTHaveAnAccount,
          style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
        ),
        GestureDetector(
          onTap: () => context.push(AppRoutes.signupWizard.path),
          child: Text(
            AppLocalizations.of(context).authSignUp,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 550.ms);
  }

  String _getAuthErrorMessage(Object? error) {
    final errorStr = error.toString().toLowerCase();
    if (errorStr.contains('user-not-found') ||
        errorStr.contains('no user found')) {
      return 'No account found with this email';
    } else if (errorStr.contains('wrong-password') ||
        errorStr.contains('wrong password') ||
        errorStr.contains('invalid-credential') ||
        errorStr.contains('incorrect')) {
      return 'Incorrect email or password. Please try again.';
    } else if (errorStr.contains('too-many-requests') ||
        errorStr.contains('too many')) {
      return 'Too many login attempts. Please try again later.';
    } else if (errorStr.contains('network')) {
      return 'Network error. Please check your connection.';
    } else if (errorStr.contains('invalid-email') ||
        errorStr.contains('invalid email')) {
      return 'Invalid email address.';
    } else {
      return AppLocalizations.of(context).signInFailedPleaseTry;
    }
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.r),
              topRight: Radius.circular(24.r),
            ),
          ),
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // Icon
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  Icons.lock_reset_rounded,
                  size: 28.sp,
                  color: AppColors.primary,
                ),
              ),

              SizedBox(height: 20.h),

              Text(
                AppLocalizations.of(context).authResetPassword,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),

              SizedBox(height: 8.h),

              Text(
                AppLocalizations.of(context).enterYourEmailAddressAnd,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),

              SizedBox(height: 24.h),

              PremiumTextField(
                controller: resetEmailController,
                label: 'Email',
                hint: 'Enter your email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),

              SizedBox(height: 24.h),

              PremiumButton(
                text: 'Send Reset Link',
                onPressed: () {
                  if (resetEmailController.text.isNotEmpty) {
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(
                            context,
                          ).passwordResetEmailSentCheck,
                        ),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    );
                  }
                },
                style: PremiumButtonStyle.gradient,
                size: ButtonSize.large,
              ),

              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}

/// Theme-consistent social login button with subtle, elegant styling
class _ThemeSocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isApple;
  final VoidCallback onPressed;

  const _ThemeSocialButton({
    required this.icon,
    required this.label,
    required this.isApple,
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
            color: isApple ? AppColors.textPrimary : AppColors.surface,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: isApple ? AppColors.textPrimary : AppColors.inputBorder,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 24.sp,
                color: isApple ? Colors.white : AppColors.textPrimary,
              ),
              SizedBox(width: 12.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: isApple ? Colors.white : AppColors.textPrimary,
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
