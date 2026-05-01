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

const _enableDebugInstrumentation = bool.fromEnvironment(
  'SPORT_CONNECT_DEBUG_INSTRUMENTATION',
);

void main() async {
  // 1. Ensure bindings are initialized first
  WidgetsFlutterBinding.ensureInitialized();

  final firebaseService = await FirebaseService.instance.initialize();
  TalkerService.info('✅ Firebase initialized');

  // 2. Set up error handling BEFORE initializing services
  FlutterError.onError = (details) async {
    await firebaseService.crashlytics.recordFlutterFatalError(details);
    TalkerService.error(
      'FlutterError: ${details.exceptionAsString()}',
      details.exception,
      details.stack,
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    firebaseService.crashlytics.recordError(error, stack, fatal: true);
    TalkerService.error('PlatformDispatcher error', error, stack);
    return true;
  };

  final prefs = await SharedPreferences.getInstance();

  // 3. Initialize with safety catch to prevent Splash Screen freeze
  try {
    await _initializeApp();
  } catch (e, st) {
    TalkerService.error('🚨 CRITICAL INITIALIZATION FAILURE', e, st);
  }

  _runApp(prefs);
}

Future<void> _initializeApp() async {
  TalkerService.info('🚀 Starting SportConnect App...');

  if (!kIsWeb) {
    // FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await PushNotificationService.instance.initialize();
    TalkerService.info('✅ Push notifications initialized');
  }

  await _initializeStripe();
}

Future<void> _initializeStripe() async {
  try {
    if (!StripeConfig.isConfigured) {
      TalkerService.warning('⚠️ Stripe not configured - payments disabled.');
      return;
    }
    await StripeService().initialize(
      publishableKey: StripeConfig.publishableKey,
    );
    TalkerService.info('✅ Stripe initialized');
  } catch (e, st) {
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
        if (kDebugMode && _enableDebugInstrumentation) ...[
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

  ProviderSubscription<AsyncValue<User?>>? _authSubscription;

  bool get _isFirebaseInitialized => Firebase.apps.isNotEmpty;

  @override
  void initState() {
    super.initState();

    _authSubscription = ref.listenManual(authStateProvider, (prev, next) {
      if (!_isFirebaseInitialized) return;

      if (next.value != null) {
        _saveFcmTokenIfNeeded();
      } else {
        _fcmTokenSaved = false;
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_isFirebaseInitialized) return;

      final router = ref.read(appRouterProvider);
      _initializeDeepLinks(router);
    });
  }

  @override
  void dispose() {
    _authSubscription?.close();
    super.dispose();
  }

  void _initializeDeepLinks(GoRouter router) {
    if (_deepLinksInitialized || !_isFirebaseInitialized) return;

    _deepLinksInitialized = true;

    PushNotificationService.navigatorKey = rootNavigatorKey;

    ref.read(deepLinkServiceProvider).initialize(router);

    final context = rootNavigatorKey.currentContext;
    if (context != null && mounted) {
      ref
          .read(pushNotificationServiceProvider)
          .handlePendingInitialMessage(context);
    }
  }

  void _saveFcmTokenIfNeeded() {
    if (_fcmTokenSaved || !_isFirebaseInitialized) return;

    final authUser = ref.read(authStateProvider).value;
    if (authUser != null) {
      _fcmTokenSaved = true;
      ref.read(pushNotificationServiceProvider).saveFcmToken(authUser.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final localeAsync = ref.watch(settingsViewModelProvider).locale;

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return AdaptiveApp.router(
          title: 'SportConnect',
          locale: localeAsync,
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

            if (!_isFirebaseInitialized) {
              return _DismissKeyboardOnTap(child: appChild);
            }

            return _DismissKeyboardOnTap(
              child: UpgradeAlert(child: appChild),
            );
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
