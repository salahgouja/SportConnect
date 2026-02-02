import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/config/app_router.dart';
import 'package:sport_connect/core/config/firebase_ui_config.dart';
import 'package:sport_connect/core/config/stripe_config.dart';
import 'package:sport_connect/core/services/firebase_service.dart';
import 'package:sport_connect/core/services/stripe_service.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/core/theme/app_theme.dart';
import 'package:sport_connect/core/widgets/debug_overlay.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:device_preview/device_preview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Talker for logging
  TalkerService.info('🚀 Starting SportConnect App...');

  // Initialize Firebase (includes emulator setup if in debug mode)
  await FirebaseService.initialize();
  TalkerService.info('✅ Firebase initialized');

  // Configure Firebase UI Auth providers
  FirebaseUIConfig.configureProviders();
  TalkerService.info('✅ Firebase UI Auth configured');

  // Initialize Hive for local storage
  await Hive.initFlutter();
  TalkerService.info('✅ Hive initialized');

  // Initialize Stripe for payments
  await _initializeStripe();

  runApp(
    ProviderScope(
      observers: [
        TalkerService.riverpodObserver,
      ],
      child: DevicePreview(
        enabled: kDebugMode,
        builder: (context) => const SportConnectApp(),
      ),
    ),
  );
}

/// Initialize Stripe with configuration
Future<void> _initializeStripe() async {
  try {
    if (!StripeConfig.isConfigured) {
      TalkerService.warning('Stripe not configured - update StripeConfig values');
      TalkerService.warning('Payments will not work until configured');
      return;
    }

    await StripeService().initialize(
      publishableKey: StripeConfig.publishableKey,
    );

    TalkerService.info('Stripe initialized: ${StripeConfig.configurationStatus}');
  } catch (e, stackTrace) {
    TalkerService.error('Failed to initialize Stripe', e, stackTrace);
    // Don't crash the app - payments just won't work
  }
}

class SportConnectApp extends StatelessWidget {
  const SportConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'SportConnect',
          debugShowCheckedModeBanner: false,
          // Device Preview integration
          useInheritedMediaQuery: true,
          locale: DevicePreview.locale(context),
          builder: (context, child) {
            // Wrap with DevicePreview in debug mode
            Widget wrappedChild = SafeArea(top: false, child: child!);

            // Apply Device Preview builder
            wrappedChild = DevicePreview.appBuilder(context, wrappedChild);
            
            // Add Debug Overlay with FAB for Talker and Theme Playground
            return DebugOverlay(
              enabled: kDebugMode,
              child: wrappedChild,
            );
          },
          theme: AppTheme.lightTheme.copyWith(
            appBarTheme: AppTheme.lightTheme.appBarTheme.copyWith(
              systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark,
              ),
            ),
          ),
          darkTheme: AppTheme.darkTheme.copyWith(
            appBarTheme: AppTheme.darkTheme.appBarTheme.copyWith(
              systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
              ),
            ),
          ),
          themeMode: ThemeMode.light,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
