import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _fadeController;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _initAnimations();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 8000),
      vsync: this,
    )..repeat();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _fadeController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Subtle ambient background gradients
          _buildAmbientBackground(),

          // Main content
          SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),

                  // Logo section
                  _buildLogoSection(),

                  const Spacer(flex: 2),

                  // Tagline
                  _buildTagline(),

                  const Spacer(flex: 3),

                  // Progress indicator
                  _buildProgressIndicator(),

                  SizedBox(height: 60.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmbientBackground() {
    return AnimatedBuilder(
      animation: _rotateController,
      builder: (context, child) {
        return Stack(
          children: [
            // Top-right soft gradient
            Positioned(
              top: -120.h,
              right: -80.w,
              child: Transform.rotate(
                angle: _rotateController.value * math.pi * 0.05,
                child: Container(
                  width: 350.w,
                  height: 350.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.08),
                        AppColors.primary.withValues(alpha: 0.02),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom-left soft gradient
            Positioned(
              bottom: -150.h,
              left: -100.w,
              child: Transform.rotate(
                angle: -_rotateController.value * math.pi * 0.05,
                child: Container(
                  width: 400.w,
                  height: 400.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.secondary.withValues(alpha: 0.06),
                        AppColors.secondary.withValues(alpha: 0.02),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Center subtle accent
            Positioned(
              top: MediaQuery.of(context).size.height * 0.3,
              left: MediaQuery.of(context).size.width * 0.2,
              child: Container(
                width: 250.w,
                height: 250.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryLight.withValues(alpha: 0.04),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLogoSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Animated logo container with subtle pulse rings
        Stack(
          alignment: Alignment.center,
          children: [
            // Outer pulse ring
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  width: 160.w + (_pulseController.value * 25.w),
                  height: 160.w + (_pulseController.value * 25.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(
                        alpha: 0.08 - _pulseController.value * 0.06,
                      ),
                      width: 1,
                    ),
                  ),
                );
              },
            ),

            // Middle ring
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  width: 130.w + (_pulseController.value * 12.w),
                  height: 130.w + (_pulseController.value * 12.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(
                        alpha: 0.12 - _pulseController.value * 0.08,
                      ),
                      width: 1.5,
                    ),
                  ),
                );
              },
            ),

            // Main logo circle with icon
            Container(
                  width: 100.w,
                  height: 100.w,
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
                        blurRadius: 30,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.directions_run_rounded,
                      size: 45.sp,
                      color: Colors.white,
                    ),
                  ),
                )
                .animate(controller: _fadeController)
                .fadeIn(duration: 800.ms, curve: Curves.easeOut)
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1, 1),
                  duration: 800.ms,
                  curve: Curves.easeOutBack,
                ),
          ],
        ),

        SizedBox(height: 36.h),

        // App name with elegant typography
        Text(
              AppLocalizations.of(context).sportconnect,
              style: TextStyle(
                fontSize: 36.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
                height: 1.1,
              ),
            )
            .animate(controller: _fadeController)
            .fadeIn(delay: 300.ms, duration: 600.ms)
            .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),

        SizedBox(height: 12.h),

        // Subtle tagline badge
        Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
              child: Text(
                AppLocalizations.of(context).carpoolingForRunners,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  letterSpacing: 2,
                ),
              ),
            )
            .animate(controller: _fadeController)
            .fadeIn(delay: 500.ms, duration: 600.ms)
            .slideY(begin: 0.3, end: 0, curve: Curves.easeOut),
      ],
    );
  }

  Widget _buildTagline() {
    return Padding(
          padding: EdgeInsets.symmetric(horizontal: 50.w),
          child: Text(
            AppLocalizations.of(context).shareRidesRunTogetherGo,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.5,
              letterSpacing: 0.2,
            ),
          ),
        )
        .animate(controller: _fadeController)
        .fadeIn(delay: 700.ms, duration: 600.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOut);
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        // Clean minimal progress bar
        AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                return Container(
                  width: 180.w,
                  height: 3.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2.r),
                    color: AppColors.primary.withValues(alpha: 0.1),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 180.w * _progressController.value,
                      height: 3.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2.r),
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                        ),
                      ),
                    ),
                  ),
                );
              },
            )
            .animate(controller: _fadeController)
            .fadeIn(delay: 900.ms, duration: 400.ms),

        SizedBox(height: 16.h),

        // Loading text
        Text(
              AppLocalizations.of(context).loading,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textTertiary,
                letterSpacing: 0.5,
              ),
            )
            .animate(controller: _fadeController)
            .fadeIn(delay: 1000.ms, duration: 400.ms),
      ],
    );
  }
}
