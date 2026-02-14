import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/premium_avatar.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/messaging/models/message_model.dart';
import 'package:sport_connect/features/messaging/view_models/chat_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Chat Detail Screen with real-time Firestore messaging
class ChatDetailScreen extends ConsumerStatefulWidget {
  final String chatId;
  final UserModel receiver;
  final bool isGroup;

  const ChatDetailScreen({
    super.key,
    required this.chatId,
    required this.receiver,
    this.isGroup = false,
  });

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _showEmojiPicker = false;
  bool _isRecording = false;
  String? _recordingPath;
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;
  Timer? _typingTimer;
  bool _isTyping = false;

  UserModel? get currentUser => ref.read(currentUserProvider).value;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _messageController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _typingTimer?.cancel();
    _recordingTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more messages when near the end
      final viewModel = ref.read(
        chatDetailViewModelProvider(
          widget.chatId,
          currentUser?.uid ?? '',
        ).notifier,
      );
      viewModel.loadMoreMessages();
    }
  }

  void _onTextChanged() {
    if (_messageController.text.isNotEmpty && !_isTyping) {
      _isTyping = true;
      _setTyping(true);
    }

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      _isTyping = false;
      _setTyping(false);
    });
  }

  void _setTyping(bool isTyping) {
    final viewModel = ref.read(
      chatDetailViewModelProvider(
        widget.chatId,
        currentUser?.uid ?? '',
      ).notifier,
    );
    viewModel.setTyping(isTyping, currentUser?.displayName ?? 'User');
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.lightImpact();
    _messageController.clear();
    setState(() => _showEmojiPicker = false);

    final viewModel = ref.read(
      chatDetailViewModelProvider(
        widget.chatId,
        currentUser?.uid ?? '',
      ).notifier,
    );

    final state = ref.read(
      chatDetailViewModelProvider(widget.chatId, currentUser?.uid ?? ''),
    );

    await viewModel.sendMessage(
      content: text,
      senderName: currentUser?.displayName ?? 'User',
      senderPhotoUrl: currentUser?.photoUrl,
      replyToMessageId: state.replyToMessage?.id,
      replyToContent: state.replyToMessage?.content,
    );

    viewModel.clearReply();
    _scrollToBottom();
  }

  Future<void> _sendImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    HapticFeedback.lightImpact();

    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20.w,
              height: 20.w,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12.w),
            Text(AppLocalizations.of(context).sendingImage),
          ],
        ),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 30),
      ),
    );

    try {
      // Upload image via repository (MVVM pattern)
      final file = File(pickedFile.path);
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}';
      final chatController = ref.read(chatActionsViewModelProvider);
      final imageUrl = await chatController.uploadChatImage(
        chatId: widget.chatId,
        imageFile: file,
        fileName: fileName,
      );

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Send image message
      final viewModel = ref.read(
        chatDetailViewModelProvider(
          widget.chatId,
          currentUser?.uid ?? '',
        ).notifier,
      );

      await viewModel.sendMessage(
        content: '📷 Photo',
        senderName: currentUser?.displayName ?? 'User',
        senderPhotoUrl: currentUser?.photoUrl,
        type: MessageType.image,
        imageUrl: imageUrl,
      );

      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).failedToSendImageValue(e)),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  /// Start voice recording
  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getTemporaryDirectory();
        final path = '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
          ),
          path: path,
        );

        setState(() {
          _isRecording = true;
          _recordingPath = path;
          _recordingDuration = Duration.zero;
        });

        // Start recording timer (updates every 100ms for smooth UI)
        _recordingTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
          if (mounted) {
            setState(() {
              _recordingDuration = Duration(milliseconds: timer.tick * 100);
            });
          }
        });

        HapticFeedback.mediumImpact();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start recording: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  /// Stop voice recording and send
  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      _recordingTimer?.cancel();

      if (path != null && mounted) {
        await _sendAudioMessage(path);
      }

      setState(() {
        _isRecording = false;
        _recordingPath = null;
        _recordingDuration = Duration.zero;
      });

      HapticFeedback.mediumImpact();
    } catch (e) {
      setState(() {
        _isRecording = false;
        _recordingPath = null;
        _recordingDuration = Duration.zero;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12.w),
              const Expanded(child: Text('Failed to stop recording')),
            ],
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  /// Cancel voice recording
  Future<void> _cancelRecording() async {
    try {
      await _audioRecorder.stop();
      _recordingTimer?.cancel();

      // Delete the recording file
      if (_recordingPath != null) {
        final file = File(_recordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }

      setState(() {
        _isRecording = false;
        _recordingPath = null;
        _recordingDuration = Duration.zero;
      });

      HapticFeedback.lightImpact();
    } catch (e) {
      // Silently fail
    }
  }

  /// Send audio message
  Future<void> _sendAudioMessage(String audioPath) async {
    HapticFeedback.lightImpact();

    // Show uploading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20.w,
              height: 20.w,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12.w),
            const Text('Sending voice message...'),
          ],
        ),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 30),
      ),
    );

    try {
      // Upload audio to Firebase Storage
      final file = File(audioPath);
      final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('chats/${widget.chatId}/audio/$fileName');
      
      await storageRef.putFile(file);
      final audioUrl = await storageRef.getDownloadURL();

      // Delete local file
      if (await file.exists()) {
        await file.delete();
      }

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Send audio message
      final viewModel = ref.read(
        chatDetailViewModelProvider(
          widget.chatId,
          currentUser?.uid ?? '',
        ).notifier,
      );

      final duration = _recordingDuration;
      final durationText = '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';

      await viewModel.sendMessage(
        content: '🎤 Voice message ($durationText)',
        senderName: currentUser?.displayName ?? 'User',
        senderPhotoUrl: currentUser?.photoUrl,
        type: MessageType.audio,
        imageUrl: audioUrl, // Reusing imageUrl field for audio URL
      );

      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      
      // Provide user-friendly error message
      String errorMessage = 'Failed to send voice message';
      if (e.toString().contains('permission') || e.toString().contains('403')) {
        errorMessage = 'Permission denied. Please check your connection and try again.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your internet connection.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12.w),
              Expanded(child: Text(errorMessage)),
            ],
          ),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'RETRY',
            textColor: Colors.white,
            onPressed: () => _sendAudioMessage(audioPath),
          ),
        ),
      );
      
      // Log error for debugging
      TalkerService.error('Audio upload failed', e);
    }
  }

  void _toggleEmojiPicker() {
    if (_showEmojiPicker) {
      setState(() => _showEmojiPicker = false);
      _focusNode.requestFocus();
    } else {
      _focusNode.unfocus();
      setState(() => _showEmojiPicker = true);
    }
  }


  void _showOptionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            _buildOptionItem(
              Icons.person_outline_rounded,
              AppLocalizations.of(context).viewProfile,
              () {
                context.pop();
              },
            ),
            _buildOptionItem(
              Icons.search_rounded,
              AppLocalizations.of(context).searchInChat,
              () {
                context.pop();
              },
            ),
            _buildOptionItem(
              Icons.notifications_off_outlined,
              AppLocalizations.of(context).muteNotifications,
              () {
                context.pop();
                _muteChat();
              },
            ),
            _buildOptionItem(
              Icons.delete_outline_rounded,
              AppLocalizations.of(context).clearChat,
              () {
                context.pop();
                _confirmClearChat();
              },
              isDestructive: true,
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  void _muteChat() async {
    final chatController = ref.read(chatActionsViewModelProvider);
    await chatController.toggleMute(
      chatId: widget.chatId,
      userId: currentUser!.uid,
      mute: true,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).notificationsMutedForThisChat,
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _confirmClearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(AppLocalizations.of(context).clearChat),
        content: Text(AppLocalizations.of(context).areYouSureYouWant),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          ElevatedButton(
            onPressed: () {
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context).chatCleared),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(
              AppLocalizations.of(context).clear,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.error : AppColors.textSecondary,
        size: 24.sp,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: isDestructive ? AppColors.error : AppColors.textPrimary,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(
      chatDetailViewModelProvider(widget.chatId, currentUser!.uid),
    );

    // Mark messages as read when new messages arrive (explicit side effect
    // outside provider initialization).
    ref.listen(chatDetailViewModelProvider(widget.chatId, currentUser!.uid), (
      previous,
      next,
    ) {
      if (next.messages.isNotEmpty) {
        ref
            .read(
              chatDetailViewModelProvider(
                widget.chatId,
                currentUser!.uid,
              ).notifier,
            )
            .markVisibleMessagesAsRead();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(chatState),
      body: Stack(
        children: [
          Column(
            children: [
              // Messages list
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _focusNode.unfocus();
                    setState(() => _showEmojiPicker = false);
                  },
                  child: chatState.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : chatState.messages.isEmpty
                      ? _buildEmptyState()
                      : _buildMessagesList(chatState),
                ),
              ),

              // Typing indicator
              if (chatState.typingUsers.isNotEmpty)
                _buildTypingIndicator(chatState),

              // Reply preview
              if (chatState.replyToMessage != null)
                _buildReplyPreview(chatState.replyToMessage!),

              // Input area
              _buildInputArea(),

              // Emoji picker
              if (_showEmojiPicker)
                SizedBox(
                  height: 280.h,
                  child: EmojiPicker(
                    textEditingController: _messageController,
                    onEmojiSelected: (category, emoji) {
                      // Insert emoji at cursor position
                      final text = _messageController.text;
                      final selection = _messageController.selection;
                      final newText = text.replaceRange(
                        selection.start,
                        selection.end,
                        emoji.emoji,
                      );
                      _messageController.text = newText;
                      _messageController.selection = TextSelection.collapsed(
                        offset: selection.start + emoji.emoji.length,
                      );
                    },
                    onBackspacePressed: () {
                      // Handle backspace when emoji picker is open
                      _messageController
                        ..text = _messageController.text.characters
                            .skipLast(1)
                            .toString()
                        ..selection = TextSelection.fromPosition(
                          TextPosition(offset: _messageController.text.length),
                        );
                    },
                    config: Config(
                      height: 280.h,
                      checkPlatformCompatibility: true,
                      emojiViewConfig: EmojiViewConfig(
                        emojiSizeMax: 28,
                        backgroundColor: AppColors.cardBg,
                        columns: 8,
                      ),
                      categoryViewConfig: CategoryViewConfig(
                        backgroundColor: AppColors.cardBg,
                        indicatorColor: AppColors.primary,
                        iconColor: AppColors.textTertiary,
                        iconColorSelected: AppColors.primary,
                      ),
                      bottomActionBarConfig: const BottomActionBarConfig(
                        enabled: false,
                      ),
                      searchViewConfig: SearchViewConfig(
                        backgroundColor: AppColors.cardBg,
                        buttonIconColor: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.2),
            ],
          ),
          
          // Recording indicator banner at top
          if (_isRecording)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE91E63), Color(0xFFF44336)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ).animate(
                      onPlay: (controller) => controller.repeat(),
                    ).fadeIn(duration: 600.ms).then().fadeOut(duration: 600.ms),
                    SizedBox(width: 12.w),
                    Icon(
                      Icons.mic,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Recording',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_recordingDuration.inMinutes}:${(_recordingDuration.inSeconds % 60).toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    GestureDetector(
                      onTap: _cancelRecording,
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().slideY(begin: -1).fadeIn(),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryLight.withOpacity(0.15),
                  AppColors.accentLight.withOpacity(0.08),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 50.sp,
              color: AppColors.primary,
            ),
          ).animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 2000.ms, delay: 2000.ms)
              .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 1500.ms)
              .then()
              .scale(begin: const Offset(1.05, 1.05), end: const Offset(1, 1), duration: 1500.ms),
          SizedBox(height: 24.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primarySurface.withOpacity(0.5),
                  AppColors.accentSurface.withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.1),
              ),
            ),
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context).noMessagesYet,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  AppLocalizations.of(context).sendAMessageToStart,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.1),
          SizedBox(height: 32.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildQuickActionChip(
                Icons.emoji_emotions_rounded,
                'Send Emoji',
                AppColors.warning,
              ),
              SizedBox(width: 12.w),
              _buildQuickActionChip(
                Icons.image_rounded,
                'Send Photo',
                AppColors.info,
              ),
            ],
          ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideY(begin: 0.15),
        ],
      ),
    );
  }

  Widget _buildQuickActionChip(IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18.sp, color: color),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(ChatDetailState chatState) {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      reverse: true, // Latest messages at bottom
      itemCount: chatState.messages.length + (chatState.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (chatState.isLoadingMore && index == chatState.messages.length) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: const CircularProgressIndicator(),
            ),
          );
        }

        final message = chatState.messages[index];
        final isMe = message.senderId == currentUser!.uid;
        final showAvatar =
            !isMe &&
            (index == chatState.messages.length - 1 ||
                chatState.messages[index + 1].senderId != message.senderId);

        return _buildMessageBubble(message, isMe, showAvatar, index);
      },
    );
  }

  PreferredSizeWidget _buildAppBar(ChatDetailState chatState) {
    return AppBar(
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: AppColors.heroGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: EdgeInsets.only(left: 8.w),
        child: IconButton(
          onPressed: () => context.pop(),
          icon: Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18.sp,
              color: Colors.white,
            ),
          ),
        ),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Stack(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.white.withOpacity(0.3), Colors.transparent],
                  ),
                ),
                child: widget.receiver.photoUrl != null
                    ? CircleAvatar(
                        radius: 20.r,
                        backgroundImage: NetworkImage(widget.receiver.photoUrl!),
                      )
                    : PremiumAvatar(name: widget.receiver.displayName, size: 40),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14.w,
                  height: 14.w,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withOpacity(0.5),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ).animate(onPlay: (controller) => controller.repeat())
                    .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 1000.ms)
                    .then()
                    .scale(begin: const Offset(1.2, 1.2), end: const Offset(1, 1), duration: 1000.ms),
              ),
            ],
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.receiver.displayName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    if (chatState.typingUsers.isNotEmpty)
                      Container(
                        width: 6.w,
                        height: 6.w,
                        margin: EdgeInsets.only(right: 4.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ).animate(onPlay: (c) => c.repeat())
                          .fadeOut(duration: 600.ms)
                          .then()
                          .fadeIn(duration: 600.ms),
                    Text(
                      chatState.typingUsers.isNotEmpty
                          ? AppLocalizations.of(context).typing
                          : AppLocalizations.of(context).online,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: EdgeInsets.only(right: 8.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: IconButton(
            onPressed: _showOptionsSheet,
            icon: Icon(
              Icons.more_vert_rounded,
              color: Colors.white,
              size: 22.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypingIndicator(ChatDetailState chatState) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          PremiumAvatar(name: widget.receiver.displayName, size: 28),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                _buildTypingDot(0),
                SizedBox(width: 4.w),
                _buildTypingDot(1),
                SizedBox(width: 4.w),
                _buildTypingDot(2),
              ],
            ),
          ),
        ],
      ),
    ).animate(onPlay: (c) => c.repeat()).fadeIn(duration: 300.ms);
  }

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 200)),
      builder: (context, value, child) {
        return Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: AppColors.textTertiary.withValues(
              alpha: 0.5 + (value * 0.5),
            ),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildReplyPreview(MessageModel message) {
    final viewModel = ref.read(
      chatDetailViewModelProvider(widget.chatId, currentUser!.uid).notifier,
    );

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12.r),
        border: Border(left: BorderSide(color: AppColors.primary, width: 3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(
                    context,
                  ).replyingToValue(message.senderName),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  message.content,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => viewModel.clearReply(),
            icon: Icon(
              Icons.close_rounded,
              color: AppColors.textSecondary,
              size: 20.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    MessageModel message,
    bool isMe,
    bool showAvatar,
    int index,
  ) {
    return GestureDetector(
          onLongPress: () => _showMessageOptions(message),
          child: Padding(
            padding: EdgeInsets.only(bottom: 4.h),
            child: Row(
              mainAxisAlignment: isMe
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!isMe) ...[
                  if (showAvatar)
                    PremiumAvatar(name: message.senderName, size: 32)
                  else
                    SizedBox(width: 32.w),
                  SizedBox(width: 8.w),
                ],
                Flexible(
                  child: Column(
                    crossAxisAlignment: isMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      // Reply indicator
                      if (message.replyToContent != null)
                        Container(
                          margin: EdgeInsets.only(bottom: 4.h),
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant.withValues(
                              alpha: 0.3,
                            ),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border(
                              left: BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Text(
                            message.replyToContent!,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                      // Message content
                      Container(
                        constraints: BoxConstraints(maxWidth: 280.w),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: isMe
                              ? LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primary.withValues(alpha: 0.9),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: isMe
                              ? null
                              : AppColors.surfaceVariant.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.r),
                            topRight: Radius.circular(20.r),
                            bottomLeft: isMe
                                ? Radius.circular(20.r)
                                : Radius.circular(4.r),
                            bottomRight: isMe
                                ? Radius.circular(4.r)
                                : Radius.circular(20.r),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isMe
                                  ? AppColors.primary.withValues(alpha: 0.2)
                                  : Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Image message
                            if (message.type == MessageType.image &&
                                message.imageUrl != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12.r),
                                child: Image.network(
                                  message.imageUrl!,
                                  width: 200.w,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Container(
                                          width: 200.w,
                                          height: 150.h,
                                          color: AppColors.surfaceVariant,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              value:
                                                  loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                  : null,
                                            ),
                                          ),
                                        );
                                      },
                                ),
                              )
                            // Location message
                            else if (message.type == MessageType.location &&
                                message.latitude != null &&
                                message.longitude != null)
                              GestureDetector(
                                onTap: () => _openLocationInMaps(
                                  message.latitude!,
                                  message.longitude!,
                                  message.content,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Map preview using OpenStreetMap static image
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12.r),
                                      child: Stack(
                                        children: [
                                          Image.network(
                                            'https://staticmap.openstreetmap.de/staticmap.php?center=${message.latitude},${message.longitude}&zoom=15&size=200x120&maptype=osmarenderer&markers=${message.latitude},${message.longitude},red-pushpin',
                                            width: 200.w,
                                            height: 120.h,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return Container(
                                                    width: 200.w,
                                                    height: 120.h,
                                                    color: AppColors
                                                        .surfaceVariant,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons.map_rounded,
                                                          size: 32.sp,
                                                          color: isMe
                                                              ? Colors.white70
                                                              : AppColors
                                                                    .textSecondary,
                                                        ),
                                                        SizedBox(height: 4.h),
                                                        Text(
                                                          AppLocalizations.of(
                                                            context,
                                                          ).tapToOpenMap,
                                                          style: TextStyle(
                                                            fontSize: 11.sp,
                                                            color: isMe
                                                                ? Colors.white70
                                                                : AppColors
                                                                      .textSecondary,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                            loadingBuilder:
                                                (
                                                  context,
                                                  child,
                                                  loadingProgress,
                                                ) {
                                                  if (loadingProgress == null)
                                                    return child;
                                                  return Container(
                                                    width: 200.w,
                                                    height: 120.h,
                                                    color: AppColors
                                                        .surfaceVariant,
                                                    child: const Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                          ),
                                                    ),
                                                  );
                                                },
                                          ),
                                          // Tap to open indicator
                                          Positioned(
                                            right: 8.w,
                                            top: 8.h,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 8.w,
                                                vertical: 4.h,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.black54,
                                                borderRadius:
                                                    BorderRadius.circular(12.r),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.open_in_new,
                                                    size: 12.sp,
                                                    color: Colors.white,
                                                  ),
                                                  SizedBox(width: 4.w),
                                                  Text(
                                                    AppLocalizations.of(
                                                      context,
                                                    ).open,
                                                    style: TextStyle(
                                                      fontSize: 10.sp,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    // Location name/address
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.location_on_rounded,
                                          size: 16.sp,
                                          color: isMe
                                              ? Colors.white70
                                              : const Color(0xFF4CAF50),
                                        ),
                                        SizedBox(width: 4.w),
                                        Flexible(
                                          child: Text(
                                            message.content.replaceFirst(
                                              '📍 ',
                                              '',
                                            ),
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              color: isMe
                                                  ? Colors.white
                                                  : AppColors.textPrimary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            // Audio message
                            else if (message.type == MessageType.audio &&
                                message.imageUrl != null) // Using imageUrl field for audio URL
                              _AudioMessagePlayer(
                                audioUrl: message.imageUrl!,
                                isMe: isMe,
                              )
                            else
                              Text(
                                message.isDeleted
                                    ? AppLocalizations.of(
                                        context,
                                      ).thisMessageWasDeleted
                                    : message.content,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  color: isMe
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontStyle: message.isDeleted
                                      ? FontStyle.italic
                                      : FontStyle.normal,
                                  height: 1.3,
                                ),
                              ),
                            SizedBox(height: 4.h),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (message.isEdited)
                                  Padding(
                                    padding: EdgeInsets.only(right: 4.w),
                                    child: Text(
                                      AppLocalizations.of(context).edited,
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: isMe
                                            ? Colors.white.withValues(
                                                alpha: 0.6,
                                              )
                                            : AppColors.textTertiary,
                                      ),
                                    ),
                                  ),
                                Text(
                                  _formatTime(message.createdAt),
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: isMe
                                        ? Colors.white.withValues(alpha: 0.7)
                                        : AppColors.textTertiary,
                                  ),
                                ),
                                if (isMe) ...[
                                  SizedBox(width: 4.w),
                                  Icon(
                                    message.status == MessageStatus.read
                                        ? Icons.done_all_rounded
                                        : message.status ==
                                              MessageStatus.delivered
                                        ? Icons.done_all_rounded
                                        : Icons.done_rounded,
                                    size: 14.sp,
                                    color: message.status == MessageStatus.read
                                        ? Colors.lightBlueAccent
                                        : Colors.white.withValues(alpha: 0.7),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isMe) SizedBox(width: 8.w),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(
          duration: 300.ms,
          delay: Duration(milliseconds: 50 * (index % 5)),
        )
        .slideX(begin: isMe ? 0.1 : -0.1, curve: Curves.easeOut);
  }

  void _showMessageOptions(MessageModel message) {
    final isMe = message.senderId == currentUser!.uid;
    final viewModel = ref.read(
      chatDetailViewModelProvider(widget.chatId, currentUser!.uid).notifier,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            _buildOptionItem(
              Icons.reply_rounded,
              AppLocalizations.of(context).reply,
              () {
                context.pop();
                viewModel.setReplyTo(message);
                _focusNode.requestFocus();
              },
            ),
            _buildOptionItem(
              Icons.copy_rounded,
              AppLocalizations.of(context).copy,
              () {
                context.pop();
                Clipboard.setData(ClipboardData(text: message.content));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context).messageCopied),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            if (isMe && !message.isDeleted) ...[
              _buildOptionItem(
                Icons.edit_rounded,
                AppLocalizations.of(context).actionEdit,
                () {
                  context.pop();
                  _showEditDialog(message);
                },
              ),
              _buildOptionItem(
                Icons.delete_outline_rounded,
                AppLocalizations.of(context).actionDelete,
                () {
                  context.pop();
                  viewModel.deleteMessage(message.id);
                },
                isDestructive: true,
              ),
            ],
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(MessageModel message) {
    final controller = TextEditingController(text: message.content);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(AppLocalizations.of(context).editMessage),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: null,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          ElevatedButton(
            onPressed: () {
              final viewModel = ref.read(
                chatDetailViewModelProvider(
                  widget.chatId,
                  currentUser!.uid,
                ).notifier,
              );
              viewModel.editMessage(message.id, controller.text);
              context.pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(
              AppLocalizations.of(context).actionSave,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.cardBg,
            AppColors.primarySurface.withOpacity(0.3),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: AppColors.primary.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Attachment button
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _showAttachmentOptions();
              },
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accentLight.withOpacity(0.2),
                      AppColors.accent.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: AppColors.accent.withOpacity(0.3),
                  ),
                ),
                child: Icon(
                  Icons.attach_file_rounded,
                  color: AppColors.primary,
                  size: 22.sp,
                ),
              ),
            ).animate(onPlay: (c) => c.repeat())
                .shimmer(duration: 2000.ms, delay: 3000.ms),

            SizedBox(width: 10.w),

            // Text input
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(
                    color: _focusNode.hasFocus
                        ? AppColors.primary
                        : AppColors.border.withOpacity(0.5),
                    width: _focusNode.hasFocus ? 2 : 1,
                  ),
                  boxShadow: _focusNode.hasFocus
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        focusNode: _focusNode,
                        onTap: () => setState(() => _showEmojiPicker = false),
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context).typeAMessage,
                          hintStyle: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                        maxLines: 5,
                        minLines: 1,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: _toggleEmojiPicker,
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: _showEmojiPicker
                              ? AppColors.primary.withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          _showEmojiPicker
                              ? Icons.keyboard_rounded
                              : Icons.emoji_emotions_rounded,
                          color: _showEmojiPicker
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          size: 22.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(width: 8.w),

            // Send button (or mic for voice recording)
            GestureDetector(
              onTap: () {
                if (_messageController.text.trim().isNotEmpty) {
                  _sendMessage();
                } else if (_isRecording) {
                  _stopRecording();
                } else {
                  _startRecording();
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  gradient: _isRecording 
                      ? const LinearGradient(
                          colors: [Color(0xFFE91E63), Color(0xFFF44336)],
                        )
                      : AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: (_isRecording 
                          ? const Color(0xFFE91E63) 
                          : AppColors.primary).withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _isRecording
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.mic_rounded,
                            color: Colors.white,
                            size: 22.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            '${_recordingDuration.inMinutes}:${(_recordingDuration.inSeconds % 60).toString().padLeft(2, '0')}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Icon(
                        _messageController.text.trim().isNotEmpty
                            ? Icons.send_rounded
                            : Icons.mic_rounded,
                        color: Colors.white,
                        size: 22.sp,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  Icons.camera_alt_rounded,
                  AppLocalizations.of(context).camera,
                  const Color(0xFFE91E63),
                  () async {
                    context.pop();
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(
                      source: ImageSource.camera,
                    );
                    if (pickedFile != null) {
                      // Handle camera image
                    }
                  },
                ),
                _buildAttachmentOption(
                  Icons.photo_rounded,
                  AppLocalizations.of(context).gallery,
                  const Color(0xFF9C27B0),
                  () {
                    context.pop();
                    _sendImage();
                  },
                ),
                _buildAttachmentOption(
                  Icons.insert_drive_file_rounded,
                  AppLocalizations.of(context).document,
                  const Color(0xFF2196F3),
                  () => context.pop(),
                ),
                _buildAttachmentOption(
                  Icons.location_on_rounded,
                  AppLocalizations.of(context).location,
                  const Color(0xFF4CAF50),
                  () {
                    context.pop();
                    _shareLocation();
                  },
                ),
              ],
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(icon, color: color, size: 28.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Share current location as a message
  Future<void> _shareLocation() async {
    HapticFeedback.mediumImpact();

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 16.h),
              Text(
                AppLocalizations.of(context).gettingYourLocation,
                style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      // Check and request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) Navigator.of(context).pop();
          _showLocationError('Location permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) Navigator.of(context).pop();
        _showLocationError(
          'Location permission permanently denied. Please enable in settings.',
        );
        return;
      }

      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) Navigator.of(context).pop();
        _showLocationError('Please enable location services');
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Try to get address from coordinates
      String locationName = 'My Location';
      try {
        final placemarks = await geocoding.placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          locationName = [
            place.street,
            place.locality,
            place.country,
          ].where((s) => s != null && s.isNotEmpty).join(', ');
        }
      } catch (_) {
        // Failed to get address, use coordinates
        locationName =
            '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      }

      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      // Send location message
      final viewModel = ref.read(
        chatDetailViewModelProvider(
          widget.chatId,
          currentUser?.uid ?? '',
        ).notifier,
      );

      final success = await viewModel.sendMessage(
        content: '📍 $locationName',
        senderName: currentUser?.displayName ?? 'User',
        senderPhotoUrl: currentUser?.photoUrl,
        type: MessageType.location,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (success && mounted) {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8.w),
                Text(AppLocalizations.of(context).locationShared),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        _showLocationError('Failed to get location: ${e.toString()}');
      }
    }
  }

  void _showLocationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            SizedBox(width: 8.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Settings',
          textColor: Colors.white,
          onPressed: () => Geolocator.openLocationSettings(),
        ),
      ),
    );
  }

  /// Opens location in external maps app (Google Maps, Apple Maps, etc.)
  Future<void> _openLocationInMaps(double lat, double lng, String label) async {
    HapticFeedback.lightImpact();

    // Encode label for URL
    final encodedLabel = Uri.encodeComponent(label.replaceFirst('📍 ', ''));

    // Build URLs for different platforms
    // Google Maps URL (works on Android and iOS if Google Maps is installed)
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );

    // Apple Maps URL (iOS only)
    final appleMapsUrl = Uri.parse(
      'https://maps.apple.com/?ll=$lat,$lng&q=$encodedLabel',
    );

    // Geo URI (universal, opens default maps app)
    final geoUrl = Uri.parse('geo:$lat,$lng?q=$lat,$lng($encodedLabel)');

    try {
      // Try different URL schemes based on platform
      bool launched = false;

      // First, try the geo URI on Android (opens default maps app)
      if (Platform.isAndroid) {
        if (await canLaunchUrl(geoUrl)) {
          launched = await launchUrl(geoUrl);
        }
        // Fallback to Google Maps
        if (!launched && await canLaunchUrl(googleMapsUrl)) {
          launched = await launchUrl(
            googleMapsUrl,
            mode: LaunchMode.externalApplication,
          );
        }
      }
      // On iOS, try Apple Maps first
      else if (Platform.isIOS) {
        if (await canLaunchUrl(appleMapsUrl)) {
          launched = await launchUrl(
            appleMapsUrl,
            mode: LaunchMode.externalApplication,
          );
        }
        // Fallback to Google Maps web
        if (!launched && await canLaunchUrl(googleMapsUrl)) {
          launched = await launchUrl(
            googleMapsUrl,
            mode: LaunchMode.externalApplication,
          );
        }
      }
      // Web or other platforms - use Google Maps
      else {
        if (await canLaunchUrl(googleMapsUrl)) {
          launched = await launchUrl(
            googleMapsUrl,
            mode: LaunchMode.externalApplication,
          );
        }
      }

      if (!launched && mounted) {
        // Copy coordinates as fallback
        Clipboard.setData(ClipboardData(text: '$lat, $lng'));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.content_copy, color: Colors.white, size: 20),
                SizedBox(width: 8.w),
                Text(AppLocalizations.of(context).coordinatesCopiedToClipboard),
              ],
            ),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).couldNotOpenMapsValue(e),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _startVoiceRecording() {
    HapticFeedback.heavyImpact();
    setState(() => _isRecording = true);

    // Show voice recording indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(AppLocalizations.of(context).recordingReleaseToSend),
            ),
            Text(
              AppLocalizations.of(context).voiceNote,
              style: TextStyle(color: Colors.white70, fontSize: 12.sp),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        duration: const Duration(minutes: 1),
      ),
    );
  }
}

/// Audio message player widget
class _AudioMessagePlayer extends StatefulWidget {
  final String audioUrl;
  final bool isMe;

  const _AudioMessagePlayer({
    required this.audioUrl,
    required this.isMe,
  });

  @override
  State<_AudioMessagePlayer> createState() => _AudioMessagePlayerState();
}

class _AudioMessagePlayerState extends State<_AudioMessagePlayer> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  void _initPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _duration = duration;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _position = Duration.zero;
          _isPlaying = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(UrlSource(widget.audioUrl));
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Play/pause button
          GestureDetector(
            onTap: _togglePlayPause,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: widget.isMe
                    ? Colors.white.withValues(alpha: 0.2)
                    : AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: widget.isMe ? Colors.white : AppColors.primary,
                size: 20.sp,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          // Waveform/progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 3.h,
                  decoration: BoxDecoration(
                    color: widget.isMe
                        ? Colors.white.withValues(alpha: 0.3)
                        : AppColors.divider,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _duration.inMilliseconds > 0
                        ? _position.inMilliseconds / _duration.inMilliseconds
                        : 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: widget.isMe ? Colors.white : AppColors.primary,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _duration.inMilliseconds > 0
                      ? _formatDuration(_position)
                      : '0:00',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: widget.isMe
                        ? Colors.white.withValues(alpha: 0.7)
                        : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          // Duration
          Text(
            _duration.inMilliseconds > 0
                ? _formatDuration(_duration)
                : '0:00',
            style: TextStyle(
              fontSize: 12.sp,
              color: widget.isMe
                  ? Colors.white.withValues(alpha: 0.7)
                  : AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
