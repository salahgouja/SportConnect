import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/platform_adaptive.dart';

/// Original GlassPanel widget — now aligned with iOS 26 Liquid Glass.
///
/// For the full Liquid Glass design system, see [liquid_glass.dart].
/// This widget is kept for backward compatibility.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    required this.child,
    super.key,
    this.padding,
    this.radius = 20,
    this.borderColor,
    this.color,
  });
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final Color? borderColor;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final panelRadius = BorderRadius.circular(radius.r);
    final shouldBlur = PlatformAdaptive.useBackdropBlur;
    final panel = Container(
      padding: padding,
      decoration: BoxDecoration(
        color:
            color ?? AppColors.surface.withValues(alpha: shouldBlur ? 0.68 : 1),
        borderRadius: panelRadius,
        border: Border.all(
          color: borderColor ?? Colors.white.withValues(alpha: 0.2),
          width: 0.8,
        ),
        gradient: shouldBlur
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.25),
                  Colors.white.withValues(alpha: 0),
                  Colors.white.withValues(alpha: 0),
                  Colors.white.withValues(alpha: 0.08),
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              )
            : null,
      ),
      child: child,
    );

    if (!shouldBlur) {
      return ClipRRect(borderRadius: panelRadius, child: panel);
    }

    return ClipRRect(
      borderRadius: panelRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: PlatformAdaptive.glassBlurSigma,
          sigmaY: PlatformAdaptive.glassBlurSigma,
        ),
        child: panel,
      ),
    );
  }
}
