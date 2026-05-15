import 'package:firebase_auth/firebase_auth.dart';
import 'package:sport_connect/features/auth/models/auth_exception.dart';

String userFacingError(
  Object error, {
  String fallback = 'Something went wrong. Please try again.',
}) {
  if (error is AuthException) {
    return error.message;
  }

  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again in a few minutes.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid credentials. Please check and try again.';
      case 'requires-recent-login':
        return 'Please sign in again to continue.';
      default:
        return error.message ?? fallback;
    }
  }

  if (error is FirebaseException) {
    switch (error.code) {
      case 'permission-denied':
        return 'You do not have permission to perform this action.';
      case 'unavailable':
        return 'Service is temporarily unavailable. Please try again.';
      case 'not-found':
        return 'Requested item was not found.';
      case 'failed-precondition':
        return 'This action cannot be completed right now.';
      default:
        break;
    }
  }

  final raw = error.toString();
  final cleaned = raw
      .replaceFirst('Exception: ', '')
      .replaceFirst('FirebaseException: ', '')
      .trim();

  if (cleaned.isEmpty || cleaned.toLowerCase() == 'null') {
    return fallback;
  }
  return cleaned;
}
