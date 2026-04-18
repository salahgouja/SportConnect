import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';

/// Unread badge count (#57)
class UnreadBadge extends StatelessWidget {
  const UnreadBadge({required this.count, required this.child, super.key});
  final int count;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return child;
    return Badge(
      label: Text(
        count > 99 ? '99+' : '$count',
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      backgroundColor: AppColors.error,
      child: child,
    );
  }
}

/// Location pin message bubble (#59)
class LocationPinBubble extends StatelessWidget {
  const LocationPinBubble({
    required this.latitude,
    required this.longitude,
    super.key,
    this.label,
    this.isMe = true,
    this.onTap,
  });
  final double latitude;
  final double longitude;
  final String? label;
  final bool isMe;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220.w,
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: isMe
              ? AppColors.primary.withValues(alpha: 0.08)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map placeholder
            Container(
              height: 100.h,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.map_rounded,
                      size: 40.sp,
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  Center(
                    child: Icon(
                      Icons.location_on_rounded,
                      size: 32.sp,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 6.h),
            Row(
              children: [
                Icon(
                  Icons.pin_drop_rounded,
                  size: 14.sp,
                  color: AppColors.primary,
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    label ?? 'Shared Location',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.open_in_new_rounded,
                  size: 14.sp,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ],
            ),
            Text(
              '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}',
              style: TextStyle(
                fontSize: 11.sp,
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Voice message player UI (#60)
class VoiceMessagePlayer extends StatefulWidget {
  const VoiceMessagePlayer({
    required this.duration,
    required this.onPlay,
    required this.onPause,
    super.key,
    this.isMe = true,
    this.positionStream,
  });
  final Duration duration;
  final bool isMe;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final Stream<Duration>? positionStream;

  @override
  State<VoiceMessagePlayer> createState() => _VoiceMessagePlayerState();
}

class _VoiceMessagePlayerState extends State<VoiceMessagePlayer> {
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  StreamSubscription<Duration>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = widget.positionStream?.listen((pos) {
      if (mounted) setState(() => _position = pos);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  String _format(Duration d) {
    final min = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final sec = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = widget.duration.inMilliseconds > 0
        ? _position.inMilliseconds / widget.duration.inMilliseconds
        : 0.0;

    return Container(
      width: 220.w,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: widget.isMe
            ? AppColors.primary.withValues(alpha: 0.08)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              setState(() => _isPlaying = !_isPlaying);
              if (_isPlaying) {
                widget.onPlay();
              } else {
                widget.onPause();
              }
            },
            child: Container(
              width: 36.w,
              height: 36.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
              child: Icon(
                _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                size: 20.sp,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(2.r),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                    minHeight: 3.h,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _isPlaying ? _format(_position) : _format(widget.duration),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
