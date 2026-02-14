import 'package:freezed_annotation/freezed_annotation.dart';

part 'money.freezed.dart';
part 'money.g.dart';

/// Value object for money/currency operations
/// Ensures consistent handling of amounts across features
@freezed
abstract class Money with _$Money {
  const Money._();

  const factory Money({
    required double amount,
    @Default('USD') String currency,
  }) = _Money;

  factory Money.fromJson(Map<String, dynamic> json) => _$MoneyFromJson(json);

  /// Create zero money
  factory Money.zero([String currency = 'USD']) =>
      Money(amount: 0, currency: currency);

  /// Formatted display
  String get formatted {
    final symbol = _getCurrencySymbol(currency);
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  /// Formatted with explicit currency code
  String get formattedWithCode => '${amount.toStringAsFixed(2)} $currency';

  /// Check if zero
  bool get isZero => amount == 0;

  /// Check if positive
  bool get isPositive => amount > 0;

  /// Check if negative
  bool get isNegative => amount < 0;

  /// Add money (must be same currency)
  Money operator +(Money other) {
    if (currency != other.currency) {
      throw ArgumentError('Cannot add different currencies');
    }
    return Money(amount: amount + other.amount, currency: currency);
  }

  /// Subtract money (must be same currency)
  Money operator -(Money other) {
    if (currency != other.currency) {
      throw ArgumentError('Cannot subtract different currencies');
    }
    return Money(amount: amount - other.amount, currency: currency);
  }

  /// Multiply by scalar
  Money operator *(num scalar) {
    return Money(amount: amount * scalar, currency: currency);
  }

  /// Divide by scalar
  Money operator /(num scalar) {
    if (scalar == 0) throw ArgumentError('Cannot divide by zero');
    return Money(amount: amount / scalar, currency: currency);
  }

  /// Compare amounts
  bool operator >(Money other) {
    _ensureSameCurrency(other);
    return amount > other.amount;
  }

  bool operator <(Money other) {
    _ensureSameCurrency(other);
    return amount < other.amount;
  }

  bool operator >=(Money other) {
    _ensureSameCurrency(other);
    return amount >= other.amount;
  }

  bool operator <=(Money other) {
    _ensureSameCurrency(other);
    return amount <= other.amount;
  }

  void _ensureSameCurrency(Money other) {
    if (currency != other.currency) {
      throw ArgumentError('Cannot compare different currencies');
    }
  }

  String _getCurrencySymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'CAD':
        return 'C\$';
      case 'AUD':
        return 'A\$';
      default:
        return currencyCode;
    }
  }
}
