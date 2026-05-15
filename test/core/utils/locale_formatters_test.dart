import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sport_connect/core/utils/locale_formatters.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

void main() {
  Widget host({
    required Locale locale,
    required Widget child,
  }) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );
  }

  testWidgets('formats relative time with localized short labels', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        locale: const Locale('fr'),
        child: Builder(
          builder: (context) => Text(
            AppLocaleFormatters.formatRelativeTime(
              context,
              DateTime.now().subtract(const Duration(hours: 3)),
            ),
          ),
        ),
      ),
    );

    expect(find.text('3 h'), findsOneWidget);
  });

  testWidgets('formats EUR currency with locale-aware separators', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        locale: const Locale('en'),
        child: Builder(
          builder: (context) => Text(
            AppLocaleFormatters.formatCurrencyFromCents(context, 12345),
          ),
        ),
      ),
    );

    expect(find.textContaining('123.45'), findsOneWidget);
  });
}
