import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/platform_adaptive.dart';
import 'package:sport_connect/core/widgets/chat_widgets.dart';
import 'package:sport_connect/features/auth/models/models.dart';

/// Main wrapper widget with bottom navigation
///
/// This widget wraps the main app shell and provides:
/// - Custom bottom navigation bar for both rider and driver modes
/// - Active tab management with proper branch indexing
/// - Haptic feedback on tab changes
/// - Role-based tab switching
class MainWrapper extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainWrapper({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: navigationShell,
      bottomNavigationBar: userAsync.when(
        loading: () => const SizedBox(height: kBottomNavigationBarHeight),
        error: (_, _) => const SizedBox(height: kBottomNavigationBarHeight),
        data: (user) => _buildBottomNav(context, user),
      ),
    );
  }

  Widget? _buildBottomNav(BuildContext context, UserModel? user) {
    if (user == null) return const SizedBox.shrink();

    final isDriver = user is DriverModel;
    final currentIndex = navigationShell.currentIndex;

    // Detect branch-set mismatch (driver on rider branches 0-4, or vice versa)
    final driverOnRiderBranch = isDriver && currentIndex < 5;
    final riderOnDriverBranch = !isDriver && currentIndex >= 5;
    if (driverOnRiderBranch || riderOnDriverBranch) {
      // Correct mismatch after the current frame to avoid calling goBranch
      // during a build phase.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigationShell.goBranch(isDriver ? 5 : 0, initialLocation: true);
      });
    }

    final activeIndex = _calculateActiveIndex(isDriver);

    return _CustomBottomNavBar(
      isDriver: isDriver,
      activeIndex: activeIndex,
      onTap: (index) => _navigateToBranch(index, isDriver),
    );
  }

  /// Calculate active local index (0-4) from the global navigation shell index.
  ///
  /// Rider branches are 0-4, driver branches are 5-9. A mismatch returns 0
  /// so the highlight falls back to the home tab — this is a safe default while
  /// the post-frame correction in [_buildBottomNav] takes effect.
  int _calculateActiveIndex(bool isDriver) {
    if (isDriver) {
      return (navigationShell.currentIndex >= 5)
          ? navigationShell.currentIndex - 5
          : 0;
    }
    return (navigationShell.currentIndex <= 4)
        ? navigationShell.currentIndex
        : 0;
  }

  void _navigateToBranch(int localIndex, bool isDriver) {
    HapticFeedback.lightImpact();
    final targetBranch = isDriver ? localIndex + 5 : localIndex;
    navigationShell.goBranch(
      targetBranch,
      initialLocation: targetBranch == navigationShell.currentIndex,
    );
  }
}

/// Custom bottom navigation bar with enterprise design
///
/// Implements:
/// - Material Design 3 guidelines
/// - iOS Human Interface Guidelines
/// - WCAG 2.1 AA accessibility compliance
/// - Proper touch targets (>=48dp)
/// - Active state indicator pill
/// - Full semantic labels for screen readers
class _CustomBottomNavBar extends StatelessWidget {
  final bool isDriver;
  final int activeIndex;
  final ValueChanged<int> onTap;
  final int _unreadChatCount;

  const _CustomBottomNavBar({
    required this.isDriver,
    required this.activeIndex,
    required this.onTap,
    int unreadChatCount = 0,
  }) : _unreadChatCount = unreadChatCount;

  @override
  Widget build(BuildContext context) {
    final tabs = isDriver ? _driverTabs : _riderTabs;
    final totalTabs = tabs.length;

    // Platform-adaptive bottom navigation
    // iOS: Liquid Glass frosted glass aesthetic
    // Android: Solid Material 3 surface
    final navContent = SafeArea(
      top: false,
      child: SizedBox(
        height: 72.h,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: List.generate(
            tabs.length,
            (index) => _NavBarTab(
              item: tabs[index],
              isActive: index == activeIndex,
              onTap: () => onTap(index),
              index: index,
              totalTabs: totalTabs,
              // Badge on chat tab (index 3 for both rider and driver)
              badgeCount: index == 3 ? _unreadChatCount : 0,
            ),
          ),
        ),
      ),
    );

    if (PlatformAdaptive.useBackdropBlur) {
      // iOS: Liquid Glass — frosted blur + translucent surface
      return ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: PlatformAdaptive.navBarBlurSigma,
            sigmaY: PlatformAdaptive.navBarBlurSigma,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(
                alpha: PlatformAdaptive.navBarAlpha,
              ),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.25),
                  width: 0.5,
                ),
              ),
            ),
            child: navContent,
          ),
        ),
      );
    }

    // Android: Material 3 — solid surface with standard elevation
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: navContent,
    );
  }

  // ============ RIDER TABS (5 ITEMS) ============
  static const _riderTabs = [
    _NavBarItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    _NavBarItem(
      icon: Icons.directions_car_outlined,
      activeIcon: Icons.directions_car_rounded,
      label: 'My Rides',
    ),
    _NavBarItem(
      icon: Icons.add_circle_outline_rounded,
      activeIcon: Icons.flag,
      label: 'Events',
    ),
    _NavBarItem(
      icon: Icons.chat_bubble_outline_rounded,
      activeIcon: Icons.chat_bubble_rounded,
      label: 'Inbox',
    ),
    _NavBarItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  // ============ DRIVER TABS (5 ITEMS) ============
  static const _driverTabs = [
    _NavBarItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    _NavBarItem(
      icon: Icons.directions_car_outlined,
      activeIcon: Icons.directions_car_rounded,
      label: 'My Rides',
    ),
    _NavBarItem(
      icon: Icons.add_circle_outline_rounded,
      activeIcon: Icons.add_circle_rounded,
      label: 'Offer',
    ),
    _NavBarItem(
      icon: Icons.chat_bubble_outline_rounded,
      activeIcon: Icons.chat_bubble_rounded,
      label: 'Inbox',
    ),
    _NavBarItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];
}

/// Individual navigation tab widget with full accessibility support
class _NavBarTab extends StatelessWidget {
  final _NavBarItem item;
  final bool isActive;
  final VoidCallback onTap;
  final int index;
  final int totalTabs;
  final int badgeCount;

  const _NavBarTab({
    required this.item,
    required this.isActive,
    required this.onTap,
    required this.index,
    required this.totalTabs,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        selected: isActive,
        label: '${item.label} tab, ${index + 1} of $totalTabs',
        hint: isActive
            ? 'Currently selected'
            : 'Double tap to switch to ${item.label}',
        child: InkWell(
          onTap: onTap,
          splashColor: AppColors.primary.withValues(alpha: 0.08),
          highlightColor: Colors.transparent,
          customBorder: const StadiumBorder(),
          child: Tooltip(
            message: item.label,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Platform-adaptive active indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.symmetric(
                    horizontal: isActive ? 18.w : 8.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary.withValues(
                            alpha: PlatformAdaptive.isApple ? 0.14 : 0.12,
                          )
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(
                      PlatformAdaptive.isApple ? 20.r : 16.r,
                    ),
                    border: isActive && PlatformAdaptive.isApple
                        ? Border.all(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            width: 0.5,
                          )
                        : null,
                  ),
                  child: AnimatedScale(
                    scale: isActive ? 1.05 : 1.0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    child: UnreadBadge(
                      count: badgeCount,
                      child: Icon(
                        isActive ? item.activeIcon : item.icon,
                        size: 24.sp,
                        color: isActive
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 3.h),
                // Label
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: PlatformAdaptive.isApple ? 11.sp : 12.sp,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    letterSpacing: 0.1,
                  ),
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Navigation bar item data
class _NavBarItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
