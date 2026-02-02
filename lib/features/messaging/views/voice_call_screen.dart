import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/services/webview_rtc_service.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/premium_avatar.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';
import 'package:sport_connect/features/messaging/models/call_model.dart';
import 'package:sport_connect/features/messaging/repositories/call_repository.dart';

/// Voice Call Screen using WebView-based WebRTC (Open Source)
///
/// Audio-only implementation using native browser WebRTC through a WebView.
/// 100% open source and free for commercial use.
class VoiceCallScreen extends ConsumerStatefulWidget {
  final String callId;
  final String chatId;
  final String receiverId;
  final String receiverName;
  final String? receiverPhotoUrl;
  final bool isIncoming;

  const VoiceCallScreen({
    super.key,
    required this.callId,
    required this.chatId,
    required this.receiverId,
    required this.receiverName,
    this.receiverPhotoUrl,
    this.isIncoming = false,
  });

  @override
  ConsumerState<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends ConsumerState<VoiceCallScreen>
    with TickerProviderStateMixin {
  CallStatus _callStatus = CallStatus.pending;
  int _callDuration = 0;
  Timer? _durationTimer;
  bool _isMuted = false;
  bool _isSpeakerOn = false;

  late AnimationController _pulseController;
  late AnimationController _waveController;

  StreamSubscription? _callSubscription;
  final WebViewRTCService _webRTCService = WebViewRTCService();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _setupWebRTCCallbacks();
    _listenToCallStatus();
  }

  void _setupWebRTCCallbacks() {
    _webRTCService.onPageReady = () {
      _initCall();
    };

    _webRTCService.onCallConnected = () {
      if (mounted) {
        setState(() {
          _callStatus = CallStatus.ongoing;
        });
        _startDurationTimer();

        // Update Firestore
        final callRepository = ref.read(callRepositoryProvider);
        callRepository.updateCallStatus(
          callId: widget.callId,
          status: CallStatus.ongoing,
        );
      }
    };

    _webRTCService.onCallEnded = () {
      if (mounted) {
        _endCall(updateFirestore: false);
      }
    };

    _webRTCService.onCallDeclined = () {
      if (mounted) {
        _endCall(updateFirestore: false);
      }
    };

    _webRTCService.onError = (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.error),
        );
      }
    };
  }

  void _listenToCallStatus() {
    final callRepository = ref.read(callRepositoryProvider);
    _callSubscription = callRepository.streamCall(widget.callId).listen((call) {
      if (call != null && mounted) {
        setState(() {
          _callStatus = call.status;
        });

        if (call.status == CallStatus.ongoing && _durationTimer == null) {
          _startDurationTimer();
        } else if (call.status == CallStatus.ended ||
            call.status == CallStatus.declined ||
            call.status == CallStatus.missed) {
          _endCall(updateFirestore: false);
        }
      }
    });
  }

  Future<void> _initCall() async {
    // Check if user is authenticated via repository (MVVM pattern)
    final authRepo = ref.read(authRepositoryProvider);
    final currentUser = authRepo.currentUser;
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must be signed in to make calls'),
            backgroundColor: AppColors.error,
          ),
        );
        context.pop();
      }
      return;
    }
    final currentUserId = currentUser.uid;

    // Request permissions (audio only)
    final hasPermission = await _webRTCService.requestPermissions(video: false);
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microphone permission is required'),
            backgroundColor: AppColors.error,
          ),
        );
        context.pop();
      }
      return;
    }

    // Initialize WebRTC (audio only)
    await _webRTCService.initCall(
      callId: widget.callId,
      userId: currentUserId,
      isVideo: false, // Audio only
      remoteName: widget.receiverName,
      signalingMode: SignalingMode.firebase,
    );

    if (widget.isIncoming) {
      setState(() {
        _callStatus = CallStatus.connecting;
      });
      await _webRTCService.answerCall();
    } else {
      setState(() {
        _callStatus = CallStatus.connecting;
      });
      await _webRTCService.startCall();

      final callRepository = ref.read(callRepositoryProvider);
      await callRepository.updateCallStatus(
        callId: widget.callId,
        status: CallStatus.ringing,
      );
    }
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _callDuration++;
        });
      }
    });
  }

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _toggleMute() {
    HapticFeedback.lightImpact();
    _webRTCService.toggleMute();
    setState(() {
      _isMuted = !_isMuted;
    });
  }

  void _toggleSpeaker() {
    HapticFeedback.lightImpact();
    setState(() {
      _isSpeakerOn = !_isSpeakerOn;
    });
    // Note: Speaker toggle would require platform-specific implementation
    // The WebView handles audio output, but we can add platform channels if needed
  }

  Future<void> _endCall({bool updateFirestore = true}) async {
    _durationTimer?.cancel();
    await _callSubscription?.cancel();

    await _webRTCService.endCall();

    if (updateFirestore) {
      final callRepository = ref.read(callRepositoryProvider);
      await callRepository.endCall(
        callId: widget.callId,
        duration: _callDuration,
      );
    }

    if (mounted) {
      context.pop();
    }
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _callSubscription?.cancel();
    _pulseController.dispose();
    _waveController.dispose();
    _webRTCService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Hidden WebView for audio handling
              Positioned(
                left: -1000, // Hide off-screen
                child: SizedBox(
                  width: 1,
                  height: 1,
                  child: WebRTCWebView(
                    service: _webRTCService,
                    remoteName: widget.receiverName,
                    isVideoCall: false,
                  ),
                ),
              ),

              // Main UI
              Column(
                children: [
                  // Top bar
                  _buildTopBar(),

                  const Spacer(),

                  // Avatar with animation
                  _buildAnimatedAvatar(),

                  SizedBox(height: 32.h),

                  // Name
                  Text(
                    widget.receiverName,
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height: 8.h),

                  // Status or duration
                  Text(
                    _callStatus == CallStatus.ongoing
                        ? _formatDuration(_callDuration)
                        : _getStatusText(),
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),

                  const Spacer(),

                  // Call controls
                  _buildCallControls(),

                  SizedBox(height: 48.h),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _endCall(),
            icon: Icon(
              Icons.arrow_back_rounded,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const Spacer(),
          Text(
            'Voice Call',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          SizedBox(width: 48.w),
        ],
      ),
    );
  }

  Widget _buildAnimatedAvatar() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulse waves
        if (_callStatus == CallStatus.ongoing)
          ...List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final delay = index * 0.2;
                final progress = (_pulseController.value + delay) % 1.0;
                return Container(
                  width: (140 + progress * 60).w,
                  height: (140 + progress * 60).w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(
                        alpha: 0.3 * (1 - progress),
                      ),
                      width: 2,
                    ),
                  ),
                );
              },
            );
          }),

        // Avatar
        widget.receiverPhotoUrl != null
            ? CircleAvatar(
                radius: 70.r,
                backgroundImage: NetworkImage(widget.receiverPhotoUrl!),
              )
            : PremiumAvatar(name: widget.receiverName, size: 140),
      ],
    );
  }

  String _getStatusText() {
    switch (_callStatus) {
      case CallStatus.pending:
      case CallStatus.connecting:
        return 'Connecting...';
      case CallStatus.ringing:
        return widget.isIncoming ? 'Incoming call...' : 'Ringing...';
      case CallStatus.ongoing:
        return 'Voice call';
      default:
        return 'Call ended';
    }
  }

  Widget _buildCallControls() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(32.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Mute button
          _buildControlButton(
            icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
            label: _isMuted ? 'Unmute' : 'Mute',
            isActive: _isMuted,
            activeColor: AppColors.warning,
            onTap: _toggleMute,
          ).animate().fadeIn(delay: 100.ms).scale(delay: 100.ms),

          // End call button (larger)
          _buildEndCallButton()
              .animate()
              .fadeIn(delay: 200.ms)
              .scale(delay: 200.ms),

          // Speaker button
          _buildControlButton(
            icon: _isSpeakerOn
                ? Icons.volume_up_rounded
                : Icons.volume_down_rounded,
            label: 'Speaker',
            isActive: _isSpeakerOn,
            activeColor: AppColors.accent,
            onTap: _toggleSpeaker,
          ).animate().fadeIn(delay: 300.ms).scale(delay: 300.ms),
        ],
      ),
    ).animate().slideY(
      begin: 0.5,
      end: 0,
      duration: 400.ms,
      curve: Curves.easeOutCubic,
    );
  }

  Widget _buildEndCallButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.heavyImpact();
        _endCall();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72.w,
            height: 72.w,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF416C).withValues(alpha: 0.5),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              Icons.call_end_rounded,
              size: 32.sp,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'End',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    Color? activeColor,
    required VoidCallback onTap,
  }) {
    final bgColor = isActive
        ? (activeColor ?? Colors.white)
        : Colors.white.withValues(alpha: 0.15);
    final iconColor = isActive ? Colors.black : Colors.white;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: (activeColor ?? Colors.white).withValues(
                          alpha: 0.4,
                        ),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Icon(icon, size: 24.sp, color: iconColor),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

/// Incoming Voice Call Screen
class IncomingVoiceCallScreen extends ConsumerStatefulWidget {
  final String callId;
  final String chatId;
  final String callerName;
  final String? callerPhotoUrl;
  final String callerId;

  const IncomingVoiceCallScreen({
    super.key,
    required this.callId,
    required this.chatId,
    required this.callerName,
    this.callerPhotoUrl,
    required this.callerId,
  });

  @override
  ConsumerState<IncomingVoiceCallScreen> createState() =>
      _IncomingVoiceCallScreenState();
}

class _IncomingVoiceCallScreenState
    extends ConsumerState<IncomingVoiceCallScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _acceptCall() async {
    HapticFeedback.heavyImpact();

    // Update Firestore
    final callRepository = ref.read(callRepositoryProvider);
    await callRepository.answerCall(widget.callId);

    if (mounted) {
      context.pushReplacementNamed(
        'voice-call',
        queryParameters: {
          'callId': widget.callId,
          'chatId': widget.chatId,
          'receiverId': widget
              .callerId, // The caller becomes the "receiver" in the call screen
          'name': widget.callerName,
          if (widget.callerPhotoUrl != null) 'photoUrl': widget.callerPhotoUrl!,
          'isIncoming': 'true',
        },
      );
    }
  }

  Future<void> _declineCall() async {
    HapticFeedback.heavyImpact();

    final callRepository = ref.read(callRepositoryProvider);
    await callRepository.declineCall(widget.callId);

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 60.h),

              // Caller info
              Text(
                'Incoming Voice Call',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),

              SizedBox(height: 40.h),

              // Animated avatar
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    padding: EdgeInsets.all(8.w * _pulseController.value),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withValues(
                          alpha: 0.5 * (1 - _pulseController.value),
                        ),
                        width: 4,
                      ),
                    ),
                    child: child,
                  );
                },
                child: widget.callerPhotoUrl != null
                    ? CircleAvatar(
                        radius: 70.r,
                        backgroundImage: NetworkImage(widget.callerPhotoUrl!),
                      )
                    : PremiumAvatar(name: widget.callerName, size: 140),
              ),

              SizedBox(height: 24.h),

              Text(
                widget.callerName,
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const Spacer(),

              // Accept/Decline buttons
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 60.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Decline
                    _buildActionButton(
                      icon: Icons.call_end_rounded,
                      color: AppColors.error,
                      label: 'Decline',
                      onTap: _declineCall,
                    ),

                    // Accept
                    _buildActionButton(
                      icon: Icons.call_rounded,
                      color: AppColors.success,
                      label: 'Accept',
                      onTap: _acceptCall,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 60.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 72.w,
            height: 72.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, size: 32.sp, color: Colors.white),
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
