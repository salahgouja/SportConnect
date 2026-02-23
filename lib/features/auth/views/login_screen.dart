import 'dart:io' show Platform;

import 'package:flutter/gestures.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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
import 'package:sport_connect/core/widgets/utility_widgets.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  bool _obscurePassword = true;
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  bool get _isIOS => !kIsWeb && Platform.isIOS;

  bool get _isAndroid => !kIsWeb && Platform.isAndroid;

  bool get _isCupertino => _isIOS;

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
    if (_isCupertino) {
      final emailError = Validators.email(_emailController.text.trim());
      final passwordError = Validators.password(_passwordController.text);
      if (emailError != null || passwordError != null) {
        await _showAdaptiveMessage(emailError ?? passwordError!, isError: true);
        return;
      }
    } else if (!_formKey.currentState!.validate()) {
      return;
    }

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
      await _showAdaptiveMessage(errorMessage, isError: true);
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
        await _showAdaptiveMessage(
          AppLocalizations.of(context).signInFailedPleaseTry,
          isError: true,
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
        await _showAdaptiveMessage(
          AppLocalizations.of(context).signInFailedPleaseTry,
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isSocialLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginViewModelProvider);
    final loginBody = SafeArea(
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

                  SizedBox(height: 16.h),

                  // Terms & Privacy footer
                  _buildLegalFooter(),

                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (_isCupertino) {
      return CupertinoPageScaffold(
        backgroundColor: Colors.white,
        child: loginBody,
      );
    }

    return Scaffold(backgroundColor: Colors.white, body: loginBody);
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
    final emailLabel = AppLocalizations.of(context).email;
    final emailHint = AppLocalizations.of(context).enterYourEmail;

    if (_isCupertino) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emailLabel,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          CupertinoTextField(
            controller: _emailController,
            focusNode: _emailFocus,
            placeholder: emailHint,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            keyboardAppearance: Brightness.light,
            autocorrect: false,
            enableSuggestions: false,
            onEditingComplete: () => _passwordFocus.requestFocus(),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            prefix: Padding(
              padding: EdgeInsets.only(left: 12.w),
              child: Icon(
                CupertinoIcons.mail,
                size: 18.sp,
                color: AppColors.textSecondary,
              ),
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(_isIOS ? 20.r : 16.r),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms, delay: 350.ms);
    }

    return TextFormField(
      controller: _emailController,
      focusNode: _emailFocus,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator: Validators.email,
      autofillHints: const [AutofillHints.email],
      autocorrect: false,
      enableSuggestions: false,
      onEditingComplete: () => _passwordFocus.requestFocus(),
      decoration: InputDecoration(
        labelText: emailLabel,
        hintText: emailHint,
        prefixIcon: const Icon(Icons.email_outlined),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 350.ms);
  }

  Widget _buildPasswordField() {
    final passwordLabel = AppLocalizations.of(context).password;
    final passwordHint = AppLocalizations.of(context).enterYourPassword;

    if (_isCupertino) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            passwordLabel,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          CupertinoTextField(
            controller: _passwordController,
            focusNode: _passwordFocus,
            placeholder: passwordHint,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleLogin(),
            autofillHints: const [AutofillHints.password],
            keyboardAppearance: Brightness.light,
            autocorrect: false,
            enableSuggestions: false,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            prefix: Padding(
              padding: EdgeInsets.only(left: 12.w),
              child: Icon(
                CupertinoIcons.lock,
                size: 18.sp,
                color: AppColors.textSecondary,
              ),
            ),
            suffix: CupertinoButton(
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              padding: EdgeInsets.only(right: 10.w),
              minimumSize: const Size(24, 24),
              alignment: Alignment.centerRight,
              child: Icon(
                _obscurePassword
                    ? CupertinoIcons.eye
                    : CupertinoIcons.eye_slash,
                size: 18.sp,
                color: AppColors.textSecondary,
              ),
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(_isIOS ? 20.r : 16.r),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms, delay: 400.ms);
    }

    return TextFormField(
      controller: _passwordController,
      focusNode: _passwordFocus,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      validator: Validators.password,
      autofillHints: const [AutofillHints.password],
      autocorrect: false,
      enableSuggestions: false,
      onFieldSubmitted: (_) => _handleLogin(),
      decoration: InputDecoration(
        labelText: passwordLabel,
        hintText: passwordHint,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          tooltip: _obscurePassword ? 'Show password' : 'Hide password',
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 400.ms);
  }

  Widget _buildOptionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Remember Me
        Semantics(
          toggled: _rememberMe,
          label: AppLocalizations.of(context).rememberMe,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Row(
              children: [
                if (_isCupertino)
                  CupertinoSwitch(
                    value: _rememberMe,
                    onChanged: (value) {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _rememberMe = value;
                      });
                    },
                    activeTrackColor: AppColors.primary,
                  )
                else
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (value) {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
                    visualDensity: VisualDensity.compact,
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
        ),
        // Forgot Password
        _isCupertino
            ? CupertinoButton(
                onPressed: _showForgotPasswordDialog,
                padding: EdgeInsets.zero,
                child: Text(
                  AppLocalizations.of(context).authForgotPassword,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              )
            : TextButton(
                onPressed: _showForgotPasswordDialog,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  AppLocalizations.of(context).authForgotPassword,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 450.ms);
  }

  Widget _buildSignInButton(AsyncValue<void> loginState) {
    final isLoading = loginState.isLoading || _isSocialLoading;

    if (_isCupertino) {
      return SizedBox(
        height: 50.h,
        child: CupertinoButton.filled(
          onPressed: isLoading ? null : _handleLogin,
          borderRadius: BorderRadius.circular(_isIOS ? 20.r : 14.r),
          child: isLoading
              ? const CupertinoActivityIndicator()
              : Text(
                  AppLocalizations.of(context).authSignIn,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ).animate().fadeIn(duration: 400.ms, delay: 500.ms);
    }

    return SizedBox(
      height: 50.h,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleLogin,
        child: isLoading
            ? SizedBox(
                height: 18.h,
                width: 18.w,
                child: const CircularProgressIndicator(strokeWidth: 2.5),
              )
            : Text(
                AppLocalizations.of(context).authSignIn,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
      ),
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
            // Compliant Google Sign-In Button
            _buildGoogleButton().animate().fadeIn(
              duration: 300.ms,
              delay: 250.ms,
            ),

            SizedBox(height: 12.h),

            // Compliant Apple Sign-In Button
            SignInWithAppleButton(
              onPressed: _handleAppleSignIn,
              text: AppLocalizations.of(context).continueWithApple,
              height: 44.h, // Matches your original height standard
              borderRadius: BorderRadius.circular(14.r),
              style: SignInWithAppleButtonStyle
                  .black, // Use .white or .whiteOutlined for light themes
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
              child: Center(
                child: _isCupertino
                    ? const CupertinoActivityIndicator(radius: 14)
                    : const CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
          ),
      ],
    );
  }

  // Google's strict branding requires the official 'G', specific padding, and Roboto font (or system default)
  Widget _buildGoogleButton() {
    // 1. Determine platform-specific dimensions based on the provided spec image
    final double buttonHeight = _isCupertino ? 44.h : 40.h;
    final double iconGap = _isCupertino ? 12.w : 10.w;

    return Semantics(
      button: true,
      label: AppLocalizations.of(context).continueWithGoogle,
      child: SizedBox(
        height: buttonHeight,
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            _handleGoogleSignIn();
          },
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white, // Fill: #FFFFFF
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
            // Stroke: #747775 | 1px | inside
            side: const BorderSide(color: Color(0xFF747775), width: 1.0),
          ),
          // Center the entire block (Icon + Gap + Text) for full-width buttons
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon is strictly 20x20 on both platforms
              SvgPicture.asset(
                'assets/icons/google_g_logo.svg',
                height: 20.sp,
                width: 20.sp,
              ),

              // Platform-specific spacing between icon and text (10 Android, 12 iOS)
              SizedBox(width: iconGap),

              Text(
                AppLocalizations.of(context).continueWithGoogle,
                style: TextStyle(
                  // Font: #1F1F1F | Roboto Medium | 14/20
                  fontFamily: 'Roboto', // Google strongly prefers Roboto here
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1F1F1F),
                  height:
                      20 / 14, // Calculates line-height of 20 for font-size 14
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
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
        Semantics(
          button: true,
          label: AppLocalizations.of(context).authSignUp,
          child: GestureDetector(
            onTap: () => context.push(AppRoutes.signupWizard.path),
            child: Padding(
              padding: EdgeInsets.all(8.w),
              child: Text(
                AppLocalizations.of(context).authSignUp,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 550.ms);
  }

  Widget _buildLegalFooter() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Text.rich(
        TextSpan(
          style: TextStyle(fontSize: 12.sp, color: AppColors.textTertiary),
          children: [
            const TextSpan(text: 'By continuing, you agree to our '),
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
        textAlign: TextAlign.center,
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 600.ms);
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

    if (_isCupertino) {
      final cancelLabel = MaterialLocalizations.of(context).cancelButtonLabel;
      final resetSentMessage = AppLocalizations.of(
        context,
      ).passwordResetEmailSentCheck;
      showCupertinoDialog<void>(
        context: context,
        builder: (dialogContext) => CupertinoAlertDialog(
          title: Text(AppLocalizations.of(context).authResetPassword),
          content: Padding(
            padding: EdgeInsets.only(top: 12.h),
            child: CupertinoTextField(
              controller: resetEmailController,
              keyboardType: TextInputType.emailAddress,
              placeholder: AppLocalizations.of(context).enterYourEmail,
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(cancelLabel),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () async {
                final email = resetEmailController.text.trim();
                if (email.isEmpty) return;
                try {
                  await ref
                      .read(authActionsViewModelProvider)
                      .sendPasswordResetEmail(email);
                  if (!context.mounted) return;
                  Navigator.of(dialogContext).pop();
                  await _showAdaptiveMessage(resetSentMessage);
                } catch (_) {
                  if (!context.mounted) return;
                  await _showAdaptiveMessage(
                    'Could not send reset email. Please try again.',
                    isError: true,
                  );
                }
              },
              child: const Text('Send'),
            ),
          ],
        ),
      );
      return;
    }

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

              TextField(
                controller: resetEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).email,
                  hintText: AppLocalizations.of(context).enterYourEmail,
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
              ),

              SizedBox(height: 24.h),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final email = resetEmailController.text.trim();
                    if (email.isEmpty) return;
                    try {
                      await ref
                          .read(authActionsViewModelProvider)
                          .sendPasswordResetEmail(email);
                      if (context.mounted) {
                        context.pop();
                        await _showAdaptiveMessage(
                          AppLocalizations.of(
                            context,
                          ).passwordResetEmailSentCheck,
                        );
                      }
                    } catch (_) {
                      if (context.mounted) {
                        await _showAdaptiveMessage(
                          'Could not send reset email. Please try again.',
                          isError: true,
                        );
                      }
                    }
                  },
                  child: const Text('Send Reset Link'),
                ),
              ),

              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAdaptiveMessage(
    String message, {
    bool isError = false,
  }) async {
    if (!mounted) return;

    if (_isCupertino) {
      await showCupertinoDialog<void>(
        context: context,
        builder: (dialogContext) => CupertinoAlertDialog(
          title: Text(isError ? 'Sign in error' : 'Success'),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
            ),
          ],
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.red.shade600 : AppColors.success,
        duration: const Duration(seconds: 4),
        margin: EdgeInsets.all(16.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }
}
