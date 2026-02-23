import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/app_spacing.dart';
import 'package:sport_connect/core/theme/platform_adaptive.dart';

/// Premium button styles
enum PremiumButtonStyle {
  primary,
  secondary,
  outline,
  ghost,
  gradient,
  success,
  danger,
}

enum ButtonSize { small, medium, large }

/// Custom elevated button with loading state and premium design
class PremiumButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final PremiumButtonStyle style;
  final ButtonSize size;
  final IconData? icon;
  final bool iconRight;
  final double? width;
  final Widget? child;

  const PremiumButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.style = PremiumButtonStyle.primary,
    this.size = ButtonSize.large,
    this.icon,
    this.iconRight = false,
    this.width,
    this.child,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _height {
    switch (widget.size) {
      case ButtonSize.small:
        return AppSpacing.buttonHeightSm;
      case ButtonSize.medium:
        return AppSpacing.buttonHeightMd;
      case ButtonSize.large:
        return AppSpacing.buttonHeightLg;
    }
  }

  double get _fontSize {
    switch (widget.size) {
      case ButtonSize.small:
        return 14.sp;
      case ButtonSize.medium:
        return 15.sp;
      case ButtonSize.large:
        return 16.sp;
    }
  }

  double get _iconSize {
    switch (widget.size) {
      case ButtonSize.small:
        return 18.sp;
      case ButtonSize.medium:
        return 20.sp;
      case ButtonSize.large:
        return 22.sp;
    }
  }

  Color get _backgroundColor {
    switch (widget.style) {
      case PremiumButtonStyle.primary:
        return AppColors.primary;
      case PremiumButtonStyle.secondary:
        return AppColors.secondary;
      case PremiumButtonStyle.outline:
      case PremiumButtonStyle.ghost:
        return Colors.transparent;
      case PremiumButtonStyle.gradient:
        return Colors.transparent;
      case PremiumButtonStyle.success:
        return AppColors.success;
      case PremiumButtonStyle.danger:
        return AppColors.error;
    }
  }

  Color get _foregroundColor {
    switch (widget.style) {
      case PremiumButtonStyle.primary:
      case PremiumButtonStyle.secondary:
      case PremiumButtonStyle.gradient:
      case PremiumButtonStyle.success:
      case PremiumButtonStyle.danger:
        return Colors.white;
      case PremiumButtonStyle.outline:
      case PremiumButtonStyle.ghost:
        return AppColors.primary;
    }
  }

  BoxBorder? get _border {
    if (widget.style == PremiumButtonStyle.outline) {
      return Border.all(color: AppColors.primary, width: 1.5);
    }
    return null;
  }

  Gradient? get _gradient {
    if (widget.style == PremiumButtonStyle.gradient) {
      return AppColors.primaryGradient;
    }
    return null;
  }

  List<BoxShadow>? get _shadow {
    if (widget.style == PremiumButtonStyle.primary ||
        widget.style == PremiumButtonStyle.gradient) {
      return AppSpacing.primaryShadow(AppColors.primary);
    }
    if (widget.style == PremiumButtonStyle.success) {
      return AppSpacing.primaryShadow(AppColors.success);
    }
    if (widget.style == PremiumButtonStyle.danger) {
      return AppSpacing.primaryShadow(AppColors.error);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },
      child: GestureDetector(
        onTapDown: isEnabled ? (_) => _controller.forward() : null,
        onTapUp: isEnabled ? (_) => _controller.reverse() : null,
        onTapCancel: isEnabled ? () => _controller.reverse() : null,
        onTap: isEnabled ? widget.onPressed : null,
        child: AnimatedOpacity(
          opacity: isEnabled ? 1.0 : 0.5,
          duration: const Duration(milliseconds: 200),
          child: Container(
            width: widget.width ?? double.infinity,
            height: _height,
            decoration: BoxDecoration(
              color: _gradient == null ? _backgroundColor : null,
              gradient: _gradient,
              // Platform-adaptive: pill-shaped on iOS, standard on Android
              borderRadius: BorderRadius.circular(
                PlatformAdaptive.buttonRadiusMd,
              ),
              border: _border ?? PlatformAdaptive.buttonGlassBorder,
              boxShadow: isEnabled ? _shadow : null,
            ),
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      height: 22.h,
                      width: 22.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _foregroundColor,
                        ),
                      ),
                    )
                  : widget.child ?? _buildContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final textWidget = Text(
      widget.text,
      style: TextStyle(
        color: _foregroundColor,
        fontSize: _fontSize,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );

    if (widget.icon == null) return textWidget;

    final iconWidget = Icon(
      widget.icon,
      color: _foregroundColor,
      size: _iconSize,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: widget.iconRight
          ? [textWidget, SizedBox(width: 8.w), iconWidget]
          : [iconWidget, SizedBox(width: 8.w), textWidget],
    );
  }
}

/// Gradient Icon Button
class GradientIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Gradient gradient;

  const GradientIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 48,
    this.gradient = AppColors.primaryGradient,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size.w,
        height: size.w,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(size / 2),
          // Platform-adaptive: glass border only on iOS
          border: PlatformAdaptive.buttonGlassBorder,
          boxShadow: AppSpacing.primaryShadow(AppColors.primary),
        ),
        child: Icon(icon, color: Colors.white, size: (size * 0.5).sp),
      ),
    );
  }
}

/// Floating Action Button with gradient
class PremiumFAB extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? label;

  const PremiumFAB({super.key, required this.icon, this.onPressed, this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: label != null ? 20.w : 16.w,
          vertical: 16.h,
        ),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          // Platform-adaptive: pill FAB on iOS, rounded on Android
          borderRadius: BorderRadius.circular(
            label != null
                ? PlatformAdaptive.buttonRadiusLg
                : PlatformAdaptive.buttonRadiusMd,
          ),
          border: PlatformAdaptive.buttonGlassBorder,
          boxShadow: AppSpacing.primaryShadow(AppColors.primary),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24.sp),
            if (label != null) ...[
              SizedBox(width: 8.w),
              Text(
                label!,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
