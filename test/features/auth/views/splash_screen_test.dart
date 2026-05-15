import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sport_connect/features/auth/views/splash_screen.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

void main() {
  Widget buildApp(Size size) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: MediaQueryData(size: size),
            child: const SplashScreen(),
          ),
        );
      },
    );
  }

  testWidgets('shows tablet status card on medium screens', (tester) async {
    await tester.pumpWidget(buildApp(const Size(900, 900)));
    await tester.pump(const Duration(milliseconds: 16));

    expect(
      find.byKey(const ValueKey('splash_tablet_status_card')),
      findsOneWidget,
    );
  });

  testWidgets('keeps compact splash layout on phones', (tester) async {
    await tester.pumpWidget(buildApp(const Size(390, 844)));
    await tester.pump(const Duration(milliseconds: 16));

    expect(
      find.byKey(const ValueKey('splash_tablet_status_card')),
      findsNothing,
    );
  });
}
