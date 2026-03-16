import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/utils/form_validators.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:sport_connect/core/widgets/utility_widgets.dart';
import 'package:sport_connect/features/auth/models/auth_exception.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';
import 'package:sport_connect/features/auth/view_models/social_auth_view_model.dart';
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
  final _formKey = GlobalKey<FormBuilderState>();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _setupAnimations();

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

  Future<void> _saveCredentials() async {
    final email =
        (_formKey.currentState?.fields['email']!.value as String? ?? '').trim();
    await ref.read(loginUiViewModelProvider.notifier).persistCredentials(email);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.saveAndValidate()) {
      return;
    }

    final email = (_formKey.currentState!.fields['email']!.value as String)
        .trim();
    final password = _formKey.currentState!.fields['password']!.value as String;
    final rememberMe = ref.read(loginUiViewModelProvider).rememberMe;
    final success = await ref
        .read(loginViewModelProvider.notifier)
        .login(email, password, rememberMe);
    if (success) {
      await _saveCredentials();
    }
  }

  void _handleGoogleSignIn() {
    ref.read(socialAuthViewModelProvider.notifier).signInWithGoogle();
  }

  void _handleAppleSignIn() {
    ref.read(socialAuthViewModelProvider.notifier).signInWithApple();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginViewModelProvider);
    final socialState = ref.watch(socialAuthViewModelProvider);

    ref.listen(loginViewModelProvider, (previous, next) {
      if (next.hasError && previous?.error != next.error) {
        final errorMessage = _getAuthErrorMessage(next.error);
        TalkerService.error('Login failed: $errorMessage');
        _showAdaptiveMessage(errorMessage, isError: true);
      }
    });

    ref.listen(socialAuthViewModelProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        final errorMessage = _getAuthErrorMessage(next.errorMessage);
        TalkerService.error('Social sign-in failed: $errorMessage');
        _showAdaptiveMessage(errorMessage, isError: true);
      }
    });

    final loginBody = SafeArea(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: FormBuilder(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 40.h),
                  _buildLogoHeader(),
                  SizedBox(height: 20.h),
                  _buildWelcomeText(),
                  SizedBox(height: 32.h),
                  _buildEmailField(),
                  SizedBox(height: 16.h),
                  _buildPasswordField(),
                  SizedBox(height: 14.h),
                  _buildOptionsRow(),
                  SizedBox(height: 12.h),
                  _buildSignInButton(loginState, socialState),
                  SizedBox(height: 24.h),
                  _buildDivider(),
                  SizedBox(height: 16.h),
                  _buildSocialButtons(socialState),
                  SizedBox(height: 28.h),
                  _buildSignUpLink(),
                  SizedBox(height: 24.h),
                  _buildLegalFooter(),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );

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
              ClipRRect(
                    borderRadius: BorderRadius.circular(200.r),
                    child: Container(
                      width: 120.w,
                      height: 120.w,
                      padding: EdgeInsets.all(16.w),
                      child: ExcludeSemantics(
                        child: Image.asset(
                          'assets/images/branding.png',
                          fit: BoxFit.contain,
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

    // The prefixIcon is purely decorative — excluded so SR does not read it.
    return FormBuilderTextField(
      name: 'email',
      initialValue: ref.watch(loginUiViewModelProvider).savedEmail,
      focusNode: _emailFocus,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator: (value) => FormValidators.email(value),
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
    final loginUiState = ref.watch(loginUiViewModelProvider);
    final toggleLabel = loginUiState.obscurePassword
        ? AppLocalizations.of(context).showPasswordTooltip
        : AppLocalizations.of(context).hidePasswordTooltip;

    return FormBuilderTextField(
      name: 'password',
      focusNode: _passwordFocus,
      obscureText: loginUiState.obscurePassword,
      textInputAction: TextInputAction.done,
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(),
        FormBuilderValidators.minLength(8),
      ]),
      autofillHints: const [AutofillHints.password],
      autocorrect: false,
      enableSuggestions: false,
      onEditingComplete: () => _handleLogin(),
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
          onPressed: () => ref
              .read(loginUiViewModelProvider.notifier)
              .togglePasswordVisibility(),
          icon: Icon(
            loginUiState.obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 400.ms);
  }

  Widget _buildOptionsRow() {
    final rememberMeLabel = AppLocalizations.of(context).rememberMe;
    final loginUiState = ref.watch(loginUiViewModelProvider);

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
                Checkbox(
                  value: loginUiState.rememberMe,
                  onChanged: (value) {
                    HapticFeedback.selectionClick();
                    ref
                        .read(loginUiViewModelProvider.notifier)
                        .setRememberMe(value ?? false);
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
        TextButton(
          onPressed: () => context.push(AppRoutes.forgotPassword.path),
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

  Widget _buildSignInButton(
    AsyncValue<void> loginState,
    SocialAuthState socialState,
  ) {
    final isEmailLoading = loginState.isLoading;
    final isDisabled = loginState.isLoading || socialState.isLoading;
    final signInLabel = AppLocalizations.of(context).authSignIn;

    return SizedBox(
      height: 50.h,
      child: ElevatedButton(
        onPressed: isDisabled ? null : _handleLogin,
        child: isEmailLoading
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
      text: "Or continue with",
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
  }

  Widget _buildSocialButtons(SocialAuthState socialState) {
    return Stack(
      children: [
        Column(
          children: [
            _buildGoogleButton(
              socialState,
            ).animate().fadeIn(duration: 300.ms, delay: 250.ms),
            SizedBox(height: 12.h),
            SignInWithAppleButton(
              onPressed: socialState.isLoading ? () {} : _handleAppleSignIn,
              text: AppLocalizations.of(context).continueWithApple,
              height: 44.h,
              borderRadius: BorderRadius.circular(14.r),
              style: SignInWithAppleButtonStyle.black,
            ).animate().fadeIn(duration: 300.ms, delay: 300.ms),
          ],
        ),
        if (socialState.isLoading)
          Positioned.fill(
            child: Semantics(
              label: 'Signing in, please wait',
              liveRegion: true,
              excludeSemantics: true,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Center(
                  child: const CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGoogleButton(SocialAuthState socialState) {
    final double buttonHeight = 40.h;
    final double iconGap = 10.w;
    final label = AppLocalizations.of(context).continueWithGoogle;

    return SizedBox(
      height: buttonHeight,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: socialState.isLoading
            ? null
            : () {
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
