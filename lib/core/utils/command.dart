/// Command pattern for handling UI events
///
/// Commands encapsulate user actions and provide standardized error handling.
/// They prevent rendering errors and standardize how the UI layer sends events
/// to the data layer.
///
/// Usage:
/// ```dart
/// final loginCommand = Command<void>(
///   action: () => authRepository.signIn(email, password),
///   onSuccess: () => showSnackbar('Logged in!'),
///   onError: (error) => showErrorDialog(error.userMessage),
/// );
///
/// // Execute command
/// await loginCommand.execute();
///
/// // Check state
/// if (loginCommand.isRunning) {
///   showLoader();
/// }
/// ```
library;
import 'package:flutter/foundation.dart';
import 'package:sport_connect/core/utils/result.dart';

/// A command that executes an async action with error handling
class Command<T> extends ChangeNotifier {
  final Future<T> Function() _action;
  final void Function(T result)? _onSuccess;
  final void Function(AppError error)? _onError;
  final void Function()? _onComplete;

  CommandState _state = CommandState.idle;
  AppError? _error;
  T? _result;

  Command({
    required Future<T> Function() action,
    void Function(T result)? onSuccess,
    void Function(AppError error)? onError,
    void Function()? onComplete,
  }) : _action = action,
       _onSuccess = onSuccess,
       _onError = onError,
       _onComplete = onComplete;

  /// Current state of the command
  CommandState get state => _state;

  /// Whether the command is currently running
  bool get isRunning => _state == CommandState.running;

  /// Whether the command is idle
  bool get isIdle => _state == CommandState.idle;

  /// Whether the command completed successfully
  bool get isSuccess => _state == CommandState.success;

  /// Whether the command failed
  bool get isError => _state == CommandState.error;

  /// Error from the last execution (if failed)
  AppError? get error => _error;

  /// Result from the last execution (if successful)
  T? get result => _result;

  /// Execute the command
  ///
  /// Returns the result wrapped in [Result] for error handling.
  Future<Result<T>> execute() async {
    if (_state == CommandState.running) {
      return Result.failure(
        AppError.validation(message: 'Command is already running'),
      );
    }

    _state = CommandState.running;
    _error = null;
    notifyListeners();

    try {
      final result = await _action();
      _result = result;
      _state = CommandState.success;
      notifyListeners();

      _onSuccess?.call(result);
      _onComplete?.call();

      return Result.success(result);
    } catch (e, stackTrace) {
      final error = AppError.fromException(e, stackTrace);
      _error = error;
      _state = CommandState.error;
      notifyListeners();

      _onError?.call(error);
      _onComplete?.call();

      return Result.failure(error);
    }
  }

  /// Reset the command to idle state
  void reset() {
    _state = CommandState.idle;
    _error = null;
    _result = null;
    notifyListeners();
  }
}

/// Command state
enum CommandState { idle, running, success, error }

/// A command with input parameters
class ParameterizedCommand<T, P> extends ChangeNotifier {
  final Future<T> Function(P params) _action;
  final void Function(T result)? _onSuccess;
  final void Function(AppError error)? _onError;

  CommandState _state = CommandState.idle;
  AppError? _error;
  T? _result;

  ParameterizedCommand({
    required Future<T> Function(P params) action,
    void Function(T result)? onSuccess,
    void Function(AppError error)? onError,
  }) : _action = action,
       _onSuccess = onSuccess,
       _onError = onError;

  CommandState get state => _state;
  bool get isRunning => _state == CommandState.running;
  AppError? get error => _error;
  T? get result => _result;

  /// Execute with parameters
  Future<Result<T>> execute(P params) async {
    if (_state == CommandState.running) {
      return Result.failure(
        AppError.validation(message: 'Command is already running'),
      );
    }

    _state = CommandState.running;
    _error = null;
    notifyListeners();

    try {
      final result = await _action(params);
      _result = result;
      _state = CommandState.success;
      notifyListeners();
      _onSuccess?.call(result);
      return Result.success(result);
    } catch (e, stackTrace) {
      final error = AppError.fromException(e, stackTrace);
      _error = error;
      _state = CommandState.error;
      notifyListeners();
      _onError?.call(error);
      return Result.failure(error);
    }
  }

  void reset() {
    _state = CommandState.idle;
    _error = null;
    _result = null;
    notifyListeners();
  }
}

/// Extension for creating commands from futures
extension CommandExtension<T> on Future<T> Function() {
  /// Create a command from this function
  Command<T> toCommand({
    void Function(T result)? onSuccess,
    void Function(AppError error)? onError,
    void Function()? onComplete,
  }) {
    return Command<T>(
      action: this,
      onSuccess: onSuccess,
      onError: onError,
      onComplete: onComplete,
    );
  }
}
