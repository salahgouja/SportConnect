import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

abstract final class AppLocaleFormatters {
  static String localeTag(BuildContext context) =>
      Localizations.localeOf(context).toLanguageTag();

  static String formatMonthDay(BuildContext context, DateTime value) =>
      DateFormat.Md(localeTag(context)).format(value);

  static String formatTime(BuildContext context, DateTime value) =>
      DateFormat.jm(localeTag(context)).format(value);

  static String formatMediumDateTime(BuildContext context, DateTime value) =>
      DateFormat.yMMMd(localeTag(context)).add_jm().format(value);

  static String formatMediumDate(BuildContext context, DateTime value) =>
      DateFormat.yMMMd(localeTag(context)).format(value);

  static String formatShortDateTime(BuildContext context, DateTime value) =>
      DateFormat.yMd(localeTag(context)).add_jm().format(value);

  static String formatMonthDayTime(BuildContext context, DateTime value) =>
      DateFormat.MMMd(localeTag(context)).add_jm().format(value);

  static String formatMonthYear(BuildContext context, DateTime value) =>
      DateFormat.yMMMM(localeTag(context)).format(value);

  static String formatShortDateLabel(BuildContext context, DateTime value) =>
      DateFormat.MMMd(localeTag(context)).format(value);

  static String formatShortWeekdayDateTime(
    BuildContext context,
    DateTime value,
  ) => DateFormat.MMMEd(localeTag(context)).add_jm().format(value);

  static String formatWeekdayDayMonth(BuildContext context, DateTime value) =>
      DateFormat('EEEE, d MMM', localeTag(context)).format(value);

  static String formatMonthLabel(BuildContext context, DateTime value) =>
      DateFormat.MMM(localeTag(context)).format(value).toUpperCase();

  static String formatDayNumber(BuildContext context, DateTime value) =>
      DateFormat.d(localeTag(context)).format(value);

  static String formatCurrency(
    BuildContext context,
    num amount, {
    String currencyCode = 'EUR',
    int decimalDigits = 2,
  }) {
    return NumberFormat.simpleCurrency(
      locale: localeTag(context),
      name: currencyCode,
      decimalDigits: decimalDigits,
    ).format(amount);
  }

  static String formatCurrencyFromCents(
    BuildContext context,
    int amountInCents, {
    String currencyCode = 'EUR',
    int decimalDigits = 2,
  }) {
    return formatCurrency(
      context,
      amountInCents / 100,
      currencyCode: currencyCode,
      decimalDigits: decimalDigits,
    );
  }

  static String formatRelativeTime(BuildContext context, DateTime? value) {
    if (value == null) return '';

    final l10n = AppLocalizations.of(context);
    final difference = DateTime.now().difference(value);

    if (difference.inMinutes < 1) return l10n.timeNow;
    if (difference.inMinutes < 60) {
      return l10n.relativeMinutesShort(difference.inMinutes);
    }
    if (difference.inHours < 24) {
      return l10n.relativeHoursShort(difference.inHours);
    }
    if (difference.inDays < 7) {
      return l10n.relativeDaysShort(difference.inDays);
    }
    return formatMonthDay(context, value);
  }
}
