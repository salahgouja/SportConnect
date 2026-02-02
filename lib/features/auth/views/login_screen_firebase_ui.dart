import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sport_connect/core/config/app_router.dart';
import 'package:sport_connect/core/config/firebase_ui_config.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/custom_button.dart';
import 'package:sport_connect/core/widgets/utility_widgets.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';
import 'package:sport_connect/features/auth/models/user_model.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Professional Login Screen with Firebase UI Auth integration
/// Combines pre-built Firebase authentication with custom SportConnect branding
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadRememberMe();

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

  Future<void> _loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('remember_me') ?? false;
    setState(() {
      _rememberMe = rememberMe;
    });
  }

  Future<void> _saveRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me', _rememberMe);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      final authRepository = ref.read(authRepositoryProvider);
      final result = await authRepository.signInWithGoogle();
      if (mounted && result != null && result.user != null) {
        if (result.isNewUser) {
          context.go(AppRouter.roleSelection);
        } else {
          final route = getHomeRouteForRole(result.user!);
          context.go(route);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        );
      }
    }
  }

  Future<void> _handleAppleSignIn() async {
    try {
      final authRepository = ref.read(authRepositoryProvider);
      final result = await authRepository.signInWithApple();
      if (mounted && result != null && result.user != null) {
        if (result.isNewUser) {
          context.go(AppRouter.roleSelection);
        } else {
          final route = getHomeRouteForRole(result.user!);
          context.go(route);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        );
      }
    }
  }

  Future<void> _handleSignedIn(User? user) async {
    if (user == null || !mounted) return;

    await _saveRememberMe();

    final authRepository = ref.read(authRepositoryProvider);
    final userData = await authRepository.getUserData(user.uid);

    if (!mounted) return;

    if (userData != null) {
      final route = getHomeRouteForRole(userData);
      context.go(route);
    } else {
      // New user from email - redirect to role selection
      context.go(AppRouter.roleSelection);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: FirebaseUIConfig.getFirebaseUITheme(context),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
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

                    // Firebase UI Auth - Email Sign In Form
                    _buildFirebaseAuthForm(),

                    SizedBox(height: 16.h),

                    // Remember me checkbox
                    _buildRememberMeRow(),

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

        Text(
          'SportConnect',
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
              'Welcome Back',
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
          'Sign in to continue your running journey',
          style: TextStyle(fontSize: 15.sp, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
      ],
    );
  }

  Widget _buildDivider() {
    return const TextDivider(
      text: 'or sign in with email',
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
  }

  Widget _buildSocialButtons() {
    return Column(
      children: [
        // Google button
        _ThemeSocialButton(
          icon: Icons.g_mobiledata_rounded,
          label: 'Continue with Google',
          isApple: false,
          onPressed: _handleGoogleSignIn,
        ).animate().fadeIn(duration: 300.ms, delay: 250.ms),

        SizedBox(height: 12.h),

        // Apple button
        _ThemeSocialButton(
          icon: Icons.apple_rounded,
          label: 'Continue with Apple',
          isApple: true,
          onPressed: _handleAppleSignIn,
        ).animate().fadeIn(duration: 300.ms, delay: 300.ms),
      ],
    );
  }

  /// Firebase UI Auth form with custom styling
  Widget _buildFirebaseAuthForm() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: FirebaseUIActions(
        actions: [
          AuthStateChangeAction<SignedIn>((context, state) {
            _handleSignedIn(state.user);
          }),
          AuthStateChangeAction<UserCreated>((context, state) {
            // New user created - redirect to role selection
            if (mounted) {
              context.go(AppRouter.roleSelection);
            }
          }),
          ForgotPasswordAction((context, email) {
            _showForgotPasswordDialog(email);
          }),
        ],
        child: LoginView(
          action: AuthAction.signIn,
          providers: FirebaseUIAuth.providersFor(FirebaseAuth.instance.app),
          showAuthActionSwitch: false,
          showTitle: false,
          subtitleBuilder: (context, action) {
            return const SizedBox.shrink();
          },
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 350.ms);
  }

  Widget _buildRememberMeRow() {
    return Row(
      children: [
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
                'Remember me',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 450.ms);
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
        ),
        GestureDetector(
          onTap: () => context.push(AppRouter.signupWizard),
          child: Text(
            'Sign Up',
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

  void _showForgotPasswordDialog([String? initialEmail]) {
    final resetEmailController = TextEditingController(text: initialEmail);

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
                'Reset Password',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),

              SizedBox(height: 8.h),

              Text(
                'Enter your email address and we\'ll send you instructions to reset your password.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),

              SizedBox(height: 24.h),

              // Email input with SportConnect styling
              TextFormField(
                controller: resetEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: AppColors.textSecondary,
                  ),
                  filled: true,
                  fillColor: AppColors.inputFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: BorderSide(color: AppColors.inputBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: BorderSide(color: AppColors.inputBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              PremiumButton(
                text: 'Send Reset Link',
                onPressed: () async {
                  if (resetEmailController.text.isNotEmpty) {
                    try {
                      await FirebaseAuth.instance.sendPasswordResetEmail(
                        email: resetEmailController.text.trim(),
                      );
                      if (mounted) {
                        context.pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Password reset email sent! Check your inbox.',
                            ),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                            backgroundColor: AppColors.error,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        );
                      }
                    }
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
