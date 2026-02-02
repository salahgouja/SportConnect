import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:sport_connect/core/theme/app_colors.dart';

/// Service for managing feature discovery and app tours
/// Similar to driver.js for Flutter - Updated for showcaseview 5.x
class FeatureDiscoveryService {
  static const String _prefKeyHomeShown = 'feature_tour_home_shown';
  static const String _prefKeyRideShown = 'feature_tour_ride_shown';
  static const String _prefKeyChatShown = 'feature_tour_chat_shown';
  static const String _prefKeyProfileShown = 'feature_tour_profile_shown';
  static const String _prefKeyFirstTimeUser = 'first_time_user_tour';

  static bool _isRegistered = false;

  /// Register ShowcaseView with global configuration (call once in main or first screen)
  static void register() {
    if (_isRegistered) return;
    ShowcaseView.register(
      autoPlayDelay: const Duration(seconds: 3),
      blurValue: 2.0,
      enableAutoScroll: true,
      scrollDuration: const Duration(milliseconds: 500),
      onFinish: () {
        debugPrint('Showcase tour finished');
      },
      onDismiss: (key) {
        debugPrint('Showcase dismissed at: $key');
      },
    );
    _isRegistered = true;
  }

  /// Unregister ShowcaseView (call in dispose)
  static void unregister() {
    if (!_isRegistered) return;
    try {
      ShowcaseView.get().unregister();
    } catch (e) {
      debugPrint('Error unregistering showcase: $e');
    }
    _isRegistered = false;
  }

  /// Start a showcase tour with given keys
  static void startShowcase(List<GlobalKey> keys) {
    if (!_isRegistered) {
      register();
    }
    ShowcaseView.get().startShowCase(keys);
  }

  /// Dismiss current showcase
  static void dismiss() {
    if (_isRegistered) {
      ShowcaseView.get().dismiss();
    }
  }

  /// Navigate to next showcase
  static void next() {
    if (_isRegistered) {
      ShowcaseView.get().next();
    }
  }

  /// Navigate to previous showcase
  static void previous() {
    if (_isRegistered) {
      ShowcaseView.get().previous();
    }
  }

  /// Check if a specific tour has been shown
  static Future<bool> isTourShown(String tourKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(tourKey) ?? false;
  }

  /// Mark a tour as shown
  static Future<void> markTourShown(String tourKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(tourKey, true);
  }

  /// Check if this is the user's first time (for post-role-selection tour)
  static Future<bool> isFirstTimeUser() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_prefKeyFirstTimeUser) ?? false);
  }

  /// Mark first time tour as completed
  static Future<void> markFirstTimeTourComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyFirstTimeUser, true);
  }

  /// Reset all tours
  static Future<void> resetAllTours() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKeyHomeShown);
    await prefs.remove(_prefKeyRideShown);
    await prefs.remove(_prefKeyChatShown);
    await prefs.remove(_prefKeyProfileShown);
    await prefs.remove(_prefKeyFirstTimeUser);
  }

  /// Keys for different tours
  static String get homeToursKey => _prefKeyHomeShown;
  static String get rideToursKey => _prefKeyRideShown;
  static String get chatToursKey => _prefKeyChatShown;
  static String get profileToursKey => _prefKeyProfileShown;
}

/// Custom Showcase tooltip with premium styling
class PremiumShowcaseTooltip extends StatelessWidget {
  final String title;
  final String description;
  final IconData? icon;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final bool showSkip;
  final VoidCallback? onSkip;
  final int? currentStep;
  final int? totalSteps;

  const PremiumShowcaseTooltip({
    super.key,
    required this.title,
    required this.description,
    this.icon,
    this.buttonText,
    this.onButtonPressed,
    this.showSkip = true,
    this.onSkip,
    this.currentStep,
    this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 300.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, AppColors.surfaceVariant],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step indicator
          if (currentStep != null && totalSteps != null) ...[
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    'Step $currentStep of $totalSteps',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const Spacer(),
                if (showSkip)
                  GestureDetector(
                    onTap: onSkip,
                    child: Text(
                      'Skip tour',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12.h),
          ],

          // Icon and title row
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24.sp),
                ),
                SizedBox(width: 12.w),
              ],
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Description
          Text(
            description,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),

          // Action button
          if (buttonText != null) ...[
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      buttonText!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Icon(Icons.arrow_forward_rounded, size: 18.sp),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Global showcase keys for feature discovery
class ShowcaseKeys {
  // Home screen keys
  static final GlobalKey searchRidesKey = GlobalKey();
  static final GlobalKey createRideKey = GlobalKey();
  static final GlobalKey xpProgressKey = GlobalKey();
  static final GlobalKey quickActionsKey = GlobalKey();
  static final GlobalKey bottomNavKey = GlobalKey();

  // Ride screen keys
  static final GlobalKey fromLocationKey = GlobalKey();
  static final GlobalKey toLocationKey = GlobalKey();
  static final GlobalKey datePickerKey = GlobalKey();
  static final GlobalKey seatsKey = GlobalKey();
  static final GlobalKey filtersKey = GlobalKey();

  // Chat screen keys
  static final GlobalKey chatTabsKey = GlobalKey();
  static final GlobalKey chatSearchKey = GlobalKey();
  static final GlobalKey chatItemKey = GlobalKey();

  // Profile screen keys
  static final GlobalKey levelAvatarKey = GlobalKey();
  static final GlobalKey xpSectionKey = GlobalKey();
  static final GlobalKey statsGridKey = GlobalKey();
  static final GlobalKey achievementsKey = GlobalKey();
}

/// Extension to start showcases easily (updated for v5.x API)
extension ShowcaseExtension on BuildContext {
  /// Start a showcase tour with given keys
  void startShowcaseTour(List<GlobalKey> keys) {
    FeatureDiscoveryService.startShowcase(keys);
  }

  /// Dismiss current showcase
  void dismissShowcase() {
    FeatureDiscoveryService.dismiss();
  }

  /// Skip to next showcase
  void nextShowcase() {
    FeatureDiscoveryService.next();
  }

  /// Go to previous showcase
  void previousShowcase() {
    FeatureDiscoveryService.previous();
  }
}

/// Builder for creating showcase widgets with consistent styling
class ShowcaseBuilder {
  /// Build a showcase widget with premium styling
  static Widget build({
    required GlobalKey key,
    required Widget child,
    required String title,
    required String description,
    IconData? icon,
    int? currentStep,
    int? totalSteps,
    VoidCallback? onComplete,
    VoidCallback? onSkip,
    ShapeBorder? targetShapeBorder,
    double targetPadding = 8,
    Color overlayColor = const Color(0xCC000000),
    Duration animationDuration = const Duration(milliseconds: 300),
    bool showArrow = true,
    TooltipPosition? tooltipPosition,
  }) {
    return Showcase.withWidget(
      key: key,
      container: PremiumShowcaseTooltip(
        title: title,
        description: description,
        icon: icon,
        currentStep: currentStep,
        totalSteps: totalSteps,
        onSkip: onSkip,
        buttonText: 'Got it',
        onButtonPressed: onComplete,
      ),
      targetShapeBorder:
          targetShapeBorder ??
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      targetPadding: EdgeInsets.all(targetPadding.w),
      overlayColor: Colors.black,
      overlayOpacity: 0.8,
      child: child,
    );
  }

  /// Simple showcase with title and description
  static Widget simple({
    required GlobalKey key,
    required Widget child,
    required String title,
    required String description,
    ShapeBorder? targetShapeBorder,
  }) {
    return Showcase(
      key: key,
      title: title,
      description: description,
      titleTextStyle: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      descTextStyle: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: Colors.white.withValues(alpha: 0.9),
      ),
      tooltipBackgroundColor: AppColors.primary,
      targetShapeBorder:
          targetShapeBorder ??
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      targetPadding: EdgeInsets.all(8.w),
      child: child,
    );
  }
}

/// Home tour data
class HomeTourData {
  static final List<Map<String, dynamic>> steps = [
    {
      'key': ShowcaseKeys.searchRidesKey,
      'title': 'Find Your Perfect Ride',
      'description':
          'Search for available rides to your destination. Filter by date, time, and preferences.',
      'icon': Icons.search_rounded,
    },
    {
      'key': ShowcaseKeys.createRideKey,
      'title': 'Share Your Journey',
      'description':
          'Driving somewhere? Create a ride and let others join you. Earn XP and split costs!',
      'icon': Icons.add_circle_outline_rounded,
    },
    {
      'key': ShowcaseKeys.xpProgressKey,
      'title': 'Track Your Progress',
      'description':
          'Watch your XP grow with every ride. Level up to unlock badges and exclusive perks.',
      'icon': Icons.trending_up_rounded,
    },
    {
      'key': ShowcaseKeys.bottomNavKey,
      'title': 'Navigate the App',
      'description':
          'Use the bottom navigation to explore Home, Search, Create Ride, Messages, and Profile.',
      'icon': Icons.navigation_rounded,
    },
  ];
}
