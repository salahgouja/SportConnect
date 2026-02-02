import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/core/services/webview_rtc_service.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/premium_avatar.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';
import 'package:sport_connect/features/messaging/models/call_model.dart';
import 'package:sport_connect/features/messaging/repositories/call_repository.dart';

/// Video Call Screen using WebView-based WebRTC (Open Source)
///
/// This implementation uses native browser WebRTC through a WebView,
/// which is 100% open source and free for commercial use.
class VideoCallScreen extends ConsumerStatefulWidget {
  final String callId;
  final String chatId;
  final String receiverId;
  final String receiverName;
  final String? receiverPhotoUrl;
  final bool isIncoming;

  const VideoCallScreen({
    super.key,
    required this.callId,
    required this.chatId,
    required this.receiverId,
    required this.receiverName,
    this.receiverPhotoUrl,
    this.isIncoming = false,
  });

  @override
  ConsumerState<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends ConsumerState<VideoCallScreen>
    with TickerProviderStateMixin {
  CallStatus _callStatus = CallStatus.pending;
  int _callDuration = 0;
  Timer? _durationTimer;
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isFrontCamera = true;
  bool _showControls = true;
  Timer? _hideControlsTimer;

  late AnimationController _controlsAnimController;

  StreamSubscription? _callSubscription;
  final WebViewRTCService _webRTCService = WebViewRTCService();

  @override
  void initState() {
    super.initState();
    _controlsAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _setupWebRTCCallbacks();
    _listenToCallStatus();
    _startHideControlsTimer();
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

    _webRTCService.onConnectionStateChange = (state) {
      TalkerService.debug('WebRTC connection state: $state');
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

    // Request permissions first
    final hasPermission = await _webRTCService.requestPermissions(video: true);
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera and microphone permissions are required'),
            backgroundColor: AppColors.error,
          ),
        );
        context.pop();
      }
      return;
    }

    // Initialize WebRTC
    await _webRTCService.initCall(
      callId: widget.callId,
      userId: currentUserId,
      isVideo: true,
      remoteName: widget.receiverName,
      signalingMode: SignalingMode.firebase, // Using Firebase for signaling
    );

    if (widget.isIncoming) {
      // Incoming call - answer it
      setState(() {
        _callStatus = CallStatus.connecting;
      });
      await _webRTCService.answerCall();
    } else {
      // Outgoing call - start it
      setState(() {
        _callStatus = CallStatus.connecting;
      });
      await _webRTCService.startCall();

      // Update call status to ringing
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

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _callStatus == CallStatus.ongoing) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startHideControlsTimer();
    }
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

  void _toggleVideo() {
    HapticFeedback.lightImpact();
    _webRTCService.toggleVideo();
    setState(() {
      _isVideoEnabled = !_isVideoEnabled;
    });
  }

  Future<void> _switchCamera() async {
    HapticFeedback.lightImpact();
    await _webRTCService.switchCamera();
    setState(() {
      _isFrontCamera = !_isFrontCamera;
    });
  }

  Future<void> _endCall({bool updateFirestore = true}) async {
    _durationTimer?.cancel();
    _hideControlsTimer?.cancel();
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
    _hideControlsTimer?.cancel();
    _callSubscription?.cancel();
    _controlsAnimController.dispose();
    _webRTCService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // WebRTC WebView (handles both local and remote video)
            WebRTCWebView(
              service: _webRTCService,
              remoteName: widget.receiverName,
              isVideoCall: true,
              onReady: () {
                // WebView is loaded
              },
            ),

            // Overlay controls
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: _buildOverlayControls(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlayControls() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.6),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withValues(alpha: 0.8),
          ],
          stops: const [0, 0.15, 0.7, 1],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Top bar with animation
            _buildTopBar()
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: -0.2, end: 0, duration: 400.ms),

            const Spacer(),

            // Duration with pulse animation
            if (_callStatus == CallStatus.ongoing)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.8),
                      AppColors.primaryLight.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        )
                        .animate(onPlay: (c) => c.repeat())
                        .fadeIn(duration: 600.ms)
                        .then()
                        .fadeOut(duration: 600.ms),
                    SizedBox(width: 8.w),
                    Text(
                      _formatDuration(_callDuration),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().scale(),

            SizedBox(height: 24.h),

            // Call controls
            _buildCallControls(),

            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        children: [
          // Back button with ripple
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _endCall(),
              borderRadius: BorderRadius.circular(24.r),
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 22.sp,
                ),
              ),
            ),
          ),
          const Spacer(),
          // User info with avatar
          Column(
            children: [
              if (widget.receiverPhotoUrl != null &&
                  widget.receiverPhotoUrl!.isNotEmpty)
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.6),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.network(
                      widget.receiverPhotoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _buildAvatarPlaceholder(),
                    ),
                  ),
                )
              else
                _buildAvatarPlaceholder(),
              SizedBox(height: 6.h),
              Text(
                widget.receiverName,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: _getStatusColor().withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  _getStatusText(),
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: _getStatusColor(),
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          SizedBox(width: 48.w),
        ],
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          widget.receiverName.isNotEmpty
              ? widget.receiverName[0].toUpperCase()
              : '?',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (_callStatus) {
      case CallStatus.pending:
      case CallStatus.connecting:
        return AppColors.warning;
      case CallStatus.ringing:
        return AppColors.accent;
      case CallStatus.ongoing:
        return AppColors.success;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (_callStatus) {
      case CallStatus.pending:
      case CallStatus.connecting:
        return 'Connecting...';
      case CallStatus.ringing:
        return widget.isIncoming ? 'Incoming call...' : 'Ringing...';
      case CallStatus.ongoing:
        return 'Video call';
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

          // Video toggle
          _buildControlButton(
            icon: _isVideoEnabled
                ? Icons.videocam_rounded
                : Icons.videocam_off_rounded,
            label: _isVideoEnabled ? 'Camera' : 'Camera Off',
            isActive: !_isVideoEnabled,
            activeColor: AppColors.warning,
            onTap: _toggleVideo,
          ).animate().fadeIn(delay: 200.ms).scale(delay: 200.ms),

          // Camera flip
          _buildControlButton(
            icon: Icons.flip_camera_ios_rounded,
            label: 'Flip',
            isActive: false,
            onTap: _switchCamera,
          ).animate().fadeIn(delay: 300.ms).scale(delay: 300.ms),

          // End call button
          _buildEndCallButton()
              .animate()
              .fadeIn(delay: 400.ms)
              .scale(delay: 400.ms),
        ],
      ),
    ).animate().slideY(
      begin: 0.5,
      end: 0,
      duration: 400.ms,
      curve: Curves.easeOutCubic,
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

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
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
      ),
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
            width: 56.w,
            height: 56.w,
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
              size: 24.sp,
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
}

/// Incoming Video Call Screen
class IncomingVideoCallScreen extends ConsumerStatefulWidget {
  final String callId;
  final String chatId;
  final String callerName;
  final String? callerPhotoUrl;
  final String callerId;

  const IncomingVideoCallScreen({
    super.key,
    required this.callId,
    required this.chatId,
    required this.callerName,
    this.callerPhotoUrl,
    required this.callerId,
  });

  @override
  ConsumerState<IncomingVideoCallScreen> createState() =>
      _IncomingVideoCallScreenState();
}

class _IncomingVideoCallScreenState
    extends ConsumerState<IncomingVideoCallScreen>
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
        'video-call',
        queryParameters: {
          'callId': widget.callId,
          'chatId': widget.chatId,
          'receiverId': widget
              .callerId, // The caller becomes the "receiver" of the connection
          'name': widget.callerName,
          if (widget.callerPhotoUrl != null) 'photoUrl': widget.callerPhotoUrl!,
          'isIncoming': 'true', // See note below
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
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 60.h),

            // Caller info
            Text(
              'Incoming Video Call',
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
                    icon: Icons.videocam_rounded,
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
