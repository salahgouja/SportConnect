import 'dart:async';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
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

  // Soft green palette
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _bg = Color(0xFFF7FAF8);
  static const Color _green = Color(0xFF2D9B6F);
  static const Color _greenLight = Color(0xFFE8F5EF);
  static const Color _greenDeep = Color(0xFF1A6B4A);
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
    );
    unawaited(_dotController.repeat(reverse: true));

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
    final size = MediaQuery.sizeOf(context);
    final l10n = AppLocalizations.of(context);

    return AdaptiveScaffold(
      body: ColoredBox(
        color: _bg,
        child: Stack(
          children: [
            Positioned(
              top: -size.width * 0.45,
              right: -size.width * 0.2,
              child: _buildAmbientOrb(size.width * 0.82),
            ),
            Positioned(
              bottom: size.height * 0.08,
              left: -20.w,
              child: _buildAmbientOrb(80.w),
            ),
            SafeArea(
              child: ResponsiveLayoutBuilder(
                compact: (_) => _buildCompactLayout(context, l10n, size),
                medium: (_) => _buildExpandedLayout(context, l10n),
                expanded: (_) => _buildExpandedLayout(context, l10n),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmbientOrb(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: _greenLight,
      ),
    );
  }

  Widget _buildCompactLayout(
    BuildContext context,
    AppLocalizations l10n,
    Size size,
  ) {
    return MaxWidthContainer(
      maxWidth: kMaxWidthFormNarrow,
      child: Column(
        children: [
          SizedBox(height: size.height * 0.14),
          FractionallySizedBox(widthFactor: 0.3, child: _buildLogo()),
          SizedBox(height: 28.h),
          _buildBrandBlock(context, l10n, center: true),
          const Spacer(),
          Padding(
                padding: EdgeInsets.symmetric(horizontal: 52.w),
                child: Text(
                  l10n.shareRidesRunTogetherGo,
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
          _buildProgress(),
          SizedBox(height: 52.h),
        ],
      ),
    );
  }

  Widget _buildExpandedLayout(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1180),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 28.h),
          child: Row(
            children: [
              Expanded(
                flex: 6,
                child: Padding(
                  padding: EdgeInsets.only(right: 24.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(width: 112.w, child: _buildLogo()),
                      ),
                      SizedBox(height: 28.h),
                      _buildBrandBlock(context, l10n),
                      SizedBox(height: 24.h),
                      Container(
                            padding: EdgeInsets.all(24.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.82),
                              borderRadius: BorderRadius.circular(28.r),
                              border: Border.all(
                                color: _green.withValues(alpha: 0.14),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _greenDeep.withValues(alpha: 0.08),
                                  blurRadius: 32,
                                  offset: const Offset(0, 20),
                                ),
                              ],
                            ),
                            child: Text(
                              l10n.shareRidesRunTogetherGo,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w400,
                                color: _textSub,
                                height: 1.55,
                              ),
                            ),
                          )
                          .animate(controller: _entryController)
                          .fadeIn(delay: 500.ms, duration: 500.ms)
                          .slideY(begin: 0.08, end: 0),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: _buildTabletStatusCard(context, l10n)
                    .animate(controller: _entryController)
                    .fadeIn(delay: 250.ms, duration: 600.ms)
                    .slideX(begin: 0.06, end: 0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandBlock(
    BuildContext context,
    AppLocalizations l10n, {
    bool center = false,
  }) {
    final alignment = center
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;
    final textAlign = center ? TextAlign.center : TextAlign.left;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
              l10n.sportconnect,
              textAlign: textAlign,
              style: TextStyle(
                fontSize: center ? 34.sp : 44.sp,
                fontWeight: FontWeight.w800,
                color: _textMain,
                letterSpacing: -1,
                height: 1,
              ),
            )
            .animate(controller: _entryController)
            .fadeIn(delay: 200.ms, duration: 500.ms)
            .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
        SizedBox(height: 12.h),
        Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: _greenLight,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: _green.withValues(alpha: 0.25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6.w,
                    height: 6.w,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: _green,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    l10n.carpoolingForRunners,
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
      ],
    );
  }

  Widget _buildTabletStatusCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      key: const ValueKey('splash_tablet_status_card'),
      padding: EdgeInsets.all(28.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF1F8F4)],
        ),
        borderRadius: BorderRadius.circular(32.r),
        border: Border.all(color: _green.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: _greenDeep.withValues(alpha: 0.10),
            blurRadius: 40,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: _green,
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Icon(
                  Icons.route_rounded,
                  size: 24.sp,
                  color: _white,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.loading,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: _greenDeep,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      l10n.carpoolingForRunners,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: _textMain,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 28.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: [
              _buildTabletMetric(
                context,
                icon: Icons.directions_car_filled_rounded,
                title: l10n.ride,
                subtitle: l10n.trip_plan,
              ),
              _buildTabletMetric(
                context,
                icon: Icons.chat_bubble_outline_rounded,
                title: l10n.chat,
                subtitle: l10n.inapp_chat,
              ),
              _buildTabletMetric(
                context,
                icon: Icons.verified_user_outlined,
                title: l10n.verified,
                subtitle: l10n.safer_rides,
              ),
            ],
          ),
          SizedBox(height: 28.h),
          _buildProgress(),
        ],
      ),
    );
  }

  Widget _buildTabletMetric(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return SizedBox(
      width: responsiveValue<double>(
        context,
        compact: 160,
        medium: 160,
        expanded: 180,
      ),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: _green.withValues(alpha: 0.10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20.sp, color: _greenDeep),
            SizedBox(height: 12.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: _textMain,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12.sp,
                height: 1.45,
                color: _textSub,
              ),
            ),
          ],
        ),
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
          end: const Offset(1, 1),
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
