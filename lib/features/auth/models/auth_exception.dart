/// Typed exception for authentication errors.
///
/// Wraps Firebase error codes into a catchable exception with a
/// user-friendly [message]. The original [code] is preserved so callers
/// can branch on specific error types (e.g. `requires-recent-login`).
class AuthException implements Exception {
  const AuthException({required this.code, required this.message});

  /// Firebase error code (e.g. `wrong-password`, `user-not-found`).
  final String code;

  /// Human-readable error message.
  final String message;

  @override
  String toString() => message;
}
