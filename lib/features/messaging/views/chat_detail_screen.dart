import 'dart:async';
import 'dart:io';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/services/location_service.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/platform_adaptive.dart';
import 'package:sport_connect/core/widgets/app_modal_sheet.dart';
import 'package:sport_connect/core/widgets/permission_dialog_helper.dart';
import 'package:sport_connect/core/widgets/premium_avatar.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/messaging/models/message_model.dart';
import 'package:sport_connect/features/messaging/view_models/chat_view_model.dart';
import 'package:sport_connect/features/messaging/widgets/flyer_chat_preview_sheet.dart';
import 'package:sport_connect/core/widgets/skeleton_loader.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:v_chat_voice_player/v_chat_voice_player.dart';
import 'package:v_platform/v_platform.dart';

/// Chat Detail Screen with real-time Firestore messaging.
class ChatDetailScreen extends ConsumerStatefulWidget {
  const ChatDetailScreen({
    required this.chatId,
    required this.receiver,
    super.key,
    this.isGroup = false,
  });

  final String chatId;
  final UserModel receiver;
  final bool isGroup;

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final AudioRecorder _audioRecorder = AudioRecorder();

  Timer? _recordingTimer;
  late String _activeChatId;
  late UserModel _resolvedReceiver;
  bool _isResolvingReceiver = false;

  // ── Convenience getters ──────────────────────────────────────────────────

  UserModel? get currentUser => ref.read(currentUserProvider).value;
  String get _chatId => _activeChatId;
  bool get _isDraftChat => isDraftChatId(_activeChatId);
  UserModel get _receiver => _resolvedReceiver;

  // ── Snack-bar helpers ────────────────────────────────────────────────────

  void _showStatusSnackBar(
    String message, {
    AdaptiveSnackBarType type = AdaptiveSnackBarType.info,
    Duration duration = const Duration(seconds: 4),
    String? action,
    VoidCallback? onActionPressed,
  }) {
    if (!mounted) return;
    AdaptiveSnackBar.show(
      context,
      message: message,
      type: type,
      duration: duration,
      action: action,
      onActionPressed: onActionPressed,
    );
  }

  void _showSendingSnackBar(String message) {
    _showStatusSnackBar(
      message,
      type: AdaptiveSnackBarType.info,
      duration: const Duration(seconds: 30),
    );
  }

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _activeChatId = widget.chatId;
    _resolvedReceiver = widget.receiver;
    _scrollController.addListener(_onScroll);
    _messageController.addListener(_onTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resolveReceiverIfNeeded();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _recordingTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  // ── Scroll / text listeners ──────────────────────────────────────────────

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref
          .read(
            chatDetailViewModelProvider(
              _chatId,
              currentUser?.uid ?? '',
            ).notifier,
          )
          .loadMoreMessages();
    }
  }

  void _onTextChanged() {
    ref
        .read(
          chatDetailViewModelProvider(_chatId, currentUser?.uid ?? '').notifier,
        )
        .handleComposerTextChanged(
          _messageController.text,
          currentUser?.username ?? 'User',
        );
  }

  // ── Chat persistence ─────────────────────────────────────────────────────

  Future<bool> _ensurePersistedChat() async {
    if (!_isDraftChat) return true;
    final user = currentUser;
    if (user == null) return false;
    if (_receiver.uid.isEmpty) return false;

    try {
      final chat = await ref
          .read(chatActionsViewModelProvider.notifier)
          .getOrCreatePrivateChat(
            userId1: user.uid,
            userId2: _receiver.uid,
            userName1: user.username,
            userName2: _receiver.username,
            userPhoto1: user.photoUrl,
            userPhoto2: _receiver.photoUrl,
          );
      if (!mounted) return false;
      setState(() => _activeChatId = chat.id);
      ref.invalidate(userChatsProvider(user.uid));
      return true;
    } on Exception {
      if (!mounted) return false;
      AdaptiveSnackBar.show(
        context,
        message: AppLocalizations.of(context).failedToCreateChatTryAgain,
        type: AdaptiveSnackBarType.error,
      );
      return false;
    }
  }

  Future<void> _resolveReceiverIfNeeded() async {
    if (_isResolvingReceiver || widget.isGroup) return;
    if (_receiver.uid.isNotEmpty || _isDraftChat) return;
    final user = currentUser;
    if (user == null) return;

    _isResolvingReceiver = true;
    try {
      final chat = await ref
          .read(chatActionsViewModelProvider.notifier)
          .getChatById(_chatId);
      if (!mounted || chat == null) return;
      final other = chat.getOtherParticipant(user.uid);
      final fallbackId = chat.participantIds.firstWhere(
        (id) => id != user.uid,
        orElse: () => '',
      );
      final resolvedUid = other?.userId ?? fallbackId;
      if (resolvedUid.isEmpty) return;
      setState(() {
        _resolvedReceiver = UserModel.rider(
          uid: resolvedUid,
          email: '',
          username: other?.username ?? _receiver.username,
          photoUrl: other?.photoUrl ?? _receiver.photoUrl,
        );
      });
    } finally {
      _isResolvingReceiver = false;
    }
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

  // ── Send operations ──────────────────────────────────────────────────────

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    if (!await _ensurePersistedChat()) return;
    if (!mounted) return;

    HapticFeedback.lightImpact();
    _messageController.clear();

    final notifier = ref.read(
      chatDetailViewModelProvider(_chatId, currentUser?.uid ?? '').notifier,
    );
    final chatState = ref.read(
      chatDetailViewModelProvider(_chatId, currentUser?.uid ?? ''),
    );

    notifier.setEmojiPickerVisible(false);

    await notifier.sendMessage(
      content: text,
      senderName: currentUser?.username ?? 'User',
      senderPhotoUrl: currentUser?.photoUrl,
      replyToMessageId: chatState.replyToMessage?.id,
      replyToContent: chatState.replyToMessage?.content,
    );

    if (!mounted) return;
    notifier.clearReply();
    _scrollToBottom();
  }

  // FIX: Unified — replaces duplicated _sendImage + _sendImageFromCamera.
  Future<void> _sendImageFromSource(ImageSource source) async {
    final l10n = AppLocalizations.of(context);
    final customMessage = source == ImageSource.gallery
        ? 'Access to your photo library is needed to send images in this chat. '
              'Your photos are only shared when you choose to send them.'
        : 'Camera access is needed to take and send photos in this chat.';

    final accepted = await PermissionDialogHelper.showCameraRationale(
      context,
      customMessage: customMessage,
    );
    if (!accepted) return;

    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile == null) return;
    if (!await _ensurePersistedChat()) return;

    HapticFeedback.lightImpact();
    if (!context.mounted) return;
    _showSendingSnackBar(l10n.sendingImage);

    try {
      final notifier = ref.read(
        chatDetailViewModelProvider(_chatId, currentUser?.uid ?? '').notifier,
      );
      final success = await notifier.sendImageMessage(
        imageFile: File(pickedFile.path),
        fileName: '${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}',
        senderName: currentUser?.username ?? 'User',
        senderPhotoUrl: currentUser?.photoUrl,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (!success) {
        final error =
            ref
                .read(
                  chatDetailViewModelProvider(_chatId, currentUser?.uid ?? ''),
                )
                .error ??
            'Failed to send image';
        _showStatusSnackBar(
          l10n.failedToSendImageValue(error),
          type: AdaptiveSnackBarType.error,
        );
        return;
      }
      _scrollToBottom();
    } catch (e, st) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _showStatusSnackBar(
        l10n.failedToSendImageValue(e),
        type: AdaptiveSnackBarType.error,
      );
    }
  }

  // ── Recording ────────────────────────────────────────────────────────────

  Future<void> _startRecording() async {
    try {
      final accepted = await PermissionDialogHelper.showMicrophoneRationale(
        context,
      );
      if (!accepted) return;

      if (!await _audioRecorder.hasPermission()) return;

      final directory = await getTemporaryDirectory();
      final path =
          '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

      // FIX: Specify encoder explicitly for reliability across platforms.
      await _audioRecorder.start(
        const RecordConfig(),
        path: path,
      );

      ref
          .read(
            chatDetailViewModelProvider(
              _chatId,
              currentUser?.uid ?? '',
            ).notifier,
          )
          .beginRecording(path);

      _recordingTimer = Timer.periodic(const Duration(milliseconds: 100), (
        timer,
      ) {
        if (!mounted) return;
        ref
            .read(
              chatDetailViewModelProvider(
                _chatId,
                currentUser?.uid ?? '',
              ).notifier,
            )
            .updateRecordingDuration(Duration(milliseconds: timer.tick * 100));
      });

      HapticFeedback.mediumImpact();
    } on Exception {
      if (!mounted) return;
      AdaptiveSnackBar.show(
        context,
        message: AppLocalizations.of(context).recordingFailedError,
        type: AdaptiveSnackBarType.error,
      );
    }
  }

  Future<void> _stopRecording() async {
    final notifier = ref.read(
      chatDetailViewModelProvider(_chatId, currentUser?.uid ?? '').notifier,
    );
    try {
      final path = await _audioRecorder.stop();
      _recordingTimer?.cancel();
      if (path != null && mounted) {
        await _sendAudioMessage(path);
      }
      notifier.clearRecording();
      HapticFeedback.mediumImpact();
    } on Exception {
      notifier.clearRecording();
      if (!mounted) return;
      _showStatusSnackBar(
        AppLocalizations.of(context).stopRecordingFailedError,
        type: AdaptiveSnackBarType.error,
      );
    }
  }

  Future<void> _cancelRecording() async {
    try {
      await _audioRecorder.stop();
      _recordingTimer?.cancel();
      final recordingPath = ref
          .read(chatDetailViewModelProvider(_chatId, currentUser?.uid ?? ''))
          .recordingPath;
      if (recordingPath != null) {
        final file = File(recordingPath);
        if (await file.exists()) await file.delete();
      }
      ref
          .read(
            chatDetailViewModelProvider(
              _chatId,
              currentUser?.uid ?? '',
            ).notifier,
          )
          .clearRecording();
      HapticFeedback.lightImpact();
    } on Exception {
      // Silently discard — user-initiated cancel, nothing to recover.
    }
  }

  Future<void> _sendAudioMessage(String audioPath) async {
    if (!await _ensurePersistedChat()) return;
    HapticFeedback.lightImpact();
    if (!mounted) return;
    _showSendingSnackBar(AppLocalizations.of(context).sendingVoiceMessage);

    try {
      final file = File(audioPath);
      final notifier = ref.read(
        chatDetailViewModelProvider(_chatId, currentUser?.uid ?? '').notifier,
      );
      final duration = ref
          .read(chatDetailViewModelProvider(_chatId, currentUser?.uid ?? ''))
          .recordingDuration;
      final durationText =
          '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';

      final success = await notifier.sendAudioMessage(
        audioFile: file,
        fileName: 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a',
        durationText: durationText,
        senderName: currentUser?.username ?? 'User',
        senderPhotoUrl: currentUser?.photoUrl,
      );

      if (await file.exists()) await file.delete();

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (!success) {
        throw Exception(
          ref
                  .read(
                    chatDetailViewModelProvider(
                      _chatId,
                      currentUser?.uid ?? '',
                    ),
                  )
                  .error ??
              'Failed to send voice message',
        );
      }
      _scrollToBottom();
    } catch (e, st) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      final errorText =
          e.toString().contains('permission') || e.toString().contains('403')
          ? 'Permission denied. Please check your connection and try again.'
          : e.toString().contains('network')
          ? 'Network error. Please check your internet connection.'
          : 'Failed to send voice message';

      _showStatusSnackBar(
        errorText,
        type: AdaptiveSnackBarType.error,
        action: 'RETRY',
        onActionPressed: () => _sendAudioMessage(audioPath),
      );
    }
  }

  // ── Emoji picker ─────────────────────────────────────────────────────────

  void _toggleEmojiPicker() {
    final showing = ref
        .read(chatDetailViewModelProvider(_chatId, currentUser?.uid ?? ''))
        .showEmojiPicker;
    final notifier = ref.read(
      chatDetailViewModelProvider(_chatId, currentUser?.uid ?? '').notifier,
    );

    if (showing) {
      notifier.setEmojiPickerVisible(false);
      _focusNode.requestFocus();
    } else {
      _focusNode.unfocus();
      notifier.setEmojiPickerVisible(true);
    }
  }

  // ── Options sheets ───────────────────────────────────────────────────────

  void _showOptionsSheet({required bool isReceiverBlocked}) {
    final l10n = AppLocalizations.of(context);

    void onViewProfile() {
      final receiverId = _receiver.uid;
      if (receiverId.isEmpty) {
        AdaptiveSnackBar.show(
          context,
          message: l10n.failedToLoadChats,
          type: AdaptiveSnackBarType.error,
        );
        return;
      }
      context.push(
        AppRoutes.driverProfile.path.replaceFirst(':id', receiverId),
        extra: _receiver,
      );
    }

    void onOpenFlyerPreview() {
      final user = currentUser;
      if (user == null) return;
      final state = ref.read(
        chatDetailViewModelProvider(_chatId, user.uid),
      );
      FlyerChatPreviewSheet.show(
        context: context,
        messages: state.messages,
        currentUser: user,
        receiver: _receiver,
      );
    }

    AppModalSheet.showActions<void>(
      context: context,
      title: 'Chat options',
      maxHeightFactor: 0.78,
      actions: [
        AppModalAction(
          icon: Icons.person_outline_rounded,
          title: l10n.viewProfile,
          onTap: onViewProfile,
        ),
        AppModalAction(
          icon: Icons.forum_outlined,
          title: 'Chat preview',
          onTap: onOpenFlyerPreview,
        ),
        AppModalAction(
          icon: Icons.notifications_off_outlined,
          title: l10n.muteNotifications,
          onTap: () => unawaited(_muteChat()),
        ),
        AppModalAction(
          icon: Icons.flag_outlined,
          title: l10n.reportUser,
          onTap: _reportUser,
        ),
        AppModalAction(
          icon: isReceiverBlocked
              ? Icons.person_remove_outlined
              : Icons.block_rounded,
          title: isReceiverBlocked ? l10n.unblockUser : l10n.blockUser,
          isDestructive: !isReceiverBlocked,
          onTap: () {
            if (isReceiverBlocked) {
              _confirmUnblockUser();
            } else {
              _confirmBlockUser();
            }
          },
        ),
        AppModalAction(
          icon: Icons.delete_outline_rounded,
          title: l10n.clearChat,
          isDestructive: true,
          onTap: _confirmClearChat,
        ),
      ],
    );
  }

  void _reportUser() {
    context.push(
      AppRoutes.reportIssue.path,
      extra: {
        'reportedUserId': _receiver.uid,
        'reportedUserName': _receiver.username,
        'reportContext': 'chat',
        'chatId': _chatId,
      },
    );
  }

  void _confirmBlockUser() {
    if (_receiver.uid.isEmpty) {
      AdaptiveSnackBar.show(
        context,
        message: AppLocalizations.of(context).couldNotBlockUserTryAgain,
        type: AdaptiveSnackBarType.error,
      );
      return;
    }
    showDialog<void>(
      context: context,
      barrierLabel: AppLocalizations.of(context).blockUserDialogTitle,
      builder: (dialogContext) => AlertDialog.adaptive(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.dialogRadius),
        ),
        title: Text(AppLocalizations.of(context).blockUserDialogTitle),
        content: Text(
          AppLocalizations.of(
            context,
          ).blockUserDialogMessage(_receiver.username),
        ),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              dialogContext.pop();
              try {
                await ref
                    .read(chatActionsViewModelProvider.notifier)
                    .blockUser(
                      chatId: _isDraftChat ? null : _chatId,
                      userId: currentUser!.uid,
                      blockedUserId: _receiver.uid,
                    );
                if (!mounted) return;
                AdaptiveSnackBar.show(
                  context,
                  message: AppLocalizations.of(
                    context,
                  ).blockedUserSuccess(_receiver.username),
                  type: AdaptiveSnackBarType.success,
                );
                context.pop();
              } on Exception {
                if (!mounted) return;
                AdaptiveSnackBar.show(
                  context,
                  message: AppLocalizations.of(
                    context,
                  ).couldNotBlockUserTryAgain,
                  type: AdaptiveSnackBarType.error,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(
              AppLocalizations.of(context).actionBlock,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmUnblockUser() {
    if (_receiver.uid.isEmpty) {
      AdaptiveSnackBar.show(
        context,
        message: AppLocalizations.of(context).couldNotUnblockUserTryAgain,
        type: AdaptiveSnackBarType.error,
      );
      return;
    }
    showDialog<void>(
      context: context,
      barrierLabel: AppLocalizations.of(context).unblockUser,
      builder: (dialogContext) => AlertDialog.adaptive(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.dialogRadius),
        ),
        title: Text(AppLocalizations.of(context).unblockUser),
        content: Text(
          AppLocalizations.of(
            context,
          ).unblockUserDialogMessage(_receiver.username),
        ),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              dialogContext.pop();
              try {
                await ref
                    .read(chatActionsViewModelProvider.notifier)
                    .unblockUser(
                      chatId: _isDraftChat ? null : _chatId,
                      userId: currentUser!.uid,
                      blockedUserId: _receiver.uid,
                    );
                if (!mounted) return;
                AdaptiveSnackBar.show(
                  context,
                  message: AppLocalizations.of(context).userUnblocked,
                  type: AdaptiveSnackBarType.success,
                );
              } on Exception {
                if (!mounted) return;
                AdaptiveSnackBar.show(
                  context,
                  message: AppLocalizations.of(
                    context,
                  ).couldNotUnblockUserTryAgain,
                  type: AdaptiveSnackBarType.error,
                );
              }
            },
            child: Text(AppLocalizations.of(context).actionUnblock),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockedBanner() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.block_rounded, color: AppColors.warning, size: 18.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              AppLocalizations.of(context).youBlockedThisUser,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          TextButton(
            onPressed: _confirmUnblockUser,
            child: Text(AppLocalizations.of(context).actionUnblock),
          ),
        ],
      ),
    );
  }

  Future<void> _muteChat() async {
    await ref
        .read(chatActionsViewModelProvider.notifier)
        .toggleMute(
          chatId: _chatId,
          userId: currentUser!.uid,
          mute: true,
        );
    if (!mounted) return;
    AdaptiveSnackBar.show(
      context,
      message: AppLocalizations.of(context).notificationsMutedForThisChat,
      type: AdaptiveSnackBarType.info,
    );
  }

  void _confirmClearChat() {
    showDialog<void>(
      context: context,
      barrierLabel: AppLocalizations.of(context).clearChat,
      builder: (dialogContext) => AlertDialog.adaptive(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.dialogRadius),
        ),
        title: Text(AppLocalizations.of(context).clearChat),
        content: Text(AppLocalizations.of(context).areYouSureYouWant),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              dialogContext.pop();
              try {
                await ref
                    .read(chatActionsViewModelProvider.notifier)
                    .clearChat(
                      chatId: _chatId,
                      userId: currentUser!.uid,
                    );
                if (!mounted) return;
                AdaptiveSnackBar.show(
                  context,
                  message: AppLocalizations.of(context).chatCleared,
                  type: AdaptiveSnackBarType.success,
                );
              } on Exception {
                if (!mounted) return;
                AdaptiveSnackBar.show(
                  context,
                  message: AppLocalizations.of(
                    context,
                  ).couldNotClearChatTryAgain,
                  type: AdaptiveSnackBarType.error,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(
              AppLocalizations.of(context).clear,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ── Small reusable builders ──────────────────────────────────────────────

  // ── build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const AdaptiveScaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    if (_receiver.uid.isEmpty && !_isResolvingReceiver) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _resolveReceiverIfNeeded(),
      );
    }

    final chatState = ref.watch(
      chatDetailViewModelProvider(_chatId, currentUser!.uid),
    );
    final blockedIdsAsync = ref.watch(blockedUserIdsProvider(currentUser!.uid));
    final isReceiverBlocked =
        blockedIdsAsync.value?.contains(_receiver.uid) ?? false;

    // FIX: ref.listen in build is correct for ConsumerStatefulWidget —
    // Riverpod deduplicates it across rebuilds. Delegate read side-effect
    // to the notifier's markVisibleMessagesAsRead instead of doing it inline.
    ref.listen(
      chatDetailViewModelProvider(_chatId, currentUser!.uid),
      (prev, next) {
        if (next.messages.isNotEmpty &&
            (prev == null ||
                prev.messages.isEmpty ||
                prev.messages.first.id != next.messages.first.id)) {
          ref
              .read(
                chatDetailViewModelProvider(_chatId, currentUser!.uid).notifier,
              )
              .markVisibleMessagesAsRead();
        }
      },
    );

    return AdaptiveScaffold(
      appBar: _buildAppBar(chatState, isReceiverBlocked),
      body: Stack(
        children: [
          Column(
            children: [
              if (isReceiverBlocked) _buildBlockedBanner(),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _focusNode.unfocus();
                    ref
                        .read(
                          chatDetailViewModelProvider(
                            _chatId,
                            currentUser!.uid,
                          ).notifier,
                        )
                        .setEmojiPickerVisible(false);
                  },
                  child: chatState.isLoading
                      ? const SkeletonLoader(type: SkeletonType.chatTile, itemCount: 6)
                      : chatState.messages.isEmpty
                      ? _buildEmptyState()
                      : _buildMessagesList(chatState),
                ),
              ),
              if (chatState.typingUsers.isNotEmpty) _buildTypingIndicator(),
              if (chatState.replyToMessage != null)
                _buildReplyPreview(chatState.replyToMessage!),
              if (!isReceiverBlocked) _buildInputArea(),
              if (!isReceiverBlocked && chatState.showEmojiPicker)
                SizedBox(
                  height: 280.h,
                  child: EmojiPicker(
                    textEditingController: _messageController,
                    onEmojiSelected: (_, emoji) {
                      final text = _messageController.text;
                      final sel = _messageController.selection;
                      _messageController
                        ..text = text.replaceRange(
                          sel.start,
                          sel.end,
                          emoji.emoji,
                        )
                        ..selection = TextSelection.collapsed(
                          offset: sel.start + emoji.emoji.length,
                        );
                    },
                    onBackspacePressed: () {
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
                      emojiViewConfig: const EmojiViewConfig(
                        backgroundColor: AppColors.cardBg,
                        columns: 8,
                      ),
                      categoryViewConfig: const CategoryViewConfig(
                        backgroundColor: AppColors.cardBg,
                        indicatorColor: AppColors.primary,
                        iconColor: AppColors.textTertiary,
                        iconColorSelected: AppColors.primary,
                      ),
                      bottomActionBarConfig: const BottomActionBarConfig(
                        enabled: false,
                      ),
                      searchViewConfig: const SearchViewConfig(
                        backgroundColor: AppColors.cardBg,
                        buttonIconColor: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.2),
            ],
          ),
          if (chatState.isRecording) _buildRecordingBanner(chatState),
        ],
      ),
    );
  }

  // ── Screen sections ──────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84.w,
              height: 84.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 36.sp,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              AppLocalizations.of(context).noMessagesYet,
              style: TextStyle(
                fontSize: 19.sp,
                fontWeight: FontWeight.w700,
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
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList(ChatDetailState chatState) {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      reverse: true,
      itemCount: chatState.messages.length + (chatState.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (chatState.isLoadingMore && index == chatState.messages.length) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: const CircularProgressIndicator.adaptive(),
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

  AdaptiveAppBar _buildAppBar(
    ChatDetailState chatState,
    bool isReceiverBlocked,
  ) {
    // 1. Extract your custom leading button
    final customLeading = Container(
      margin: EdgeInsets.only(left: 8.w),
      child: IconButton(
        tooltip: AppLocalizations.of(context).goBackTooltip,
        onPressed: () => context.pop(),
        icon: Icon(
          Icons.adaptive.arrow_back_rounded,
          size: 18.sp,
          color: AppColors.textPrimary,
        ),
      ),
    );

    // 2. Extract your rich custom title (Avatar + Name + Status)
    final customTitle = Row(
      children: [
        if (_receiver.photoUrl != null)
          CircleAvatar(
            radius: 20.r,
            backgroundImage: NetworkImage(_receiver.photoUrl!),
          )
        else
          PremiumAvatar(name: _receiver.username, size: 40),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _receiver.username,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 6.w,
                    height: 6.w,
                    margin: EdgeInsets.only(right: 6.w),
                    decoration: BoxDecoration(
                      color: chatState.typingUsers.isNotEmpty
                          ? AppColors.success
                          : AppColors.textTertiary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Text(
                    chatState.typingUsers.isNotEmpty
                        ? AppLocalizations.of(context).typing
                        : AppLocalizations.of(context).offline,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    // 3. Extract your custom action button
    final customAction = Container(
      margin: EdgeInsets.only(right: 8.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: IconButton(
        tooltip: AppLocalizations.of(context).moreOptions,
        onPressed: () =>
            _showOptionsSheet(isReceiverBlocked: isReceiverBlocked),
        icon: Icon(
          Icons.adaptive.more_rounded,
          color: AppColors.textPrimary,
          size: 22.sp,
        ),
      ),
    );

    return AdaptiveAppBar(
      // --- NATIVE FALLBACK CONFIG ---
      // Used by iOS 26+ if useNativeToolbar is true.
      title: _receiver.username,
      leading: customLeading,
      useNativeToolbar:
          false, // Keep false to ensure your custom UI (Avatar/Status) renders on iOS
      actions: [
        // Note: Map params here based on your specific AdaptiveAppBarAction class structure
        AdaptiveAppBarAction(
          onPressed: () =>
              _showOptionsSheet(isReceiverBlocked: isReceiverBlocked),
          // Assuming it takes an icon or child:
          // icon: Icons.adaptive.more_rounded,
        ),
      ],

      // --- ANDROID ---
      // Wraps your exact original setup in a Material AppBar
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        leading: customLeading,
        titleSpacing: 0,
        title: customTitle,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.h),
          child: Divider(height: 1.h, thickness: 1, color: AppColors.border),
        ),
        actions: [customAction],
      ),

      // --- IOS (< 26 OR useNativeToolbar: false) ---
      // Translates your custom UI to Cupertino to prevent missing features on Apple devices
      cupertinoNavigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.surface,
        padding: EdgeInsetsDirectional.zero,
        leading: customLeading,
        middle: customTitle,
        trailing: customAction,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: 1.h,
          ),
        ),
      ),
    );
  }

  // FIX: Uses _TypingDot widget — properly loops via AnimationController.
  Widget _buildTypingIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          PremiumAvatar(name: _receiver.username, size: 28),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                const _TypingDot(index: 0),
                SizedBox(width: 4.w),
                const _TypingDot(index: 1),
                SizedBox(width: 4.w),
                const _TypingDot(index: 2),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 220.ms);
  }

  Widget _buildReplyPreview(MessageModel message) {
    final notifier = ref.read(
      chatDetailViewModelProvider(_chatId, currentUser!.uid).notifier,
    );
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12.r),
        border: const Border(
          left: BorderSide(color: AppColors.primary, width: 3),
        ),
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
            tooltip: AppLocalizations.of(context).clearReply,
            onPressed: notifier.clearReply,
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

  // FIX: Delegates message-type rendering to extracted widgets.
  // Each widget is self-contained and testable independently.
  Widget _buildMessageBubble(
    MessageModel message,
    bool isMe,
    bool showAvatar,
    int index,
  ) {
    return Semantics(
          label: AppLocalizations.of(
            context,
          ).messageFromLongPressOptions(message.senderName),
          child: GestureDetector(
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
                        if (message.replyToContent != null)
                          _ReplyIndicator(content: message.replyToContent!),
                        Container(
                          constraints: BoxConstraints(maxWidth: 300.w),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 9.h,
                          ),
                          decoration: BoxDecoration(
                            gradient: isMe
                                ? LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.primary.withValues(alpha: 0.92),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: isMe ? null : AppColors.surface,
                            border: isMe
                                ? null
                                : Border.all(
                                    color: AppColors.border.withValues(
                                      alpha: 0.75,
                                    ),
                                  ),
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
                                    ? AppColors.primary.withValues(alpha: 0.16)
                                    : Colors.black.withValues(alpha: 0.03),
                                blurRadius: isMe ? 6 : 4,
                                offset: Offset(0, isMe ? 2 : 1),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _MessageContent(
                                message: message,
                                isMe: isMe,
                                onLocationTap: _openLocationInMaps,
                              ),
                              SizedBox(height: 4.h),
                              _MessageMetaRow(
                                message: message,
                                isMe: isMe,
                                // FIX: Convert to local time before formatting.
                                formattedTime: _formatTime(message.createdAt),
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
    final notifier = ref.read(
      chatDetailViewModelProvider(_chatId, currentUser!.uid).notifier,
    );
    final l10n = AppLocalizations.of(context);

    void onReply() {
      notifier.setReplyTo(message);
      _focusNode.requestFocus();
    }

    void onCopy() {
      Clipboard.setData(ClipboardData(text: message.content));
      AdaptiveSnackBar.show(
        context,
        message: l10n.messageCopied,
        type: AdaptiveSnackBarType.info,
      );
    }

    Future<void> onDelete() async {
      try {
        await notifier.deleteMessage(message.id);
        if (!mounted) return;
        AdaptiveSnackBar.show(
          context,
          message: l10n.thisMessageWasDeleted,
          type: AdaptiveSnackBarType.success,
        );
      } on Exception {
        if (!mounted) return;
        AdaptiveSnackBar.show(
          context,
          message: l10n.couldNotClearChatTryAgain,
          type: AdaptiveSnackBarType.error,
        );
      }
    }

    AppModalSheet.showActions<void>(
      context: context,
      title: 'Message options',
      maxHeightFactor: 0.6,
      actions: [
        AppModalAction(
          icon: Icons.reply_rounded,
          title: l10n.reply,
          onTap: onReply,
        ),
        AppModalAction(
          icon: Icons.copy_rounded,
          title: l10n.copy,
          onTap: onCopy,
        ),
        if (isMe && !message.isDeleted)
          AppModalAction(
            icon: Icons.edit_rounded,
            title: l10n.actionEdit,
            onTap: () => _showEditDialog(message),
          ),
        if (isMe && !message.isDeleted)
          AppModalAction(
            icon: Icons.delete_outline_rounded,
            title: l10n.actionDelete,
            isDestructive: true,
            onTap: () => unawaited(onDelete()),
          ),
      ],
    );
  }

  void _showEditDialog(MessageModel message) {
    final controller = TextEditingController(text: message.content);
    showDialog<void>(
      context: context,
      barrierLabel: AppLocalizations.of(context).editMessage,
      builder: (ctx) => AlertDialog.adaptive(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.dialogRadius),
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
            onPressed: () => ctx.pop(),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(
                    chatDetailViewModelProvider(
                      _chatId,
                      currentUser!.uid,
                    ).notifier,
                  )
                  .editMessage(message.id, controller.text);
              ctx.pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(
              AppLocalizations.of(context).actionSave,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // FIX: Convert Firestore UTC DateTime to local before displaying.
  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final local = dateTime.toLocal();
    return '${local.hour}:${local.minute.toString().padLeft(2, '0')}';
  }

  // ── Input area ───────────────────────────────────────────────────────────

  Widget _buildInputArea() {
    final chatState = ref.watch(
      chatDetailViewModelProvider(_chatId, currentUser!.uid),
    );
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border.withValues(alpha: 0.75)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                tooltip: AppLocalizations.of(context).attachFile,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _showAttachmentOptions();
                },
                icon: Icon(
                  Icons.attach_file_rounded,
                  size: 22.sp,
                  color: AppColors.textSecondary,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surfaceVariant,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  minimumSize: Size(44.w, 44.w),
                  maximumSize: Size(44.w, 44.w),
                  padding: EdgeInsets.zero,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: ListenableBuilder(
                  listenable: _focusNode,
                  builder: (context, child) => AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(
                        color: _focusNode.hasFocus
                            ? AppColors.primary
                            : AppColors.border.withOpacity(0.4),
                        width: _focusNode.hasFocus ? 1.5 : 1,
                      ),
                      boxShadow: _focusNode.hasFocus
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : const [],
                    ),
                    child: child,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          focusNode: _focusNode,
                          onTap: () {
                            if (chatState.showEmojiPicker) {
                              ref
                                  .read(
                                    chatDetailViewModelProvider(
                                      _chatId,
                                      currentUser!.uid,
                                    ).notifier,
                                  )
                                  .setEmojiPickerVisible(false);
                            }
                          },
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context).typeAMessage,
                            hintStyle: TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 15.sp,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.fromLTRB(
                              16.w,
                              10.h,
                              4.w,
                              10.h,
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                          maxLines: 5,
                          minLines: 1,
                          textCapitalization: TextCapitalization.sentences,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                        ),
                      ),
                      IconButton(
                        tooltip: chatState.showEmojiPicker
                            ? AppLocalizations.of(context).showKeyboard
                            : AppLocalizations.of(context).showEmojiPicker,
                        onPressed: _toggleEmojiPicker,
                        icon: Icon(
                          chatState.showEmojiPicker
                              ? Icons.keyboard_rounded
                              : Icons.emoji_emotions_rounded,
                          size: 22.sp,
                        ),
                        color: chatState.showEmojiPicker
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.fromLTRB(4.w, 8.h, 12.w, 8.h),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _messageController,
                builder: (context, value, _) {
                  final hasText = value.text.trim().isNotEmpty;
                  final showPrimary = hasText || chatState.isRecording;
                  return Semantics(
                    button: true,
                    label: chatState.isRecording
                        ? AppLocalizations.of(context).stopRecording
                        : hasText
                        ? AppLocalizations.of(context).sendMessage
                        : AppLocalizations.of(context).recordVoiceMessage,
                    child: GestureDetector(
                      onTap: () {
                        if (chatState.isRecording) {
                          _stopRecording();
                        } else if (hasText) {
                          _sendMessage();
                        } else {
                          _startRecording();
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.all(11.w),
                        decoration: BoxDecoration(
                          gradient: chatState.isRecording
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFFE91E63),
                                    Color(0xFFF44336),
                                  ],
                                )
                              : showPrimary
                              ? AppColors.primaryGradient
                              : null,
                          color: showPrimary ? null : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(14.r),
                          boxShadow: showPrimary
                              ? [
                                  BoxShadow(
                                    color:
                                        (chatState.isRecording
                                                ? const Color(0xFFE91E63)
                                                : AppColors.primary)
                                            .withValues(alpha: 0.26),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : const [],
                        ),
                        child: Icon(
                          chatState.isRecording
                              ? Icons.stop_rounded
                              : hasText
                              ? Icons.send_rounded
                              : Icons.mic_rounded,
                          color: showPrimary
                              ? Colors.white
                              : AppColors.textSecondary,
                          size: 22.sp,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAttachmentOptions() async {
    final l10n = AppLocalizations.of(context);
    await AppModalSheet.showActions<void>(
      context: context,
      title: 'Attachments',
      maxHeightFactor: 0.56,
      description: 'Choose what you want to share in this chat.',
      actions: [
        AppModalAction(
          icon: Icons.camera_alt_rounded,
          title: l10n.camera,
          accentColor: const Color(0xFFE91E63),
          onTap: () => unawaited(_sendImageFromSource(ImageSource.camera)),
        ),
        AppModalAction(
          icon: Icons.photo_rounded,
          title: l10n.gallery,
          accentColor: const Color(0xFF9C27B0),
          onTap: () => unawaited(_sendImageFromSource(ImageSource.gallery)),
        ),
        AppModalAction(
          icon: Icons.location_on_rounded,
          title: l10n.location,
          accentColor: const Color(0xFF4CAF50),
          onTap: () => unawaited(_shareLocation()),
        ),
      ],
    );
  }

  // FIX: Permission checks happen BEFORE the spinner.
  // Dialog is NOT awaited — closed programmatically after getting position.
  // Duplicate permission checks inside the try block removed.
  Future<void> _shareLocation() async {
    final l10n = AppLocalizations.of(context);

    final accepted = await PermissionDialogHelper.showLocationSharingRationale(
      context,
    );
    if (!accepted) return;
    if (!mounted) return;

    final svc = ref.read(locationServiceProvider);
    if (!await svc.isServiceEnabled()) {
      if (!mounted) return;
      _showLocationError('Please enable location services');
      return;
    }
    if (!await svc.checkPermission()) {
      final granted = await svc.requestPermission();
      if (!granted) {
        if (!mounted) return;
        _showLocationError('Location permission required');
        return;
      }
    }

    if (!await _ensurePersistedChat()) return;
    if (!mounted) return;

    // FIX: Do NOT await the dialog — we close it programmatically below.
    // Awaiting it would deadlock because barrierDismissible is false.
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(
          child: Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                SizedBox(height: 16.h),
                Text(
                  l10n.gettingYourLocation,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final position = await ref
          .read(locationServiceProvider)
          .getCurrentLocation();
      if (!mounted) return;
      if (position == null) {
        Navigator.of(context).pop();
        _showLocationError('Could not get your location');
        return;
      }

      final locationName =
          await ref
              .read(locationServiceProvider)
              .getAddressFromCoordinates(
                position.latitude,
                position.longitude,
              ) ??
          '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';

      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog.

      final success = await ref
          .read(
            chatDetailViewModelProvider(
              _chatId,
              currentUser?.uid ?? '',
            ).notifier,
          )
          .sendLocationMessage(
            content: locationName,
            latitude: position.latitude,
            longitude: position.longitude,
            senderName: currentUser?.username ?? 'User',
            senderPhotoUrl: currentUser?.photoUrl,
          );

      if (success && mounted) {
        HapticFeedback.lightImpact();
        _showStatusSnackBar(
          l10n.locationShared,
          type: AdaptiveSnackBarType.success,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e, st) {
      if (!mounted) return;
      Navigator.of(context).pop();
      _showLocationError('Failed to get location: $e');
    }
  }

  void _showLocationError(String message) {
    AdaptiveSnackBar.show(
      context,
      message: message,
      type: AdaptiveSnackBarType.error,
      duration: const Duration(seconds: 3),
      action: 'Settings',
      onActionPressed: () =>
          ref.read(locationServiceProvider).openLocationSettings(),
    );
  }

  Future<void> _openLocationInMaps(double lat, double lng, String label) async {
    HapticFeedback.lightImpact();
    final encodedLabel = Uri.encodeComponent(label.replaceFirst('📍 ', ''));
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    final appleMapsUrl = Uri.parse(
      'https://maps.apple.com/?ll=$lat,$lng&q=$encodedLabel',
    );
    final geoUrl = Uri.parse('geo:$lat,$lng?q=$lat,$lng($encodedLabel)');

    try {
      var launched = false;
      if (Platform.isAndroid) {
        if (await canLaunchUrl(geoUrl)) launched = await launchUrl(geoUrl);
        if (!launched && await canLaunchUrl(googleMapsUrl)) {
          launched = await launchUrl(
            googleMapsUrl,
            mode: LaunchMode.externalApplication,
          );
        }
      } else if (Platform.isIOS) {
        if (await canLaunchUrl(appleMapsUrl)) {
          launched = await launchUrl(
            appleMapsUrl,
            mode: LaunchMode.externalApplication,
          );
        }
        if (!launched && await canLaunchUrl(googleMapsUrl)) {
          launched = await launchUrl(
            googleMapsUrl,
            mode: LaunchMode.externalApplication,
          );
        }
      } else {
        if (await canLaunchUrl(googleMapsUrl)) {
          launched = await launchUrl(
            googleMapsUrl,
            mode: LaunchMode.externalApplication,
          );
        }
      }

      if (!launched && mounted) {
        await Clipboard.setData(ClipboardData(text: '$lat, $lng'));
        if (!mounted) return;
        _showStatusSnackBar(
          AppLocalizations.of(context).coordinatesCopiedToClipboard,
          type: AdaptiveSnackBarType.success,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e, st) {
      if (!mounted) return;
      _showStatusSnackBar(
        AppLocalizations.of(context).couldNotOpenMapsValue(e),
        type: AdaptiveSnackBarType.error,
      );
    }
  }

  // ── Recording banner ─────────────────────────────────────────────────────

  Widget _buildRecordingBanner(ChatDetailState chatState) {
    return Positioned(
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
                )
                .animate(onPlay: (c) => c.repeat())
                .fadeIn(duration: 600.ms)
                .then()
                .fadeOut(duration: 600.ms),
            SizedBox(width: 12.w),
            Icon(Icons.mic, color: Colors.white, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              AppLocalizations.of(context).recording,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '${chatState.recordingDuration.inMinutes}:'
              '${(chatState.recordingDuration.inSeconds % 60).toString().padLeft(2, '0')}',
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
                child: Icon(Icons.close, color: Colors.white, size: 18.sp),
              ),
            ),
          ],
        ),
      ).animate().slideY(begin: -1).fadeIn(),
    );
  }
}

// ── Extracted message content widgets ────────────────────────────────────────

/// Routes to the correct content widget based on [MessageModel.type].
class _MessageContent extends StatelessWidget {
  const _MessageContent({
    required this.message,
    required this.isMe,
    required this.onLocationTap,
  });

  final MessageModel message;
  final bool isMe;
  final void Function(double lat, double lng, String label) onLocationTap;

  @override
  Widget build(BuildContext context) {
    return switch (message.type) {
      MessageType.image when message.mediaUrl != null => _ImageMessageContent(
        mediaUrl: message.mediaUrl!,
      ),
      MessageType.location
          when message.latitude != null && message.longitude != null =>
        _LocationMessageContent(
          message: message,
          isMe: isMe,
          onTap: () => onLocationTap(
            message.latitude!,
            message.longitude!,
            message.content,
          ),
        ),
      MessageType.audio when message.mediaUrl != null => _AudioMessagePlayer(
        message: message,
        audioUrl: message.mediaUrl!,
        isMe: isMe,
      ),
      _ => _TextMessageContent(message: message, isMe: isMe),
    };
  }
}

/// Network image with loading shimmer.
class _ImageMessageContent extends StatelessWidget {
  const _ImageMessageContent({required this.mediaUrl});

  final String mediaUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: Image.network(
        mediaUrl,
        width: 200.w,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: 200.w,
            height: 150.h,
            color: AppColors.surfaceVariant,
            child: Center(
              child: CircularProgressIndicator.adaptive(
                value: progress.expectedTotalBytes != null
                    ? progress.cumulativeBytesLoaded /
                          progress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Static map preview + address label. Tappable to open in maps app.
class _LocationMessageContent extends StatelessWidget {
  const _LocationMessageContent({
    required this.message,
    required this.isMe,
    required this.onTap,
  });

  final MessageModel message;
  final bool isMe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mapUrl =
        'https://staticmap.openstreetmap.de/staticmap.php'
        '?center=${message.latitude},${message.longitude}'
        '&zoom=15&size=200x120&maptype=osmarenderer'
        '&markers=${message.latitude},${message.longitude},red-pushpin';

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Stack(
              children: [
                Image.network(
                  mapUrl,
                  width: 200.w,
                  height: 120.h,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 200.w,
                    height: 120.h,
                    color: AppColors.surfaceVariant,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.map_rounded,
                          size: 32.sp,
                          color: isMe
                              ? Colors.white70
                              : AppColors.textSecondary,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          AppLocalizations.of(context).tapToOpenMap,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: isMe
                                ? Colors.white70
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  loadingBuilder: (_, child, progress) => progress == null
                      ? child
                      : Container(
                          width: 200.w,
                          height: 120.h,
                          color: AppColors.surfaceVariant,
                          child: const Center(
                            child: CircularProgressIndicator.adaptive(
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                ),
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
                      borderRadius: BorderRadius.circular(12.r),
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
                          AppLocalizations.of(context).open,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 16.sp,
                color: isMe ? Colors.white70 : const Color(0xFF4CAF50),
              ),
              SizedBox(width: 4.w),
              Flexible(
                child: Text(
                  message.content.replaceFirst('📍 ', ''),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isMe ? Colors.white : AppColors.textPrimary,
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
    );
  }
}

/// Plain text or deleted-message placeholder.
class _TextMessageContent extends StatelessWidget {
  const _TextMessageContent({required this.message, required this.isMe});

  final MessageModel message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Text(
      message.isDeleted
          ? AppLocalizations.of(context).thisMessageWasDeleted
          : message.content,
      style: TextStyle(
        fontSize: 15.sp,
        color: isMe ? Colors.white : AppColors.textPrimary,
        fontStyle: message.isDeleted ? FontStyle.italic : FontStyle.normal,
        height: 1.4,
      ),
    );
  }
}

/// Timestamp + edited flag + read-receipt icon row.
class _MessageMetaRow extends StatelessWidget {
  const _MessageMetaRow({
    required this.message,
    required this.isMe,
    required this.formattedTime,
  });

  final MessageModel message;
  final bool isMe;
  final String formattedTime;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (message.isEdited)
          Padding(
            padding: EdgeInsets.only(right: 4.w),
            child: Text(
              AppLocalizations.of(context).edited,
              style: TextStyle(
                fontSize: 12.sp,
                color: isMe
                    ? Colors.white.withValues(alpha: 0.6)
                    : AppColors.textTertiary,
              ),
            ),
          ),
        Text(
          formattedTime,
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
            // delivered and read both show double-tick; color distinguishes them.
            message.status == MessageStatus.read ||
                    message.status == MessageStatus.delivered
                ? Icons.done_all_rounded
                : Icons.done_rounded,
            size: 14.sp,
            color: message.status == MessageStatus.read
                ? Colors.lightBlueAccent
                : Colors.white.withValues(alpha: 0.7),
          ),
        ],
      ],
    );
  }
}

/// Quoted-message strip shown above a bubble when replying.
class _ReplyIndicator extends StatelessWidget {
  const _ReplyIndicator({required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 4.h),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8.r),
        border: const Border(
          left: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      child: Text(
        content,
        style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// ── Audio player ──────────────────────────────────────────────────────────────

// ── Audio player ──────────────────────────────────────────────────────────────

class _AudioMessagePlayer extends StatefulWidget {
  const _AudioMessagePlayer({
    required this.audioUrl,
    required this.isMe,
    required this.message,
  });

  final String audioUrl;
  final bool isMe;
  final MessageModel message;

  @override
  State<_AudioMessagePlayer> createState() => _AudioMessagePlayerState();
}

class _AudioMessagePlayerState extends State<_AudioMessagePlayer> {
  late VVoiceMessageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VVoiceMessageController(
      id: widget.message.id,
      audioSrc: VPlatformFile.fromUrl(networkUrl: widget.audioUrl),
      maxDuration: const Duration(minutes: 10),
      onComplete: (_) => HapticFeedback.lightImpact(),
      onPlaying: (_) => HapticFeedback.selectionClick(),
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

        // ── Colors ────────────────────────────────────────────────────────
        colorConfig: VoiceColorConfig(
          activeSliderColor: widget.isMe ? Colors.white : AppColors.primary,
          notActiveSliderColor: widget.isMe
              ? Colors.white.withValues(alpha: 0.35)
              : AppColors.divider,
        ),

        // ── Container ─────────────────────────────────────────────────────
        containerConfig: VoiceContainerConfig(
          backgroundColor: Colors.transparent,
          borderRadius: 0,
          containerPadding: EdgeInsets.symmetric(
            horizontal: 6.w,
            vertical: 6.h,
          ),
        ),

        // ── Play / Pause button ───────────────────────────────────────────
        buttonConfig: VoiceButtonConfig(
          buttonColor: widget.isMe
              ? Colors.white.withValues(alpha: 0.18)
              : AppColors.primary.withValues(alpha: 0.08),
          buttonIconColor: widget.isMe ? Colors.white : AppColors.primary,
          buttonSize: 40.w,
          useSimplePlayIcon: true,
          simpleIconSize: 20.sp,
        ),

        // ── Waveform visualizer ───────────────────────────────────────────
        visualizerConfig: VoiceVisualizerConfig(
          showVisualizer: true,
          height: 32.h,
          barCount: 45,
          barSpacing: 2,
          minBarHeight: 4,
          useRandomHeights: true, // unique pattern per message
          enableBarAnimations: true, // animates bars while playing
        ),

        // ── Speed control ─────────────────────────────────────────────────
        speedConfig: VoiceSpeedConfig(
          showSpeedControl: true,
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

        // ── Avatar ────────────────────────────────────────────────────────
        // shows sender avatar with mic icon + played/unplayed status badge
        avatarConfig: VoiceAvatarConfig(
          avatarSize: 36.w,
          micIconSize: 13.sp,
          userAvatar: widget.isMe
              ? const SizedBox.shrink() // no avatar on sent side
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

        // ── Text / counter ────────────────────────────────────────────────
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

// ── Typing dot ────────────────────────────────────────────────────────────────

/// A single animated dot for the typing indicator.
/// Uses [AnimationController] with repeat() so it loops indefinitely.
class _TypingDot extends StatefulWidget {
  const _TypingDot({required this.index});

  final int index;

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        (widget.index * 0.2).clamp(0.0, 1.0),
        (widget.index * 0.2 + 0.6).clamp(0.0, 1.0),
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity.drive(Tween(begin: 0.3, end: 1)),
      child: Container(
        width: 8.w,
        height: 8.w,
        decoration: const BoxDecoration(
          color: AppColors.textTertiary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
