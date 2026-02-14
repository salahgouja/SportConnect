import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/providers/settings_provider.dart';

part 'distance_formatter.g.dart';

/// Conversion factor from km to miles
const double _kmToMiles = 0.621371;

/// Formats a distance in km according to the user's distance unit preference.
///
/// Returns a formatted string like "12.3 km" or "7.6 mi".
String formatDistance(double km, String unit) {
  if (unit == 'miles') {
    final miles = km * _kmToMiles;
    return '${miles.toStringAsFixed(1)} mi';
  }
  return '${km.toStringAsFixed(1)} km';
}

/// Converts km to the user's preferred unit value (without unit label).
double convertDistance(double km, String unit) {
  if (unit == 'miles') {
    return km * _kmToMiles;
  }
  return km;
}

/// Provider that exposes a distance formatting function using the saved unit.
@riverpod
String Function(double km) distanceFormatter(Ref ref) {
  final unit = ref.watch(distanceUnitProviderProvider).value ?? 'km';
  return (double km) => formatDistance(km, unit);
}
