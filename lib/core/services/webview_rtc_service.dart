import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// WebRTC Service using WebView - Open Source Implementation
///
/// This implementation uses the native browser WebRTC stack through a WebView,
/// which is 100% open source and free for commercial use.
///
/// Features:
/// - Voice and video calls
/// - WebSocket signaling (with Firebase fallback)
/// - STUN servers (free, no cost)
/// - Works on Android and iOS
class WebViewRTCService {
  InAppWebViewController? _webViewController;
  WebSocketChannel? _wsChannel;
  StreamSubscription? _wsSubscription;

  // Firebase fallback for signaling
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _firestoreSubscription;

  // Call state
  String? _callId;
  String? _userId;
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isFrontCamera = true;
  bool _isConnected = false;

  // Signaling mode
  SignalingMode _signalingMode = SignalingMode.firebase;
  String? _wsUrl;

  // Callbacks
  Function()? onPageReady;
  Function()? onLocalStreamReady;
  Function()? onRemoteStreamReady;
  Function()? onCallConnected;
  Function()? onCallEnded;
  Function()? onCallDeclined;
  Function(String)? onError;
  Function(String)? onConnectionStateChange;

  bool get isMuted => _isMuted;
  bool get isVideoEnabled => _isVideoEnabled;
  bool get isFrontCamera => _isFrontCamera;
  bool get isConnected => _isConnected;

  /// Request necessary permissions for voice/video calls
  Future<bool> requestPermissions({bool video = true}) async {
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      onError?.call('Microphone permission denied');
      return false;
    }

    if (video) {
      final cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        onError?.call('Camera permission denied');
        return false;
      }
    }

    return true;
  }

  /// Set WebView controller (called from widget)
  void setWebViewController(InAppWebViewController controller) {
    _webViewController = controller;
    _setupMessageHandler();
  }

  /// Setup console message handler for communication from JS
  void _setupMessageHandler() {
    // Messages are received via onConsoleMessage in the WebView widget
  }

  /// Handle messages from JavaScript
  void handleJsMessage(String message) {
    try {
      if (message.startsWith('FLUTTER_MSG:')) {
        final jsonStr = message.substring('FLUTTER_MSG:'.length);
        final data = json.decode(jsonStr) as Map<String, dynamic>;
        _processMessage(data);
      }
    } catch (e) {
      TalkerService.debug('Error parsing JS message: $e');
    }
  }

  void _processMessage(Map<String, dynamic> data) {
    final type = data['type'] as String?;

    switch (type) {
      case 'pageReady':
        onPageReady?.call();
        break;
      case 'initialized':
        TalkerService.debug('WebRTC client initialized');
        break;
      case 'localStreamReady':
        onLocalStreamReady?.call();
        break;
      case 'remoteStreamReady':
        onRemoteStreamReady?.call();
        break;
      case 'callConnected':
        _isConnected = true;
        onCallConnected?.call();
        break;
      case 'callEnded':
        _isConnected = false;
        onCallEnded?.call();
        break;
      case 'callDeclined':
        onCallDeclined?.call();
        break;
      case 'muteChanged':
        _isMuted = data['isMuted'] as bool? ?? _isMuted;
        break;
      case 'videoChanged':
        _isVideoEnabled = data['isVideoEnabled'] as bool? ?? _isVideoEnabled;
        break;
      case 'cameraSwitched':
        _isFrontCamera = data['isFrontCamera'] as bool? ?? _isFrontCamera;
        break;
      case 'connectionStateChange':
        onConnectionStateChange?.call(data['state'] as String? ?? 'unknown');
        break;
      case 'error':
        onError?.call(data['message'] as String? ?? 'Unknown error');
        break;
      case 'signaling':
        _handleSignalingFromJs(data);
        break;
      case 'offerSent':
      case 'answerSent':
      case 'answerReceived':
        TalkerService.debug('Signaling: $type');
        break;
    }
  }

  /// Handle signaling messages from JS and save to Firebase
  Future<void> _handleSignalingFromJs(Map<String, dynamic> data) async {
    if (_callId == null) return;

    final callDoc = _firestore.collection('calls').doc(_callId);
    final signalingType = data['type'] as String?;

    switch (signalingType) {
      case 'offer':
        await callDoc.update({
          'offer': {'sdp': data['sdp'], 'type': 'offer'},
          'offerCreatedAt': FieldValue.serverTimestamp(),
        });
        TalkerService.debug('Offer saved to Firebase');
        break;
      case 'answer':
        await callDoc.update({
          'answer': {'sdp': data['sdp'], 'type': 'answer'},
          'answerCreatedAt': FieldValue.serverTimestamp(),
        });
        TalkerService.debug('Answer saved to Firebase');
        break;
      case 'ice-candidate':
        final candidateData = data['candidate'] as Map<String, dynamic>?;
        if (candidateData != null) {
          // Determine if we're caller or callee based on whether offer exists
          final callSnapshot = await callDoc.get();
          final callData = callSnapshot.data();
          final isCaller = callData?['callerId'] == _userId;

          final candidateCollection = isCaller
              ? callDoc.collection('callerCandidates')
              : callDoc.collection('calleeCandidates');

          await candidateCollection.add({
            'candidate': candidateData['candidate'],
            'sdpMid': candidateData['sdpMid'],
            'sdpMLineIndex': candidateData['sdpMLineIndex'],
          });
        }
        break;
      case 'call-ended':
        await callDoc.update({
          'status': 'ended',
          'endedAt': FieldValue.serverTimestamp(),
        });
        break;
    }
  }

  /// Initialize call
  Future<void> initCall({
    required String callId,
    required String userId,
    required bool isVideo,
    String? remoteName,
    SignalingMode signalingMode = SignalingMode.firebase,
    String? wsUrl,
  }) async {
    _callId = callId;
    _userId = userId;
    _signalingMode = signalingMode;
    _wsUrl = wsUrl;

    final config = {
      'callId': callId,
      'userId': userId,
      'isVideo': isVideo,
      'remoteName': remoteName ?? 'Unknown',
      'signalingUrl': wsUrl,
    };

    await _evaluateJs('WebRTCClient.init(${json.encode(config)})');

    // Setup signaling
    if (_signalingMode == SignalingMode.websocket && _wsUrl != null) {
      await _connectWebSocket();
    } else {
      await _setupFirebaseSignaling();
    }
  }

  /// Connect to WebSocket signaling server
  Future<void> _connectWebSocket() async {
    if (_wsUrl == null) return;

    try {
      _wsChannel = WebSocketChannel.connect(Uri.parse(_wsUrl!));

      _wsSubscription = _wsChannel!.stream.listen(
        (message) {
          _forwardSignalingToJs(message as String);
        },
        onError: (error) {
          TalkerService.error('WebSocket error: $error');
          onError?.call('Signaling connection failed');
        },
        onDone: () {
          TalkerService.debug('WebSocket closed');
        },
      );

      // Join the call room
      _wsChannel!.sink.add(
        json.encode({'type': 'join', 'callId': _callId, 'userId': _userId}),
      );
    } catch (e) {
      TalkerService.debug('WebSocket connect error: $e');
      // Fallback to Firebase
      await _setupFirebaseSignaling();
    }
  }

  /// Forward signaling message to JS
  void _forwardSignalingToJs(String message) {
    _evaluateJs('WebRTCClient.handleSignalingMessage($message)');
  }

  /// Setup Firebase signaling (fallback)
  Future<void> _setupFirebaseSignaling() async {
    if (_callId == null) return;

    final callDoc = _firestore.collection('calls').doc(_callId);

    _firestoreSubscription = callDoc.snapshots().listen((snapshot) async {
      final data = snapshot.data();
      if (data == null) return;

      // Handle offer
      if (data['offer'] != null && data['offerProcessed'] != true) {
        final offer = {'type': 'offer', 'sdp': data['offer']['sdp']};
        _forwardSignalingToJs(json.encode(offer));
      }

      // Handle answer
      if (data['answer'] != null && data['answerProcessed'] != true) {
        final answer = {'type': 'answer', 'sdp': data['answer']['sdp']};
        _forwardSignalingToJs(json.encode(answer));
      }
    });

    // Listen for ICE candidates
    callDoc.collection('callerCandidates').snapshots().listen((snapshot) {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data != null) {
            _forwardSignalingToJs(
              json.encode({'type': 'ice-candidate', 'candidate': data}),
            );
          }
        }
      }
    });

    callDoc.collection('calleeCandidates').snapshots().listen((snapshot) {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data != null) {
            _forwardSignalingToJs(
              json.encode({'type': 'ice-candidate', 'candidate': data}),
            );
          }
        }
      }
    });
  }

  /// Start call (caller)
  Future<void> startCall() async {
    await _evaluateJs('WebRTCClient.startCall()');
  }

  /// Answer call (callee)
  Future<void> answerCall() async {
    await _evaluateJs('WebRTCClient.answerCall()');
  }

  /// Toggle mute
  Future<void> toggleMute() async {
    await _evaluateJs('WebRTCClient.toggleMute()');
    _isMuted = !_isMuted;
  }

  /// Toggle video
  Future<void> toggleVideo() async {
    await _evaluateJs('WebRTCClient.toggleVideo()');
    _isVideoEnabled = !_isVideoEnabled;
  }

  /// Switch camera
  Future<void> switchCamera() async {
    await _evaluateJs('WebRTCClient.switchCamera()');
    _isFrontCamera = !_isFrontCamera;
  }

  /// Update status display
  Future<void> updateStatus(String status) async {
    await _evaluateJs('WebRTCClient.updateStatus("$status")');
  }

  /// End call
  Future<void> endCall() async {
    await _evaluateJs('WebRTCClient.endCall()');
    await dispose();
  }

  /// Evaluate JavaScript in WebView
  Future<void> _evaluateJs(String js) async {
    try {
      await _webViewController?.evaluateJavascript(source: js);
    } catch (e) {
      TalkerService.debug('JS evaluation error: $e');
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _wsSubscription?.cancel();
    await _firestoreSubscription?.cancel();
    _wsChannel?.sink.close();
    _webViewController = null;
    _isConnected = false;
  }
}

/// Signaling mode options
enum SignalingMode {
  /// Use WebSocket for signaling (lower latency)
  websocket,

  /// Use Firebase Firestore for signaling (easier setup)
  firebase,
}

/// WebRTC WebView Widget
///
/// This widget encapsulates the WebView that runs the WebRTC client.
/// Use this in your call screens to display video.
class WebRTCWebView extends StatefulWidget {
  final WebViewRTCService service;
  final String? remoteName;
  final bool isVideoCall;
  final VoidCallback? onReady;

  const WebRTCWebView({
    super.key,
    required this.service,
    this.remoteName,
    this.isVideoCall = true,
    this.onReady,
  });

  @override
  State<WebRTCWebView> createState() => _WebRTCWebViewState();
}

class _WebRTCWebViewState extends State<WebRTCWebView> {
  bool _isReady = false;

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialFile: 'assets/webrtc/call_client.html',
      initialSettings: InAppWebViewSettings(
        mediaPlaybackRequiresUserGesture: false,
        allowsInlineMediaPlayback: true,
        javaScriptEnabled: true,
        domStorageEnabled: true,
        useHybridComposition: true,
        allowFileAccess: true,
        allowContentAccess: true,
        // Enable WebRTC
        userAgent:
            'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 Chrome/91.0.4472.120 Mobile Safari/537.36',
      ),
      onWebViewCreated: (controller) {
        widget.service.setWebViewController(controller);
      },
      onLoadStop: (controller, url) {
        if (!_isReady) {
          _isReady = true;
          widget.onReady?.call();
        }
      },
      onConsoleMessage: (controller, consoleMessage) {
        widget.service.handleJsMessage(consoleMessage.message);
      },
      onPermissionRequest: (controller, request) async {
        // Grant all permissions for WebRTC
        return PermissionResponse(
          resources: request.resources,
          action: PermissionResponseAction.GRANT,
        );
      },
    );
  }
}

/// Global WebView RTC service instance
final webViewRTCService = WebViewRTCService();
