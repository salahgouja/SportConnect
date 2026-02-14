import 'package:flutter/foundation.dart';

/// Base result type for operations that can fail
///
/// Usage:
/// ```dart
/// Future<Result<User>> getUser(String id) async {
///   try {
///     final user = await _repository.getUser(id);
///     return Result.success(user);
///   } catch (e) {
///     return Result.failure(AppError.fromException(e));
///   }
/// }
///
/// // Handling result
/// final result = await getUser('123');
/// result.when(
///   success: (user) => print('Got user: $user'),
///   failure: (error) => print('Error: $error'),
/// );
/// ```
@immutable
sealed class Result<T> {
  const Result._();

  /// Creates a successful result
  const factory Result.success(T data) = Success<T>;

  /// Creates a failure result
  const factory Result.failure(AppError error) = Failure<T>;

  /// Pattern matching on result
  R when<R>({
    required R Function(T data) success,
    required R Function(AppError error) failure,
  });

  /// Map success value to another type
  Result<R> map<R>(R Function(T data) mapper) {
    return when(
      success: (data) => Result.success(mapper(data)),
      failure: (error) => Result.failure(error),
    );
  }

  /// Flat map for chaining operations
  Result<R> flatMap<R>(Result<R> Function(T data) mapper) {
    return when(
      success: (data) => mapper(data),
      failure: (error) => Result.failure(error),
    );
  }

  /// Get data or null
  T? get dataOrNull => when(success: (data) => data, failure: (_) => null);

  /// Get error or null
  AppError? get errorOrNull =>
      when(success: (_) => null, failure: (error) => error);

  /// Check if result is success
  bool get isSuccess => this is Success<T>;

  /// Check if result is failure
  bool get isFailure => this is Failure<T>;
}

/// Success result
@immutable
final class Success<T> extends Result<T> {
  final T data;

  const Success(this.data) : super._();

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(AppError error) failure,
  }) {
    return success(data);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'Success($data)';
}

/// Failure result
@immutable
final class Failure<T> extends Result<T> {
  final AppError error;

  const Failure(this.error) : super._();

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(AppError error) failure,
  }) {
    return failure(error);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<T> &&
          runtimeType == other.runtimeType &&
          error == other.error;

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'Failure($error)';
}

/// Application error types
@immutable
class AppError {
  final String message;
  final String? code;
  final Object? originalError;
  final StackTrace? stackTrace;
  final ErrorType type;

  const AppError({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
    this.type = ErrorType.unknown,
  });

  /// Create from exception
  factory AppError.fromException(Object error, [StackTrace? stackTrace]) {
    if (error is AppError) return error;

    return AppError(
      message: error.toString(),
      originalError: error,
      stackTrace: stackTrace,
      type: _inferErrorType(error),
    );
  }

  /// Create a network error
  factory AppError.network({String? message}) {
    return AppError(
      message: message ?? 'Network error occurred',
      type: ErrorType.network,
    );
  }

  /// Create an authentication error
  factory AppError.auth({String? message, String? code}) {
    return AppError(
      message: message ?? 'Authentication failed',
      code: code,
      type: ErrorType.authentication,
    );
  }

  /// Create a validation error
  factory AppError.validation({required String message}) {
    return AppError(message: message, type: ErrorType.validation);
  }

  /// Create a not found error
  factory AppError.notFound({String? message}) {
    return AppError(
      message: message ?? 'Resource not found',
      type: ErrorType.notFound,
    );
  }

  /// Create a permission error
  factory AppError.permission({String? message}) {
    return AppError(
      message: message ?? 'Permission denied',
      type: ErrorType.permission,
    );
  }

  /// Create a server error
  factory AppError.server({String? message, String? code}) {
    return AppError(
      message: message ?? 'Server error occurred',
      code: code,
      type: ErrorType.server,
    );
  }

  /// Create an unknown error
  factory AppError.unknown({String? message}) {
    return AppError(
      message: message ?? 'An unexpected error occurred',
      type: ErrorType.unknown,
    );
  }

  static ErrorType _inferErrorType(Object error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') ||
        errorString.contains('socket') ||
        errorString.contains('connection')) {
      return ErrorType.network;
    }
    if (errorString.contains('auth') ||
        errorString.contains('permission') ||
        errorString.contains('unauthorized')) {
      return ErrorType.authentication;
    }
    if (errorString.contains('not found') || errorString.contains('404')) {
      return ErrorType.notFound;
    }
    if (errorString.contains('validation') || errorString.contains('invalid')) {
      return ErrorType.validation;
    }

    return ErrorType.unknown;
  }

  /// Get user-friendly message
  String get userMessage {
    switch (type) {
      case ErrorType.network:
        return 'Please check your internet connection and try again.';
      case ErrorType.authentication:
        return 'Please sign in again to continue.';
      case ErrorType.validation:
        return message;
      case ErrorType.notFound:
        return 'The requested item could not be found.';
      case ErrorType.permission:
        return 'You don\'t have permission to perform this action.';
      case ErrorType.server:
        return 'Something went wrong on our end. Please try again later.';
      case ErrorType.unknown:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppError &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          code == other.code &&
          type == other.type;

  @override
  int get hashCode => Object.hash(message, code, type);

  @override
  String toString() => 'AppError(type: $type, message: $message, code: $code)';
}

/// Error type categorization
enum ErrorType {
  network,
  authentication,
  validation,
  notFound,
  permission,
  server,
  unknown,
}

/// Extension to handle Future results
extension FutureResultExtension<T> on Future<T> {
  /// Convert a Future to Result
  Future<Result<T>> toResult() async {
    try {
      final data = await this;
      return Result.success(data);
    } catch (e, stackTrace) {
      return Result.failure(AppError.fromException(e, stackTrace));
    }
  }
}
