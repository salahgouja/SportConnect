import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart' as flyer;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/app_modal_sheet.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/messaging/models/message_model.dart'
    as sport;

/// Read-only Flyer Chat UI bridge.
///
/// Keeps the existing SportConnect chat composer/actions in place while making
/// Flyer Chat UI available as a compatible rendering surface for the same
/// Firestore message stream.
class FlyerChatPreviewSheet extends StatefulWidget {
  const FlyerChatPreviewSheet({
    required this.messages,
    required this.currentUser,
    required this.receiver,
    super.key,
  });

  final List<sport.MessageModel> messages;
  final UserModel currentUser;
  final UserModel receiver;

  static Future<void> show({
    required BuildContext context,
    required List<sport.MessageModel> messages,
    required UserModel currentUser,
    required UserModel receiver,
  }) {
    return AppModalSheet.show<void>(
      context: context,
      title: 'Chat preview',
      forceMaxHeight: true,
      maxHeightFactor: 0.86,
      child: FlyerChatPreviewSheet(
        messages: messages,
        currentUser: currentUser,
        receiver: receiver,
      ),
    );
  }

  @override
  State<FlyerChatPreviewSheet> createState() => _FlyerChatPreviewSheetState();
}

class _FlyerChatPreviewSheetState extends State<FlyerChatPreviewSheet> {
  late final flyer.InMemoryChatController _controller;

  @override
  void initState() {
    super.initState();
    _controller = flyer.InMemoryChatController(
      messages: _toFlyerMessages(widget.messages),
    );
  }

  @override
  void didUpdateWidget(covariant FlyerChatPreviewSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.messages != widget.messages) {
      _controller.setMessages(_toFlyerMessages(widget.messages));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18.r),
      child: Chat(
        currentUserId: widget.currentUser.uid,
        chatController: _controller,
        backgroundColor: AppColors.background,
        resolveUser: (id) async {
          if (id == widget.currentUser.uid) {
            return flyer.User(
              id: widget.currentUser.uid,
              name: widget.currentUser.username,
              imageSource: widget.currentUser.photoUrl,
            );
          }
          return flyer.User(
            id: widget.receiver.uid,
            name: widget.receiver.username,
            imageSource: widget.receiver.photoUrl,
          );
        },
        builders: const flyer.Builders(
          composerBuilder: _ReadOnlyComposer.new,
        ),
      ),
    );
  }

  List<flyer.Message> _toFlyerMessages(List<sport.MessageModel> messages) {
    final sorted = [...messages]
      ..sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return aDate.compareTo(bDate);
      });

    return sorted.map(_toFlyerMessage).toList(growable: false);
  }

  flyer.Message _toFlyerMessage(sport.MessageModel message) {
    final status = switch (message.status) {
      sport.MessageStatus.sending => flyer.MessageStatus.sending,
      sport.MessageStatus.failed => flyer.MessageStatus.error,
      sport.MessageStatus.read => flyer.MessageStatus.seen,
      sport.MessageStatus.delivered => flyer.MessageStatus.delivered,
      sport.MessageStatus.sent => flyer.MessageStatus.sent,
    };

    return switch (message.type) {
      sport.MessageType.image when message.mediaUrl?.isNotEmpty == true =>
        flyer.Message.image(
          id: message.id,
          authorId: message.senderId,
          createdAt: message.createdAt,
          sentAt: message.status == sport.MessageStatus.sent
              ? message.createdAt
              : null,
          deliveredAt: message.status == sport.MessageStatus.delivered
              ? message.createdAt
              : null,
          seenAt: message.status == sport.MessageStatus.read
              ? message.createdAt
              : null,
          status: status,
          source: message.mediaUrl!,
          text: message.content.isEmpty ? null : message.content,
        ),
      _ => flyer.Message.text(
        id: message.id,
        authorId: message.senderId,
        createdAt: message.createdAt,
        sentAt: message.status == sport.MessageStatus.sent
            ? message.createdAt
            : null,
        deliveredAt: message.status == sport.MessageStatus.delivered
            ? message.createdAt
            : null,
        seenAt: message.status == sport.MessageStatus.read
            ? message.createdAt
            : null,
        status: status,
        text: _displayTextFor(message),
      ),
    };
  }

  String _displayTextFor(sport.MessageModel message) {
    if (message.content.isNotEmpty) return message.content;
    return switch (message.type) {
      sport.MessageType.location => message.locationName ?? 'Shared location',
      sport.MessageType.audio => 'Voice message',
      sport.MessageType.ride => 'Ride attachment',
      sport.MessageType.system => 'System message',
      sport.MessageType.image => 'Image',
      sport.MessageType.text => '',
    };
  }
}

class _ReadOnlyComposer extends StatelessWidget {
  const _ReadOnlyComposer(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Text(
        'Preview mode',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
