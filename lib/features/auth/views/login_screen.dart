import 'dart:io' show Platform;

import 'package:flutter/gestures.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/repositories/settings_repository.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/utils/validators.dart';
import 'package:sport_connect/core/widgets/utility_widgets.dart';
import 'package:sport_connect/features/auth/models/auth_exception.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Professional Login Screen with clean, modern design
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

  bool get _isCupertino => !kIsWeb && Platform.isIOS;

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
    final settings = await ref.read(settingsRepositoryProvider.future);
    if (settings.rememberMe && settings.savedEmail != null) {
      setState(() {
        _emailController.text = settings.savedEmail!;
        _rememberMe = true;
      });
    }
  }

  Future<void> _saveCredentials() async {
    final settings = await ref.read(settingsRepositoryProvider.future);
    if (_rememberMe) {
      await settings.saveCredentials(email: _emailController.text.trim());
    } else {
      await settings.clearCredentials();
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

    try {
      await ref
          .read(loginViewModelProvider.notifier)
          .login(
            _emailController.text.trim(),
            _passwordController.text,
            _rememberMe,
          );
      await _saveCredentials();
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
    } catch (e) {
      if (mounted) {
        await _showAdaptiveMessage(_getAuthErrorMessage(e), isError: true);
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
    } catch (e) {
      if (mounted) {
        await _showAdaptiveMessage(_getAuthErrorMessage(e), isError: true);
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
                  _buildLogoHeader(),
                  SizedBox(height: 32.h),
                  _buildWelcomeText(),
                  SizedBox(height: 32.h),
                  _buildSocialButtons(),
                  SizedBox(height: 24.h),
                  _buildDivider(),
                  SizedBox(height: 24.h),
                  _buildEmailField(),
                  SizedBox(height: 16.h),
                  _buildPasswordField(),
                  SizedBox(height: 14.h),
                  _buildOptionsRow(),
                  SizedBox(height: 28.h),
                  _buildSignInButton(loginState),
                  SizedBox(height: 28.h),
                  _buildSignUpLink(),
                  SizedBox(height: 8.h),
                  _buildAlternateAuthLinks(),
                  SizedBox(height: 16.h),
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
        // The logo container is purely decorative — the app name Text below
        // already communicates the brand. We give it a label so VoiceOver
        // reads "SportConnect logo" once, and exclude the inner Icon so its
        // raw name isn't announced as a second node.
        Semantics(
          label: 'SportConnect logo',
          image: true,
          child:
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
                      child: ExcludeSemantics(
                        // Icon is non-interactive and already described by the
                        // parent Semantics label — exclude to avoid duplication.
                        child: Icon(
                          Icons.directions_run_rounded,
                          size: 40.sp,
                          color: Colors.white,
                        ),
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
        ),

        SizedBox(height: 16.h),

        // App name — plain Text, no changes needed.
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
    // Plain text nodes — no semantics changes needed.
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
          // Visual label only — VoiceOver uses the placeholder as the field's
          // accessible name, so this Text is purely decorative from an a11y
          // perspective. ExcludeSemantics prevents a redundant focus stop.
          ExcludeSemantics(
            child: Text(
              emailLabel,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
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
              child: ExcludeSemantics(
                // Decorative prefix icon — excluded so SR does not read it.
                child: Icon(
                  CupertinoIcons.mail,
                  size: 18.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(_isCupertino ? 20.r : 16.r),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms, delay: 350.ms);
    }

    // Material: TextFormField's labelText is the accessible name already.
    // Only the decorative prefix icon needs excluding.
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
        prefixIcon: ExcludeSemantics(child: const Icon(Icons.email_outlined)),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 350.ms);
  }

  Widget _buildPasswordField() {
    final passwordLabel = AppLocalizations.of(context).password;
    final passwordHint = AppLocalizations.of(context).enterYourPassword;
    // Dynamic label reflects the current state so SR users know what the
    // button will do before they activate it.
    final toggleLabel = _obscurePassword ? 'Show password' : 'Hide password';

    if (_isCupertino) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: Text(
              passwordLabel,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
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
              child: ExcludeSemantics(
                child: Icon(
                  CupertinoIcons.lock,
                  size: 18.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            suffix: Semantics(
              // The toggle IS interactive — it needs its own focusable node
              // with a meaningful label. We do NOT use excludeSemantics here.
              // The inner icon is excluded so only this label is announced.
              label: toggleLabel,
              button: true,
              child: CupertinoButton(
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                padding: EdgeInsets.only(right: 10.w),
                minimumSize: const Size(44, 44),
                alignment: Alignment.centerRight,
                child: ExcludeSemantics(
                  child: Icon(
                    _obscurePassword
                        ? CupertinoIcons.eye
                        : CupertinoIcons.eye_slash,
                    size: 18.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(_isCupertino ? 20.r : 16.r),
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
        prefixIcon: ExcludeSemantics(
          child: const Icon(Icons.lock_outline_rounded),
        ),
        suffixIcon: IconButton(
          // `tooltip` is used by both TalkBack and VoiceOver as the button's
          // accessible name. Dynamic string keeps the state accurate.
          tooltip: toggleLabel,
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
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
    final rememberMeLabel = AppLocalizations.of(context).rememberMe;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // MergeSemantics combines the Checkbox/Switch and its sibling Text
        // into ONE focusable node: "Remember me, checkbox, checked".
        // This avoids two separate focus stops for what is logically one
        // control, without suppressing interactivity.
        MergeSemantics(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Row(
              children: [
                if (_isCupertino)
                  CupertinoSwitch(
                    value: _rememberMe,
                    onChanged: (value) {
                      HapticFeedback.selectionClick();
                      setState(() => _rememberMe = value);
                    },
                    activeTrackColor: AppColors.primary,
                  )
                else
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (value) {
                      HapticFeedback.selectionClick();
                      setState(() => _rememberMe = value ?? false);
                    },
                    visualDensity: VisualDensity.compact,
                  ),
                SizedBox(width: 8.w),
                Text(
                  rememberMeLabel,
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

        // Forgot password button — interactive, label is already descriptive.
        _isCupertino
            ? CupertinoButton(
                onPressed: () => context.push(AppRoutes.forgotPassword.path),
                padding: EdgeInsets.zero,
                minimumSize: const Size(44, 44),
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
                onPressed: () => context.push(AppRoutes.forgotPassword.path),
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
    final signInLabel = AppLocalizations.of(context).authSignIn;

    if (_isCupertino) {
      return SizedBox(
        height: 50.h,
        child: CupertinoButton.filled(
          onPressed: isLoading ? null : _handleLogin,
          borderRadius: BorderRadius.circular(_isCupertino ? 20.r : 14.r),
          child: isLoading
              ? Semantics(
                  label: 'Signing in, please wait',
                  liveRegion: true,
                  child: const CupertinoActivityIndicator(),
                )
              : Text(
                  signInLabel,
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
            ? Semantics(
                label: 'Signing in, please wait',
                liveRegion: true,
                child: SizedBox(
                  height: 18.h,
                  width: 18.w,
                  child: const CircularProgressIndicator(strokeWidth: 2.5),
                ),
              )
            : Text(
                signInLabel,
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
            _buildGoogleButton().animate().fadeIn(
              duration: 300.ms,
              delay: 250.ms,
            ),
            SizedBox(height: 12.h),
            SignInWithAppleButton(
              onPressed: _handleAppleSignIn,
              text: AppLocalizations.of(context).continueWithApple,
              height: 44.h,
              borderRadius: BorderRadius.circular(14.r),
              style: SignInWithAppleButtonStyle.black,
            ).animate().fadeIn(duration: 300.ms, delay: 300.ms),
          ],
        ),
        if (_isSocialLoading)
          Positioned.fill(
            child: Semantics(
              // liveRegion announces this as soon as it appears without the
              // user needing to navigate to it.
              label: 'Signing in, please wait',
              liveRegion: true,
              // The overlay itself is not interactive. excludeSemantics here
              // only applies to the overlay container's own node — the buttons
              // beneath it in the Stack are not children of this widget so
              // they are unaffected and remain fully accessible.
              excludeSemantics: true,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Center(
                  child: _isCupertino
                      ? const CupertinoActivityIndicator(radius: 14)
                      : const CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGoogleButton() {
    final double buttonHeight = _isCupertino ? 44.h : 40.h;
    final double iconGap = _isCupertino ? 12.w : 10.w;
    final label = AppLocalizations.of(context).continueWithGoogle;

    // OutlinedButton is already announced as a button by the framework.
    // The only fix needed is to silence the decorative SVG icon so it is
    // not read alongside the button label. The Text inside will naturally
    // form the button's accessible name — no extra Semantics wrapper needed.
    return SizedBox(
      height: buttonHeight,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          _handleGoogleSignIn();
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          side: const BorderSide(color: Color(0xFF747775), width: 1.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ExcludeSemantics(
              // Decorative SVG logo — excluded so SR reads only the button
              // label text and not a raw asset path or "image".
              child: SvgPicture.asset(
                'assets/icons/google_g_logo.svg',
                height: 20.sp,
                width: 20.sp,
              ),
            ),
            SizedBox(width: iconGap),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1F1F1F),
                height: 20 / 14,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    final l10n = AppLocalizations.of(context);

    // ROOT CAUSE OF THE DOUBLE-READ BUG:
    // Original code: Semantics(label: 'Sign up') wrapping a GestureDetector
    // that contained Text('Sign up'). The SR tree had two nodes both
    // contributing "Sign up" → announced twice.
    //
    // CORRECT FIX:
    // • Remove the redundant label from the Semantics wrapper.
    // • Keep Semantics(button: true) so SR knows the Text is activatable.
    // • The Text widget is the single source of the label — no duplication.
    // • GestureDetector's tap handler remains fully reachable.
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.donTHaveAnAccount,
          style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
        ),
        Semantics(
          // button: true tells SR this is activatable.
          // No `label` here — the child Text('Sign up') provides it,
          // which is the single source of truth. This eliminates the duplicate.
          button: true,
          child: GestureDetector(
            onTap: () => context.push(AppRoutes.signupWizard.path),
            child: Padding(
              padding: EdgeInsets.all(8.w),
              child: Text(
                l10n.authSignUp,
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

  Widget _buildAlternateAuthLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () => context.push(AppRoutes.phoneOtp.path),
          child: Text(
            'Use phone OTP',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
        Text(
          '•',
          style: TextStyle(fontSize: 13.sp, color: AppColors.textTertiary),
        ),
        TextButton(
          onPressed: () => context.push(AppRoutes.onboarding.path),
          child: Text(
            'View onboarding',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 575.ms);
  }

  Widget _buildLegalFooter() {
    // TextSpan tappable links require `semanticsLabel` to be announced as
    // interactive by both TalkBack and VoiceOver. Without it the spans are
    // read as plain text with no affordance that they are tappable.
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Text.rich(
        TextSpan(
          style: TextStyle(fontSize: 12.sp, color: AppColors.textTertiary),
          children: [
            const TextSpan(text: 'By continuing, you agree to our '),
            TextSpan(
              text: 'Terms of Service',
              semanticsLabel: 'Terms of Service, link',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => context.push(AppRoutes.terms.path),
            ),
            const TextSpan(text: ' and '),
            TextSpan(
              text: 'Privacy Policy',
              semanticsLabel: 'Privacy Policy, link',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => context.push(AppRoutes.privacy.path),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 600.ms);
  }

  String _getAuthErrorMessage(Object? error) {
    final l10n = AppLocalizations.of(context);
    if (error is AuthException) {
      switch (error.code) {
        case 'user-not-found':
          return l10n.loginErrorUserNotFound;
        case 'wrong-password' || 'invalid-credential':
          return l10n.loginErrorWrongPassword;
        case 'too-many-requests':
          return l10n.loginErrorTooManyRequests;
        case 'invalid-email':
          return l10n.loginErrorInvalidEmail;
        case 'account-exists-with-different-credential':
          return l10n.accountExistsError;
        case 'network-request-failed':
          return l10n.loginErrorNetwork;
        default:
          return error.message;
      }
    }
    final errorStr = error.toString().toLowerCase();
    if (errorStr.contains('user-not-found')) {
      return l10n.loginErrorUserNotFound;
    } else if (errorStr.contains('wrong-password') ||
        errorStr.contains('invalid-credential')) {
      return l10n.loginErrorWrongPassword;
    } else if (errorStr.contains('too-many-requests')) {
      return l10n.loginErrorTooManyRequests;
    } else if (errorStr.contains('network')) {
      return l10n.loginErrorNetwork;
    } else if (errorStr.contains('invalid-email')) {
      return l10n.loginErrorInvalidEmail;
    } else if (errorStr.contains('account-exists-with-different-credential')) {
      return l10n.accountExistsError;
    }
    return l10n.signInFailedPleaseTry;
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
