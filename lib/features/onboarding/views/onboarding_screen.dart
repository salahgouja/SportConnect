import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:sport_connect/core/config/app_router.dart';
import 'package:sport_connect/core/theme/app_colors.dart';

/// Data model for onboarding pages
class OnboardingPage {
  final String title;
  final String subtitle;
  final String description;
  final String lottieUrl;
  final List<Color> gradientColors;
  final List<String> features;
  final String emoji;

  const OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.lottieUrl,
    required this.gradientColors,
    this.features = const [],
    this.emoji = '🚀',
  });
}

/// Premium Onboarding Screen with beautiful Lottie animations
/// Clean, modern design with warm sunset colors
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Find Running\nPartners',
      subtitle: 'Run Together',
      description:
          'Connect with runners in your area. Find partners for morning jogs, evening runs, or marathon training.',
      lottieUrl:
          'https://lottie.host/e47c7b5e-dc95-4f75-8e78-b6e8c1bd7a7f/5k1bTD3w4O.json',
      gradientColors: [
        AppColors.primary,
        AppColors.primary.withValues(alpha: 0.7),
      ],
      features: ['Find Runners', 'Nearby Routes', 'Pace Matching'],
      emoji: '',
    ),
    OnboardingPage(
      title: 'Join Running\nGroups',
      subtitle: 'Train With Community',
      description:
          'Create or join running groups. Train together, share routes, and push each other to new personal bests.',
      lottieUrl:
          'https://lottie.host/7b0c3f22-0af2-4e6c-9f3d-4f0e6b2b9c7d/wHBmPMZ8hc.json',
      gradientColors: [
        AppColors.secondary,
        AppColors.secondary.withValues(alpha: 0.7),
      ],
      features: ['Running Clubs', 'Group Chat', 'Training Plans'],
      emoji: '',
    ),
    OnboardingPage(
      title: 'Track Your\nProgress',
      subtitle: 'Monitor Performance',
      description:
          'Track your distance, pace, and personal records. See your improvement over time with detailed statistics.',
      lottieUrl:
          'https://lottie.host/37a8e726-9b3d-4c8e-8f7a-2d8a7b6c5d4e/nKP2gMZE9w.json',
      gradientColors: [
        AppColors.primary,
        AppColors.primary.withValues(alpha: 0.7),
      ],
      features: ['Run History', 'Performance Stats', 'Personal Records'],
      emoji: '',
    ),
    OnboardingPage(
      title: 'Achieve Your\nGoals',
      subtitle: 'Personal Best Awaits',
      description:
          'Set running goals, follow training programs, and get personalized recommendations to become a better runner.',
      lottieUrl:
          'https://lottie.host/c5f2a8e9-1b3d-4c7e-8a9f-2d1a3b5c6d7e/xYWvQnR3tK.json',
      gradientColors: [
        AppColors.secondary,
        AppColors.secondary.withValues(alpha: 0.7),
      ],
      features: ['Goal Setting', 'Run Analytics', 'Training Plans'],
      emoji: '',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
  }

  Future<void> _completeOnboarding() async {
    // Show clean welcome dialog
    await _showWelcomeDialog();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (mounted) {
      context.go(AppRouter.login);
    }
  }

  Future<void> _showWelcomeDialog() async {
    HapticFeedback.mediumImpact();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(28.w),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(20.r),
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
              // Clean runner icon
              Container(
                width: 72.w,
                height: 72.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.directions_run_rounded,
                  size: 36.sp,
                  color: AppColors.primary,
                ),
              ).animate().scale(
                begin: const Offset(0.8, 0.8),
                duration: 300.ms,
                curve: Curves.easeOutBack,
              ),

              SizedBox(height: 20.h),

              // Title - professional, no emoji
              Text(
                "You're Ready to Run",
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 150.ms),

              SizedBox(height: 10.h),

              Text(
                'Create an account to start tracking your runs and connect with other runners.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 250.ms),

              SizedBox(height: 28.h),

              // Continue button - clean styling
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    'Continue',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.2),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            _buildTopBar(),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index], index);
                },
              ),
            ),

            // Bottom controls
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Page indicator badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _pages[_currentPage].gradientColors,
                  ),
                  borderRadius: BorderRadius.circular(25.r),
                  boxShadow: [
                    BoxShadow(
                      color: _pages[_currentPage].gradientColors[0].withValues(
                        alpha: 0.3,
                      ),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'Step ${_currentPage + 1} of ${_pages.length}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2),

              // Skip button
              if (_currentPage < _pages.length - 1)
                GestureDetector(
                      onTap: _completeOnboarding,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(25.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Skip',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: AppColors.textSecondary,
                              size: 18.sp,
                            ),
                          ],
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 100.ms)
                    .slideX(begin: 0.2),
            ],
          ),

          SizedBox(height: 16.h),

          // Step progress indicator
          _buildStepProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildStepProgressIndicator() {
    final stepLabels = ['Partners', 'Groups', 'Progress', 'Goals'];

    return Row(
      children: List.generate(_pages.length, (index) {
        final isActive = index <= _currentPage;
        final isCurrent = index == _currentPage;

        return Expanded(
          child: Row(
            children: [
              // Step circle
              Column(
                children: [
                  AnimatedContainer(
                    duration: 300.ms,
                    width: isCurrent ? 32.w : 24.w,
                    height: isCurrent ? 32.w : 24.w,
                    decoration: BoxDecoration(
                      gradient: isActive
                          ? LinearGradient(colors: _pages[index].gradientColors)
                          : null,
                      color: isActive ? null : AppColors.border,
                      shape: BoxShape.circle,
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: _pages[index].gradientColors[0]
                                    .withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: isActive && index < _currentPage
                          ? Icon(
                              Icons.check_rounded,
                              size: 14.sp,
                              color: Colors.white,
                            )
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: isCurrent ? 14.sp : 11.sp,
                                fontWeight: FontWeight.w700,
                                color: isActive
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    stepLabels[index],
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                      color: isActive
                          ? _pages[index].gradientColors[0]
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              // Connector line
              if (index < _pages.length - 1)
                Expanded(
                  child: Container(
                    height: 3.h,
                    margin: EdgeInsets.only(bottom: 16.h),
                    decoration: BoxDecoration(
                      gradient: index < _currentPage
                          ? LinearGradient(
                              colors: [
                                _pages[index].gradientColors[0],
                                _pages[index + 1].gradientColors[0],
                              ],
                            )
                          : null,
                      color: index < _currentPage ? null : AppColors.border,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    ).animate().fadeIn(duration: 500.ms, delay: 200.ms);
  }

  Widget _buildPage(OnboardingPage page, int index) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28.w),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 20.h),

            // Lottie Animation Container
            _buildLottieContainer(page, index),

            SizedBox(height: 40.h),

            // Subtitle badge
            _buildSubtitleBadge(page),

            SizedBox(height: 16.h),

            // Title
            _buildTitle(page),

            SizedBox(height: 16.h),

            // Description
            _buildDescription(page),

            SizedBox(height: 24.h),

            // Feature chips
            _buildFeatureChips(page),
          ],
        ),
      ),
    );
  }

  Widget _buildLottieContainer(OnboardingPage page, int index) {
    return Container(
          height: 280.h,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                page.gradientColors[0].withValues(alpha: 0.1),
                page.gradientColors[1].withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(32.r),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32.r),
            child: Lottie.network(
              page.lottieUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return _buildFallbackAnimation(page);
              },
              frameBuilder: (context, child, composition) {
                if (composition == null) {
                  return _buildLoadingPlaceholder(page);
                }
                return child;
              },
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 600.ms)
        .scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack);
  }

  Widget _buildFallbackAnimation(OnboardingPage page) {
    IconData iconData;
    switch (page.emoji) {
      case '🏃':
        iconData = Icons.sports_soccer_rounded;
        break;
      case '🤝':
        iconData = Icons.groups_rounded;
        break;
      case '🏆':
        iconData = Icons.emoji_events_rounded;
        break;
      case '📊':
        iconData = Icons.trending_up_rounded;
        break;
      default:
        iconData = Icons.star_rounded;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: page.gradientColors,
        ),
        borderRadius: BorderRadius.circular(32.r),
      ),
      child: Center(
        child: Container(
          width: 140.w,
          height: 140.w,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(iconData, size: 70.sp, color: page.gradientColors[0])
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.1, 1.1),
                duration: 1500.ms,
              ),
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder(OnboardingPage page) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            page.gradientColors[0].withValues(alpha: 0.2),
            page.gradientColors[1].withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(32.r),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: page.gradientColors[0],
          strokeWidth: 3,
        ),
      ),
    );
  }

  Widget _buildSubtitleBadge(OnboardingPage page) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            page.gradientColors[0].withValues(alpha: 0.15),
            page.gradientColors[1].withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(25.r),
        border: Border.all(
          color: page.gradientColors[0].withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        page.subtitle.toUpperCase(),
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
          color: page.gradientColors[0],
          letterSpacing: 2,
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 150.ms).slideY(begin: 0.2);
  }

  Widget _buildTitle(OnboardingPage page) {
    return Text(
      page.title,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 36.sp,
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
        height: 1.1,
        letterSpacing: -1,
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(begin: 0.2);
  }

  Widget _buildDescription(OnboardingPage page) {
    return Text(
      page.description,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.6,
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 300.ms).slideY(begin: 0.2);
  }

  Widget _buildFeatureChips(OnboardingPage page) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10.w,
      runSpacing: 12.h,
      children: page.features.asMap().entries.map((entry) {
        return _buildFeatureChip(
          entry.value,
          page.gradientColors[0],
          entry.key,
        );
      }).toList(),
    );
  }

  Widget _buildFeatureChip(String feature, Color accentColor, int index) {
    return Container(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30.r),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.15),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(color: accentColor.withValues(alpha: 0.2)),
          ),
          child: Text(
            feature,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        )
        .animate()
        .fadeIn(
          duration: 400.ms,
          delay: Duration(milliseconds: 400 + index * 100),
        )
        .slideY(begin: 0.3)
        .scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildBottomControls() {
    final isLastPage = _currentPage == _pages.length - 1;

    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
      child: Column(
        children: [
          // Page indicator
          SmoothPageIndicator(
            controller: _pageController,
            count: _pages.length,
            effect: ExpandingDotsEffect(
              dotHeight: 10.h,
              dotWidth: 10.w,
              activeDotColor: _pages[_currentPage].gradientColors[0],
              dotColor: AppColors.border,
              expansionFactor: 4,
              spacing: 10.w,
            ),
          ),

          SizedBox(height: 32.h),

          // Navigation buttons
          Row(
            children: [
              // Back button
              if (_currentPage > 0)
                GestureDetector(
                  onTap: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                    );
                  },
                  child: Container(
                    width: 60.w,
                    height: 60.w,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.textSecondary,
                      size: 26.sp,
                    ),
                  ),
                ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.2),

              if (_currentPage > 0) SizedBox(width: 16.w),

              // Next/Get Started button
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (isLastPage) {
                      _completeOnboarding();
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                      );
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 60.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _pages[_currentPage].gradientColors,
                      ),
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: _pages[_currentPage].gradientColors[0]
                              .withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLastPage ? 'Get Started' : 'Continue',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Container(
                              width: 32.w,
                              height: 32.w,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isLastPage
                                    ? Icons.rocket_launch_rounded
                                    : Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 18.sp,
                              ),
                            )
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .slideX(begin: 0, end: 0.15, duration: 800.ms),
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
