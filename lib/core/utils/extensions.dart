import 'package:intl/intl.dart';

/// DateTime extensions
extension DateTimeExtensions on DateTime {
  /// Format as time (HH:mm)
  String toTimeString() {
    return DateFormat('HH:mm').format(this);
  }

  /// Format as date (dd/MM/yyyy)
  String toDateString() {
    return DateFormat('dd/MM/yyyy').format(this);
  }

  /// Format as date and time
  String toDateTimeString() {
    return DateFormat('dd/MM/yyyy HH:mm').format(this);
  }

  /// Relative time (e.g., "2 hours ago")
  String toRelativeTime() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}

/// String extensions
extension StringExtensions on String {
  /// Capitalize first letter
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Check if string is a valid email
  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  /// Truncate string with ellipsis
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }
}

/// Double extensions for distance
extension DoubleExtensions on double {
  /// Format distance in km
  String toDistanceString() {
    if (this < 1) {
      return '${(this * 1000).toStringAsFixed(0)} m';
    }
    return '${toStringAsFixed(1)} km';
  }
}
