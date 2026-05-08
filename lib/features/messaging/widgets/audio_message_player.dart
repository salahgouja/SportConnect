import 'dart:async';



import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/features/messaging/models/message_model.dart';
import 'package:v_chat_voice_player/v_chat_voice_player.dart';
import 'package:v_platform/v_platform.dart';

class AudioMessagePlayer extends StatefulWidget {
  const AudioMessagePlayer({
    required this.audioUrl,
    required this.isMe,
    required this.message,
    super.key,
  });

  final String audioUrl;
  final bool isMe;
  final MessageModel message;

  @override
  State<AudioMessagePlayer> createState() => _AudioMessagePlayerState();
}

class _AudioMessagePlayerState extends State<AudioMessagePlayer> {
  late VVoiceMessageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VVoiceMessageController(
      id: widget.message.id,
      audioSrc: VPlatformFile.fromUrl(networkUrl: widget.audioUrl),
      maxDuration: const Duration(minutes: 10),
      onComplete: (_) => unawaited(HapticFeedback.lightImpact()),
      onPlaying: (_) => unawaited(HapticFeedback.selectionClick()),
      onPause: (_) {},
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final senderName = widget.message.senderName;
    final initials = senderName
        .trim()
        .split(' ')
        .take(2)
        .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
        .join();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
      child: VVoiceMessageView(
        controller: _controller,

        colorConfig: VoiceColorConfig(
          activeSliderColor: widget.isMe ? Colors.white : AppColors.primary,
          notActiveSliderColor: widget.isMe
              ? Colors.white.withValues(alpha: 0.35)
              : AppColors.divider,
        ),

        containerConfig: VoiceContainerConfig(
          backgroundColor: Colors.transparent,
          borderRadius: 0,
          containerPadding: EdgeInsets.symmetric(
            horizontal: 6.w,
            vertical: 6.h,
          ),
        ),

        buttonConfig: VoiceButtonConfig(
          buttonColor: widget.isMe
              ? Colors.white.withValues(alpha: 0.18)
              : AppColors.primary.withValues(alpha: 0.08),
          buttonIconColor: widget.isMe ? Colors.white : AppColors.primary,
          buttonSize: 40.w,
          useSimplePlayIcon: true,
          simpleIconSize: 20.sp,
        ),

        visualizerConfig: VoiceVisualizerConfig(
          height: 32.h,
          barCount: 45,
        ),

        speedConfig: VoiceSpeedConfig(
          speedButtonColor: widget.isMe
              ? Colors.white.withValues(alpha: 0.18)
              : AppColors.primary.withValues(alpha: 0.08),
          speedButtonTextColor: widget.isMe ? Colors.white : AppColors.primary,
          speedButtonBorderRadius: 8,
          speedButtonPadding: EdgeInsets.symmetric(
            horizontal: 7.w,
            vertical: 3.h,
          ),
        ),

        avatarConfig: VoiceAvatarConfig(
          avatarSize: 36.w,
          micIconSize: 13.sp,
          userAvatar: widget.isMe
              ? const SizedBox.shrink()
              : (widget.message.senderPhotoUrl != null &&
                        widget.message.senderPhotoUrl!.isNotEmpty
                    ? CircleAvatar(
                        radius: 18.r,
                        backgroundImage: NetworkImage(
                          widget.message.senderPhotoUrl!,
                        ),
                      )
                    : CircleAvatar(
                        radius: 18.r,
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.12,
                        ),
                        child: Text(
                          initials,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      )),
        ),

        textConfig: VoiceTextConfig(
          counterTextStyle: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            fontFeatures: const [FontFeature.tabularFigures()],
            color: widget.isMe
                ? Colors.white.withValues(alpha: 0.7)
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
