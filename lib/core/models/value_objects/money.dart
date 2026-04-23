import 'package:freezed_annotation/freezed_annotation.dart';

part 'money.freezed.dart';
part 'money.g.dart';

/// Value object for money/currency operations
/// Ensures consistent handling of amounts across features
@freezed
abstract class Money with _$Money {
  const factory Money({
    required int amountInCents,
    @Default('EUR') String currency,
  }) = _Money;
  const Money._();

  factory Money.fromJson(Map<String, dynamic> json) => _$MoneyFromJson(json);

  /// Create zero money
  factory Money.zero([String currency = 'EUR']) =>
      Money(amountInCents: 0, currency: currency);

  /// Formatted display
  String get formatted {
    final symbol = _getCurrencySymbol(currency);
    return '$symbol${(amountInCents / 100).toStringAsFixed(2)}';
  }

  /// Formatted with explicit currency code
  String get formattedWithCode =>
      '${(amountInCents / 100).toStringAsFixed(2)} EUR';

  /// Check if zero
  bool get isZero => amountInCents == 0;

  /// Check if positive
  bool get isPositive => amountInCents > 0;

  /// Check if negative
  bool get isNegative => amountInCents < 0;

  /// Add money (must be same currency)
  Money operator +(Money other) {
    if (currency != other.currency) {
      throw ArgumentError('Cannot add different currencies');
    }
    return Money(
      amountInCents: amountInCents + other.amountInCents,
      currency: currency,
    );
  }

  /// Subtract money (must be same currency)
  Money operator -(Money other) {
    if (currency != other.currency) {
      throw ArgumentError('Cannot subtract different currencies');
    }
    return Money(
      amountInCents: amountInCents - other.amountInCents,
      currency: currency,
    );
  }

  /// Multiply by scalar
  Money operator *(num scalar) {
    return Money(
      amountInCents: (amountInCents * scalar).round(),
      currency: currency,
    );
  }

  /// Divide by scalar
  Money operator /(num scalar) {
    if (scalar == 0) throw ArgumentError('Cannot divide by zero');
    return Money(
      amountInCents: (amountInCents / scalar).round(),
      currency: currency,
    );
  }

  /// Compare amounts
  bool operator >(Money other) {
    _ensureSameCurrency(other);
    return amountInCents > other.amountInCents;
  }

  bool operator <(Money other) {
    _ensureSameCurrency(other);
    return amountInCents < other.amountInCents;
  }

  bool operator >=(Money other) {
    _ensureSameCurrency(other);
    return amountInCents >= other.amountInCents;
  }

  bool operator <=(Money other) {
    _ensureSameCurrency(other);
    return amountInCents <= other.amountInCents;
  }

  void _ensureSameCurrency(Money other) {
    if (currency != other.currency) {
      throw ArgumentError('Cannot compare different currencies');
    }
  }

  String _getCurrencySymbol(String _) => '€';
}
