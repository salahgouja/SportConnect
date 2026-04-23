import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Main wrapper widget with bottom navigation
///
/// This widget wraps the main app shell and provides:
/// - Custom bottom navigation bar for both rider and driver modes
/// - Active tab management with proper branch indexing
/// - Haptic feedback on tab changes
/// - Role-based tab switching
class MainWrapper extends ConsumerStatefulWidget {
  const MainWrapper({required this.navigationShell, super.key});
  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends ConsumerState<MainWrapper> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final shellUser = ref.watch(
      currentUserProvider.select((value) {
        final user = value.value;
        if (user == null) return null;
        final isPremium = switch (user) {
          final DriverModel driver => driver.isPremium,
          final RiderModel rider => rider.isPremium,
          _ => false,
        };
        return (
          uid: user.uid,
          isDriver: user is DriverModel,
          isPremium: isPremium,
        );
      }),
    );

    if (shellUser == null) {
      return const AdaptiveScaffold(body: SizedBox.shrink());
    }

    final isDriver = shellUser.isDriver;
    final currentIndex = widget.navigationShell.currentIndex;

    // Detect branch-set mismatch and correct after frame
    final driverOnRiderBranch = isDriver && currentIndex < 5;
    final riderOnDriverBranch = !isDriver && currentIndex >= 5;
    if (driverOnRiderBranch || riderOnDriverBranch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.navigationShell.goBranch(
          isDriver ? 5 : 0,
          initialLocation: true,
        );
      });
    }

    final activeIndex = _calculateActiveIndex(isDriver);
    final destinations = isDriver
        ? _driverDestinations(l10n)
        : _riderDestinations(l10n);

    return AdaptiveScaffold(
      body: SafeArea(bottom: false, child: widget.navigationShell),
      bottomNavigationBar: AdaptiveBottomNavigationBar(
        selectedIndex: activeIndex,
        onTap: (index) => _navigateToBranch(index, isDriver),
        selectedItemColor: AppColors.primaryLight,
        items: destinations,
      ),
    );
  }

  static List<AdaptiveNavigationDestination> _riderDestinations(
    AppLocalizations l10n,
  ) => [
    AdaptiveNavigationDestination(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: l10n.navHome,
    ),
    AdaptiveNavigationDestination(
      icon: Icons.directions_car_outlined,
      selectedIcon: Icons.directions_car_rounded,
      label: l10n.navRides,
    ),
    AdaptiveNavigationDestination(
      icon: Icons.add_circle_outline_rounded,
      selectedIcon: Icons.flag,
      label: l10n.events,
    ),
    AdaptiveNavigationDestination(
      icon: Icons.chat_bubble_outline_rounded,
      selectedIcon: Icons.chat_bubble_rounded,
      label: l10n.navChat,
    ),
    AdaptiveNavigationDestination(
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
      label: l10n.navProfile,
    ),
  ];

  static List<AdaptiveNavigationDestination> _driverDestinations(
    AppLocalizations l10n,
  ) => [
    AdaptiveNavigationDestination(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: l10n.navHome,
    ),
    AdaptiveNavigationDestination(
      icon: Icons.directions_car_outlined,
      selectedIcon: Icons.directions_car_rounded,
      label: l10n.navRides,
    ),
    AdaptiveNavigationDestination(
      icon: Icons.add_circle_outline_rounded,
      selectedIcon: Icons.add_circle_rounded,
      label: l10n.earnings,
    ),
    AdaptiveNavigationDestination(
      icon: Icons.chat_bubble_outline_rounded,
      selectedIcon: Icons.chat_bubble_rounded,
      label: l10n.navChat,
    ),
    AdaptiveNavigationDestination(
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
      label: l10n.navProfile,
    ),
  ];

  /// Calculate active local index (0-4) from the global navigation shell index.
  ///
  /// Rider branches are 0-4, driver branches are 5-9. A mismatch returns 0
  /// so the highlight falls back to the home tab — this is a safe default while
  /// the post-frame correction in [_buildBottomNav] takes effect.
  int _calculateActiveIndex(bool isDriver) {
    if (isDriver) {
      return (widget.navigationShell.currentIndex >= 5)
          ? widget.navigationShell.currentIndex - 5
          : 0;
    }
    return (widget.navigationShell.currentIndex <= 4)
        ? widget.navigationShell.currentIndex
        : 0;
  }

  void _navigateToBranch(int localIndex, bool isDriver) {
    HapticFeedback.lightImpact();
    final targetBranch = isDriver ? localIndex + 5 : localIndex;
    widget.navigationShell.goBranch(
      targetBranch,
      initialLocation: targetBranch == widget.navigationShell.currentIndex,
    );
  }
}
