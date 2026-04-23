import 'dart:math' as math;

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/features/onboarding/models/onboarding_model.dart';
import 'package:sport_connect/features/onboarding/view_models/onboarding_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();

  int get _currentPage =>
      ref.read(onboardingViewModelProvider).currentPageIndex;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) =>
      ref.read(onboardingViewModelProvider.notifier).setPageIndex(page);

  Future<void> _completeOnboarding() async {
    final success = await ref
        .read(onboardingViewModelProvider.notifier)
        .completeOnboarding();
    if (!success || !mounted) return;
    await _showWelcomeDialog();
  }

  Future<void> _showWelcomeDialog() async {
    HapticFeedback.mediumImpact();
    final router = GoRouter.of(context);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Semantics(
          label: AppLocalizations.of(ctx).youReReadyToRun,
          explicitChildNodes: true,
          child: Container(
            padding: EdgeInsets.all(28.w),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ExcludeSemantics(
                  child: Container(
                    width: 72.w,
                    height: 72.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: onboardingPages[_currentPage].gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.directions_car_rounded,
                      size: 34.sp,
                      color: Colors.white,
                    ),
                  ),
                ).animate().scale(
                  begin: const Offset(0.7, 0.7),
                  duration: 350.ms,
                  curve: Curves.easeOutBack,
                ),
                SizedBox(height: 20.h),
                Semantics(
                  header: true,
                  child: Text(
                    AppLocalizations.of(ctx).youReReadyToRun,
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ).animate().fadeIn(delay: 150.ms),
                SizedBox(height: 10.h),
                Text(
                  AppLocalizations.of(ctx).createAnAccountToStart,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 250.ms),
                SizedBox(height: 28.h),
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      router.go(AppRoutes.login.path);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(ctx).kContinue,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vmState = ref.watch(onboardingViewModelProvider);
    return AdaptiveScaffold(
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: _TopBar(
              currentPage: _currentPage,
              pages: onboardingPages,
              onSkip: _completeOnboarding,
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: onboardingPages.length,
              itemBuilder: (_, i) => _PageContent(page: onboardingPages[i]),
            ),
          ),
          SafeArea(
            top: false,
            child: _BottomControls(
              currentPage: _currentPage,
              pages: onboardingPages,
              vmState: vmState,
              pageController: _pageController,
              onComplete: _completeOnboarding,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Top bar
// ---------------------------------------------------------------------------

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.currentPage,
    required this.pages,
    required this.onSkip,
  });

  final int currentPage;
  final List<OnboardingPage> pages;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final page = pages[currentPage];
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 6.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Semantics(
                label: 'Step ${currentPage + 1} of ${pages.length}',
                child: _GradientPill(
                  colors: page.gradientColors,
                  child: Text(
                    '${currentPage + 1} / ${pages.length}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2),

              if (currentPage < pages.length - 1)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onSkip();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 9.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppLocalizations.of(context).skip,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.adaptive.arrow_forward_rounded,
                          size: 15.sp,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
            ],
          ),
          SizedBox(height: 14.h),
          _StepTrack(currentPage: currentPage, pages: pages),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step track
// ---------------------------------------------------------------------------

class _StepTrack extends StatelessWidget {
  const _StepTrack({required this.currentPage, required this.pages});

  final int currentPage;
  final List<OnboardingPage> pages;

  static const _labels = ['Find', 'Offer', 'Route', 'Connect'];

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Row(
        children: List.generate(pages.length, (i) {
          final active = i <= currentPage;
          final current = i == currentPage;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: 300.ms,
                    height: 5.h,
                    decoration: BoxDecoration(
                      gradient: active
                          ? LinearGradient(colors: pages[i].gradientColors)
                          : null,
                      color: active ? null : AppColors.border,
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _labels[i],
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: current ? FontWeight.w700 : FontWeight.w500,
                      color: active
                          ? pages[i].gradientColors[0]
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
    );
  }
}

// ---------------------------------------------------------------------------
// Page content
// ---------------------------------------------------------------------------

class _PageContent extends StatelessWidget {
  const _PageContent({required this.page});
  final OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    // Illustration takes 36 % of screen height, clamped for SE ↔ tablet range.
    final illustrationH = (1.sh * 0.36).clamp(170.0, 310.0);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 22.w),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.h),
            _Illustration(
              variant: page.illustration,
              colors: page.gradientColors,
              height: illustrationH,
            ),
            SizedBox(height: 22.h),
            _SubtitleBadge(label: page.subtitle, colors: page.gradientColors),
            SizedBox(height: 11.h),
            _Title(text: page.title),
            SizedBox(height: 9.h),
            _Description(text: page.description),
            SizedBox(height: 16.h),
            _FeatureRow(
              features: page.features,
              accentColor: page.gradientColors[0],
            ),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Illustration shell — LayoutBuilder passes real pixel w/h to each variant
// ---------------------------------------------------------------------------

class _Illustration extends StatefulWidget {
  const _Illustration({
    required this.variant,
    required this.colors,
    required this.height,
  });

  final IllustrationVariant variant;
  final List<Color> colors;
  final double height;

  @override
  State<_Illustration> createState() => _IllustrationState();
}

class _IllustrationState extends State<_Illustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      excludeSemantics: true,
      child:
          AnimatedBuilder(
                animation: _ctrl,
                builder: (_, _) => LayoutBuilder(
                  builder: (_, constraints) {
                    final w = constraints.maxWidth;
                    final h = widget.height;
                    return Container(
                      height: h,
                      width: w,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            widget.colors[0].withValues(alpha: 0.11),
                            widget.colors[1].withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(22.r),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22.r),
                        child: _buildVariant(w, h),
                      ),
                    );
                  },
                ),
              )
              .animate()
              .fadeIn(duration: 600.ms)
              .scale(
                begin: const Offset(0.93, 0.93),
                curve: Curves.easeOutBack,
              ),
    );
  }

  Widget _buildVariant(double w, double h) {
    switch (widget.variant) {
      case IllustrationVariant.findRide:
        return _FindRideIllustration(
          colors: widget.colors,
          t: _ctrl.value,
          w: w,
          h: h,
        );
      case IllustrationVariant.offerSeat:
        return _OfferSeatIllustration(
          colors: widget.colors,
          t: _ctrl.value,
          w: w,
          h: h,
        );
      case IllustrationVariant.planRoute:
        return _PlanRouteIllustration(
          colors: widget.colors,
          t: _ctrl.value,
          w: w,
          h: h,
        );
      case IllustrationVariant.connectGo:
        return _ConnectGoIllustration(
          colors: widget.colors,
          t: _ctrl.value,
          w: w,
          h: h,
        );
    }
  }
}

// ---------------------------------------------------------------------------
// Page 1 — Find Your Ride
// All geometry expressed as fractions of w / h — zero hardcoded pixels.
// ---------------------------------------------------------------------------

class _FindRideIllustration extends StatelessWidget {
  const _FindRideIllustration({
    required this.colors,
    required this.t,
    required this.w,
    required this.h,
  });

  final List<Color> colors;
  final double t;
  final double w;
  final double h;

  @override
  Widget build(BuildContext context) {
    final cx = w * 0.5;
    final cy = h * 0.5;
    final carR = math.min(w, h) * 0.14; // car circle radius
    final orbitR = h * 0.28; // orbit radius
    final avatarR = math.min(w, h) * 0.07; // runner avatar radius
    final pulse = 1.0 + 0.05 * math.sin(t * math.pi);

    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _ArcPainter(color: colors[0], t: t, cx: cx, cy: cy),
          ),
        ),

        // Central car
        Positioned(
          left: cx - carR * pulse,
          top: cy - carR * pulse,
          child: Transform.scale(
            scale: pulse,
            child: Container(
              width: carR * 2,
              height: carR * 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colors[0].withValues(alpha: 0.35),
                    blurRadius: carR * 0.8,
                  ),
                ],
              ),
              child: Icon(
                Icons.directions_car_filled_rounded,
                size: carR * 0.95,
                color: Colors.white,
              ),
            ),
          ),
        ),

        // Orbiting runner avatars
        for (int i = 0; i < 3; i++) ...[
          () {
            final angle = (i / 3) * 2 * math.pi + t * math.pi * 0.4;
            final dx = math.cos(angle) * orbitR;
            final dy = math.sin(angle) * orbitR;
            return Positioned(
              left: cx + dx - avatarR,
              top: cy + dy - avatarR,
              child: Container(
                width: avatarR * 2,
                height: avatarR * 2,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors[0].withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors[0].withValues(alpha: 0.14),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.directions_run_rounded,
                  size: avatarR * 0.9,
                  color: colors[0],
                ),
              ),
            );
          }(),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Page 2 — Offer a Seat
// ---------------------------------------------------------------------------

class _OfferSeatIllustration extends StatelessWidget {
  const _OfferSeatIllustration({
    required this.colors,
    required this.t,
    required this.w,
    required this.h,
  });

  final List<Color> colors;
  final double t;
  final double w;
  final double h;

  @override
  Widget build(BuildContext context) {
    // Cards take up ~38% of width each, gap fills the rest
    final cardW = (w * 0.36).clamp(68.0, 108.0);
    final cardH = (h * 0.30).clamp(54.0, 86.0);
    final gap = (w - cardW * 2) * 0.38;
    final badgeOffset = -4 * math.sin(t * math.pi);

    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(painter: _GridPainter(color: colors[0])),
        ),

        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SeatCard(
                    icon: Icons.person_rounded,
                    label: 'Driver',
                    colors: colors,
                    filled: true,
                    cardW: cardW,
                    cardH: cardH,
                    delay: 0,
                  ),
                  SizedBox(width: gap),
                  _SeatCard(
                    icon: Icons.person_add_alt_1_rounded,
                    label: 'Seat 2',
                    colors: colors,
                    filled: true,
                    cardW: cardW,
                    cardH: cardH,
                    delay: 80,
                  ),
                ],
              ),
              SizedBox(height: gap),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SeatCard(
                    icon: Icons.person_add_alt_1_rounded,
                    label: 'Seat 3',
                    colors: colors,
                    filled: false,
                    cardW: cardW,
                    cardH: cardH,
                    delay: 160,
                  ),
                  SizedBox(width: gap),
                  _SeatCard(
                    icon: Icons.person_add_alt_1_rounded,
                    label: 'Available',
                    colors: colors,
                    filled: false,
                    cardW: cardW,
                    cardH: cardH,
                    delay: 240,
                  ),
                ],
              ),
            ],
          ),
        ),

        // Cost badge — position as fraction of w/h
        Positioned(
          top: h * 0.07 + badgeOffset,
          right: w * 0.05,
          child: _FloatingBadge(label: '−12€', colors: colors, t: t),
        ),
      ],
    );
  }
}

class _SeatCard extends StatelessWidget {
  const _SeatCard({
    required this.icon,
    required this.label,
    required this.colors,
    required this.filled,
    required this.cardW,
    required this.cardH,
    required this.delay,
  });

  final IconData icon;
  final String label;
  final List<Color> colors;
  final bool filled;
  final double cardW;
  final double cardH;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return Container(
          width: cardW,
          height: cardH,
          decoration: BoxDecoration(
            gradient: filled
                ? LinearGradient(
                    colors: colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: filled ? null : Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: filled
                  ? Colors.transparent
                  : colors[0].withValues(alpha: 0.28),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: colors[0].withValues(alpha: filled ? 0.22 : 0.07),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: (cardH * 0.36).clamp(16.0, 28.0),
                color: filled
                    ? Colors.white
                    : colors[0].withValues(alpha: 0.45),
              ),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w700,
                  color: filled
                      ? Colors.white
                      : colors[0].withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(
          duration: 400.ms,
          delay: Duration(milliseconds: delay),
        )
        .scale(begin: const Offset(0.85, 0.85));
  }
}

// ---------------------------------------------------------------------------
// Page 3 — Plan Your Route
// ---------------------------------------------------------------------------

class _PlanRouteIllustration extends StatelessWidget {
  const _PlanRouteIllustration({
    required this.colors,
    required this.t,
    required this.w,
    required this.h,
  });

  final List<Color> colors;
  final double t;
  final double w;
  final double h;

  @override
  Widget build(BuildContext context) {
    // Cubic bezier control points — must match _RoutePainter exactly.
    final p0 = Offset(w * 0.10, h * 0.35);
    final p1 = Offset(w * 0.32, h * 0.12);
    final p2 = Offset(w * 0.68, h * 0.78);
    final p3 = Offset(w * 0.90, h * 0.62);

    // Standard cubic bezier formula: B(t) = (1-t)³P0 + 3(1-t)²tP1 + 3(1-t)t²P2 + t³P3
    final u = 1.0 - t;
    final carPos =
        p0 * (u * u * u) +
        p1 * (3 * u * u * t) +
        p2 * (3 * u * t * t) +
        p3 * (t * t * t);

    final pinSize = math.min(w, h) * 0.11;
    final carSize = pinSize * 0.75;

    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _RoutePainter(color: colors[0], t: t),
          ),
        ),

        // Pickup pin — anchored to bezier start (p0)
        Positioned(
          left: w * 0.10 - pinSize / 2,
          top: h * 0.38 - pinSize,
          child: _MapPin(
            icon: Icons.my_location_rounded,
            label: 'You',
            colors: colors,
            size: pinSize,
          ).animate().fadeIn(delay: 100.ms).slideY(begin: -0.3),
        ),

        // Destination pin — anchored to bezier end (p3)
        Positioned(
          left: w * 0.90 - pinSize / 2,
          top: h * 0.62 - pinSize,
          child: _MapPin(
            icon: Icons.flag_rounded,
            label: 'Race',
            colors: colors,
            size: pinSize,
          ).animate().fadeIn(delay: 300.ms).slideY(begin: -0.3),
        ),

        // Animated car dot — positioned exactly on the bezier curve
        Positioned(
          left: carPos.dx - carSize / 2,
          top: carPos.dy - carSize / 2,
          child: Container(
            width: carSize,
            height: carSize,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colors[0].withValues(alpha: 0.4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(
              Icons.directions_car_filled_rounded,
              size: carSize * 0.52,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin({
    required this.icon,
    required this.label,
    required this.colors,
    required this.size,
  });

  final IconData icon;
  final String label;
  final List<Color> colors;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colors[0].withValues(alpha: 0.35),
                blurRadius: 8,
              ),
            ],
          ),
          child: Icon(icon, size: size * 0.48, color: Colors.white),
        ),
        SizedBox(height: 3.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 4,
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 8.sp,
              fontWeight: FontWeight.w700,
              color: colors[0],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Page 4 — Connect & Go
// ---------------------------------------------------------------------------

class _ConnectGoIllustration extends StatelessWidget {
  const _ConnectGoIllustration({
    required this.colors,
    required this.t,
    required this.w,
    required this.h,
  });

  final List<Color> colors;
  final double t;
  final double w;
  final double h;

  @override
  Widget build(BuildContext context) {
    final cx = w * 0.5;
    final cy = h * 0.5;
    final badgeR = math.min(w, h) * 0.13;
    // Orbit radius: fits inside the tighter of cx / cy with padding
    final orbitR = math.min(cx, cy) * 0.64;
    final bubbleR = math.min(w, h) * 0.065;

    final compassItems = [
      (Icons.chat_bubble_rounded, 'Chat', Offset(cx, cy - orbitR)),
      (Icons.shield_rounded, 'Safe', Offset(cx + orbitR, cy)),
      (Icons.location_on_rounded, 'Live', Offset(cx, cy + orbitR)),
      (Icons.star_rounded, 'Rated', Offset(cx - orbitR, cy)),
    ];

    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _PulseRingPainter(color: colors[0], t: t, cx: cx, cy: cy),
          ),
        ),

        // Central badge
        Positioned(
          left: cx - badgeR,
          top: cy - badgeR,
          child: Container(
            width: badgeR * 2,
            height: badgeR * 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colors[0].withValues(alpha: 0.4),
                  blurRadius: badgeR * 0.6,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              Icons.verified_rounded,
              size: badgeR * 0.85,
              color: Colors.white,
            ),
          ),
        ),

        // Compass bubbles — positioned relative to cx/cy, no fixed offsets
        for (final item in compassItems)
          Positioned(
            left: item.$3.dx - bubbleR,
            top: item.$3.dy - bubbleR,
            child: _CompassBubble(
              icon: item.$1,
              label: item.$2,
              colors: colors,
              size: bubbleR * 2,
            ),
          ),
      ],
    );
  }
}

class _CompassBubble extends StatelessWidget {
  const _CompassBubble({
    required this.icon,
    required this.label,
    required this.colors,
    required this.size,
  });

  final IconData icon;
  final String label;
  final List<Color> colors;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: colors[0].withValues(alpha: 0.28),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: colors[0].withValues(alpha: 0.12),
                blurRadius: 8,
              ),
            ],
          ),
          child: Icon(icon, size: size * 0.45, color: colors[0]),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 8.sp,
            fontWeight: FontWeight.w700,
            color: colors[0],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Custom painters — all geometry relative to canvas size or passed cx/cy
// ---------------------------------------------------------------------------

class _ArcPainter extends CustomPainter {
  _ArcPainter({
    required this.color,
    required this.t,
    required this.cx,
    required this.cy,
  });
  final Color color;
  final double t;
  final double cx;
  final double cy;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final base = math.min(size.width, size.height) * 0.18;
    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(cx, cy),
        base + i * base * 0.85 + t * base * 0.12,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ArcPainter o) => o.t != t;
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.06)
      ..strokeWidth = 1;
    // Grid step = 1/10 of width — stays proportional on any screen
    final step = size.width / 10;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter o) => false;
}

class _RoutePainter extends CustomPainter {
  _RoutePainter({required this.color, required this.t});
  final Color color;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = color.withValues(alpha: 0.04),
    );

    final gridPaint = Paint()
      ..color = color.withValues(alpha: 0.07)
      ..strokeWidth = 1;
    final step = w / 9;
    for (double x = 0; x <= w; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
    }
    for (double y = 0; y <= h; y += step) {
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // Route bezier — control points MUST match _PlanRouteIllustration exactly.
    final path = Path()
      ..moveTo(w * 0.10, h * 0.35)
      ..cubicTo(w * 0.32, h * 0.12, w * 0.68, h * 0.78, w * 0.90, h * 0.62);

    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: 0.65)
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Dashed animated progress overlay
    final metrics = path.computeMetrics().first;
    final totalLen = metrics.length;
    const dashLen = 7.0;
    const gapLen = 5.0;
    final progress = totalLen * t /*(0.25 + t * 0.55)*/;
    double d = 0;
    while (d < progress) {
      final seg = metrics.extractPath(d, math.min(d + dashLen, progress));
      canvas.drawPath(
        seg,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.55)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
      d += dashLen + gapLen;
    }
  }

  @override
  bool shouldRepaint(_RoutePainter o) => o.t != t;
}

class _PulseRingPainter extends CustomPainter {
  _PulseRingPainter({
    required this.color,
    required this.t,
    required this.cx,
    required this.cy,
  });
  final Color color;
  final double t;
  final double cx;
  final double cy;

  @override
  void paint(Canvas canvas, Size size) {
    final base = math.min(size.width, size.height) * 0.18;
    for (var i = 0; i < 3; i++) {
      final alpha = (0.12 - i * 0.03 + t * 0.03).clamp(0.0, 0.14);
      canvas.drawCircle(
        Offset(cx, cy),
        base * (1.0 + i * 0.55) + t * base * 0.10,
        Paint()
          ..color = color.withValues(alpha: alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(_PulseRingPainter o) => o.t != t;
}

// ---------------------------------------------------------------------------
// Shared widgets
// ---------------------------------------------------------------------------

class _GradientPill extends StatelessWidget {
  const _GradientPill({required this.colors, required this.child});
  final List<Color> colors;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(25.r),
        boxShadow: [
          BoxShadow(
            color: colors[0].withValues(alpha: 0.26),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _FloatingBadge extends StatelessWidget {
  const _FloatingBadge({
    required this.label,
    required this.colors,
    required this.t,
  });
  final String label;
  final List<Color> colors;
  final double t;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, -4 * math.sin(t * math.pi)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 6.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: colors[0].withValues(alpha: 0.38),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _SubtitleBadge extends StatelessWidget {
  const _SubtitleBadge({required this.label, required this.colors});
  final String label;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 6.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors[0].withValues(alpha: 0.11),
            colors[1].withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colors[0].withValues(alpha: 0.22)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w800,
          color: colors[0],
          letterSpacing: 1.5,
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 150.ms).slideY(begin: 0.2);
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 32.sp,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
          height: 1.1,
          letterSpacing: -0.7,
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(begin: 0.2);
  }
}

class _Description extends StatelessWidget {
  const _Description({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.sp,
        color: AppColors.textSecondary,
        height: 1.65,
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 280.ms).slideY(begin: 0.2);
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.features, required this.accentColor});
  final List<String> features;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Features: ${features.join(', ')}',
      child: Row(
        children: features.asMap().entries.map((e) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: e.key < features.length - 1 ? 7.w : 0,
              ),
              child: _FeatureChip(
                label: e.value,
                accentColor: accentColor,
                delay: e.key * 80,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({
    required this.label,
    required this.accentColor,
    required this.delay,
  });
  final String label;
  final Color accentColor;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return Container(
          padding: EdgeInsets.symmetric(vertical: 9.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(11.r),
            border: Border.all(color: accentColor.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.09),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_rounded, size: 14.sp, color: accentColor),
              SizedBox(height: 3.h),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(
          duration: 400.ms,
          delay: Duration(milliseconds: 380 + delay),
        )
        .slideY(begin: 0.25)
        .scale(begin: const Offset(0.88, 0.88));
  }
}

// ---------------------------------------------------------------------------
// Bottom controls
// ---------------------------------------------------------------------------

class _BottomControls extends StatelessWidget {
  const _BottomControls({
    required this.currentPage,
    required this.pages,
    required this.vmState,
    required this.pageController,
    required this.onComplete,
  });

  final int currentPage;
  final List<OnboardingPage> pages;
  final OnboardingState vmState;
  final PageController pageController;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final isLast = currentPage == pages.length - 1;
    final isCompleting = vmState.isCompleting;
    final page = pages[currentPage];

    return Container(
      padding: EdgeInsets.fromLTRB(22.w, 10.h, 22.w, 22.h),
      child: Column(
        children: [
          // Dot indicators
          ExcludeSemantics(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pages.length, (i) {
                final cur = i == currentPage;
                return AnimatedContainer(
                  duration: 300.ms,
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  height: 7.h,
                  width: cur ? 26.w : 7.w,
                  decoration: BoxDecoration(
                    color: cur ? page.gradientColors[0] : AppColors.border,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                );
              }),
            ),
          ),

          SizedBox(height: 18.h),

          Row(
            children: [
              if (currentPage > 0) ...[
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    pageController.previousPage(
                      duration: const Duration(milliseconds: 450),
                      curve: Curves.easeOutCubic,
                    );
                  },
                  child: Container(
                    width: 54.w,
                    height: 54.w,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                    child: Icon(
                      Icons.adaptive.arrow_back_rounded,
                      color: AppColors.textSecondary,
                      size: 22.sp,
                    ),
                  ),
                ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.2),
                SizedBox(width: 12.w),
              ],

              Expanded(
                child: GestureDetector(
                  onTap: isCompleting
                      ? null
                      : () {
                          HapticFeedback.mediumImpact();
                          if (isLast) {
                            onComplete();
                          } else {
                            pageController.nextPage(
                              duration: const Duration(milliseconds: 450),
                              curve: Curves.easeOutCubic,
                            );
                          }
                        },
                  child: AnimatedContainer(
                    duration: 300.ms,
                    height: 54.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: page.gradientColors),
                      borderRadius: BorderRadius.circular(15.r),
                      boxShadow: [
                        BoxShadow(
                          color: page.gradientColors[0].withValues(alpha: 0.34),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isCompleting
                              ? '...'
                              : isLast
                              ? AppLocalizations.of(context).getStarted
                              : AppLocalizations.of(context).kContinue,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Container(
                              width: 28.w,
                              height: 28.w,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isLast
                                    ? Icons.rocket_launch_rounded
                                    : Icons.adaptive.arrow_forward_rounded,
                                color: Colors.white,
                                size: 14.sp,
                              ),
                            )
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .slideX(
                              begin: 0,
                              end: 0.15,
                              duration: 900.ms,
                              curve: Curves.easeInOut,
                            ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
