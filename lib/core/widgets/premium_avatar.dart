import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/app_spacing.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Premium Avatar with border, badge, and online indicator
class PremiumAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double size;
  final bool showOnlineIndicator;
  final bool isOnline;
  final bool hasBorder;
  final Color? borderColor;
  final Widget? badge;
  final VoidCallback? onTap;
  final Gradient? borderGradient;

  const PremiumAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = 48,
    this.showOnlineIndicator = false,
    this.isOnline = false,
    this.hasBorder = false,
    this.borderColor,
    this.badge,
    this.onTap,
    this.borderGradient,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: size.w,
            height: size.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: hasBorder && borderGradient == null
                  ? Border.all(
                      color: borderColor ?? AppColors.primary,
                      width: 3,
                    )
                  : null,
              gradient: borderGradient,
            ),
            padding: borderGradient != null ? EdgeInsets.all(3.w) : null,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: borderGradient != null ? AppColors.cardBg : null,
              ),
              padding: borderGradient != null ? EdgeInsets.all(2.w) : null,
              child: ClipOval(
                child: imageUrl != null && imageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => _buildPlaceholder(),
                        errorWidget: (context, url, error) =>
                            _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
            ),
          ),
          // Online indicator
          if (showOnlineIndicator)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: (size * 0.28).w,
                height: (size * 0.28).w,
                decoration: BoxDecoration(
                  color: isOnline ? AppColors.success : AppColors.textTertiary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.cardBg, width: 2),
                ),
              ),
            ),
          // Badge
          if (badge != null) Positioned(right: 0, top: 0, child: badge!),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.2),
      child: Center(
        child: name != null && name!.isNotEmpty
            ? Text(
                name![0].toUpperCase(),
                style: TextStyle(
                  fontSize: (size * 0.4).sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              )
            : Icon(
                Icons.person_rounded,
                size: (size * 0.5).sp,
                color: AppColors.primary,
              ),
      ),
    );
  }
}

/// Avatar with level badge
class LevelAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final int level;
  final double size;

  const LevelAvatar({
    super.key,
    this.imageUrl,
    this.name,
    required this.level,
    this.size = 56,
  });

  Gradient get _levelGradient {
    if (level >= 50) return AppColors.diamondGradient;
    if (level >= 40) return AppColors.platinumGradient;
    if (level >= 30) return AppColors.goldGradientLevel;
    if (level >= 20) return AppColors.silverGradient;
    return AppColors.bronzeGradient;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        PremiumAvatar(
          imageUrl: imageUrl,
          name: name,
          size: size,
          hasBorder: true,
          borderGradient: _levelGradient,
        ),
        Positioned(
          bottom: -8.h,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                gradient: _levelGradient,
                borderRadius: BorderRadius.circular(10.r),
                boxShadow: AppSpacing.shadowSm,
              ),
              child: Text(
                AppLocalizations.of(context).lvValue(level),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w800,
                  color: level >= 40 ? Colors.black87 : Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Avatar Group for showing multiple users
class AvatarGroup extends StatelessWidget {
  final List<String?>? imageUrls;
  final List<String?>? names;
  final double size;
  final int maxDisplay;
  final int? extraCount;
  final VoidCallback? onTap;

  const AvatarGroup({
    super.key,
    this.imageUrls,
    this.names,
    this.size = 36,
    this.maxDisplay = 3,
    this.extraCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Use imageUrls if provided, otherwise create a list from names length
    final urls = imageUrls ?? List.filled(names?.length ?? 0, null);
    final displayCount = urls.length > maxDisplay ? maxDisplay : urls.length;
    final extra =
        extraCount ?? (urls.length > maxDisplay ? urls.length - maxDisplay : 0);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width:
            (size +
                    (displayCount - 1) * (size * 0.6) +
                    (extra > 0 ? size * 0.6 : 0))
                .w,
        height: size.w,
        child: Stack(
          children: [
            for (int i = 0; i < displayCount; i++)
              Positioned(
                left: (i * size * 0.6).w,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.cardBg, width: 2),
                  ),
                  child: PremiumAvatar(
                    imageUrl: urls[i],
                    name: names != null && i < names!.length ? names![i] : null,
                    size: size - 4,
                  ),
                ),
              ),
            if (extra > 0)
              Positioned(
                left: (displayCount * size * 0.6).w,
                child: Container(
                  width: size.w,
                  height: size.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                    border: Border.all(color: AppColors.cardBg, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context).value4(extra),
                      style: TextStyle(
                        fontSize: (size * 0.35).sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Profile Avatar with edit button
class EditableAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double size;
  final VoidCallback? onEdit;
  final bool isLoading;

  const EditableAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = 100,
    this.onEdit,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PremiumAvatar(
          imageUrl: imageUrl,
          name: name,
          size: size,
          hasBorder: true,
          borderGradient: AppColors.primaryGradient,
        ),
        if (isLoading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black38,
              ),
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
          ),
        Positioned(
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: onEdit,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: AppSpacing.primaryShadow(AppColors.primary),
              ),
              child: Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: (size * 0.2).sp,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
