import 'dart:async';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_devtools_tracker/riverpod_devtools_tracker.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Config & Services
import 'package:sport_connect/core/config/app_router.dart';
import 'package:sport_connect/core/config/stripe_config.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/repositories/settings_repository.dart';
import 'package:sport_connect/core/services/deep_link_service.dart';
import 'package:sport_connect/core/services/firebase_service.dart';
import 'package:sport_connect/core/services/push_notification_service.dart';
import 'package:sport_connect/core/services/stripe_service.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/core/theme/cupertino_app_theme.dart';
import 'package:sport_connect/core/theme/material_app_theme.dart';
import 'package:sport_connect/features/profile/view_models/settings_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';
import 'package:upgrader/upgrader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Only fast, local work before runApp so the native launch screen dismisses
  // immediately. Network-dependent work (App Check, Crashlytics collection
  // toggle) is deferred to _initializeAppAfterFirstFrame.
  //
  // Wrapped in try-catch with a timeout: if Firebase.initializeApp() hangs
  // (seen on some iPadOS versions), we still call runApp() so the Flutter
  // splash renders and its 10-second timeout safely redirects the user.
  // Start Firebase and SharedPreferences in parallel — they're independent.
  FirebaseService? firebase;
  final firebaseFuture = FirebaseService.instance.initializeCore().timeout(
    const Duration(seconds: 8),
  );
  final prefsFuture = SharedPreferences.getInstance();

  try {
    firebase = await firebaseFuture;
    TalkerService.info('✅ Firebase core initialized');
  } on TimeoutException {
    TalkerService.error(
      '❌ Firebase initialization timed out — continuing without Firebase',
    );
  } on Exception catch (e, st) {
    TalkerService.error(
      '❌ Firebase initialization failed — continuing without Firebase',
      e,
      st,
    );
  }

  if (firebase != null) {
    FlutterError.onError = (details) {
      unawaited(firebase!.crashlytics.recordFlutterFatalError(details));
      TalkerService.error(
        'FlutterError: ${details.exceptionAsString()}',
        details.exception,
        details.stack,
      );
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      unawaited(firebase!.crashlytics.recordError(error, stack, fatal: true));
      TalkerService.error('PlatformDispatcher error', error, stack);
      return true;
    };
  }

  final prefs = await prefsFuture;

  _runApp(prefs);
}

/// Runs non-critical startup work after the first frame.
///
/// This prevents App Review/users from getting stuck on the native launch
/// screen if push notifications, Stripe, App Check, or other
/// network-related startup work is slow.
Future<void> _initializeAppAfterFirstFrame() async {
  TalkerService.info('🚀 Starting post-launch initialization...');

  // App Check activation makes a network call on production iOS (DeviceCheck).
  // Running it here keeps the native splash short.
  await FirebaseService.instance.activateAppCheck();
  await _initializePushNotifications();
  await _initializeStripe();

  TalkerService.info('✅ Post-launch initialization completed');
}

Future<void> _initializePushNotifications() async {
  if (kIsWeb) return;

  try {
    // FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await PushNotificationService.instance.initialize().timeout(
      const Duration(seconds: 6),
    );

    TalkerService.info('✅ Push notifications initialized');
  } on Exception catch (e, st) {
    TalkerService.error('❌ Failed to initialize push notifications', e, st);
  }
}

Future<void> _initializeStripe() async {
  try {
    if (!StripeConfig.isConfigured) {
      TalkerService.warning('⚠️ Stripe not configured - payments disabled.');
      return;
    }

    await StripeService()
        .initialize(
          publishableKey: StripeConfig.publishableKey,
        )
        .timeout(const Duration(seconds: 6));

    TalkerService.info('✅ Stripe initialized');
  } on Exception catch (e, st) {
    TalkerService.error('❌ Failed to initialize Stripe', e, st);
  }
}

void _runApp(SharedPreferences prefs) {
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      observers: [
        if (kDebugMode) ...[
          TalkerService.riverpodObserver,
          RiverpodDevToolsObserver(
            config: TrackerConfig.forPackage('com.sportconnect.app'),
          ),
        ],
      ],
      child: const SportConnectApp(),
    ),
  );
}

class SportConnectApp extends ConsumerStatefulWidget {
  const SportConnectApp({super.key});

  @override
  ConsumerState<SportConnectApp> createState() => _SportConnectAppState();
}

class _SportConnectAppState extends ConsumerState<SportConnectApp> {
  bool _deepLinksInitialized = false;
  bool _fcmTokenSaved = false;
  bool _postLaunchStartupStarted = false;
  bool _postLaunchStartupCompleted = false;
  bool _showUpgradeAlert = false;

  ProviderSubscription<AsyncValue<User?>>? _authSubscription;

  bool get _isFirebaseInitialized => Firebase.apps.isNotEmpty;

  @override
  void initState() {
    super.initState();

    _authSubscription = ref.listenManual(authStateProvider, (prev, next) {
      if (!_isFirebaseInitialized) return;

      if (next.value != null) {
        if (_postLaunchStartupCompleted) {
          _saveFcmTokenIfNeeded();
        }
      } else {
        _fcmTokenSaved = false;
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_runPostLaunchStartup());
    });
  }

  @override
  void dispose() {
    _authSubscription?.close();
    super.dispose();
  }

  Future<void> _runPostLaunchStartup() async {
    if (_postLaunchStartupStarted) return;

    _postLaunchStartupStarted = true;

    await _initializeAppAfterFirstFrame();

    if (!mounted) return;

    _postLaunchStartupCompleted = true;

    if (_isFirebaseInitialized) {
      final router = ref.read(appRouterProvider);
      _initializeDeepLinks(router);
      _saveFcmTokenIfNeeded();
    }

    if (!mounted) return;

    setState(() {
      _showUpgradeAlert = true;
    });
  }

  void _initializeDeepLinks(GoRouter router) {
    if (_deepLinksInitialized || !_isFirebaseInitialized) return;

    _deepLinksInitialized = true;

    PushNotificationService.navigatorKey = rootNavigatorKey;

    unawaited(ref.read(deepLinkServiceProvider).initialize(router));

    final context = rootNavigatorKey.currentContext;

    if (context != null && mounted) {
      ref
          .read(pushNotificationServiceProvider)
          .handlePendingInitialMessage(context);
    }
  }

  void _saveFcmTokenIfNeeded() {
    if (_fcmTokenSaved || !_isFirebaseInitialized) return;
    if (!_postLaunchStartupCompleted) return;

    final authUser = ref.read(authStateProvider).value;

    if (authUser != null) {
      _fcmTokenSaved = true;

      unawaited(
        ref.read(pushNotificationServiceProvider).saveFcmToken(authUser.uid),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(settingsViewModelProvider.select((s) => s.locale));

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return AdaptiveApp.router(
          title: 'SportConnect',
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          themeMode: ThemeMode.light,
          materialLightTheme: AppMaterialTheme.lightTheme,
          materialDarkTheme: AppMaterialTheme.lightTheme,
          cupertinoLightTheme: AppCupertinoTheme.lightTheme,
          cupertinoDarkTheme: AppCupertinoTheme.lightTheme,
          routerConfig: router,
          builder: (context, child) {
            final appChild = child ?? const SizedBox.shrink();

            var wrappedChild = appChild;

            if (_isFirebaseInitialized && _showUpgradeAlert) {
              wrappedChild = UpgradeAlert(
                navigatorKey: rootNavigatorKey,
                dialogStyle: UpgradeDialogStyle.cupertino,
                showIgnore: false,
                showReleaseNotes: false,
                child: appChild,
              );
            }

            return _DismissKeyboardOnTap(child: wrappedChild);
          },
        );
      },
    );
  }
}

class _DismissKeyboardOnTap extends StatelessWidget {
  const _DismissKeyboardOnTap({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) {
        final currentFocus = FocusManager.instance.primaryFocus;

        if (currentFocus == null || !currentFocus.hasFocus) return;

        currentFocus.unfocus();
      },
      child: child,
    );
  }
}
