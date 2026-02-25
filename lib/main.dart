import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_devtools_tracker/riverpod_devtools_tracker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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

/// Application entry point
///
/// Initializes all services and runs the app with proper error handling.
/// Crashlytics captures both Flutter framework errors and asynchronous errors.
void main() async {
  await _initializeApp();

  // Capture Flutter framework errors (widget build failures, etc.)
  FlutterError.onError = (details) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    // Also log locally for debug visibility
    TalkerService.error(
      'FlutterError: ${details.exceptionAsString()}',
      details.exception,
      details.stack,
    );
  };

  // Capture asynchronous errors not caught by Flutter framework
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    TalkerService.error('PlatformDispatcher error', error, stack);
    return true;
  };

  _runApp();
}

/// Initialize all application services
///
/// Services are initialized in dependency order:
/// 1. Flutter bindings
/// 2. Logging (for debugging other initializations)
/// 3. Firebase (core infrastructure)
/// 4. Push notifications (FCM + local)
/// 6. Payments (Stripe)
Future<void> _initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Logging - First, so we can log other initializations
  TalkerService.info('🚀 Starting SportConnect App...');

  // 2. Firebase - Core infrastructure
  await FirebaseService.initialize();
  TalkerService.info('✅ Firebase initialized');

  // 3. Push notifications — register background handler, init channels
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await PushNotificationService.instance.initialize();
  TalkerService.info('✅ Push notifications initialized');

  // 4. Analytics & Crashlytics
  await AnalyticsService.instance.initialize();

  // 5. Payments
  await _initializeStripe();
}

/// Initialize Stripe with error handling
///
/// Stripe initialization is non-blocking - the app can function
/// without payments if configuration is missing.
Future<void> _initializeStripe() async {
  try {
    if (!StripeConfig.isConfigured) {
      TalkerService.warning(
        '⚠️ Stripe not configured - payments will be disabled.',
      );
      return;
    }
    await StripeService().initialize(
      publishableKey: StripeConfig.publishableKey,
    );
    TalkerService.info(
      '✅ Stripe initialized (${StripeConfig.configurationStatus})',
    );
  } catch (e, stackTrace) {
    TalkerService.error('❌ Failed to initialize Stripe', e, stackTrace);
  }
}

/// Run the application with proper provider scope
void _runApp() {
  runApp(
    ProviderScope(
      observers: [
        TalkerService.riverpodObserver,
        RiverpodDevToolsObserver(
          config: TrackerConfig.forPackage('com.sportconnect.app'),
        ),
      ],
      child: DevicePreview(
        enabled: kDebugMode, // Enable only in debug mode
        builder: (context) => const SportConnectApp(),
      ),
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

  void _initializeDeepLinks(BuildContext context) {
    if (_deepLinksInitialized) return;
    _deepLinksInitialized = true;

    // Wire up the navigator key so notification taps can navigate
    PushNotificationService.navigatorKey = rootNavigatorKey;

    // Initialize after first frame so the router is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(deepLinkServiceProvider).initialize(context);
        // Handle any pending notification that launched the app
        PushNotificationService.instance.handlePendingInitialMessage(context);
      }
    });
  }

  /// Save FCM token when user is authenticated
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
    // Watch the GoRouter provider so the app rebuilds if the router changes
    final router = ref.watch(appRouterProvider);

    // Watch auth state to save FCM token when user logs in
    ref.listen(authStateProvider, (prev, next) {
      if (next.value != null) {
        _saveFcmTokenIfNeeded();
      } else {
        _fcmTokenSaved = false; // Reset on sign-out
      }
    });
    _saveFcmTokenIfNeeded(); // Also check on initial build

    // Watch locale provider - app rebuilds when language changes
    final localeAsync = ref.watch(localeProviderProvider);
    final locale = localeAsync.value; // null = use system locale

    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X/11/12/13 standard width
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        // Initialize deep links after the widget tree is ready
        _initializeDeepLinks(context);

        return MaterialApp.router(
          title: 'SportConnect',
          debugShowCheckedModeBanner: false,

          // --- Localization ---
          locale: locale ?? DevicePreview.locale(context),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English
            Locale('fr'), // French
            Locale('de'), // German
            Locale('es'), // Spanish
          ],

          // --- Device Preview Config ---
          builder: (context, child) {
            // Apply Device Preview logic
            final wrapped = DevicePreview.appBuilder(context, child);

            // Wrap everything in Debug Overlay (Talker)
            return wrapped;
          },

          // --- Theming ---
          themeMode: ThemeMode.light,
          theme: AppTheme.lightTheme.copyWith(
            appBarTheme: AppTheme.lightTheme.appBarTheme.copyWith(
              systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness:
                    Brightness.dark, // Dark icons on light bg
              ),
            ),
          ),

          // --- Navigation ---
          routerConfig: router,
        );
      },
    );
  }
}
