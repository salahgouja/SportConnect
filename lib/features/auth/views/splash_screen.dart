import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _progressController;
  late AnimationController _dotController;

  late Animation<double> _progressAnim;

  // Soft green palette — tweak to match your AppColors exactly
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _bg = Color(0xFFF7FAF8); // barely-tinted white
  static const Color _green = Color(0xFF2D9B6F); // primary green
  static const Color _greenLight = Color(0xFFE8F5EF); // chip background
  static const Color _greenDeep = Color(0xFF1A6B4A); // logo shadow tint
  static const Color _textMain = Color(0xFF111B16);
  static const Color _textSub = Color(0xFF7A9E8E);

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      duration: const Duration(milliseconds: 1100),
      vsync: this,
    );
    unawaited(_entryController.forward());

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2600),
      vsync: this,
    );
    unawaited(_progressController.forward());

    _dotController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat(reverse: true);

    _progressAnim = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _entryController.dispose();
    _progressController.dispose();
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // ── Subtle top-corner accent arc ───────────────────────────────
          Positioned(
            top: -size.width * 0.55,
            right: -size.width * 0.35,
            child: Container(
              width: size.width * 1.0,
              height: size.width * 1.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _greenLight,
              ),
            ),
          ),

          // ── Bottom-left small dot accent ───────────────────────────────
          Positioned(
            bottom: size.height * 0.08,
            left: -20.w,
            child: Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _greenLight,
              ),
            ),
          ),

          // ── Main content ───────────────────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: size.height * 0.14),

                // ── Logo ──────────────────────────────────────────────────
                _buildLogo(),

                SizedBox(height: 28.h),

                // ── App name ──────────────────────────────────────────────
                Text(
                      AppLocalizations.of(context).sportconnect,
                      style: TextStyle(
                        fontSize: 34.sp,
                        fontWeight: FontWeight.w800,
                        color: _textMain,
                        letterSpacing: -1.0,
                        height: 1,
                      ),
                    )
                    .animate(controller: _entryController)
                    .fadeIn(delay: 200.ms, duration: 500.ms)
                    .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),

                SizedBox(height: 12.h),

                // ── Pill badge ────────────────────────────────────────────
                Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: _greenLight,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: _green.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6.w,
                            height: 6.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _green,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            AppLocalizations.of(context).carpoolingForRunners,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: _green,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate(controller: _entryController)
                    .fadeIn(delay: 350.ms, duration: 500.ms),

                const Spacer(),

                // ── Tagline ───────────────────────────────────────────────
                Padding(
                      padding: EdgeInsets.symmetric(horizontal: 52.w),
                      child: Text(
                        AppLocalizations.of(context).shareRidesRunTogetherGo,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w400,
                          color: _textSub,
                          height: 1.55,
                          letterSpacing: 0.1,
                        ),
                      ),
                    )
                    .animate(controller: _entryController)
                    .fadeIn(delay: 500.ms, duration: 500.ms),

                SizedBox(height: 44.h),

                // ── Progress ──────────────────────────────────────────────
                _buildProgress(),

                SizedBox(height: 52.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
          width: 88.w,
          height: 88.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _green,
            boxShadow: [
              BoxShadow(
                color: _greenDeep.withValues(alpha: 0.18),
                blurRadius: 32,
                spreadRadius: 0,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: _green.withValues(alpha: 0.22),
                blurRadius: 16,
                spreadRadius: -4,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.directions_run_rounded,
              size: 42.sp,
              color: _white,
            ),
          ),
        )
        .animate(controller: _entryController)
        .fadeIn(duration: 600.ms, curve: Curves.easeOut)
        .scale(
          begin: const Offset(0.75, 0.75),
          end: const Offset(1.0, 1.0),
          duration: 600.ms,
          curve: Curves.easeOutBack,
        );
  }

  Widget _buildProgress() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 48.w),
          child:
              AnimatedBuilder(
                    animation: _progressAnim,
                    builder: (context, _) {
                      return Stack(
                        children: [
                          // Track
                          Container(
                            width: double.infinity,
                            height: 2.5.h,
                            decoration: BoxDecoration(
                              color: _greenLight,
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                          ),
                          // Fill
                          FractionallySizedBox(
                            widthFactor: _progressAnim.value,
                            child: Container(
                              height: 2.5.h,
                              decoration: BoxDecoration(
                                color: _green,
                                borderRadius: BorderRadius.circular(2.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: _green.withValues(alpha: 0.35),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  )
                  .animate(controller: _entryController)
                  .fadeIn(delay: 700.ms, duration: 400.ms),
        ),

        SizedBox(height: 14.h),

        Text(
              AppLocalizations.of(context).loading,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                color: _textSub,
                letterSpacing: 1.8,
              ),
            )
            .animate(controller: _entryController)
            .fadeIn(delay: 800.ms, duration: 400.ms),
      ],
    );
  }
}
