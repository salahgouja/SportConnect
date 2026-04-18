import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';

/// Apple iOS 26 Liquid Glass design system for SportConnect.
///
/// Liquid Glass is Apple's new design language featuring translucent,
/// dynamic materials for controls and navigation elements.
/// These widgets implement the glass-morphism aesthetic cross-platform
/// using BackdropFilter and blur effects.
///
/// Usage guidelines (per Apple HIG):
/// - Use for navigation layer (tab bars, app bars, toolbars)
/// - Use sparingly for custom controls
/// - Do NOT use in the content layer (use standard materials instead)
/// - Two variants: regular (more opaque) and clear (highly translucent)

/// Liquid Glass material variant.
enum LiquidGlassVariant {
  /// Regular variant — blurs and adjusts luminosity for legibility.
  /// Best for elements with text, alerts, navigation bars.
  regular,

  /// Clear variant — highly translucent, prioritizes background visibility.
  /// Best for elements floating above rich visual content (photos, maps).
  clear,
}

/// A Liquid Glass container that creates a frosted glass effect.
///
/// This is the foundational widget for the Liquid Glass design system.
/// It wraps content in a translucent, blurred container with subtle
/// border highlights that mimic glass refraction.
class LiquidGlassContainer extends StatelessWidget {
  const LiquidGlassContainer({
    required this.child,
    super.key,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.variant = LiquidGlassVariant.regular,
    this.tintColor,
    this.blurSigma = 24,
    this.onTap,
    this.showHighlight = true,
  });

  /// The child widget to display inside the glass container.
  final Widget child;

  /// Padding inside the glass container.
  final EdgeInsetsGeometry? padding;

  /// Margin outside the glass container.
  final EdgeInsetsGeometry? margin;

  /// Border radius of the glass container.
  final double borderRadius;

  /// The glass variant to use.
  final LiquidGlassVariant variant;

  /// Optional tint color to apply to the glass.
  final Color? tintColor;

  /// Blur intensity (sigma). Higher = more frosted.
  final double blurSigma;

  /// Optional callback when tapped.
  final VoidCallback? onTap;

  /// Whether to show the top highlight border (simulates light refraction).
  final bool showHighlight;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine glass opacity based on variant
    final double backgroundOpacity;
    final double borderOpacity;
    final double highlightOpacity;

    switch (variant) {
      case LiquidGlassVariant.regular:
        backgroundOpacity = isDark ? 0.35 : 0.65;
        borderOpacity = isDark ? 0.15 : 0.18;
        highlightOpacity = isDark ? 0.08 : 0.35;
      case LiquidGlassVariant.clear:
        backgroundOpacity = isDark ? 0.15 : 0.30;
        borderOpacity = isDark ? 0.10 : 0.12;
        highlightOpacity = isDark ? 0.05 : 0.20;
    }

    final glassColor = tintColor ?? (isDark ? Colors.black : Colors.white);

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: glassColor.withValues(alpha: backgroundOpacity),
                borderRadius: BorderRadius.circular(borderRadius.r),
                border: Border.all(
                  color: (isDark ? Colors.white : AppColors.textPrimary)
                      .withValues(alpha: borderOpacity),
                  width: 0.8,
                ),
                gradient: showHighlight
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: highlightOpacity),
                          Colors.white.withValues(alpha: 0),
                          Colors.white.withValues(alpha: 0),
                          Colors.white.withValues(
                            alpha: highlightOpacity * 0.3,
                          ),
                        ],
                        stops: const [0.0, 0.3, 0.7, 1.0],
                      )
                    : null,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// A Liquid Glass AppBar that replaces PremiumAppBar with frosted glass.
///
/// Floats above content with translucent background, allowing content
/// to scroll and peek through — per Apple's Liquid Glass guidelines.
class LiquidGlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LiquidGlassAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.onBackPressed,
    this.centerTitle = true,
    this.bottom,
    this.variant = LiquidGlassVariant.regular,
  });

  /// The title text to display.
  final String? title;

  /// Custom title widget (takes precedence over [title]).
  final Widget? titleWidget;

  /// Action widgets to display on the trailing side.
  final List<Widget>? actions;

  /// Custom leading widget.
  final Widget? leading;

  /// Whether to show the back button when navigation can pop.
  final bool showBackButton;

  /// Called when the back button is tapped.
  final VoidCallback? onBackPressed;

  /// Whether to center the title.
  final bool centerTitle;

  /// Bottom widget (e.g. TabBar).
  final PreferredSizeWidget? bottom;

  /// Glass variant to use.
  final LiquidGlassVariant variant;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.72),
            border: Border(
              bottom: BorderSide(
                color: AppColors.border.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: centerTitle,
            leading:
                leading ??
                (showBackButton && canPop
                    ? _buildGlassBackButton(context)
                    : null),
            title:
                titleWidget ??
                (title != null
                    ? Text(
                        title!,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      )
                    : null),
            actions: actions != null
                ? [
                    ...actions!.map(
                      (action) => Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: action,
                      ),
                    ),
                  ]
                : null,
            bottom: bottom,
          ),
        ),
      ),
    );
  }

  Widget _buildGlassBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onBackPressed != null) {
          onBackPressed!();
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Container(
        margin: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: AppColors.textPrimary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.15),
            width: 0.5,
          ),
        ),
        child: Icon(
          Icons.adaptive.arrow_back_rounded,
          color: AppColors.textPrimary,
          size: 22.sp,
        ),
      ),
    );
  }
}

/// A Liquid Glass card for content areas.
///
/// Unlike [LiquidGlassContainer] which is for navigation/controls,
/// this provides a subtler glass effect appropriate for content sections.
class LiquidGlassCard extends StatelessWidget {
  const LiquidGlassCard({
    required this.child,
    super.key,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.onTap,
    this.tintColor,
  });

  /// The child widget.
  final Widget child;

  /// Padding inside the card.
  final EdgeInsetsGeometry? padding;

  /// Margin outside the card.
  final EdgeInsetsGeometry? margin;

  /// Border radius.
  final double borderRadius;

  /// Called when tapped.
  final VoidCallback? onTap;

  /// Tint color for the glass.
  final Color? tintColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: padding ?? EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: (tintColor ?? AppColors.surface).withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(borderRadius.r),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// A Liquid Glass bottom navigation bar.
///
/// Implements iOS 26 Liquid Glass aesthetic for the main tab bar.
/// The bar floats above content with translucent blur, allowing
/// content to peek through from beneath.
class LiquidGlassBottomBar extends StatelessWidget {
  const LiquidGlassBottomBar({
    required this.items,
    required this.activeIndex,
    required this.onTap,
    super.key,
  });

  /// Navigation items to display.
  final List<LiquidGlassNavItem> items;

  /// Currently active tab index.
  final int activeIndex;

  /// Called when a tab is tapped.
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.68),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.25),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 72.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List.generate(
                  items.length,
                  (index) => _LiquidGlassNavTab(
                    item: items[index],
                    isActive: index == activeIndex,
                    onTap: () => onTap(index),
                    index: index,
                    totalTabs: items.length,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A single tab item for [LiquidGlassBottomBar].
class _LiquidGlassNavTab extends StatelessWidget {
  const _LiquidGlassNavTab({
    required this.item,
    required this.isActive,
    required this.onTap,
    required this.index,
    required this.totalTabs,
  });
  final LiquidGlassNavItem item;
  final bool isActive;
  final VoidCallback onTap;
  final int index;
  final int totalTabs;

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
                // Liquid Glass active indicator — pill with glass effect
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.symmetric(
                    horizontal: isActive ? 18.w : 8.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary.withValues(alpha: 0.14)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20.r),
                    border: isActive
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
                    child: Icon(
                      isActive ? item.activeIcon : item.icon,
                      size: 24.sp,
                      color: isActive
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                SizedBox(height: 3.h),
                // Label
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 11.sp,
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

/// Data class for [LiquidGlassBottomBar] items.
class LiquidGlassNavItem {
  const LiquidGlassNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  /// Icon when inactive.
  final IconData icon;

  /// Icon when active.
  final IconData activeIcon;

  /// Tab label text.
  final String label;
}

/// A Liquid Glass floating action button.
///
/// A pill-shaped or circular FAB with frosted glass effect.
class LiquidGlassFAB extends StatelessWidget {
  const LiquidGlassFAB({
    required this.onPressed,
    required this.icon,
    super.key,
    this.label,
    this.semanticLabel,
  });

  /// Called when tapped.
  final VoidCallback onPressed;

  /// Icon to display.
  final IconData icon;

  /// Optional label text (creates a pill-shaped extended FAB).
  final String? label;

  /// Semantic label for accessibility.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final isExtended = label != null;

    return Semantics(
      button: true,
      label: semanticLabel ?? label ?? 'Action button',
      child: GestureDetector(
        onTap: onPressed,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isExtended ? 28.r : 999),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isExtended ? 20.w : 16.w,
                vertical: 16.h,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(isExtended ? 28.r : 999),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.white, size: 22.sp),
                  if (isExtended) ...[
                    SizedBox(width: 8.w),
                    Text(
                      label!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A Liquid Glass bottom sheet handle / drag indicator.
///
/// Provides the frosted-glass top section for modal sheets,
/// matching iOS 26 rounded sheet corners and glass aesthetic.
class LiquidGlassSheetHandle extends StatelessWidget {
  const LiquidGlassSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 12.h),
        width: 36.w,
        height: 5.h,
        decoration: BoxDecoration(
          color: AppColors.textTertiary.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(3.r),
        ),
      ),
    );
  }
}

/// A Liquid Glass chip / tag widget.
///
/// Small translucent pill-shaped label, useful for status badges,
/// category tags, or filter chips with glass effect.
class LiquidGlassChip extends StatelessWidget {
  const LiquidGlassChip({
    required this.label,
    super.key,
    this.icon,
    this.color,
    this.onTap,
    this.isSelected = false,
  });

  /// Label text.
  final String label;

  /// Optional leading icon.
  final IconData? icon;

  /// Tint color for the chip.
  final Color? color;

  /// Called when tapped.
  final VoidCallback? onTap;

  /// Whether the chip is selected.
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? chipColor.withValues(alpha: 0.18)
                  : AppColors.surface.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isSelected
                    ? chipColor.withValues(alpha: 0.3)
                    : AppColors.border.withValues(alpha: 0.2),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 16.sp,
                    color: isSelected ? chipColor : AppColors.textSecondary,
                  ),
                  SizedBox(width: 6.w),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? chipColor : AppColors.textPrimary,
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

/// A Liquid Glass section header.
///
/// Per Apple's Liquid Glass guidance, section headers should use
/// title-style capitalization and provide visual separation.
class LiquidGlassSectionHeader extends StatelessWidget {
  const LiquidGlassSectionHeader({
    required this.title,
    super.key,
    this.trailing,
    this.padding,
  });

  /// Section title text.
  final String title;

  /// Optional trailing widget (e.g., "See All" button).
  final Widget? trailing;

  /// Padding around the header.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
