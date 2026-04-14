import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_devtools_tracker/riverpod_devtools_tracker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';
// Config & Services
import 'package:sport_connect/core/config/app_router.dart';
import 'package:sport_connect/core/config/stripe_config.dart';
import 'package:sport_connect/core/services/analytics_service.dart';
import 'package:sport_connect/core/services/deep_link_service.dart';
import 'package:sport_connect/core/services/firebase_service.dart';
import 'package:sport_connect/core/services/push_notification_service.dart';
import 'package:sport_connect/core/services/stripe_service.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/core/theme/app_theme.dart';

// Localization
import 'package:sport_connect/l10n/generated/app_localizations.dart';
import 'package:sport_connect/core/providers/settings_provider.dart';
import 'package:sport_connect/core/providers/user_providers.dart';

void main() async {
  // 1. Ensure bindings are initialized first
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Set up error handling BEFORE initializing services
  FlutterError.onError = (details) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    TalkerService.error(
      'FlutterError: ${details.exceptionAsString()}',
      details.exception,
      details.stack,
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    TalkerService.error('PlatformDispatcher error', error, stack);
    return true;
  };

  // 3. Initialize with safety catch to prevent Splash Screen freeze
  try {
    await _initializeApp();
  } catch (e, stack) {
    TalkerService.error('🚨 CRITICAL INITIALIZATION FAILURE', e, stack);
  }

  _runApp();
}

Future<void> _initializeApp() async {
  TalkerService.info('🚀 Starting SportConnect App...');

  // Core Firebase
  await FirebaseService.instance.initialize();
  TalkerService.info('✅ Firebase initialized');

  if (defaultTargetPlatform != TargetPlatform.iOS) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await PushNotificationService.instance.initialize();
    TalkerService.info('✅ Push notifications initialized');
  }

  await AnalyticsService.instance.initialize();
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
  } catch (e, stackTrace) {
    TalkerService.error('❌ Failed to initialize Stripe', e, stackTrace);
  }
}

void _runApp() {
  runApp(
    ProviderScope(
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

  void _initializeDeepLinks(GoRouter router, BuildContext context) {
    if (_deepLinksInitialized) return;
    _deepLinksInitialized = true;

    PushNotificationService.navigatorKey = rootNavigatorKey;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(deepLinkServiceProvider).initialize(router);
        PushNotificationService.instance.handlePendingInitialMessage(context);
      }
    });
  }

  void _saveFcmTokenIfNeeded() {
    if (_fcmTokenSaved) return;
    final authUser = ref.read(authStateProvider).value;
    if (authUser != null) {
      _fcmTokenSaved = true;
      PushNotificationService.instance.saveFcmToken(authUser.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final localeAsync = ref.watch(localeProviderProvider);

    ref.listen(authStateProvider, (prev, next) {
      if (next.value != null) {
        _saveFcmTokenIfNeeded();
      } else {
        _fcmTokenSaved = false;
      }
    });

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        _initializeDeepLinks(router, context);

        return MaterialApp.router(
          title: 'SportConnect',
          debugShowCheckedModeBanner: false,
          locale: localeAsync.value,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          themeMode: ThemeMode.light,
          theme: AppTheme.lightTheme,
          routerConfig: router,
          builder: (context, child) {
            return child!;
          },
        );
      },
    );
  }
}
