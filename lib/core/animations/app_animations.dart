import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sport_connect/core/theme/app_colors.dart';

/// Global animation configurations and effects for the SportConnect app
/// These create a cohesive, premium user experience with micro-interactions

class AppAnimations {
  /// Configure global defaults at app startup
  static void configure() {
    Animate.defaultDuration = 400.ms;
    Animate.defaultCurve = Curves.easeOutCubic;
    Animate.restartOnHotReload = true;
  }

  // ============================================================
  // ENTRY ANIMATIONS - For widgets appearing on screen
  // ============================================================

  /// Fade in and slide up - Great for cards and list items
  static List<Effect> get fadeInUp => [
    FadeEffect(duration: 400.ms, curve: Curves.easeOut),
    SlideEffect(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
      duration: 400.ms,
      curve: Curves.easeOutCubic,
    ),
  ];

  /// Fade in and slide from right - Good for navigation transitions
  static List<Effect> get fadeInRight => [
    FadeEffect(duration: 350.ms, curve: Curves.easeOut),
    SlideEffect(
      begin: const Offset(0.15, 0),
      end: Offset.zero,
      duration: 350.ms,
      curve: Curves.easeOutCubic,
    ),
  ];

  /// Scale in with fade - Great for buttons and icons
  static List<Effect> get scaleIn => [
    FadeEffect(duration: 300.ms),
    ScaleEffect(
      begin: const Offset(0.85, 0.85),
      end: const Offset(1, 1),
      duration: 300.ms,
      curve: Curves.easeOutBack,
    ),
  ];

  /// Bounce in scale - Playful entry for achievement badges
  static List<Effect> get bounceIn => [
    FadeEffect(duration: 300.ms),
    ScaleEffect(
      begin: const Offset(0.3, 0.3),
      end: const Offset(1, 1),
      duration: 500.ms,
      curve: Curves.elasticOut,
    ),
  ];

  /// Subtle pop - For interactive elements
  static List<Effect> get popIn => [
    FadeEffect(duration: 200.ms),
    ScaleEffect(
      begin: const Offset(0.9, 0.9),
      end: const Offset(1, 1),
      duration: 250.ms,
      curve: Curves.easeOutBack,
    ),
  ];

  // ============================================================
  // STAGGER INTERVALS - For list animations
  // ============================================================

  static Duration get staggerInterval => 50.ms;
  static Duration get staggerIntervalSlow => 100.ms;
  static Duration get staggerIntervalFast => 30.ms;

  // ============================================================
  // ATTENTION ANIMATIONS - Draw focus to elements
  // ============================================================

  /// Subtle pulse effect - For notifications or important elements
  static List<Effect> get pulse => [
    ScaleEffect(
      begin: const Offset(1, 1),
      end: const Offset(1.05, 1.05),
      duration: 600.ms,
      curve: Curves.easeInOut,
    ),
  ];

  /// Shimmer loading effect
  static List<Effect> get shimmer => [
    ShimmerEffect(duration: 1500.ms, color: const Color(0x3000B894)),
  ];

  /// Shake for errors
  static List<Effect> get errorShake => [
    ShakeEffect(
      duration: 400.ms,
      hz: 5,
      offset: const Offset(8, 0),
      rotation: 0,
    ),
    TintEffect(color: AppColors.error, end: 0.2, duration: 200.ms),
  ];

  /// Glow for success
  static List<Effect> get successGlow => [
    TintEffect(color: const Color(0xFF00B894), end: 0.3, duration: 300.ms),
    ScaleEffect(
      begin: const Offset(1, 1),
      end: const Offset(1.02, 1.02),
      duration: 200.ms,
      curve: Curves.easeOut,
    ),
  ];

  // ============================================================
  // BUTTON INTERACTIONS
  // ============================================================

  /// Tap feedback - scale down slightly
  static List<Effect> get buttonPress => [
    ScaleEffect(
      begin: const Offset(1, 1),
      end: const Offset(0.95, 0.95),
      duration: 100.ms,
      curve: Curves.easeInOut,
    ),
  ];

  // ============================================================
  // HERO ANIMATIONS - For splash and onboarding
  // ============================================================

  /// Dramatic hero entrance
  static List<Effect> get heroEntrance => [
    FadeEffect(duration: 800.ms, curve: Curves.easeOut),
    ScaleEffect(
      begin: const Offset(0.7, 0.7),
      end: const Offset(1, 1),
      duration: 1000.ms,
      curve: Curves.easeOutCubic,
    ),
    BlurEffect(
      begin: const Offset(10, 10),
      end: Offset.zero,
      duration: 800.ms,
      curve: Curves.easeOut,
    ),
  ];

  /// Floating animation for hero images
  static List<Effect> get floating => [
    MoveEffect(
      begin: const Offset(0, 0),
      end: const Offset(0, -10),
      duration: 2000.ms,
      curve: Curves.easeInOut,
    ),
  ];

  // ============================================================
  // CARD ANIMATIONS
  // ============================================================

  /// Ride card entry - slides up with slight delay for polish
  static List<Effect> get rideCardEntry => [
    FadeEffect(duration: 350.ms, curve: Curves.easeOut),
    SlideEffect(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
      duration: 400.ms,
      curve: Curves.easeOutCubic,
    ),
    ScaleEffect(
      begin: const Offset(0.97, 0.97),
      end: const Offset(1, 1),
      duration: 400.ms,
      curve: Curves.easeOut,
    ),
  ];

  // ============================================================
  // NAVIGATION ANIMATIONS
  // ============================================================

  /// Tab switch animation
  static List<Effect> get tabSwitch => [
    FadeEffect(duration: 200.ms),
    SlideEffect(
      begin: const Offset(0.05, 0),
      end: Offset.zero,
      duration: 200.ms,
      curve: Curves.easeOut,
    ),
  ];

  // ============================================================
  // UTILITY METHODS
  // ============================================================

  /// Create staggered list animation
  static Widget animateList({
    required List<Widget> children,
    Duration interval = const Duration(milliseconds: 50),
    Duration duration = const Duration(milliseconds: 400),
    Offset slideOffset = const Offset(0, 0.1),
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children
          .asMap()
          .entries
          .map(
            (entry) => entry.value
                .animate(
                  delay: Duration(
                    milliseconds: entry.key * interval.inMilliseconds,
                  ),
                )
                .fadeIn(duration: duration)
                .slide(
                  begin: slideOffset,
                  end: Offset.zero,
                  duration: duration,
                ),
          )
          .toList(),
    );
  }
}

// ============================================================
// EXTENSION METHODS FOR EASY ACCESS
// ============================================================

extension AnimateExtensions on Widget {
  /// Apply fade in up animation
  Widget animateFadeInUp({Duration? delay}) {
    return animate(delay: delay)
        .fadeIn(duration: 400.ms)
        .slideY(
          begin: 0.1,
          end: 0,
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        );
  }

  /// Apply fade in from right animation
  Widget animateFadeInRight({Duration? delay}) {
    return animate(delay: delay)
        .fadeIn(duration: 350.ms)
        .slideX(
          begin: 0.15,
          end: 0,
          duration: 350.ms,
          curve: Curves.easeOutCubic,
        );
  }

  /// Apply scale in animation
  Widget animateScaleIn({Duration? delay}) {
    return animate(delay: delay)
        .fadeIn(duration: 300.ms)
        .scale(
          begin: const Offset(0.85, 0.85),
          end: const Offset(1, 1),
          duration: 300.ms,
          curve: Curves.easeOutBack,
        );
  }

  /// Apply bounce in animation
  Widget animateBounceIn({Duration? delay}) {
    return animate(delay: delay)
        .fadeIn(duration: 300.ms)
        .scale(
          begin: const Offset(0.3, 0.3),
          end: const Offset(1, 1),
          duration: 500.ms,
          curve: Curves.elasticOut,
        );
  }

  /// Apply shimmer loading animation
  Widget animateShimmer() {
    return animate(
      onPlay: (controller) => controller.repeat(),
    ).shimmer(duration: 1500.ms, color: const Color(0x3000B894));
  }

  /// Apply pulse animation (looping)
  Widget animatePulse() {
    return animate(
      onPlay: (controller) => controller.repeat(reverse: true),
    ).scale(
      begin: const Offset(1, 1),
      end: const Offset(1.05, 1.05),
      duration: 1000.ms,
      curve: Curves.easeInOut,
    );
  }

  /// Apply floating animation (looping)
  Widget animateFloating() {
    return animate(
      onPlay: (controller) => controller.repeat(reverse: true),
    ).moveY(begin: 0, end: -10, duration: 2000.ms, curve: Curves.easeInOut);
  }

  /// Apply error shake animation
  Widget animateError() {
    return animate()
        .shake(hz: 5, offset: const Offset(8, 0), duration: 400.ms)
        .tint(color: AppColors.error, end: 0.2, duration: 200.ms);
  }

  /// Apply success glow animation
  Widget animateSuccess() {
    return animate()
        .tint(color: const Color(0xFF00B894), end: 0.3, duration: 300.ms)
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.02, 1.02),
          duration: 200.ms,
        );
  }

  /// Staggered item in a list
  Widget animateListItem(
    int index, {
    Duration interval = const Duration(milliseconds: 50),
  }) {
    return animate(
          delay: Duration(milliseconds: index * interval.inMilliseconds),
        )
        .fadeIn(duration: 400.ms)
        .slideY(
          begin: 0.1,
          end: 0,
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        );
  }
}
