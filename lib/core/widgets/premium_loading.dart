import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sport_connect/core/theme/app_colors.dart';

/// Premium loading indicator with multiple styles
class PremiumLoader extends StatelessWidget {
  final double size;
  final Color? color;
  final LoaderStyle style;

  const PremiumLoader({
    super.key,
    this.size = 40,
    this.color,
    this.style = LoaderStyle.spinner,
  });

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case LoaderStyle.spinner:
        return _buildSpinner();
      case LoaderStyle.dots:
        return _buildDots();
      case LoaderStyle.pulse:
        return _buildPulse();
      case LoaderStyle.ring:
        return _buildRing();
    }
  }

  Widget _buildSpinner() {
    return SizedBox(
      width: size.w,
      height: size.w,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation(color ?? AppColors.primary),
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Container(
              width: (size / 4).w,
              height: (size / 4).w,
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              decoration: BoxDecoration(
                color: color ?? AppColors.primary,
                shape: BoxShape.circle,
              ),
            )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .fadeIn(
              delay: Duration(milliseconds: index * 150),
              duration: 400.ms,
            )
            .scale(
              delay: Duration(milliseconds: index * 150),
              duration: 400.ms,
              begin: const Offset(0.6, 0.6),
              end: const Offset(1, 1),
            );
      }),
    );
  }

  Widget _buildPulse() {
    return Container(
          width: size.w,
          height: size.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (color ?? AppColors.primary).withValues(alpha: 0.15),
          ),
          child: Center(
            child: Container(
              width: (size * 0.5).w,
              height: (size * 0.5).w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color ?? AppColors.primary,
              ),
            ),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          duration: 800.ms,
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.2, 1.2),
        );
  }

  Widget _buildRing() {
    return SizedBox(
      width: size.w,
      height: size.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size.w,
            height: size.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: (color ?? AppColors.primary).withValues(alpha: 0.2),
                width: 3,
              ),
            ),
          ),
          SizedBox(
                width: size.w,
                height: size.w,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  strokeCap: StrokeCap.round,
                  valueColor: AlwaysStoppedAnimation(
                    color ?? AppColors.primary,
                  ),
                ),
              )
              .animate(onPlay: (controller) => controller.repeat())
              .rotate(duration: 1200.ms),
        ],
      ),
    );
  }
}

enum LoaderStyle { spinner, dots, pulse, ring }

/// Full screen loading overlay
class PremiumLoadingOverlay extends StatelessWidget {
  final String? message;
  final bool isVisible;
  final Widget child;

  const PremiumLoadingOverlay({
    super.key,
    this.message,
    this.isVisible = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isVisible)
          Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: Center(
              child:
                  Container(
                        padding: EdgeInsets.all(32.w),
                        decoration: BoxDecoration(
                          color: AppColors.cardBg,
                          borderRadius: BorderRadius.circular(24.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 30,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const PremiumLoader(
                              size: 48,
                              style: LoaderStyle.ring,
                            ),
                            if (message != null) ...[
                              SizedBox(height: 20.h),
                              Text(
                                message!,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 200.ms)
                      .scale(begin: const Offset(0.9, 0.9), duration: 200.ms),
            ),
          ).animate().fadeIn(duration: 200.ms),
      ],
    );
  }
}

/// Skeleton shimmer effect for loading states
class SkeletonShimmer extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;

  const SkeletonShimmer({
    super.key,
    required this.child,
    this.isLoading = true,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;

    return child
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: 1200.ms,
          color: highlightColor ?? AppColors.surfaceVariant,
        );
  }
}

/// Skeleton box placeholder
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.border.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(borderRadius.r),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: 1200.ms,
          color: AppColors.surfaceVariant.withValues(alpha: 0.6),
        );
  }
}

/// Skeleton circle placeholder
class SkeletonCircle extends StatelessWidget {
  final double size;

  const SkeletonCircle({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return Container(
          width: size.w,
          height: size.w,
          decoration: BoxDecoration(
            color: AppColors.border.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: 1200.ms,
          color: AppColors.surfaceVariant.withValues(alpha: 0.6),
        );
  }
}

/// Skeleton text line placeholder
class SkeletonLine extends StatelessWidget {
  final double width;
  final double height;

  const SkeletonLine({
    super.key,
    this.width = double.infinity,
    this.height = 14,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      width: width.isFinite ? width.w : width,
      height: height.h,
      borderRadius: 6,
    );
  }
}

/// Pre-built skeleton for ride cards
class RideCardSkeleton extends StatelessWidget {
  final int delay;

  const RideCardSkeleton({super.key, this.delay = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          // Driver row skeleton
          Row(
            children: [
              const SkeletonCircle(size: 56),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLine(width: 120.w, height: 16),
                    SizedBox(height: 8.h),
                    SkeletonLine(width: 80.w, height: 12),
                  ],
                ),
              ),
              SkeletonBox(width: 60.w, height: 50.h, borderRadius: 14),
            ],
          ),
          SizedBox(height: 18.h),
          // Route section skeleton
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                Column(
                  children: [
                    const SkeletonCircle(size: 14),
                    SizedBox(height: 4.h),
                    SkeletonBox(width: 2.w, height: 30.h, borderRadius: 1),
                    SizedBox(height: 4.h),
                    const SkeletonCircle(size: 14),
                  ],
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonLine(width: 100.w, height: 12),
                      SizedBox(height: 4.h),
                      SkeletonLine(width: 140.w, height: 14),
                      SizedBox(height: 16.h),
                      SkeletonLine(width: 100.w, height: 12),
                      SizedBox(height: 4.h),
                      SkeletonLine(width: 130.w, height: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          // Bottom bar skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonBox(width: 100.w, height: 36.h, borderRadius: 10),
              SkeletonBox(width: 110.w, height: 44.h, borderRadius: 12),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(
      delay: Duration(milliseconds: delay),
      duration: 300.ms,
    );
  }
}

/// Pre-built skeleton for user profile cards
class ProfileCardSkeleton extends StatelessWidget {
  const ProfileCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          const SkeletonCircle(size: 80),
          SizedBox(height: 16.h),
          SkeletonLine(width: 140.w, height: 18),
          SizedBox(height: 8.h),
          SkeletonLine(width: 100.w, height: 14),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  SkeletonBox(width: 50.w, height: 24.h),
                  SizedBox(height: 4.h),
                  SkeletonLine(width: 60.w, height: 12),
                ],
              ),
              Column(
                children: [
                  SkeletonBox(width: 50.w, height: 24.h),
                  SizedBox(height: 4.h),
                  SkeletonLine(width: 60.w, height: 12),
                ],
              ),
              Column(
                children: [
                  SkeletonBox(width: 50.w, height: 24.h),
                  SizedBox(height: 4.h),
                  SkeletonLine(width: 60.w, height: 12),
                ],
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

/// Pre-built skeleton for message items
class MessageItemSkeleton extends StatelessWidget {
  final bool isOwnMessage;
  final int delay;

  const MessageItemSkeleton({
    super.key,
    this.isOwnMessage = false,
    this.delay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isOwnMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isOwnMessage ? 80.w : 16.w,
          right: isOwnMessage ? 16.w : 80.w,
          bottom: 8.h,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isOwnMessage) ...[
              const SkeletonCircle(size: 32),
              SizedBox(width: 8.w),
            ],
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: isOwnMessage
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.surfaceVariant.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLine(width: 150.w, height: 14),
                  SizedBox(height: 6.h),
                  SkeletonLine(width: 100.w, height: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(
      delay: Duration(milliseconds: delay),
      duration: 200.ms,
    );
  }
}

/// Skeleton list view builder
class SkeletonListView extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final EdgeInsetsGeometry? padding;

  const SkeletonListView({
    super.key,
    this.itemCount = 5,
    required this.itemBuilder,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding,
      itemCount: itemCount,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: itemBuilder,
    );
  }
}
