import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/features/legal/views/legal_screen.dart';

/// Legal module routes
class LegalRoutes {
  List<RouteBase> getRoutes() {
    return [
      GoRoute(
        path: AppRoutes.terms.path,
        name: AppRoutes.terms.name,
        pageBuilder: (context, state) => PlatformInfo.isIOS
            ? CupertinoPage(
                key: state.pageKey,
                child: const LegalScreen(type: LegalDocumentType.terms),
              )
            : MaterialPage(
                key: state.pageKey,
                child: const LegalScreen(type: LegalDocumentType.terms),
              ),
      ),
      GoRoute(
        path: AppRoutes.privacy.path,
        name: AppRoutes.privacy.name,
        pageBuilder: (context, state) => PlatformInfo.isIOS
            ? CupertinoPage(
                key: state.pageKey,
                child: const LegalScreen(type: LegalDocumentType.privacy),
              )
            : MaterialPage(
                key: state.pageKey,
                child: const LegalScreen(type: LegalDocumentType.privacy),
              ),
      ),
    ];
  }
}
