import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sport_connect/core/services/firebase_service.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/premium_avatar.dart';
import 'package:sport_connect/features/messaging/models/call_model.dart';
import 'package:sport_connect/features/messaging/models/message_model.dart';
import 'package:sport_connect/features/messaging/repositories/call_repository.dart';
import 'package:sport_connect/features/messaging/repositories/chat_repository.dart';
import 'package:sport_connect/features/messaging/view_models/chat_view_model.dart';
import 'package:sport_connect/features/messaging/views/voice_call_screen.dart';
import 'package:sport_connect/features/messaging/views/video_call_screen.dart';
import 'dart:io';

/// Chat Detail Screen with real-time Firestore messaging
class ChatDetailScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String receiverId;
  final String receiverName;
  final String? receiverPhotoUrl;
  final bool isGroup;

  const ChatDetailScreen({
    super.key,
    required this.chatId,
    required this.receiverId,
    required this.receiverName,
    this.receiverPhotoUrl,
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
  bool _showEmojiPicker = false;
  bool _isRecording = false;
  Timer? _typingTimer;
  bool _isTyping = false;

  String get _currentUserId => FirebaseService.currentUser?.uid ?? '';
  String get _currentUserName =>
      FirebaseService.currentUser?.displayName ?? 'User';
  String? get _currentUserPhoto => FirebaseService.currentUser?.photoURL;

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
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more messages when near the end
      final viewModel = ref.read(
        chatDetailViewModelProvider(widget.chatId, _currentUserId).notifier,
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
      chatDetailViewModelProvider(widget.chatId, _currentUserId).notifier,
    );
    viewModel.setTyping(isTyping, _currentUserName);
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
      chatDetailViewModelProvider(widget.chatId, _currentUserId).notifier,
    );

    final state = ref.read(
      chatDetailViewModelProvider(widget.chatId, _currentUserId),
    );

    await viewModel.sendMessage(
      content: text,
      senderName: _currentUserName,
      senderPhotoUrl: _currentUserPhoto,
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
            const Text('Sending image...'),
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
      final chatRepo = ref.read(chatRepositoryProvider);
      final imageUrl = await chatRepo.uploadChatImage(
        chatId: widget.chatId,
        imageFile: file,
        fileName: fileName,
      );

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Send image message
      final viewModel = ref.read(
        chatDetailViewModelProvider(widget.chatId, _currentUserId).notifier,
      );

      await viewModel.sendMessage(
        content: '📷 Photo',
        senderName: _currentUserName,
        senderPhotoUrl: _currentUserPhoto,
        type: MessageType.image,
        imageUrl: imageUrl,
      );

      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send image: $e'),
          backgroundColor: AppColors.error,
        ),
      );
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

  Future<void> _startVoiceCall() async {
    HapticFeedback.mediumImpact();

    try {
      // Create call in Firestore
      final callRepository = ref.read(callRepositoryProvider);
      final call = await callRepository.createCall(
        chatId: widget.chatId,
        type: CallType.voice,
        callerId: _currentUserId,
        callerName: _currentUserName,
        callerPhotoUrl: _currentUserPhoto,
        calleeId: widget.receiverId,
        calleeName: widget.receiverName,
        calleePhotoUrl: widget.receiverPhotoUrl,
      );

      // Navigate to voice call screen
      context.pushNamed(
        'voice-call',
        queryParameters: {
          'callId': call.id,
          'chatId': widget.chatId,
          'receiverId': widget.receiverId,
          'name': widget.receiverName,
          // Only add photoUrl if it's not null
          if (widget.receiverPhotoUrl != null)
            'photoUrl': widget.receiverPhotoUrl!,
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start call: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _startVideoCall() async {
    HapticFeedback.mediumImpact();

    try {
      // Create call in Firestore
      final callRepository = ref.read(callRepositoryProvider);
      final call = await callRepository.createCall(
        chatId: widget.chatId,
        type: CallType.video,
        callerId: _currentUserId,
        callerName: _currentUserName,
        callerPhotoUrl: _currentUserPhoto,
        calleeId: widget.receiverId,
        calleeName: widget.receiverName,
        calleePhotoUrl: widget.receiverPhotoUrl,
      );

      // Navigate to video call screen
      context.pushNamed(
        'video-call',
        queryParameters: {
          'callId': call.id,
          'chatId': widget.chatId,
          'receiverId': widget.receiverId,
          'name': widget.receiverName,
          if (widget.receiverPhotoUrl != null)
            'photoUrl': widget.receiverPhotoUrl!,
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start video call: $e'),
          backgroundColor: AppColors.error,
        ),
      );
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
            _buildOptionItem(Icons.person_outline_rounded, 'View Profile', () {
              context.pop();
            }),
            _buildOptionItem(Icons.search_rounded, 'Search in Chat', () {
              context.pop();
            }),
            _buildOptionItem(
              Icons.notifications_off_outlined,
              'Mute Notifications',
              () {
                context.pop();
                _muteChat();
              },
            ),
            _buildOptionItem(Icons.delete_outline_rounded, 'Clear Chat', () {
              context.pop();
              _confirmClearChat();
            }, isDestructive: true),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  void _muteChat() async {
    final chatRepository = ref.read(chatRepositoryProvider);
    await chatRepository.toggleMute(
      chatId: widget.chatId,
      odid: _currentUserId,
      mute: true,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notifications muted for this chat'),
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
        title: const Text('Clear Chat'),
        content: const Text(
          'Are you sure you want to delete all messages? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Chat cleared'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Clear', style: TextStyle(color: Colors.white)),
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
      chatDetailViewModelProvider(widget.chatId, _currentUserId),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(chatState),
      body: Column(
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
                onEmojiSelected: (category, emoji) {},
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 40.sp,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Send a message to start the conversation',
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
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
        final isMe = message.senderId == _currentUserId;
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
      backgroundColor: AppColors.cardBg,
      elevation: 0,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20.sp,
          color: AppColors.textPrimary,
        ),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Stack(
            children: [
              widget.receiverPhotoUrl != null
                  ? CircleAvatar(
                      radius: 20.r,
                      backgroundImage: NetworkImage(widget.receiverPhotoUrl!),
                    )
                  : PremiumAvatar(name: widget.receiverName, size: 40),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.cardBg, width: 2),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.receiverName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  chatState.typingUsers.isNotEmpty ? 'typing...' : 'Online',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: chatState.typingUsers.isNotEmpty
                        ? AppColors.primary
                        : AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _startVoiceCall,
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.phone_outlined,
              color: AppColors.primary,
              size: 20.sp,
            ),
          ),
        ),
        IconButton(
          onPressed: _startVideoCall,
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.videocam_outlined,
              color: AppColors.primary,
              size: 22.sp,
            ),
          ),
        ),
        IconButton(
          onPressed: _showOptionsSheet,
          icon: Icon(
            Icons.more_vert_rounded,
            color: AppColors.textSecondary,
            size: 22.sp,
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
          PremiumAvatar(name: widget.receiverName, size: 28),
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
            color: AppColors.textTertiary.withOpacity(0.5 + (value * 0.5)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildReplyPreview(MessageModel message) {
    final viewModel = ref.read(
      chatDetailViewModelProvider(widget.chatId, _currentUserId).notifier,
    );

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withOpacity(0.5),
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
                  'Replying to ${message.senderName}',
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
                            color: AppColors.surfaceVariant.withOpacity(0.3),
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
                                    AppColors.primary.withOpacity(0.9),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: isMe
                              ? null
                              : AppColors.surfaceVariant.withOpacity(0.7),
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
                                  ? AppColors.primary.withOpacity(0.2)
                                  : Colors.black.withOpacity(0.05),
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
                            else
                              Text(
                                message.isDeleted
                                    ? 'This message was deleted'
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
                                      'edited',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: isMe
                                            ? Colors.white.withOpacity(0.6)
                                            : AppColors.textTertiary,
                                      ),
                                    ),
                                  ),
                                Text(
                                  _formatTime(message.createdAt),
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: isMe
                                        ? Colors.white.withOpacity(0.7)
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
                                        : Colors.white.withOpacity(0.7),
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
    final isMe = message.senderId == _currentUserId;
    final viewModel = ref.read(
      chatDetailViewModelProvider(widget.chatId, _currentUserId).notifier,
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
            _buildOptionItem(Icons.reply_rounded, 'Reply', () {
              context.pop();
              viewModel.setReplyTo(message);
              _focusNode.requestFocus();
            }),
            _buildOptionItem(Icons.copy_rounded, 'Copy', () {
              context.pop();
              Clipboard.setData(ClipboardData(text: message.content));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Message copied'),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }),
            if (isMe && !message.isDeleted) ...[
              _buildOptionItem(Icons.edit_rounded, 'Edit', () {
                context.pop();
                _showEditDialog(message);
              }),
              _buildOptionItem(Icons.delete_outline_rounded, 'Delete', () {
                context.pop();
                viewModel.deleteMessage(message.id);
              }, isDestructive: true),
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
        title: const Text('Edit Message'),
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
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final viewModel = ref.read(
                chatDetailViewModelProvider(
                  widget.chatId,
                  _currentUserId,
                ).notifier,
              );
              viewModel.editMessage(message.id, controller.text);
              context.pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
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
        color: AppColors.cardBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Attachment button
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _showAttachmentOptions();
              },
              child: Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.add_rounded,
                  color: AppColors.textSecondary,
                  size: 22.sp,
                ),
              ),
            ),

            SizedBox(width: 8.w),

            // Text input
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(
                    color: _focusNode.hasFocus
                        ? AppColors.primary.withOpacity(0.3)
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        focusNode: _focusNode,
                        onTap: () => setState(() => _showEmojiPicker = false),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 15.sp,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 4,
                        minLines: 1,
                      ),
                    ),
                    GestureDetector(
                      onTap: _toggleEmojiPicker,
                      child: Icon(
                        _showEmojiPicker
                            ? Icons.keyboard_rounded
                            : Icons.emoji_emotions_outlined,
                        color: _showEmojiPicker
                            ? AppColors.primary
                            : AppColors.textTertiary,
                        size: 22.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(width: 8.w),

            // Send button
            GestureDetector(
              onTap: _messageController.text.trim().isNotEmpty
                  ? _sendMessage
                  : _startVoiceRecording,
              onLongPress: _startVoiceRecording,
              onLongPressEnd: (_) => _stopVoiceRecording(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  gradient: _isRecording
                      ? LinearGradient(
                          colors: [
                            AppColors.error,
                            AppColors.error.withOpacity(0.8),
                          ],
                        )
                      : AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: _isRecording
                          ? AppColors.error.withOpacity(0.3)
                          : AppColors.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  _messageController.text.trim().isNotEmpty
                      ? Icons.send_rounded
                      : (_isRecording ? Icons.stop_rounded : Icons.mic_rounded),
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
                  'Camera',
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
                  'Gallery',
                  const Color(0xFF9C27B0),
                  () {
                    context.pop();
                    _sendImage();
                  },
                ),
                _buildAttachmentOption(
                  Icons.insert_drive_file_rounded,
                  'Document',
                  const Color(0xFF2196F3),
                  () => context.pop(),
                ),
                _buildAttachmentOption(
                  Icons.location_on_rounded,
                  'Location',
                  const Color(0xFF4CAF50),
                  () => context.pop(),
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
              color: color.withOpacity(0.15),
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

  void _startVoiceRecording() {
    HapticFeedback.heavyImpact();
    setState(() => _isRecording = true);
  }

  void _stopVoiceRecording() {
    if (_isRecording) {
      HapticFeedback.mediumImpact();
      setState(() => _isRecording = false);
    }
  }
}
