import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/messaging/models/message_model.dart';
import 'package:sport_connect/core/services/talker_service.dart';

part 'deep_link_service.g.dart';

/// Route handler helper class.
class _RouteHandler {
  final RegExp pattern;
  final String routeName;
  final String? paramKey;

  const _RouteHandler({
    required this.pattern,
    required this.routeName,
    this.paramKey,
  });
}

/// Handles incoming deep links and routes them to the appropriate screen.
///
/// Supports:
/// - Custom URL schemes: `sportconnect://ride/abc123`, `sc://ride/abc123`
/// - App Links (HTTPS): `https://sportaxitrip.com/ride/abc123`
///
/// Format: scheme://host/path
/// Examples:
/// - sportconnect://ride/abc123
/// - sportconnect://open/ride/abc123
/// - sc://ride/abc123
/// - https://sportaxitrip.com/ride/abc123
class DeepLinkService {
  DeepLinkService() : _appLinks = AppLinks();

  /// Singleton instance for convenient static access.
  static final DeepLinkService instance = DeepLinkService();

  final AppLinks _appLinks;
  StreamSubscription<Uri>? _subscription;

  CollectionReference<UserModel> get _usersCollection => FirebaseFirestore
      .instance
      .collection(AppConstants.usersCollection)
      .withConverter<UserModel>(
        fromFirestore: (snap, _) => UserModel.fromJson(snap.data()!),
        toFirestore: (user, _) => user.toJson(),
      );

  CollectionReference<ChatModel> get _chatsCollection => FirebaseFirestore
      .instance
      .collection(AppConstants.chatsCollection)
      .withConverter<ChatModel>(
        fromFirestore: (snap, _) => ChatModel.fromJson(snap.data()!),
        toFirestore: (chat, _) => chat.toJson(),
      );

  /// Primary custom URL scheme
  static const String primaryScheme = 'sportconnect';

  /// Short custom URL scheme
  static const String shortScheme = 'sc';

  /// Firebase Hosting domain for HTTPS deep links.
  ///
  /// HTTPS links work in WhatsApp, Messenger, and other messaging platforms.
  static const String hostingDomain = 'sportaxitrip.com';

  /// Supported schemes
  static const List<String> supportedSchemes = [primaryScheme, shortScheme];

  /// Generates a shareable deep link for a ride.
  ///
  /// Returns an HTTPS link using Firebase Hosting:
  /// `https://sportaxitrip.com/ride/{rideId}`.
  ///
  /// HTTPS links work correctly in WhatsApp, Messenger, and other
  /// messaging platforms, unlike custom URL schemes.
  Future<String> generateRideLink({
    required String rideId,
    required String fromCity,
    required String toCity,
    required double price,
    required int seats,
    required DateTime departureTime,
  }) async {
    final uri = Uri(
      scheme: 'https',
      host: hostingDomain,
      path: '/ride/$rideId',
      queryParameters: {
        'from': fromCity,
        'to': toCity,
        'price': price.toStringAsFixed(0),
        'seats': seats.toString(),
        'date': departureTime.toIso8601String(),
      },
    );
    return uri.toString();
  }

  /// Initializes deep link listening.
  ///
  /// Handles App Links / Custom URL schemes (app_links package).
  ///
  /// Call this once from the app's root widget after the router is ready.
  Future<void> initialize(BuildContext context) async {
    try {
      // Handle App Links / Custom URL schemes
      await _initializeAppLinks(context);

      TalkerService.info('✅ Deep link service initialized');
    } catch (e, stackTrace) {
      TalkerService.error('❌ Failed to initialize deep links', e, stackTrace);
    }
  }

  /// Initialize standard App Links (sportconnect://, sc://)
  Future<void> _initializeAppLinks(BuildContext context) async {
    final router = GoRouter.of(context);

    // Handle the initial link (app opened via link while closed)
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      TalkerService.info('🔗 Initial App Link: $initialUri');
      await _handleDeepLink(router, initialUri);
    }

    // Listen for subsequent links (app already running)
    _subscription = _appLinks.uriLinkStream.listen(
      (uri) {
        TalkerService.info('🔗 Incoming App Link: $uri');
        unawaited(_handleDeepLink(router, uri));
      },
      onError: (error) {
        TalkerService.error('❌ App Link error', error);
      },
    );
  }

  /// Parses the URI and navigates to the appropriate screen.
  Future<void> _handleDeepLink(GoRouter router, Uri uri) async {
    final path = _extractPath(uri);
    if (path == null) {
      TalkerService.warning('⚠️ Unrecognized deep link: $uri');
      return;
    }

    TalkerService.info('🔗 Parsed path: $path');

    // Route patterns
    final handlers = [
      // Ride detail: /ride/{id}
      _RouteHandler(
        pattern: RegExp(r'^/ride/([a-zA-Z0-9_-]+)$'),
        routeName: AppRoutes.rideDetail.name,
        paramKey: 'id',
      ),
      // Chat detail: /chat/detail/{id}
      _RouteHandler(
        pattern: RegExp(r'^/chat/detail/([a-zA-Z0-9_-]+)$'),
        routeName: AppRoutes.chatDetail.name,
        paramKey: 'id',
      ),
      // Chat ride: /chat/ride/{id}
      _RouteHandler(
        pattern: RegExp(r'^/chat/ride/([a-zA-Z0-9_-]+)$'),
        routeName: AppRoutes.chatRide.name,
        paramKey: 'id',
      ),
      // Profile: /profile
      _RouteHandler(
        pattern: RegExp(r'^/profile$'),
        routeName: AppRoutes.profile.name,
      ),
      // Edit profile: /edit-profile
      _RouteHandler(
        pattern: RegExp(r'^/edit-profile$'),
        routeName: AppRoutes.editProfile.name,
      ),
      // Driver vehicles: /driver/vehicles
      _RouteHandler(
        pattern: RegExp(r'^/driver/vehicles$'),
        routeName: AppRoutes.driverVehicles.name,
      ),
      // Notifications: /notifications
      _RouteHandler(
        pattern: RegExp(r'^/notifications$'),
        routeName: AppRoutes.notifications.name,
      ),
    ];

    for (final handler in handlers) {
      final match = handler.pattern.firstMatch(path);
      if (match != null) {
        TalkerService.info('🔗 Matching route: ${handler.routeName}');
        if (handler.paramKey != null) {
          final routeId = match.group(1)!;
          if (handler.routeName == AppRoutes.chatDetail.name ||
              handler.routeName == AppRoutes.chatRide.name) {
            final receiver = await _resolveReceiverForChat(chatId: routeId);
            if (receiver == null) {
              TalkerService.warning(
                'Could not resolve receiver for deep-link chat $routeId; '
                'redirecting to notifications.',
              );
              router.pushNamed(AppRoutes.notifications.name);
              return;
            }

            router.pushNamed(
              handler.routeName,
              pathParameters: {handler.paramKey!: routeId},
              extra: receiver,
            );
          } else {
            router.pushNamed(
              handler.routeName,
              pathParameters: {handler.paramKey!: routeId},
            );
          }
        } else {
          router.pushNamed(handler.routeName);
        }
        return;
      }
    }

    TalkerService.warning('⚠️ No route matched for deep link path: $path');
  }

  Future<UserModel?> _resolveReceiverForChat({required String chatId}) async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      final chat = await _chatsCollection
          .doc(chatId)
          .get()
          .then((s) => s.data());
      if (chat == null) return null;

      if (chat.type != ChatType.private) {
        final title = chat.groupName ?? chat.getChatTitle(currentUserId ?? '');
        return UserModel.rider(
          uid: chatId,
          email: '',
          displayName: title.isEmpty ? 'Group Chat' : title,
          photoUrl: chat.groupPhotoUrl,
        );
      }

      final otherParticipant = currentUserId == null
          ? null
          : chat.getOtherParticipant(currentUserId);
      final participantId = otherParticipant?.odid;

      if (participantId != null && participantId.isNotEmpty) {
        final fullUser = await _usersCollection
            .doc(participantId)
            .get()
            .then((s) => s.data());
        if (fullUser != null) return fullUser;
      }

      if (otherParticipant == null) return null;
      return UserModel.rider(
        uid: participantId ?? chatId,
        email: '',
        displayName: otherParticipant.displayName,
        photoUrl: otherParticipant.photoUrl,
      );
    } catch (e) {
      TalkerService.error('Failed to resolve chat receiver from deep link', e);
      return null;
    }
  }

  /// Extracts the path from a deep link URI.
  ///
  /// Handles:
  /// - Custom URL schemes: sportconnect://ride/123, sc://ride/123
  /// - HTTPS App Links: https://sportaxitrip.com/ride/123
  String? _extractPath(Uri uri) {
    final scheme = uri.scheme.toLowerCase();
    final host = uri.host.toLowerCase();

    // Handle HTTPS App Links from Firebase Hosting
    if (scheme == 'https' && host == hostingDomain) {
      return uri.path;
    }

    // Handle custom URL schemes
    if (!supportedSchemes.contains(scheme)) {
      return null;
    }

    // For sportconnect://open/ride/123, the host is "open" and path is "/ride/123"
    // For sportconnect://ride/123, the host is "ride" and path is "/123"
    // For sc://ride/123, the host is "ride" and path is "/123"

    String path;
    if (host == 'open' || host.isEmpty) {
      // sportconnect://open/ride/123 or sc://ride/123 (host empty)
      path = uri.path;
    } else {
      // sportconnect://ride/123
      path = '/$host${uri.path}';
    }

    // Ensure path starts with /
    if (!path.startsWith('/')) {
      path = '/$path';
    }

    return path;
  }

  /// Cleans up the link stream subscription.
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}

/// Provides the [DeepLinkService] singleton.
@Riverpod(keepAlive: true)
DeepLinkService deepLinkService(Ref ref) {
  final service = DeepLinkService();
  ref.onDispose(service.dispose);
  return service;
}
