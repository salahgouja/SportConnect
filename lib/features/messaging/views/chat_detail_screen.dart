import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
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
import 'package:audioplayers/audioplayers.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/premium_avatar.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/messaging/models/message_model.dart';
import 'package:sport_connect/features/messaging/view_models/chat_view_model.dart';
import 'package:sport_connect/core/widgets/permission_dialog_helper.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';
import 'package:sport_connect/core/theme/platform_adaptive.dart';

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
  Timer? _recordingTimer;
  late String _activeChatId;
  late UserModel _resolvedReceiver;
  bool _isResolvingReceiver = false;

  UserModel? get currentUser => ref.read(currentUserProvider).value;
  String get _chatId => _activeChatId;
  bool get _isDraftChat => isDraftChatId(_activeChatId);
  UserModel get _receiver => _resolvedReceiver;

  void _showStatusSnackBar(
    Widget content, {
    required Color backgroundColor,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: content,
        backgroundColor: backgroundColor,
        duration: duration,
        action: action,
      ),
    );
  }

  void _showSendingSnackBar(String message) {
    _showStatusSnackBar(
      Row(
        children: [
          SizedBox(
            width: 20.w,
            height: 20.w,
            child: const CircularProgressIndicator.adaptive(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(width: 12.w),
          Text(message),
        ],
      ),
      backgroundColor: AppColors.primary,
      duration: const Duration(seconds: 30),
    );
  }

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

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more messages when near the end
      final viewModel = ref.read(
        chatDetailViewModelProvider(_chatId, currentUser?.uid ?? '').notifier,
      );
      viewModel.loadMoreMessages();
    }
  }

  void _onTextChanged() {
    final viewModel = ref.read(
      chatDetailViewModelProvider(_chatId, currentUser?.uid ?? '').notifier,
    );
    viewModel.handleComposerTextChanged(
      _messageController.text,
      currentUser?.displayName ?? 'User',
    );
  }

  Future<bool> _ensurePersistedChat() async {
    if (!_isDraftChat) return true;

    final user = currentUser;
    if (user == null) return false;
    if (_receiver.uid.isEmpty) return false;

    try {
      final chat = await ref
          .read(chatActionsViewModelProvider)
          .getOrCreatePrivateChat(
            userId1: user.uid,
            userId2: _receiver.uid,
            userName1: user.displayName,
            userName2: _receiver.displayName,
            userPhoto1: user.photoUrl,
            userPhoto2: _receiver.photoUrl,
          );

      if (!mounted) return false;

      setState(() {
        _activeChatId = chat.id;
      });

      ref.invalidate(userChatsProvider(user.uid));
      return true;
    } catch (_) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).failedToCreateChatTryAgain,
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }
  }

  Future<void> _resolveReceiverIfNeeded() async {
    if (_isResolvingReceiver) return;
    if (widget.isGroup) return;
    if (_receiver.uid.isNotEmpty) return;
    if (_isDraftChat) return;

    final user = currentUser;
    if (user == null) return;

    _isResolvingReceiver = true;
    try {
      final chat = await ref
          .read(chatActionsViewModelProvider)
          .getChatById(_chatId);
      if (!mounted || chat == null) return;

      final other = chat.getOtherParticipant(user.uid);
      final fallbackId = chat.participantIds.firstWhere(
        (id) => id != user.uid,
        orElse: () => '',
      );
      final resolvedUid = other?.odid ?? fallbackId;
      if (resolvedUid.isEmpty) return;

      setState(() {
        _resolvedReceiver = UserModel.rider(
          uid: resolvedUid,
          email: '',
          displayName: other?.displayName ?? _receiver.displayName,
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

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    if (!await _ensurePersistedChat()) return;
    HapticFeedback.lightImpact();
    _messageController.clear();
    ref
        .read(
          chatDetailViewModelProvider(_chatId, currentUser?.uid ?? '').notifier,
        )
        .setEmojiPickerVisible(false);

    final viewModel = ref.read(
      chatDetailViewModelProvider(_chatId, currentUser?.uid ?? '').notifier,
    );

    final state = ref.read(
      chatDetailViewModelProvider(_chatId, currentUser?.uid ?? ''),
    );
    TalkerService.info(
      "the message is sent: $text and the replyToMessage is ${state.replyToMessage?.content} with id ${state.replyToMessage?.id} and the sender is ${currentUser?.displayName} and the sender photo url is ${currentUser?.photoUrl} and the chat id is ${_chatId} and the user id is ${currentUser?.uid}",
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
    final accepted = await PermissionDialogHelper.showCameraRationale(
      context,
      customMessage:
          'Access to your photo library is needed to send '
          'images in this chat. Your photos are only shared '
          'when you choose to send them.',
    );
    if (!accepted) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;
    if (!await _ensurePersistedChat()) return;

    HapticFeedback.lightImpact();
    _showSendingSnackBar(AppLocalizations.of(context).sendingImage);

    try {
      final file = File(pickedFile.path);
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}';
      final viewModel = ref.read(
        chatDetailViewModelProvider(_chatId, currentUser?.uid ?? '').notifier,
      );
      final viewState = ref.read(
        chatDetailViewModelProvider(_chatId, currentUser?.uid ?? ''),
      );

      final success = await viewModel.sendImageMessage(
        imageFile: file,
        fileName: fileName,
        senderName: currentUser?.displayName ?? 'User',
        senderPhotoUrl: currentUser?.photoUrl,
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (!success) {
        final errorMessage = viewState.error ?? 'Failed to send image';
        _showStatusSnackBar(
          Text(
            AppLocalizations.of(context).failedToSendImageValue(errorMessage),
          ),
          backgroundColor: AppColors.error,
        );
        return;
      }
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _showStatusSnackBar(
        Text(AppLocalizations.of(context).failedToSendImageValue(e)),
        backgroundColor: AppColors.error,
      );
    }
  }

  Future<void> _sendImageFromCamera() async {
    final accepted = await PermissionDialogHelper.showCameraRationale(
      context,
      customMessage:
          'Camera access is needed to take and send '
          'photos in this chat.',
    );
    if (!accepted) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile == null) return;
    if (!await _ensurePersistedChat()) return;

    HapticFeedback.lightImpact();
    _showSendingSnackBar(AppLocalizations.of(context).sendingImage);

    try {
      final file = File(pickedFile.path);
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}';
      final viewModel = ref.read(
        chatDetailViewModelProvider(_chatId, currentUser?.uid ?? '').notifier,
      );
      final viewState = ref.read(
        chatDetailViewModelProvider(_chatId, currentUser?.uid ?? ''),
      );

      final success = await viewModel.sendImageMessage(
        imageFile: file,
        fileName: fileName,
        senderName: currentUser?.displayName ?? 'User',
        senderPhotoUrl: currentUser?.photoUrl,
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (!success) {
        final errorMessage = viewState.error ?? 'Failed to send image';
        _showStatusSnackBar(
          Text(
            AppLocalizations.of(context).failedToSendImageValue(errorMessage),
          ),
          backgroundColor: AppColors.error,
        );
        return;
      }
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _showStatusSnackBar(
        Text(AppLocalizations.of(context).failedToSendImageValue(e)),
        backgroundColor: AppColors.error,
      );
    }
  }

  /// Start voice recording
  Future<void> _startRecording() async {
    try {
      final accepted = await PermissionDialogHelper.showMicrophoneRationale(
        context,
      );
      if (!accepted) return;
      if (await _audioRecorder.hasPermission()) {
        final directory = await getTemporaryDirectory();
        final path =
            '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
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

        // Start recording timer (updates every 100ms for smooth UI)
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
              .updateRecordingDuration(
                Duration(milliseconds: timer.tick * 100),
              );
        });

        HapticFeedback.mediumImpact();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).recordingFailedError),
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

      if (path != null && context.mounted) {
        await _sendAudioMessage(path);
      }

      ref
          .read(
            chatDetailViewModelProvider(
              _chatId,
              currentUser?.uid ?? '',
            ).notifier,
          )
          .clearRecording();

      HapticFeedback.mediumImpact();
    } catch (e) {
      ref
          .read(
            chatDetailViewModelProvider(
              _chatId,
              currentUser?.uid ?? '',
            ).notifier,
          )
          .clearRecording();

      _showStatusSnackBar(
        Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                AppLocalizations.of(context).stopRecordingFailedError,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
      );
    }
  }

  /// Cancel voice recording
  Future<void> _cancelRecording() async {
    try {
      await _audioRecorder.stop();
      _recordingTimer?.cancel();

      // Delete the recording file
      final recordingPath = ref
          .read(chatDetailViewModelProvider(_chatId, currentUser?.uid ?? ''))
          .recordingPath;
      if (recordingPath != null) {
        final file = File(recordingPath);
        if (await file.exists()) {
          await file.delete();
        }
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
    } catch (e) {
      // Silently fail
    }
  }

  /// Send audio message
  Future<void> _sendAudioMessage(String audioPath) async {
    if (!await _ensurePersistedChat()) return;
    HapticFeedback.lightImpact();
    _showSendingSnackBar(AppLocalizations.of(context).sendingVoiceMessage);

    try {
      final file = File(audioPath);
      final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final viewModel = ref.read(
        chatDetailViewModelProvider(_chatId, currentUser?.uid ?? '').notifier,
      );
      final viewState = ref.read(
        chatDetailViewModelProvider(_chatId, currentUser?.uid ?? ''),
      );

      final duration = viewState.recordingDuration;
      final durationText =
          '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';

      final success = await viewModel.sendAudioMessage(
        audioFile: file,
        fileName: fileName,
        durationText: durationText,
        senderName: currentUser?.displayName ?? 'User',
        senderPhotoUrl: currentUser?.photoUrl,
      );

      if (await file.exists()) {
        await file.delete();
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (!success) {
        throw Exception(viewState.error ?? 'Failed to send voice message');
      }

      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Provide user-friendly error message
      String errorMessage = 'Failed to send voice message';
      if (e.toString().contains('permission') || e.toString().contains('403')) {
        errorMessage =
            'Permission denied. Please check your connection and try again.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your internet connection.';
      }

      _showStatusSnackBar(
        Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 12.w),
            Expanded(child: Text(errorMessage)),
          ],
        ),
        backgroundColor: AppColors.error,
        action: SnackBarAction(
          label: 'RETRY',
          textColor: Colors.white,
          onPressed: () => _sendAudioMessage(audioPath),
        ),
      );

      // Log error for debugging
      TalkerService.error('Audio upload failed', e);
    }
  }

  void _toggleEmojiPicker() {
    final chatState = ref.read(
      chatDetailViewModelProvider(_chatId, currentUser?.uid ?? ''),
    );
    if (chatState.showEmojiPicker) {
      ref
          .read(
            chatDetailViewModelProvider(
              _chatId,
              currentUser?.uid ?? '',
            ).notifier,
          )
          .setEmojiPickerVisible(false);
      _focusNode.requestFocus();
    } else {
      _focusNode.unfocus();
      ref
          .read(
            chatDetailViewModelProvider(
              _chatId,
              currentUser?.uid ?? '',
            ).notifier,
          )
          .setEmojiPickerVisible(true);
    }
  }

  void _showOptionsSheet({required bool isReceiverBlocked}) {
    final l10n = AppLocalizations.of(context);

    // iOS: Use CupertinoActionSheet per HIG guidelines.
    if (PlatformAdaptive.isApple) {
      showCupertinoModalPopup<void>(
        context: context,
        builder: (ctx) => CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                ctx.pop();
                final receiverId = _receiver.uid;
                if (receiverId.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.failedToLoadChats),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }
                context.push('/driver/profile/$receiverId', extra: _receiver);
              },
              child: Text(l10n.viewProfile),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                ctx.pop();
                _muteChat();
              },
              child: Text(l10n.muteNotifications),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                ctx.pop();
                _reportUser();
              },
              child: Text(l10n.reportUser),
            ),
            CupertinoActionSheetAction(
              isDestructiveAction: !isReceiverBlocked,
              onPressed: () {
                ctx.pop();
                if (isReceiverBlocked) {
                  _confirmUnblockUser();
                } else {
                  _confirmBlockUser();
                }
              },
              child: Text(
                isReceiverBlocked ? l10n.unblockUser : l10n.blockUser,
              ),
            ),
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () {
                ctx.pop();
                _confirmClearChat();
              },
              child: Text(l10n.clearChat),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => ctx.pop(),
            child: Text(l10n.actionCancel),
          ),
        ),
      );
      return;
    }

    // Android: Material bottom sheet
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
                final receiverId = _receiver.uid;
                if (receiverId.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context).failedToLoadChats,
                      ),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }
                context.push(
                  '/driver/profile/$receiverId',
                  extra: _receiver,
                );
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
              Icons.flag_outlined,
              AppLocalizations.of(context).reportUser,
              () {
                context.pop();
                _reportUser();
              },
            ),
            _buildOptionItem(
              isReceiverBlocked
                  ? Icons.person_remove_outlined
                  : Icons.block_rounded,
              isReceiverBlocked
                  ? AppLocalizations.of(context).unblockUser
                  : AppLocalizations.of(context).blockUser,
              () {
                context.pop();
                if (isReceiverBlocked) {
                  _confirmUnblockUser();
                } else {
                  _confirmBlockUser();
                }
              },
              isDestructive: !isReceiverBlocked,
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

  void _reportUser() {
    context.push(
      AppRoutes.reportIssue.path,
      extra: {
        'reportedUserId': _receiver.uid,
        'reportedUserName': _receiver.displayName,
        'reportContext': 'chat',
        'chatId': _chatId,
      },
    );
  }

  void _confirmBlockUser() {
    if (_receiver.uid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).couldNotBlockUserTryAgain),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
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
          ).blockUserDialogMessage(_receiver.displayName),
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
                final chatController = ref.read(chatActionsViewModelProvider);
                await chatController.blockUser(
                  chatId: _isDraftChat ? null : _chatId,
                  userId: currentUser!.uid,
                  blockedUserId: _receiver.uid,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(
                          context,
                        ).blockedUserSuccess(_receiver.displayName),
                      ),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  context.pop(); // Leave the chat
                }
              } catch (_) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context).couldNotBlockUserTryAgain,
                      ),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).couldNotUnblockUserTryAgain,
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
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
          ).unblockUserDialogMessage(_receiver.displayName),
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
                final chatController = ref.read(chatActionsViewModelProvider);
                await chatController.unblockUser(
                  chatId: _isDraftChat ? null : _chatId,
                  userId: currentUser!.uid,
                  blockedUserId: _receiver.uid,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context).userUnblocked),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (_) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(
                          context,
                        ).couldNotUnblockUserTryAgain,
                      ),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
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

  void _muteChat() async {
    final chatController = ref.read(chatActionsViewModelProvider);
    await chatController.toggleMute(
      chatId: _chatId,
      userId: currentUser!.uid,
      mute: true,
    );
    if (!mounted) return;
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
                final chatController = ref.read(chatActionsViewModelProvider);
                await chatController.clearChat(
                  chatId: _chatId,
                  userId: currentUser!.uid,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context).chatCleared),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (_) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context).couldNotClearChatTryAgain,
                      ),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
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
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    if (_receiver.uid.isEmpty && !_isResolvingReceiver) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _resolveReceiverIfNeeded();
      });
    }

    final chatState = ref.watch(
      chatDetailViewModelProvider(_chatId, currentUser!.uid),
    );
    final blockedIdsAsync = ref.watch(blockedUserIdsProvider(currentUser!.uid));
    final isReceiverBlocked =
        blockedIdsAsync.value?.contains(_receiver.uid) ?? false;

    // Mark messages as read only when a new message arrives (count changed or
    // last message ID changed) to avoid an excessive Firestore write on every
    // state update.
    ref.listen(chatDetailViewModelProvider(_chatId, currentUser!.uid), (
      previous,
      next,
    ) {
      if (next.messages.isNotEmpty &&
          (previous == null ||
              previous.messages.length != next.messages.length ||
              previous.messages.first.id != next.messages.first.id)) {
        ref
            .read(
              chatDetailViewModelProvider(_chatId, currentUser!.uid).notifier,
            )
            .markVisibleMessagesAsRead();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(chatState, isReceiverBlocked),
      body: Stack(
        children: [
          Column(
            children: [
              if (isReceiverBlocked) _buildBlockedBanner(),
              // Messages list
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
                      ? const Center(
                          child: CircularProgressIndicator.adaptive(),
                        )
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
              if (!isReceiverBlocked) _buildInputArea(),

              // Emoji picker
              if (!isReceiverBlocked && chatState.showEmojiPicker)
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
          if (chatState.isRecording)
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
                        )
                        .animate(onPlay: (controller) => controller.repeat())
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
                      '${chatState.recordingDuration.inMinutes}:${(chatState.recordingDuration.inSeconds % 60).toString().padLeft(2, '0')}',
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
      reverse: true, // Latest messages at bottom
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

  PreferredSizeWidget _buildAppBar(
    ChatDetailState chatState,
    bool isReceiverBlocked,
  ) {
    return AppBar(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      leading: Container(
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
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          _receiver.photoUrl != null
              ? CircleAvatar(
                  radius: 20.r,
                  backgroundImage: NetworkImage(_receiver.photoUrl!),
                )
              : PremiumAvatar(name: _receiver.displayName, size: 40),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _receiver.displayName,
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
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1.h),
        child: Divider(height: 1.h, thickness: 1, color: AppColors.border),
      ),
      actions: [
        Container(
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
        ),
      ],
    );
  }

  Widget _buildTypingIndicator(ChatDetailState chatState) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          PremiumAvatar(name: _receiver.displayName, size: 28),
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
    ).animate().fadeIn(duration: 220.ms);
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
      chatDetailViewModelProvider(_chatId, currentUser!.uid).notifier,
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
            tooltip: AppLocalizations.of(context).clearReply,
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
                              // Image message
                              if (message.type == MessageType.image &&
                                  message.imageUrl != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12.r),
                                  child: Image.network(
                                    message.imageUrl!,
                                    width: 200.w,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        width: 200.w,
                                        height: 150.h,
                                        color: AppColors.surfaceVariant,
                                        child: Center(
                                          child: CircularProgressIndicator.adaptive(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Map preview using OpenStreetMap static image
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
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
                                                                  ? Colors
                                                                        .white70
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
                                                    if (loadingProgress ==
                                                        null) {
                                                      return child;
                                                    }
                                                    return Container(
                                                      width: 200.w,
                                                      height: 120.h,
                                                      color: AppColors
                                                          .surfaceVariant,
                                                      child: const Center(
                                                        child:
                                                            CircularProgressIndicator.adaptive(
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
                                                      BorderRadius.circular(
                                                        12.r,
                                                      ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
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
                                                        fontSize: 12.sp,
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
                                  message.imageUrl !=
                                      null) // Using imageUrl field for audio URL
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
                                    height: 1.4,
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
                                          fontSize: 12.sp,
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
                                      color:
                                          message.status == MessageStatus.read
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
      chatDetailViewModelProvider(_chatId, currentUser!.uid).notifier,
    );
    final l10n = AppLocalizations.of(context);

    void onReply() {
      viewModel.setReplyTo(message);
      _focusNode.requestFocus();
    }

    void onCopy() {
      Clipboard.setData(ClipboardData(text: message.content));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.messageCopied),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    Future<void> onDelete() async {
      try {
        await viewModel.deleteMessage(message.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.thisMessageWasDeleted),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.couldNotClearChatTryAgain),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }

    // iOS: CupertinoActionSheet per HIG
    if (PlatformAdaptive.isApple) {
      showCupertinoModalPopup<void>(
        context: context,
        builder: (ctx) => CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                ctx.pop();
                onReply();
              },
              child: Text(l10n.reply),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                ctx.pop();
                onCopy();
              },
              child: Text(l10n.copy),
            ),
            if (isMe && !message.isDeleted) ...[
              CupertinoActionSheetAction(
                onPressed: () {
                  ctx.pop();
                  _showEditDialog(message);
                },
                child: Text(l10n.actionEdit),
              ),
              CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: () {
                  ctx.pop();
                  onDelete();
                },
                child: Text(l10n.actionDelete),
              ),
            ],
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => ctx.pop(),
            child: Text(l10n.actionCancel),
          ),
        ),
      );
      return;
    }

    // Android: Material bottom sheet
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
              l10n.reply,
              () {
                context.pop();
                onReply();
              },
            ),
            _buildOptionItem(
              Icons.copy_rounded,
              l10n.copy,
              () {
                context.pop();
                onCopy();
              },
            ),
            if (isMe && !message.isDeleted) ...[
              _buildOptionItem(
                Icons.edit_rounded,
                l10n.actionEdit,
                () {
                  context.pop();
                  _showEditDialog(message);
                },
              ),
              _buildOptionItem(
                Icons.delete_outline_rounded,
                l10n.actionDelete,
                () {
                  context.pop();
                  onDelete();
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
      barrierLabel: AppLocalizations.of(context).editMessage,
      builder: (context) => AlertDialog.adaptive(
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
            onPressed: () => context.pop(),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          ElevatedButton(
            onPressed: () {
              final viewModel = ref.read(
                chatDetailViewModelProvider(_chatId, currentUser!.uid).notifier,
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
    final chatState = ref.watch(
      chatDetailViewModelProvider(_chatId, currentUser!.uid),
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.border.withValues(alpha: 0.75),
            width: 1,
          ),
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
              // Attachment
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
              // Text field with reactive focus border
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
                      // Emoji / keyboard toggle
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
              // Send / Mic / Stop — rebuilt reactively when text changes
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _messageController,
                builder: (context, value, _) {
                  final hasText = value.text.trim().isNotEmpty;
                  final showPrimaryAction = hasText || chatState.isRecording;
                  return Semantics(
                    button: true,
                    label: chatState.isRecording
                        ? AppLocalizations.of(context).stopRecording
                        : hasText
                        ? AppLocalizations.of(context).sendMessage
                        : AppLocalizations.of(context).recordVoiceMessage,
                    child: GestureDetector(
                      onTap: () {
                        // Recording takes priority over send so tapping while
                        // recording always stops it regardless of typed text.
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
                              : showPrimaryAction
                              ? AppColors.primaryGradient
                              : null,
                          color: showPrimaryAction
                              ? null
                              : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(14.r),
                          boxShadow: showPrimaryAction
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
                          color: showPrimaryAction
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

  void _showAttachmentOptions() {
    final l10n = AppLocalizations.of(context);

    // iOS: CupertinoActionSheet per HIG
    if (PlatformAdaptive.isApple) {
      showCupertinoModalPopup<void>(
        context: context,
        builder: (ctx) => CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                ctx.pop();
                _sendImageFromCamera();
              },
              child: Text(l10n.camera),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                ctx.pop();
                _sendImage();
              },
              child: Text(l10n.gallery),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                ctx.pop();
                _shareLocation();
              },
              child: Text(l10n.location),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => ctx.pop(),
            child: Text(l10n.actionCancel),
          ),
        ),
      );
      return;
    }

    // Android: Material bottom sheet with icon grid
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
                  () {
                    context.pop();
                    _sendImageFromCamera();
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
    if (!await _ensurePersistedChat()) return;
    HapticFeedback.mediumImpact();

    // Show rationale before requesting location
    final accepted = await PermissionDialogHelper.showLocationSharingRationale(
      context,
    );
    if (!accepted) return;

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
              const CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
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

      if (!context.mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      // Send location message
      final viewModel = ref.read(
        chatDetailViewModelProvider(_chatId, currentUser?.uid ?? '').notifier,
      );

      final success = await viewModel.sendLocationMessage(
        content: locationName,
        latitude: position.latitude,
        longitude: position.longitude,
        senderName: currentUser?.displayName ?? 'User',
        senderPhotoUrl: currentUser?.photoUrl,
      );

      if (success && context.mounted) {
        HapticFeedback.lightImpact();
        _showStatusSnackBar(
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 8.w),
              Text(AppLocalizations.of(context).locationShared),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      if (context.mounted) {
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

      if (!launched && context.mounted) {
        // Copy coordinates as fallback
        Clipboard.setData(ClipboardData(text: '$lat, $lng'));
        _showStatusSnackBar(
          Row(
            children: [
              const Icon(Icons.content_copy, color: Colors.white, size: 20),
              SizedBox(width: 8.w),
              Text(AppLocalizations.of(context).coordinatesCopiedToClipboard),
            ],
          ),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showStatusSnackBar(
          Text(AppLocalizations.of(context).couldNotOpenMapsValue(e)),
          backgroundColor: AppColors.error,
        );
      }
    }
  }
}

/// Audio message player widget
class _AudioMessagePlayer extends StatefulWidget {
  final String audioUrl;
  final bool isMe;

  const _AudioMessagePlayer({required this.audioUrl, required this.isMe});

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
            _duration.inMilliseconds > 0 ? _formatDuration(_duration) : '0:00',
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
