import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/config/routes/route_config.dart';
import 'package:sport_connect/features/messaging/views/chat_list_screen.dart';

/// Messaging module routes with type-safe parameters
///
/// NOTE: This file is for future modular routing architecture.
/// Currently not used - the main router in app_router.dart
/// handles messaging routes with proper parameter passing via GoRouterState.extra.
class MessagingRoutes implements RouteConfig {
  @override
  String get moduleName => 'messaging';

  @override
  String? get initialRoute => AppRoutes.chat.path;

  @override
  List<RouteBase> getRoutes() {
    return [
      // Chat list screen - primary entry point
      GoRoute(
        path: AppRoutes.chat.path,
        name: AppRoutes.chat.name,
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const ChatListScreen()),
      ),
      // NOTE: chatDetail, voiceCall, videoCall require passing complex objects
      // (UserModel receiver) through GoRouterState.extra, which is handled
      // in the main router (app_router.dart). These routes should
      // not be defined here until the modular routing is fully implemented.
    ];
  }
}
