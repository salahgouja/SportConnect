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
