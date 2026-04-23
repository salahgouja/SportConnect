import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/config/routes/route_config.dart';
import 'package:sport_connect/core/config/routes/route_params.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/messaging/views/chat_detail_screen.dart';

/// Chat module routes
class ChatRoutes implements RouteConfig {
  @override
  String get moduleName => 'chat';

  @override
  String? get initialRoute => null;

  @override
  List<RouteBase> getRoutes() {
    UserModel fallbackReceiver(GoRouterState state) {
      final receiverId = state.params.getQueryOrDefault('receiverId', '');
      final receiverName = state.params.getQueryOrDefault(
        'receiverName',
        'User',
      );
      final receiverPhoto = state.params.getQuery('receiverPhotoUrl');

      return UserModel.rider(
        uid: receiverId,
        email: '',
        username: receiverName,
        photoUrl: receiverPhoto,
      );
    }

    return [
      GoRoute(
        path: AppRoutes.chatDetail.path,
        name: AppRoutes.chatDetail.name,
        pageBuilder: (context, state) {
          final chatId = state.params.getStringOrThrow('id');
          final receiver =
              state.params.getExtra<UserModel>() ?? fallbackReceiver(state);
          return PlatformInfo.isIOS
              ? CupertinoPage(
                  key: state.pageKey,
                  child: ChatDetailScreen(chatId: chatId, receiver: receiver),
                )
              : MaterialPage(
                  key: state.pageKey,
                  child: ChatDetailScreen(chatId: chatId, receiver: receiver),
                );
        },
      ),
      GoRoute(
        path: AppRoutes.chatGroup.path,
        name: AppRoutes.chatGroup.name,
        pageBuilder: (context, state) {
          final groupId = state.params.getStringOrThrow('id');
          final receiver =
              state.params.getExtra<UserModel>() ?? fallbackReceiver(state);
          return PlatformInfo.isIOS
              ? CupertinoPage(
                  key: state.pageKey,
                  child: ChatDetailScreen(
                    chatId: groupId,
                    receiver: receiver,
                    isGroup: true,
                  ),
                )
              : MaterialPage(
                  key: state.pageKey,
                  child: ChatDetailScreen(
                    chatId: groupId,
                    receiver: receiver,
                    isGroup: true,
                  ),
                );
        },
      ),
      GoRoute(
        path: AppRoutes.chatRide.path,
        name: AppRoutes.chatRide.name,
        pageBuilder: (context, state) {
          final rideId = state.params.getStringOrThrow('id');
          final receiver =
              state.params.getExtra<UserModel>() ?? fallbackReceiver(state);
          return PlatformInfo.isIOS
              ? CupertinoPage(
                  key: state.pageKey,
                  child: ChatDetailScreen(
                    chatId: rideId,
                    receiver: receiver,
                    isGroup: true,
                  ),
                )
              : MaterialPage(
                  key: state.pageKey,
                  child: ChatDetailScreen(
                    chatId: rideId,
                    receiver: receiver,
                    isGroup: true,
                  ),
                );
        },
      ),
    ];
  }
}
