import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';

/// Original GlassPanel widget — now aligned with iOS 26 Liquid Glass.
///
/// For the full Liquid Glass design system, see [liquid_glass.dart].
/// This widget is kept for backward compatibility.
class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final Color? borderColor;
  final Color? color;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding,
    this.radius = 20,
    this.borderColor,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? AppColors.surface.withValues(alpha: 0.68),
            borderRadius: BorderRadius.circular(radius.r),
            border: Border.all(
              color: borderColor ?? Colors.white.withValues(alpha: 0.2),
              width: 0.8,
            ),
            // Liquid Glass highlight gradient
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.25),
                Colors.white.withValues(alpha: 0.0),
                Colors.white.withValues(alpha: 0.0),
                Colors.white.withValues(alpha: 0.08),
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
